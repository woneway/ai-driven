---
description: 规范设计命令。基于 OpenSpec 框架，在编写代码之前先完成技术规范。
---

# /sdd 命令 - 规范设计 (Spec-Driven Development)

## 概述

SDD = Spec-Driven Development

使用 OpenSpec 框架，在编写代码之前先完成技术规范。确保：
- 人类和 AI 在写代码前对齐规范
- 每个变更有独立的文件夹（proposal, specs, design, tasks）
- 规范作为"活文档"与代码共存

## 前置要求

```bash
# 安装 OpenSpec
npm install -g @fission-ai/openspec@latest

# 在项目中初始化
cd your-project
openspec init --tools cursor
```

## OpenSpec 工作流

```
用户需求
    ↓
/opsx:new <变更名>   创建变更
    ↓
/opsx:ff            快速生成所有规划文档
    ↓
/opsx:continue      继续下一个 artifact
    ↓
/opsx:apply         实现任务
    ↓
/opsx:archive       归档并更新主规格
```

## OpenSpec 命令

| 命令 | 用途 |
|------|------|
| /opsx:new | 创建新变更 |
| /opsx:ff | 快速生成所有规划文档 |
| /opsx:continue | 继续下一个 artifact |
| /opsx:apply | 实现任务 |
| /opsx:archive | 归档并更新主规格 |
| /opsx:verify | 验证完整性 |

## 目录结构

```
your-project/
├── openspec/
│   ├── specs/                    # 权威规格
│   └── changes/                  # 变更提案
│       ├── add-dark-mode/
│       │   ├── proposal.md      # 为什么做
│       │   ├── specs/           # 需求和场景
│       │   ├── design.md        # 技术设计
│       │   └── tasks.md          # 实现任务
│       └── archive/              # 已完成的变更
└── .cursor/
    └── commands/                 # OpenSpec 命令
```

## 设计文档结构

### proposal.md
```markdown
# Proposal: [变更名称]

## Summary
[一行描述]

## Why
[为什么需要这个变更]

## What
[将会发生什么变化]

## Risks
- [风险 1]
- [风险 2]

## Success Criteria
- [ ] 标准 1
- [ ] 标准 2
```

### design.md
```markdown
# Design: [变更名称]

## Approach
[技术方案描述]

## Architecture
[架构变更]

## API Design
[API 设计]

## Data Model
[数据模型]

## Dependencies
- [依赖 1]
- [依赖 2]
```

### tasks.md
```markdown
# Tasks: [变更名称]

## Implementation Checklist

- [ ] 1.1 [任务描述]
    - File: path/to/file.ts

- [ ] 1.2 [任务描述]
    - File: path/to/another.ts
```

## 与 TDD 配合

```
SDD 阶段（设计）
    ↓
/opsx:ff 生成 design.md, tasks.md
    ↓
/opsx:apply 实现代码
    ↓
TDD 阶段（实现）
    ↓
使用 /tdd 命令写测试
    ↓
ECC code-reviewer 代码审查
    ↓
ECC e2e-runner E2E 测试
```

## 更多信息

- OpenSpec 官网: https://openspec.dev/
- OpenSpec GitHub: https://github.com/Fission-AI/OpenSpec
