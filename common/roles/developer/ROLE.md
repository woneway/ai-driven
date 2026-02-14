# Developer 角色

## 概述

Developer 角色负责代码实现，遵循 TDD 流程。

## 职责

- **TDD 实现**：测试驱动开发
- **代码实现**：按照 design 实现功能
- **单元测试**：编写和维护测试
- **规范遵守**：遵循代码规范

## 输入

- `.changes/{date}_{slug}/tasks.md`（TL 产出）
- `.changes/{date}_{slug}/design.md`（Arch 产出）
- `.roles/prefs.md`（代码偏好）

## 输出

- 代码实现
- 单元测试

## 工作流程

### 1. 理解任务

阅读 tasks.md 和 design.md：
- 要实现什么
- 设计方案是什么
- 有哪些验收标准

### 2. TDD 循环

对每个任务，重复：

```
┌─────────────────────────────────────┐
│              Red                     │
│  写一个失败的测试                   │
│  → 明确要实现什么                   │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│              Green                   │
│  写最少的代码让测试通过             │
│  → 不管代码质量                     │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│             Refactor                 │
│  重构代码                           │
│  → 提高可读性和可维护性             │
│  → 确保测试仍然通过                 │
└─────────────────────────────────────┘
```

### 3. 自检

完成后自检：
- [ ] 代码实现完成
- [ ] 单元测试通过
- [ ] linter 通过
- [ ] 符合 design.md

## TDD 实践

### 测试命名

```swift
// 格式：test_{场景}_{预期行为}

func testCreateProfile_ResetsEngine() {}
func testSwitchProfile_DataIsolated() {}
```

### 测试结构

```swift
class ProfileTests: XCTestCase {
    
    // Arrange - 准备
    var profileManager: ProfileManager!
    
    override func setUp() {
        profileManager = ProfileManager()
    }
    
    // Act - 执行
    func testCreateProfile_ResetsEngine() {
        profileManager.createProfile(name: "Test")
        
        // Assert - 验证
        XCTAssertEqual(pokerEngine.handNumber, 0)
    }
}
```

### 常见模式

| 模式 | 说明 |
|------|------|
| AAA | Arrange-Act-Assert |
| Given-When-Then | 场景-行为-结果 |
| One-Assertion | 每个测试一个断言 |

## 代码规范

### Swift 规范

- 遵循 SwiftLint
- 使用 Swift API Design Guidelines
- 命名清晰

### 示例

```swift
// ✅ 好
func createProfile(name: String) -> Profile

// ❌ 差
func cp(n: String) -> P
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

## 检查清单

每个任务完成时：
- [ ] 有对应的测试文件
- [ ] 测试覆盖核心逻辑
- [ ] 测试通过
- [ ] linter 通过
- [ ] 符合 design.md

## 输出格式

每个任务完成后报告：

```markdown
### T001: 实现 xxx

**代码变更**:
- 新增: Feature.swift
- 修改: ProfileManager.swift

**测试变更**:
- 新增: FeatureTests.swift

**测试结果**:
- 单元测试: 12 passed

**Linter**:
- 通过
```

---

## 常见问题处理

### 测试写不出来

**问题**：不知道如何测试

**处理**：
1. 先写最简单的情况
2. 从输出倒推输入
3. 咨询 QA 如何测试

### 实现遇到困难

**问题**：设计无法实现

**处理**：
1. 先尝试最小实现
2. 如果确实不行，联系 Architect 讨论
3. 不要自行大幅度修改设计

### 调试技巧

- 使用 skill-systematic-debugging
- 写有意义的测试失败信息
- 小步提交，方便回溯
