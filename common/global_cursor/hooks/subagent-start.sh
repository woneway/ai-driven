#!/bin/bash
# =============================================================================
# subagent-start.sh - Cursor Sub-agent Start Hook
# 
# 当 Sub-agent 启动时自动记录信息并发送通知
# 用于追踪 Sub-agent 调用情况
# =============================================================================

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

# 检查 hook 是否启用
if ! hook_enabled "SUBAGENT_START"; then
    echo '{}'
    exit 0
fi

# 读取 stdin 输入（session 数据）
read -r input

# 提取关键信息 - 尝试多种字段名
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // .id // "unknown"')
subagent_type=$(echo "$input" | jq -r '.subagentType // .type // .subagent_type // "unknown"')
description=$(echo "$input" | jq -r '.description // .task // .instruction // "unknown"')
prompt=$(echo "$input" | jq -r '.prompt // .instruction // ""')

# 获取工作目录 - 尝试多种字段名
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .workspace // .cwd // "unknown"')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
log_file="$LOG_DIR/subagent-start.log"

echo "[$timestamp] Sub-agent 启动" >> "$log_file"
echo "  Session: $session_id" >> "$log_file"
echo "  Type: $subagent_type" >> "$log_file"
echo "  Description: $description" >> "$log_file"
echo "  Workspace: $workspace_name" >> "$log_file"
echo "  Config: $CONFIG_SOURCE" >> "$log_file"
echo "---" >> "$log_file"

# 发送通知
notify_message="工作空间: $workspace_name
Sub-agent: $subagent_type
任务: $description"

notify "Sub-agent 启动" "$notify_message" "info" 0

# 输出空 JSON（必须返回有效的 JSON，允许继续执行）
echo '{}'

exit 0
