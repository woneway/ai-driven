---
name: ai-driven-help
description: AI-Driven 框架使用帮助与问答服务。回答关于 ai-driven 的问题，提供使用指南，解释概念和工作流程。
---

# AI-Driven Help

提供 ai-driven 框架的使用帮助和问答服务。

## 触发条件

当用户询问以下内容时使用此 skill：

- 什么是 ai-driven？
- ai-driven 提供哪些能力？
- ai-driven 怎么使用？
- 如何创建 workspace？
- /team 命令是什么？
- OpenSpec 是什么？
- common/global_cursor 是什么？
- 其他关于 ai-driven 框架的问题

## 什么是 ai-driven？

AI-Driven 是一个 AI 自主开发框架。核心理念：

> 人只说需求，AI 全自动完成。失败自己修，中间不需要人确认。

## ai-driven 提供了什么能力？

ai-driven 通过 **common/global_cursor/** 提供以下全局能力：

### 1. Sub-Agents（13个）

| Agent | 用途 |
|-------|------|
| `code-reviewer` | 代码审查 |
| `python-reviewer` | Python 代码审查 |
| `go-reviewer` | Go 代码审查 |
| `tdd-guide` | TDD 测试驱动开发指导 |
| `architect` | 架构设计 |
| `planner` | 计划制定 |
| `build-error-resolver` | 构建错误解决 |
| `go-build-resolver` | Go 构建错误解决 |
| `database-reviewer` | 数据库审查 |
| `security-reviewer` | 安全审查 |
| `e2e-runner` | 端到端测试 |
| `refactor-cleaner` | 重构清理 |
| `doc-updater` | 文档更新 |

### 2. Commands（43个）

| 分类 | 命令 | 用途 |
|------|------|------|
| **OpenSpec** | `opsx-new`, `opsx-ff`, `opsx-verify`, `opsx-archive` 等 | 变更管理工作流 |
| **开发** | `build-fix`, `code-review`, `refactor-clean` | 代码构建和审查 |
| **测试** | `e2e`, `test-coverage`, `tdd` | 测试相关 |
| **多任务** | `multi-execute`, `multi-plan`, `multi-workflow` | 并行执行多个任务 |
| **运维** | `pm2`, `setup-pm` | PM2 部署 |
| **学习** | `learn`, `evolve`, `instinct-*` | 持续学习 |
| **其他** | `plan`, `verify`, `sessions`, `checkpoint` | 计划、验证、会话管理 |

### 3. Rules（28个）

| 分类 | 内容 |
|------|------|
| **通用** | common-coding-style, common-git-workflow, common-security, common-testing 等 |
| **TypeScript** | typescript-coding-style, typescript-patterns, typescript-security 等 |
| **Python** | python-coding-style, python-patterns, python-security 等 |
| **Go** | golang-coding-style, golang-patterns, golang-security 等 |

### 4. Skills（49个）

| 分类 | Skills |
|------|--------|
| **框架特定** | django-patterns, django-security, django-tdd, springboot-patterns, golang-patterns 等 |
| **数据库** | postgres-patterns, clickhouse-io, jpa-patterns |
| **前端** | frontend-patterns |
| **后端** | backend-patterns |
| **安全** | security-review, security-scan |
| **测试** | python-testing, cpp-testing, tdd-workflow |
| **工具** | create-rule, create-skill, create-subagent, configure-ecc, update-cursor-settings |
| **OpenSpec** | openspec-new-change, openspec-verify-change 等 |
| **持续学习** | continuous-learning, continuous-learning-v2, eval-harness |

### 5. Hooks（9个）

| Hook | 用途 |
|------|------|
| `session-start` | 会话开始时触发 |
| `session-end` | 会话结束时触发 |
| `subagent-start` | Sub-Agent 启动时触发 |
| `subagent-stop` | Sub-Agent 停止时触发 |
| `audit-shell` | Shell 命令审计 |
| `audit-tool` | Tool 调用审计 |
| `notify` | 发送通知（钉钉/微信/短信） |

## 核心概念

### /team 命令

`/team` 是 ai-driven 的唯一自主开发入口。

用户只需说出需求（例如 `/team 做一个用户登录功能`），AI 会：
1. 分析需求类型和复杂度
2. 选择合适的开发模式（完整模式/轻量模式）
3. 通过 OpenSpec 记录变更
4. 调度 Sub-Agent 完成代码实现和审查
5. 验证并归档

详见 `.cursor/commands/team.md`

### OpenSpec

OpenSpec 是 ai-driven 的变更记录系统。

- 每个功能/修复都是一个"变更"（change）
- 变更包含：proposal（提案）、design（设计）、tasks（任务）、specs（规范）
- 变更记录在 `openspec/changes/<name>/` 目录下
- 完整模式：`opsx-new` → `opsx-ff` → 实现 → `opsx-verify` → `opsx-archive`
- 轻量模式：`opsx-new` → 只写 proposal → 实现 → `opsx-archive`

### Workspace

Workspace 是 ai-driven 的项目工作空间。

每个 workspace 包含：
- `.workspace.env` - 工作空间配置
- `.cursor/` - Cursor 配置（rules、commands、skills、agents）
- `openspec/` - 变更记录
- 项目代码目录

### common/global_cursor

`common/global_cursor/` 是 ai-driven 提供的全局能力目录。

- 通过 symlink 挂载到 `~/.cursor/`
- 所有 workspace 共享这些能力
- 包含 rules、skills、agents、commands、hooks

## 常见操作

### 如何创建新 workspace？

```
在 ai-driven 根目录的 Cursor 中说："创建一个 workspace"
AI 会通过 AskQuestion 询问：
1. Workspace 名称
2. 是否关联已有代码
```

### workspace 的目录结构？

```
my_workspace/
├── .workspace.env            # workspace 配置
├── .cursor/               # Cursor 配置
│   ├── rules/             # 项目规则
│   ├── commands/          # 项目命令
│   ├── skills/            # 项目专属 skills
│   └── agents/            # 项目专属 agents
├── openspec/              # 变更记录
└── <code_projects>/      # 代码目录
```

### 路径配置？

ai-driven 使用 `.workspace.env` 文件管理路径：

| 变量 | 说明 |
|------|------|
| WORKSPACE_ROOT | workspace 根目录 |
| PROJECT_PATH | 项目代码路径 |

读取配置：
```bash
grep 'PROJECT_PATH' .workspace.env | cut -d'=' -f2
```

### 全局 vs 项目资源？

| 类型 | 位置 | 说明 |
|------|------|------|
| 全局 skills | `~/.cursor/skills/` | 所有 workspace 共享 |
| 项目 skills | `<workspace>/.cursor/skills/` | 当前项目专属 |
| 全局 commands | `~/.cursor/commands/` | 所有 workspace 共享 |
| 项目 commands | `<workspace>/.cursor/commands/` | 当前项目专属 |

### 如何同步 workspace 配置？

```
在 ai-driven 根目录的 Cursor 中说："同步所有 workspace"
```

### 如何验证框架健康？

```
在 ai-driven 根目录的 Cursor 中说："检查框架是否正常"
```

## 不知道答案时

如果用户的问题你不确定答案，可以：

1. 读取 ai-driven 相关文件获取信息
2. 建议用户查看 README.md
3. 直接在对话中询问 AI 获取帮助

## 交互原则

### AskQuestion 方式

当需要收集用户参数时，使用 AskQuestion：

```python
AskQuestion 询问"<问题>"，选项：
- "<id>": "<选项文字>"
```
