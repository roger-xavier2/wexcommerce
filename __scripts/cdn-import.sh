#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
用法:
  ./__scripts/cdn-import.sh [--volume <VOLUME_NAME>] [--in <DIR>] [--create-volume] [--clean]

说明:
  - 把本机目录中的 CDN 文件“原样复制”到 Docker named volume（不打包）
  - 适用于把备份/迁移的 cdn_export_volume 灌入到新的 docker 环境里

参数:
  --volume <VOLUME_NAME>  目标 volume 名称（默认: wexcommerce_cdn）
  --in <DIR>              导入来源目录（默认: ./cdn_export_volume）
  --create-volume          若 volume 不存在则自动创建
  --clean                  导入前清空目标 volume（危险：会删除 volume 内全部文件）
  -h, --help               显示帮助

示例:
  ./__scripts/cdn-import.sh
  ./__scripts/cdn-import.sh --in ./cdn_export_volume --volume wexcommerce_cdn
  ./__scripts/cdn-import.sh --create-volume --clean
EOF
}

VOLUME_NAME="wexcommerce_cdn"
IN_DIR="./cdn_export_volume"
CREATE_VOLUME=false
CLEAN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --volume)
      VOLUME_NAME="${2:-}"; shift 2 ;;
    --in)
      IN_DIR="${2:-}"; shift 2 ;;
    --create-volume)
      CREATE_VOLUME=true; shift ;;
    --clean)
      CLEAN=true; shift ;;
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

if [[ -z "$IN_DIR" ]]; then
  echo "--in 不能为空" >&2
  exit 1
fi

if [[ ! -d "$IN_DIR" ]]; then
  echo "导入目录不存在: $IN_DIR" >&2
  exit 1
fi

if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
  if [[ "$CREATE_VOLUME" == "true" ]]; then
    echo "volume 不存在，正在创建: $VOLUME_NAME"
    docker volume create "$VOLUME_NAME" >/dev/null
  else
    echo "未找到 volume: $VOLUME_NAME（可加 --create-volume 自动创建）" >&2
    exit 1
  fi
fi

echo "准备导入：in=$IN_DIR -> volume=$VOLUME_NAME"
echo "来源文件数：$(find "$IN_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')"

if [[ "$CLEAN" == "true" ]]; then
  echo "注意：已启用 --clean，将清空目标 volume 内全部文件。"
  docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    alpine sh -c "rm -rf /data/* /data/.[!.]* /data/..?* 2>/dev/null || true"
fi

docker run --rm \
  -v "${VOLUME_NAME}:/data" \
  -v "$(pwd)/${IN_DIR}:/seed" \
  alpine sh -c "cp -a /seed/. /data/"

echo "导入完成。"


