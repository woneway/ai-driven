---
description: ai-driven 框架建设团队。用 OpenSpec 管理框架本身的 Skill、Rule、Agent、Command 开发，以及规范制定。
---

# /driven_team

ai-driven 框架的"建设团队"。当用户要建设 ai-driven 框架本身（而非业务项目）时使用。

## 核心约束

- 实现 MUST 通过 Task tool 委派给 Sub-Agent 执行
- 你（主 Agent）是编排者，NOT 执行者
- 所有变更必须走 OpenSpec 流程
- 你的职责：需求分类 → OpenSpec 记录 → 调用 Task tool 委派 → 验证归档

## 触发条件

在以下情况使用 /driven_team：

| 场景 | 示例 |
|------|------|
| 创建新 Skill | "创建一个 iOS 开发 Skill" |
| 创建新 Rule | "添加 Python 编码规范" |
| 创建新 Agent | "做一个代码审查 Agent" |
| 创建新 Command | "添加一个部署命令" |
| 制定规范 | "制定 API 规范" |
| 优化现有资源 | "优化现有的 Django Skill" |
| 框架升级 | "升级 OpenSpec 版本" |

## 执行流程

### 步骤 0：环境准备

1. 确认当前在 ai-driven 根目录（有 `common/`、`workspaces/` 目录）
2. 确认 OpenSpec 命令可用（检查 `~/.cursor/commands/opsx-*.md` 或 global_cursor 中的 opsx 命令）
3. 确定变更产出的目标目录（根据变更类型）：
   - Skill → `common/global_cursor/skills/<name>/`
   - Rule → `common/global_cursor/rules/<name>.md`
   - Agent → `common/global_cursor/agents/<name>.md`
   - Command → `common/global_cursor/commands/<name>.md`

### 步骤 1：需求分类

分析用户需求，判断变更类型和复杂度：

| 类型 | 判断依据 | OpenSpec 模式 |
|------|---------|--------------|
| 新 Skill/Rule/Agent/Command | 全新资源 | 完整模式 |
| 复杂规范制定 | 涉及架构决策、多方权衡 | 完整模式 |
| 优化现有资源 | 改进已有资源 | 轻量模式 |
| 小改动 | 文档修正、配置调整 | 直接 Git，不走 OpenSpec |

### 步骤 2：OpenSpec 记录

所有变更走 OpenSpec，确保框架演进有完整的变更历史。

#### 完整模式

1. 执行 `/opsx-new` 命令 — 创建变更目录
2. 如果涉及架构决策，调用 Task tool（architect）评估
3. 执行 `/opsx-ff` 命令 — 生成 proposal.md、specs/、design.md、tasks.md

#### 轻量模式

1. 执行 `/opsx-new` 命令 — 创建变更目录
2. 只写 proposal.md（1-2 句话说明改了什么）
3. 直接进入实现

### 步骤 3：实现

根据变更类型，调用合适的 Sub-Agent：

#### 创建 Skill

调用 Task tool（可使用 create-skill skill 或直接委派）：

```
Task tool 调用:
  subagent_type: generalPurpose
  description: "创建 Skill: <name>"
  prompt: |
    任务：创建一个新的 Skill
    Skill 名称：<name>
    用途：<描述>
    目标目录：common/global_cursor/skills/<name>/
    
    请按照 Skill 标准格式创建：
    - SKILL.md（必需）：主文件，包含 name、description、Instructions、Examples
    - reference.md（可选）：详细参考
    - scripts/（可选）：辅助脚本
    
    参考现有 Skill 格式：common/global_cursor/skills/django-patterns/SKILL.md
```

#### 创建 Rule

调用 Task tool：

```
Task tool 调用:
  subagent_type: generalPurpose
  description: "创建 Rule: <name>"
  prompt: |
    任务：创建一个新的 Cursor Rule
    Rule 名称：<name>
    用途：<描述>
    目标目录：common/global_cursor/rules/<name>.md
    
    请按照 Rule 标准格式创建：
    - name: 规则名称
    - description: 规则描述
    - 规则内容...
    
    参考现有 Rule 格式：common/global_cursor/rules/coding-standards.md
```

#### 创建 Agent

调用 Task tool：

```
Task tool 调用:
  subagent_type: generalPurpose
  description: "创建 Agent: <name>"
  prompt: |
    任务：创建一个新的 Sub-Agent
    Agent 名称：<name>
    用途：<描述>
    目标目录：common/global_cursor/agents/<name>.md
    
    请按照 Sub-Agent 标准格式创建：
    - description: Agent 描述
    - instructions: Agent 指令
    - tools: 可用工具列表
    
    参考现有 Agent 格式：common/global_cursor/agents/code-reviewer.md
```

#### 创建 Command

调用 Task tool：

```
Task tool 调用:
  subagent_type: generalPurpose
  description: "创建 Command: <name>"
  prompt: |
    任务：创建一个新的 Command
    Command 名称：<name>
    用途：<描述>
    目标目录：common/global_cursor/commands/<name>.md
    
    请按照 Command 标准格式创建：
    - name: 命令名称
    - description: 命令描述
    - trigger: 触发方式
    - 内容...
    
    参考现有 Command 格式：common/global_cursor/commands/opsx-new.md
```

### 步骤 4：验证与归档

#### 完整模式

1. 执行 `/opsx-verify` 命令
2. 如有问题 → 回到步骤 3 修复
3. 执行 `/opsx-archive` 命令
4. 可选：执行 `/opsx-sync` 将 specs 同步到主规格库

#### 轻量模式

1. 执行 `/opsx-archive` 命令

## 变更类型速查

| 需求关键词 | 变更类型 | 产出目录 |
|------------|----------|----------|
| "创建 Skill" | skill | `common/global_cursor/skills/<name>/` |
| "创建 Rule" | rule | `common/global_cursor/rules/<name>.md` |
| "创建 Agent" | agent | `common/global_cursor/agents/<name>.md` |
| "创建 Command" | command | `common/global_cursor/commands/<name>.md` |
| "添加规范" | spec | `openspec/specs/<category>/` |
| "优化" | improvement | 原资源目录 |

## 错误恢复

- OpenSpec 命令不可用: 提示用户检查 global_cursor 配置
- openspec/ 目录不存在: 执行 `openspec init --tools none`
- 构建失败: 调用对应语言的 build-error-resolver
- 验证发现问题: 回到步骤 3 修复

## 备注

- /driven_team 是 ai-driven 框架专属命令，放在 `ai-driven/.cursor/commands/`
- OpenSpec 命令是全局的，通过 global_cursor 共享
- 产出资源后，可能需要运行 sync-space.sh 同步到各 workspace
