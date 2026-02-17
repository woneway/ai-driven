# 资源管理规范

本文档定义 ai-driven 框架中资源的创建、安装和同步规范。

## 资源类型

| 类型 | 位置 | 说明 |
|---|---|---|
| Skills | `skills/` | AI 技能包，包含 SKILL.md |
| Rules | `rules/` | Cursor 规则，包含 .mdc 文件 |
| Commands | `commands/` | 命令定义 |
| Agents | `agents/` | Sub-Agent 定义 |

## 安装规范

详细规范请参考：[资源安装规范](../../../.cursor/rules/resources.mdc)

> **注意**：本文档引用 `.cursor/rules/resources.mdc` 作为权威规范。

## 快速参考

### 安装到 ai-driven 自己用

适用于专门管理和赋能 ai-driven 框架的资源：

```bash
# 1. 安装
npx skills add <owner/repo@skill> -g -y

# 2. 复制到 ai-driven/.cursor/skills/
cp -r ~/.agents/skills/<skill-name> /path/to/ai-driven/.cursor/skills/
```

### 安装到 common/global_cursor/（所有 Workspace 共享）

适用于所有 Workspace 都能用的资源：

```bash
# 1. 安装
npx skills add <owner/repo@skill> -g -y

# 2. 移动到 common/global_cursor/skills/
mv ~/.agents/skills/<skill-name> /path/to/ai-driven/common/global_cursor/skills/

# 3. 清理
rm -rf ~/.agents/skills/
```

## Skill 标准格式

### 目录结构

```
skill-name/
├── SKILL.md # 必需
├── reference.md # 可选
└── scripts/ # 可选
```

### 必填字段

| 字段 | 要求 |
|---|---|
| name | 小写字母、数字、连字符，最多 64 字符 |
| description | 说明用途和触发条件 |
| SKILL.md | 包含 Instructions 和 Examples |

### 行数限制

| 文件 | 限制 |
|---|---|
| SKILL.md | < 500 行 |
| reference.md | 可超过 |

## 相关文档

- [核心概念](./core/concepts.md)
