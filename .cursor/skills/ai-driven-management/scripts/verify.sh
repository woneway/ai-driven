#!/bin/bash
# =============================================================================
# verify.sh - AI-Driven 自动化验证
#
# 验证模板结构、文件格式、内容一致性，并测试 workspace 创建和同步。
# exit 0 = 全部通过，exit 1 = 有失败。
#
# 用法:
#   bash .cursor/skills/ai-driven-management/scripts/verify.sh
#
# 环境变量（详见 common.sh）:
#   AI_ROOT            ai-driven 所在的父目录
#   AI_DRIVEN_ROOT     ai-driven 仓库根目录
#   WORKSPACES_PATH    自定义 workspaces 存放路径
# =============================================================================

set -e

# === 加载公共配置 ===
CALLER_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$CALLER_SCRIPT_DIR/common.sh"
_validate_ai_driven_root

TEMPLATE="$TEMPLATE_DIR"
TEST_WS="$WORKSPACES_PATH/_verify_test"
SCRIPTS="$CALLER_SCRIPT_DIR"
PASS=0
FAIL=0

check() {
    local desc="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== 路径信息 ==="
_show_paths
echo ""

echo "=== 1. 模板结构检查 ==="
check "ai-driven.mdc 存在" \
    "[ -f '$TEMPLATE/.cursor/rules/ai-driven.mdc' ]"
check "team.md 存在" \
    "[ -f '$TEMPLATE/.cursor/commands/team.md' ]"
check ".workspace.env.example 存在" \
    "[ -f '$TEMPLATE/.workspace.env.example' ]"
check ".gitignore 存在" \
    "[ -f '$TEMPLATE/.gitignore' ]"
check "无 agents 目录（已移除自定义 agents）" \
    "[ ! -d '$TEMPLATE/.cursor/agents' ]"

echo ""
echo "=== 2. 无遗留检查 ==="
check "无 AGENTS.md" \
    "[ ! -f '$TEMPLATE/AGENTS.md' ]"
check "无 .homunculus 目录" \
    "[ ! -d '$TEMPLATE/.homunculus' ]"
check "无 .cursor/skills 目录" \
    "[ ! -d '$TEMPLATE/.cursor/skills' ]"
check "无 010-ai-driven.mdc" \
    "[ ! -f '$TEMPLATE/.cursor/rules/010-ai-driven.mdc' ]"
check "ai-driven 根无 AI-DRIVEN-MASTER-PROMPT.md" \
    "[ ! -f '$AI_DRIVEN_ROOT/AI-DRIVEN-MASTER-PROMPT.md' ]"
check "ai-driven 根无 011-ai-driven-cmd.mdc" \
    "[ ! -f '$AI_DRIVEN_ROOT/.cursor/rules/011-ai-driven-cmd.mdc' ]"

echo ""
echo "=== 3. 文件格式检查 ==="
check "ai-driven.mdc 有 alwaysApply: true" \
    "grep -q 'alwaysApply: true' '$TEMPLATE/.cursor/rules/ai-driven.mdc'"
check "ai-driven.mdc 无 globs" \
    "! grep -q 'globs:' '$TEMPLATE/.cursor/rules/ai-driven.mdc'"
check "team.md 有 description frontmatter" \
    "grep -q '^description:' '$TEMPLATE/.cursor/commands/team.md'"

echo ""
echo "=== 4. 内容一致性检查 ==="
check "无 /opsx: 冒号格式（应为 /opsx-）" \
    "! grep -r '/opsx:' '$TEMPLATE/' --include='*.md' --include='*.mdc' 2>/dev/null | grep -v '^\$'"
check "team.md 使用 subagent_type 格式" \
    "grep -q 'subagent_type:' '$TEMPLATE/.cursor/commands/team.md'"
check "team.md 有需求分类" \
    "grep -q '需求分类' '$TEMPLATE/.cursor/commands/team.md'"
check "team.md 有轻量/完整模式" \
    "grep -q '轻量模式' '$TEMPLATE/.cursor/commands/team.md' && grep -q '完整模式' '$TEMPLATE/.cursor/commands/team.md'"
check "team.md 有 Handoff 格式" \
    "grep -q 'HANDOFF:' '$TEMPLATE/.cursor/commands/team.md'"
check "team.md 有错误恢复" \
    "grep -q '错误恢复' '$TEMPLATE/.cursor/commands/team.md'"
check "team.md 有 OpenSpec 前置检查（步骤 0）" \
    "grep -q '全局命令.*opsx-new.*是否可用' '$TEMPLATE/.cursor/commands/team.md'"
check "无残留 --yes 参数" \
    "! grep -r '\-\-yes' '$TEMPLATE/' --include='*.md' --include='*.mdc' 2>/dev/null | grep -v '^\$'"

echo ""
echo "=== 5. 零重复检查 ==="
check "ai-driven.mdc 不含覆盖率要求" \
    "! grep -qi '80%\|覆盖率' '$TEMPLATE/.cursor/rules/ai-driven.mdc'"
check "ai-driven.mdc 不含 Handoff 格式" \
    "! grep -q 'HANDOFF:' '$TEMPLATE/.cursor/rules/ai-driven.mdc'"
check "team.md 使用 PROJECT_PATH 而非 PROJECT_ROOT" \
    "! grep -q 'PROJECT_ROOT' '$TEMPLATE/.cursor/commands/team.md'"

echo ""
echo "=== 6. Skill 和脚本检查 ==="
check "SKILL.md 存在" \
    "[ -f '$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/SKILL.md' ]"
check "SKILL.md 有 name 和 description" \
    "grep -q '^name:' '$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/SKILL.md' && grep -q '^description:' '$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/SKILL.md'"
check "无 .cursor/commands/ai-driven.md（已迁移到 skill）" \
    "[ ! -f '$AI_DRIVEN_ROOT/.cursor/commands/ai-driven.md' ]"
check "无 bin/ 目录（已迁移到 skill/scripts/）" \
    "[ ! -d '$AI_DRIVEN_ROOT/bin' ]"
check "common.sh 存在" \
    "[ -f '$SCRIPTS/common.sh' ]"
check "setup-global.sh 存在且可执行" \
    "[ -x '$SCRIPTS/setup-global.sh' ]"
check "init-space.sh 存在且可执行" \
    "[ -x '$SCRIPTS/init-space.sh' ]"
check "setup.sh 存在且可执行" \
    "[ -x '$SCRIPTS/setup.sh' ]"
check "sync-space.sh 存在且可执行" \
    "[ -x '$SCRIPTS/sync-space.sh' ]"
check "migrate-space-config.sh 存在且可执行" \
    "[ -x '$SCRIPTS/migrate-space-config.sh' ]"
check "migrate-workspace.sh 存在且可执行" \
    "[ -x '$SCRIPTS/migrate-workspace.sh' ]"
check "verify.sh 存在且可执行" \
    "[ -x '$SCRIPTS/verify.sh' ]"

echo ""
echo "=== 6b. 全局配置检查 ==="
check "global_cursor 目录存在" \
    "[ -d '$GLOBAL_CURSOR_DIR' ]"
check "全局 opsx 命令已安装" \
    "[ \$(ls '$CURSOR_HOME/commands'/opsx-*.md 2>/dev/null | wc -l) -ge 8 ]"
check "全局 openspec skills 已安装" \
    "[ \$(ls -d '$CURSOR_HOME/skills'/openspec-* 2>/dev/null | wc -l) -ge 8 ]"

# 检查 symlink
for dir in $MANAGED_DIRS; do
    check "symlink ~/.cursor/$dir 存在" \
        "[ -L '$CURSOR_HOME/$dir' ]"
done

echo ""
echo "=== 7. 创建空 workspace 测试 ==="
rm -rf "$TEST_WS" 2>/dev/null || true
if "$SCRIPTS/init-space.sh" _verify_test 2>/dev/null; then
    check "空 workspace 创建成功" \
        "[ -d '$TEST_WS' ]"
    check "ai-driven.mdc 被复制" \
        "[ -f '$TEST_WS/.cursor/rules/ai-driven.mdc' ]"
    check "team.md 被复制" \
        "[ -f '$TEST_WS/.cursor/commands/team.md' ]"
    check ".workspace.env 已填充" \
        "grep -q 'SPACE_NAME=_verify_test' '$TEST_WS/.workspace.env'"
    check ".code-workspace 存在" \
        "[ -f '$TEST_WS/_verify_test.code-workspace' ]"
    check ".cursor/commands 目录存在" \
        "[ -d '$TEST_WS/.cursor/commands' ]"
    check "无 .homunculus 目录" \
        "[ ! -d '$TEST_WS/.homunculus' ]"
    check "无 010-ai-driven.mdc" \
        "[ ! -f '$TEST_WS/.cursor/rules/010-ai-driven.mdc' ]"
    check "workspace 内无 opsx 命令（已迁移到全局）" \
        "[ \$(ls '$TEST_WS/.cursor/commands'/opsx-*.md 2>/dev/null | wc -l) -eq 0 ]"
    check "workspace 内无 openspec skills（已迁移到全局）" \
        "[ \$(ls -d '$TEST_WS/.cursor/skills'/openspec-* 2>/dev/null | wc -l) -eq 0 ]"
    check "OpenSpec openspec/changes/ 目录存在" \
        "[ -d '$TEST_WS/openspec/changes' ]"
    check "OpenSpec openspec/specs/ 目录存在" \
        "[ -d '$TEST_WS/openspec/specs' ]"
    check "无 agents 目录" \
        "[ ! -d '$TEST_WS/.cursor/agents' ]"
else
    echo "  FAIL: 空 workspace 创建失败"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== 8. sync-space.sh 测试 ==="
if [ -d "$TEST_WS" ]; then
    # 修改 workspace 的 ai-driven.mdc，然后 sync，验证被覆盖
    echo "MODIFIED" >> "$TEST_WS/.cursor/rules/ai-driven.mdc"
    # 修改 .workspace.env，验证不被覆盖
    ORIGINAL_CONFIG="$(cat "$TEST_WS/.workspace.env")"

    "$SCRIPTS/sync-space.sh" 2>/dev/null

    check "sync 后 ai-driven.mdc 与模板一致" \
        "diff -q '$TEMPLATE/.cursor/rules/ai-driven.mdc' '$TEST_WS/.cursor/rules/ai-driven.mdc'"
    check "sync 后 team.md 与模板一致" \
        "diff -q '$TEMPLATE/.cursor/commands/team.md' '$TEST_WS/.cursor/commands/team.md'"
    check "sync 后 .workspace.env 未被改动" \
        "grep -q 'SPACE_NAME=_verify_test' '$TEST_WS/.workspace.env'"
    check "sync 后无 agents 目录（已清理）" \
        "[ ! -d '$TEST_WS/.cursor/agents' ]"
    check "sync 后无 opsx 命令（已迁移到全局）" \
        "[ \$(ls '$TEST_WS/.cursor/commands'/opsx-*.md 2>/dev/null | wc -l) -eq 0 ]"
    check "sync 后无 openspec skills（已迁移到全局）" \
        "[ \$(ls -d '$TEST_WS/.cursor/skills'/openspec-* 2>/dev/null | wc -l) -eq 0 ]"
fi

# 清理测试 workspace
rm -rf "$TEST_WS" 2>/dev/null || true

echo ""
echo "=============================="
echo "  PASS: $PASS  FAIL: $FAIL"
echo "=============================="
[ "$FAIL" -eq 0 ] && echo "ALL PASSED" && exit 0
echo "SOME FAILED" && exit 1
