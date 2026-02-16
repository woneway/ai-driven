#!/bin/bash
# =============================================================================
# audit-shell.sh - Before Shell Execution Hook
# 
# 在执行 shell 命令前审计，可阻止危险命令
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

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
log_file="$LOG_DIR/shell-execution.log"

echo "[$timestamp] Shell 执行" >> "$log_file"
echo "  Command: $command" >> "$log_file"
echo "  CWD: $cwd" >> "$log_file"

# 检查危险命令（由 hooks.json 的 matcher 过滤）
# 这里可以做额外的检查

# 允许执行
echo '{"permission": "allow"}'

exit 0
