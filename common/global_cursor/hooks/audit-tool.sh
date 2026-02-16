#!/bin/bash
# =============================================================================
# audit-tool.sh - Post Tool Use Hook
# 
# 在工具执行后记录信息
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

# 记录日志
LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
log_file="$LOG_DIR/tool-use.log"

echo "[$timestamp] Tool 使用" >> "$log_file"
echo "  Tool: $tool_name" >> "$log_file"
echo "  Duration: ${duration}ms" >> "$log_file"
echo "---" >> "$log_file"

# 输出空 JSON
echo '{}'

exit 0
