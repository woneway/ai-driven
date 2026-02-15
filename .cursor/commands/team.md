---
description: AI 自主开发唯一入口
---

# /team

> ⚠️ **注意**：此文件是全局备份。权威版本位于 `common/workspace-template/.cursor/commands/team.md`

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

## Agent 编排

- `@openspec` - 需求分析 + 设计规划 + 进度管理
- `@tdd-guide` - TDD 开发执行
- `@code-reviewer` - 代码审查

### 1. 任务派发

主 Agent (Lead) 将大任务拆分为子任务，派发给子 Agent：

```
Lead: @planner 分析需求，生成任务列表
      @tdd-guide 实现用户模块
      @tdd-guide 实现认证模块
      @code-reviewer 审查代码
```

### 2. 持续对话 (Resume)

子 Agent 完成后，主 Agent 可以继续派发新任务，保持上下文：

```
主 Agent: @tdd-guide 实现用户认证
子 Agent: 完成用户登录、注册、登出功能

主 Agent: @tdd-guide 再添加验证码功能
子 Agent: 好的，继续...
```

### 3. 进度检查点

大任务分阶段执行，每阶段完成后报告进度：

```
## 进度报告 [3/5]

✅ 完成:
- 用户模型设计
- 数据库迁移

🔄 进行中:
- API 端点实现 (80%)

⏳ 待办:
- 单元测试
- 文档

⚠️ 需要确认:
- 密码加密算法用 bcrypt 还是 scrypt?
```

### 4. 问题确认

子 Agent 遇到关键决策时，主动询问后再继续。

### 5. 结果验证

子 Agent 返回后，主 Agent 进行验证，不通过则反馈重做。

## 最佳实践

1. **任务粒度**：子任务控制在 30 分钟内可完成
2. **主动确认**：关键决策前先问用户/主 Agent
3. **进度透明**：定期报告进度
4. **错误处理**：失败后分析原因，可选择重试或换策略
5. **上下文保持**：相关任务尽量交给同一子 Agent
