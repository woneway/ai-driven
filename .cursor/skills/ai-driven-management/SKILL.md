---
name: ai-driven-management
description: Manages the ai-driven framework. Creates, syncs, verifies, and upgrades workspaces. Use when the user says /ai-driven, or needs to create/sync/verify/analyze/upgrade workspaces.
---

# AI-Driven Management

管理 ai-driven 框架本身。在 ai-driven 根目录的 Cursor 窗口中使用。

## 命令路由

根据用户输入选择对应流程：

- `/ai-driven:setup` -> Setup 流程（全局初始化）
- `/ai-driven:init` -> Init 流程
- `/ai-driven:sync` -> 直接执行 `bash scripts/sync-space.sh`
- `/ai-driven:verify` -> 直接执行 `bash scripts/verify.sh`
- `/ai-driven:analyze` -> Analyze 流程
- `/ai-driven:upgrade` -> Upgrade 流程
- `/ai-driven:status` -> Status 流程

所有脚本路径相对于此 skill 目录：`.cursor/skills/ai-driven-management/scripts/`

## Instructions

在 ai-driven 根目录的 Cursor 窗口中使用此 skill。

### 使用场景

当用户需要以下操作时使用：
- 创建新的 workspace
- 同步所有 workspace 的配置
- 验证框架健康状态
- 分析 workspace 资源使用情况
- 升级/安装新的 skills
- 查看框架状态

### 关键约束

- 此 skill 只在 ai-driven 根目录（包含 `workspaces/` 和 `common/` 目录）中使用
- 所有脚本通过 `common.sh` 管理路径
- 全局资源在 `common/global_cursor/`，通过 symlink 挂载到 `~/.cursor/`
- workspace 专属资源在 `workspaces/<name>/.cursor/`

## Setup 流程（全局初始化）

初始化全局 Cursor 配置，安装 OpenSpec、ECC 等工具到 `common/global_cursor/`，并通过 symlink 挂载到 `~/.cursor/`。

所有路径通过 `AI_ROOT` 环境变量配置，`ai-driven` 可放在任意位置。

1. 使用 AskQuestion 收集参数：

```
问题 1: "安装哪些组件？"
  选项: ["全部", "只安装 OpenSpec", "只安装 Everything Claude Code"]

问题 2: "ECC 语言规则？"（如果安装 ECC）
  选项: ["typescript", "python", "golang", "typescript python", "全部"]
```

2. 执行：

```bash
bash scripts/setup-global.sh [--openspec-only|--ecc-only] [--ecc-langs "<langs>"] --force
```

3. 提示用户重启 Cursor IDE 使全局命令生效。

**路径配置**：所有脚本通过 `common.sh` 统一管理路径，支持以下环境变量：
- `AI_ROOT` - ai-driven 所在的父目录（如 `~/ai`）
- `AI_DRIVEN_ROOT` - 直接指定 ai-driven 根目录
- `CURSOR_HOME` - Cursor 配置目录（默认 `~/.cursor`）
- `GLOBAL_CURSOR_DIR` - global_cursor 路径
- `WORKSPACES_PATH` - workspaces 存放路径

## Init 流程

创建新 workspace。需要收集参数：

1. 使用 AskQuestion 收集缺失参数：

```
问题 1: "Workspace 名称是什么？"（如果用户未提供）
  - 自由文本，只允许字母数字下划线连字符

问题 2: "是否关联已有代码目录？"
  选项: ["是，指定路径", "否，创建空 workspace"]
  - 如果"是"，追问代码目录路径（可以多个，逗号分隔）
```

2. 参数齐全后执行：

```bash
bash scripts/init-space.sh <space_name> [code_root1] [code_root2] ...
```

3. 执行完成后提示用户打开生成的 `.code-workspace` 文件。

## Analyze 流程

1. 遍历 `workspaces/` 下所有含 `.space-config` 的目录
2. 读取每个 workspace 的项目经验和使用模式

### 2.1 资源分析（可选）

