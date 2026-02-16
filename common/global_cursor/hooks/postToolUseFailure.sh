#!/bin/bash
# =============================================================================
# postToolUseFailure.sh - Cursor Post Tool Use Failure Hook
#
# 工具使用失败时触发 - 发送钉钉通知提醒用户
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "POST_TOOL_FAILURE"; then
    echo '{}'
    exit 0
fi

read -r input

# 尝试多种字段名
tool_name=$(echo "$input" | jq -r '.tool // .toolName // .name // "unknown"')
error=$(echo "$input" | jq -r '.error // .failure // .message // "unknown"')
tool_input=$(echo "$input" | jq -r '.tool_input // .input // "{}"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
duration=$(echo "$input" | jq -r '.duration // "0"')

# workspace 信息
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .workspace // .cwd // "unknown"')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# 记录日志 - 使用新的 log_write 函数
error_preview=$(echo "$error" | head -c 100)
log_write "tool" "error" "$workspace_name | $tool_name | ${error_preview}..."

# 截断错误信息用于通知
error_notify=$(echo "$error" | head -c 200)
[ ${#error} -gt 200 ] && error_notify="$error_notify..."

# 截断工具输入用于通知
input_notify=$(echo "$tool_input" | head -c 100)

# 发送钉钉通知 - 精简内容
notify_message="**工作空间**: $workspace_name

**工具**: $tool_name
**错误**: $error_notify"

notify "⚠️ 工具失败" "$notify_message" "error" "0"

echo '{}'
exit 0
