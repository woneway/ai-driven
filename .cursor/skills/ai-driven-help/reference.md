# AI-Driven Help 详细参考

本文件包含 ai-driven 框架的详细能力说明和操作指南。

## Sub-Agents（13个）

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

## Commands（43个）

### OpenSpec 命令
| 命令 | 用途 |
|------|------|
| `opsx-new` | 创建新变更 |
| `opsx-ff` | 快速创建变更 |
| `opsx-verify` | 验证变更 |
| `opsx-archive` | 归档变更 |
| `opsx-sync-specs` | 同步规范 |

### 开发命令
| 命令 | 用途 |
|------|------|
| `build-fix` | 修复构建错误 |
| `code-review` | 代码审查 |
| `refactor-clean` | 重构清理 |

### 测试命令
| 命令 | 用途 |
|------|------|
| `e2e` | 端到端测试 |
| `test-coverage` | 测试覆盖率 |
| `tdd` | TDD 开发 |

### 多任务命令
| 命令 | 用途 |
|------|------|
| `multi-execute` | 并行执行 |
| `multi-plan` | 并行计划 |
| `multi-workflow` | 并行工作流 |

### 运维命令
| 命令 | 用途 |
|------|------|
| `pm2` | PM2 管理 |
| `setup-pm` | PM2 部署 |

### 学习命令
| 命令 | 用途 |
|------|------|
| `learn` | 学习模式 |
| `evolve` | 进化模式 |
| `instinct-*` | 直觉系列 |

### 其他命令
| 命令 | 用途 |
|------|------|
| `plan` | 计划 |
| `verify` | 验证 |
| `sessions` | 会话管理 |
| `checkpoint` | 检查点 |

## Rules（28个）

### 通用 Rules
- common-coding-style
- common-git-workflow
- common-security
- common-testing

### TypeScript Rules
- typescript-coding-style
- typescript-patterns
- typescript-security

### Python Rules
- python-coding-style
- python-patterns
- python-security

### Go Rules
- golang-coding-style
- golang-patterns
- golang-security

## Skills（49个）

| 分类 | Skills |
|------|--------|
| **框架特定** | django-patterns, django-security, django-tdd, springboot-patterns, golang-patterns |
| **数据库** | postgres-patterns, clickhouse-io, jpa-patterns |
| **前端** | frontend-patterns |
| **后端** | backend-patterns |
| **安全** | security-review, security-scan |
| **测试** | python-testing, cpp-testing, tdd-workflow |
| **工具** | create-rule, create-skill, create-subagent, configure-ecc, update-cursor-settings |
| **OpenSpec** | openspec-new-change, openspec-verify-change, openspec-archive-change 等 |
| **持续学习** | continuous-learning, continuous-learning-v2, eval-harness |

## Hooks（9个）

| Hook | 用途 |
|------|------|
| `session-start` | 会话开始时触发 |
| `session-end` | 会话结束时触发 |
| `subagent-start` | Sub-Agent 启动时触发 |
| `subagent-stop` | Sub-Agent 停止时触发 |
| `audit-shell` | Shell 命令审计 |
| `audit-tool` | Tool 调用审计 |
| `notify` | 发送通知（钉钉/微信/短信） |

## OpenSpec 工作流

### 完整模式
1. `opsx-new` - 创建变更
2. `opsx-ff` - 快速创建 artifacts
3. 实现代码
4. `opsx-verify` - 验证实现
5. `opsx-archive` - 归档变更

### 轻量模式
1. `opsx-new` - 创建变更
2. 只写 proposal
3. 实现代码
4. `opsx-archive` - 归档变更

## Workspace 目录结构

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

## 路径配置

ai-driven 使用 `.workspace.env` 文件管理路径：

| 变量 | 说明 |
|------|------|
| WORKSPACE_ROOT | workspace 根目录 |
| PROJECT_PATH | 项目代码路径 |

读取配置：
```bash
grep 'PROJECT_PATH' .workspace.env | cut -d'=' -f2
```

## 全局 vs 项目资源

| 类型 | 位置 | 说明 |
|------|------|------|
| 全局 skills | `~/.cursor/skills/` | 所有 workspace 共享 |
| 项目 skills | `<workspace>/.cursor/skills/` | 当前项目专属 |
| 全局 commands | `~/.cursor/commands/` | 所有 workspace 共享 |
| 项目 commands | `<workspace>/.cursor/commands/` | 当前项目专属 |
