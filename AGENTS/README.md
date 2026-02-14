# Agents 子 Agent 定义

## 概述

本文档定义 ai-driven 的子 Agent 体系。

## Agent 对应关系

| Agent | 旧角色 | 职责 | 产出 |
|-------|--------|------|------|
| **planner** | PM + Arch + TL | 需求分析、计划制定 | proposal + design + tasks |
| **executor** | Dev | 代码实现、TDD | 代码 + 单元测试 |
| **reviewer** | CR | 代码审查 | 审查报告 |
| **researcher** | - | 调研分析 | 调研报告 |
| **qa** | QA | 测试验证 | 测试报告 |

## 调度规则

### 按复杂度

| 复杂度 | 调度 |
|--------|------|
| 小（<2h） | executor → reviewer |
| 中（2h-1d） | planner → executor → reviewer |
| 大（>1d） | planner → executor → reviewer → qa |

### 按类型

| 类型 | 可跳过 |
|------|--------|
| Bug 修复 | planner |
| 调研 | executor, qa |
| 小优化 | planner, qa |

## Agent 详细说明

详见各 Agent 目录下的 AGENT.md：

- `planner/AGENT.md` - 计划 Agent
- `executor/AGENT.md` - 执行 Agent  
- `reviewer/AGENT.md` - 审查 Agent
- `researcher/AGENT.md` - 调研 Agent
- `qa/AGENT.md` - 测试 Agent
