---
name: ai-driven-management
description: Manages the ai-driven framework. Creates, syncs, verifies, and analyzes workspaces. Use when the user wants to create/sync/verify/analyze workspaces, or manage the framework itself.
---

# AI-Driven Management

管理 ai-driven 框架本身。在 ai-driven 根目录的 Cursor 窗口中使用。

## 触发方式

用户直接说出需求，AI 自动选择对应流程。所有流程**优先使用 AskQuestion 收集参数**。

| 用户说... | 自动触发流程 |
|-----------|-------------|
| "创建一个 workspace" | Init 流程 |
| "同步所有 workspace" | Sync 流程 |
| "检查框架是否正常" | Verify 流程 |
| "分析 workspace 资源" | Analyze 流程 |
| "升级/安装新技能" | Upgrade 流程 |
| "查看 workspace 状态" | Status 流程 |
| "初始化全局配置" | Setup 流程 |

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

**路径规范约束**：

当创建、修改或同步任何资源时（commands/rules/skills/agents），必须遵循以下规则：

1. **禁止硬编码路径**：禁止在代码或配置文件中写入以下类型的绝对路径：
   - 包含用户名的路径（如 `/Users/lianwu/...`）
   - 硬编码的 `/Users/lianwu/ai/ai-driven`
   - 硬编码的 `/Users/lianwu/ai/ai-projects`

2. **正确做法**：
   - 使用 `.workspace.env` 配置文件管理路径
   - 使用相对路径
   - 使用环境变量或 `common.sh` 中的路径变量

3. **模板文件检查**：
   - 所有放在 `common/workspace-template/` 下的文件必须可被复制到任意用户的环境
   - 创建新资源后，检查是否有硬编码路径

## 流程总览

| 流程 | 用途 | AskQuestion 参数 |
|------|------|-----------------|
| Setup | 全局初始化 | 组件选择、语言规则 |
| Init | 创建 workspace | workspace 名称、代码路径 |
| Sync | 同步配置 | 无需参数 |
| Verify | 验证框架 | 无需参数 |
| Analyze | 分析资源 | 分析范围选择 |
| Upgrade | 升级框架 | 升级类型选择 |
| Status | 查看状态 | 无需参数 |

## Setup 流程（全局初始化）

初始化全局 Cursor 配置，安装 OpenSpec、ECC 等工具到 `common/global_cursor/`，并通过 symlink 挂载到 `~/.cursor/`。

### 步骤 1：AskQuestion 收集参数

```python
# 第一步：选择安装什么
AskQuestion 询问"安装哪些组件？"，选项：
- "all": "全部（OpenSpec + ECC）"
- "openspec": "只安装 OpenSpec"
- "ecc": "只安装 Everything Claude Code"
```

### 步骤 2：如果选择 ECC，AskQuestion 语言规则

```python
AskQuestion 询问"选择需要安装的语言规则？"，选项：
- "typescript": "TypeScript"
- "python": "Python"
- "golang": "Go"
- "typescript_python": "TypeScript + Python"
- "all": "全部语言规则"
```

### 步骤 3：执行脚本

根据选择执行：

| 选择 | 执行命令 |
|------|----------|
| 全部 | `bash scripts/setup-global.sh --force` |
| 只 OpenSpec | `bash scripts/setup-global.sh --openspec-only --force` |
| 只 ECC | `bash scripts/setup-global.sh --ecc-only --ecc-langs "<langs>" --force` |

### 步骤 4：提示用户

提示用户重启 Cursor IDE 使全局命令生效。

**路径配置**：所有脚本通过 `common.sh` 统一管理路径，支持以下环境变量：
- `AI_ROOT` - ai-driven 所在的父目录（如 `~/ai`）
- `AI_DRIVEN_ROOT` - 直接指定 ai-driven 根目录
- `CURSOR_HOME` - Cursor 配置目录（默认 `~/.cursor`）
- `GLOBAL_CURSOR_DIR` - global_cursor 路径
- `WORKSPACES_PATH` - workspaces 存放路径

