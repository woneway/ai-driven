# AI-Driven Management 详细参考

本文件包含 ai-driven-management 的详细技术说明。

## 路径配置

所有脚本通过 `common.sh` 统一管理路径，支持以下环境变量：

| 变量 | 说明 |
|------|------|
| `AI_ROOT` | ai-driven 父目录（如 `~/ai`） |
| `AI_DRIVEN_ROOT` | ai-driven 根目录 |
| `CURSOR_HOME` | Cursor 配置目录（默认 `~/.cursor`） |
| `GLOBAL_CURSOR_DIR` | global_cursor 路径 |
| `WORKSPACES_PATH` | workspaces 存放路径 |

### .workspace.env 格式

```bash
# AI-Driven 全局配置文件
WORKSPACES_PATH=~/ai/workspaces
PROJECTS_DIR=~/ai/projects
# HOOK_ENABLED=true
```

## Setup 详细流程

### 检查配置文件

```bash
if [ ! -f ".workspace.env" ]; then
    # 引导用户创建配置
fi
```

### 安装选项说明

| 选项 | 说明 |
|------|------|
| all | OpenSpec + ECC + TypeScript/Python/Go 规则 |
| openspec | OpenSpec 工作流工具 |
| ecc | Everything Claude Code + 语言规则 |
| minimal | 仅基础配置 |

### 执行命令详情

```bash
# 全部安装
bash scripts/setup-global.sh --force

# 只安装 OpenSpec
bash scripts/setup-global.sh --openspec-only --force

# 只安装 ECC
bash scripts/setup-global.sh --ecc-only --ecc-langs "typescript,python,golang" --force

# 最小化安装
bash scripts/setup-global.sh --minimal --force
```

## Init 详细流程

### 参数说明

| 参数 | 说明 |
|------|------|
| space_name | workspace 名称（字母、数字、下划线、连字符） |
| project_name | 项目目录名称 |

### 关联已有项目 vs 创建新项目

- **关联已有**：项目代码已存在于 `{PROJECTS_DIR}` 中
- **创建新**：同时创建 workspace 和项目目录

### 脚本自动完成

1. 在 `{WORKSPACES_PATH}/<space_name>/` 创建 workspace 配置
2. 在 `{PROJECTS_DIR}/<project_name>/` 创建项目目录
3. 生成 `.code-workspace` 文件

## Analyze 详细流程

### 分析深度

| 级别 | 说明 |
|------|------|
| basic | 基本信息（名称、代码路径） |
| resources | 资源分析（skills、commands、rules） |
| upgrade | 升级建议 |

### 升级执行

如果用户选择升级：

```bash
cp workspaces/<name>/.cursor/skills/<skill> common/global_cursor/skills/
```

## Upgrade 详细流程

### search 流程

1. AskQuestion 搜索关键词
2. 执行 `npx skills find <关键词>`
3. 展示结果
4. AskQuestion 是否安装
5. 执行 `npx skills add <package> -g -y`

### create 流程

使用 `create-skill` skill 按规范创建。

### template 流程

| 模板文件 | 说明 |
|----------|------|
| ai-driven.mdc | 核心规则 |
| team.md | team 命令 |
| paths.mdc | 路径规则 |

## Status 详细流程

1. 列出 `workspaces/` 下所有含 `.workspace.env` 的目录
2. 读取每个 `.workspace.env` 的 `SPACE_NAME` 和 `PROJECT_PATH`
3. 对比 workspace 中的 `ai-driven.mdc` / `team.md` 与模板是否一致
4. 汇总报告

## 全局资源管理

- **全局资源**：`common/global_cursor/`，通过 symlink 挂载到 `~/.cursor/`
- **workspace 专属资源**：`workspaces/<name>/.cursor/`

### Symlink 说明

```bash
# 创建全局 symlink
ln -s /path/to/ai-driven/common/global_cursor/skills ~/.cursor/skills
```

## 路径规范约束

1. **禁止硬编码**：禁止在代码或配置文件中写入包含用户名的绝对路径
2. **正确做法**：使用 `.workspace.env`、相对路径、环境变量
3. **模板检查**：所有放在 `common/workspace-template/` 下的文件必须可复制到任意环境
