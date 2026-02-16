#!/bin/bash
# =============================================================================
# audit-shell.sh - Before Shell Execution Hook
#
# 记录关键 shell 命令，对危险命令发送通知
# =============================================================================

# 加载配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

# 检查 hook 是否启用
if ! hook_enabled "BEFORE_SHELL"; then
    echo '{"permission": "allow"}'
    exit 0
fi

# 读取 stdin 输入
read -r input

# 提取命令和工作目录
command=$(echo "$input" | jq -r '.command // ""')
cwd=$(echo "$input" | jq -r '.cwd // "."')

# 获取工作空间名称
workspace_name=$(basename "$cwd" 2>/dev/null || echo "$cwd")

# 判断是否为关键命令（需要记录的）
is_critical_command() {
    local cmd="$1"
    # git、npm、docker、make 等开发命令
    case "$cmd" in
        git*|npm*|yarn|pnpm|docker*|make|cmake|gradle|.*py|*pip*|*node*|.*sh)
            return 0
            ;;
        *)
            # 检查是否包含危险操作
            echo "$cmd" | grep -qE 'rm -rf|del -rf|sudo|chmod|chown|: \(\)' && return 0
            return 1
            ;;
    esac
}

# 判断是否为危险命令（需要通知的）
is_dangerous_command() {
    local cmd="$1"
    echo "$cmd" | grep -qE 'rm -rf|del -rf|: \(\)|shutdown|reboot' && return 0
    return 1
}

# 只记录关键命令
if is_critical_command "$command"; then
    # 截断过长的命令
    cmd_display="$command"
    if [ ${#cmd_display} -gt 80 ]; then
        cmd_display="${cmd_display:0:80}..."
    fi
    
    if is_dangerous_command "$command"; then
        # 危险命令记录错误级别并发送通知
        log_write "shell" "error" "$workspace_name | ⚠️ $cmd_display"
        notify "危险Shell命令" "**工作空间**: $workspace_name

**命令**: \`$cmd_display\`

> 已被执行，请确认安全" "warning" "0"
    else
        log_write "shell" "info" "$workspace_name | $cmd_display"
    fi
fi

# 允许执行
echo '{"permission": "allow"}'

exit 0