## Init 流程

创建新 workspace。

### 步骤 1：AskQuestion 收集参数

```python
# 第一步：AskQuestion workspace 名称
AskQuestion 询问"请输入 Workspace 名称？（只允许字母、数字、下划线、连字符）"，选项：
- "input": "用户手动输入名称"
```

### 步骤 2：AskQuestion 代码路径

```python
# 第二步：AskQuestion 是否关联代码
AskQuestion 询问"是否关联已有代码目录？"，选项：
- "yes": "是，指定代码路径"
- "no": "否，创建空 workspace"
```

如果用户选择"是"，继续 AskQuestion：

```python
AskQuestion 询问"请输入代码目录路径？（多个路径用逗号分隔）"，选项：
- "input": "用户手动输入路径"
```

### 步骤 3：执行脚本

```bash
# 创建空 workspace
bash scripts/init-space.sh <space_name>

# 关联已有代码
bash scripts/init-space.sh <space_name> <code_path1> <code_path2>
```

### 步骤 4：提示用户

提示用户打开生成的 `.code-workspace` 文件。

## Sync 流程

同步所有 workspace 的配置。

### 步骤 1：确认执行

直接执行，无需 AskQuestion（用户明确说"同步"）：

```bash
bash scripts/sync-space.sh
```

### 步骤 2：展示结果

展示同步结果，包括：
- 同步了多少个 workspace
- 哪些文件被更新

## Verify 流程

验证框架健康状态。

### 步骤 1：确认执行

直接执行，无需 AskQuestion（用户明确说"验证"）：

```bash
bash scripts/verify.sh
```

### 步骤 2：展示结果

展示验证结果，包括：
- 通过/失败的检查项
- 需要注意的问题

## Analyze 流程

分析 workspace 资源使用情况。

### 步骤 1：列出 workspace

先获取所有 workspace 列表：

```bash
ls workspaces/*/.workspace.env | xargs -n1 dirname | xargs -n1 basename
```

### 步骤 2：AskQuestion 选择分析范围

```python
AskQuestion 询问"分析哪些 workspace？（可多选）"，选项：
- "all": "全部 workspace"
- [动态生成每个 workspace 的选项]
```

### 步骤 3：AskQuestion 分析深度

```python
AskQuestion 询问"分析哪些内容？"，选项：
- "basic": "基本信息（名称、代码路径）"
- "resources": "资源分析（skills、commands、rules）"
- "upgrade": "升级建议（可迁移到全局的资源）"
```

### 步骤 4：执行分析

```bash
# 基本信息分析
# 直接读取 .workspace.env

# 资源分析
bash scripts/check-workspace-resources.sh
```

### 步骤 5：展示结果

展示分析结果，包括：
- workspace 列表和基本信息
- 资源使用情况
- 可升级到全局的建议

### 步骤 6：AskQuestion 是否执行升级

如果选择"upgrade"，询问：

```python
AskQuestion 询问"是否执行升级？"，选项：
- "yes": "是，执行升级"
- "no": "否，稍后手动处理"
```

如果选择"是"，执行复制操作：

```bash
cp workspaces/<name>/.cursor/skills/<skill> common/global_cursor/skills/
```

## Upgrade 流程

升级框架能力。

### 步骤 1：AskQuestion 升级类型

```python
AskQuestion 询问"需要什么类型的升级？"，选项：
- "search": "搜索并安装开源技能"
- "create": "创建项目专属技能"
- "template": "更新框架模板"
- "sync": "同步到所有 workspace"
```

### 步骤 2：根据类型执行

#### search（搜索开源）

```python
# 先 AskQuestion 搜索关键词
AskQuestion 询问"搜索什么关键词？"，选项：
- "input": "用户输入关键词"
```

然后执行：

```bash
npx skills find <关键词>
```

找到后 AskQuestion：

