#!/bin/bash
# =============================================================================
# beforeMCPExecution.sh - Cursor Before MCP Execution Hook
#
# MCP 工具执行前触发
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "BEFORE_MCP"; then
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
mcp_input=$(echo "$input" | jq -r '.input // .parameters // .args // "{}"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')

echo "[$timestamp] ===== BeforeMCP =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  MCP Tool: $mcp_tool" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录 MCP 输入（截断过长的）
if [ -n "$mcp_input" ] && [ "$mcp_input" != "{}" ]; then
    mcp_input_truncated=$(echo "$mcp_input" | head -c 500)
    if [ ${#mcp_input} -gt 500 ]; then
        mcp_input_truncated="$mcp_input_truncated...[truncated]"
    fi
    echo "  MCP Input: $mcp_input_truncated" >> "$log_file"
fi

# 记录完整输入 JSON
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

echo '{}'
exit 0
