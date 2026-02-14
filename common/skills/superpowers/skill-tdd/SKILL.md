# TDD Skill

## 概述

测试驱动开发技能。

## 何时使用

- 实现新功能
- 修复 Bug
- 重构代码

## TDD 循环

```
┌─────────────┐
│  1. Red    │  写一个失败的测试
└──────┬──────┘
       ↓
┌─────────────┐
│  2. Green   │  写最少的代码让测试通过
└──────┬──────┘
       ↓
┌─────────────┐
│ 3. Refactor │  重构代码
└─────────────┘
```

## 执行步骤

### 1. Red - 写失败的测试

```swift
func testAdd_ReturnsSum() {
    let calculator = Calculator()
    let result = calculator.add(2, 3)
    XCTAssertEqual(result, 5)  // 测试失败，因为还没实现
}
```

### 2. Green - 写最小实现

```swift
func add(_ a: Int, _ b: Int) -> Int {
    return 5  // 最小的实现，让测试通过
}
```

### 3. Refactor - 重构

```swift
func add(_ a: Int, _ b: Int) -> Int {
    return a + b  // 正确的实现
}
```

## 原则

- **测试先行**
- **小步前进**
- **快速反馈**
- **保持简洁**

## 测试结构

```swift
class FeatureTests: XCTestCase {
    
    // Arrange - 准备
    var subject: Subject!
    
    override func setUp() {
        subject = Subject()
    }
    
    // Act - 执行
    func testScenario_ExpectedBehavior() {
        let result = subject.action()
        
        // Assert - 验证
        XCTAssertEqual(result, expected)
    }
}
```

## 常见模式

| 模式 | 说明 |
|------|------|
| Given-When-Then | 场景-行为-结果 |
| One-Assertion | 每个测试一个断言 |
| AAA | Arrange-Act-Assert |
