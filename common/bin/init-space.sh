#!/bin/bash
# =============================================================================
# init-space.sh - 创建新的 workspace
# 用法: ./init-space.sh <space_name> <code_root1> [code_root2] ...
# 示例: ./init-space.sh poker_space /Users/lianwu/york/ios-poker-game
# =============================================================================

set -e

SPACE_NAME="$1"
shift
CODE_ROOTS="$@"

if [ -z "$SPACE_NAME" ] || [ -z "$CODE_ROOTS" ]; then
    echo "用法: $0 <space_name> <code_root1> [code_root2] ..."
    echo "示例: $0 poker_space /Users/lianwu/york/ios-poker-game"
    exit 1
fi

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

# 2. 创建 .space-config
cat > "$SPACE_ROOT/.space-config" << EOF
SPACE_NAME=$SPACE_NAME
CODE_ROOTS=$CODE_ROOTS
EOF

# 3. 创建 .code-workspace（Cursor 多文件夹配置）
# 生成相对路径
FIRST_CODE_ROOT="$1"
CODE_ROOT_REL=$(perl -e 'use File::Spec; print File::Spec->abs2rel($ARGV[0], $ARGV[1])' "$FIRST_CODE_ROOT" "$SPACE_ROOT")

cat > "$SPACE_ROOT/.code-workspace" << EOF
{
    "folders": [
        { "path": "." },
        { "path": "$CODE_ROOT_REL" }
    ],
    "settings": {}
}
EOF

# 4. 创建角色记忆文件
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

> 记录需要 ai-driven 升级或添加的通用能力。

---
EOF

# 5. 创建 .cursor/rules（从模板复制）
for tmpl in "$AI_DRIVEN_ROOT/common/rules/"*.template.mdc; do
    [ -f "$tmpl" ] || continue
    out_name="$(basename "${tmpl%.template.mdc}.mdc")"
    sed "s|{{SPEC_ROOT}}|$SPACE_ROOT|g; s|{{PROJECT_NAME}}|$SPACE_NAME|g" \
        "$tmpl" > "$SPACE_ROOT/.cursor/rules/$out_name"
done

# 复制非模板 rules
for static_mdc in "$AI_DRIVEN_ROOT/common/rules/"*.mdc; do
    [ -f "$static_mdc" ] || continue
    [[ "$static_mdc" == *.template.mdc ]] && continue
    cp "$static_mdc" "$SPACE_ROOT/.cursor/rules/"
done

# 6. 创建 skills symlinks
for skill_dir in "$AI_DRIVEN_ROOT/common/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    ln -s "$AI_DRIVEN_ROOT/common/skills/$skill_name" "$SPACE_ROOT/.cursor/skills/$skill_name"
done

# 7. 初始化 git
cd "$SPACE_ROOT"
git init -q
git add -A
git commit -q -m "初始化 $SPACE_NAME workspace"

echo "✅ 创建完成: $SPACE_NAME"
echo ""
echo "下一步："
echo "  1. 用 Cursor 打开: $SPACE_ROOT/.code-workspace"
echo "  2. 使用 /dev 命令开始开发"
