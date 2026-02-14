#!/usr/bin/env python3
"""
ai-driven 记忆客户端

Usage:
    from common.memory.memory_client import AiDrivenMemory

    memory = AiDrivenMemory("poker_space")
    memory.add("使用 SQLite 存储数据")
    results = memory.search("存储方案")
"""

import os
import sys
from pathlib import Path

# 添加 ai-driven 根目录到路径
AI_DRIVEN_ROOT = Path(__file__).parent.parent.parent
sys.path.insert(0, str(AI_DRIVEN_ROOT))

try:
    from mem0 import Memory
except ImportError:
    print("Error: mem0ai not installed.")
    print("Install with: pip install mem0ai")
    sys.exit(1)


class AiDrivenMemory:
    """ai-driven 记忆客户端"""

    def __init__(self, workspace_name: str, config_path: str = None):
        """
        初始化记忆客户端

        Args:
            workspace_name: workspace 名称，用于隔离记忆
            config_path: 配置文件路径
        """
        self.workspace_name = workspace_name
        self.config_path = config_path or self._get_default_config()

        # 初始化 Mem0
        self.memory = self._init_memory()

    def _get_default_config(self) -> str:
        """获取默认配置路径"""
        return str(AI_DRIVEN_ROOT / "common" / "memory" / "config.yaml")

    def _init_memory(self) -> Memory:
        """初始化 Mem0"""
        config = {}

        # 如果配置文件存在，读取配置
        if os.path.exists(self.config_path):
            import yaml
            with open(self.config_path, 'r') as f:
                config_data = yaml.safe_load(f)
                if config_data and 'memory' in config_data:
                    config = config_data['memory']

        # 使用 workspace 名称作为 user_id
        config['user_id'] = self.workspace_name

        return Memory.from_config(config)

    def add(self, message: str, metadata: dict = None) -> dict:
        """
        添加记忆

        Args:
            message: 要记忆的内容
            metadata: 额外的元数据

        Returns:
            添加结果
        """
        result = self.memory.add(
            message,
            user_id=self.workspace_name,
            metadata=metadata or {}
        )
        return result

    def search(self, query: str, limit: int = 5) -> list:
        """
        搜索记忆

        Args:
            query: 搜索关键词
            limit: 返回结果数量

        Returns:
            记忆列表
        """
        results = self.memory.search(
            query,
            user_id=self.workspace_name,
            limit=limit
        )
        return results

    def get_all(self, limit: int = 100) -> list:
        """
        获取所有记忆

        Args:
            limit: 返回结果数量

        Returns:
            记忆列表
        """
        results = self.memory.get_all(
            user_id=self.workspace_name,
            limit=limit
        )
        return results

    def delete(self, memory_id: str) -> bool:
        """
        删除记忆

        Args:
            memory_id: 记忆 ID

        Returns:
            是否成功
        """
        try:
            self.memory.delete(memory_id)
            return True
        except Exception:
            return False

    def update(self, memory_id: str, message: str) -> bool:
        """
        更新记忆

        Args:
            memory_id: 记忆 ID
            message: 新内容

        Returns:
            是否成功
        """
        try:
            self.memory.update(memory_id, message)
            return True
        except Exception:
            return False

    def reset(self) -> bool:
        """
        清空当前 workspace 的所有记忆

        Returns:
            是否成功
        """
        try:
            memories = self.get_all(limit=1000)
            for mem in memories:
                self.delete(mem['id'])
            return True
        except Exception:
            return False


def main():
    """CLI 入口"""
    import argparse

    parser = argparse.ArgumentParser(description="ai-driven 记忆系统")
    parser.add_argument("--workspace", "-w", required=True, help="workspace 名称")
    parser.add_argument("--config", "-c", help="配置文件路径")

    subparsers = parser.add_subparsers(dest="command", help="命令")

    # add 命令
    add_parser = subparsers.add_parser("add", help="添加记忆")
    add_parser.add_argument("message", help="记忆内容")
    add_parser.add_argument("--metadata", "-m", help="元数据 (JSON)")

    # search 命令
    search_parser = subparsers.add_parser("search", help="搜索记忆")
    search_parser.add_argument("query", help="搜索关键词")
    search_parser.add_argument("--limit", "-l", type=int, default=5, help="结果数量")

    # list 命令
    list_parser = subparsers.add_parser("list", help="列出所有记忆")
    list_parser.add_argument("--limit", "-l", type=int, default=100, help="结果数量")

    # reset 命令
    subparsers.add_parser("reset", help="清空记忆")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    # 初始化记忆客户端
    memory = AiDrivenMemory(args.workspace, args.config)

    if args.command == "add":
        import json
        metadata = json.loads(args.metadata) if args.metadata else None
        result = memory.add(args.message, metadata)
        print(f"Added: {result}")

    elif args.command == "search":
        results = memory.search(args.query, args.limit)
        print(f"Found {len(results)} results:")
        for i, r in enumerate(results, 1):
            print(f"\n{i}. {r.get('content', r.get('message', 'N/A'))}")
            print(f"   Score: {r.get('score', 'N/A')}")

    elif args.command == "list":
        results = memory.get_all(args.limit)
        print(f"Total {len(results)} memories:")
        for i, r in enumerate(results, 1):
            print(f"\n{i}. {r.get('content', r.get('message', 'N/A'))}")

    elif args.command == "reset":
        confirm = input(f"Confirm reset all memories for {args.workspace}? [y/N]: ")
        if confirm.lower() == 'y':
            memory.reset()
            print("Reset complete.")


if __name__ == "__main__":
    main()