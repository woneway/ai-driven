#!/bin/bash
# =============================================================================
# afterAgentResponse.sh - Cursor After Agent Response Hook
#
# 当 Agent 响应后记录信息
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "AFTER_AGENT_RESPONSE"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/agent-response.log"

# 提取信息
message=$(echo "$input" | jq -r '.message // .response // "N/A"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
model=$(echo "$input" | jq -r '.model // .ai_model // "unknown"')
token_usage=$(echo "$input" | jq -r '.token_usage // .tokens // .usage // "{}"')

echo "[$timestamp] ===== Agent 响应 =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Model: $model" >> "$log_file"
echo "  Token Usage: $token_usage" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录消息内容（截断过长的）
if [ -n "$message" ]; then
    message_truncated=$(echo "$message" | head -c 500)
    if [ ${#message} -gt 500 ]; then
        message_truncated="$message_truncated...[truncated, original length: ${#message}]"
    fi
    echo "  Message:" >> "$log_file"
    echo "$message_truncated" | sed 's/^/    /' >> "$log_file"
fi

# 记录完整输入 JSON
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

echo '{}'
exit 0
