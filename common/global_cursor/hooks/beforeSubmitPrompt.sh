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

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
prompt=$(echo "$input" | jq -r '.prompt // .message // ""' | head -c 100)

echo "[$timestamp] BeforeSubmitPrompt: $prompt..." >> "$LOG_DIR/prompt.log"

echo '{}'
exit 0
