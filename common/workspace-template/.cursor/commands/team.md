---
description: AI 自主开发入口。使用 OpenSpec 管理变更，通过调度 Agent 完成开发。
---

# /team

人只说需求，AI 全自动完成。中间不需人确认。

**关键动作：**
- OpenSpec 命令（如 /opsx-ff）：输入命令触发 Cursor Command
- Agent（如 tdd-guide）：用 Task tool 调用 subagent

---

## OpenSpec 规范

OpenSpec 是变更管理框架，每个变更是一个独立工作单元。

### Change 构成

| 工件 | 是什么 |
|------|--------|
| proposal.md | 为什么要做？（动机、目标、价值） |
| design.md | 怎么实现？（技术选型、决策、方案） |
| specs/ | 做什么？（WHEN/THEN/AND 格式，可测试的需求） |
| tasks.md | 做到哪步？（可执行的任务清单） |

### 工作流程

```
Explore → New → Proposal → Specs → Design → Tasks → Apply → Archive
```

| 阶段 | 做什么 | 产出 |
|------|--------|------|
| Explore | 纯粹思考，不写代码 | 清晰的问题定义 |
| New | 创建 change 目录 | openspec/changes/&lt;name&gt;/ |
| Proposal | 写为什么要做 | proposal.md |
| Specs | 写可测试的需求 | specs/*.md |
| Design | 写技术方案 | design.md |
| Tasks | 拆任务清单 | tasks.md |
| Apply | 逐个完成任务 | 实现代码 |
| Archive | 移到历史记录 | - |

### 常用命令

**看到这些命令时，调用对应的 command 来执行（输入命令触发，不是自己去做）。**

| 命令 | 什么时候用 |
|------|------------|
| /opsx-explore | 想不清楚问题时，调用进入探索模式 |
| /opsx-new &lt;name&gt; | 开始一个变更，调用逐步创建 |
| /opsx-ff &lt;name&gt; | 快速创建所有 artifacts，调用自动创建 |
| /opsx-continue &lt;name&gt; | 继续未完成的变更，调用继续 |
| /opsx-apply &lt;name&gt; | 开始实现，调用执行任务 |
| /opsx-verify &lt;name&gt; | 验证实现是否匹配设计，调用验证 |
| /opsx-archive &lt;name&gt; | 完成后归档，调用归档 |

---

## 执行流程

### 1. 理解需求

先问自己：

- 核心功能是什么？用户期望什么效果？
- 涉及哪些模块？数据怎么流转？
- 边界情况有哪些？错了怎么反馈？
- 现有代码结构是怎样的？

**需求不清晰时主动提问。**

---

### 2. 创建变更

先问自己：

- 这个变更大小？复杂还是简单？
- 需要完整的 artifacts 还是只写 proposal？
- 用 /opsx-ff 还是 /opsx-new？

| 场景 | 用什么命令 |
|------|------------|
| 新功能、复杂改动 | 调用 /opsx-ff &lt;name&gt; |
| 小改动、简单 bug | 调用 /opsx-new &lt;name&gt; |

---

### 3. 设计方案

先问自己：

- 这个功能怎么实现？技术选型是什么？
- 为什么要这样选？有没有更好的方式？
- 改动会影响什么？有没有副作用？
- 需要拆成哪些任务？

**用 proposal → specs → design → tasks 记录决策。**

---

### 4. 实现

先问自己：

- 这个任务谁来干？自己干还是派给 Agent？
- 有什么现成的 Agent/Skill 能用？
- 怎么验证做对了？

**能调用 Agent 就不自己干。**

---

### 5. 测试和验收

先问自己：

- 这个改动会影响什么？需要测什么？
- 有没有现成的 Agent/Skill 可以用？
- 用户真正能用上吗？

### 用什么取决于具体情况

**用 Task tool 调用对应的 subagent 来执行。**

| 场景 | 用什么 |
|------|--------|
| 后端逻辑改动 | 调用 **tdd-guide** subagent |
| 前端页面改动 | 调用 **e2e-runner** subagent |
| 前后端交互 | 调用 **tdd-guide** + **e2e-runner** subagent |
| 不确定用什么 | 用 /find-skills 搜索 Skill |
| 验收全部 | 调用 **verification-loop** subagent |
| 安全相关 | 调用 **security-reviewer** subagent |
| 代码质量 | 调用 **code-reviewer** subagent |

### 验收标准

- 构建通过了吗？
- 测试通过了吗？
- 页面能打开、交互正常吗？
- API 能调通吗？
- 安全有问题吗？
- 符合设计意图吗？

**边实现边验收，不要写完再测。**

---

## 问题处理

先问自己：

- 这个问题的根本原因是什么？
- 有没有现成的 Agent 能帮忙？
- 修这个问题会引入新问题吗？

常见情况：

- 编译/测试失败 → 修复错误，重新验证
- 页面不对 → 启动服务，看实际效果
- 联调不通 → 前后端都启动，调接口确认
- 改了又坏 → 检查是否偏离设计

---

## 关键原则

- **OpenSpec 是规范** → 不是束缚，是记录决策的方式
- **每个阶段有产出** → proposal/design/specs/tasks 都是给 AI 看的
- **Agent 是工具** → 不会用什么就用 Task tool 调用 subagent，用错了就换
- **验收是必须的** → 代码写完不是完，用户能用才是完
- **主动思考** → 不要机械执行，多问自己"这样够了吗"

---

## 备注

- 代码目标：`.workspace.env` 的 `PROJECT_PATH`
- 遇到问题先想有没有合适的 Agent/Skill
