# 提案：更新 resources.mdc 规范

## 概述

更新 `resources.mdc` 规则，补充 skills 安装流程的规范。

## 背景

在安装 `obra/superpowers` skills 时，发现原规范缺少以下内容：

1. 安装后需要移动到 `common/global_cursor/skills/`，而非保留在 `~/.agents/skills/`
2. 需要清理 `~/.agents/skills/` 避免重复存储
3. 需要验证确保是实际文件（非 symlink）

## 变更内容

1. 新增「安装流程」通用步骤说明
2. 强调使用 `mv`（移动）而非 `cp`（复制）
3. 新增清理 `~/.agents/skills/` 步骤
4. 新增验证项：确保是实际目录、验证 symlink

## 目标文件

- `.cursor/rules/resources.mdc`
