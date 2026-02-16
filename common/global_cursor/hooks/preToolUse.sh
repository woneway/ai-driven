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

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
# 尝试多种字段名: tool, toolName, name
tool_name=$(echo "$input" | jq -r '.tool // .toolName // .name // "unknown"')

echo "[$timestamp] PreToolUse: $tool_name" >> "$LOG_DIR/tool-use.log"
echo "[$timestamp] Config: global -> workspace (覆盖)" >> "$LOG_DIR/tool-use.log"

echo '{}'
exit 0
