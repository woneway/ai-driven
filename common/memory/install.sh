#!/bin/bash
# install-memory.sh - 安装 ai-driven 记忆系统依赖

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AI_DRIVEN_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== 安装 ai-driven 记忆系统 ==="

# 检查 Python 版本
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
REQUIRED_VERSION="3.9"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "错误: 需要 Python $REQUIRED_VERSION+, 当前版本: $PYTHON_VERSION"
    exit 1
fi

# 创建 data 目录
mkdir -p "$AI_DRIVEN_ROOT/data"

# 安装 Python 依赖
echo "安装 Python 依赖..."

# 检查是否有 requirements.txt
if [ -f "$AI_DRIVEN_ROOT/requirements.txt" ]; then
    # 检查是否已包含 mem0
    if ! grep -q "mem0" "$AI_DRIVEN_ROOT/requirements.txt"; then
        echo "mem0ai" >> "$AI_DRIVEN_ROOT/requirements.txt"
    fi
    if ! grep -q "yaml" "$AI_DRIVEN_ROOT/requirements.txt"; then
        echo "pyyaml" >> "$AI_DRIVEN_ROOT/requirements.txt"
    fi
    pip install -r "$AI_DRIVEN_ROOT/requirements.txt"
else
    # 创建 requirements.txt
    cat > "$AI_DRIVEN_ROOT/requirements.txt" << 'EOF'
mem0ai
pyyaml
EOF
    pip install -r "$AI_DRIVEN_ROOT/requirements.txt"
fi

# 创建数据库文件（如果不存在）
if [ ! -f "$AI_DRIVEN_ROOT/data/memory.db" ]; then
    touch "$AI_DRIVEN_ROOT/data/memory.db"
    echo "创建记忆数据库: $AI_DRIVEN_ROOT/data/memory.db"
fi

echo ""
echo "=== 记忆系统安装完成 ==="
echo ""
echo "使用方式:"
echo "  from common.memory.memory_client import AiDrivenMemory"
echo ""
echo "  memory = AiDrivenMemory('workspace_name')"
echo "  memory.add('记住这个知识点')"
echo "  memory.search('知识点')"
echo ""
echo "CLI 使用:"
echo "  python -m common.memory.memory add '记住这个' -w workspace_name"
echo "  python -m common.memory.memory search '知识点' -w workspace_name"