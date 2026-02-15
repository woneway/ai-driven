---
description: AI 自主开发入口。接收需求后通过 OpenSpec + Sub-Agent 编排自动完成。
---

# /team

人只说需求，AI 全自动完成。中间不需要人确认，失败自己修。

## 执行步骤

收到需求后按三个阶段执行：

### 阶段一：规划（OpenSpec 驱动）

1. 读取 .cursor/commands/opsx-new.md 并按其指引执行 -- 创建变更目录
2. 读取 .cursor/commands/opsx-ff.md 并按其指引执行 -- 生成 proposal.md、specs/、design.md、tasks.md

### 阶段二：实现（Sub-Agent 驱动）

3. 读取 openspec/changes/<name>/tasks.md 和 design.md
4. 使用 Task tool (subagent_type: tdd-guide) 逐项实现
   - Handoff prompt 必须包含：tasks.md 全文 + design.md 全文 + 目标代码目录
5. 使用 Task tool (subagent_type: code-reviewer) 审查代码
   - Handoff prompt 必须包含：变更文件列表 + design.md 关键决策

### 阶段三：验证与归档（OpenSpec 驱动）

6. 读取 .cursor/commands/opsx-verify.md 并执行
7. 如有问题 -> 回到步骤 4 修复 -> 重新验证（最多 3 轮，超过报告用户）
8. 读取 .cursor/commands/opsx-archive.md 并执行

## Sub-Agent Handoff 格式

调用 Task tool 时的 prompt 必须包含：

    HANDOFF: orchestrator -> <target subagent_type>

    Context: [需求摘要，来自 openspec/changes/<name>/proposal.md]
    Design: [技术方案，来自 openspec/changes/<name>/design.md]
    Tasks: [待实现任务，来自 openspec/changes/<name>/tasks.md]
    Target Dir: [代码目标目录，来自 .space-config 的 CODE_ROOTS_ABS]
    Files: [需要修改的具体文件列表]
    Open Questions: [待确认的问题]

## 错误恢复

- OpenSpec 未初始化: openspec init --tools cursor --yes
- 构建失败: Task tool (subagent_type: build-error-resolver)
- 测试失败: 修复后重跑，NOT 跳过
- verify 发现问题: 回到阶段二修复，最多 3 轮
- opsx-*.md 不存在: openspec init --tools cursor --yes 重新生成

## 备注

- 完整 OpenSpec 命令列表见 .cursor/commands/opsx-*.md
- OpenSpec 命令格式为 /opsx-<id>（短横线，非冒号）
- 阶段二跳过 /opsx-apply，改用 tdd-guide 以强制 TDD 流程
