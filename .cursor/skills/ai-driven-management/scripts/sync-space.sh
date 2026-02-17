#!/bin/bash
# =============================================================================
# sync-space.sh - 同步升级所有 AI-Driven workspace
#
# 将 common/workspace-template 中的框架文件同步到所有已存在的 workspace。
# 只覆盖框架维护的文件，不动用户配置。
#
# 同步前会备份用户可能修改过的文件。
#
# 用法:
#   bash .cursor/skills/ai-driven-management/scripts/sync-space.sh
#
# 环境变量（详见 common.sh）:
#   AI_ROOT            ai-driven 所在的父目录
#   AI_DRIVEN_ROOT     ai-driven 仓库根目录
#   WORKSPACES_PATH    自定义 workspaces 存放路径
# =============================================================================

set -e

# === 加载公共配置 ===
CALLER_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$CALLER_SCRIPT_DIR/common.sh"
_validate_ai_driven_root

synced=0
backups=()

# 需要同步的文件列表
SYNC_FILES=(
    ".cursor/commands/team.md"
    ".cursor/rules/ai-driven.mdc"
)

# 检查文件是否有用户修改（通过 git status）
has_user_modifications() {
    local file="$1"
    if [ -d "$file" ]; then
        return 1  # 目录不检查
    fi
    if [ ! -f "$file" ]; then
        return 1  # 文件不存在，不算修改
    fi
    # 如果是 git 仓库，检查是否有未提交的更改
    if git rev-parse --git-dir >/dev/null 2>&1; then
        if git diff --quiet "$file" 2>/dev/null; then
            return 1  # 没有修改
        else
            return 0  # 有修改
        fi
    fi
    # 非 git 仓库，保守假设可能有修改
    return 0
}

# 同步单个文件，带备份
sync_file() {
    local src="$1"
    local dst="$2"
    local filename="$(basename "$dst")"

    # 确保目标目录存在
    mkdir -p "$(dirname "$dst")"

    # 检查目标文件是否有用户修改
    if [ -f "$dst" ]; then
        if has_user_modifications "$dst"; then
            # 创建备份
            local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
            cp "$dst" "$backup"
            backups+=("$backup")
            warn "已备份 $filename -> $(basename "$backup")"
        fi
    fi

    # 复制新文件
    cp "$src" "$dst"
    info "已同步 $filename"
}

for ws in "$WORKSPACES_PATH"/*/; do
    [ -d "$ws" ] || continue
    [ -f "$ws/.workspace.env" ] || continue

    ws_name="$(basename "$ws")"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  同步: $ws_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 同步框架文件（带备份）
    for file in "${SYNC_FILES[@]}"; do
        src="$TEMPLATE_DIR/$file"
        dst="$ws/$file"
        if [ -f "$src" ]; then
            sync_file "$src" "$dst"
        fi
    done

    # 清理旧文件（如果存在）
    rm -f "$ws/.cursor/rules/010-ai-driven.mdc" 2>/dev/null || true
    rm -f "$ws/AGENTS.md" 2>/dev/null || true
    rm -rf "$ws/.homunculus" 2>/dev/null || true
    rm -rf "$ws/.cursor/agents" 2>/dev/null || true

    # 清理 workspace 内的 opsx 命令和 skills（已迁移到全局）
    rm -f "$ws/.cursor/commands"/opsx-*.md 2>/dev/null || true
    rm -rf "$ws/.cursor/skills"/openspec-* 2>/dev/null || true

    # 确保 openspec/ 项目目录存在（变更记录用）
    mkdir -p "$ws/openspec/changes" "$ws/openspec/specs"

    synced=$((synced + 1))
done

echo ""
echo "=========================================="
echo "  同步完成"
echo "=========================================="
echo ""
echo "已同步: $synced 个 workspace"

# 显示备份信息
if [ ${#backups[@]} -gt 0 ]; then
    echo ""
    warn "发现 ${#backups[@]} 个备份文件:"
    for backup in "${backups[@]}"; do
        echo "  - $backup"
    done
    echo ""
    info "请检查备份文件，确认是否需要合并用户修改"
fi
