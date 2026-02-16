#!/bin/bash
# =============================================================================
# audit-shell-log.sh - After Shell Execution Hook
#
# 只记录关键 shell 命令的输出
# =============================================================================

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

# 检查 hook 是否启用
if ! hook_enabled "AFTER_SHELL"; then
    echo '{}'
    exit 0
fi

# 读取 stdin 输入
read -r input

# 提取命令、输出和耗时
command=$(echo "$input" | jq -r '.command // ""')
output=$(echo "$input" | jq -r '.output // ""')
duration=$(echo "$input" | jq -r '.duration // "0"')
exit_code=$(echo "$input" | jq -r '.exit_code // .exitCode // .code // "-1"')

# workspace 信息
workspace=$(echo "$input" | jq -r '.workspace_roots[0] // .workspacePath // .workspace // .cwd // "unknown"')
workspace_name=$(basename "$workspace" 2>/dev/null || echo "$workspace")

# 判断是否为关键命令
is_critical_command() {
    local cmd="$1"
    case "$cmd" in
        git*|npm*|yarn|pnpm|docker*|make|cmake|gradle|.*py|*pip*|*node*|.*sh|curl|wget)
            return 0
            ;;
        *)
            # 检查是否包含危险操作
            echo "$cmd" | grep -qE 'rm -rf|del -rf|sudo|chmod|chown' && return 0
            return 1
            ;;
    esac
}

# 只记录关键命令
if ! is_critical_command "$command"; then
    echo '{}'
    exit 0
fi

# 格式化耗时
if [ "$duration" -lt 1000 ]; then
    duration_str="${duration}ms"
elif [ "$duration" -lt 60000 ]; then
    duration_str="$((duration / 1000))秒"
else
    duration_str="$((duration / 60000))分$(((duration % 60000) / 1000))秒"
fi

# 截断命令显示
cmd_display="$command"
[ ${#cmd_display} -gt 60 ] && cmd_display="${cmd_display:0:60}..."

# 记录日志 - 使用新的 log_write 函数
if [ "$exit_code" = "0" ]; then
    log_write "shell" "success" "$workspace_name | $cmd_display | $duration_str | ✓"
else
    # 失败时记录错误输出
    error_preview=$(echo "$output" | head -c 100 | tr '\n' ' ')
    log_write "shell" "error" "$workspace_name | $cmd_display | $duration_str | ✗ $error_preview"
    
    # 失败时发送通知
    notify "Shell命令失败" "**工作空间**: $workspace_name

**命令**: \`$cmd_display\`
**耗时**: $duration_str
**退出码**: $exit_code

**错误输出**: ${output:0:200}" "error" "0"
fi

# 输出空 JSON
echo '{}'

exit 0
