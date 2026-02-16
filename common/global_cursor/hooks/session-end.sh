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

# 提取关键信息 - 尝试多种可能的字段名
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // .id // "unknown"')
duration=$(echo "$input" | jq -r '.duration // "0"')
status=$(echo "$input" | jq -r '.status // "completed"')

# workspace: 尝试多种字段名
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .workspace // .cwd // "unknown"')

summary=$(echo "$input" | jq -r '.summary // .message // "任务完成"')
prompt=$(echo "$input" | jq -r '.prompt // .lastPrompt // ""')
error=$(echo "$input" | jq -r '.error // .failure // ""')

# 提取更多调试信息
model=$(echo "$input" | jq -r '.model // .ai_model // "unknown"')
token_usage=$(echo "$input" | jq -r '.token_usage // .tokens // .usage // "{}"')
tool_count=$(echo "$input" | jq -r '.tool_count // .tools_used // "0"')

# 获取工作空间名称
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/session-end.log"

echo "[$timestamp] ===== 会话结束 =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Duration: ${duration}s" >> "$log_file"
echo "  Status: $status" >> "$log_file"
echo "  Workspace: $workspace" >> "$log_file"
echo "  Workspace Name: $workspace_name" >> "$log_file"
echo "  Model: $model" >> "$log_file"
echo "  Tool Count: $tool_count" >> "$log_file"
echo "  Token Usage: $token_usage" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录错误信息（如果有）
if [ -n "$error" ] && [ "$error" != "null" ]; then
    echo "  Error: $error" >> "$log_file"
fi

# 记录完整输入 JSON (用于调试)
if [ -n "$input" ]; then
    echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"
fi

# 记录关键环境变量
echo "  ENV - PWD: $PWD" >> "$log_file"

echo "=============================" >> "$log_file"

# 提取对话标题（从 prompt 中截取前 80 字符，更清晰）
if [ -n "$prompt" ]; then
    # 移除多余空白字符
    title_preview=$(echo "$prompt" | sed 's/[[:space:]]\+/ /g' | head -c 80)
    if [ ${#prompt} -gt 80 ]; then
        title_preview="$title_preview..."
    fi
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

# 根据状态设置通知类型和标题
if [ "$status" = "completed" ] || [ "$status" = "success" ]; then
    notify_status="success"
    status_icon="✅"
    notify_title="Cursor 对话结束"
elif [ "$status" = "error" ] || [ "$status" = "failed" ]; then
    notify_status="error"
    status_icon="❌"
    notify_title="⚠️ Cursor 对话异常结束"
elif [ "$status" = "cancelled" ] || [ "$status" = "stopped" ]; then
    notify_status="warning"
    status_icon="⏹️"
    notify_title="⏹️ Cursor 对话已终止"
else
    notify_status="info"
    status_icon="ℹ️"
    notify_title="Cursor 对话结束"
fi

# 发送通知 - 优化内容格式
notify_message="**工作空间**: $workspace_name

**对话内容**: $title_preview

**耗时**: $duration_str | **状态**: $status_icon $status | **工具调用**: $tool_count"

# 如果有错误信息，添加到通知中
if [ -n "$error" ] && [ "$error" != "null" ]; then
    error_preview=$(echo "$error" | head -c 200)
    if [ ${#error} -gt 200 ]; then
        error_preview="$error_preview..."
    fi
    notify_message="$notify_message

**错误信息**: $error_preview"
fi

notify "$notify_title" "$notify_message" "$notify_status" "$duration"

# 输出空 JSON（必须返回有效的 JSON）
echo '{}'

exit 0
