#!/bin/bash
# =============================================================================
# notify.sh - 通知脚本
#
# 支持微信、钉钉、短信通知
# 使用方法: source notify.sh && notify "标题" "内容" [状态] [耗时]
#
# 通知级别:
# - success: 成功 (绿色)
# - error: 失败 (红色)
# - warning: 警告 (黄色)
# - info: 信息 (蓝色)
# =============================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# 获取脚本真实路径（支持 symlink）
_SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]:-$0}" 2>/dev/null || echo "${BASH_SOURCE[0]:-$0}")"
NOTIFY_SCRIPT_DIR="$(dirname "$_SCRIPT_PATH")"

# AI_DRIVEN_ROOT: 从脚本位置推导 -> common/global_cursor/hooks/ -> common/global_cursor/ -> common/ -> ai-driven
AI_DRIVEN_ROOT="$(cd "$NOTIFY_SCRIPT_DIR/../../../" && pwd)"
ENV_FILE="$AI_DRIVEN_ROOT/.workspace.env"

# 加载配置（从 .workspace.env 文件）
# 实现字段级别覆盖：只有 workspace 明确设置的变量才覆盖全局
load_config() {
    # 日志目录
    local log_dir="${HOME}/.cursor/logs/hooks"
    mkdir -p "$log_dir"
    local config_log="$log_dir/config-load.log"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # 1. 先加载全局配置（ai-driven 根目录）
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a

        # 映射变量名
        ENABLED_CHANNELS="${NOTIFY_ENABLED_CHANNELS:-dingtalk}"
        NOTIFY_MIN_DURATION="${NOTIFY_MIN_DURATION:-0}"

        echo "[$timestamp] 全局配置加载: $ENV_FILE" >> "$config_log"
    else
        warn "未找到配置文件: $ENV_FILE"
        echo "[$timestamp] 警告: 未找到全局配置 $ENV_FILE" >> "$config_log"
    fi

    # 记录全局配置值（用于比较）
    local global_hook_enabled="$HOOK_ENABLED"
    local global_notify_channels="$NOTIFY_ENABLED_CHANNELS"
    local global_notify_duration="$NOTIFY_MIN_DURATION"

    # 2. 如果存在 workspace 配置，只读取明确设置的变量（未注释的行）进行覆盖
    local workspace_config_loaded=false
    if [ -n "$CURSOR_PROJECT_DIR" ] && [ -f "$CURSOR_PROJECT_DIR/.workspace.env" ]; then
        # 解析 workspace 配置，只读取有效行（非注释、非空行）
        while IFS= read -r line; do
            # 跳过注释行和空行
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ "$line" =~ ^[[:space:]]*$ ]] && continue

            # 提取变量名和值
            if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.+)$ ]]; then
                local var_name="${BASH_REMATCH[1]}"
                local var_value="${BASH_REMATCH[2]}"

                # 移除可能的引号
                var_value="${var_value//\"/}"
                var_value="${var_value//\'/}"

                # 设置变量（覆盖全局）
                eval "$var_name=\"$var_value\""

                echo "[$timestamp] Workspace 覆盖: $var_name=$var_value" >> "$config_log"
            fi
        done < "$CURSOR_PROJECT_DIR/.workspace.env"

        workspace_config_loaded=true
    fi

    # 3. 记录最终配置状态
    echo "[$timestamp] ===== 最终配置 =====" >> "$config_log"
    echo "[$timestamp] HOOK_ENABLED: ${HOOK_ENABLED:-true} (全局: ${global_hook_enabled:-未设置})" >> "$config_log"
    echo "[$timestamp] NOTIFY_ENABLED_CHANNELS: ${NOTIFY_ENABLED_CHANNELS:-dingtalk} (全局: ${global_notify_channels:-未设置})" >> "$config_log"
    echo "[$timestamp] NOTIFY_MIN_DURATION: ${NOTIFY_MIN_DURATION:-0} (全局: ${global_notify_duration:-未设置})" >> "$config_log"
    echo "[$timestamp] ====================" >> "$config_log"

    # 导出配置来源
    if [ "$workspace_config_loaded" = true ]; then
        export CONFIG_SOURCE="全局 -> Workspace 覆盖: $CURSOR_PROJECT_DIR/.workspace.env"
    else
        export CONFIG_SOURCE="全局: $ENV_FILE"
    fi
}

# 检查 hooks 是否启用
# 用法: hook_enabled "SESSION_START" → 返回 0 如果启用，1 如果禁用
hook_enabled() {
    local hook_name="$1"

    # 检查全局开关
    if [ "${HOOK_ENABLED:-true}" = "false" ]; then
        return 1
    fi

    # 检查特定 hook 开关（优先级更高）
    local hook_var="HOOK_${hook_name}"
    local hook_value="${!hook_var}"

    if [ -n "$hook_value" ]; then
        [ "$hook_value" = "true" ]
        return $?
    fi

    # 默认启用
    return 0
}

