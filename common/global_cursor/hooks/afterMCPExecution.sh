#!/bin/bash
# =============================================================================
# afterMCPExecution.sh - Cursor After MCP Execution Hook
#
# MCP 工具执行后触发
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "AFTER_MCP"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/mcp.log"

# 尝试多种字段名
mcp_tool=$(echo "$input" | jq -r '.tool // .server // .name // .toolName // "unknown"')
mcp_result=$(echo "$input" | jq -r '.result // .output // .response // ""')
duration=$(echo "$input" | jq -r '.duration // "0"')
status=$(echo "$input" | jq -r '.status // .success // "success"')
error=$(echo "$input" | jq -r '.error // .failure // ""')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')

echo "[$timestamp] ===== AfterMCP =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  MCP Tool: $mcp_tool" >> "$log_file"
echo "  Duration: ${duration}ms" >> "$log_file"
echo "  Status: $status" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录错误信息（如果有）
if [ -n "$error" ] && [ "$error" != "null" ]; then
    echo "  Error: $error" >> "$log_file"
fi

# 记录 MCP 结果（截断过长的）
if [ -n "$mcp_result" ]; then
    mcp_result_truncated=$(echo "$mcp_result" | head -c 500)
    if [ ${#mcp_result} -gt 500 ]; then
        mcp_result_truncated="$mcp_result_truncated...[truncated]"
    fi
    echo "  MCP Result: $mcp_result_truncated" >> "$log_file"
fi

# 记录完整输入 JSON
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

echo '{}'
exit 0
