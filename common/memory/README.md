# ai-driven 记忆系统配置

## 概述

本配置用于 ai-driven 平台的统一记忆服务，支持跨 workspace 的 AI 学习能力。

## Mem0 配置

```yaml
version: "1.0"

# 记忆服务配置
memory:
  # 提供者: mem0 (开源版) 或 mem0-platform (托管版)
  provider: "mem0"

  # 存储配置
  storage:
    # 类型: sqlite, postgres, chroma, qdrant
    type: "sqlite"
    path: "../data/memory.db"

  # 默认配置
  defaults:
    # 基础配置
    user_id: "ai-driven"
    recall: true
    remember: true

    # 嵌入模型
    embedding_model: "openai"
    # embedding_dims: 1536

    # 搜索配置
    search:
      top_k: 5
      threshold: 0.7

    # 保留策略
    retention:
      max_memories: 1000
      auto_cleanup: true
```

## Workspace 隔离

每个 workspace 通过唯一的 `user_id` 隔离记忆：
- workspace: poker_space → user_id: poker_space
- workspace: crypto_trade → user_id: crypto_trade

## 使用方式

### Python API

```python
from common.memory.memory_client import AiDrivenMemory

# 初始化（传入 workspace 名称）
memory = AiDrivenMemory("poker_space")

# 添加记忆
memory.add("使用 SQLite 存储用户数据，因为数据量小且需要简单部署")

# 搜索记忆
results = memory.search("用户数据存储方案")

# 获取所有记忆
all_memories = memory.get_all()
```

### CLI

```bash
# 添加记忆
python -m common.memory.cli add "使用 SQLite" --workspace poker_space

# 搜索记忆
python -m common.memory.cli search "存储方案" --workspace poker_space

# 列出所有记忆
python -m common.memory.cli list --workspace poker_space
```

## 数据存储

- SQLite 数据库: `data/memory.db`
- 包含表: memories, embeddings, metadata

## 注意事项

1. 首次使用需安装依赖: `pip install mem0ai`
2. 确保 data 目录可写
3. 定期备份 memory.db