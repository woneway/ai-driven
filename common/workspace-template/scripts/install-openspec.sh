#!/bin/bash
# install-openspec.sh - 集成 OpenSpec 规范设计框架

set -e

echo "=== 集成 OpenSpec ==="

# 检查是否已安装
if command -v openspec &> /dev/null; then
    echo "OpenSpec 已安装: $(openspec --version)"
else
    echo "安装 OpenSpec..."
    npm install -g @fission-ai/openspec@latest
fi

# 在当前项目初始化 OpenSpec
if [ -d "openspec" ]; then
    echo "OpenSpec 已初始化"
else
    echo "初始化 OpenSpec..."
    openspec init --tools cursor
fi

echo "=== OpenSpec 集成完成 ==="
echo "使用 /opsx:new <功能名> 开始新功能"
