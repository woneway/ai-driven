---
description: AI 驱动开发唯一入口。
---

# /dev 命令 - AI 驱动开发唯一入口

## 概述

`/dev` 是唯一的开发命令。

人类只需表达需求，AI 自动完成全流程。

## 使用方式

```
人类: /dev 做一个锦标赛盲注递增功能
AI:   自动执行完整流程
```

## 自动执行流程

AI 收到 `/dev` 命令后，自动执行以下步骤：

### 1. 理解需求
- 分析用户需求
- 确认目标和约束

### 2. 规范设计（SDD）
- 创建 `.changes/{date}_{slug}/design.md`
- 包含：方案选型、API 设计、架构图

### 3. TDD 实现
- 先写测试
- 再写实现
- 确保 80%+ 覆盖率

### 4. 代码审查
- 使用 code-reviewer 代理审查
- 修复所有问题

### 5. E2E 测试
- 验证关键路径
- 确保功能正常

### 6. 记忆更新
- 更新 `.roles/knowledge.md`
- 更新 `.roles/decisions.md`
- 创建 `.changes/{date}_{slug}/summary.md`

### 7. 报告完成
- 总结完成的内容
- 说明遇到的问题和解决方案

## 支持的需求类型

| 类型 | 示例 |
|------|------|
| 新功能 | `/dev 做一个锦标赛盲注递增功能` |
| Bug 修复 | `/dev 新建档案后数据没清空` |
| 优化 | `/dev 优化排行榜查询性能` |
| 调研 | `/dev 调研 WebSocket 连接管理` |
| 技术债 | `/dev 清理 SwiftLint 警告` |

## 可用资源

AI 可以使用全局配置中的资源：

- `~/.cursor/commands/` - 31 个命令
- `~/.cursor/agents/` - 13 个代理
- `~/.cursor/skills/` - 33 个技能

## 质量门禁

AI 必须确保：

- [ ] design.md 存在且完整
- [ ] 测试存在（TDD 方式）
- [ ] 测试通过（80%+ 覆盖率）
- [ ] 代码审查通过
- [ ] E2E 测试通过
- [ ] lint 通过
- [ ] 记忆已更新

## 记忆更新

每个任务完成后，AI 自动更新：

- `.roles/knowledge.md` - 项目知识
- `.roles/decisions.md` - 架构决策
- `.roles/lessons.md` - 经验教训
- `.changes/{date}_{slug}/summary.md` - 任务总结

## 重要

- `/dev` 是唯一入口
- 不需要手动调用其他命令
- AI 自动执行完整流程
- 完成后自动更新记忆