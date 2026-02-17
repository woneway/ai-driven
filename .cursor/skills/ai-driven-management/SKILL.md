---
name: ai-driven-management
description: Manages the ai-driven framework. Creates, syncs, verifies, and analyzes workspaces. Use when the user wants to create/sync/verify/analyze workspaces, set up the framework, or manage workspaces.
---

# AI-Driven Management

管理 ai-driven 框架本身。在 ai-driven 根目录的 Cursor 窗口中使用。

## 触发方式

当用户需要以下操作时使用：

| 用户说... | 自动触发 |
|-----------|---------|
| "初始化/设置/开始使用" | Setup |
| "创建 workspace" | Init |
| "同步" | Sync |
| "检查/验证" | Verify |
| "分析" | Analyze |
| "升级/安装技能" | Upgrade |
| "查看状态" | Status |

所有脚本路径：`.cursor/skills/ai-driven-management/scripts/`

## 快速开始

### 前提条件

- 此 skill 只在 ai-driven 根目录（包含 `workspaces/` 和 `common/` 目录）中使用
- workspace 和项目路径需配置在 `.workspace.env`

### 关键约束

**路径规范**：
- 禁止硬编码路径（如 `/Users/lianwu/...`）
- 使用 `.workspace.env` 或相对路径
- 模板文件必须可复制到任意环境

## 流程

### Setup

初始化全局 Cursor 配置（OpenSpec、ECC 等）。

1. 检查 `.workspace.env` 是否存在，不存在则引导创建
2. AskQuestion 选择安装内容
3. 执行安装脚本
4. 提示重启 Cursor

### Init

创建新 workspace。

1. AskQuestion workspace 名称和项目名称
2. 执行 `bash scripts/init-space.sh <space_name> <project_name>`
3. 提示打开 `.code-workspace` 文件

### Sync

执行 `bash scripts/sync-space.sh`

### Verify

执行 `bash scripts/verify.sh`

### Analyze

1. AskQuestion 分析范围
2. 执行 `bash scripts/check-workspace-resources.sh`
3. 展示结果

### Upgrade

1. AskQuestion 升级类型
2. 根据选择执行：
   - search: `npx skills find <关键词>`
   - create: 使用 `create-skill` skill
   - template: 更新模板文件
   - sync: `bash scripts/sync-space.sh`

### Status

1. 获取 workspace 列表
2. 展示状态

## 脚本说明

| 脚本 | 用途 |
|------|------|
| `scripts/common.sh` | 公共路径配置 |
| `scripts/setup-global.sh` | 全局初始化 |
| `scripts/init-space.sh` | 创建 workspace |
| `scripts/sync-space.sh` | 同步所有 workspace |
| `scripts/verify.sh` | 验证框架健康 |
| `scripts/check-workspace-resources.sh` | 分析资源 |

## Examples

用户说"我要开始使用 ai-driven" → 执行 Setup 流程

用户说"帮我创建 workspace" → 执行 Init 流程

用户说"同步" → 执行 Sync 流程

用户说"检查框架" → 执行 Verify 流程

用户说"分析 workspace" → 执行 Analyze 流程

用户说"安装技能" → 执行 Upgrade 流程

用户说"查看状态" → 执行 Status 流程

详细说明见 [reference.md](reference.md)
