---
description: AI 驱动开发入口。先设计（SDD），再实现（TDD），确保代码质量和符合业务需求。
---

# /dev 命令 - AI 驱动开发入口

## 概述

`/dev` 是唯一的开发命令。人类只需表达需求，AI 自动完成全流程。

## 完整工作流（强制闭环）

```
用户需求
    ↓
/sdd        规范设计（OpenSpec）
    ↓
/plan       需求分析（ECC planner）
    ↓
/tdd        TDD 实现（ECC tdd-guide）
    ↓
/code-review 代码审查（ECC code-reviewer）
    ↓
/e2e        E2E 测试（ECC e2e-runner）
    ↓
/dev-verify 完成闭环 ← 必须执行！
    ↓
完成
```

**重要**: 每次任务完成后必须执行 `/dev-verify`，这是闭环的最后一步。

## 支持的需求类型

| 类型 | 示例 | 推荐流程 |
|------|------|---------|
| 新功能 | `/dev 做一个锦标赛盲注递增功能` | SDD → TDD → Review |
| Bug 修复 | `/dev 新建档案后数据没清空` | TDD（先写测试复现） |
| 优化 | `/dev 优化排行榜查询性能` | SDD → TDD |
| 调研 | `/dev 调研 WebSocket 连接管理` | 直接执行 |
| 技术债 | `/dev 清理 SwiftLint 警告` | 直接执行 |

## 可用命令（来自全局配置）

| 命令 | 用途 | 配置文件 |
|------|------|---------|
| /plan | 需求分析，制定计划 | ~/.cursor/commands/plan.md |
| /tdd | 测试驱动开发 | ~/.cursor/commands/tdd.md |
| /code-review | 代码审查 | ~/.cursor/commands/code-review.md |
| /e2e | 端到端测试 | ~/.cursor/commands/e2e.md |
| /build-fix | 构建错误修复 | ~/.cursor/commands/build-fix.md |
| /refactor-clean | 死代码清理 | ~/.cursor/commands/refactor-clean.md |
| /test-coverage | 测试覆盖率检查 | ~/.cursor/commands/test-coverage.md |
| /verify | 验证循环 | ~/.cursor/commands/verify.md |

## 可用代理（来自全局配置）

| 代理 | 用途 | 配置文件 |
|------|------|---------|
| planner | 需求分析和计划制定 | ~/.cursor/agents/planner.md |
| tdd-guide | TDD 开发 | ~/.cursor/agents/tdd-guide.md |
| code-reviewer | 代码审查 | ~/.cursor/agents/code-reviewer.md |
| e2e-runner | E2E 测试 | ~/.cursor/agents/e2e-runner.md |
| architect | 架构设计 | ~/.cursor/agents/architect.md |
| security-reviewer | 安全审查 | ~/.cursor/agents/security-reviewer.md |

## 质量门禁（必须通过）

**每次任务完成后必须执行 `/verify`**

### /verify 验证清单

执行 `/verify` 时自动检查：

- [ ] proposal.md 完整（目标、约束、成功标准）
- [ ] design.md 完整（方案选型、架构图、API 设计）
- [ ] TDD 测试存在（先写测试）
- [ ] 测试通过（80%+ 覆盖率）
- [ ] 代码审查通过
- [ ] E2E 测试通过（关键路径）
- [ ] lint 通过
- [ ] **记忆已添加** ← 自动触发

### 为什么需要 /verify

1. **确保质量** - 所有门禁必须通过
2. **自动记忆** - 验证通过后自动调用记忆服务
3. **不可跳过** - 不执行 /verify 视为任务未完成

## 记忆更新

变更完成后自动更新：

- `.roles/lessons.md` - 经验教训
- `.roles/decisions.md` - 架构决策
- `.roles/prefs.md` - 代码偏好
- `.roles/feedback.md` - 反馈给 ai-driven
