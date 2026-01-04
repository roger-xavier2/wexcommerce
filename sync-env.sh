#!/bin/bash

# =============================================================================
# 环境变量同步脚本
# =============================================================================
# 从根目录的 .env.docker 文件同步配置到各个子目录
# =============================================================================

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  环境变量同步脚本${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 检查根目录的 .env.docker 是否存在
if [ ! -f ".env.docker" ]; then
    echo -e "${RED}❌ 错误: 根目录的 .env.docker 文件不存在${NC}"
    echo ""
    echo "请先创建根目录的 .env.docker 文件，或运行以下命令创建默认配置："
    echo "  touch .env.docker"
    exit 1
fi

echo -e "${YELLOW}📄 读取根目录配置文件...${NC}"
echo ""

# 创建临时目录
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# 提取后端配置（WC_ 开头的变量）
echo -e "${YELLOW}🔧 生成后端配置...${NC}"
cat > "$TMP_DIR/backend.env" << 'HEADER'
# wexCommerce Backend Configuration for Docker Production
# 此文件由 sync-env.sh 自动生成
# 请编辑根目录的 .env.docker 文件，然后运行 ./sync-env.sh 同步

HEADER

grep '^WC_' .env.docker >> "$TMP_DIR/backend.env" 2>/dev/null || true

# 提取前端配置（NEXT_PUBLIC_ 开头的变量 + 部分前端需要的变量）
echo -e "${YELLOW}🌐 生成前端配置...${NC}"
cat > "$TMP_DIR/frontend.env" << 'HEADER'
# wexCommerce Frontend Configuration for Docker Production
# 此文件由 sync-env.sh 自动生成
# 请编辑根目录的 .env.docker 文件，然后运行 ./sync-env.sh 同步

HEADER

# 提取所有 NEXT_PUBLIC_ 变量（排除管理后台专用的）
grep '^NEXT_PUBLIC_' .env.docker | \
  grep -v 'WC_CDN_USERS' | \
  grep -v 'WC_CDN_TEMP_USERS' | \
  grep -v 'WC_CDN_TEMP_CATEGORIES' | \
  grep -v 'WC_CDN_TEMP_PRODUCTS' \
  >> "$TMP_DIR/frontend.env" 2>/dev/null || true

# 提取管理后台配置
echo -e "${YELLOW}🔐 生成管理后台配置...${NC}"
cat > "$TMP_DIR/admin.env" << 'HEADER'
# wexCommerce Admin Configuration for Docker Production
# 此文件由 sync-env.sh 自动生成
# 请编辑根目录的 .env.docker 文件，然后运行 ./sync-env.sh 同步

HEADER

# 管理后台需要的变量
grep '^NEXT_PUBLIC_WC_SERVER_API_HOST' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_CLIENT_API_HOST' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_DEFAULT_LANGUAGE' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_PAGE_SIZE' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_ORDERS_PAGE_SIZE' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_CDN_USERS' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_CDN_TEMP_USERS' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_CDN_CATEGORIES' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_CDN_TEMP_CATEGORIES' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_CDN_PRODUCTS' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true
grep '^NEXT_PUBLIC_WC_CDN_TEMP_PRODUCTS' .env.docker >> "$TMP_DIR/admin.env" 2>/dev/null || true

# 备份现有配置
echo ""
echo -e "${YELLOW}💾 备份现有配置...${NC}"
BACKUP_DIR="./backups/env-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "backend/.env.docker" ]; then
    cp backend/.env.docker "$BACKUP_DIR/backend.env.docker"
    echo "  ✓ 已备份: backend/.env.docker → $BACKUP_DIR/"
fi

if [ -f "frontend/.env.docker" ]; then
    cp frontend/.env.docker "$BACKUP_DIR/frontend.env.docker"
    echo "  ✓ 已备份: frontend/.env.docker → $BACKUP_DIR/"
fi

if [ -f "admin/.env.docker" ]; then
    cp admin/.env.docker "$BACKUP_DIR/admin.env.docker"
    echo "  ✓ 已备份: admin/.env.docker → $BACKUP_DIR/"
fi

# 复制新配置
echo ""
echo -e "${YELLOW}📋 同步配置到子目录...${NC}"

cp "$TMP_DIR/backend.env" "backend/.env.docker"
echo -e "  ${GREEN}✓ backend/.env.docker${NC}"

cp "$TMP_DIR/frontend.env" "frontend/.env.docker"
echo -e "  ${GREEN}✓ frontend/.env.docker${NC}"

cp "$TMP_DIR/admin.env" "admin/.env.docker"
echo -e "  ${GREEN}✓ admin/.env.docker${NC}"

# 显示统计信息
echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}✅ 配置同步完成！${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "📊 配置统计："
echo "  后端配置:     $(grep -c '^WC_' backend/.env.docker 2>/dev/null || echo 0) 个变量"
echo "  前端配置:     $(grep -c '^NEXT_PUBLIC_' frontend/.env.docker 2>/dev/null || echo 0) 个变量"
echo "  管理后台配置: $(grep -c '^NEXT_PUBLIC_' admin/.env.docker 2>/dev/null || echo 0) 个变量"
echo ""
echo "🔍 查看配置："
echo "  cat backend/.env.docker"
echo "  cat frontend/.env.docker"
echo "  cat admin/.env.docker"
echo ""
echo "📦 备份位置："
echo "  $BACKUP_DIR/"
echo ""
echo "🚀 下一步："
echo "  docker-compose up -d --build"
echo ""

