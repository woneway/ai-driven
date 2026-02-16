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

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/agent-thought.log"

# 提取信息
thought=$(echo "$input" | jq -r '.thought // .reasoning // "N/A"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
model=$(echo "$input" | jq -r '.model // .ai_model // "unknown"')

echo "[$timestamp] ===== Agent 思考 =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Model: $model" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录思考内容（截断过长的）
if [ -n "$thought" ]; then
    thought_truncated=$(echo "$thought" | head -c 1000)
    if [ ${#thought} -gt 1000 ]; then
        thought_truncated="$thought_truncated...[truncated, original length: ${#thought}]"
    fi
    echo "  Thought:" >> "$log_file"
    echo "$thought_truncated" | sed 's/^/    /' >> "$log_file"
fi

# 记录完整输入 JSON
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

echo '{}'
exit 0
