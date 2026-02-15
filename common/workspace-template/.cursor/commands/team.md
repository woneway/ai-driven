---
description: AI 自主开发唯一入口
---

# /team

**人只需要说"做一个 xxx"，AI 自动完成全部开发工作。**

## 流程

```
人: /team 做一个用户认证
AI: → OpenSpec 需求 → OpenSpec 设计 → TDD 实现 → 审查 → E2E → 归档
```

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

## Agent 编排

`/team` 内部使用以下 Agent 协作：

- `/openspec` - 需求分析 + 设计规划 + 进度管理
- `/tdd-guide` - TDD 开发执行
- `/code-reviewer` - 代码审查和质量把控

## OpenSpec 集成

### 命令

```bash
# 初始化 OpenSpec (首次使用时)
openspec init --tools cursor

# 创建新需求规范
openspec spec:create <feature-name>

# 生成变更提案
openspec proposal:create <description>
```

### 目录结构

```
openspec/
├── specs/              # 需求规范库
│   ├── auth-login/
│   │   └── spec.md
│   └── user-profile/
│       └── spec.md
└── changes/            # 变更提案
    ├── add-remember-me/
    │   ├── proposal.md   # 变更描述
    │   ├── design.md     # 技术设计
    │   └── tasks.md      # 实施任务 ← 这是进度管理的核心
    └── ...
```

### 工作流

```
1. @openspec 分析需求 → 生成 spec.md
2. @openspec 设计实现方案 → 生成 proposal.md + design.md + tasks.md
3. @tdd-guide 按 tasks.md 执行 → 每完成一个任务更新进度
4. @code-reviewer 审查代码
5. 更新 spec.md 反映最终实现
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