```python
AskQuestion 询问"是否安装？"，选项：
- "yes": "是，安装"
- "no": "否"
```

如果选择"是"：

```bash
npx skills add <package> -g -y
```

#### create（创建专属技能）

使用 `create-skill` skill 按规范创建。

#### template（更新模板）

```python
AskQuestion 询问"更新哪个模板文件？"，选项：
- "ai-driven.mdc": "核心规则"
- "team.md": "team 命令"
- "paths.mdc": "路径规则"
- "other": "其他文件"
```

#### sync（同步配置）

```bash
bash scripts/sync-space.sh
```

## Status 流程

查看 workspace 状态。

### 步骤 1：获取 workspace 列表

```bash
ls workspaces/*/.workspace.env | xargs -n1 dirname | xargs -n1 basename
```

### 步骤 2：执行状态检查

直接执行，无需 AskQuestion：

1. 列出 `workspaces/` 下所有含 `.workspace.env` 的目录
2. 读取每个 `.workspace.env` 的 `SPACE_NAME` 和 `PROJECT_PATH`
3. 对比 workspace 中的 `ai-driven.mdc` / `team.md` 与模板是否一致
4. 汇总报告

### 步骤 3：展示结果

展示：
- workspace 总数
- 每个 workspace 的名称、代码路径
- 配置是否与模板一致

## 脚本说明

| 脚本 | 用途 | 需要参数 |
|------|------|----------|
| `scripts/common.sh` | 公共路径配置（被其他脚本 source） | 无 |
| `scripts/setup-global.sh` | 全局初始化（OpenSpec/ECC/symlink） | [options] |
| `scripts/init-space.sh` | 创建 workspace | space_name, [code_roots...] |
| `scripts/sync-space.sh` | 同步所有 workspace | 无 |
| `scripts/verify.sh` | 验证框架健康 | 无 |
| `scripts/check-workspace-resources.sh` | 分析 workspace 资源 | [workspace_name] |

## Examples

### 示例 1: 创建新 workspace

用户说: "帮我创建一个 workspace"

```
1. AskQuestion: "请输入 Workspace 名称？"
2. AskQuestion: "是否关联已有代码目录？"
3. 如果关联，AskQuestion: "代码目录路径是？"
4. 执行: bash scripts/init-space.sh <name> [code_paths]
5. 提示用户打开 .code-workspace 文件
```

### 示例 2: 分析 workspace 资源

用户说: "分析一下 workspace 资源"

```
1. AskQuestion: "分析哪些 workspace？"（列出所有 workspace）
2. AskQuestion: "分析哪些内容？"（basic/resources/upgrade）
3. 执行分析脚本
4. 展示分析结果
5. AskQuestion: "是否执行升级？"
```

### 示例 3: 同步配置

用户说: "同步一下所有 workspace"

```
1. 直接执行: bash scripts/sync-space.sh
2. 展示同步结果
```

### 示例 4: 验证框架

用户说: "检查框架是否正常"

```
1. 直接执行: bash scripts/verify.sh
2. 展示验证结果
```

### 示例 5: 升级技能

用户说: "安装一个新技能"

```
1. AskQuestion: "需要什么类型的升级？"
2. 如果选择搜索: AskQuestion 搜索关键词 -> npx skills find -> AskQuestion 是否安装
3. 如果选择创建: 使用 create-skill skill
4. 如果选择同步: bash scripts/sync-space.sh
```

## 交互原则

### 优先使用 AskQuestion

- **所有流程都使用 AskQuestion 收集参数**
- 先列出选项，让用户选择
- 必要时让用户手动输入（使用 input 类型）

### AskQuestion 格式

```python
AskQuestion 询问"<问题>"，选项：
- "<id>": "<选项文字>"
```

### 必要时的输入

如果选项中没有用户需要的值，使用 input 类型：

```python
AskQuestion 询问"<问题>"，选项：
- "input": "手动输入"
```
