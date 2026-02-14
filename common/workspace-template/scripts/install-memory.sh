#!/bin/bash
# install-memory.sh - 安装记忆系统

set -e

echo "=== 安装记忆系统 ==="

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "需要 Python 3"
    exit 1
fi

# 安装依赖
pip install mem0ai pyyaml 2>/dev/null || pip3 install mem0ai pyyaml

echo "=== 记忆系统安装完成 ==="