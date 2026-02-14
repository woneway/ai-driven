#!/bin/bash
# =============================================================================
# init-space.sh - 创建新的 workspace
#
# 用法:
#   ./init-space.sh <space_name> [code_root1] [code_root2] ...
#
# 示例:
#   ./init-space.sh poker_space ../york/ios-poker-game
#   ./init-space.sh myapp ../frontend ../backend
#
# 注意:
#   - 代码仓库路径是相对于 workspace 目录的相对路径
#   - 会在当前目录创建 workspaces/<space_name> 目录
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
    echo "  $0 poker_space ../york/ios-poker-game"
    echo ""
    echo "  # 多代码仓库"
    echo "  $0 myapp ../frontend ../backend"
    echo ""
    echo "注意: 代码仓库路径是相对于 workspace 目录的相对路径"
    exit 1
fi

# 获取 ai-driven 根目录
AI_DRIVEN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SPACE_ROOT="$AI_DRIVEN_ROOT/workspaces/$SPACE_NAME"

if [ -d "$SPACE_ROOT" ]; then
    echo "错误: $SPACE_ROOT 已存在"
    exit 1
fi

echo "创建 workspace: $SPACE_NAME"
echo "  代码仓库: $CODE_ROOTS"
echo ""

# 1. 创建目录结构
mkdir -p "$SPACE_ROOT"/{.specs,.changes,.roles,.cursor/{skills,rules}}

# 2. 创建 .space-config（核心配置文件）
# 将 CODE_ROOTS 转换为逗号分隔的字符串
CODE_ROOTS_COMMA=$(echo "$CODE_ROSTS" | tr ' ' ',')

cat > "$SPACE_ROOT/.space-config" << EOF
# Workspace Configuration
# 此文件是 ai-driven 的核心配置

# workspace 名称
SPACE_NAME=$SPACE_NAME

# 代码仓库列表（相对于 workspace 目录的路径）
CODE_ROOTS=$CODE_ROOTS

# 使用的语言/技术栈（用于选择合适的技能，可选）
# LANGUAGES=swift,python,go
EOF

# 3. 创建 .code-workspace（Cursor 配置）
# 将每个 code_root 转换为相对路径
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
cat > "$SPACE_ROOT/.roles/decisions.md" << 'EOF'
# 架构与产品决策记录

> 记录项目中的重要架构和产品决策。

---
EOF

cat > "$SPACE_ROOT/.roles/lessons.md" << 'EOF'
# 经验教训

> 记录开发过程中的踩坑经验和最佳实践。

---
EOF

cat > "$SPACE_ROOT/.roles/prefs.md" << 'EOF'
# 代码偏好

> 记录项目的代码风格约定和偏好。

---
EOF

cat > "$SPACE_ROOT/.roles/feedback.md" << 'EOF'
# 反馈给 AI-Driven

> AI 自动识别并记录需要升级的能力。

---
EOF

# 6. 创建 .cursor/rules（从模板复制）
for tmpl in "$AI_DRIVEN_ROOT/common/rules/"*.template.mdc; do
    [ -f "$tmpl" ] || continue
    out_name="$(basename "${tmpl%.template.mdc}.mdc")"
    sed "s|{{SPEC_ROOT}}|.|g; s|{{PROJECT_NAME}}|$SPACE_NAME|g" \
        "$tmpl" > "$SPACE_ROOT/.cursor/rules/$out_name"
done

# 复制非模板 rules
for static_mdc in "$AI_DRIVEN_ROOT/common/rules/"*.mdc; do
    [ -f "$static_mdc" ] || continue
    [[ "$static_mdc" == *.template.mdc ]] && continue
    cp "$static_mdc" "$SPACE_ROOT/.cursor/rules/"
done

# 7. 创建 skills symlinks（使用相对路径）
cd "$SPACE_ROOT/.cursor/skills"
for skill_dir in "$AI_DRIVEN_ROOT/common/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    ln -s "../../common/skills/$skill_name" "$skill_name"
done

# 8. 初始化 git
cd "$SPACE_ROOT"
git init -q
git add -A
git commit -q -m "初始化 $SPACE_NAME workspace"

echo "✅ 创建完成: $SPACE_NAME"
echo ""
echo "📁 目录结构:"
echo "   $SPACE_ROOT/"
echo "   ├── .specs/         # 权威规范"
echo "   ├── .changes/       # 变更管理"
echo "   ├── .roles/         # 共享记忆"
echo "   ├── .cursor/        # Cursor 配置"
echo "   ├── .space-config   # workspace 配置（核心）"
echo "   └── .code-workspace # Cursor 多文件夹"
echo ""
echo "📝 下一步:"
echo "   1. 用 Cursor 打开: $SPACE_ROOT/.code-workspace"
echo "   2. 使用 /dev 命令开始开发"
echo ""
echo "💡 提示: 代码仓库路径是相对路径，便于项目迁移"
