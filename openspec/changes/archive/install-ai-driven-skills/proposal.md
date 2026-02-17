# 提案：安装 obra/superpowers skills

## 概述

安装 obra/superpowers 仓库中的 2 个热门 skills，补充 ai-driven 框架在方案分析和调试方面的能力。

## 背景

- 当前 global_cursor 缺少通用的头脑风暴和系统调试技能
- OpenSpec 的 `openspec-explore` 可用于思路探索，但缺少更结构化的头脑风暴流程
- 量化交易项目 (crypto-trade) 经常需要系统性调试

## 方案

安装以下 skills：

| Skill | 安装量 | 用途 |
|-------|--------|------|
| brainstorming | 21.3K | 头脑风暴、方案设计 |
| systematic-debugging | 11.8K | 系统化调试、根因分析 |

## 安装流程

1. 使用 `npx skills add` 安装到 ~/.agents/skills/
2. 移动到 common/global_cursor/skills/
3. 清理 ~/.agents/skills/ 避免重复存储
4. 验证 ~/.cursor/skills symlink 正常

## 目标目录

- 实际文件：`common/global_cursor/skills/`
- Cursor 读取：`~/.cursor/skills/` → symlink
