---
description: AI 自主开发入口。接收需求后智能路由：判断类型和复杂度，选择 OpenSpec 模式（轻量/完整），调度全局 Sub-Agent 完成开发。
---

# /team

人只说需求，AI 全自动完成。中间不需要人确认，失败自己修。

## 核心约束

- 实现、审查、架构、规划等工作 MUST 通过 Task tool 委派给 Sub-Agent 执行
- 你（主 Agent）是编排者，NOT 执行者。你 MUST NOT 自己写业务代码、自己做代码审查
- 你的职责：需求分类 → OpenSpec 记录 → 调用 Task tool 委派 → 验证归档
- 每个需要 Sub-Agent 的步骤，MUST 实际调用 Task tool，NOT 只是提到它

## 执行流程

收到需求后按以下步骤执行：

### 步骤 0：环境准备

0. 读取 .space-config 获取 SPACE_NAME 和 CODE_ROOTS_ABS
1. 如果 CODE_ROOTS_ABS 包含多个路径（逗号分隔），解析为列表备用
2. 检查全局命令 /opsx-new 是否可用（即 ~/.cursor/commands/opsx-new.md 存在）。不可用则提示用户运行 setup-global.sh

### 步骤 1：需求分类

分析用户需求，判断类型和复杂度，决定 OpenSpec 模式：

| 类型 | 复杂度判断 | OpenSpec 模式 |
|------|-----------|--------------|
| 新功能开发 | 新模块、新页面、新 API | 完整模式 |
| 复杂 Bug | 跨模块、架构问题、根因不明 | 完整模式 |
| 重构 | 跨模块、架构级调整 | 完整模式 |
| 仅规划 | 用户明确只要方案不要实现（"帮我规划..."、"给个方案..."、"分析一下怎么做..."、"不用实现"） | 完整模式（只到规划） |
| 简单 Bug | 单文件、根因明确 | 轻量模式 |
| 小改动 | 改样式、改文案、加按钮、改配置 | 轻量模式 |

如果有多个 CODE_ROOTS，根据需求内容判断涉及哪些目录，后续 Sub-Agent prompt 的 Target Dir 只传入相关目录（而非全部）。

### 步骤 2：OpenSpec 记录

**所有变更都走 OpenSpec**，确保 AI 对项目有完整的变更历史。

#### 完整模式

1. 执行 /opsx-new 命令（全局命令）— 创建变更目录
2. 如果涉及架构决策，MUST 调用 Task tool：

```
Task tool 调用:
  subagent_type: architect
  description: "架构评估: <简述>"
  prompt: |
    HANDOFF: /team -> architect
    Context: <需求摘要>
    Target Dir: <CODE_ROOTS_ABS>
    Task: 评估架构方案，输出决策记录
```

3. 如果需求复杂，MUST 调用 Task tool：

```
Task tool 调用:
  subagent_type: planner
  description: "需求规划: <简述>"
  prompt: |
    HANDOFF: /team -> planner
    Context: <需求摘要>
    Target Dir: <CODE_ROOTS_ABS>
    Task: 制定实施计划，输出任务拆分
```

4. 执行 /opsx-ff 命令（全局命令）— 生成 proposal.md、specs/、design.md、tasks.md

#### 轻量模式

1. 执行 /opsx-new 命令（全局命令）— 创建变更目录
2. 在变更目录中只写 proposal.md（1-2 句话说明改了什么、为什么改）
3. 跳过 opsx-ff（不生成 specs/design/tasks）

### 步骤 3：实现

根据需求类型调度对应的 Sub-Agent。

**关键规则：所有代码实现和审查 MUST 通过 Task tool 委派，NEVER 自己直接写代码。**

#### 新功能 / 复杂 Bug / 重构

1. 读取 openspec/changes/<name>/tasks.md 和 design.md

2. MUST 调用 Task tool 实现代码：

```
Task tool 调用:
  subagent_type: tdd-guide
  description: "TDD 实现: <简述>"
  prompt: |
    HANDOFF: /team -> tdd-guide
    Context: <proposal.md 内容>
    Design: <design.md 全文>
    Tasks: <tasks.md 全文>
    Target Dir: <CODE_ROOTS_ABS>
    Files: <需要修改的文件列表>
```

3. MUST 调用 Task tool 审查代码：

```
Task tool 调用:
  subagent_type: code-reviewer
  description: "代码审查: <简述>"
  prompt: |
    HANDOFF: /team -> code-reviewer
    Context: <需求摘要>
    Design: <design.md 关键决策>
    Files: <变更文件列表>
```

4. 语言感知审查 — MUST 根据项目技术栈调用对应 Task tool：

```
Go 项目:
  Task tool 调用:
    subagent_type: go-reviewer
    description: "Go 审查: <简述>"
    prompt: |
      HANDOFF: /team -> go-reviewer
      Files: <变更的 .go 文件列表>

Python 项目:
  Task tool 调用:
    subagent_type: python-reviewer
    description: "Python 审查: <简述>"
    prompt: |
      HANDOFF: /team -> python-reviewer
      Files: <变更的 .py 文件列表>
```

5. 如果涉及安全相关代码，MUST 调用 Task tool：

```
Task tool 调用:
  subagent_type: security-reviewer
  description: "安全审查: <简述>"
  prompt: |
    HANDOFF: /team -> security-reviewer
    Files: <涉及安全的文件列表>
```

6. 如果涉及数据库操作，MUST 调用 Task tool：

```
Task tool 调用:
  subagent_type: database-reviewer
  description: "数据库审查: <简述>"
  prompt: |
    HANDOFF: /team -> database-reviewer
    Files: <涉及数据库的文件列表>
```

#### 简单 Bug

