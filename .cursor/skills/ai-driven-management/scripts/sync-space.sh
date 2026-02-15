#!/bin/bash
# =============================================================================
# sync-space.sh - 同步升级所有 AI-Driven workspace
#
# 将 common/workspace-template 中的框架文件同步到所有已存在的 workspace。
# 只覆盖框架维护的文件，不动用户配置。
#
# 用法:
#   bash .cursor/skills/ai-driven-management/scripts/sync-space.sh
#
# 环境变量:
#   WORKSPACES_PATH  自定义 workspaces 存放路径（默认: ai-driven/workspaces）
# =============================================================================

set -e

# scripts/ -> ai-driven-management/ -> skills/ -> .cursor/ -> ai-driven root
AI_DRIVEN_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
WORKSPACES_PATH="${WORKSPACES_PATH:-$AI_DRIVEN_ROOT/workspaces}"
TEMPLATE="$AI_DRIVEN_ROOT/common/workspace-template"

synced=0

for ws in "$WORKSPACES_PATH"/*/; do
    [ -d "$ws" ] || continue
    [ -f "$ws/.space-config" ] || continue

    ws_name="$(basename "$ws")"
    echo "同步: $ws_name"

    # 同步框架文件（直接覆盖）
    mkdir -p "$ws/.cursor/commands" "$ws/.cursor/rules"
    cp "$TEMPLATE/.cursor/commands/team.md" "$ws/.cursor/commands/team.md"
    cp "$TEMPLATE/.cursor/rules/ai-driven.mdc" "$ws/.cursor/rules/ai-driven.mdc"

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
echo "完成: 同步了 $synced 个 workspace"
