#!/bin/bash
# =============================================================================
# verify.sh - AI-Driven 自动化验证
#
# 验证模板结构、文件格式、内容一致性，并测试 workspace 创建和同步。
# exit 0 = 全部通过，exit 1 = 有失败。
#
# 用法:
#   bash .cursor/skills/ai-driven-management/scripts/verify.sh
# =============================================================================

set -e

# scripts/ -> ai-driven-management/ -> skills/ -> .cursor/ -> ai-driven root
AI_DRIVEN_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
TEMPLATE="$AI_DRIVEN_ROOT/common/workspace-template"
WORKSPACES_PATH="${WORKSPACES_PATH:-$AI_DRIVEN_ROOT/workspaces}"
TEST_WS="$WORKSPACES_PATH/_verify_test"
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

echo "=== 1. 模板结构检查 ==="
check "ai-driven.mdc 存在" \
    "[ -f '$TEMPLATE/.cursor/rules/ai-driven.mdc' ]"
check "team.md 存在" \
    "[ -f '$TEMPLATE/.cursor/commands/team.md' ]"
check ".space-config 存在" \
    "[ -f '$TEMPLATE/.space-config' ]"
check ".gitignore 存在" \
    "[ -f '$TEMPLATE/.gitignore' ]"

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
check "team.md 有三阶段结构" \
    "grep -q '阶段一' '$TEMPLATE/.cursor/commands/team.md'"
check "team.md 有 Handoff 格式" \
    "grep -q 'HANDOFF:' '$TEMPLATE/.cursor/commands/team.md'"
check "team.md 有错误恢复" \
    "grep -q '错误恢复' '$TEMPLATE/.cursor/commands/team.md'"

echo ""
echo "=== 5. 零重复检查 ==="
check "ai-driven.mdc 不含覆盖率要求" \
    "! grep -qi '80%\|覆盖率' '$TEMPLATE/.cursor/rules/ai-driven.mdc'"
check "ai-driven.mdc 不含 Handoff 格式" \
    "! grep -q 'HANDOFF:' '$TEMPLATE/.cursor/rules/ai-driven.mdc'"
check "team.md 不含 MUST 目录规则" \
    "! grep -q 'MUST.*CODE_ROOTS\|CODE_ROOTS.*MUST' '$TEMPLATE/.cursor/commands/team.md'"

echo ""
echo "=== 6. Skill 和脚本检查 ==="
SCRIPTS="$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/scripts"
check "SKILL.md 存在" \
    "[ -f '$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/SKILL.md' ]"
check "SKILL.md 有 name 和 description" \
    "grep -q '^name:' '$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/SKILL.md' && grep -q '^description:' '$AI_DRIVEN_ROOT/.cursor/skills/ai-driven-management/SKILL.md'"
check "无 .cursor/commands/ai-driven.md（已迁移到 skill）" \
    "[ ! -f '$AI_DRIVEN_ROOT/.cursor/commands/ai-driven.md' ]"
check "无 bin/ 目录（已迁移到 skill/scripts/）" \
    "[ ! -d '$AI_DRIVEN_ROOT/bin' ]"
check "init-space.sh 存在且可执行" \
    "[ -x '$SCRIPTS/init-space.sh' ]"
check "sync-space.sh 存在且可执行" \
    "[ -x '$SCRIPTS/sync-space.sh' ]"
check "verify.sh 存在且可执行" \
    "[ -x '$SCRIPTS/verify.sh' ]"

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
    check ".space-config 已填充" \
        "grep -q 'SPACE_NAME=\"_verify_test\"' '$TEST_WS/.space-config'"
    check ".code-workspace 存在" \
        "[ -f '$TEST_WS/_verify_test.code-workspace' ]"
    check ".cursor/commands 目录存在" \
        "[ -d '$TEST_WS/.cursor/commands' ]"
    check ".cursor/skills 目录存在" \
        "[ -d '$TEST_WS/.cursor/skills' ]"
    check "无 .homunculus 目录" \
        "[ ! -d '$TEST_WS/.homunculus' ]"
    check "无 010-ai-driven.mdc" \
        "[ ! -f '$TEST_WS/.cursor/rules/010-ai-driven.mdc' ]"
else
    echo "  FAIL: 空 workspace 创建失败"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "=== 8. sync-space.sh 测试 ==="
if [ -d "$TEST_WS" ]; then
    # 修改 workspace 的 ai-driven.mdc，然后 sync，验证被覆盖
    echo "MODIFIED" >> "$TEST_WS/.cursor/rules/ai-driven.mdc"
    # 修改 .space-config，验证不被覆盖
    ORIGINAL_CONFIG="$(cat "$TEST_WS/.space-config")"

    "$SCRIPTS/sync-space.sh" 2>/dev/null

    check "sync 后 ai-driven.mdc 与模板一致" \
        "diff -q '$TEMPLATE/.cursor/rules/ai-driven.mdc' '$TEST_WS/.cursor/rules/ai-driven.mdc'"
    check "sync 后 team.md 与模板一致" \
        "diff -q '$TEMPLATE/.cursor/commands/team.md' '$TEST_WS/.cursor/commands/team.md'"
    check "sync 后 .space-config 未被改动" \
        "grep -q 'SPACE_NAME=\"_verify_test\"' '$TEST_WS/.space-config'"
fi

# 清理测试 workspace
rm -rf "$TEST_WS" 2>/dev/null || true

echo ""
echo "=============================="
echo "  PASS: $PASS  FAIL: $FAIL"
echo "=============================="
[ "$FAIL" -eq 0 ] && echo "ALL PASSED" && exit 0
echo "SOME FAILED" && exit 1
