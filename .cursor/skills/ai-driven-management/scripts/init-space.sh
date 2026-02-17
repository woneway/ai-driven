#!/bin/bash
# =============================================================================
# init-space.sh - 创建新的 AI-Driven workspace
#
# 用法:
#   bash .cursor/skills/ai-driven-management/scripts/init-space.sh <space_name>
#
# 示例:
#   bash scripts/init-space.sh my_space
#
# 环境变量（详见 common.sh）:
#   AI_ROOT            ai-driven 所在的父目录（自动检测）
#   PROJECTS_DIR       项目代码目录（默认: projects，相对于 ai-driven）
#   WORKSPACES_PATH   workspaces 存放路径（默认: workspaces）
# =============================================================================

set -e

# === 加载公共配置 ===
CALLER_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$CALLER_SCRIPT_DIR/common.sh"
_validate_ai_driven_root

# === 解析参数 ===
SPACE_NAME="$1"

# === 验证 ===
if [ -z "$SPACE_NAME" ]; then
    echo "用法: $0 <space_name>"
    echo ""
    echo "示例:"
    echo "  $0 my_space"
    exit 1
fi

if [[ ! "$SPACE_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "错误: workspace 名称只能包含字母、数字、下划线和连字符"
    exit 1
fi

SPACE_ROOT="$WORKSPACES_PATH/$SPACE_NAME"

if [ -d "$SPACE_ROOT" ]; then
    echo "错误: $SPACE_ROOT 已存在"
    exit 1
fi

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "错误: 未找到模板目录 $TEMPLATE_DIR"
    exit 1
fi

echo "创建 workspace: $SPACE_NAME"
info "AI_ROOT: $AI_ROOT"
info "AI_DRIVEN_ROOT: $AI_DRIVEN_ROOT"
info "PROJECTS_DIR: $PROJECTS_DIR"
echo ""

# === 1. 从模板复制 ===
echo "从模板复制..."
mkdir -p "$SPACE_ROOT"
cp -r "$TEMPLATE_DIR"/. "$SPACE_ROOT/" 2>/dev/null || true
# 复制隐藏文件
for f in "$TEMPLATE_DIR"/.*; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "." ] || [ "$(basename "$f")" = ".." ] && continue
    cp -r "$f" "$SPACE_ROOT/" 2>/dev/null || true
done

# === 2. 生成 .workspace.env ===
echo "配置 .workspace.env 文件..."

# 代码路径 = PROJECTS_DIR/项目名（去掉 _space 后缀）
# 使用相对路径，便于 fork 后使用
PROJECT_NAME="${SPACE_NAME%_space}"
PROJECT_PATH="../projects/$PROJECT_NAME"

cat > "$SPACE_ROOT/.workspace.env" << EOF
# AI-Driven Workspace 配置
# 由 init-space.sh 自动生成

# ========== Workspace 信息 ==========
SPACE_NAME=$SPACE_NAME
PROJECT_PATH=$PROJECT_PATH

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

echo "  已生成 .workspace.env"

# === 3. 创建项目目录 ===
echo "创建项目目录..."

# 使用完整路径创建目录（因为 mkdir 需要完整路径）
# PROJECT_PATH 是相对路径，需要基于 workspace 父目录计算
PARENT_DIR="$(dirname "$SPACE_ROOT")"
ABS_PROJECT_PATH="$PARENT_DIR/$PROJECT_PATH"
mkdir -p "$ABS_PROJECT_PATH"
echo "  项目目录: $PROJECT_PATH (相对路径)"

# === 4. 生成 .code-workspace ===
echo "生成 .code-workspace..."

cat > "$SPACE_ROOT/${SPACE_NAME}.code-workspace" << EOF
{
    "folders": [
        {"path": "."},
        {"path": "$PROJECT_PATH"}
    ],
    "settings": {}
}
EOF

# === 5. 初始化 OpenSpec 项目目录 ===
echo "初始化 OpenSpec 项目目录..."

# 检查全局 opsx 命令是否已安装
GLOBAL_OPSX_COUNT=$(ls "$CURSOR_HOME/commands"/opsx-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$GLOBAL_OPSX_COUNT" -ge 8 ]; then
    echo "  全局 opsx 命令已就绪 ($GLOBAL_OPSX_COUNT 个)"
else
    echo "  警告: 全局 opsx 命令未安装或不完整 ($GLOBAL_OPSX_COUNT 个)"
    echo "  请先运行: bash $CALLER_SCRIPT_DIR/setup-global.sh"
fi

# 只创建 openspec/ 项目目录
if command -v openspec &>/dev/null; then
    if (cd "$SPACE_ROOT" && openspec init --tools none 2>/dev/null); then
        echo "  OpenSpec 项目目录已创建"
    else
        echo "  警告: OpenSpec 初始化失败，手动创建目录"
        mkdir -p "$SPACE_ROOT/openspec/changes" "$SPACE_ROOT/openspec/specs"
    fi
else
    echo "  openspec 未安装，手动创建目录"
    mkdir -p "$SPACE_ROOT/openspec/changes" "$SPACE_ROOT/openspec/specs"
    echo "  安装 openspec: npm i -g @fission-ai/openspec@latest"
fi

# === 6. 确保 .cursor 目录完整 ===
echo "确保 .cursor 目录完整..."
mkdir -p "$SPACE_ROOT/.cursor/commands"
mkdir -p "$SPACE_ROOT/.cursor/rules"
# 注意：skills 和 agents 使用全局的，不需要在 workspace 中创建

# 复制 rules 模板
if [ -f "$TEMPLATE_DIR/.cursor/rules/ai-driven.mdc" ] && [ ! -f "$SPACE_ROOT/.cursor/rules/ai-driven.mdc" ]; then
    cp "$TEMPLATE_DIR/.cursor/rules/ai-driven.mdc" "$SPACE_ROOT/.cursor/rules/"
fi

# 复制 commands 模板
if [ -d "$TEMPLATE_DIR/.cursor/commands" ]; then
    for cmd in "$TEMPLATE_DIR/.cursor/commands"/*.md; do
        [ -f "$cmd" ] || continue
        cmd_name=$(basename "$cmd")
        if [ ! -f "$SPACE_ROOT/.cursor/commands/$cmd_name" ]; then
            cp "$cmd" "$SPACE_ROOT/.cursor/commands/"
        fi
    done
fi

# === 7. 生成 README.md ===
cat > "$SPACE_ROOT/README.md" << EOF
# $SPACE_NAME

AI 自主开发 workspace。

## 入口

```
/team 做一个 xxx
```

## 原则

- 人只说需求
- AI 全自动
- 中间不需要人确认

## 项目代码

代码位于: $PROJECT_PATH (相对于 workspace 根目录)
EOF

# === 8. git init ===
cd "$SPACE_ROOT"
git init -q
git add -A
git commit -q -m "初始化 $SPACE_NAME workspace" 2>/dev/null || true

echo ""
echo "=========================================="
echo "  创建完成: $SPACE_NAME"
echo "=========================================="
echo ""
echo "目录: $SPACE_ROOT/"
echo "项目: $PROJECT_PATH"
echo ""
echo "下一步:"
echo "  1. 打开: $SPACE_ROOT/${SPACE_NAME}.code-workspace"
echo "  2. 输入: '/team 做一个 xxx'"
