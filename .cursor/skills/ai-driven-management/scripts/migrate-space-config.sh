#!/bin/bash
# =============================================================================
# migrate-space-config.sh - 迁移 .space-config 到 .env
#
# 将 workspace 中的 .space-config 内容迁移到 .env
# 迁移后 .space-config 会被重命名为 .space-config.bak
#
# 用法:
#   bash .cursor/skills/ai-driven-management/scripts/migrate-space-config.sh [workspace_dir]
#
# 示例:
#   bash scripts/migrate-space-config.sh                    # 迁移所有 workspace
#   bash scripts/migrate-space-config.sh my_workspace       # 迁移指定 workspace
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

WORKSPACE_DIR="${1:-}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

migrate_one() {
    local ws="$1"
    local space_config="$ws/.space-config"
    local env_file="$ws/.env"
    
    if [ ! -f "$space_config" ]; then
        echo -e "${YELLOW}跳过: $ws/.space-config 不存在${NC}"
        return 1
    fi
    
    # 读取 .space-config 内容
    source "$space_config"
    
    echo "迁移: $(basename "$ws")"
    
    # 创建或更新 .env
    if [ -f "$env_file" ]; then
        # 备份现有 .env
        cp "$env_file" "$env_file.bak"
        echo "  备份现有 .env -> .env.bak"
    fi
    
    # 写入新 .env
    # 旧 .space-config 中的 CODE_ROOTS_ABS 转为 PROJECT_PATH
    cat > "$env_file" << EOF
# AI-Driven Workspace 配置
# 由 migrate-space-config.sh 生成

# ========== Workspace 信息 ==========
SPACE_NAME=$SPACE_NAME
PROJECT_PATH=${CODE_ROOTS_ABS:-}

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
    
    # 重命名 .space-config
    mv "$space_config" "$space_config.bak"
    
    echo -e "  ${GREEN}完成!${NC} .env 已创建，.space-config 已备份"
    return 0
}

if [ -n "$WORKSPACE_DIR" ]; then
    # 迁移指定 workspace
    if [ -d "$WORKSPACE_DIR" ]; then
        migrate_one "$WORKSPACE_DIR"
    else
        echo -e "${RED}错误: 目录不存在: $WORKSPACE_DIR${NC}"
        exit 1
    fi
else
    # 迁移所有 workspace
    echo "迁移所有 workspace..."
    
    count=0
    for ws in "$WORKSPACES_PATH"/*; do
        [ -d "$ws" ] || continue
        if [ -f "$ws/.space-config" ]; then
            migrate_one "$ws" && count=$((count + 1))
        fi
    done
    
    echo ""
    echo -e "${GREEN}迁移完成: $count 个 workspace${NC}"
fi
