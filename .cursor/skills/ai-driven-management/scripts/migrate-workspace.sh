#!/bin/bash
# =============================================================================
# migrate-workspace.sh - AI-Driven Workspace 迁移脚本
#
# 使用方式：
#   bash .cursor/skills/ai-driven-management/scripts/migrate-workspace.sh
#
# 此脚本会：
#   - 扫描所有 workspace
#   - 将硬编码路径转换为相对路径
#   - 更新 .workspace.env 配置
# =============================================================================

set -e

# === 加载配置 ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

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
echo "  AI-Driven Workspace 迁移"
echo "=========================================="
echo ""

# === 检查是否有 workspace 需要迁移 ===
info "扫描 workspaces: $WORKSPACES_PATH"

migrated=0
skipped=0

for ws in "$WORKSPACES_PATH"/*/; do
    [ -d "$ws" ] || continue
    [ -f "$ws/.workspace.env" ] || continue
    
    ws_name=$(basename "$ws")
    env_file="$ws/.workspace.env"
    
    # 检查是否有硬编码路径
    if grep -q "^PROJECT_PATH=/" "$env_file" 2>/dev/null; then
        info "迁移: $ws_name"
        
        # 读取当前 PROJECT_PATH
        old_path=$(grep "^PROJECT_PATH=" "$env_file" | cut -d'=' -f2-)
        
        # 计算相对路径
        # 尝试多种方式
        ws_parent=$(dirname "$ws")
        
        # 方式1：检查是否在同一个 AI_ROOT 下
        # workspace 在 /xxx/ai/workspaces/xxx
        # projects 在 /xxx/ai/projects/
        if [[ "$old_path" == "$ws_parent"/* ]]; then
            # 在同一父目录下
            if command -v python3 &>/dev/null; then
                relative_path=$(python3 -c "import os; print(os.path.relpath('$old_path', '$ws_parent'))" 2>/dev/null || echo "")
            elif command -v python &>/dev/null; then
                relative_path=$(python -c "import os; print(os.path.relpath('$old_path', '$ws_parent'))" 2>/dev/null || echo "")
            else
                old_basename=$(basename "$old_path")
                relative_path="../projects/$old_basename"
            fi
        elif [[ "$old_path" == "$(dirname "$ws_parent")"/* ]]; then
            # projects 在 workspaces 的父目录下（如 /ai/projects/xxx 和 /ai/workspaces/xxx）
            if command -v python3 &>/dev/null; then
                relative_path=$(python3 -c "import os; print(os.path.relpath('$old_path', '$ws_parent'))" 2>/dev/null || echo "")
            elif command -v python &>/dev/null; then
                relative_path=$(python -c "import os; print(os.path.relpath('$old_path', '$ws_parent'))" 2>/dev/null || echo "")
            else
                # 手动计算：../projects/xxx
                old_basename=$(basename "$old_path")
                relative_path="../projects/$old_basename"
            fi
        else
            warn "  跳过: 路径结构不符合预期 ($old_path)"
            skipped=$((skipped + 1))
        fi
        
        if [ -n "$relative_path" ]; then
            # 备份原文件
            cp "$env_file" "$env_file.bak"
            
            # 替换为相对路径
            sed -i '' "s|^PROJECT_PATH=.*|PROJECT_PATH=$relative_path|" "$env_file"
            
            ok "  $old_path -> $relative_path"
            ok "  备份: $env_file.bak"
            migrated=$((migrated + 1))
        fi
    else
        info "跳过: $ws_name (已是相对路径)"
        skipped=$((skipped + 1))
    fi
done

echo ""
echo "=========================================="
echo -e "  ${GREEN}迁移完成${NC}"
echo "=========================================="
echo ""
echo "统计:"
echo "  迁移: $migrated"
echo "  跳过: $skipped"
echo ""
echo "提示:"
echo "  - 备份文件保存在 .workspace.env.bak"
echo "  - 验证迁移: bash $SCRIPT_DIR/verify.sh"
echo ""
