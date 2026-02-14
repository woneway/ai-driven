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
│  - SOUL.md        核心价值观                                │
│  - IDENTITY.md    身份定义                                  │
│  - DECISION.md    决策逻辑                                   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         AGENTS                              │
│  - planner/       计划型 Agent                              │
│  - executor/     执行型 Agent                              │
│  - reviewer/     审查型 Agent                              │
│  - researcher/   调研型 Agent                              │
│  - qa/           测试型 Agent                              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         TOOLS                               │
│  - skills/       技能库                                     │
│  - commands/     命令定义                                   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         MEMORY                              │
│  - decisions    架构决策                                    │
│  - lessons      经验教训                                    │
│  - prefs        代码偏好                                   │
│  - feedback     反馈                                        │
└─────────────────────────────────────────────────────────────┘
```

## 目录结构

```
ai-driven/
├── MAIN/                       # 主 Agent 配置
│   ├── SOUL.md
│   ├── IDENTITY.md
│   └── DECISION.md
│
├── AGENTS/                     # 子 Agent 定义
│   ├── README.md              # Agent 对应关系
│   ├── planner/
│   ├── executor/
│   ├── reviewer/
│   ├── researcher/
│   └── qa/
│
├── TOOLS/                      # 工具
│   ├── skills/                # 技能库
│   └── commands/              # 命令定义
│
├── MEMORY/                     # 记忆模板
│
├── WORKSPACE/                  # 工作空间
│
├── config/
│   └── workspaces.yaml
│
└── common/
    ├── bin/init-space.sh
    └── rules/
```

## 快速开始

### 1. 克隆

```bash
git clone https://github.com/woneway/ai-driven.git
cd ai-driven
```

### 2. 创建 workspace

```bash
./common/bin/init-space.sh myproject ../my-code
```

### 3. 开发

```
/dev 做一个锦标赛盲注递增功能
```

## 许可证

MIT
