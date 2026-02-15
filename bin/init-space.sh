#!/bin/bash
# =============================================================================
# init-space.sh - 创建新的 workspace
#
# 用法:
#   ./init-space.sh <space_name> [code_root1] [code_root2] ...
#
# 示例:
#   ./init-space.sh poker_space ../ai-projects/ios-poker-game
#   ./init-space.sh myapp "../ai-projects/frontend" "../ai-projects/backend"
# =============================================================================

set -e

SPACE_NAME="$1"
shift
# 使用数组避免空格分割问题
CODE_ROOTS=("$@")

if [ -z "$SPACE_NAME" ] || [ ${#CODE_ROOTS[@]} -eq 0 ]; then
    echo "用法: $0 <space_name> [code_root1] [code_root2] ..."
    echo ""
    echo "示例:"
    echo "  $0 poker_space ../ai-projects/ios-poker-game"
    echo "  $0 myapp \"../ai-projects/frontend\" \"../ai-projects/backend\""
    exit 1
fi

# 获取 ai-driven 根目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AI_DRIVEN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACES_ROOT="$AI_DRIVEN_ROOT/workspaces"
SPACE_ROOT="$WORKSPACES_ROOT/$SPACE_NAME"

# 验证 workspace 名称格式
if [[ ! "$SPACE_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "错误: workspace 名称只能包含字母、数字、下划线和连字符"
    exit 1
fi

if [ -d "$SPACE_ROOT" ]; then
    echo "错误: $SPACE_ROOT 已存在"
    exit 1
fi

# 创建父目录
mkdir -p "$WORKSPACES_ROOT"

echo "创建 workspace: $SPACE_NAME"
echo "  代码仓库: ${CODE_ROOTS[*]}"
echo ""

# 1. 从模板复制
TEMPLATE_DIR="$AI_DRIVEN_ROOT/common/workspace-template"
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "错误: 未找到模板目录 $TEMPLATE_DIR"
    exit 1
fi

echo "从模板复制..."
# 先创建目标目录
mkdir -p "$SPACE_ROOT"
# 复制所有文件（包括隐藏文件）
cp -r "$TEMPLATE_DIR"/. "$SPACE_ROOT/" 2>/dev/null || true
# 复制隐藏文件
for f in "$TEMPLATE_DIR"/.*; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "." ] || [ "$(basename "$f")" = ".." ] && continue
    cp -r "$f" "$SPACE_ROOT/" 2>/dev/null || true
done

# 2. 创建 .space-config（保留模板注释）
echo "创建配置文件..."
cat > "$SPACE_ROOT/.space-config" << 'HEADER'
# Workspace Configuration
# 此文件由 init-space.sh 自动生成，请勿手动编辑
HEADER
echo "SPACE_NAME=\"$SPACE_NAME\"" >> "$SPACE_ROOT/.space-config"
echo "CODE_ROOTS=\"${CODE_ROOTS[*]}\"" >> "$SPACE_ROOT/.space-config"
cat >> "$SPACE_ROOT/.space-config" << 'BODY'

# Agent Teams (使用 /team 命令)
# 详细说明：见 .cursor/commands/team.md
# 原理：使用 sub-agent 能力，Lead Agent 分发任务，子 Agent 在独立窗口执行

# 依赖
# - OpenSpec: 需求规范 + 进度管理 (必需)
#   安装: npm install -g @fission-ai/openspec@latest
# - TDD: 代码质量保障 (必需)
#   使用: @tdd-guide sub-agent
# - Code Review: 代码审查
#   使用: @code-reviewer sub-agent
BODY

# 3. 创建 .code-workspace
echo "配置 VS Code 工作区..."
# 使用数组构建 JSON
FOLDERS=("{\"path\": \".\"}")
for code_root in "${CODE_ROOTS[@]}"; do
    # 验证代码目录存在
    if [ ! -d "$code_root" ]; then
        echo "警告: 代码目录不存在: $code_root"
        continue
    fi
    # 使用 realpath 获取相对路径
    CODE_ROOT_ABS="$(cd "$code_root" 2>/dev/null && pwd)" || true
    if [ -n "$CODE_ROOT_ABS" ]; then
        CODE_ROOT_REL="$(realpath --relative-to="$SPACE_ROOT" "$CODE_ROOT_ABS" 2>/dev/null || echo "$code_root")"
        FOLDERS+=("{\"path\": \"$CODE_ROOT_REL\"}")
    fi
done
# 用 , 连接数组元素
FOLDERS_JSON=$(IFS=,; echo "${FOLDERS[*]}")

cat > "$SPACE_ROOT/.code-workspace" << EOF
{
    "folders": [$FOLDERS_JSON],
    "settings": {}
}
EOF

# 4. 初始化 .homunculus
echo "初始化 .homunculus..."
mkdir -p "$SPACE_ROOT/.homunculus/insights"

# 5. 复制 ai-driven 命令到全局 (确保 /team 可用)
echo "配置 /team 命令..."
AI_DRIVEN_CMDS="$TEMPLATE_DIR/.cursor/commands"
if [ -f "$AI_DRIVEN_CMDS/team.md" ]; then
    mkdir -p "$HOME/.cursor/commands"
    if cp "$AI_DRIVEN_CMDS/team.md" "$HOME/.cursor/commands/"; then
        echo "✓ /team 命令已配置"
    else
        echo "⚠ 复制 /team 命令失败"
    fi
fi

# 6. 配置 continuous-learning-v2 hooks（合并而非覆盖）
echo "配置持续学习..."
CLV2_HOOKS="$HOME/.cursor/skills/continuous-learning-v2/hooks/observe.sh"
SETTINGS_FILE="$HOME/.cursor/settings.json"

if [ -f "$CLV2_HOOKS" ]; then
    if [ -f "$SETTINGS_FILE" ] && grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
        echo "✓ 持续学习 hooks 已存在"
    else
        mkdir -p "$HOME/.cursor"
        # 如果 settings.json 已存在，先备份
        [ -f "$SETTINGS_FILE" ] && cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
        cat > "$SETTINGS_FILE" << 'HOOKS'
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.cursor/skills/continuous-learning-v2/hooks/observe.sh pre"
      }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.cursor/skills/continuous-learning-v2/hooks/observe.sh post"
      }]
    }]
  }
}
HOOKS
        echo "✓ 持续学习 hooks 已配置"
    fi
