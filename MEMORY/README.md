# 项目记忆模板

## 概述

项目记忆是 AI 学习的基础，包含经验教训、架构决策和代码偏好。

## 目录结构

```
MEMORY/
├── roles/
│   ├── decisions.md      # 架构决策
│   ├── lessons.md        # 经验教训
│   └── prefs.md         # 代码偏好
│
└── templates/
    ├── decision.template.md
    ├── lesson.template.md
    └── pref.template.md
```

---

## decisions.md - 架构决策

### 格式

```markdown
### [日期] {决策标题}

**背景**: 为什么需要做这个决策

**决策**: 选择了什么方案

**理由**: 为什么选择这个方案

**影响**: 这个决策对后续的影响
```

### 示例

```markdown
### [2026-02-14] 使用 URLSessionWebSocketTask

**背景**: 需要实现 WebSocket 连接

**决策**: 使用 URLSessionWebSocketTask 而非第三方库

**理由**:
1. 官方支持，长期维护
2. 足够满足需求
3. 无额外依赖

**影响**: 后续 WebSocket 相关功能都基于此实现
```

---

## lessons.md - 经验教训

### 格式

```markdown
### [日期] {经验标题}

**场景**: 在什么情况下遇到

**问题**: 具体是什么问题

**解决**: 如何解决

**教训**: 以后如何避免
```

### 示例

```markdown
### [2026-02-14] 盲注递增需考虑边界

**场景**: 实现锦标赛盲注递增功能

**问题**: 没有限制最大层级，导致无限递增

**解决**: 添加 maxLevel 检查，超过返回 nil

**教训**: 数值相关功能需要考虑边界值
```

---

## prefs.md - 代码偏好

### 格式

```markdown
### [日期] {场景}: {偏好描述}

**场景**: 适用于什么场景

**约定**: 具体的代码风格或模式

**示例**:
```swift
// ✅ 正确
let initialAnte = 10

// ❌ 错误
let v = 10
```
```

### 示例

```markdown
### [2026-02-14] Swift 命名规范

**场景**: 变量和函数命名

**约定**: 使用描述性名称，避免缩写

**示例**:
```swift
// ✅ 正确
func createProfile(name: String) -> Profile

// ❌ 错误
func cp(n: String) -> P
```
```

---

## 版本

- **Version**: 1.0.0
- **Updated**: 2026-02-14
