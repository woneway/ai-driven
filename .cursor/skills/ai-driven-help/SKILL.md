---
name: ai-driven-help
description: AI-Driven 框架使用帮助与问答服务。回答关于 ai-driven 的问题，提供使用指南，解释概念和工作流程。
---

# AI-Driven Help

提供 ai-driven 框架的使用帮助和问答服务。

## 触发条件

当用户询问以下内容时使用：

- 什么是 ai-driven？
- ai-driven 提供哪些能力？
- /team 命令是什么？
- OpenSpec 是什么？
- Workspace 是什么？
- common/global_cursor 是什么？
- 如何创建/同步 workspace？
- 其他关于 ai-driven 框架的问题

## 核心概念

### 什么是 ai-driven？

AI-Driven 是一个 AI 自主开发框架。核心理念：

> 人只说需求，AI 全自动完成。失败自己修，中间不需要人确认。

### /team 命令

`/team` 是 ai-driven 的唯一自主开发入口。

用户说出需求（如 `/team 做一个用户登录功能`），AI 会：
1. 分析需求类型和复杂度
2. 选择合适的开发模式
3. 通过 OpenSpec 记录变更
4. 调度 Sub-Agent 完成代码实现和审查
5. 验证并归档

详见 `.cursor/commands/team.md`

### OpenSpec

OpenSpec 是 ai-driven 的变更记录系统。

- 每个功能/修复都是一个"变更"（change）
- 变更包含：proposal、design、tasks、specs
- 变更记录在 `openspec/changes/<name>/` 目录下

### Workspace

Workspace 是 ai-driven 的项目工作空间。

每个 workspace 包含：
- `.workspace.env` - 工作空间配置
- `.cursor/` - Cursor 配置
- `openspec/` - 变更记录
- 项目代码目录

### common/global_cursor

`common/global_cursor/` 是 ai-driven 提供的全局能力目录。

- 通过 symlink 挂载到 `~/.cursor/`
- 所有 workspace 共享这些能力

## ai-driven 提供的能力

| 类型 | 数量 | 说明 |
|------|------|------|
| Sub-Agents | 13个 | 代码审查、架构设计、测试等 |
| Commands | 43个 | OpenSpec、开发、测试、运维等 |
| Rules | 28个 | 通用和各语言编码规范 |
| Skills | 49个 | 框架特定、数据库、前端后端等 |

详细列表见 [reference.md](reference.md)

## 常见操作

### 创建 workspace

在 ai-driven 根目录说"创建一个 workspace"

### 同步配置

在 ai-driven 根目录说"同步所有 workspace"

### 验证框架

在 ai-driven 根目录说"检查框架是否正常"

详细操作说明见 [reference.md](reference.md)

## 不知道答案时

如果不确定答案：
1. 读取 ai-driven 相关文件获取信息
2. 建议用户查看 README.md
3. 使用 ai-driven-management skill 获取帮助
