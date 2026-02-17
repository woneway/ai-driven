# AI-Driven

> AI 自主开发框架。人只说需求，AI 全自动完成。

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Cursor IDE](https://img.shields.io/badge/IDE-Cursor-blue.svg)](https://cursor.sh/)

## 什么是 AI-Driven？

AI-Driven 是一个 AI 自主开发框架。核心理念：

> 人只说需求，AI 全自动完成。失败自己修，中间不需要人确认。

只需告诉 AI 你的需求（如"做一个用户登录功能"），AI 会自动完成需求分析、代码实现、测试、审查全部流程。

## 特性

- **/team 入口**：一句话需求，AI 全自动开发
- **OpenSpec 变更管理**：规范记录每个功能的设计和实现
- **13 个 Sub-Agents**：代码审查、架构设计、测试驱动开发等
- **43 个 Commands**：OpenSpec、开发、测试、运维等
- **49 个 Skills**：Django、Spring Boot、Go、Python、TypeScript 等
- **28 个 Rules**：各语言编码规范、安全规范
- **Workspace 隔离**：每个项目独立配置，按需同步

## 快速开始

### 前置要求

- [Cursor IDE](https://cursor.sh/)
- macOS / Linux

### 1. 初始化（只需一次）

在 ai-driven 根目录的 Cursor 中，告诉 AI：

```
帮我初始化全局配置
```

AI 会引导你配置路径和工作区。

### 2. 创建 Workspace

告诉 AI：

```
帮我创建一个 workspace
```

AI 会询问 workspace 名称和关联的项目。

### 3. 开始开发

1. 打开生成的 `.code-workspace` 文件
2. 告诉 AI 你的需求，例如：

```
做一个用户登录功能
```

AI 会自动完成全部开发工作。

## 目录结构

```
ai-driven/
├── common/                      # 全局共享资源
│   ├── global_cursor/          # 全局 Cursor 配置
│   │   ├── agents/             # 13 个 Sub-Agents
│   │   ├── commands/           # 43 个 Commands
│   │   ├── rules/              # 28 个 Rules
│   │   ├── skills/             # 49 个 Skills
│   │   └── hooks/              # Hooks
│   └── workspace-template/     # Workspace 模板
├── workspaces/                  # 各项目的工作空间
│   └── <workspace_name>/
│       ├── .workspace.env       # 工作空间配置
│       ├── .cursor/            # 项目专属配置
│       ├── openspec/           # 变更记录
│       └── <project_code>/     # 项目代码
└── .workspace.env               # 框架全局配置
```

## 核心概念

| 概念 | 说明 |
|------|------|
| **Workspace** | 项目工作空间，包含配置、代码、变更记录 |
| **/team** | 唯一开发入口，一句话触发全自动开发 |
| **OpenSpec** | 变更记录系统，规范每个功能的提案、设计、任务 |
| **global_cursor** | 全局能力目录，通过 symlink 挂载到 `~/.cursor/` |

## 常见操作

在 ai-driven 根目录的 Cursor 中，直接告诉 AI：

| 操作 | 怎么说 |
|------|--------|
| 创建 workspace | "帮我创建一个 workspace" |
| 同步配置 | "同步所有 workspace" |
| 验证框架 | "检查框架是否正常" |
| 分析资源 | "分析 workspace 资源" |
| 查看状态 | "查看 workspace 状态" |

## 全局能力

| 类型 | 数量 | 说明 |
|------|------|------|
| Sub-Agents | 13 | 代码审查、架构设计、TDD指导等 |
| Commands | 43 | OpenSpec命令、开发、测试、运维等 |
| Rules | 28 | 编码规范、安全规范、Git工作流等 |
| Skills | 49 | 框架特定、数据库、前端后端等 |

详细能力列表请查看 [common/global_cursor/README.md](common/global_cursor/README.md)

## 了解更多

- **框架能力** → 问 AI："ai-driven 提供哪些能力？"
- **使用帮助** → 问 AI："ai-driven 怎么使用？"
- **OpenSpec** → 问 AI："OpenSpec 是什么？"
- **/team 命令** → 问 AI："/team 命令是什么？"

## 依赖

- [Cursor IDE](https://cursor.sh/) - AI 代码编辑器
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) - 变更记录系统
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) - ECC 工具集

## 许可证

[MIT](LICENSE)

## 交流

如果你有问题或建议，欢迎提出 Issue 或 Pull Request。
