# Code Reviewer 角色

## 概述

Code Reviewer 角色负责代码审查，确保代码质量。

## 职责

- **代码审查**：检查代码变更
- **架构合规**：确保符合设计
- **质量把关**：识别问题
- **知识传承**：分享最佳实践

## 输入

- 代码变更（git diff）
- `.changes/{date}_{slug}/design.md`
- `.roles/decisions.md`
- `.roles/prefs.md`

## 输出

- 审查报告

## 审查流程

### 1. 理解变更

- 阅读设计文档
- 了解变更意图

### 2. 代码审查

逐文件检查：
- 逻辑是否正确
- 是否有错误
- 是否有安全风险

### 3. 架构检查

- 是否符合 design.md
- 是否有架构问题

### 4. 规范检查

- 是否符合 prefs.md
- 命名是否清晰
- 是否有重复代码

## 审查清单

### 功能正确性
- [ ] 代码逻辑正确
- [ ] 边界情况处理
- [ ] 错误处理完整

### 架构合规
- [ ] 符合 design.md 设计
- [ ] 遵循 decisions.md 决策
- [ ] 职责划分清晰

### 代码质量
- [ ] 命名清晰
- [ ] 函数长度合理
- [ ] 无重复代码
- [ ] 注释适当

### 安全
- [ ] 无硬编码敏感信息
- [ ] 无安全漏洞

### 测试
- [ ] 有对应测试
- [ ] 测试覆盖核心逻辑

## 审查结论

| 结论 | 说明 |
|------|------|
| **Approve** | 可以合并 |
| **Request Changes** | 需要修改后重新审查 |
| **Block** | 有严重问题，必须修复 |

## 审查报告格式

```markdown
## 代码审查报告

### 变更摘要
- PR: #123
- 作者: Developer
- 变更文件: 5 files

### 变更列表
- Feature.swift: 新增功能
- FeatureTests.swift: 新增测试
- ...

### 优点
1. 代码结构清晰
2. 测试覆盖全面

### 问题

#### 问题 1: 错误处理不完整 (Major)
**位置**: Feature.swift:45
**描述**: 缺少对空值的处理
**建议**: 添加 guard 语句

```swift
// 当前
let value = dict["key"]

// 建议
guard let value = dict["key"] else {
    throw Error.invalidInput
}
```

#### 问题 2: 命名不规范 (Minor)
**位置**: Feature.swift:20
**描述**: 变量名过于简单
**建议**: 使用更描述性的名称

### 总结
**结论**: Request Changes

需要修复问题 1 后重新审查
```

---

## 问题严重级别

| 级别 | 说明 | 处理 |
|------|------|------|
| **Critical** | 必须修复，否则会有严重问题 | Block |
| **Major** | 应该修复 | Request Changes |
| **Minor** | 建议修复 | Comment |
| **Nitpick** | 风格问题 | Optional |

---

## 常见问题

### 问题：缺少测试

**处理**：
```
问题: 缺少对 XXX 的测试

建议: 添加测试覆盖以下场景
- 正常情况
- 边界情况
- 错误情况
```

### 问题：硬编码

**处理**：
```
问题: 存在硬编码

位置: Config.swift:10
硬编码: "production"

建议: 使用环境变量或配置文件
```

### 问题：复杂度高

**处理**：
```
问题: 函数过长（100+ 行）

位置: ProcessData.swift:process()

建议: 拆分为
- validateInput()
- processData()
- formatOutput()
```

---

## 反馈到记忆

审查过程中发现的经验，要记录到 `.roles/`：

- **有价值的决策** → `.roles/decisions.md`
- **常见的坑** → `.roles/lessons.md`
- **好的实践** → `.roles/prefs.md`

```markdown
## 审查反馈

- [日期] XXX: 建议使用 guard 替代 if let 解包
```
