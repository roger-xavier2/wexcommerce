#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
用法:
  ./__scripts/cdn-export.sh [--volume <VOLUME_NAME>] [--out <DIR>]

说明:
  - 把 Docker named volume（默认: wexcommerce_cdn）里的 CDN 文件“原样复制”到本机目录（不打包）
  - 适用于把 Docker 内上传的图片导出到宿主机，后续可用 cdn-import.sh 灌回新环境

参数:
  --volume <VOLUME_NAME>  要导出的 volume 名称（默认: wexcommerce_cdn）
  --out <DIR>             导出目录（默认: ./cdn_export_volume）
  -h, --help              显示帮助

示例:
  ./__scripts/cdn-export.sh
  ./__scripts/cdn-export.sh --volume wexcommerce_cdn --out ./cdn_export_volume
EOF
}

VOLUME_NAME="wexcommerce_cdn"
OUT_DIR="./cdn_export_volume"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --volume)
      VOLUME_NAME="${2:-}"; shift 2 ;;
    --out)
      OUT_DIR="${2:-}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "未知参数: $1" >&2
      usage
      exit 2 ;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "未找到 docker 命令，请先安装/启动 Docker。" >&2
  exit 1
fi

if [[ -z "$VOLUME_NAME" ]]; then
  echo "--volume 不能为空" >&2
  exit 1
fi

if [[ -z "$OUT_DIR" ]]; then
  echo "--out 不能为空" >&2
  exit 1
fi

if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
  echo "未找到 volume: $VOLUME_NAME" >&2
  echo "可用卷列表（包含 cdn 的行）：" >&2
  docker volume ls | grep -i cdn || true
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "准备导出：volume=$VOLUME_NAME -> out=$OUT_DIR"

# 注意：使用 /data/. 和 /backup/ 的方式可保留目录结构
docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "$(pwd)/${OUT_DIR}:/backup" \
  alpine sh -c "cp -a /data/. /backup/"

echo "导出完成。"
echo "文件数：$(find "$OUT_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')"
echo "目录数：$(find "$OUT_DIR" -type d 2>/dev/null | wc -l | tr -d ' ')"


