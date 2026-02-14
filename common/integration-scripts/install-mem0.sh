#!/bin/bash
# install-mem0.sh - 集成 Mem0 记忆系统

set -e

echo "=== 集成 Mem0 记忆系统 ==="

# 检查 Node.js 版本
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "错误: 需要 Node.js 20+, 当前版本: $(node -v)"
    exit 1
fi

# 安装 Mem0
if npm list mem0 &> /dev/null; then
    echo "Mem0 已安装"
else
    echo "安装 Mem0..."
    npm install mem0ai
fi

# 创建记忆配置文件
if [ ! -f ".ai-memory.json" ]; then
    cat > .ai-memory.json << 'EOF'
{
  "provider": "mem0",
  "config": {
    "user_id": "{{PROJECT_NAME}}",
    "preference": {
      "remember": true,
      "recall": true
    }
  }
}
EOF
    echo "创建 .ai-memory.json 配置文件"
fi

echo "=== Mem0 集成完成 ==="
echo "记忆系统已配置，使用 Mem0 API 进行跨会话记忆"
