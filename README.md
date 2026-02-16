# AI-Driven

人只说需求，AI 全自动完成开发。

## 前置要求

- [Cursor IDE](https://cursor.sh/)
- Node.js 20+
- [Everything Claude Code](https://github.com/affaan-m/everything-claude-code)（需手动 clone 或下载）
- [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec)（`setup-global.sh` 会自动安装）

## 快速开始

```bash
# 1. 全局初始化（只需运行一次）
#    安装 OpenSpec、ECC 的 skills/commands/rules 到 ~/.cursor/
bash .cursor/skills/ai-driven-management/scripts/setup-global.sh

# 2. 重启 Cursor IDE 使全局命令生效

# 3. 创建 workspace
bash .cursor/skills/ai-driven-management/scripts/init-space.sh my_app

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
│               ├── setup-global.sh # 全局初始化（OpenSpec/ECC → ~/.cursor/）
│               ├── init-space.sh   # 创建新 workspace
│               ├── sync-space.sh   # 同步升级所有 workspace
│               └── verify.sh       # 自动化验证
├── common/
│   └── workspace-template/         # workspace 模板（唯一 source of truth）
└── workspaces/                     # 所有 workspace
```

## 全局配置

`setup-global.sh` 将以下工具安装到 `~/.cursor/` 全局目录，所有 workspace 共享：

| 来源 | 安装内容 | 说明 |
|------|---------|------|
| OpenSpec | commands/opsx-*.md, skills/openspec-* | 规范驱动工作流命令 |
| ECC | skills/*, commands/*, rules/* | 通用开发技能和规则 |

## Workspace 结构

每个 workspace 创建后包含（精简，不含全局内容）：

```
workspace/
├── .cursor/
│   ├── commands/
│   │   └── team.md         # /team 命令入口
│   └── rules/
│       └── ai-driven.mdc   # 核心约束规则
├── openspec/               # 需求规范目录（项目级）
├── .env                     # workspace 配置
└── .code-workspace         # Cursor 工作区文件
```

## 升级

当框架更新后，同步到所有已有 workspace：

```bash
bash .cursor/skills/ai-driven-management/scripts/sync-space.sh
```

同步会覆盖 `ai-driven.mdc` 和 `team.md`，不会动 `.env` 和 `.gitignore`。

## 验证

运行自动化验证，检查模板结构和内容：

```bash
bash .cursor/skills/ai-driven-management/scripts/verify.sh
```

## 管理命令

在 ai-driven 根目录的 Cursor 窗口中，AI 会自动发现 `ai-driven-management` skill：

| 命令 | 用途 |
|------|------|
| `/ai-driven:setup` | 全局初始化（安装 OpenSpec/ECC 到 ~/.cursor/） |
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
