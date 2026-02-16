#!/bin/bash
# =============================================================================
# beforeReadFile.sh - Cursor Before Read File Hook
#
# 读取文件前触发
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "BEFORE_READ"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
# 尝试多种字段名
file_path=$(echo "$input" | jq -r '.file_path // .path // .filePath // .file // "unknown"')

echo "[$timestamp] BeforeReadFile: $file_path" >> "$LOG_DIR/file-access.log"
echo "[$timestamp] Config: $CONFIG_SOURCE" >> "$LOG_DIR/file-access.log"

echo '{}'
exit 0
