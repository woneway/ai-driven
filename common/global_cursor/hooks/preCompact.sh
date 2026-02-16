#!/bin/bash
# =============================================================================
# preCompact.sh - Cursor Pre Compact Hook
#
# 上下文窗口压缩前触发
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "PRE_COMPACT"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
# 尝试多种字段名
reason=$(echo "$input" | jq -r '.reason // .trigger // .cause // "unknown"')

echo "[$timestamp] PreCompact: $reason" >> "$LOG_DIR/compact.log"
echo "[$timestamp] Config: $CONFIG_SOURCE" >> "$LOG_DIR/compact.log"

echo '{}'
exit 0
