---
description: AI 驱动开发唯一入口。简短规则。
---

# /dev 规则（快速参考）

## 核心原则

1. **先设计，后实现** - 永远先写 design.md
2. **先测试，后代码** - TDD 方式
3. **用户确认才能继续** - 需求理解、规范设计必须确认
4. **失败就停止** - 测试不通过就修复
5. **完成要记忆** - 更新 .roles/knowledge.md

## 执行流程

```
1. 理解需求 → 用户确认
2. 写 design.md → 用户确认
3. 写测试 → 通过
4. 写代码 → 通过
5. 代码审查 → 通过
6. E2E → 通过
7. 记忆更新 → 完成
```

## 检查清单

每次完成后检查：

- [ ] design.md 存在
- [ ] 测试通过 + 覆盖率 >= 80%
- [ ] lint 通过
- [ ] 代码审查通过
- [ ] E2E 通过
- [ ] knowledge.md 已更新
- [ ] summary.md 已创建

## 记忆位置

- `.roles/knowledge.md` - 项目知识
- `.roles/decisions.md` - 架构决策
- `.changes/{date}_{name}/summary.md` - 任务总结

## 失败处理

测试失败 → 修复代码 → 重新测试 → 通过后才能提交代码审查

代码审查失败 → 修复问题 → 重新审查 → 通过后才能 E2E

## 文件位置

- 规范设计: `.changes/{date}_{slug}/design.md`
- 任务总结: `.changes/{date}_{slug}/summary.md`