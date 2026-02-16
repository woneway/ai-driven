#!/bin/bash
# =============================================================================
# audit-shell-log.sh - After Shell Execution Hook
# 
# 在 shell 命令执行后记录输出
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

# 截断输出（太长则省略）
if [ ${#output} -gt 500 ]; then
    output="${output:0:500}...[truncated]"
fi

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
log_file="$LOG_DIR/shell-output.log"

echo "[$timestamp] Shell 完成" >> "$log_file"
echo "  Command: $command" >> "$log_file"
echo "  Duration: ${duration}ms" >> "$log_file"
echo "  Output: $output" >> "$log_file"
echo "---" >> "$log_file"

# 输出空 JSON
echo '{}'

exit 0
