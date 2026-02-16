#!/bin/bash
# =============================================================================
# session-end.sh - Cursor Session End Hook
#
# 当 Cursor 对话结束时自动发送通知
# 精简日志，使用分类日志
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
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // .id // "unknown"')
duration=$(echo "$input" | jq -r '.duration // "0"')
status=$(echo "$input" | jq -r '.status // "completed"')

# workspace
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .workspace // .cwd // "unknown"')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# summary 和 prompt
summary=$(echo "$input" | jq -r '.summary // .message // "任务完成"')
prompt=$(echo "$input" | jq -r '.prompt // .lastPrompt // ""')
error=$(echo "$input" | jq -r '.error // .failure // ""')

# 提取工具调用数
tool_count=$(echo "$input" | jq -r '.tool_count // .tools_used // "0"')

# 提取对话标题
if [ -n "$prompt" ]; then
    title_preview=$(echo "$prompt" | sed 's/[[:space:]]\+/ /g' | head -c 60)
    [ ${#prompt} -gt 60 ] && title_preview="$title_preview..."
else
    title_preview="$summary"
fi

# 格式化耗时
if [ "$duration" -lt 60 ]; then
    duration_str="${duration}秒"
elif [ "$duration" -lt 3600 ]; then
    duration_str="$((duration / 60))分$((duration % 60))秒"
else
    duration_str="$((duration / 3600))小时$(((duration % 3600) / 60))分"
fi

# 根据状态设置通知类型
case "$status" in
    completed|success)
        notify_status="success"
        status_icon="✅"
        notify_title="对话完成"
        ;;
    error|failed)
        notify_status="error"
        status_icon="❌"
        notify_title="对话异常"
        ;;
    cancelled|stopped)
        notify_status="warning"
        status_icon="⏹️"
        notify_title="对话终止"
        ;;
    *)
        notify_status="info"
        status_icon="ℹ️"
        notify_title="对话结束"
        ;;
esac

# 记录日志
if [ "$notify_status" = "error" ]; then
    log_write "session" "error" "$workspace_name | $status_icon $title_preview | $duration_str | 工具:$tool_count"
else
    log_write "session" "success" "$workspace_name | $status_icon $title_preview | $duration_str | 工具:$tool_count"
fi

# 发送通知 - 精简内容
notify_message="**工作空间**: $workspace_name

**任务**: $title_preview

**耗时**: $duration_str | **工具**: $tool_count次 | **状态**: $status_icon $status"

# 如果有错误信息，添加到通知中
if [ -n "$error" ] && [ "$error" != "null" ]; then
    error_preview=$(echo "$error" | head -c 150)
    [ ${#error} -gt 150 ] && error_preview="$error_preview..."
    notify_message="$notify_message

**错误**: $error_preview"
fi

notify "$notify_title" "$notify_message" "$notify_status" "$duration"

# 输出空 JSON（必须返回有效的 JSON）
echo '{}'

exit 0
