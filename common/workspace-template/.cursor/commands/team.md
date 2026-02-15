---
description: AI 自主开发入口。接收需求后智能路由：判断类型和复杂度，选择 OpenSpec 模式（轻量/完整），调度全局 Sub-Agent 完成开发。
---

# /team

人只说需求，AI 全自动完成。中间不需要人确认，失败自己修。

## 执行流程

收到需求后按以下步骤执行：

### 步骤 0：环境准备

0. 读取 .space-config 获取 SPACE_NAME 和 CODE_ROOTS_ABS
1. 检查 .cursor/commands/opsx-new.md 是否存在。不存在则执行: openspec init --tools cursor

### 步骤 1：需求分类

分析用户需求，判断类型和复杂度，决定 OpenSpec 模式：

| 类型 | 复杂度判断 | OpenSpec 模式 |
|------|-----------|--------------|
| 新功能开发 | 新模块、新页面、新 API | 完整模式 |
| 复杂 Bug | 跨模块、架构问题、根因不明 | 完整模式 |
| 重构 | 跨模块、架构级调整 | 完整模式 |
| 仅规划 | 用户明确只要方案不要实现 | 完整模式（只到规划） |
| 简单 Bug | 单文件、根因明确 | 轻量模式 |
| 小改动 | 改样式、改文案、加按钮、改配置 | 轻量模式 |

### 步骤 2：OpenSpec 记录

**所有变更都走 OpenSpec**，确保 AI 对项目有完整的变更历史。

#### 完整模式

1. 读取 .cursor/commands/opsx-new.md 并按其指引执行 — 创建变更目录
2. 如果涉及架构决策，使用 Task tool (subagent_type: architect) 评估架构方案
3. 如果需求复杂，使用 Task tool (subagent_type: planner) 制定实施计划
4. 读取 .cursor/commands/opsx-ff.md 并按其指引执行 — 生成 proposal.md、specs/、design.md、tasks.md

#### 轻量模式

1. 读取 .cursor/commands/opsx-new.md 并按其指引执行 — 创建变更目录
2. 在变更目录中只写 proposal.md（1-2 句话说明改了什么、为什么改）
3. 跳过 opsx-ff（不生成 specs/design/tasks）

### 步骤 3：实现

根据需求类型调度对应的 Sub-Agent：

#### 新功能 / 复杂 Bug / 重构

1. 读取 openspec/changes/<name>/tasks.md 和 design.md
2. 使用 Task tool (subagent_type: tdd-guide) 逐项实现
   - Handoff prompt 必须包含：tasks.md 全文 + design.md 全文 + 目标代码目录
3. 使用 Task tool (subagent_type: code-reviewer) 审查代码
   - Handoff prompt 必须包含：变更文件列表 + design.md 关键决策
4. 语言感知审查（根据项目技术栈选择）：
   - Go 项目 → Task tool (subagent_type: go-reviewer)
   - Python 项目 → Task tool (subagent_type: python-reviewer)
5. 如果涉及安全相关代码 → Task tool (subagent_type: security-reviewer)
6. 如果涉及数据库操作 → Task tool (subagent_type: database-reviewer)

#### 简单 Bug

1. 在 CODE_ROOTS_ABS 中定位问题代码
2. 先写失败测试复现 bug（TDD Red）
3. 修改代码使测试通过（TDD Green）
4. 运行全部测试确保无回归
5. 使用 Task tool (subagent_type: code-reviewer) 审查修复

#### 小改动

1. 在 CODE_ROOTS_ABS 目录中定位相关代码
2. 直接修改代码
3. 运行测试确保不破坏已有功能
4. 使用 Task tool (subagent_type: code-reviewer) 审查修改

#### 重构（额外步骤）

- 实现前使用 Task tool (subagent_type: refactor-cleaner) 扫描死代码
- 每个原子重构步骤后运行测试验证行为不变
- 不在重构中混入功能变更

#### 仅规划

- 完成步骤 2（完整模式）后停止
- 向用户展示规划摘要（proposal + design + tasks）
- 不进入实现阶段

### 步骤 4：验证与归档

#### 完整模式

1. 读取 .cursor/commands/opsx-verify.md 并执行
2. 如果项目有 E2E 测试配置 → Task tool (subagent_type: e2e-runner)
3. 如有问题 → 回到步骤 3 修复 → 重新验证（最多 3 轮，超过报告用户）
4. 读取 .cursor/commands/opsx-archive.md 并执行
5. 使用 Task tool (subagent_type: doc-updater) 更新项目文档

#### 轻量模式

1. 运行测试确认通过
2. 读取 .cursor/commands/opsx-archive.md 并执行

## Sub-Agent Handoff 格式

调用 Task tool 时的 prompt 必须包含：

    HANDOFF: /team -> <target subagent_type>

    Context: [需求摘要，来自 openspec/changes/<name>/proposal.md]
    Design: [技术方案，来自 design.md（完整模式）或 proposal.md（轻量模式）]
    Tasks: [待实现任务，来自 tasks.md（完整模式）或直接描述（轻量模式）]
    Target Dir: [代码目标目录，来自 .space-config 的 CODE_ROOTS_ABS]
    Files: [需要修改的具体文件列表]
    Open Questions: [待确认的问题]

## Sub-Agent 速查表

| 场景 | subagent_type |
|------|---------------|
| 新功能实现 | tdd-guide |
| 代码审查 | code-reviewer |
| 架构设计 | architect |
| 复杂规划 | planner |
| 构建失败（TS/通用） | build-error-resolver |
| 构建失败（Go） | go-build-resolver |
| Go 代码审查 | go-reviewer |
| Python 代码审查 | python-reviewer |
| 数据库相关 | database-reviewer |
| 安全审查 | security-reviewer |
| E2E 测试 | e2e-runner |
| 文档更新 | doc-updater |
| 死代码清理 | refactor-cleaner |

## 错误恢复

- OpenSpec 未初始化: openspec init --tools cursor
- 构建失败: Task tool (subagent_type: build-error-resolver)
- Go 构建失败: Task tool (subagent_type: go-build-resolver)
- 测试失败: 修复后重跑，NOT 跳过
- verify 发现问题: 回到步骤 3 修复，最多 3 轮
- opsx-*.md 不存在: openspec init --tools cursor
- 死代码/重复代码: Task tool (subagent_type: refactor-cleaner)

## 备注

- 完整 OpenSpec 命令列表见 .cursor/commands/opsx-*.md
- OpenSpec 命令格式为 /opsx-<id>（短横线，非冒号）
- 代码目标目录见 .space-config 的 CODE_ROOTS_ABS（NOT workspace 根目录）
- openspec/ 是规范目录，NOT 代码目录
- 根据项目技术栈选择对应的语言感知 sub-agent
