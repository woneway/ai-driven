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
result=$(echo "$input" | jq -r '.result // .output // ""')
error=$(echo "$input" | jq -r '.error // .failure // ""')

# 获取工作目录
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .cwd // "unknown"')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# 提取更多调试信息
model=$(echo "$input" | jq -r '.model // .ai_model // "unknown"')
parent_session=$(echo "$input" | jq -r '.parent_session // .parentSession // ""')

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/subagent-stop.log"

echo "[$timestamp] ===== Sub-agent 结束 =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Parent Session: $parent_session" >> "$log_file"
echo "  Type: $subagent_type" >> "$log_file"
echo "  Model: $model" >> "$log_file"
echo "  Status: $status" >> "$log_file"
echo "  Duration: ${duration}ms" >> "$log_file"
echo "  Workspace: $workspace" >> "$log_file"
echo "  Workspace Name: $workspace_name" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录错误信息（如果有）
if [ -n "$error" ] && [ "$error" != "null" ]; then
    echo "  Error: $error" >> "$log_file"
fi

# 记录结果（截断过长的）
if [ -n "$result" ]; then
    result_truncated=$(echo "$result" | head -c 500)
    if [ ${#result} -gt 500 ]; then
        result_truncated="$result_truncated...[truncated]"
    fi
    echo "  Result: $result_truncated" >> "$log_file"
fi

# 记录完整输入 JSON (用于调试)
if [ -n "$input" ]; then
    echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"
fi

echo "=============================" >> "$log_file"

# 发送通知
# 格式化耗时
duration_sec=$((duration / 1000))
if [ "$duration_sec" -lt 60 ]; then
    duration_str="${duration_sec}秒"
elif [ "$duration_sec" -lt 3600 ]; then
    duration_str="$((duration_sec / 60))分${duration_sec % 60}秒"
else
    duration_str="$((duration_sec / 3600))小时$(((duration_sec % 3600) / 60))分"
fi

# 根据状态设置通知类型
if [ "$status" = "completed" ] || [ "$status" = "success" ]; then
    notify_status="success"
    status_icon="✅"
elif [ "$status" = "error" ] || [ "$status" = "failed" ]; then
    notify_status="error"
    status_icon="❌"
else
    notify_status="info"
    status_icon="ℹ️"
fi

# 获取描述信息
description=$(echo "$input" | jq -r '.description // .task // .instruction // ""')
desc_preview=$(echo "$description" | head -c 100)

# 根据 subagent 类型和耗时决定是否通知
# 重要类型或耗时较长时才通知
should_notify=false
case "$subagent_type" in
    *explore*|*browser*|*generalPurpose*)
        # 这些是重要任务类型
        should_notify=true
        ;;
    *)
        # 其他类型，超过 30 秒才通知
        if [ "$duration_sec" -gt 30 ]; then
            should_notify=true
        fi
        ;;
esac

if [ "$should_notify" = true ]; then
    if [ "$notify_status" = "error" ]; then
        # 失败时总是通知
        notify_message="**工作空间**: $workspace_name

**Sub-agent**: $subagent_type

**任务**: $desc_preview

**耗时**: $duration_str | **状态**: $status"

        notify "❌ Sub-agent 执行失败" "$notify_message" "error" "$duration_sec"
    elif [ "$notify_status" = "success" ]; then
        notify_message="**工作空间**: $workspace_name

**Sub-agent**: $subagent_type

**任务**: $desc_preview

**耗时**: $duration_str"

        notify "Sub-agent 完成" "$notify_message" "success" "$duration_sec"
    fi
fi

# 输出空 JSON
echo '{}'

exit 0
