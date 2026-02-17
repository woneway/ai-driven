# Skills 规格库

## 概述

ai-driven 框架的全局 Skills 资源库，记录所有安装的 skills。

## 安装记录

### 2026-02-17: obra/superpowers skills

| Skill | 来源 | 安装量 | 用途 |
|-------|------|--------|------|
| brainstorming | obra/superpowers | 21.3K | 头脑风暴、方案设计 |
| systematic-debugging | obra/superpowers | 11.8K | 系统化调试、根因分析 |

## 安装规范

1. 使用 `npx skills add` 安装
2. 移动到 `common/global_cursor/skills/` 目录
3. 清理 `~/.agents/skills/` 避免重复存储
4. 归档变更到 `openspec/changes/archive/`
5. 同步规格到 `openspec/specs/skills/`

## 规则更新记录

### 2026-02-17: 更新 resources.mdc

- 新增「安装流程」通用步骤说明
- 强调使用 `mv`（移动）而非 `cp`（复制）
- 新增清理 `~/.agents/skills/` 步骤
- 新增验证项：确保是实际目录、验证 symlink
