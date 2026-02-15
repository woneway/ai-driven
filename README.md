# AI-Driven

人只说需求，AI 全自动完成开发。

## 前置要求

- [Cursor IDE](https://cursor.sh/)
- Node.js 20+
- 全局 `~/.cursor/` 配置（[everything-claude-code](https://github.com/affaan-m/everything-claude-code) 提供 skills/rules/agents）

## 快速开始

```bash
# 创建带代码目录的 workspace
bash .cursor/skills/ai-driven-management/scripts/init-space.sh my_app ../ai-projects/my-app

# 或创建空 workspace
bash .cursor/skills/ai-driven-management/scripts/init-space.sh my_app
```

打开生成的 `.code-workspace` 文件，输入：

```
/team 做一个用户认证功能
```

AI 会自动完成全部开发工作。

## 目录结构

```
ai-driven/
├── .cursor/
│   └── skills/
│       └── ai-driven-management/   # 框架管理 skill
│           ├── SKILL.md            # 管理能力说明
│           └── scripts/
│               ├── init-space.sh   # 创建新 workspace
│               ├── sync-space.sh   # 同步升级所有 workspace
│               └── verify.sh       # 自动化验证
├── common/
│   └── workspace-template/         # workspace 模板（唯一 source of truth）
└── workspaces/                     # 所有 workspace
```

## Workspace 结构

每个 workspace 创建后包含：

```
workspace/
├── .cursor/
│   ├── commands/
│   │   ├── team.md         # /team 命令入口
│   │   └── opsx-*.md       # OpenSpec 命令（自动生成）
│   ├── rules/
│   │   └── ai-driven.mdc   # 核心约束规则
│   └── skills/             # OpenSpec 技能（自动生成）
├── openspec/               # 需求规范目录
├── .space-config           # workspace 配置
└── .code-workspace         # Cursor 工作区文件
```

## 升级

当框架更新后，同步到所有已有 workspace：

```bash
bash .cursor/skills/ai-driven-management/scripts/sync-space.sh
```

同步会覆盖 `ai-driven.mdc` 和 `team.md`，不会动 `.space-config` 和 `.gitignore`。

## 验证

运行自动化验证，检查模板结构和内容：

```bash
bash .cursor/skills/ai-driven-management/scripts/verify.sh
```

## 管理命令

在 ai-driven 根目录的 Cursor 窗口中，AI 会自动发现 `ai-driven-management` skill：

| 命令 | 用途 |
|------|------|
| `/ai-driven:init` | 创建新 workspace |
| `/ai-driven:sync` | 同步框架文件到所有 workspace |
| `/ai-driven:analyze` | 分析 workspace 发现改进机会 |
| `/ai-driven:upgrade` | 升级框架能力 |
| `/ai-driven:verify` | 验证框架健康状态 |
| `/ai-driven:status` | 查看管理状态 |

## 核心依赖

- [OpenSpec](https://github.com/Fission-AI/OpenSpec) -- 需求规范与工作流管理
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) -- 全局 skills/rules/agents

## 许可证

[MIT](LICENSE)
