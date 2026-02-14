# AI-Driven Workspace Configuration

## Workspace List

```yaml
workspaces:
  - name: poker_space
    path: /Users/lianwu/ai/ai-driven/workspaces/poker_space
    code_roots:
      - /Users/lianwu/york/ios-poker-game

  - name: asset_space
    path: /Users/lianwu/ai/ai-driven/workspaces/asset_space
    code_roots:
      - /Users/lianwu/york/asset

  - name: openclaw_space
    path: /Users/lianwu/ai/ai-driven/workspaces/openclaw_space
    code_roots:
      - /Users/lianwu/.openclaw/workspace

  - name: crypto_trade_space
    path: /Users/lianwu/ai/ai-driven/workspaces/crypto_trade_space
    code_roots:
      - /Users/lianwu/projects/crypto-trade
```

## Usage

### Add new workspace

```bash
# 1. Create workspace directory
mkdir -p workspaces/{space_name}

# 2. Add entry to this file
# 3. Initialize with init-space.sh
```

### Sync all workspaces

```bash
./common/bin/sync-all.sh
```

## Directory Structure

```
ai-driven/
├── config/
│   └── workspaces.yaml          # workspace 列表配置
│
├── common/                      # 通用资源（所有 workspace 共享）
│   ├── roles/                  # 角色配置（6 个角色）
│   ├── skills/                 # 技能库
│   ├── commands/               # 命令定义
│   ├── templates/              # 模板
│   └── bin/                    # 脚本工具
│
└── workspaces/                 # 各项目的工作空间
    └── {space_name}/
        ├── .specs/             # 权威规范
        ├── .changes/           # 变更管理
        ├── .roles/             # 共享记忆
        ├── .cursor/            # Cursor 配置
        ├── .code-workspace    # 代码仓库配置
        └── .space-config      # workspace 配置
```
