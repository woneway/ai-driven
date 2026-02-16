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
exit_code=$(echo "$input" | jq -r '.exit_code // .exitCode // .code // "-1"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')

# 截断输出（默认2000字符，比之前500更合理）
max_output_length=2000
if [ ${#output} -gt $max_output_length ]; then
    output="${output:0:$max_output_length}...[truncated, original length: ${#output}]"
fi

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/shell-output.log"

echo "[$timestamp] ===== Shell 完成 =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  Command: $command" >> "$log_file"
echo "  Duration: ${duration}ms" >> "$log_file"
echo "  Exit Code: $exit_code" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录输出
echo "  Output Length: ${#output} chars" >> "$log_file"
echo "  Output:" >> "$log_file"
echo "$output" | sed 's/^/    /' >> "$log_file"

# 记录完整输入 JSON (用于调试)
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

# 输出空 JSON
echo '{}'

exit 0
