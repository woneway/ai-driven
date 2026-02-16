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

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
# 尝试多种字段名
mcp_tool=$(echo "$input" | jq -r '.tool // .server // .name // .toolName // "unknown"')

echo "[$timestamp] AfterMCPExecution: $mcp_tool" >> "$LOG_DIR/mcp.log"
echo "[$timestamp] Config: $CONFIG_SOURCE" >> "$LOG_DIR/mcp.log"

echo '{}'
exit 0
