# AI-Driven 资源完整安装使用方案

> 最大化发挥 Skills、Agents、Rules、Commands 作用的完整指南

---

## 一、架构理解

### 1.1 资源作用链

```
用户需求 → Commands → Agents → Skills → Rules → 代码生成
```

| 资源 | 作用 | 触发时机 |
|------|------|----------|
| **Commands** | 入口命令 | 用户说出特定关键词 |
| **Agents** | 专业角色 | 执行特定类型任务 |
| **Skills** | 知识包 | 提供领域知识指导 |
| **Rules** | 编码规范 | 代码生成时自动应用 |

### 1.2 生效范围

```
┌─────────────────────────────────────────────────────────┐
│                    ~/.cursor/                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │              global_cursor (全局)               │   │
│  │  skills/ rules/ commands/ agents/              │   │
│  │                  ↑ symlink                      │   │
│  │  ~/ai/ai-driven/common/global_cursor/          │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │           workspaces/<name>/.cursor/           │   │
│  │  (Workspace 专属，只对该项目生效)                │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 二、资源安装方案

### 2.1 全局安装（推荐 P0 资源）

**安装位置**: `common/global_cursor/`

**适用**: 多项目通用技术

```
P0 全局 Skills:
├── ios-development         # Swift/SwiftUI 开发
├── swift-testing           # XCTest 测试
├── nodejs-backend          # Express/Node.js 后端
├── socket-io-patterns       # 实时通信
└── crypto-trading           # 交易系统

全局 Rules:
├── swift-coding-style      # Swift 编码规范
├── ios-testing             # iOS 测试规范
└── nodejs-coding-style     # Node.js 编码规范

全局 Agents:
├── ios-developer           # iOS 开发专家
└── nodejs-developer        # Node.js 开发专家
```

**安装命令**:

```bash
# 1. 创建 Skill 目录
mkdir -p common/global_cursor/skills/ios-development
mkdir -p common/global_cursor/skills/swift-testing
mkdir -p common/global_cursor/skills/nodejs-backend
mkdir -p common/global_cursor/skills/socket-io-patterns
mkdir -p common/global_cursor/skills/crypto-trading

# 2. 创建 Rules 目录
mkdir -p common/global_cursor/rules

# 3. 创建 Agents 目录
mkdir -p common/global_cursor/agents

# 4. 创建 Commands 目录
mkdir -p common/global_cursor/commands
```

### 2.2 Workspace 专属安装

**安装位置**: `workspaces/<workspace>/.cursor/`

**适用**: 项目特定业务

| Workspace | 专属 Skills | 专属 Rules |
|-----------|-------------|------------|
| crypto-trade | quantitative-trading, trading-strategist | crypto-security |
| ios-poker-game | ios-developer-agent | swift-advanced |
| daily_stock_analysis | financial-analysis | fintech-rules |
| mobile-controller | (已全局) | (已全局) |
| ai-fashion | nextjs-advanced, shadcn-patterns | react-patterns |

**Workspace 目录结构**:

```
workspaces/
└── crypto-trade/
    ├── .workspace.env
    ├── .cursor/
    │   ├── skills/          # 专属 Skills
    │   │   └── quantitative-trading/
    │   ├── rules/            # 专属 Rules
    │   │   └── crypto-security.mdc
    │   └── agents/           # 专属 Agents
    └── project_code/        # 项目代码
```

---

## 三、最大化作用的使用策略

### 3.1 技能触发机制

#### 自然语言触发

当你在项目 Cursor 中说以下话时，自动触发对应技能：

| 技能 | 触发语句 |
|------|----------|
| ios-development | "开发 iOS 功能"、"Swift 代码"、"SwiftUI 页面" |
| swift-testing | "写测试"、"XCTest"、"单元测试" |
| nodejs-backend | "Node.js"、"Express API"、"后端接口" |
| crypto-trading | "交易策略"、"交易所"、"CCXT"、"量化" |

#### Agent 任务触发

| Agent | 触发任务 |
|-------|----------|
| ios-developer | iOS 功能开发、架构设计 |
| nodejs-developer | 后端 API 开发 |
| trading-strategist | 策略设计、回测分析 |

### 3.2 技能组合策略

#### 场景 1: 开发 iOS 新功能

```
触发流程:
1. /team "添加一个多人游戏房间功能"
2. → ios-developer Agent 激活
3. → ios-development Skill 提供 Swift/SwiftUI 规范
4. → swift-testing Skill 提供测试指导
5. → swift-coding-style Rule 应用编码规范
6. → 代码生成
```

#### 场景 2: 开发交易策略

```
触发流程:
1. /team "实现一个 RSI 均值回归策略"
2. → trading-strategist Agent 激活
3. → crypto-trading Skill 提供策略框架
4. → python-coding-style Rule 应用编码规范
5. → 代码生成 + 测试
```

### 3.3 上下文继承

新安装的技能会自动继承以下能力：

```
新 Skill 自动获得:
├── common-* Rules (通用规范)
├── hooks (自动化)
└── 框架内置 Commands
```

---

## 四、安装步骤

### 4.1 第一步：创建资源文件

按优先级创建以下文件（详见 RESOURCE_PRIORITY.md）:

```
# Skills (10 个)
common/global_cursor/skills/ios-development/SKILL.md
common/global_cursor/skills/swift-testing/SKILL.md
common/global_cursor/skills/nodejs-backend/SKILL.md
common/global_cursor/skills/socket-io-patterns/SKILL.md
common/global_cursor/skills/crypto-trading/SKILL.md

