# AI-Driven 资源扩展优先级文档

> 基于当前项目技术栈分析，推荐添加的 Skills、Agents、Rules、Commands

---

## 📊 当前项目技术栈

| 项目 | 技术栈 | 类型 |
|------|--------|------|
| crypto-trade | Python + Next.js + TypeScript | 量化交易 |
| ai-fashion | Next.js 16 + React 19 + TypeScript | 电商 |
| ios-poker-game | Swift 5.0 + SwiftUI + XCTest | iOS 游戏 |
| daily_stock_analysis | Python + Next.js | 金融分析 |
| mobile-controller | Node.js + Express + Socket.IO | 物联网 |

---

## 现有资源统计

| 类型 | 数量 | 说明 |
|------|------|------|
| Agents | 13 | 审查、TDD、架构等 |
| Rules | 27 | 编码规范、安全等 |
| Commands | 41 | OpenSpec、开发、运维等 |
| Skills | 49 | 框架特定、数据库等 |

---

## 🔴 高优先级 - 必须添加

这些技术与你的项目直接相关，强烈建议添加。

### Skills

| 优先级 | 名称 | 适用项目 | 理由 |
|--------|------|----------|------|
| P0 | **ios-development** | ios-poker-game | 完整的 Swift 项目，缺少 iOS 开发规范 |
| P0 | **swift-testing** | ios-poker-game | 项目已有 XCTest，需要测试规范 |
| P0 | **nodejs-backend** | mobile-controller, crypto-trade dashboard | Node.js/Express 项目需要 |
| P0 | **crypto-trading** | crypto-trade | 核心业务，CCXT、交易所 API、策略框架 |
| P0 | **socket-io-patterns** | mobile-controller | 实时通信核心依赖 |

### Agents

| 优先级 | 名称 | 适用项目 | 理由 |
|--------|------|
| P0 | **ios-developer**|------|---------- | ios-poker-game | iOS 开发专业指导 |
| P0 | **nodejs-developer** | mobile-controller | Node.js 后端开发指导 |

### Rules

| 优先级 | 名称 | 适用项目 | 理由 |
|--------|------|----------|------|
| P0 | **swift-coding-style** | ios-poker-game | Swift 编码规范缺失 |
| P0 | **ios-testing** | ios-poker-game | iOS 测试规范缺失 |
| P0 | **nodejs-coding-style** | mobile-controller | Node.js 编码规范缺失 |

### Commands

| 优先级 | 名称 | 适用项目 | 理由 |
|--------|------|----------|------|
| P0 | **ios-test** | ios-poker-game | 运行 XCTest |
| P0 | **ios-build** | ios-poker-game | 构建 iOS 项目 |
| P0 | **node-lint** | mobile-controller | Node.js 代码检查 |

---

## 🟡 中优先级 - 建议添加

这些技术对特定项目有帮助，可以后续添加。

### Skills

| 优先级 | 名称 | 适用项目 | 理由 |
|--------|------|----------|------|
| P1 | **quantitative-trading** | crypto-trade | 量化策略、回测、风险管理 |
| P1 | **financial-analysis** | daily_stock_analysis | 股票分析、资金流、指标 |
| P1 | **pandas-dataframe** | daily_stock_analysis, crypto-trade | Pandas 高效数据处理 |
| P1 | **nextjs-advanced** | ai-fashion, crypto-trade | Next.js 16 App Router、RSC、AI SDK |
| P1 | **shadcn-patterns** | ai-fashion, crypto-trade | shadcn/ui 最佳实践 |

### Agents

| 优先级 | 名称 | 适用项目 | 理由 |
|--------|------|----------|------|
| P1 | **trading-strategist** | crypto-trade | 交易策略设计指导 |
| P1 | **financial-analyst** | daily_stock_analysis | 金融数据分析指导 |

### Rules

| 优先级 | 名称 | 适用项目 | 理由 |
|--------|------|----------|------|
| P1 | **nodejs-testing** | mobile-controller | Node.js 测试规范 |
| P1 | **react-hooks** | ai-fashion, crypto-trade | React Hooks 规范（缺失） |
| P1 | **react-security** | ai-fashion, crypto-trade | React 安全规范（缺失） |

### Commands

