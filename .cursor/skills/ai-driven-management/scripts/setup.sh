#!/bin/bash
# =============================================================================
# setup.sh - AI-Driven 初始化脚本
#
# 使用方式：
#   bash .cursor/skills/ai-driven-management/scripts/setup.sh
#
# 此脚本会：
#   1. 自动检测 ai-driven 目录位置
#   2. 自动检测或创建 workspaces 和 projects 目录
#   3. 引导用户确认或修改配置
#   4. 生成 .workspace.env
#   5. 安装全局配置
# =============================================================================

set -e

# === 脚本位置 ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AI_DRIVEN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AI_ROOT="$(dirname "$AI_DRIVEN_ROOT")"

# === 颜色输出 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

echo ""
echo "=========================================="
echo "  AI-Driven 初始化"
echo "=========================================="
echo ""

# === 自动检测配置 ===
info "自动检测配置..."

# 1. 检测 AI_ROOT（ai-driven 的父目录）
if [ -z "$AI_ROOT" ] || [ ! -d "$AI_ROOT" ]; then
    AI_ROOT="$HOME/ai"
fi

# 2. 检测或创建 workspaces 目录
if [ -d "$AI_ROOT/workspaces" ]; then
    WORKSPACES_PATH="$AI_ROOT/workspaces"
else
    WORKSPACES_PATH="$AI_ROOT/workspaces"
    info "将创建: $WORKSPACES_PATH"
fi

# 3. 检测或创建 projects 目录
if [ -d "$AI_ROOT/projects" ]; then
    PROJECTS_DIR="$AI_ROOT/projects"
else
    PROJECTS_DIR="$AI_ROOT/projects"
    info "将创建: $PROJECTS_DIR"
fi

echo ""
echo "配置确认（直接回车使用默认值）："
echo ""

# === 交互式确认/修改 ===
read -p "AI 根目录 [$AI_ROOT]: " input
AI_ROOT="${input:-$AI_ROOT}"

read -p "Workspaces 目录 [$WORKSPACES_PATH]: " input
WORKSPACES_PATH="${input:-$WORKSPACES_PATH}"

read -p "Projects 目录 [$PROJECTS_DIR]: " input
PROJECTS_DIR="${input:-$PROJECTS_DIR}"

# 展开 ~
AI_ROOT=$(eval echo "$AI_ROOT")
WORKSPACES_PATH=$(eval echo "$WORKSPACES_PATH")
PROJECTS_DIR=$(eval echo "$PROJECTS_DIR")

echo ""
info "最终配置："
echo "  AI_ROOT:        $AI_ROOT"
echo "  WORKSPACES:     $WORKSPACES_PATH"
echo "  PROJECTS:       $PROJECTS_DIR"
echo ""

# === 验证目录 ===
if [ ! -d "$AI_ROOT/ai-driven" ]; then
    error "ai-driven 目录不存在: $AI_ROOT/ai-driven"
    error "请确认 AI_ROOT 配置正确"
    exit 1
fi

# === 创建必要的目录 ===
mkdir -p "$WORKSPACES_PATH"
mkdir -p "$PROJECTS_DIR"
ok "目录已就绪"

# === 创建 .workspace.env ===
WORKSPACE_ENV="$AI_DRIVEN_ROOT/.workspace.env"

if [ -f "$WORKSPACE_ENV" ]; then
    info ".workspace.env 已存在"
    read -p "是否覆盖？[y/N]: " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        info "跳过创建 .workspace.env"
    else
        cat > "$WORKSPACE_ENV" << EOF
# AI-Driven 全局配置文件
# 此文件为 ai-driven 根目录专用

# ========== 路径配置 ==========
# 使用相对路径或留空（让脚本自动推导）
# WORKSPACES_PATH=../workspaces
# PROJECTS_DIR=../projects

# ========== Hooks 配置 ==========
# HOOK_ENABLED=true
# HOOK_SESSION_START=true
# HOOK_SESSION_END=true
# HOOK_SUBAGENT_START=true
# HOOK_SUBAGENT_STOP=true

# ========== 通知配置 ==========
# NOTIFY_ENABLED_CHANNELS=dingtalk
# NOTIFY_MIN_DURATION=0
EOF
        ok "已更新 .workspace.env"
    fi
else
    cat > "$WORKSPACE_ENV" << EOF
# AI-Driven 全局配置文件
# 此文件为 ai-driven 根目录专用

# ========== 路径配置 ==========
# 使用相对路径或留空（让脚本自动推导）
# WORKSPACES_PATH=../workspaces
# PROJECTS_DIR=../projects

# ========== Hooks 配置 ==========
# HOOK_ENABLED=true
# HOOK_SESSION_START=true
# HOOK_SESSION_END=true
# HOOK_SUBAGENT_START=true
# HOOK_SUBAGENT_STOP=true

# ========== 通知配置 ==========
# NOTIFY_ENABLED_CHANNELS=dingtalk
# NOTIFY_MIN_DURATION=0
EOF
    ok "已创建 .workspace.env"
fi

# === 运行 setup-global.sh ===
echo ""
info "运行全局配置初始化..."
if bash "$SCRIPT_DIR/setup-global.sh"; then
    ok "全局配置完成"
else
    warn "全局配置部分失败，请检查上面的错误"
fi

echo ""
echo "=========================================="
echo -e "  ${GREEN}初始化完成${NC}"
echo "=========================================="
echo ""
echo "下一步："
echo "  1. 重启 Cursor IDE"
echo "  2. 创建 workspace:"
echo "       bash $SCRIPT_DIR/init-space.sh <workspace_name>"
echo ""
