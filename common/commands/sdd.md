# `/sdd` 命令 - Spec-Driven Development 规范驱动开发

> 基于 [OpenSpec](https://github.com/Fission-AI/OpenSpec) 框架

## 概述

**SDD = Spec-Driven Development**

使用 OpenSpec 框架，在编写代码之前先完成技术规范。确保：
- 人类和 AI 在写代码前对齐规范
- 每个变更有独立的文件夹（proposal, specs, design, tasks）
- 规范作为"活文档"与代码共存

## OpenSpec 安装

```bash
npm install -g @fission-ai/openspec@latest

# 在项目中初始化
cd your-project
openspec init --tools cursor
```

## 用法

```
/sdd <需求描述>
```

## OpenSpec 工作流

```
用户需求
    ↓
/opsx:new <变更名>   创建变更
    ↓
/opsx:ff            快速生成所有规划文档（推荐）
    ↓
/opsx:continue      继续下一个 artifact
    ↓
/opsx:apply         实现任务
    ↓
/opsx:archive       归档并更新主规格
```

## OpenSpec 命令详解

### 1. `/opsx:new` - 创建新变更

```
你: /opsx:new add-dark-mode
AI: Created openspec/changes/add-dark-mode/
     Ready to create: proposal
```

### 2. `/opsx:ff` - Fast-Forward 快速生成

```
你: /opsx:ff   # "fast-forward" - 生成所有规划文档
AI: ✓ proposal.md — 为什么做，改变了什么
     ✓ specs/       — 需求和场景
     ✓ design.md    — 技术方案
     ✓ tasks.md     — 实现清单
     Ready for implementation!
```

### 3. `/opsx:continue` - 继续下一个 artifact

```
你: /opsx:continue
AI: [根据当前状态提示下一个步骤]
```

### 4. `/opsx:apply` - 实现任务

```
你: /opsx:apply
AI: Implementing tasks...
     ✓ 1.1 Add theme context provider
     ✓ 1.2 Create toggle component
     All tasks complete!
```

### 5. `/opsx:archive` - 归档

```
你: /opsx:archive
AI: Archived to openspec/changes/archive/2025-01-23-add-dark-mode/
     Specs updated. Ready for the next feature!
```

## OpenSpec 目录结构

```
your-project/
├── openspec/
│   ├── specs/                    # 权威规格（当前系统规范）
│   │   └── ...
│   └── changes/                  # 变更提案
│       ├── add-dark-mode/
│       │   ├── proposal.md      # 为什么做
│       │   ├── specs/            # 需求和场景
│       │   │   └── ...
│       │   ├── design.md         # 技术设计
│       │   ├── tasks.md          # 实现任务
│       │   └── spec-deltas/      # 规格变更
│       └── archive/              # 已完成的变更
│
└── .cursor/                     # OpenSpec 生成的命令和 skills
    ├── commands/opsx-*.md
    └── skills/openspec-*/
```

## proposal.md 结构

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

## specs/ 结构

```
specs/
├── requirements.md       # 需求列表
├── scenarios/           # 用户场景
│   ├── scenario-1.md
│   └── scenario-2.md
└── acceptance.md        # 验收标准
```

## design.md 结构

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

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| ...  |            |        |            |
```

## tasks.md 结构

```markdown
# Tasks: [变更名称]

## Implementation Checklist

- [ ] 1.1 [任务描述]
    - File: path/to/file.ts
    - Details: ...

- [ ] 1.2 [任务描述]
    - File: path/to/another.ts
    - Details: ...

## Testing

- [ ] Unit tests for X
- [ ] Integration test for Y
- [ ] E2E test for Z
```

## ai-driven 中的使用方式

### 方式 1：直接使用 OpenSpec 命令

在配置了 OpenSpec 的项目中，直接使用 `/opsx:*` 命令。

### 方式 2：通过 /sdd 调用

```
/sdd 做一个锦标赛盲注递增功能
```

AI 会：
1. 使用 `/opsx:new` 创建变更
2. 使用 `/opsx:ff` 生成所有规划文档
3. 等待用户确认
4. 使用 `/opsx:apply` 实现

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

## OpenSpec 配置

### 全局配置

```bash
openspec config --view          # 查看配置
openspec config --set key=value # 设置配置
```

### 工具选择

初始化时选择你的 AI 工具：

```bash
openspec init --tools cursor   # Cursor
openspec init --tools claude   # Claude Code
openspec init --tools windsurf # Windsurf
openspec init --tools all      # 所有工具
```

## 质量门禁

使用 `/opsx:verify` 检查：

- [ ] proposal.md 完整
- [ ] specs/ 包含需求和场景
- [ ] design.md 包含技术方案
- [ ] tasks.md 包含实现清单
- [ ] 所有任务已完成

## 相关资源

- OpenSpec 官网: https://openspec.dev/
- OpenSpec GitHub: https://github.com/Fission-AI/OpenSpec
- ECC tdd-guide: `~/.cursor/agents/tdd-guide.md`
- ECC code-reviewer: `~/.cursor/agents/code-reviewer.md`
