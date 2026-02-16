#!/bin/bash
# =============================================================================
# session-start.sh - Cursor Session Start Hook
#
# 当 Cursor 会话开始时记录信息
# =============================================================================

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

# 检查 hook 是否启用
if ! hook_enabled "SESSION_START"; then
    echo '{}'
    exit 0
fi

# 读取 stdin 输入
read -r input

# 提取关键信息
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
is_background=$(echo "$input" | jq -r '.is_background_agent // false')
composer_mode=$(echo "$input" | jq -r '.composer_mode // "agent"')

# workspace: 尝试多种字段名
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .workspace // .cwd // "unknown"')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# 提取更多调试信息
user=$(echo "$input" | jq -r '.user // .username // .operator // "unknown"')
model=$(echo "$input" | jq -r '.model // .ai_model // "unknown"')
prompt=$(echo "$input" | jq -r '.prompt // .message // ""')

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/session-start.log"

echo "[$timestamp] ===== 会话开始 =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Mode: $composer_mode" >> "$log_file"
echo "  Background: $is_background" >> "$log_file"
echo "  Workspace: $workspace" >> "$log_file"
echo "  Workspace Name: $workspace_name" >> "$log_file"
echo "  User: $user" >> "$log_file"
echo "  Model: $model" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Parent PID: $PPID" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录完整输入 JSON (用于调试)
if [ -n "$input" ]; then
    echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"
fi

# 记录关键环境变量 (用于调试环境问题)
echo "  ENV - PWD: $PWD" >> "$log_file"
echo "  ENV - HOME: $HOME" >> "$log_file"

echo "=============================" >> "$log_file"

# 输出空 JSON（允许继续）
echo '{}'

exit 0
