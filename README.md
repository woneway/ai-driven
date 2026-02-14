# AI-Driven

AI 驱动的自动化研发平台。

## 核心理念

- **简单**：只有一个 `/dev` 命令
- **自动化**：AI 完成全流程
- **可迁移**：使用相对路径，便于项目迁移

## 目录结构

```
ai-driven/
├── config/
│   └── workspaces.yaml          # workspace 列表
│
├── common/                      # 通用资源
│   ├── roles/                  # 6 个角色
│   ├── commands/               # 命令定义
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
        ├── .code-workspace    # 代码仓库配置
        └── .space-config       # workspace 配置
```

## 快速开始

### 1. 创建 workspace

```bash
cd /path/to/ai-driven
./common/bin/init-space.sh poker_space ../york/ios-poker-game
```

注意：代码仓库路径是**相对于 workspace 目录**的相对路径。

### 2. 打开项目

用 Cursor 打开生成的 `.code-workspace` 文件。

### 3. 开始开发

```bash
/dev 做一个锦标赛盲注递增功能
```

## 路径说明

- **代码仓库路径**：相对于 workspace 目录（便于迁移）
- **workspace 配置**：使用相对路径
- **skills symlinks**：使用相对路径

## 开源友好

本项目设计为可自由迁移和分发：
- 无硬编码绝对路径
- 所有路径可配置
- 配置文件自包含
