#!/bin/bash
# =============================================================================
# check-workspace-resources.sh - 检查 workspace 资源分布和全局同步状态
#
# 功能：
# 1. 扫描每个 workspace 的专属资源
# 2. 检查全局 ~/.cursor/ 与 global_cursor 的差异
# 3. 识别可升级到全局的资源（被多个 workspace 使用）
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_BASE="$SCRIPT_DIR"  # 脚本已经在 skill 内部

if [ -f "$SCRIPTS_BASE/common.sh" ]; then
    source "$SCRIPTS_BASE/common.sh"
else
    # 备用：从 skill 目录向上找
    AI_DRIVEN_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
    if [ -f "$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/scripts/common.sh" ]; then
        source "$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/scripts/common.sh"
    fi
fi

RESOURCE_TYPES="skills agents commands rules"

# =============================================================================
# 扫描 workspace 资源
# =============================================================================
scan_workspace_resources() {
    local ws_path="$1"
    local ws_name=$(basename "$ws_path")
    
    echo "=== $ws_name ==="
    
    for res_type in $RESOURCE_TYPES; do
        local res_dir="$ws_path/.cursor/$res_type"
        if [ -d "$res_dir" ]; then
            local count=$(ls -1 "$res_dir" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$count" -gt 0 ]; then
                echo "  $res_type: $count"
                ls -1 "$res_dir" 2>/dev/null | sed 's/^/    - /'
            fi
        fi
    done
}

# =============================================================================
# 检查全局与 global_cursor 差异
# =============================================================================
check_global_diff() {
    echo ""
    echo "=== 全局资源差异检查 ==="
    echo "比较: ~/.cursor/ vs $GLOBAL_CURSOR_DIR"
    echo ""
    
    for res_type in $RESOURCE_TYPES; do
        local cursor_dir="$CURSOR_HOME/$res_type"
        local global_dir="$GLOBAL_CURSOR_DIR/$res_type"
        
        if [ -L "$cursor_dir" ]; then
            local link_target=$(readlink "$cursor_dir")
            echo "  $res_type: -> $link_target"
            if [ -d "$global_dir" ]; then
                echo "    状态: symlink 正常"
            else
                echo "    状态: 警告: symlink 目标不存在!"
            fi
        else
            echo "  $res_type: (非 symlink)"
            
            if [ -d "$cursor_dir" ] && [ -d "$global_dir" ]; then
                for item in "$cursor_dir"/*; do
                    if [ -e "$item" ]; then
                        local item_name=$(basename "$item")
                        if [ ! -e "$global_dir/$item_name" ]; then
                            echo "    警告: 额外资源 $item_name (不在 global_cursor 中)"
                        fi
                    fi
                done
            fi
        fi
    done
}

# =============================================================================
# 简化版：列出每个 workspace 的资源
# =============================================================================
find_upgradable_resources() {
    echo ""
    echo "=== 可升级资源分析 ==="
    echo "(被多个 workspace 共同使用的资源建议升级到全局)"
    echo ""
    
    # 简化输出：直接列出所有 workspace 的资源
    for res_type in $RESOURCE_TYPES; do
        echo "--- $res_type ---"
        
        local found=0
        for ws in "$WORKSPACES_PATH"/*; do
            if [ -d "$ws/.cursor/$res_type" ]; then
                local ws_name=$(basename "$ws")
                local items=$(ls -1 "$ws/.cursor/$res_type" 2>/dev/null)
                if [ -n "$items" ]; then
                    echo "  $ws_name:"
                    echo "$items" | sed 's/^/    - /'
                    found=1
                fi
            fi
        done
        
        if [ $found -eq 0 ]; then
            echo "  (无项目专属 $res_type)"
        fi
    done
}

# =============================================================================
# 主流程
# =============================================================================
main() {
    _validate_ai_driven_root 2>/dev/null || {
        # 如果没有 common.sh，手动设置变量
        AI_DRIVEN_ROOT="${AI_DRIVEN_ROOT:-/Users/lianwu/ai/ai-driven}"
        WORKSPACES_PATH="${WORKSPACES_PATH:-$AI_DRIVEN_ROOT/workspaces}"
        CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
        GLOBAL_CURSOR_DIR="${GLOBAL_CURSOR_DIR:-$AI_DRIVEN_ROOT/common/global_cursor}"
    }
    
    echo "========================================"
    echo "Workspace 资源分析"
    echo "========================================"
    echo ""
    echo "AI_DRIVEN_ROOT: $AI_DRIVEN_ROOT"
    echo "WORKSPACES_PATH: $WORKSPACES_PATH"
    echo "CURSOR_HOME: $CURSOR_HOME"
    echo "GLOBAL_CURSOR_DIR: $GLOBAL_CURSOR_DIR"
    echo ""
    
    # 1. 扫描每个 workspace 的资源
    echo "========================================"
    echo "各 Workspace 专属资源"
    echo "========================================"
    
    for ws in "$WORKSPACES_PATH"/*; do
        if [ -d "$ws/.cursor" ]; then
            scan_workspace_resources "$ws"
        fi
    done
    
    # 2. 检查全局差异
    check_global_diff
    
    # 3. 分析可升级资源
    find_upgradable_resources
    
    echo ""
    echo "========================================"
    echo "分析完成"
    echo "========================================"
}

main "$@"
