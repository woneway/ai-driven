# `/dev` 命令 - AI 驱动开发入口

## 概述

`/dev` 是唯一的开发命令。人类只需表达需求，AI 自动完成全流程。

## 用法

```
/dev <需求描述>
```

### 支持的需求类型

| 类型 | 示例 |
|------|------|
| 新功能 | `/dev 做一个锦标赛盲注递增功能` |
| Bug 修复 | `/dev 新建档案后数据没清空` |
| 优化 | `/dev 优化排行榜查询性能` |
| 调研 | `/dev 调研 WebSocket 连接管理` |
| 技术债 | `/dev 清理 SwiftLint 警告` |

## 执行流程

```
┌─────────────────────────────────────────────────────────────┐
│                    Phase 1: 理解需求                         │
│                                                             │
│  - 分析需求类型                                             │
│  - 识别涉及的代码仓库                                       │
│  - 读取 .space-config 获取配置                               │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Phase 2: 创建变更                         │
│                                                             │
│  创建 .changes/{date}_{slug}/                               │
│  ├── proposal.md   # 为什么做、影响范围、成功标准           │
│  ├── design.md     # 技术方案                               │
│  └── tasks.md      # 实施任务                               │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Phase 3: 调度子 Agent                    │
│                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │ Developer │ → │ Code     │ → │ QA       │             │
│  │          │    │ Reviewer │    │ Engineer │             │
│  └──────────┘    └──────────┘    └──────────┘             │
│                                                             │
│  对每个任务:                                                │
│  1. 调度 Developer 子 Agent 实现                            │
│  2. 调度 CodeReviewer 子 Agent 审查                        │
│  3. 修复问题（如果有）                                     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Phase 4: 完成                            │
│                                                             │
│  - 集成测试                                                 │
│  - 归档到 .specs/                                          │
│  - 更新 .roles/ 记忆                                        │
│  - 识别并记录反馈到 feedback.md                            │
└─────────────────────────────────────────────────────────────┘
```

## 子 Agent 调度机制

### 读取配置

首先读取 `.space-config`：

```bash
SPACE_NAME=poker_space
CODE_ROOTS=../york/ios-poker-game
# LANGUAGES=swift,objective-c
```

### 角色定义

| 角色 | 子 Agent 类型 | 职责 |
|------|--------------|------|
| ProductManager | generalPurpose | 需求分析，定义成功标准 |
| Architect | generalPurpose | 技术设计 |
| TechLead | generalPurpose | 任务拆解 |
| Developer | generalPurpose | TDD 开发 |
| CodeReviewer | generalPurpose | 代码审查 |
| QAEngineer | generalPurpose | 集成测试 |

### Task tool 调用模板

```python
Task(
    description="[角色] 执行: [任务]",
    subagent_type="generalPurpose",
    prompt="""
        # 角色
        [读取 roles/[角色]/ROLE.md]
        
        # 项目上下文
        [读取 .space-config]
        
        # 代码仓库
        - 代码根目录: [从 CODE_ROOTS 获取]
        
        # 任务
        [具体任务描述]
        
        # 输出要求
        [根据角色定义的输出格式]
    """
)
```

## 变更创建

### 目录结构

```
.changes/{date}_{slug}/
├── proposal.md    # 为什么做
├── design.md      # 技术设计
└── tasks.md       # 实施任务
```

### proposal.md

```markdown
# {功能名}

## 为什么做
[背景和动机]

## 影响范围
- 涉及的模块:
- 风险评估: 低/中/高

## 成功标准
- [ ] 标准 1
- [ ] 标准 2

## 非目标
- 不做 XXX
```

### design.md

```markdown
# 技术设计

## 核心流程
[用 Mermaid 或文字描述]

## 数据模型
[新增/修改的数据结构]

## 接口设计
[新增/修改的接口]

## 错误处理
[错误处理策略]

## 测试策略
[测试计划]
```

### tasks.md

```markdown
# 实施任务

## 阶段 1: 基础

- [ ] T001: 任务描述
- [ ] T002: 任务描述

## 阶段 2: 核心

- [ ] T003: 任务描述
```

## 质量门禁

AI 自我检查清单（每个阶段必须验证）：

### PM 阶段
- [ ] proposal.md 有"为什么做"
- [ ] proposal.md 有"影响范围"
- [ ] proposal.md 有"成功标准"（至少 1 条）

### Arch 阶段
- [ ] design.md 有"核心流程"
- [ ] design.md 有"数据模型"
- [ ] design.md 有"错误处理"
- [ ] design.md 有"测试策略"

### Dev 阶段
- [ ] 代码有对应的测试文件
- [ ] 测试通过
- [ ] linter 通过
- [ ] 代码符合 design.md

### CR 阶段
- [ ] 无 Critical 问题
- [ ] 架构合规
- [ ] 代码风格符合

### QA 阶段
- [ ] 集成测试通过
- [ ] 无回归问题

## 记忆更新

变更完成后，AI 自动：

### 1. 提取经验 → `.roles/lessons.md`

```markdown
- [日期] {功能}: {一句话经验}
```

### 2. 记录决策 → `.roles/decisions.md`

```markdown
- [日期] {功能}: {决策内容}
```

### 3. 更新偏好 → `.roles/prefs.md`

```markdown
- [日期] {场景}: {偏好内容}
```

### 4. 自动反馈 → `.roles/feedback.md`

AI 在开发过程中识别到需要通用化的能力时，自动记录：

```markdown
- [日期] 需要添加 {能力描述}
```

## 辅助命令

### `/dev:status`

查看当前变更进度：

```markdown
## 当前变更: 20260214_tournament-blind

### 进度
- [x] proposal.md
- [x] design.md
- [x] tasks.md
- [ ] T001: BlindLevel 模型
- [ ] T002: 盲注递增逻辑

### 阻塞
- 无
```

### `/dev:review`

请求人工代码审查（可选）。

## 错误处理

如果执行过程中遇到问题：

1. **任务失败** → 分析原因 → 重试或调整
2. **需要澄清** → 询问人类
3. **阻塞** → 报告阻塞点

## 输出格式

`/dev` 命令完成后的输出：

```markdown
═══ 完成 ═══

✅ 变更: 20260214_tournament-blind

📝 产出:
  - .changes/20260214_tournament-blind/proposal.md
  - .changes/20260214_tournament-blind/design.md
  - .changes/20260214_tournament-blind/tasks.md

🔧 实现:
  - T001: BlindLevel.swift ✓
  - T002: BlindLevelTests.swift ✓
  - ...

🧪 测试:
  - 单元测试: 15 passed
  - 集成测试: 3 passed

📚 记忆更新:
  - lessons.md: +2
  - decisions.md: +1
  - feedback.md: +0
```
