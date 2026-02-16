#!/bin/bash
# =============================================================================
# subagent-stop.sh - Cursor Sub-agent Stop Hook
# 
# 当 Sub-agent 结束时记录信息并发送通知
# =============================================================================

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

# 检查 hook 是否启用
if ! hook_enabled "SUBAGENT_STOP"; then
    echo '{}'
    exit 0
fi

# 读取 stdin 输入
read -r input

# 提取关键信息
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
subagent_type=$(echo "$input" | jq -r '.subagent_type // .subagentType // "unknown"')
status=$(echo "$input" | jq -r '.status // "completed"')
duration=$(echo "$input" | jq -r '.duration // "0"')
result=$(echo "$input" | jq -r '.result // ""')

# 获取工作目录
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .cwd // "unknown"')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
log_file="$LOG_DIR/subagent-stop.log"

echo "[$timestamp] Sub-agent 结束" >> "$log_file"
echo "  Session: $session_id" >> "$log_file"
echo "  Type: $subagent_type" >> "$log_file"
echo "  Status: $status" >> "$log_file"
echo "  Duration: ${duration}ms" >> "$log_file"
echo "  Workspace: $workspace_name" >> "$log_file"
echo "---" >> "$log_file"

# 发送通知（仅在完成时）
if [ "$status" = "completed" ]; then
    notify_message="工作空间: $workspace_name
Sub-agent: $subagent_type
状态: 完成
耗时: $((duration / 1000))秒"
    
    # 根据 NOTIFY_MIN_DURATION 决定是否发送
    if [ "$NOTIFY_MIN_DURATION" = "0" ] || [ "$duration" -gt "$((NOTIFY_MIN_DURATION * 1000))" ]; then
        notify "Sub-agent 完成" "$notify_message" "success" "$((duration / 1000))"
    fi
fi

# 输出空 JSON
echo '{}'

exit 0
