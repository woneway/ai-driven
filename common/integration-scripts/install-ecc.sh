#!/bin/bash
# install-ecc.sh - 验证 everything-claude-code 配置

set -e

echo "=== 验证 ECC 配置 ==="

ECC_DIR="$HOME/.cursor"

# 检查目录
if [ ! -d "$ECC_DIR" ]; then
    echo "错误: 未找到 ~/.cursor 目录"
    echo "请先安装 everything-claude-code"
    exit 1
fi

# 检查关键配置
CHECK_FILES=(
    "$ECC_DIR/commands/plan.md"
    "$ECC_DIR/commands/tdd.md"
    "$ECC_DIR/commands/code-review.md"
    "$ECC_DIR/commands/e2e.md"
    "$ECC_DIR/agents/planner.md"
    "$ECC_DIR/agents/tdd-guide.md"
    "$ECC_DIR/agents/code-reviewer.md"
)

MISSING=0
for file in "${CHECK_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $(basename $file)"
    else
        echo "✗ $(basename $file) - 缺失"
        MISSING=1
    fi
done

if [ $MISSING -eq 1 ]; then
    echo ""
    echo "请安装 everything-claude-code: https://github.com/affaan-m/everything-claude-code"
    exit 1
fi

echo ""
echo "=== ECC 配置验证通过 ==="
echo ""
echo "可用命令: /plan, /tdd, /code-review, /e2e, /build-fix"
echo "可用代理: planner, tdd-guide, code-reviewer, e2e-runner"
