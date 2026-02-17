# Tasks

## Task 1: 安装 brainstorming skill

- [x] 执行 `npx skills add obra/superpowers@brainstorming -g -y`
- [x] 验证安装在 ~/.agents/skills/brainstorming

## Task 2: 安装 systematic-debugging skill

- [x] 执行 `npx skills add obra/superpowers@systematic-debugging -g -y`
- [x] 验证安装在 ~/.agents/skills/systematic-debugging

## Task 3: 移动 skills 到 global_cursor

- [x] 移动 brainstorming 到 common/global_cursor/skills/
- [x] 移动 systematic-debugging 到 common/global_cursor/skills/
- [x] 验证文件为实际目录（非 symlink）

## Task 4: 清理 ~/.agents/skills

- [x] 删除 ~/.agents/skills/ 目录
- [x] 验证已清理

## Task 5: 验证 symlink

- [x] 确认 ~/.cursor/skills → common/global_cursor/skills symlink 正常

## Task 6: 归档

- [ ] 归档变更到 openspec/changes/archive/
