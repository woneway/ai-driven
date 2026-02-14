#!/bin/bash
# =============================================================================
# init-space.sh - 创建新的 workspace
#
# 用法:
#   ./init-space.sh <space_name> [code_root1] [code_root2] ...
#
# 示例:
#   ./init-space.sh poker_space ../ai-projects/ios-poker-game
#   ./init-space.sh myapp ../ai-projects/frontend ../ai-projects/backend
#
# 注意:
#   - 代码仓库路径是相对于 ai-driven 根目录的路径
#   - 项目代码应该存放在 ai/ai-projects/ 目录下
#   - 会在 workspaces/ 创建 workspace 元数据
# =============================================================================

set -e

SPACE_NAME="$1"
shift
CODE_ROOTS="$@"

if [ -z "$SPACE_NAME" ] || [ -z "$CODE_ROOTS" ]; then
    echo "用法: $0 <space_name> [code_root1] [code_root2] ..."
    echo ""
    echo "示例:"
    echo "  # 单代码仓库"
    echo "  $0 poker_space ../ai-projects/ios-poker-game"
    echo ""
    echo "  # 多代码仓库"
    echo "  $0 myapp ../ai-projects/frontend ../ai-projects/backend"
    echo ""
    echo "注意: 代码仓库路径是相对于 ai-driven 根目录的路径"
    echo "      项目代码应存放在 ai/ai-projects/ 目录下"
    exit 1
fi

# 获取 ai-driven 根目录
AI_DRIVEN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORKSPACES_ROOT="$AI_DRIVEN_ROOT/workspaces"
SPACE_ROOT="$WORKSPACES_ROOT/$SPACE_NAME"

if [ -d "$SPACE_ROOT" ]; then
    echo "错误: $SPACE_ROOT 已存在"
    exit 1
fi

echo "创建 workspace: $SPACE_NAME"
echo "  代码仓库: $CODE_ROOTS"
echo ""

# 1. 创建目录结构
mkdir -p "$SPACE_ROOT"/{.specs,.changes,.roles,.cursor/{rules,agents,skills}}

# 2. 创建 .space-config
cat > "$SPACE_ROOT/.space-config" << EOF
# Workspace Configuration
SPACE_NAME=$SPACE_NAME
CODE_ROOTS=$CODE_ROOTS
EOF

# 3. 创建 .code-workspace（Cursor 配置）
FOLDERS_JSON="[{\"path\": \".\""
for code_root in $CODE_ROOTS; do
    CODE_ROOT_REL=$(perl -e 'use File::Spec; print File::Spec->abs2rel($ARGV[0], $ARGV[1])' "$code_root" "$SPACE_ROOT")
    FOLDERS_JSON="$FOLDERS_JSON, {\"path\": \"$CODE_ROOT_REL\"}"
done
FOLDERS_JSON="$FOLDERS_JSON]"

cat > "$SPACE_ROOT/.code-workspace" << EOF
{
    "folders": $FOLDERS_JSON,
    "settings": {}
}
EOF

# 4. 创建 .gitignore
cat > "$SPACE_ROOT/.gitignore" << 'EOF'
.DS_Store
*.swp
*.swo
*~
EOF

# 5. 创建角色记忆文件
for mem_file in decisions lessons prefs feedback; do
    case $mem_file in
        decisions) title="决策" ;;
        lessons) title="经验教训" ;;
        prefs) title="偏好" ;;
        feedback) title="反馈" ;;
    esac
    cat > "$SPACE_ROOT/.roles/${mem_file}.md" << EOF
# $title

> $mem_file 记录。

---
EOF
done

# 6. 同步 Cursor Rules (common/rules/*.mdc -> .cursor/rules/)
echo "同步 Rules..."
if [ -d "$AI_DRIVEN_ROOT/common/rules" ]; then
    cp -n "$AI_DRIVEN_ROOT/common/rules/"*.mdc "$SPACE_ROOT/.cursor/rules/" 2>/dev/null || true
fi

# 7. 同步 Commands 参考文档 (common/commands/*.md -> .cursor/commands/)
echo "同步 Commands..."
mkdir -p "$SPACE_ROOT/.cursor/commands"
if [ -d "$AI_DRIVEN_ROOT/common/commands" ]; then
    cp -n "$AI_DRIVEN_ROOT/common/commands/"*.md "$SPACE_ROOT/.cursor/commands/" 2>/dev/null || true
fi

# 7. 同步 Cursor Agents (common/agents/*.md -> .cursor/agents/)
echo "同步 Agents..."
mkdir -p "$SPACE_ROOT/.cursor/agents"
if [ -d "$AI_DRIVEN_ROOT/common/agents" ]; then
    cp -n "$AI_DRIVEN_ROOT/common/agents/"*.md "$SPACE_ROOT/.cursor/agents/" 2>/dev/null || true
fi

# 8. 创建 skills symlinks
echo "同步 Skills..."
cd "$SPACE_ROOT/.cursor/skills"
if [ -d "$AI_DRIVEN_ROOT/common/skills" ]; then
    for skill_dir in "$AI_DRIVEN_ROOT/common/skills/"*/; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        if [ ! -e "$skill_name" ]; then
            ln -s "../../common/skills/$skill_name" "$skill_name"
        fi
    done
fi

# 9. 初始化 git
cd "$SPACE_ROOT"
git init -q
git add -A
git commit -q -m "初始化 $SPACE_NAME workspace"

echo ""
echo "✅ 创建完成: $SPACE_NAME"
echo ""
echo "📁 目录结构:"
echo "   $SPACE_ROOT/"
echo "   ├── .specs/              # 需求规格"
echo "   ├── .changes/            # 变更记录"
echo "   ├── .roles/              # 角色记忆"
echo "   ├── .cursor/"
echo "   │   ├── rules/           # Cursor Rules (自动加载)"
echo "   │   ├── agents/          # Cursor Subagents (自动加载)"
echo "   │   └── skills/          # 技能链接"
echo "   ├── .space-config"
echo "   └── .code-workspace"
echo ""
echo "📝 下一步:"
echo "   1. 用 Cursor 打开: $SPACE_ROOT/.code-workspace"
echo "   2. 使用 /dev 命令开始开发"
