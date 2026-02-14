# AI-Driven

AI 驱动的自动化研发平台。

## 核心理念

```
人类：表达需求（"做一个锦标赛功能"）
AI：自动完成（需求分析 → 设计 → 开发 → 测试 → 归档）
```

## 特点

- **简单**：只有一个 `/dev` 命令
- **自动化**：AI 子 Agent 调度完成全流程
- **SDD + TDD**：规范驱动 + 测试驱动
- **可迁移**：相对路径，开源友好

## 目录结构

```
ai-driven/
├── config/
│   └── workspaces.yaml          # ai-driven 管理的 workspace 列表
│
├── common/                      # 通用资源（所有 workspace 共享）
│   ├── roles/                  # 6 个角色定义
│   ├── commands/               # 命令定义（/dev）
│   ├── rules/                  # 规则模板
│   ├── templates/              # 文档模板
│   ├── skills/                 # 技能库
│   └── bin/                    # 脚本工具
│
└── workspaces/                 # 项目工作空间
    └── {space_name}/
        ├── .specs/             # 权威规范
        ├── .changes/           # 变更管理
        ├── .roles/             # 共享记忆
        ├── .cursor/            # Cursor 配置
        ├── .space-config       # workspace 配置（核心！）
        └── .gitignore
```

## `.space-config` - 核心配置

每个 workspace 的核心配置文件：

```bash
# workspace 名称
SPACE_NAME=poker_space

# 代码仓库列表（相对于 workspace 目录的路径）
CODE_ROOTS=../york/ios-poker-game

# 使用的语言/技术栈（用于选择合适的技能）
LANGUAGES=swift,objective-c

# 特殊配置（如有）
# TEST_COMMAND=swift test
# LINT_COMMAND=swiftlint
```

### 为什么用 `.space-config` 而不是 `.code-workspace`？

| 配置 | 作用 | 工具 |
|------|------|------|
| `.space-config` | workspace 元信息（ai-driven 专用） | ai-driven |
| `.code-workspace` | Cursor 多文件夹打开 | Cursor |

- `.space-config` 是 **ai-driven 的配置**
- `.code-workspace` 是 **Cursor 的配置**
- 两者配合使用

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/woneway/ai-driven.git
cd ai-driven
```

### 2. 创建 workspace

```bash
# 单代码仓库
./common/bin/init-space.sh poker_space ../ios-poker-game

# 多代码仓库
./common/bin/init-space.sh myapp ../frontend ../backend
```

### 3. 打开项目

```bash
# 用 Cursor 打开 .code-workspace 文件
open workspaces/poker_space/poker_space.code-workspace
```

### 4. 开始开发

```
/dev 做一个锦标赛盲注递增功能
```

## `/dev` 命令 - 唯一开发入口

### 支持的需求类型

| 类型 | 示例 |
|------|------|
| 新功能 | `/dev 做一个锦标赛盲注递增功能` |
| Bug 修复 | `/dev 新建档案后数据没清空` |
| 优化 | `/dev 优化排行榜查询性能` |
| 调研 | `/dev 调研 WebSocket 连接管理` |
| 技术债 | `/dev 清理 SwiftLint 警告` |

### AI 执行流程

```
1. 理解需求 → 创建 .changes/{date}_{slug}/proposal.md
                ↓
2. 技术设计 → 创建 design.md
                ↓
3. 任务拆解 → 创建 tasks.md
                ↓
4. 调度子 Agent 实现
   - Developer: 代码 + 单元测试
   - CodeReviewer: 代码审查
                ↓
5. QA: 集成测试
                ↓
6. 归档 → 合并到 .specs/ + 更新 .roles/
```

### 子 Agent 调度

`/dev` 命令会根据任务类型调度不同的子 Agent：

| 阶段 | 调用的角色 | 职责 |
|------|-----------|------|
| 需求分析 | ProductManager | 理解需求，定义成功标准 |
| 技术设计 | Architect | 设计技术方案 |
| 任务拆解 | TechLead | 拆解为可执行任务 |
| 编码实现 | Developer | TDD 开发 + 单元测试 |
| 代码审查 | CodeReviewer | 质量把关 |
| 集成测试 | QA Engineer | 验证功能 |

## 变更管理

### `.changes/` - 进行中的变更

```
.changes/
└── 20260214_tournament-blind/
    ├── proposal.md    # 为什么做
    ├── design.md      # 技术设计
    └── tasks.md       # 实施任务
```

### `.specs/` - 权威规范（系统当前状态）

```
.specs/
├── auth/
│   └── spec.md        # 认证模块规范
├── profile/
│   └── spec.md        # 档案模块规范
└── ...
```

### 归档流程

变更完成后：
1. 将变更内容合并到 `.specs/` 对应的 domain
2. 从 `.changes/` 移除（或标记为 done）
3. 自动更新 `.roles/` 记忆

## 项目记忆

### `.roles/` - AI 学习来源

| 文件 | 内容 | 谁会读 |
|------|------|--------|
| decisions.md | 架构决策 | Architect, CR |
| lessons.md | 经验教训 | Dev, TL |
| prefs.md | 代码偏好 | Dev, CR |
| feedback.md | 反馈给 ai-driven | ai-driven |

### 自动反馈机制

**AI 在开发过程中会自动识别并记录**：
- 遇到的问题和解决方案 → lessons.md
- 新的架构决策 → decisions.md
- 代码风格发现 → prefs.md
- 需要通用化的能力 → feedback.md

### feedback.md 格式

```markdown
# 反馈给 AI-Driven

## 需要添加的能力
- [日期] 需要 iOS 特有的调试技能
- [日期] 需要更好的 Swift 测试技能

## 建议
- 考虑添加自动生成文档的技能
```

ai-driven 会定期读取所有 workspace 的 feedback.md 并升级。

## 质量保障

AI 自我门禁检查：
- [ ] proposal.md 有"为什么做"和"影响范围"
- [ ] design.md 有"核心流程"和"错误处理"
- [ ] tasks.md 有可执行的任务列表
- [ ] 代码有对应的测试
- [ ] 测试通过
- [ ] linter 通过

## 迁移说明

所有路径使用相对路径，便于项目迁移：

- 代码仓库路径：相对于 workspace 目录
- workspace 配置：相对于 ai-driven 根目录
- skills symlinks：使用相对路径

## 贡献

欢迎提交 Issue 和 PR！

## 许可证

MIT
