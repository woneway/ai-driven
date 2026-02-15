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

## Setup 流程（全局初始化）

初始化全局 Cursor 配置，安装 OpenSpec、ECC 等工具的 skills/commands/rules 到 `~/.cursor/`。

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
3. 使用 AskQuestion 确认分析范围：

```
问题: "分析哪些 workspace？"
  选项: [列出所有发现的 workspace 名称]（允许多选）
```

4. 汇总分析，生成升级建议，等待用户确认

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
| `scripts/setup-global.sh` | 全局初始化（OpenSpec/ECC） | [options] |
| `scripts/init-space.sh` | 创建 workspace | space_name, [code_roots...] |
| `scripts/sync-space.sh` | 同步所有 workspace | 无 |
| `scripts/verify.sh` | 验证框架健康 | 无 |
