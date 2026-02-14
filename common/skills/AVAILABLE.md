# AI-Driven 可用技能

本文档列出 ai-driven 支持的技能。可通过 `npx skills add` 安装。

## 安装

```bash
# 安装 skill
npx skills add <owner/repo> --skill <skill-name>

# 例如
npx skills add avdlee/swiftui-agent-skill --skill swiftui-expert-skill
```

## 按语言/框架分类

### Swift / iOS

| 技能 | 描述 | 安装命令 |
|------|------|---------|
| swiftui-expert-skill | SwiftUI 专家技能（状态管理、性能优化） | `npx skills add avdlee/swiftui-agent-skill --skill swiftui-expert-skill` |
| mobile-ios-design | iOS 设计技能（UI/UX 最佳实践） | `npx skills add wshobson/agents --skill mobile-ios-design` |
| qa-testing-ios | iOS 测试技能（xcodebuild, simctl） | `npx skills add vasilyu1983/ai-agents-public --skill qa-testing-ios` |
| xcode-build-skill | Xcode 构建技能 | `npx skills add pzep1/xcode-build-skill --skill xcode-build` |

### Python

| 技能 | 描述 | 安装命令 |
|------|------|---------|
| python-testing-patterns | Python 测试技能（pytest, mocking） | `npx skills add wshobson/agents --skill python-testing-patterns` |
| python-performance-optimization | Python 性能优化 | `npx skills add wshobson/agents --skill python-performance-optimization` |
| async-python-patterns | Python 异步编程 | `npx skills add wshobson/agents --skill async-python-patterns` |
| python-packaging | Python 包发布 | `npx skills add wshobson/agents --skill python-packaging` |

### Java / Spring

| 技能 | 描述 | 安装命令 |
|------|------|---------|
| java-spring-development | Spring 开发最佳实践 | `npx skills add mindrally/skills --skill java-spring-development` |
| spring-framework | Spring Framework 技能 | `npx skills add mindrally/skills --skill spring-framework` |
| spring-boot-dependency-injection | Spring DI 技能 | `npx skills add giuseppe-trisciuoglio/developer-kit --skill spring-boot-dependency-injection` |
| java-spring-boot | Spring Boot 技能 | `npx skills add pluginagentmarketplace/custom-plugin-java --skill java-spring-boot` |
| java-architect | Java 架构师技能 | `npx skills add jeffallan/claude-skills --skill java-architect` |

### 测试

| 技能 | 描述 | 安装命令 |
|------|------|---------|
| e2e-testing-patterns | 端到端测试 | `npx skills add wshobson/agents --skill e2e-testing-patterns` |
| webapp-testing | Web 应用测试 | `npx skills add anthropics/skills --skill webapp-testing` |
| javascript-testing-patterns | JavaScript 测试 | `npx skills add wshobson/agents --skill javascript-testing-patterns` |

### 通用

| 技能 | 描述 | 安装命令 |
|------|------|---------|
| modern-javascript-patterns | 现代 JavaScript | `npx skills add wshobson/agents --skill modern-javascript-patterns` |

---

## 使用方式

安装后，在 AI 中使用：

```
我需要写一个 SwiftUI 应用，请使用 swiftui-expert-skill
我需要优化 Python 代码性能，请使用 python-performance-optimization
```

---

## 推荐安装

根据你的需求，推荐安装：

```bash
# Swift / iOS
npx skills add avdlee/swiftui-agent-skill --skill swiftui-expert-skill
npx skills add wshobson/agents --skill mobile-ios-design

# Python
npx skills add wshobson/agents --skill python-testing-patterns

# Java
npx skills add mindrally/skills --skill java-spring-development

# 测试
npx skills add wshobson/agents --skill e2e-testing-patterns
```

---

## 更多技能

浏览完整列表：https://skills.sh/
