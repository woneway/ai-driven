#!/bin/bash
# =============================================================================
# audit-tool.sh - Post Tool Use Hook
#
# 在工具执行后记录信息
# =============================================================================

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

# 检查 hook 是否启用
if ! hook_enabled "POST_TOOL"; then
    echo '{}'
    exit 0
fi

# 读取 stdin 输入
read -r input

# 提取工具信息
tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"')
tool_input=$(echo "$input" | jq -r '.tool_input // "{}"')
duration=$(echo "$input" | jq -r '.duration // "0"')
status=$(echo "$input" | jq -r '.status // .success // "success"')
error=$(echo "$input" | jq -r '.error // .failure // ""')

# 提取更多调试信息
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
result=$(echo "$input" | jq -r '.result // .output // ""')

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/tool-use.log"

echo "[$timestamp] ===== Tool 使用 =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Tool: $tool_name" >> "$log_file"
echo "  Duration: ${duration}ms" >> "$log_file"
echo "  Status: $status" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录错误信息（如果有）
if [ -n "$error" ] && [ "$error" != "null" ]; then
    echo "  Error: $error" >> "$log_file"
fi

# 记录工具输入（截断过长的）
if [ -n "$tool_input" ] && [ "$tool_input" != "{}" ]; then
    tool_input_truncated=$(echo "$tool_input" | head -c 500)
    if [ ${#tool_input} -gt 500 ]; then
        tool_input_truncated="$tool_input_truncated...[truncated]"
    fi
    echo "  Tool Input: $tool_input_truncated" >> "$log_file"
fi

# 记录工具输出/结果（截断过长的）
if [ -n "$result" ]; then
    result_truncated=$(echo "$result" | head -c 500)
    if [ ${#result} -gt 500 ]; then
        result_truncated="$result_truncated...[truncated]"
    fi
    echo "  Tool Result: $result_truncated" >> "$log_file"
fi

# 记录完整输入 JSON (用于调试)
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

# 输出空 JSON
echo '{}'

exit 0
