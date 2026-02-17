---
name: prompt-engineering-patterns
description: 高级 Prompt 工程模式，最大化 LLM 性能、可靠性和可控性。适用于设计复杂 prompt、优化性能、实现结构化输出。
---

# Prompt Engineering Patterns

掌握高级 prompt 工程技巧，提升 LLM 表现、可靠性和可控性。

## 触发条件

当用户需要以下场景时激活此 skill：

- 为生产级 LLM 应用设计复杂 prompt
- 优化 prompt 性能和一致性
- 实现结构化推理模式（chain-of-thought、tree-of-thought）
- 构建少样本学习系统
- 创建可复用的 prompt 模板
- 调试和优化不稳定的 prompt 输出
- 实现专业化 AI 助手
- 使用结构化输出（JSON mode）

## 核心技巧

### 1. 少样本学习 (Few-Shot Learning)

- 示例选择策略（语义相似性、多样性采样）
- 平衡示例数量与上下文窗口限制
- 构建有效的输入-输出对演示
- 动态从知识库检索示例
- 通过战略性示例选择处理边缘案例

### 2. 思维链提示 (Chain-of-Thought)

- 逐步推理引导
- 零样本 CoT（"Let's think step by step"）
- 少样本 CoT（带推理轨迹）
- 自一致性技术（采样多个推理路径）
- 验证和确认步骤

### 3. 结构化输出

- JSON 模式可靠解析
- Pydantic schema 强制
- 类型安全响应处理
- 格式错误输出的错误处理

### 4. Prompt 优化

- 迭代优化工作流
- A/B 测试 prompt 变体
- 测量 prompt 性能指标（准确性、一致性、延迟）
- 减少 token 使用同时保持质量
- 处理边缘案例和失败模式

### 5. 模板系统

- 变量插值和格式化
- 条件 prompt 部分
- 多轮对话模板
- 基于角色的 prompt 组合
- 模块化 prompt 组件

### 6. System Prompt 设计

- 设置模型行为和约束
- 定义输出格式和结构
- 确立角色和专业知识
- 安全指南和内容策略
- 上下文设置和背景信息

## 快速模板

### 代码审查 Prompt

```
Review this [language] code for:
1. Bugs and logic errors
2. Security vulnerabilities
3. Performance issues
4. Code style/best practices

Code:
[code]

For each issue found, provide:
- Line number
- Issue description
- Severity (high/medium/low)
- Suggested fix
```

### 内容写作 Prompt

```
Write a [content type] about [topic].

Audience: [target audience]
Tone: [formal/casual/professional]
Length: [word count]
Key points to cover:
1. [point 1]
2. [point 2]
3. [point 3]

Include: [specific elements]
Avoid: [things to exclude]
```

### 结构化输出 Prompt

```
Answer the question based on the context provided.

Context: {context}
Question: {question}

Respond with JSON:
{
    "answer": "your answer",
    "confidence": 0.0-1.0,
    "sources": ["relevant context excerpts"]
}
```

## 最佳实践

1. **具体明确**：模糊的 prompt 产生不一致的结果
2. **展示而非讲述**：示例比描述更有效
3. **使用结构化输出**：用 Pydantic 强制 schema 以确保可靠性
4. **广泛测试**：在多样化的代表性输入上评估
5. **快速迭代**：小的变化可能产生大的影响
6. **监控性能**：在生产环境中跟踪指标
7. **版本控制**：将 prompt 视为代码进行版本管理
8. **记录意图**：解释为什么 prompt 如此构建

## 常见陷阱

- **过度工程**：在尝试简单方法之前不要从复杂的 prompt 开始
- **示例污染**：使用与目标任务不匹配的示例
- **上下文溢出**：使用过多示例超出 token 限制
- **模糊指令**：留出多种解释的空间
- **忽略边缘案例**：在不寻常或边界输入上未测试
- **无错误处理**：假设输出总是格式良好
- **硬编码值**：不参数化 prompt 以便重用

## 成功指标

跟踪这些 KPI：

- **准确性**：输出的正确性
- **一致性**：类似输入的可重复性
- **延迟**：响应时间（P50、P95、P99）
- **Token 使用**：每次请求的平均 token
- **成功率**：有效、可解析输出的百分比
- **用户满意度**：评分和反馈
