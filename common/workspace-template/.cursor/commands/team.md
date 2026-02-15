---
description: AI 自主开发唯一入口
---

# /team

**人只需要说"做一个 xxx"，AI 自动完成全部开发工作。**

## 流程

```
人: /team 做一个用户认证
AI: → 快速实现 → TDD验证 → 审查发现问题 → 修复 → 再次验证 → E2E → 归档
```

## 核心理念

**后置发现问题，而非前置避免问题。**

| 旧模式 | 新模式 |
|--------|--------|
| 设计阶段解决所有问题 | 快速迭代，发现问题再修复 |
| 一次性完成 | 小步快跑，多次验证 |
| 预防为主 | 验证为主 |

## 核心能力

| 工具 | 用途 |
|------|------|
| **OpenSpec** | 需求规范 + 进度管理 + 技术设计 |
| **TDD** | 代码质量保障 |
| **Code Review** | 代码审查 |

## 使用示例

```
/team 做一个用户注册功能
/team 实现 REST API
/team 添加单元测试覆盖
```

## 目录结构（重要！）

```
workspace/
├── .cursor/           # Cursor 配置
├── .homunculus/      # 项目知识
├── openspec/         # 规范文档（不是代码！）
│   └── specs/        # 需求规范存放位置
│       └── <feature>/
│           └── spec.md
└── .code-workspace   # 指向 project 目录

project/              # 实际代码目录（由 .code-workspace 指定）
├── src/
├── tests/
└── main.py
```

### 关键规则

