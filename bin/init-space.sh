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

# 1. 从模板复制
TEMPLATE_DIR="$AI_DRIVEN_ROOT/common/workspace-template"
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "错误: 未找到模板目录 $TEMPLATE_DIR"
    exit 1
fi

echo "从模板复制..."
cp -r "$TEMPLATE_DIR"/* "$SPACE_ROOT/"
cp -r "$TEMPLATE_DIR"/.??* "$SPACE_ROOT/" 2>/dev/null || true

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

# 9. 集成 AI Coding 能力
echo ""
echo "=== 集成 AI Coding 能力 ==="

# 9.1 验证 ECC (全局配置)
echo "检查 ECC..."
if [ -d "$HOME/.cursor/commands" ] && [ -d "$HOME/.cursor/agents" ]; then
    echo "✓ ECC 已配置 (全局 ~/.cursor/)"
else
    echo "⚠ 警告: 未找到全局 ECC 配置"
    echo "  请参考: https://github.com/affaan-m/everything-claude-code"
fi

# 9.2 询问是否安装 OpenSpec
echo ""
read -p "是否安装 OpenSpec (规范设计)? [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "安装 OpenSpec..."
    if command -v openspec &> /dev/null; then
        cd "$SPACE_ROOT"
        openspec init --tools cursor --yes 2>/dev/null || openspec init --tools cursor
        echo "✓ OpenSpec 已集成"
    else
        echo "⚠ 请手动安装: npm install -g @fission-ai/openspec@latest"
    fi
fi

# 9.3 创建能力配置说明
cat > "$SPACE_ROOT/AI-CODING-INFO.md" << 'EOF'
# AI Coding 能力

本 workspace 已集成以下 AI Coding 能力：

## 全局配置（自动加载）
- `~/.cursor/commands/` - 31 个命令
- `~/.cursor/agents/` - 13 个代理
- `~/.cursor/skills/` - 33 个技能

## 可用命令
| 命令 | 用途 |
|------|------|
| /dev | AI 驱动开发入口 |
| /sdd | 规范设计 (OpenSpec) |
| /plan | 需求分析 |
| /tdd | 测试驱动开发 |
| /code-review | 代码审查 |
| /e2e | 端到端测试 |
| /build-fix | 构建错误修复 |
| /refactor-clean | 死代码清理 |

## 工作流
1. `/sdd` - 规范设计 (OpenSpec)
2. `/plan` - 需求分析
3. `/tdd` - TDD 实现
4. `/code-review` - 代码审查
5. `/e2e` - E2E 测试
EOF

# 10. 初始化 git
cd "$SPACE_ROOT"
git init -q
git add -A
git commit -q -m "初始化 $SPACE_NAME workspace"

echo ""
echo "=========================================="
echo "  ✅ 创建完成: $SPACE_NAME"
echo "=========================================="
echo ""
echo "📁 目录结构:"
echo "   $SPACE_ROOT/"
echo "   ├── .specs/              # 需求规格"
echo "   ├── .changes/            # 变更记录"
echo "   ├── .roles/              # 角色记忆"
echo "   ├── .cursor/"
echo "   │   ├── rules/           # Cursor Rules"
echo "   │   ├── agents/          # Cursor Subagents"
echo "   │   ├── commands/        # 项目命令"
echo "   │   └── skills/          # 技能链接"
echo "   ├── AI-CODING-INFO.md    # AI 能力说明"
echo "   ├── .space-config"
echo "   └── .code-workspace"
echo ""
echo "📝 下一步:"
echo "   1. 用 Cursor 打开: $SPACE_ROOT/.code-workspace"
echo "   2. 使用 /dev 命令开始开发"
echo ""
echo "💡 AI Coding 能力:"
echo "   - ECC 命令: /plan, /tdd, /code-review, /e2e"
echo "   - OpenSpec: /sdd (如已安装)"
