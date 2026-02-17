# OpenSpec 设计规格

本文档记录 ai-driven 框架的完整设计规范。

## 概述

ai-driven 是一个 AI 自主开发框架，核心理念是：人只说需求，AI 全自动完成。

## 目录结构

```
openspec/
├── specs/              # 设计规格
│   ├── core/          # 框架核心概念
│   │   └── concepts.md
│   └── resources/     # 资源管理规范
│       └── README.md
└── changes/            # 变更记录
    └── archive/       # 已归档变更
```

## 核心模块

### core - 框架核心概念

定义四大核心概念：
- **Workspace** - 项目工作空间
- **/team** - 唯一开发入口
- **OpenSpec** - 变更记录系统
- **global_cursor** - 全局能力目录

详见 [core/concepts.md](./core/concepts.md)

### resources - 资源管理规范

定义 Skills、Rules、Commands、Agents 的安装和使用规范。

详见 [resources/README.md](./resources/README.md)

## 相关链接

- [ai-driven README](../../README.md)
- [资源安装规范](../../.cursor/rules/resources.mdc)
