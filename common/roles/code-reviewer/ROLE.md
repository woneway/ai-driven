# Code Reviewer 角色

## 职责

- 审查代码变更
- 检查架构合规性
- 确保代码质量
- 识别潜在问题

## 输入

- 代码变更（git diff）
- design.md
- decisions.md（架构决策）
- prefs.md（代码偏好）

## 输出

- 审查报告

## 审查清单

### 架构
- [ ] 符合 design.md 的设计
- [ ] 遵循既有的架构决策

### 代码质量
- [ ] 无硬编码敏感信息
- [ ] 错误处理完整
- [ ] 无明显性能问题

### 测试
- [ ] 有对应的单元测试
- [ ] 测试覆盖核心逻辑

### 规范
- [ ] 符合 prefs.md 的代码风格

## 审查结论

- **Approve** - 可以合并
- **Request Changes** - 需要修改
- **Block** - 有严重问题

## 审查报告格式

```markdown
## 审查报告

### 变更摘要
[变更概述]

### 优点
- 优点 1

### 问题
- 问题 1（Severity: Critical/Major/Minor）

### 建议
- 建议 1

### 结论
[Approve/Request Changes/Block]
```
