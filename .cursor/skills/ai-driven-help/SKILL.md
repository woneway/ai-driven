---
name: ai-driven-help
description: AI-Driven 框架使用帮助与问答服务。回答关于 ai-driven 的问题，提供使用指南，解释概念和工作流程。
---

# AI-Driven Help

提供 ai-driven 框架的使用帮助和问答服务。

## 触发条件

当用户询问以下内容时使用此 skill：

- 什么是 ai-driven？
- ai-driven 怎么使用？
- 如何创建 workspace？
- /team 命令是什么？
- OpenSpec 是什么？
- 如何配置路径？
- 如何同步配置？
- 其他关于 ai-driven 框架的问题

## 问答内容

### 什么是 ai-driven？

AI-Driven 是一个 AI 自主开发框架。核心理念：

> 人只说需求，AI 全自动完成。失败自己修，中间不需要人确认。

### /team 是什么？

`/team` 是 ai-driven 的唯一自主开发入口。

用户只需说出需求（例如 `/team 做一个用户登录功能`），AI 会：
1. 分析需求类型和复杂度
2. 选择合适的开发模式（完整模式/轻量模式）
3. 通过 OpenSpec 记录变更
4. 调度 Sub-Agent 完成代码实现和审查
5. 验证并归档

详见 `.cursor/commands/team.md`

### OpenSpec 是什么？

OpenSpec 是 ai-driven 的变更记录系统。

- 每个功能/修复都是一个"变更"（change）
- 变更包含：proposal（提案）、design（设计）、tasks（任务）、specs（规范）
- 变更记录在 `openspec/changes/<name>/` 目录下
- 完整模式：`opsx-new` → `opsx-ff` → 实现 → `opsx-verify` → `opsx-archive`
- 轻量模式：`opsx-new` → 只写 proposal → 实现 → `opsx-archive`

### 如何创建新 workspace？

```bash
# 在 ai-driven 根目录运行
bash .cursor/skills/ai-driven-management/scripts/init-space.sh <workspace_name> [code_path]
```

示例：
```bash
# 创建 workspace（项目代码自动放在 projects/ 目录下）
bash scripts/init-space.sh my_project
```

### workspace 的目录结构？

```
my_workspace/
├── .env                    # 配置文件（从 .env.example 生成）
├── .env                    # workspace 配置
├── .cursor/               # Cursor 配置
│   ├── rules/             # 规则
│   ├── commands/          # 命令
│   ├── skills/            # 项目专属 skills
│   └── agents/            # 项目专属 agents
├── openspec/              # 变更记录
└── <code_projects>/      # 代码目录（可选）
```

### 路径配置？

ai-driven 使用 `.env` 文件管理路径：

| 变量 | 说明 |
|------|------|
| WORKSPACE_ROOT | workspace 根目录 |
| PROJECT_PATH | 项目代码路径 |
| GLOBAL_CURSOR_PATH | 全局 Cursor 配置路径 |

读取配置：
```bash
grep 'PROJECT_PATH' .env | cut -d'=' -f2
```

### 全局 vs 项目资源？

| 类型 | 位置 | 说明 |
|------|------|------|
| 全局 skills | `~/.cursor/skills/` | 所有 workspace 共享 |
| 项目 skills | `<workspace>/.cursor/skills/` | 当前项目专属 |
| 全局 commands | `~/.cursor/commands/` | 所有 workspace 共享 |
| 项目 commands | `<workspace>/.cursor/commands/` | 当前项目专属 |

### 如何同步所有 workspace？

```bash
bash .cursor/skills/ai-driven-management/scripts/sync-space.sh
```

这会同步：
- 模板更新（ai-driven.mdc、team.md 等）
- 全局 rules/skills/commands

### 如何验证框架健康？

```bash
bash .cursor/skills/ai-driven-management/scripts/verify.sh
```

### /ai-driven 命令？

在 ai-driven 根目录的 Cursor 中使用：

| 命令 | 说明 |
|------|------|
| `/ai-driven:setup` | 全局初始化 |
| `/ai-driven:init` | 创建新 workspace |
| `/ai-driven:sync` | 同步所有 workspace |
| `/ai-driven:verify` | 验证框架健康 |
| `/ai-driven:analyze` | 分析 workspace 资源 |
| `/ai-driven:upgrade` | 升级框架 |
| `/ai-driven:status` | 查看状态 |

## 不知道答案时

如果用户的问题你不确定答案，可以：

1. 读取 ai-driven 相关文件获取信息
2. 建议用户查看 README.md
3. 引导用户使用 `/ai-driven` 命令获取帮助
