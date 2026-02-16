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

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/tool-failure.log"

# 尝试多种字段名
tool_name=$(echo "$input" | jq -r '.tool // .toolName // .name // "unknown"')
error=$(echo "$input" | jq -r '.error // .failure // .message // "unknown"')
tool_input=$(echo "$input" | jq -r '.tool_input // .input // "{}"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
duration=$(echo "$input" | jq -r '.duration // "0"')

# workspace 信息
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .workspace // .cwd // "unknown"')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

echo "[$timestamp] ===== Tool 使用失败 =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Tool: $tool_name" >> "$log_file"
echo "  Duration: ${duration}ms" >> "$log_file"
echo "  Error: $error" >> "$log_file"
echo "  Workspace: $workspace_name" >> "$log_file"
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

# 记录完整输入 JSON (用于调试)
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

# 发送钉钉通知 - 仅通知重要错误
# 截断错误信息
error_preview=$(echo "$error" | head -c 200)
if [ ${#error} -gt 200 ]; then
    error_preview="$error_preview..."
fi

# 截断工具输入
input_preview=$(echo "$tool_input" | head -c 100)

notify_message="**工作空间**: $workspace_name

**失败工具**: $tool_name

**错误信息**: $error_preview

**工具输入**: $input_preview"

# 发送通知（工具失败总是通知，因为需要用户关注）
notify "⚠️ 工具执行失败" "$notify_message" "error" "0"

echo '{}'
exit 0
