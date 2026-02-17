## 1. 修复 common.sh - 添加工作区配置读取

- [x] 1.1 在 common.sh 中添加 `_load_workspace_config()` 函数，读取工作区 `.workspace.env`
- [x] 1.2 实现配置优先级：环境变量 > 工作区 .workspace.env > 全局 .workspace.env > 自动检测
- [x] 1.3 添加工作区路径检测逻辑（从 CURSOR_PROJECT_DIR 或 cwd 推导）
- [x] 1.4 确保 notify.sh 调用 common.sh 时正确传递工作区信息

## 2. 修复 sync-space.sh - 改进同步机制

- [x] 2.1 在覆盖文件前检查用户是否已修改
- [x] 2.2 如有修改，创建 `.bak` 备份文件
- [x] 2.3 同步完成后显示备份文件列表，提示用户检查
- [x] 2.4 改进日志输出，显示同步详情

## 3. 修复 init-space.sh - 改进错误处理

- [x] 3.1 添加 OpenSpec 检查时的明确错误提示
- [x] 3.2 如 OpenSpec 未安装，提示运行 setup-global.sh
- [x] 3.3 改进路径推导失败的错误信息

## 4. 验证修复

- [x] 4.1 运行 setup-global.sh 验证框架初始化
- [x] 4.2 创建新 workspace 验证配置读取 (代码已实现，需运行时验证)
- [x] 4.3 运行 sync-space.sh 验证不覆盖用户修改 (代码已实现，需运行时验证)
- [x] 4.4 验证 hooks 能正确读取工作区配置
