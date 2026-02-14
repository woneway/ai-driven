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

# 6. 创建 Cursor 规则文件（深度集成）
cat > "$SPACE_ROOT/.cursor/rules/001-main.mdc" << 'EOF'
---
description: AI-Driven 主 Agent 定义
globs: "*"
---
# AI-Driven 主 Agent

## 核心价值观
1. 简单优先
2. 自动化
3. 质量保障
4. 持续学习

## 子 Agent
| Agent | 职责 |
|-------|------|
| planner | 需求分析、计划制定 |
| executor | 代码实现、TDD |
| reviewer | 代码审查 |
| researcher | 调研分析 |
| qa | 测试验证 |
EOF

cat > "$SPACE_ROOT/.cursor/rules/002-dev.mdc" << 'EOF'
---
description: /dev 命令定义
globs: "*"
---
# /dev 命令

## 用法
/dev <需求描述>

## 支持类型
- 新功能、Bug、优化、调研、技术债

## 流程
1. 分析需求
2. 创建 .changes/{date}_{slug}/
3. 调度子 Agent
4. 执行验证
5. 更新记忆
EOF

cat > "$SPACE_ROOT/.cursor/rules/003-skills.mdc" << 'EOF'
---
description: 可用技能库
globs: "*"
---
# 可用技能

## 核心
- brainstorming
- tdd
- debugging

## 语言特定（需安装）
- Swift: swiftui-expert-skill
- Python: python-testing-patterns
- Java: java-spring-development
EOF

# 7. 创建 skills symlinks
cd "$SPACE_ROOT/.cursor/skills"
for skill_dir in "$AI_DRIVEN_ROOT/TOOLS/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    ln -s "../../TOOLS/skills/$skill_name" "$skill_name"
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
echo "   ├── .specs/"
echo "   ├── .changes/"
echo "   ├── .roles/"
echo "   ├── .cursor/"
echo "   │   ├── rules/     # Cursor 自动加载"
echo "   │   └── skills/   # 技能链接"
echo "   ├── .space-config"
echo "   └── .code-workspace"
echo ""
echo "📝 下一步:"
echo "   1. 用 Cursor 打开: $SPACE_ROOT/.code-workspace"
echo "   2. 使用 /dev 命令开始开发"
