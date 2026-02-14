# AI-Driven

AI 驱动的自动化研发平台。

## 核心理念

```
人类：表达需求（"帮我做一个锦标赛功能"）
AI：自动完成（分析 → 计划 → 执行 → 验证 → 学习）
```

## 架构

```
┌─────────────────────────────────────────────────────────────┐
│                         MAIN                                │
│  - SOUL.md        核心价值观                               │
│  - IDENTITY.md    身份定义                                 │
│  - DECISION.md    决策逻辑                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         AGENTS                               │
│  - planner/       计划型 Agent                              │
│  - executor/     执行型 Agent                              │
│  - reviewer/     审查型 Agent                              │
│  - researcher/   调研型 Agent                              │
│  - qa/           测试型 Agent                              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         TOOLS                                │
│  - skills/       技能库                                     │
│  - commands/     命令定义                                   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         MEMORY                               │
│  - roles/        记忆（decisions/lessons/prefs）          │
└─────────────────────────────────────────────────────────────┘
```

## 目录结构

```
ai-driven/
├── MAIN/                       # 主 Agent 配置
│   ├── SOUL.md                # 核心价值观
│   ├── IDENTITY.md            # 身份定义
│   └── DECISION.md            # 决策逻辑
│
├── AGENTS/                     # 子 Agent 定义
│   ├── planner/               # 计划 Agent
│   ├── executor/              # 执行 Agent
│   ├── reviewer/              # 审查 Agent
│   ├── researcher/            # 调研 Agent
│   └── qa/                   # 测试 Agent
│
├── TOOLS/                      # 工具/技能
│   ├── skills/                # 技能库
│   └── commands/              # 命令定义
│
├── MEMORY/                     # 记忆
│   └── README记忆模板
│
├── WORKSPACE/                  #.md              #  工作空间
│   ├── config/                # 配置
│   └── instances/             # 实例
│
├── config/
│   └── workspaces.yaml         # workspace 列表
│
└── common/                     # 共享资源
    ├── bin/                   # 脚本
    └── templates/              # 模板
```

## 核心文件

### MAIN/

- **SOUL.md**: 核心价值观（简单优先、自动化、质量保障、持续学习）
- **IDENTITY.md**: AI 身份定义（我是谁，我能做什么）
- **DECISION.md**: 决策逻辑（需求分类、调度规则、跳过规则）

### AGENTS/

每个子 Agent 都有明确的：
- 职责定义
- 输入/输出
- 工作流程
- 检查清单

### TOOLS/

- **skills/**: 技能库（TDD、调试、图表等）
- **commands/**: 命令定义（/dev）

### MEMORY/

- **decisions.md**: 架构决策
- **lessons.md**: 经验教训
- **prefs.md**: 代码偏好

## 使用方式

### 1. 克隆项目

```bash
git clone https://github.com/woneway/ai-driven.git
cd ai-driven
```

### 2. 创建 workspace

```bash
./common/bin/init-space.sh myproject ../my-code
```

### 3. 开始开发

```
/dev 做一个锦标赛盲注递增功能
```

## 工作流程

```
用户需求
    ↓
Main Agent 分析
    ↓
判断复杂度 → 选择调度策略
    ↓
调度子 Agent（Planner/Executor/Reviewer/QA）
    ↓
执行并验证
    ↓
更新记忆 → 学习改进
```

## 子 Agent 调度规则

| 复杂度 | 调度 |
|--------|------|
| 小 | Executor → Reviewer |
| 中 | Planner → Executor → Reviewer |
| 大 | Planner → Executor → Reviewer → QA |

| 类型 | 可跳过 |
|------|--------|
| Bug | Planner |
| 调研 | Executor、QA |
| 小优化 | Planner、QA |

## 开源

本项目设计为可自由迁移和分发：
- 无硬编码绝对路径
- 所有路径可配置
- 配置文件自包含

## 许可证

MIT
