#!/bin/bash
# =============================================================================
# common.sh - AI-Driven 脚本公共配置
#
# 所有脚本通过 source 此文件获取路径配置。
# 路径推导优先级: 环境变量 > .workspace.env > 自动检测（基于脚本位置）
#
# 可配置的环境变量:
#   AI_ROOT            ai-driven 所在的父目录（默认: 自动检测）
#   AI_DRIVEN_ROOT     ai-driven 仓库根目录（默认: $AI_ROOT/ai-driven）
#   CURSOR_HOME        Cursor 全局配置目录（默认: ~/.cursor）
#   GLOBAL_CURSOR_DIR  global_cursor 路径（默认: $AI_DRIVEN_ROOT/common/global_cursor）
#   WORKSPACES_PATH    workspaces 存放路径（默认: $AI_ROOT/workspaces）
#
# 示例:
#   # ai-driven 在 ~/ai/ai-driven
#   export AI_ROOT=~/ai
#
#   # ai-driven 在 /opt/projects/ai-driven
#   export AI_ROOT=/opt/projects
#
#   # 也可以直接指定 ai-driven 根目录（跳过 AI_ROOT 推导）
#   export AI_DRIVEN_ROOT=/some/custom/path/ai-driven
# =============================================================================

# === 颜色输出 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# === 路径推导 ===
# 自动检测: 脚本在 ai-driven/.cursor/skills/ai-driven-management/scripts/ 下
# CALLER_SCRIPT_DIR 由调用方设置，或者用 common.sh 自身位置
_SCRIPTS_DIR="${CALLER_SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# AI_DRIVEN_ROOT: 优先环境变量，其次从脚本位置推导
if [ -z "${AI_DRIVEN_ROOT:-}" ]; then
    if [ -n "${AI_ROOT:-}" ]; then
        # 从 AI_ROOT 推导
        AI_DRIVEN_ROOT="$AI_ROOT/ai-driven"
    else
        # 从脚本位置推导: scripts/ -> ai-driven-management/ -> skills/ -> .cursor/ -> ai-driven
        AI_DRIVEN_ROOT="$(cd "$_SCRIPTS_DIR/../../../.." && pwd)"
    fi
fi

# AI_ROOT: 从 AI_DRIVEN_ROOT 反推（如果未设置）
AI_ROOT="${AI_ROOT:-$(dirname "$AI_DRIVEN_ROOT")}"

# === 从 setup.env 读取配置（用户配置文件）===
_SETUP_ENV="$AI_DRIVEN_ROOT/../setup.env"
if [ -f "$_SETUP_ENV" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        # 跳过注释和空行
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # 解析 key=value
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            
            # 去除引号和空格
            value="${value#"${value%%[![:space:]]*}"}"
            value="${value%"${value##*[![:space:]]}"}"
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # 展开 ~
            if [[ "$value" == ~* ]]; then
                value=$(eval echo "$value")
            fi
            
            # 设置环境变量（如果未设置）
            case "$key" in
                AI_ROOT)
                    [ -z "${AI_ROOT:-}" ] && AI_ROOT="$value"
                    ;;
                WORKSPACES_DIR)
                    [ -z "${WORKSPACES_DIR:-}" ] && WORKSPACES_DIR="$value"
                    ;;
                PROJECTS_DIR)
                    [ -z "${PROJECTS_DIR:-}" ] && PROJECTS_DIR="$value"
                    ;;
            esac
        fi
    done < "$_SETUP_ENV"
fi
unset _SETUP_ENV

# === 从 .workspace.env 读取配置（运行时配置）===
_WS_ENV="$AI_DRIVEN_ROOT/.workspace.env"
if [ -f "$_WS_ENV" ]; then
    # 逐行读取，跳过注释和空行
    while IFS= read -r line || [ -n "$line" ]; do
        # 跳过注释和空行
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        # 解析 key=value
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            
            # 去除引号
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # 只有在环境变量未设置时才使用 .workspace.env 中的值
            case "$key" in
                AI_ROOT)
                    [ -z "${AI_ROOT:-}" ] && AI_ROOT="$value"
                    ;;
                AI_DRIVEN_ROOT)
                    [ -z "${AI_DRIVEN_ROOT:-}" ] && AI_DRIVEN_ROOT="$value"
                    ;;
                WORKSPACES_PATH)
                    [ -z "${WORKSPACES_PATH:-}" ] && WORKSPACES_PATH="$value"
                    ;;
                PROJECTS_DIR)
                    [ -z "${PROJECTS_DIR:-}" ] && PROJECTS_DIR="$value"
                    ;;
            esac
        fi
    done < "$_WS_ENV"
fi
unset _WS_ENV

# 其他路径
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
GLOBAL_CURSOR_DIR="${GLOBAL_CURSOR_DIR:-$AI_DRIVEN_ROOT/common/global_cursor}"
WORKSPACES_PATH="${WORKSPACES_PATH:-$AI_ROOT/workspaces}"
PROJECTS_DIR="${PROJECTS_DIR:-$AI_ROOT/projects}"
TEMPLATE_DIR="$AI_DRIVEN_ROOT/common/workspace-template"

# symlink 管理的目录列表
MANAGED_DIRS="rules skills agents commands hooks"

# === 验证 AI_DRIVEN_ROOT 有效 ===
_validate_ai_driven_root() {
    if [ ! -d "$AI_DRIVEN_ROOT" ]; then
        error "AI_DRIVEN_ROOT 不存在: $AI_DRIVEN_ROOT"
        error "请设置环境变量 AI_ROOT 或 AI_DRIVEN_ROOT"
        exit 1
    fi
    if [ ! -d "$AI_DRIVEN_ROOT/common" ]; then
        error "无效的 ai-driven 目录（缺少 common/）: $AI_DRIVEN_ROOT"
        exit 1
    fi
}

# === 显示路径信息 ===
_show_paths() {
    info "AI_ROOT:          $AI_ROOT"
    info "AI_DRIVEN_ROOT:   $AI_DRIVEN_ROOT"
    info "PROJECTS_DIR:     $PROJECTS_DIR"
    info "WORKSPACES_PATH:  $WORKSPACES_PATH"
    info "GLOBAL_CURSOR_DIR: $GLOBAL_CURSOR_DIR"
    info "CURSOR_HOME:      $CURSOR_HOME"
}

# === 辅助函数 ===
copy_file() {
    local src="$1" dst="$2"
    if ${DRY_RUN:-false}; then
        echo "  [DRY-RUN] cp $src -> $dst"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
}

copy_dir() {
    local src="$1" dst="$2"
    if ${DRY_RUN:-false}; then
        echo "  [DRY-RUN] cp -r $src/ -> $dst/"
        return
    fi
    mkdir -p "$dst"
    cp -r "$src/." "$dst/"
}
