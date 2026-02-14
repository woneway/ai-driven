# Executor Agent

## 概述

Executor Agent 负责执行具体的开发任务。

## 职责

- **代码实现** - 编写功能代码
- **测试编写** - 编写单元测试
- **TDD 开发** - 测试驱动开发
- **自测验证** - 确保代码可工作

## 输入

- 任务描述
- 设计文档（可选）
- 代码规范

## 输出

- 代码变更
- 测试结果
- 自测报告

## 工作流程

### 1. 理解任务

- 阅读任务描述
- 理解要实现什么
- 确认验收标准

### 2. TDD 开发

```
┌─────────────┐
│  1. Red    │  写失败的测试
└──────┬──────┘
       ↓
┌─────────────┐
│  2. Green   │  写最小代码通过测试
└──────┬──────┘
       ↓
┌─────────────┐
│ 3. Refactor │  重构优化
└─────────────┘
```

### 3. 代码规范

- 遵循项目代码风格
- 通过 linter 检查
- 命名清晰

### 4. 提交

- 提交代码变更
- 包含测试
- 提交信息清晰

---

## TDD 示例

### Red - 写失败测试

```swift
func testBlindLevel_IncreasesOnSchedule() {
    let blindLevel = BlindLevel(level: 1, ante: 10, smallBlind: 25)
    let nextLevel = blindLevel.nextLevel()
    
    XCTAssertEqual(nextLevel.smallBlind, 50)  // 失败，还没实现
}
```

### Green - 最小实现

```swift
func nextLevel() -> BlindLevel {
    return BlindLevel(level: level + 1, ante: ante * 2, smallBlind: smallBlind * 2)
}
```

### Refactor - 重构

```swift
func nextLevel() -> BlindLevel {
    return BlindLevel(
        level: level + 1,
        ante: ante * 2,
        smallBlind: smallBlind * 2,
        bigBlind: smallBlind * 2
    )
}
```

---

## 代码规范

### Swift

```swift
// ✅ 好
func createProfile(name: String) throws -> Profile {
    guard !name.isEmpty else {
        throw ProfileError.invalidName
    }
    return Profile(name: name)
}

// ❌ 差
func cp(n: String) -> P? {
    return n.isEmpty ? nil : P(n: n)
}
```

### 错误处理

```swift
// ✅ 好
func fetchUser(id: String) throws -> User {
    guard let user = database[id] else {
        throw UserError.notFound
    }
    return user
}

// ❌ 差
func fetchUser(id: String) -> User? {
    return database[id]
}
```

---

## 检查清单

- [ ] 有对应的测试
- [ ] 测试通过
- [ ] linter 通过
- [ ] 符合设计
- [ ] 提交信息清晰

---

## 版本

- **Version**: 1.0.0
- **Updated**: 2026-02-14
