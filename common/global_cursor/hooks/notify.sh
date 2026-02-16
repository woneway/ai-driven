#!/bin/bash
# =============================================================================
# notify.sh - 通知脚本
# 
# 支持微信、钉钉、短信通知
# 使用方法: source notify.sh && notify "标题" "内容"
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

NOTIFY_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# AI_DRIVEN_ROOT: 从脚本位置推导 -> common/global_cursor/hooks/ -> common/global_cursor/ -> common/ -> ai-driven
AI_DRIVEN_ROOT="$(cd "$NOTIFY_SCRIPT_DIR/../../../" && pwd)"
ENV_FILE="$AI_DRIVEN_ROOT/.env"

# 加载配置（从 .env 和 .workspace.env 文件）
load_config() {
    # 优先加载 workspace 级别配置，然后加载全局配置
    # workspace 配置会覆盖全局配置
    
    # 1. 先加载全局配置（ai-driven 根目录）
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a
        
        # 映射变量名
        ENABLED_CHANNELS="${NOTIFY_ENABLED_CHANNELS:-dingtalk}"
        NOTIFY_MIN_DURATION="${NOTIFY_MIN_DURATION:-0}"
    else
        warn "未找到配置文件: $ENV_FILE"
    fi
    
    # 2. 如果存在 workspace 配置，加载并覆盖
    # 从 CURSOR_PROJECT_DIR 或环境变量获取 workspace 路径
    if [ -n "$CURSOR_PROJECT_DIR" ] && [ -f "$CURSOR_PROJECT_DIR/.workspace.env" ]; then
        set -a
        source "$CURSOR_PROJECT_DIR/.workspace.env"
        set +a
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
    
    if [ -z "$WECHAT_WEBHOOK_URL" ]; then
        [ -n "$WECHAT_WEBHOOK_URL" ] || return 0
    fi
    
    # 使用企业微信群机器人 webhook
    local payload=$(cat <<EOF
{
    "msgtype": "markdown",
    "markdown": {
        "content": "## $title\n$content\n\n> 由 ai-driven 框架发送"
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

# 发送钉钉通知
notify_dingtalk() {
    local title="$1"
    local content="$2"
    
    if [ -z "$DINGTALK_WEBHOOK_URL" ]; then
        return 0
    fi
    
    # 关键词验证：如果设置了关键词，必须在消息开头包含
    local keyword="${DINGTALK_KEYWORD:-cursor}"
    local text_with_keyword="$keyword $content"
    
    local payload=$(cat <<EOF
{
    "msgtype": "markdown",
    "markdown": {
        "title": "$keyword $title",
        "text": "## $keyword $title\n\n$text_with_keyword\n\n> 由 ai-driven 框架发送"
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

# 主通知函数
notify() {
    local title="${1:-任务完成}"
    local content="${2:-任务执行完成}"
    local cmd_status="${3:-成功}"
    local duration="${4:-0}"
    
    # 加载配置
    load_config
    
    # 检查是否需要通知（根据耗时）
    if [ "$NOTIFY_MIN_DURATION" -gt 0 ] && [ "$duration" -lt "$NOTIFY_MIN_DURATION" ]; then
        return 0
    fi
    
    # 根据配置启用渠道
    local channels="${ENABLED_CHANNELS:-wechat}"
    
    if echo "$channels" | grep -q "wechat"; then
        notify_wechat "$title" "$content (耗时: ${duration}秒, 状态: $cmd_status)"
    fi
    
    if echo "$channels" | grep -q "dingtalk"; then
        notify_dingtalk "$title" "$content (耗时: ${duration}秒, 状态: $cmd_status)"
    fi
    
    if echo "$channels" | grep -q "sms"; then
        notify_sms "$title" "$content (耗时: ${duration}秒, 状态: $cmd_status)"
    fi
}

# 快速通知（使用默认内容）
quick_notify() {
    local status="${1:-完成}"
    notify "Cursor 任务 $status" "任务已执行完成" "$status" "0"
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
