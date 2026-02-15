# AI-Driven

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**AI 自主开发，人只验收结果。**

一个让 AI 能够自主完成全栈开发的框架，人只需要表达需求，AI 会自动完成设计、开发、测试和部署。

## 目标

```
人: /team 做一个用户认证
AI: → 自动完成全部开发 → 完成
```

## 特性

- 🤖 **AI 全自主** - 从需求到交付全程自动化
- 👤 **人只验收** - 无需参与开发过程，只看结果
- 🔄 **自迭代** - 完成后自动总结经验，持续优化
- 🛠️ **开箱即用** - 几分钟内启动第一个 AI 开发项目

## 原则

- 人只说需求
- AI 全自动
- 失败自己修
- 完成后自迭代

## 快速开始

### 前置要求

- macOS / Linux
- Cursor IDE (或 VSCode + Claude Code)
- Git

### 安装

```bash
# 克隆项目
git clone https://github.com/yourusername/ai-driven.git
cd ai-driven

# 创建第一个 workspace
./bin/init-space.sh my_workspace ../ai-projects/my-project
```

### 使用

1. 双击打开生成的 `my_workspace.code-workspace`
2. 在 Cursor 中输入需求：

```
/team 做一个锦标赛功能
```

3. AI 会自动完成全部开发

## 目录结构

```
ai-driven/
├── bin/
│   └── init-space.sh          # 创建新 workspace
├── common/
│   └── workspace-template/    # 工作空间模板
├── workspaces/                # 所有工作空间
├── .cursor/
│   ├── commands/              # 全局命令
│   ├── rules/                 # AI 行为规则
│   └── skills/                # 技能库
└── README.md
```

## 核心命令

| 命令 | 说明 |
|------|------|
| `/team <需求>` | 让 AI 完成一个开发任务 |
| `/team:review` | AI 自审代码质量 |
| `/team:test` | 运行测试 |

## 参考

- [OpenSpec](https://openspec.dev/)
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code)

## 许可证

本项目基于 [MIT](LICENSE) 许可证开源。

## 鸣谢

- [Cursor IDE](https://cursor.sh/) - AI 增强的代码编辑器
- [Claude Code](https://claude.com/claude-code) - AI 编程助手

---

**愿景：让 AI 成为真正的开发者，人做真正的产品经理。**
