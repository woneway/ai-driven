#!/bin/bash
# =============================================================================
# audit-tool.sh - Post Tool Use Hook
#
# 只记录关键工具调用（写入操作），写入分类日志
# =============================================================================

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

# 检查 hook 是否启用
if ! hook_enabled "POST_TOOL"; then
    echo '{}'
    exit 0
fi

# 读取 stdin 输入
read -r input

# 提取工具信息
tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"')
tool_input=$(echo "$input" | jq -r '.tool_input // "{}"')
duration=$(echo "$input" | jq -r '.duration // "0"')
status=$(echo "$input" | jq -r '.status // .success // "success"')
error=$(echo "$input" | jq -r '.error // .failure // ""')

# 提取工作空间
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .workspace // .cwd // ""')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "unknown")

# 判断工具类型
if is_readonly_tool "$tool_name"; then
    # 只读工具不记录详细日志
    echo '{}'
    exit 0
fi

# 判断是否为关键工具
if ! is_critical_tool "$tool_name"; then
    # 非关键工具也不记录
    echo '{}'
    exit 0
fi

# 格式化耗时
if [ "$duration" -lt 1000 ]; then
    duration_str="${duration}ms"
elif [ "$duration" -lt 60000 ]; then
    duration_str="$((duration / 1000))秒$((duration % 1000))ms"
else
    duration_str="$((duration / 60000))分$(((duration % 60000) / 1000))秒"
fi

# 构建简洁的日志内容
case "$tool_name" in
    Write)
        path=$(echo "$tool_input" | jq -r '.path // "unknown"')
        log_message="Write: $(basename "$path")"
        ;;
    Edit)
        path=$(echo "$tool_input" | jq -r '.path // "unknown"')
        log_message="Edit: $(basename "$path")"
        ;;
    Delete)
        path=$(echo "$tool_input" | jq -r '.path // "unknown"')
        log_message="Delete: $(basename "$path")"
        ;;
    Shell|Bash)
        command=$(echo "$tool_input" | jq -r '.command // "unknown"')
        # 截断过长的命令
        if [ ${#command} -gt 100 ]; then
            command="${command:0:100}..."
        fi
        log_message="Shell: $command"
        ;;
    GenerateImage)
        log_message="GenerateImage"
        ;;
    *)
        log_message="$tool_name"
        ;;
esac

# 记录到日志文件
if [ "$status" = "success" ] || [ "$status" = "completed" ]; then
    log_write "tool" "success" "$workspace_name | $log_message | $duration_str"
else
    log_write "tool" "error" "$workspace_name | $log_message | 失败: ${error:0:100}"
    
    # 错误时发送通知
    notify "工具执行失败" "**工作空间**: $workspace_name

**工具**: $tool_name
**操作**: $log_message
**耗时**: $duration_str
**错误**: ${error:0:200}" "error" "0"
fi

# 输出空 JSON
echo '{}'

exit 0
