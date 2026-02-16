#!/bin/bash
# =============================================================================
# afterAgentThought.sh - Cursor After Agent Thought Hook
#
# 当 Agent 思考后记录信息
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "AFTER_AGENT_THOUGHT"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
log_file="$LOG_DIR/agent-thought.log"

echo "[$timestamp] Agent 思考" >> "$log_file"
echo "$input" | jq -r '.thought // .reasoning // "N/A"' | head -c 200 >> "$log_file"
echo "" >> "$log_file"
echo "---" >> "$log_file"

echo '{}'
exit 0
