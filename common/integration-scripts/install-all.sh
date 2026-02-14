#!/bin/bash
# install-all.sh - 一键集成所有 AI Coding 能力

set -e

echo "=========================================="
echo "  ai-driven 能力集成"
echo "=========================================="
echo ""

# 当前目录
PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_DIR"

# 1. 验证 ECC
echo ">>> 1/4 验证 ECC 配置..."
if bash common/integration-scripts/install-ecc.sh; then
    echo "✓ ECC 验证通过"
else
    echo "⚠ ECC 未完全配置，部分功能可能不可用"
fi
echo ""

# 2. 安装 OpenSpec
echo ">>> 2/4 安装 OpenSpec..."
if command -v openspec &> /dev/null; then
    bash common/integration-scripts/install-openspec.sh
    echo "✓ OpenSpec 已集成"
else
    echo "⚠ OpenSpec 未安装，使用 /sdd 命令需要先安装"
fi
echo ""

# 3. 安装 Mem0 (可选)
echo ">>> 3/4 安装 Mem0 (可选)..."
if [ -f "package.json" ]; then
    bash common/integration-scripts/install-mem0.sh
    echo "✓ Mem0 已集成"
else
    echo "⚠ 跳过 Mem0 (需要 package.json)"
fi
echo ""

# 4. 验证结果
echo ">>> 4/4 验证结果..."
echo ""
echo "=========================================="
echo "  集成完成"
echo "=========================================="
echo ""
echo "可用命令:"
echo "  /dev    - AI 驱动开发入口"
echo "  /sdd    - 规范设计 (需要 OpenSpec)"
echo "  /plan   - 需求分析"
echo "  /tdd    - 测试驱动开发"
echo "  /code-review - 代码审查"
echo "  /e2e    - 端到端测试"
echo ""
echo "如需安装 OpenSpec:"
echo "  npm install -g @fission-ai/openspec@latest"
echo "  openspec init --tools cursor"
