# Skills 技能库

ai-driven 使用的技能库。

## 目录结构

```
skills/
├── README.md                 # 本文件
│
├── superpowers/             # 核心开发技能
│   ├── skill-brainstorming/
│   ├── skill-subagent-driven-development/
│   ├── skill-test-driven-development/
│   ├── skill-systematic-debugging/
│   ├── skill-receiving-code-review/
│   ├── skill-executing-plans/
│   ├── skill-writing-plans/
│   ├── skill-verification-before-completion/
│   ├── skill-using-git-worktrees/
│   ├── skill-root-cause-tracing/
│   └── ... (更多)
│
├── tdd/                    # TDD 相关技能
│   ├── skill-red/
│   ├── skill-green/
│   └── skill-refactor/
│
├── diagram/                # 图表技能
│   └── skill-diagram-expert/
│
└── utils/                  # 工具技能
    ├── skill-sync-workspace/
    └── skill-git-automation/
```

## 使用方式

技能通过 `.cursor/skills/` 的 symlink 链接到各 workspace。

## 添加新技能

1. 在对应分类目录创建技能
2. 创建 SKILL.md 文件
3. 在 workspace 中创建 symlink

## 技能列表

### superpowers/ - 核心开发技能

| 技能 | 用途 |
|------|------|
| skill-brainstorming | 方案讨论 |
| skill-subagent-driven-development | 子 Agent 调度 |
| skill-test-driven-development | TDD 开发 |
| skill-systematic-debugging | 调试 |
| skill-receiving-code-review | 代码审查 |
| skill-executing-plans | 执行计划 |
| skill-writing-plans | 写计划 |
| skill-verification-before-completion | 完成前验证 |

### tdd/ - TDD 流程技能

| 技能 | 用途 |
|------|------|
| skill-red | 写失败测试 |
| skill-green | 写最小实现 |
| skill-refactor | 重构 |

### diagram/ - 图表技能

| 技能 | 用途 |
|------|------|
| skill-diagram-expert | Mermaid/PlantUML 图表 |

### utils/ - 工具技能

| 技能 | 用途 |
|------|------|
| skill-sync-workspace | 同步 workspace |
| skill-git-automation | Git 自动化 |