else
    echo "⚠ continuous-learning-v2 未安装"
fi

# 6b. 追加 .gitignore 规则（如果 workspace 有代码根目录）
if [ ${#CODE_ROOTS[@]} -gt 0 ]; then
    echo "追加 .gitignore 规则..."
    for code_root in "${CODE_ROOTS[@]}"; do
        # 使用 || true 避免 set -e 导致脚本退出
        CODE_ROOT_ABS="$(cd "$code_root" 2>/dev/null && pwd)" || true
        if [ -n "$CODE_ROOT_ABS" ]; then
            CODE_ROOT_NAME="$(basename "$CODE_ROOT_ABS")"
            # 追加到 .gitignore（如果还没有这条规则）
            if ! grep -q "^$CODE_ROOT_NAME/" "$SPACE_ROOT/.gitignore" 2>/dev/null; then
                echo "$CODE_ROOT_NAME/" >> "$SPACE_ROOT/.gitignore"
            fi
        fi
    done
fi

# 7. 安装 OpenSpec (强制)
echo ""
echo "安装 OpenSpec..."
if command -v openspec &> /dev/null; then
    echo "  → 使用已安装的 OpenSpec"
else
    echo "  → 安装 OpenSpec CLI..."
    if npm install -g @fission-ai/openspec@latest 2>/dev/null; then
        echo "  ✓ OpenSpec CLI 已安装"
    else
        echo "  ⚠ OpenSpec CLI 安装失败"
    fi
fi

# 初始化 OpenSpec
if command -v openspec &> /dev/null; then
    if cd "$SPACE_ROOT" && (openspec init --tools cursor --yes 2>/dev/null || openspec init --tools cursor); then
        echo "✓ OpenSpec 已初始化"
    else
        echo "⚠ OpenSpec 初始化失败"
    fi
else
    echo "⚠ OpenSpec 不可用"
fi

# 8. 创建 README
cat > "$SPACE_ROOT/README.md" << EOF
# $SPACE_NAME

**AI 自主开发 workspace。**

## 入口

```
/team 做一个用户认证
```

## 原则

- 人只说需求
- AI 全自动
- 中间不需要人确认

## 依赖

- ECC: ~/.cursor/ (全局)
- OpenSpec: 已初始化
- 持续学习: 已配置

## 可用命令

| 命令 | 用途 |
|------|------|
| /team | AI 自主开发 |
| /plan | 需求分析 |
| /tdd | TDD 开发 |
| /code-review | 代码审查 |
| /e2e | E2E 测试 |

## 项目知识

.homunculus/insights/ - 记录项目经验
EOF

# 9. 初始化 git（检查是否有文件）
cd "$SPACE_ROOT"
if [ -n "$(find . -maxdepth 1 -type f -o -type d ! -name '.' ! -name '..' ! -name '.git' 2>/dev/null)" ]; then
    git init -q
    git add -A
    if git commit -q -m "初始化 $SPACE_NAME workspace" 2>/dev/null; then
        echo "✓ Git 仓库已初始化"
    else
        echo "⚠ Git 提交失败（可能没有文件）"
    fi
else
    echo "⚠ 没有文件可提交"
fi

echo ""
echo "=========================================="
echo "  ✅ 创建完成: $SPACE_NAME"
echo "=========================================="
echo ""
echo "📁 目录:"
echo "   $SPACE_ROOT/"
echo "   ├── .cursor/commands/  # /team 命令"
echo "   ├── .homunculus/      # 项目知识"
echo "   ├── openspec/         # 规范设计"
echo "   └── README.md"
echo ""
echo "📝 下一步:"
echo "   1. 用 Cursor 打开: $SPACE_ROOT/.code-workspace"
echo "   2. 说: /team 做一个 xxx"
