# `/dev` 命令 - AI 驱动开发入口

## 概述

`/dev` 是唯一的开发命令。人类只需表达需求，AI 自动完成全流程。

**设计理念**：先设计，再实现（SDD + TDD）

## 用法

```
/dev <需求描述>
```

### 支持的需求类型

| 类型 | 示例 | 推荐流程 |
|------|------|---------|
| 新功能 | `/dev 做一个锦标赛盲注递增功能` | SDD → TDD |
| Bug 修复 | `/dev 新建档案后数据没清空` | TDD（先写测试复现） |
| 优化 | `/dev 优化排行榜查询性能` | SDD → TDD |
| 调研 | `/dev 调研 WebSocket 连接管理` | 直接执行 |
| 技术债 | `/dev 清理 SwiftLint 警告` | 直接执行 |

## 执行流程（SDD + TDD）

```
用户需求
    ↓
SDD: 需求分析 + 技术设计（必须）
    ↓
ECC planner 制定计划
    ↓
ECC tdd-guide TDD 实现（复杂功能）
    ↓
ECC code-reviewer 代码审查
    ↓
ECC e2e-runner E2E 测试
    ↓
质量门禁检查
    ↓
记忆更新
```

## ECC 能力复用

ai-driven 复用 everything-claude-code 的成熟能力：

| 能力 | ECC 命令/Agent | 用途 |
|------|---------------|------|
| 需求分析 | `/plan` | 理解需求，制定计划 |
| 设计阶段 | `/sdd` | 技术设计，方案选型 |
| TDD 实现 | `/tdd` | 测试驱动开发 |
| 代码审查 | `/code-review` | 质量审查 |
| E2E 测试 | `/e2e` | 端到端测试 |
| 构建修复 | `/build-fix` | 修复构建错误 |

详见全局配置：`~/.cursor/commands/`, `~/.cursor/agents/`

## 子 Agent 调度（直接复用 ECC）

### Agent 来源

所有子 Agents 直接来自全局 ECC 配置：

| Agent | 配置文件 | 职责 |
|-------|----------|------|
| planner | `~/.cursor/agents/planner.md` | 需求分析、计划制定 |
| tdd-guide | `~/.cursor/agents/tdd-guide.md` | 测试驱动开发 |
| code-reviewer | `~/.cursor/agents/code-reviewer.md` | 代码审查 |
| e2e-runner | `~/.cursor/agents/e2e-runner.md` | E2E 测试 |
| architect | `~/.cursor/agents/architect.md` | 架构设计 |
| security-reviewer | `~/.cursor/agents/security-reviewer.md` | 安全审查 |
| refactor-cleaner | `~/.cursor/agents/refactor-cleaner.md` | 死代码清理 |
| build-error-resolver | `~/.cursor/agents/build-error-resolver.md` | 构建错误修复 |

### ai-driven 特有

| Agent | 配置文件 | 职责 |
|-------|----------|------|
| researcher | `common/agents/researcher.md` | 技术调研 |

### Task tool 调用

```python
Task(
    description="[Agent] 执行: [任务]",
    subagent_type="generalPurpose",
    prompt="""
        # Agent 定义（来自全局 ECC）
        读取 ~/.cursor/agents/[agent].md

        # 项目上下文
        读取 .space-config

        # 代码仓库
        - 代码根目录: [从 CODE_ROOTS 获取]

        # 任务
        [具体任务描述]
    """
)
```

## 变更结构

```
.changes/{date}_{slug}/
├── proposal.md    # 为什么做（需求分析）
├── design.md      # 技术设计（SDD 输出）
└── tasks.md       # 实施任务（TDD 实现）
```

## 质量门禁（AI 自我检查）

- [ ] proposal.md 完整（目标、约束、成功标准）
- [ ] design.md 完整（方案选型、架构图、API 设计）
- [ ] TDD 测试存在（先写测试）
- [ ] 测试通过（80%+ 覆盖率）
- [ ] 代码审查通过（ECC code-reviewer）
- [ ] E2E 测试通过（关键路径）
- [ ] linter 通过

## 记忆更新

变更完成后自动更新：

- `.roles/lessons.md` - 经验教训
- `.roles/decisions.md` - 架构决策
- `.roles/prefs.md` - 代码偏好
- `.roles/feedback.md` - 反馈给 ai-driven

## SDD 工作流（新增）

详见 `/sdd` 命令：

```
SDD = Solution-Driven Design
先设计，再实现
```

## TDD 工作流（复用 ECC）

详见 `/tdd` 命令：

```
TDD = Test-Driven Development
先写测试，再实现
```
