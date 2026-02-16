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

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/compact.log"

# 尝试多种字段名
reason=$(echo "$input" | jq -r '.reason // .trigger // .cause // "unknown"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
token_count=$(echo "$input" | jq -r '.token_count // .tokens // "unknown"')

echo "[$timestamp] ===== PreCompact =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Reason: $reason" >> "$log_file"
echo "  Token Count: $token_count" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录完整输入 JSON
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

echo '{}'
exit 0
