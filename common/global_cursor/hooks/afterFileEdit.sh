#!/bin/bash
# =============================================================================
# afterFileEdit.sh - Cursor After File Edit Hook
#
# 文件编辑后触发
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/notify.sh"
load_config

if ! hook_enabled "AFTER_EDIT"; then
    echo '{}'
    exit 0
fi

read -r input

LOG_DIR="${HOME}/.cursor/logs/hooks"
mkdir -p "$LOG_DIR"

# 使用高精度时间戳
timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
log_file="$LOG_DIR/file-access.log"

# 尝试多种字段名
file_path=$(echo "$input" | jq -r '.file_path // .path // .filePath // .file // "unknown"')
session_id=$(echo "$input" | jq -r '.session_id // .sessionId // "unknown"')
diff=$(echo "$input" | jq -r '.diff // .changes // ""')

# 获取文件信息（如果文件存在）
file_size=""
file_modified=""
if [ -f "$file_path" ]; then
    file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "unknown")
    file_modified=$(stat -f"%Sm" "$file_path" 2>/dev/null || stat -c%y "$file_path" 2>/dev/null | cut -d'.' -f1 || echo "unknown")
fi

echo "[$timestamp] ===== AfterFileEdit =====" >> "$log_file"
echo "  Session ID: $session_id" >> "$log_file"
echo "  File: $file_path" >> "$log_file"
echo "  File Size: $file_size bytes" >> "$log_file"
echo "  Modified: $file_modified" >> "$log_file"
echo "  PID: $$" >> "$log_file"
echo "  Config Source: $CONFIG_SOURCE" >> "$log_file"

# 记录 diff（截断过长的）
if [ -n "$diff" ]; then
    diff_truncated=$(echo "$diff" | head -c 500)
    if [ ${#diff} -gt 500 ]; then
        diff_truncated="$diff_truncated...[truncated]"
    fi
    echo "  Diff: $diff_truncated" >> "$log_file"
fi

# 记录完整输入 JSON
echo "  Input JSON: $(echo "$input" | jq -c '.')" >> "$log_file"

echo "=============================" >> "$log_file"

echo '{}'
exit 0
