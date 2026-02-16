#!/bin/bash
# =============================================================================
# session-end.sh - Cursor Session End Hook
# 
# 当 Cursor 对话结束时自动发送通知
# 读取 session 信息并发送钉钉通知
# =============================================================================

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

# 检查 hook 是否启用
if ! hook_enabled "SESSION_END"; then
    echo '{}'
    exit 0
fi

# 读取 stdin 输入（session 数据）
read -r input

# 提取关键信息
session_id=$(echo "$input" | jq -r '.sessionId // "unknown"')
duration=$(echo "$input" | jq -r '.duration // "0"')
status=$(echo "$input" | jq -r '.status // "completed"')
workspace=$(echo "$input" | jq -r '.workspacePath // .workspace // "unknown"')
summary=$(echo "$input" | jq -r '.summary // .message // "任务完成"')
prompt=$(echo "$input" | jq -r '.prompt // .lastPrompt // ""')

# 获取工作空间名称
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# 提取对话标题（从 prompt 中截取前 50 字符）
if [ -n "$prompt" ]; then
    title_preview=$(echo "$prompt" | head -c 50 | tr '\n' ' ')
    if [ ${#prompt} -gt 50 ]; then
        title_preview="$title_preview..."
    fi
else
    title_preview="$summary"
fi

# 发送通知
notify_message="工作空间: $workspace_name
对话: $title_preview
耗时: ${duration}秒
状态: $status"

notify "Cursor 对话结束" "$notify_message" "$status" "$duration"

# 输出空 JSON（必须返回有效的 JSON）
echo '{}'

exit 0