# Rules (8 个)
common/global_cursor/rules/swift-coding-style.md
common/global_cursor/rules/ios-testing.md
common/global_cursor/rules/nodejs-coding-style.md
...

# Agents (5 个)
common/global_cursor/agents/ios-developer.md
common/global_cursor/agents/nodejs-developer.md
...
```

### 4.2 第二步：同步配置

```bash
# 在 ai-driven 根目录
cd /Users/lianwu/ai/ai-driven

# 运行同步脚本
bash .cursor/skills/ai-driven-management/scripts/sync-space.sh
```

### 4.3 第三步：验证安装

```bash
# 检查 skills
ls -la ~/.cursor/skills/ | grep -E "ios|nodejs|crypto"

# 检查 rules
ls -la ~/.cursor/rules/ | grep -E "swift|nodejs"

 agents
ls -# 检查la ~/.cursor/agents/ | grep -E "ios|nodejs"
```

### 4.4 第四步：重启 Cursor

```
完全退出 Cursor (Cmd + Q)
重新打开项目
```

---

## 五、使用示例

### 5.1 开发新功能

**场景**: 在 ios-poker-game 添加新功能

```bash
# 1. 打开 ios-poker-game workspace
# 2. 告诉 AI:
"实现一个锦标赛报名功能，包括报名界面和状态管理"
# 3. 自动触发:
#    - ios-developer Agent
#    - ios-development Skill
#    - swift-coding-style Rule
# 4. AI 自动完成代码
```

### 5.2 开发后端 API

**场景**: 在 mobile-controller 添加 API

```bash
# 1. 打开 mobile-controller workspace
# 2. 告诉 AI:
"添加一个设备控制 API，支持开关设备"
# 3. 自动触发:
#    - nodejs-developer Agent
#    - nodejs-backend Skill
#    - nodejs-coding-style Rule
```

### 5.3 实现交易策略

**场景**: 在 crypto-trade 添加新策略

```bash
# 1. 打开 crypto-trade workspace
# 2. 告诉 AI:
"实现一个基于布林带的突破策略"
# 3. 自动触发:
#    - trading-strategist Agent
#    - crypto-trading Skill
#    - python-coding-style Rule
```

---

## 六、最佳实践

### 6.1 技能维护

1. **定期更新**: 每季度审查一次 Skills 是否过时
2. **收集反馈**: 从实际使用中记录改进点
3. **版本记录**: 更新时在 SKILL.md 添加 changelog

### 6.2 技能扩展

当需要新技能时：

```
判断流程:
1. 这个技能适用于多少项目?
   → 2+ 项目 → 全局安装
   → 1 个项目 → Workspace 专属

2. 这个技能是否包含敏感信息?
   → 是 → Workspace 专属
   → 否 → 全局安装
```

### 6.3 调试技能

如果技能不生效：

```bash
# 1. 检查 symlink 是否正确
ls -la ~/.cursor/skills/

# 2. 检查 Skill 格式
cat common/global_cursor/skills/<skill>/SKILL.md | head -20

# 3. 重启 Cursor
# 4. 检查触发关键词是否在 Skill 描述中
```

---

## 七、预期效果

安装完成后，你的开发效率将提升：

| 场景 | 提升效果 |
|------|----------|
| iOS 开发 | 代码规范自动应用，测试自动生成 |
| Node.js 后端 | API 设计遵循最佳实践 |
| 量化交易 | 策略开发有专业指导 |
| 代码审查 | 自动识别语言并应用对应规范 |

---

## 八、下一步行动

```
□ 第一周: 创建 P0 级别 Skills (5个)
□ 第二周: 创建 P0 级别 Rules/Agents (5个)
□ 第三周: 创建 P1 级别 Skills (4个)
□ 第四周: 完善 Commands (5个)
□ 持续: 根据使用反馈优化
```

---

文档位置: `RESOURCE_PRIORITY.md` (详细清单)
框架管理: 使用 ai-driven-management skill
