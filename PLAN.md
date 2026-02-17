# AI-Driven 资源创建执行计划

## 目标
创建 P0 优先级的 Skills、Rules、Agents、Commands，最大化开发效率

## 执行阶段

---

### Phase 1: Skills 创建 (P0)

| 序号 | 资源 | 路径 | 状态 |
|------|------|------|------|
| 1.1 | ios-development | `common/global_cursor/skills/ios-development/SKILL.md` | ⏳ |
| 1.2 | swift-testing | `common/global_cursor/skills/swift-testing/SKILL.md` | ⏳ |
| 1.3 | nodejs-backend | `common/global_cursor/skills/nodejs-backend/SKILL.md` | ⏳ |
| 1.4 | socket-io-patterns | `common/global_cursor/skills/socket-io-patterns/SKILL.md` | ⏳ |
| 1.5 | crypto-trading | `common/global_cursor/skills/crypto-trading/SKILL.md` | ⏳ |

---

### Phase 2: Rules 创建 (P0)

| 序号 | 资源 | 路径 | 状态 |
|------|------|------|------|
| 2.1 | swift-coding-style | `common/global_cursor/rules/swift-coding-style.md` | ⏳ |
| 2.2 | ios-testing | `common/global_cursor/rules/ios-testing.md` | ⏳ |
| 2.3 | nodejs-coding-style | `common/global_cursor/rules/nodejs-coding-style.md` | ⏳ |

---

### Phase 3: Agents 创建 (P0)

| 序号 | 资源 | 路径 | 状态 |
|------|------|------|------|
| 3.1 | ios-developer | `common/global_cursor/agents/ios-developer.md` | ⏳ |
| 3.2 | nodejs-developer | `common/global_cursor/agents/nodejs-developer.md` | ⏳ |

---

### Phase 4: Commands 创建 (P0)

| 序号 | 资源 | 路径 | 状态 |
|------|------|------|------|
| 4.1 | ios-test | `common/global_cursor/commands/ios-test.md` | ⏳ |
| 4.2 | ios-build | `common/global_cursor/commands/ios-build.md` | ⏳ |
| 4.3 | node-lint | `common/global_cursor/commands/node-lint.md` | ⏳ |

---

### Phase 5: 同步与验证

| 序号 | 任务 | 命令 | 状态 |
|------|------|------|------|
| 5.1 | 同步配置 | `bash .cursor/skills/ai-driven-management/scripts/sync-space.sh` | ⏳ |
| 5.2 | 验证安装 | 检查 `~/.cursor/skills/` symlink | ⏳ |
| 5.3 | 重启 Cursor | 手动退出并重启 | ⏳ |

---

## 执行方式

每次执行 1-2 个资源，确保质量后再继续。

---

## 后续阶段 (P1-P2)

Phase 1-5 完成后，可继续：

- **Phase 6**: P1 Skills (quantitative-trading, financial-analysis, nextjs-advanced 等)
- **Phase 7**: P1 Rules/Agents
- **Phase 8**: P2 增强资源
