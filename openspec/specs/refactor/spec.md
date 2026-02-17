# refactor Specification

## Purpose
TBD - created by archiving change ai-driven-refactor. Update Purpose after archive.
## Requirements
### Requirement: 工作区配置读取

系统 SHALL 在脚本执行时自动读取工作区 `.workspace.env` 文件，并允许覆盖全局配置。

#### Scenario: 工作区配置覆盖全局
- **WHEN** 工作区 `.workspace.env` 中设置了 `HOOK_ENABLED=false`
- **THEN** 钩子脚本应读取该配置并禁用钩子

#### Scenario: 全局配置作为默认值
- **WHEN** 工作区 `.workspace.env` 中未设置 `NOTIFY_MIN_DURATION`
- **THEN** 应使用全局 `.workspace.env` 中的默认值

#### Scenario: 环境变量优先级最高
- **WHEN** 系统中设置了环境变量 `HOOK_ENABLED`
- **THEN** 环境变量应覆盖所有配置文件

### Requirement: 同步机制改进

系统 SHALL 在同步框架文件前备份用户已修改的文件。

#### Scenario: 用户修改被备份
- **WHEN** `sync-space.sh` 检测到用户修改了 `team.md`
- **THEN** 应创建 `team.md.bak` 备份文件

#### Scenario: 同步后提示用户检查
- **WHEN** 同步完成且存在备份文件
- **THEN** 应向用户显示提示信息，说明需要检查备份文件

### Requirement: 路径推导强化

系统 SHALL 提供明确的错误信息，当无法确定关键路径时。

#### Scenario: AI_DRIVEN_ROOT 无法推导
- **WHEN** 脚本无法通过目录层级推导 `AI_DRIVEN_ROOT`
- **THEN** 应显示明确的错误信息，提示用户设置环境变量

#### Scenario: 配置文件缺失
- **WHEN** 引用的配置文件不存在
- **THEN** 应显示警告而非静默失败

