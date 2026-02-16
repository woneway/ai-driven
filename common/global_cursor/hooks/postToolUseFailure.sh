#!/bin/bash
# =============================================================================
# postToolUseFailure.sh - Cursor Post Tool Use Failure Hook
#
# 工具使用失败时触发
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "POST_TOOL_FAILURE"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
# 尝试多种字段名
tool_name=$(echo "$input" | jq -r '.tool // .toolName // .name // "unknown"')
error=$(echo "$input" | jq -r '.error // .failure // .message // "unknown"')

echo "[$timestamp] PostToolUseFailure: $tool_name - $error" >> "$LOG_DIR/tool-use.log"
echo "[$timestamp] Config: $CONFIG_SOURCE" >> "$LOG_DIR/tool-use.log"

echo '{}'
exit 0