执行 `.cursor/skills/ai-driven-management/scripts/check-workspace-resources.sh` 分析：

1. **扫描每个 workspace 的专属资源**：
   - skills
   - agents
   - commands
   - rules

2. **检查全局 vs global_cursor 差异**：
   - 识别未同步到 global_cursor 的资源

3. **识别可升级资源**：
   - 被多个 workspace 共同使用的资源
   - 通用型资源建议升级到全局

### 2.2 用户选择（QA 多选）

使用 AskQuestion 提供 4 个多选题：

```
问题 1: "发现以下 skills 可以升级到全局，选择要升级的："
  选项: [多选]
  - skill-A (workspace: ai-fashion)
  - skill-B (workspace: daily-stock)
  - skill-C (workspace: crypto-trade)

问题 2: "发现以下 commands 可以升级到全局，选择要升级的："
  选项: [多选]
  - command-A (workspace: xxx)
  - ...

问题 3: "发现以下 rules 可以升级到全局，选择要升级的："
  选项: [多选]
  - rule-A (workspace: xxx)
  - ...

问题 4: "发现以下 agents 可以升级到全局，选择要升级的："
  选项: [多选]
  - agent-A (workspace: xxx)
  - ...
```

### 2.3 执行升级

根据用户选择，执行复制操作：

```bash
# 将选中的资源从 workspace 复制到 global_cursor
cp workspaces/<name>/.cursor/skills/<skill> common/global_cursor/skills/
```

### 2.4 确认分析范围（原有）

```
问题: "分析哪些 workspace？"
  选项: [列出所有发现的 workspace 名称]（允许多选）
```

## Upgrade 流程

1. 使用 AskQuestion 收集需求：

```
问题: "需要什么类型的升级？"
  选项: ["搜索并安装开源技能", "创建项目专属技能", "更新框架模板", "同步到所有 workspace"]
```

2. 根据选择执行：
   - 搜索开源：`npx skills find <关键词>` -> 找到则 `npx skills add <package> -g -y`
   - 创建专属：使用 create-skill skill 按规范创建
   - 更新模板：编辑 `common/workspace-template/` 下的文件
   - 同步：执行 `bash scripts/sync-space.sh`

## Status 流程

直接执行，无需参数：

1. 列出 `workspaces/` 下所有含 `.space-config` 的目录
2. 读取每个 `.space-config` 的 `SPACE_NAME` 和 `CODE_ROOTS_ABS`
3. 对比 workspace 中的 `ai-driven.mdc` / `team.md` 与模板是否一致
4. 汇总报告

## 脚本说明

| 脚本 | 用途 | 需要参数 |
|------|------|----------|
| `scripts/common.sh` | 公共路径配置（被其他脚本 source） | 无 |
| `scripts/setup-global.sh` | 全局初始化（OpenSpec/ECC/symlink） | [options] |
| `scripts/init-space.sh` | 创建 workspace | space_name, [code_roots...] |
| `scripts/sync-space.sh` | 同步所有 workspace | 无 |
| `scripts/verify.sh` | 验证框架健康 | 无 |

## Examples

### 示例 1: 创建新 workspace

用户说: "创建一个新的项目 workspace"

```
1. 使用 AskQuestion 收集：
   - workspace 名称
   - 是否关联已有代码目录
2. 执行: bash scripts/init-space.sh <name> [code_paths]
3. 提示用户打开 .code-workspace 文件
```

### 示例 2: 分析 workspace 资源

用户说: "分析一下各个 workspace 的资源使用情况"

```
1. 执行 check-workspace-resources.sh 脚本
2. 分析输出，识别可升级资源
3. 使用 AskQuestion 让用户选择要升级的资源
4. 执行复制操作升级到 global_cursor
```

### 示例 3: 同步配置

用户说: "同步一下所有 workspace 的配置"

```
直接执行: bash scripts/sync-space.sh
```

### 示例 4: 验证框架

用户说: "检查一下框架是否正常"

```
直接执行: bash scripts/verify.sh
```