1. 在 CODE_ROOTS_ABS 中定位问题代码
2. MUST 调用 Task tool 修复（TDD 方式）：

```
Task tool 调用:
  subagent_type: tdd-guide
  description: "Bug 修复: <简述>"
  prompt: |
    HANDOFF: /team -> tdd-guide
    Context: <bug 描述>
    Target Dir: <CODE_ROOTS_ABS>
    Task: 先写失败测试复现 bug，再修复使测试通过，最后运行全部测试确保无回归
    Files: <相关文件>
```

3. MUST 调用 Task tool 审查修复：

```
Task tool 调用:
  subagent_type: code-reviewer
  description: "审查 Bug 修复: <简述>"
  prompt: |
    HANDOFF: /team -> code-reviewer
    Context: <bug 描述和修复方案>
    Files: <变更文件列表>
```

#### 小改动

1. 在 CODE_ROOTS_ABS 目录中定位相关代码
2. 直接修改代码（小改动允许主 Agent 直接执行）
3. 运行测试确保不破坏已有功能
4. MUST 调用 Task tool 审查修改：

```
Task tool 调用:
  subagent_type: code-reviewer
  description: "审查小改动: <简述>"
  prompt: |
    HANDOFF: /team -> code-reviewer
    Context: <改动描述>
    Files: <变更文件列表>
```

#### 重构（额外步骤）

- 实现前 MUST 调用 Task tool 扫描死代码：

```
Task tool 调用:
  subagent_type: refactor-cleaner
  description: "死代码扫描: <简述>"
  prompt: |
    HANDOFF: /team -> refactor-cleaner
    Target Dir: <CODE_ROOTS_ABS>
    Task: 扫描死代码和重复代码，输出清理建议
```

- 每个原子重构步骤后运行测试验证行为不变
- 不在重构中混入功能变更

#### 仅规划

- 完成步骤 2（完整模式）后停止
- 向用户展示规划摘要（proposal + design + tasks）
- 不进入实现阶段

### 步骤 4：验证与归档

#### 完整模式

1. 执行 /opsx-verify 命令（全局命令）
2. 如果项目有 E2E 测试配置，MUST 调用 Task tool：

```
Task tool 调用:
  subagent_type: e2e-runner
  description: "E2E 测试: <简述>"
  prompt: |
    HANDOFF: /team -> e2e-runner
    Target Dir: <CODE_ROOTS_ABS>
    Task: 运行端到端测试，报告结果
```

3. 如有问题 → 回到步骤 3 修复 → 重新验证（最多 3 轮，超过报告用户）
4. 执行 /opsx-archive 命令（全局命令）
5. MUST 调用 Task tool 更新文档：

```
Task tool 调用:
  subagent_type: doc-updater
  description: "文档更新: <简述>"
  prompt: |
    HANDOFF: /team -> doc-updater
    Target Dir: <CODE_ROOTS_ABS>
    Task: 更新项目文档，反映本次变更
    Files: <变更文件列表>
```

#### 轻量模式

1. 运行测试确认通过
2. 执行 /opsx-archive 命令（全局命令）

## Sub-Agent 速查表

| 场景 | subagent_type | 何时调用 |
|------|---------------|---------|
| 新功能实现 | tdd-guide | MUST: 所有代码实现 |
| 代码审查 | code-reviewer | MUST: 每次代码变更后 |
| 架构设计 | architect | MUST: 涉及架构决策时 |
| 复杂规划 | planner | MUST: 需求复杂需拆分时 |
| 构建失败（TS/通用） | build-error-resolver | MUST: 构建失败时 |
| 构建失败（Go） | go-build-resolver | MUST: Go 构建失败时 |
| Go 代码审查 | go-reviewer | MUST: Go 项目代码变更后 |
| Python 代码审查 | python-reviewer | MUST: Python 项目代码变更后 |
| 数据库相关 | database-reviewer | MUST: 涉及数据库操作时 |
| 安全审查 | security-reviewer | MUST: 涉及安全代码时 |
| E2E 测试 | e2e-runner | MUST: 有 E2E 配置时 |
| 文档更新 | doc-updater | MUST: 完整模式归档前 |
| 死代码清理 | refactor-cleaner | MUST: 重构前 |
| 代码库探索 | explore | 需要快速了解代码结构时 |
| 通用研究 | generalPurpose | 需要多步骤调查或复杂问题分析时 |

以上为常用 Sub-Agent，不是完整列表。以 Cursor 平台实际支持的 subagent_type 为准，按任务需要选择最合适的类型。

## 错误恢复

- 全局 opsx 命令不可用: 提示用户运行 setup-global.sh（在 ai-driven 根目录）
- openspec/ 目录不存在: openspec init --tools none（只创建项目目录）
- 构建失败: MUST 调用 Task tool (subagent_type: build-error-resolver)
- Go 构建失败: MUST 调用 Task tool (subagent_type: go-build-resolver)
- 测试失败: 修复后重跑，NOT 跳过
- verify 发现问题: 回到步骤 3 修复，最多 3 轮
- 死代码/重复代码: MUST 调用 Task tool (subagent_type: refactor-cleaner)

## 备注

- OpenSpec 命令（/opsx-*）已安装在全局 ~/.cursor/commands/，所有 workspace 共享
- OpenSpec 命令格式为 /opsx-<id>（短横线，非冒号）
- 代码目标目录见 .space-config 的 CODE_ROOTS_ABS（NOT workspace 根目录）
- openspec/ 是规范目录，NOT 代码目录
- 根据项目技术栈选择对应的语言感知 sub-agent
- 调用 Task tool 时 MUST 使用实际的 Task tool 函数调用，NOT 只是在文本中提到它
