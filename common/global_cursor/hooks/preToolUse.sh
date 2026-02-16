#!/bin/bash
# =============================================================================
# preToolUse.sh - Cursor Pre Tool Use Hook
#
# 工具使用前触发
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "PRE_TOOL"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/tool-use.log"

# 尝试多种字段名: tool, toolName, name
tool_name=$(echo "$input" | jq -r '.tool // .toolName // .name // "unknown"')
tool_input=$(echo "$input" | jq -r '.tool_input // .input // "{}"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')

echo "[$timestamp] ===== PreToolUse =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Tool: $tool_name" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录工具输入（截断过长的）
if [ -n "$tool_input" ] && [ "$tool_input" != "{}" ]; then
    tool_input_truncated=$(echo "$tool_input" | head -c 500)
    if [ ${#tool_input} -gt 500 ]; then
        tool_input_truncated="$tool_input_truncated...[truncated]"
    fi
    echo "  Tool Input: $tool_input_truncated" >> "$log_file"
fi

# 记录完整输入 JSON
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

echo '{}'
exit 0