1. **代码写到 project 目录**，不是 workspace 根目录
2. **spec.md 写到 openspec/specs/**，格式为 `YYYY-MM-DD-HHMMSS_feature-name`
3. 查看 project 路径：`cat .space-config` 或打开 `.code-workspace`

### 规范命名格式

```
openspec/specs/2026-02-15-134230_calculator/spec.md
        ↑ 年-月日-时分秒 ↑ 功能名
```

创建规范时使用当前时间戳：
```bash
# 获取当前时间戳
TIMESTAMP=$(date +"%Y-%m-%d%H%M%S")
# 创建目录
mkdir -p openspec/specs/${TIMESTAMP}_<feature-name>
```

## Agent 编排

`/team` 内部使用以下 Agent 协作：

- `/tdd-guide` - 快速实现 + TDD 验证（核心）
- `/code-reviewer` - 审查发现问题
- `/openspec` - **边做边记**，记录规范和进度（不是前置设计）

## 工作流：边做边记

### 1. 快速实现 + TDD（先完成，再完美）

```
@tdd-guide 实现用户登录
→ 先写最小可行代码
→ 写测试 → 测试失败 = 发现需求问题 → 问用户
→ 测试通过 = 需求理解正确
→ 不要过度设计
```

### 2. 审查发现问题（代码审查 = 质量把关）

```
@code-reviewer 审查代码
→ 发现问题 → 分类: 严重/中等/低
→ 严重问题必须修复
→ 中等问题视情况修复
→ 低问题可忽略
```

### 3. 修复循环（迭代直到通过）

```
@tdd-guide 修复问题
→ 再次审查
→ 直到所有严重问题解决
```

### 4. E2E 验证（端到端 = 集成验证）

```
→ 运行完整测试
→ 发现集成问题 → 修复
→ 直到全部通过
```

### 5. **边做边记**（OpenSpec）

```
→ 完成后更新 spec.md 反映最终实现
→ 更新 tasks.md 标记完成
→ 记录技术决策到 design.md
```

## OpenSpec 集成

> **重要**：OpenSpec 是**边做边记**，不是前置设计。

### 核心理念

| 前置设计 | 边做边记 |
|----------|----------|
| 先写完 spec 再写代码 | 先写代码，过程中记录 spec |
| 设计阶段解决所有问题 | 迭代中发现问题 |
| 一次性完成 | 持续更新 |

### 使用方式

```bash
# 1. 先实现功能，边做边记
# 2. 完成后更新 spec.md
# 3. 更新 tasks.md 标记进度

# 可选：如有需要，用 openspec 生成 proposal
openspec proposal:create <description>
```

### 目录结构

```
openspec/
├── specs/              # 需求规范库（完成后记录）
│   ├── auth-login/
│   │   └── spec.md    # 最终实现的规范
│   └── user-profile/
│       └── spec.md
└── changes/            # 变更提案（如需要）
    ├── add-remember-me/
    │   ├── proposal.md   # 变更描述
    │   ├── design.md     # 技术决策
    │   └── tasks.md      # 实施任务
    └── ...
```

### 进度管理

使用 `tasks.md` 管理进度：

```
## Tasks: add-remember-me

- [x] 1. 更新 auth-session spec 支持 remember me
- [x] 2. 添加数据库字段 remember_token
- [ ] 3. 实现登录时设置 remember me cookie
- [ ] 4. 实现自动登录逻辑
- [ ] 5. 添加单元测试
- [ ] 6. 集成测试
```

每完成一个任务，标记 `[x]`，AI 自动更新进度。

## Agent 协作模式

### 1. 任务派发

主 Agent (Lead) 将大任务拆分为子任务，派发给子 Agent：

```
Lead: @openspec 分析需求，生成规范和任务列表
      @tdd-guide 实现用户模块 (按 tasks.md)
      @tdd-guide 实现认证模块
      @code-reviewer 审查代码
```

每个子 Agent 有独立上下文，可以并行工作。

### 2. 持续对话 (Resume)

子 Agent 完成后，主 Agent 可以继续派发新任务，保持上下文：

```
主 Agent: @tdd-guide 实现用户认证
子 Agent: 完成用户登录、注册、登出功能

主 Agent: @tdd-guide 再添加验证码功能
子 Agent: 好的，继续...
```

**要点**：使用"继续"、"再"、"额外"等词让子 Agent 保持上下文。

### 3. 进度检查点

大任务通过 OpenSpec `tasks.md` 管理，每阶段完成后更新进度：

```
## tasks.md 进度

✅ 已完成 (3/8):
- [x] 1. 创建用户模型
- [x] 2. 数据库迁移
- [x] 3. 用户注册 API

🔄 进行中 (1/8):
- [ ] 4. 用户登录 API (80%)

⏳ 待办 (4/8):
- [ ] 5. 验证码发送
- [ ] 6. 密码重置
- [ ] 7. 单元测试
- [ ] 8. 集成测试
```

> **关键**：进度存储在 `openspec/changes/<change-id>/tasks.md`，不是临时文件。

### 4. 问题确认

子 Agent 遇到关键决策时，主动询问后再继续：

```
@tdd-guide 实现支付模块

> 子 Agent: 支付模块需要支持多种渠道，请问：
> 1. 初期支持哪些渠道? (支付宝/微信/银行卡)
> 2. 是否需要退款功能?
> 3. 回调通知的签名验签方式?
```

### 5. 结果验证

子 Agent 返回后，主 Agent 进行验证，不通过则反馈重做：

```
@code-reviewer 审查用户模块代码

> 子 Agent: 审查完成，发现 3 个问题:
> 1. 密码明文存储 - 严重
> 2. 缺少事务处理 - 中等
> 3. 日志不规范 - 低

主 Agent: @tdd-guide 修复问题 1 和 2，问题 3 暂时忽略
```

### 6. 状态文件 (可选)

复杂任务可通过共享文件传递状态：

```
.workspace/
  ├── .agent-state/
  │   ├── pending-tasks.md    # 待办任务
  │   ├── progress.md         # 进度报告
  │   └── questions.md        # 待确认问题
```

## 子 Agent 生命周期

```
┌─────────────┐
│   Lead      │
│  (主 Agent) │
└──────┬──────┘
       │ 1. 派发任务
       ▼
┌─────────────┐     ┌─────────────┐
│  子 Agent   │────►│  执行任务   │
│  (被调用)   │     │  - 独立上下文│
└─────────────┘     └──────┬──────┘
                          │ 2. 返回结果
                          │    (或问题)
                          ▼
                   ┌─────────────┐
                   │  主 Agent    │
                   │  验证/继续   │
                   └─────────────┘
```

## 最佳实践

1. **任务粒度**：子任务控制在 30 分钟内可完成
2. **主动确认**：关键决策前先问用户/主 Agent
3. **进度透明**：使用 `tasks.md` 管理进度，避免"石沉大海"
4. **错误处理**：失败后分析原因，可选择重试或换策略
5. **上下文保持**：相关任务尽量交给同一子 Agent
6. **规范先行**：先写 spec，再写代码，避免返工
7. **进度即文档**：`tasks.md` 完成后的就是项目文档