# 发送微信通知
notify_wechat() {
    local title="$1"
    local content="$2"
    local status="${3:-info}"

    if [ -z "$WECHAT_WEBHOOK_URL" ]; then
        return 0
    fi

    # 根据状态设置emoji
    local emoji=""
    case "$status" in
        success) emoji="✅" ;;
        error) emoji="❌" ;;
        warning) emoji="⚠️" ;;
        *) emoji="ℹ️" ;;
    esac

    # 使用企业微信群机器人 webhook
    local payload=$(cat <<EOF
{
    "msgtype": "markdown",
    "markdown": {
        "content": "## $emoji $title\n$content\n\n> 由 ai-driven 框架发送"
    }
}
EOF
)

    curl -s -X POST "$WECHAT_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[微信通知发送成功]${NC}"
    else
        echo -e "${RED}[微信通知发送失败]${NC}"
    fi
}

# 发送钉钉通知 - 优化版
notify_dingtalk() {
    local title="$1"
    local content="$2"
    local status="${3:-info}"

    if [ -z "$DINGTALK_WEBHOOK_URL" ]; then
        return 0
    fi

    # 根据状态设置emoji和颜色
    local emoji=""
    local color=""
    case "$status" in
        success)
            emoji="✅"
            color="#00CC00"
            ;;
        error)
            emoji="❌"
            color="#FF0000"
            ;;
        warning)
            emoji="⚠️"
            color="#FF9900"
            ;;
        *)
            emoji="ℹ️"
            color="#0099CC"
            ;;
    esac

    # 关键词验证：如果设置了关键词，必须在消息开头包含
    local keyword="${DINGTALK_KEYWORD:-cursor}"

    # 构建更丰富的消息格式
    local payload=$(cat <<EOF
{
    "msgtype": "markdown",
    "markdown": {
        "title": "$emoji $keyword $title",
        "text": "## $emoji $keyword $title\n\n$content\n\n---\n> 由 ai-driven 框架发送 | $(date '+%H:%M:%S')"
    }
}
EOF
)

    local response=$(curl -s -X POST "$DINGTALK_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # 检查返回结果
    if echo "$response" | grep -q '"errcode":0'; then
        echo -e "${GREEN}[钉钉通知发送成功]${NC}"
    else
        echo -e "${RED}[钉钉通知发送失败]${NC} - $response"
    fi
}

# 发送短信通知
notify_sms() {
    local title="$1"
    local content="$2"

    if [ -z "$SMS_ACCESS_KEY" ] || [ -z "$SMS_PHONE" ]; then
        return 0
    fi

    local message="$title: $content"
    # 短信内容截断
    message="${message:0:200}"

    if [ "$SMS_PROVIDER" = "aliyun" ]; then
        # 阿里云短信 API（需要自行实现签名等）
        echo "阿里云短信: $message -> $SMS_PHONE"
        # TODO: 实现阿里云短信发送
    elif [ "$SMS_PROVIDER" = "tencent" ]; then
        # 腾讯云短信 API
        echo "腾讯云短信: $message -> $SMS_PHONE"
        # TODO: 实现腾讯云短信发送
    fi
}

# 主通知函数 - 优化版
# 参数: notify "标题" "内容" [状态] [耗时(秒)]
notify() {
    local title="${1:-任务完成}"
    local content="${2:-任务执行完成}"
    local status="${3:-info}"
    local duration="${4:-0}"

    # 加载配置
    load_config

    # 检查是否需要通知（根据耗时）
    # duration 传入的是秒，如果小于最小配置则跳过
    if [ "$NOTIFY_MIN_DURATION" -gt 0 ] && [ "$duration" -lt "$NOTIFY_MIN_DURATION" ]; then
        return 0
    fi

    # 根据配置启用渠道
    local channels="${ENABLED_CHANNELS:-dingtalk}"

    # 构建简洁的内容（不重复添加耗时和状态，因为内容已经包含）
    local notify_content="$content"

    if echo "$channels" | grep -q "wechat"; then
        notify_wechat "$title" "$notify_content" "$status"
    fi

    if echo "$channels" | grep -q "dingtalk"; then
        notify_dingtalk "$title" "$notify_content" "$status"
    fi

    if echo "$channels" | grep -q "sms"; then
        notify_sms "$title" "$notify_content"
    fi
}

# 快速通知（使用默认内容）
quick_notify() {
    local status="${1:-完成}"
    notify "Cursor 任务 $status" "任务已执行完成" "$status" "0"
}

# 直接运行时执行通知
if [ -n "$1" ]; then
    load_config
    notify "$@"
    exit 0
fi

# 导出函数（供其他脚本 source 使用）
export -f notify
export -f notify_wechat
export -f notify_dingtalk
export -f notify_sms
export -f quick_notify
export -f load_config
export -f hook_enabled
