# Global Cursor 配置

全局 Cursor IDE 配置集合，包含 rules、skills、agents、commands。

作为 `ai-driven` 框架的一部分，通过 symlink 挂载到 `~/.cursor/`，随 ai-driven 仓库统一版本控制。

## 目录结构

```
$AI_ROOT/
└── ai-driven/
    └── common/
        └── global_cursor/      <- 本目录
            ├── agents/          # Agent 定义（code-reviewer, planner 等）
            ├── commands/        # Cursor 命令（opsx-*, build-fix, plan 等）
            ├── rules/           # 编码规则（common-*, typescript-*, python-* 等）
            └── skills/          # Agent Skills（openspec-*, create-rule 等）
```

## 路径配置

所有路径通过环境变量配置，`ai-driven` 可放在任意位置：

```bash
# 设置根路径（ai-driven 所在的父目录）
export AI_ROOT=~/ai          # ai-driven 在 ~/ai/ai-driven
export AI_ROOT=/opt/projects  # ai-driven 在 /opt/projects/ai-driven
```

## 安装

运行 `ai-driven` 的 setup 脚本会自动配置 symlink：

```bash
# 使用默认路径（自动检测）
bash .cursor/skills/ai-driven-management/scripts/setup-global.sh

# 指定根路径
AI_ROOT=~/my-projects bash .cursor/skills/ai-driven-management/scripts/setup-global.sh
```

或手动创建 symlink：

```bash
GLOBAL_CURSOR="$AI_ROOT/ai-driven/common/global_cursor"
for dir in rules skills agents commands; do
    ln -sf "$GLOBAL_CURSOR/$dir" ~/.cursor/$dir
done
```

## 来源

- **OpenSpec**: commands (`opsx-*`) 和 skills (`openspec-*`)
- **Everything Claude Code**: rules、skills、commands、agents
- **Cursor 内置**: skills（create-rule, create-skill 等）
- **自定义**: 项目特定的配置和扩展
