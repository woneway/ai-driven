# AI-Driven 项目配置

## Agent Teams 模式

本项目已启用 Claude Code Agent Teams 模式。

### 启用

在 Cursor 设置中添加：
```json
{
  "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": true
}
```

### 使用方式

**启动 Agent Teams**：
```
/team start "实现用户认证模块"

# 或指定队友
/team start "前端" "后端" "测试"
```

**列出队友**：
```
/team list
```

**与队友沟通**：
```
/team @前端 问一下进度
```

**综合结果**：
```
/team synthesize
```

### 角色分配

- **Lead**：主协调者
- **Frontend**：前端开发
- **Backend**：后端开发
- **QA**：测试
- **Researcher**：调研

### 场景示例

```
用户: /team 实现用户认证

Lead: 好的，我来协调团队
  → 分配 Frontend: 登录页面
  → 分配 Backend: API 接口
  → 分配 QA: 测试用例
  → 分配 Researcher: JWT 方案调研

Frontend: 登录页面完成
Backend: API 完成
Researcher: 推荐使用 JWT + Refresh Token

Lead: 综合结果，合成最终实现
```

### 注意事项

- Agent Teams 会消耗更多 tokens
- 适合复杂任务
- 简单任务用 /dev 即可