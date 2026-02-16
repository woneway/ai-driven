#!/bin/bash
# =============================================================================
# beforeSubmitPrompt.sh - Cursor Before Submit Prompt Hook
#
# 提交 prompt 前触发
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "BEFORE_SUBMIT"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/prompt.log"

# 提取信息
prompt=$(echo "$input" | jq -r '.prompt // .message // ""')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')

echo "[$timestamp] ===== BeforeSubmitPrompt =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录 prompt（截断过长的）
if [ -n "$prompt" ]; then
    prompt_truncated=$(echo "$prompt" | head -c 500)
    if [ ${#prompt} -gt 500 ]; then
        prompt_truncated="$prompt_truncated...[truncated, original length: ${#prompt}]"
    fi
    echo "  Prompt: $prompt_truncated" >> "$log_file"
fi

# 记录完整输入 JSON
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

echo '{}'
exit 0