| 优先级 | 名称 | 适用项目 | 理由 |
|--------|------|----------|------|
| P1 | **crypto-backtest** | crypto-trade | 回测交易策略 |
| P1 | **analyze-stock** | daily_stock_analysis | 股票分析命令 |

---

## 🟢 低优先级 - 可选添加

这些是通用增强，可以根据需要添加。

### Skills

| 优先级 | 名称 | 理由 |
|--------|------|------|
| P2 | **tailwind-advanced** | Tailwind CSS 高级用法 |
| P2 | **zustand-patterns** | 状态管理（已在用 zustand） |
| P2 | **ai-sdk-patterns** | AI SDK 集成（ai-fashion 已用） |
| P2 | **recharts-visualization** | 图表绘制（交易/金融项目需要） |

### Agents

| 优先级 | 名称 | 理由 |
|--------|------|------|
| P2 | **mobile-developer** | 移动端开发指导（Flutter/React Native 预留） |

### Rules

| 优先级 | 名称 | 理由 |
|--------|------|------|
| P2 | **git-hooks** | Git Hooks 自动化 |
| P2 | **ci-cd-pipeline** | CI/CD 配置规范 |

---

## 📦 推荐安装策略

### 全局安装（所有项目可用）

```bash
# 路径: common/global_cursor/skills/
ios-development
swift-testing
nodejs-backend
socket-io-patterns
crypto-trading
pandas-dataframe
```

### Workspace 专属安装

| Workspace | 专属 Skills |
|-----------|-------------|
| crypto-trade | quantitative-trading, trading-strategist |
| ios-poker-game | ios-developer, ios-testing |
| daily_stock_analysis | financial-analysis |
| ai-fashion | nextjs-advanced, shadcn-patterns |
| mobile-controller | nodejs-developer |

---

## 🔄 安装顺序建议

### 第一阶段：iOS + Node.js 核心（立即）

```
Skills:
├── ios-development
├── swift-testing
├── nodejs-backend
└── socket-io-patterns

Agents:
├── ios-developer
└── nodejs-developer

Rules:
├── swift-coding-style
├── ios-testing
└── nodejs-coding-style
```

### 第二阶段：交易 + 金融（本周）

```
Skills:
├── crypto-trading
├── quantitative-trading
└── financial-analysis

Agents:
└── trading-strategist
```

### 第三阶段：前端增强（后续）

```
Skills:
├── nextjs-advanced
├── shadcn-patterns
└── pandas-dataframe
```

---

## 📝 待创建文件清单

### Skills (10 个)

```
common/global_cursor/skills/
├── ios-development/SKILL.md
├── swift-testing/SKILL.md
├── nodejs-backend/SKILL.md
├── socket-io-patterns/SKILL.md
├── crypto-trading/SKILL.md
├── quantitative-trading/SKILL.md
├── financial-analysis/SKILL.md
├── pandas-dataframe/SKILL.md
├── nextjs-advanced/SKILL.md
└── shadcn-patterns/SKILL.md
```

### Agents (5 个)

```
common/global_cursor/agents/
├── ios-developer.md
├── nodejs-developer.md
├── trading-strategist.md
├── financial-analyst.md
└── mobile-developer.md
```

### Rules (8 个)

```
common/global_cursor/rules/
├── swift-coding-style.md
├── ios-testing.md
├── nodejs-coding-style.md
├── nodejs-testing.md
├── react-hooks.md
├── react-security.md
├── git-hooks.md
└── ci-cd-pipeline.md
```

### Commands (5 个)

```
common/global_cursor/commands/
├── ios-test.md
├── ios-build.md
├── node-lint.md
├── crypto-backtest.md
└── analyze-stock.md
```

---

## ✅ 总结

| 类型 | 现有 | 建议新增 | 优先级 |
|------|------|----------|--------|
| Skills | 49 | 10 | P0: 5, P1: 4, P2: 1 |
| Agents | 13 | 5 | P0: 2, P1: 2, P2: 1 |
| Rules | 27 | 8 | P0: 3, P1: 3, P2: 2 |
| Commands | 41 | 5 | P0: 3, P1: 2 |

**建议优先创建 P0 级别资源**，覆盖 iOS 和 Node.js 核心开发需求。
