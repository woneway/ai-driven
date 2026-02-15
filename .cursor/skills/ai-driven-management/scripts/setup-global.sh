#!/bin/bash
# =============================================================================
# setup-global.sh - 初始化全局 Cursor 配置
#
# 将 OpenSpec、Everything-Claude-Code 等工具的 skills/commands/rules/agents
# 安装到 ai-driven/common/global_cursor/，并通过 symlink 挂载到 ~/.cursor/。
#
# 架构:
#   $AI_ROOT/
#   └── ai-driven/common/global_cursor/   <- 随 ai-driven 仓库版本控制
#       ├── rules/
#       ├── skills/
#       ├── agents/
#       └── commands/
#   ~/.cursor/                            <- symlink 指向 global_cursor
#       ├── rules    -> $GLOBAL_CURSOR_DIR/rules
#       ├── skills   -> $GLOBAL_CURSOR_DIR/skills
#       ├── agents   -> $GLOBAL_CURSOR_DIR/agents
#       └── commands -> $GLOBAL_CURSOR_DIR/commands
#
# 用法:
#   bash .cursor/skills/ai-driven-management/scripts/setup-global.sh [options]
#
# 选项:
#   --openspec-only    只安装 OpenSpec
#   --ecc-only         只安装 Everything Claude Code
#   --ecc-langs        ECC 语言规则（默认: typescript）
#                      示例: --ecc-langs "typescript python golang"
#   --ecc-path         ECC 项目路径（默认: 自动查找）
#   --skip-symlink     跳过 symlink 创建
#   --dry-run          只显示将要执行的操作，不实际执行
#   --force            强制覆盖已有文件
#
# 示例:
#   bash scripts/setup-global.sh                                    # 安装全部
#   bash scripts/setup-global.sh --openspec-only                    # 只装 OpenSpec
#   bash scripts/setup-global.sh --ecc-langs "typescript python"    # 指定语言
#   bash scripts/setup-global.sh --dry-run                          # 预览
#
# 环境变量（详见 common.sh）:
#   AI_ROOT            ai-driven 所在的父目录
#   AI_DRIVEN_ROOT     ai-driven 仓库根目录
#   CURSOR_HOME        Cursor 全局配置目录（默认: ~/.cursor）
#   GLOBAL_CURSOR_DIR  global_cursor 路径
#   ECC_PATH           Everything Claude Code 项目路径
# =============================================================================

set -e

# === 加载公共配置 ===
CALLER_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$CALLER_SCRIPT_DIR/common.sh"
_validate_ai_driven_root

# === 默认配置 ===
ECC_LANGS="typescript"
INSTALL_OPENSPEC=true
INSTALL_ECC=true
DRY_RUN=false
FORCE=false
SKIP_SYMLINK=false
ECC_PATH_ARG=""

# === 解析参数 ===
while [[ $# -gt 0 ]]; do
    case "$1" in
        --openspec-only)
            INSTALL_ECC=false
            shift
            ;;
        --ecc-only)
            INSTALL_OPENSPEC=false
            shift
            ;;
        --ecc-langs)
            ECC_LANGS="$2"
            shift 2
            ;;
        --ecc-path)
            ECC_PATH_ARG="$2"
            shift 2
            ;;
        --skip-symlink)
            SKIP_SYMLINK=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            head -44 "$0" | tail -42
            exit 0
            ;;
        *)
            error "未知参数: $1"
            exit 1
            ;;
    esac
done

# === 开始 ===
echo ""
echo "=========================================="
echo "  AI-Driven 全局配置初始化"
echo "=========================================="
echo ""
_show_paths
$DRY_RUN && warn "DRY-RUN 模式：只显示操作，不实际执行"
echo ""

installed_openspec=0
installed_ecc=0

# =============================================================================
# 0. 确保 global_cursor 目录存在
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  0. global_cursor 目录"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "$GLOBAL_CURSOR_DIR" ]; then
    ok "global_cursor 目录已存在: $GLOBAL_CURSOR_DIR"
else
    info "创建 global_cursor 目录..."
    if ! $DRY_RUN; then
        mkdir -p "$GLOBAL_CURSOR_DIR"
        ok "已创建: $GLOBAL_CURSOR_DIR"
    else
        echo "  [DRY-RUN] mkdir -p $GLOBAL_CURSOR_DIR"
    fi
fi

# 确保子目录存在
for dir in $MANAGED_DIRS; do
    if ! $DRY_RUN; then
        mkdir -p "$GLOBAL_CURSOR_DIR/$dir"
    fi
done
echo ""

# =============================================================================
# 0.5 创建 symlink（~/.cursor/ -> global_cursor）
# =============================================================================
if ! $SKIP_SYMLINK; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  0.5 Symlink 配置"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    for dir in $MANAGED_DIRS; do
        target="$GLOBAL_CURSOR_DIR/$dir"
        link="$CURSOR_HOME/$dir"

        if [ -L "$link" ]; then
            current_target=$(readlink "$link")
            if [ "$current_target" = "$target" ]; then
                ok "$link -> $target (已存在)"
            else
                warn "$link 指向 $current_target，更新为 $target"
                if ! $DRY_RUN; then
                    rm "$link"
                    ln -s "$target" "$link"
                    ok "$link -> $target"
                else
                    echo "  [DRY-RUN] rm $link && ln -s $target $link"
                fi
            fi
        elif [ -d "$link" ]; then
            warn "$link 是实际目录，迁移到 global_cursor..."
            if ! $DRY_RUN; then
                cp -rn "$link/." "$target/" 2>/dev/null || true
                rm -rf "$link"
                ln -s "$target" "$link"
                ok "$link -> $target (已迁移)"
            else
                echo "  [DRY-RUN] 迁移 $link -> $target 并创建 symlink"
            fi
        else
            if ! $DRY_RUN; then
                mkdir -p "$(dirname "$link")"
                ln -s "$target" "$link"
                ok "$link -> $target (新建)"
            else
                echo "  [DRY-RUN] ln -s $target $link"
            fi
        fi
    done
    echo ""
fi

# =============================================================================
# 1. OpenSpec - 全局安装 commands 和 skills
# =============================================================================
if $INSTALL_OPENSPEC; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  1. OpenSpec"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if ! command -v openspec &>/dev/null; then
        info "openspec CLI 未安装，尝试安装..."
        if ! $DRY_RUN; then
            if npm i -g @fission-ai/openspec@latest 2>/dev/null; then
                ok "openspec 已安装: $(openspec --version 2>/dev/null)"
            else
                error "openspec 安装失败"
                error "手动安装: npm i -g @fission-ai/openspec@latest"
                INSTALL_OPENSPEC=false
            fi
        else
            echo "  [DRY-RUN] npm i -g @fission-ai/openspec@latest"
        fi
    else
        ok "openspec 已安装: $(openspec --version 2>/dev/null)"
    fi

    if $INSTALL_OPENSPEC; then
        existing_opsx=$(ls "$GLOBAL_CURSOR_DIR/commands"/opsx-*.md 2>/dev/null | wc -l | tr -d ' ')
        if [ "$existing_opsx" -gt 0 ] && ! $FORCE; then
            info "已有 $existing_opsx 个 opsx 命令在 global_cursor"
            info "使用 --force 强制覆盖"
        fi

        if [ "$existing_opsx" -eq 0 ] || $FORCE; then
            TMPDIR_OPSX=$(mktemp -d)
            trap "rm -rf $TMPDIR_OPSX" EXIT

            if ! $DRY_RUN; then
                info "生成 OpenSpec commands 和 skills..."
                if openspec init --tools cursor "$TMPDIR_OPSX" 2>/dev/null; then
                    cmd_count=0
                    for f in "$TMPDIR_OPSX/.cursor/commands"/opsx-*.md; do
                        [ -f "$f" ] || continue
                        copy_file "$f" "$GLOBAL_CURSOR_DIR/commands/$(basename "$f")"
                        cmd_count=$((cmd_count + 1))
                    done
                    ok "已安装 $cmd_count 个 opsx 命令"

                    skill_count=0
                    for d in "$TMPDIR_OPSX/.cursor/skills"/openspec-*; do
                        [ -d "$d" ] || continue
                        copy_dir "$d" "$GLOBAL_CURSOR_DIR/skills/$(basename "$d")"
                        skill_count=$((skill_count + 1))
                    done
                    ok "已安装 $skill_count 个 openspec skills"

                    installed_openspec=$((cmd_count + skill_count))
                else
                    error "OpenSpec 初始化失败"
                fi
            else
                echo "  [DRY-RUN] openspec init --tools cursor <tmpdir>"
                echo "  [DRY-RUN] 复制 opsx-*.md -> $GLOBAL_CURSOR_DIR/commands/"
                echo "  [DRY-RUN] 复制 openspec-* skills -> $GLOBAL_CURSOR_DIR/skills/"
                installed_openspec=1
            fi
        fi
    fi
    echo ""
fi

# =============================================================================
# 2. Everything Claude Code - 全局安装 rules/skills/commands/agents
# =============================================================================
if $INSTALL_ECC; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  2. Everything Claude Code"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    ECC_DIR=""
    if [ -n "$ECC_PATH_ARG" ]; then
        ECC_DIR="$ECC_PATH_ARG"
    elif [ -n "${ECC_PATH:-}" ]; then
        ECC_DIR="$ECC_PATH"
    else
        for candidate in \
            "$HOME/Downloads/everything-claude-code-main" \
            "$HOME/Downloads/everything-claude-code" \
            "$HOME/projects/everything-claude-code" \
            "$HOME/code/everything-claude-code" \
            "$HOME/github/everything-claude-code"; do
            if [ -d "$candidate" ] && [ -f "$candidate/install.sh" ]; then
                ECC_DIR="$candidate"
                break
            fi
        done
    fi

    if [ -z "$ECC_DIR" ] || [ ! -d "$ECC_DIR" ]; then
        warn "未找到 Everything Claude Code 项目"
        warn "请使用 --ecc-path 指定路径，或设置 ECC_PATH 环境变量"
        warn "下载: git clone https://github.com/affaan-m/everything-claude-code"
    else
        ok "找到 ECC: $ECC_DIR"
        info "安装语言: $ECC_LANGS"

        ECC_CURSOR_SRC="$ECC_DIR/.cursor"

        if [ -d "$ECC_CURSOR_SRC" ]; then
            # --- Rules ---
            if [ -d "$ECC_CURSOR_SRC/rules" ]; then
                rule_count=0
                for f in "$ECC_CURSOR_SRC/rules"/common-*.md; do
                    [ -f "$f" ] || continue
                    fname="$(basename "$f")"
                    if [ ! -f "$GLOBAL_CURSOR_DIR/rules/$fname" ] || $FORCE; then
                        copy_file "$f" "$GLOBAL_CURSOR_DIR/rules/$fname"
                        rule_count=$((rule_count + 1))
                    fi
                done
                for lang in $ECC_LANGS; do
                    for f in "$ECC_CURSOR_SRC/rules"/${lang}-*.md; do
                        [ -f "$f" ] || continue
                        fname="$(basename "$f")"
                        if [ ! -f "$GLOBAL_CURSOR_DIR/rules/$fname" ] || $FORCE; then
                            copy_file "$f" "$GLOBAL_CURSOR_DIR/rules/$fname"
                            rule_count=$((rule_count + 1))
                        fi
                    done
                done
                [ $rule_count -gt 0 ] && ok "已安装 $rule_count 个 rules"
                [ $rule_count -eq 0 ] && info "rules 已是最新（使用 --force 强制覆盖）"
            fi

            # --- Skills ---
            if [ -d "$ECC_CURSOR_SRC/skills" ]; then
                skill_count=0
                for d in "$ECC_CURSOR_SRC/skills"/*/; do
                    [ -d "$d" ] || continue
                    skill_name="$(basename "$d")"
                    if [ ! -d "$GLOBAL_CURSOR_DIR/skills/$skill_name" ] || $FORCE; then
                        copy_dir "$d" "$GLOBAL_CURSOR_DIR/skills/$skill_name"
                        skill_count=$((skill_count + 1))
                    fi
                done
                [ $skill_count -gt 0 ] && ok "已安装 $skill_count 个 skills"
                [ $skill_count -eq 0 ] && info "skills 已是最新（使用 --force 强制覆盖）"
            fi

            # --- Commands ---
            if [ -d "$ECC_CURSOR_SRC/commands" ]; then
                cmd_count=0
                for f in "$ECC_CURSOR_SRC/commands"/*.md; do
                    [ -f "$f" ] || continue
                    fname="$(basename "$f")"
                    if [ ! -f "$GLOBAL_CURSOR_DIR/commands/$fname" ] || $FORCE; then
                        copy_file "$f" "$GLOBAL_CURSOR_DIR/commands/$fname"
                        cmd_count=$((cmd_count + 1))
                    fi
                done
                [ $cmd_count -gt 0 ] && ok "已安装 $cmd_count 个 commands"
                [ $cmd_count -eq 0 ] && info "commands 已是最新（使用 --force 强制覆盖）"
            fi

            # --- Agents ---
            if [ -d "$ECC_CURSOR_SRC/agents" ]; then
                agent_count=0
                for f in "$ECC_CURSOR_SRC/agents"/*.md; do
                    [ -f "$f" ] || continue
                    fname="$(basename "$f")"
                    if [ ! -f "$GLOBAL_CURSOR_DIR/agents/$fname" ] || $FORCE; then
                        copy_file "$f" "$GLOBAL_CURSOR_DIR/agents/$fname"
                        agent_count=$((agent_count + 1))
                    fi
                done
                [ $agent_count -gt 0 ] && ok "已安装 $agent_count 个 agents"
                [ $agent_count -eq 0 ] && info "agents 已是最新（使用 --force 强制覆盖）"
            fi

            installed_ecc=1
        else
            warn "ECC 目录中未找到 .cursor/ 子目录"
            if [ -f "$ECC_DIR/install.sh" ]; then
                info "可手动运行: cd $ECC_DIR && ./install.sh --target cursor $ECC_LANGS"
            fi
        fi
    fi
    echo ""
fi

# =============================================================================
# 3. 验证
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  验证全局配置"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

errors=0

# 检查 symlink
if ! $SKIP_SYMLINK; then
    for dir in $MANAGED_DIRS; do
        link="$CURSOR_HOME/$dir"
        if [ -L "$link" ]; then
            ok "symlink: $link -> $(readlink "$link")"
        else
            warn "symlink 缺失: $link"
            errors=$((errors + 1))
        fi
    done
fi

# 检查 OpenSpec
opsx_count=$(ls "$GLOBAL_CURSOR_DIR/commands"/opsx-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$opsx_count" -ge 8 ]; then
    ok "OpenSpec commands: $opsx_count 个"
else
    warn "OpenSpec commands: $opsx_count 个（预期 10 个）"
    errors=$((errors + 1))
fi

opsx_skills=$(ls -d "$GLOBAL_CURSOR_DIR/skills"/openspec-* 2>/dev/null | wc -l | tr -d ' ')
if [ "$opsx_skills" -ge 8 ]; then
    ok "OpenSpec skills: $opsx_skills 个"
else
    warn "OpenSpec skills: $opsx_skills 个（预期 10 个）"
    errors=$((errors + 1))
fi

# 统计
gc_skills=$(ls -d "$GLOBAL_CURSOR_DIR/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')
gc_commands=$(ls "$GLOBAL_CURSOR_DIR/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
gc_rules=$(ls "$GLOBAL_CURSOR_DIR/rules"/*.md 2>/dev/null | wc -l | tr -d ' ')
gc_agents=$(ls "$GLOBAL_CURSOR_DIR/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')

ok "全局 skills: $gc_skills 个"
ok "全局 commands: $gc_commands 个"
ok "全局 rules: $gc_rules 个"
ok "全局 agents: $gc_agents 个"

echo ""
echo "=========================================="
if [ $errors -eq 0 ]; then
    echo -e "  ${GREEN}全局配置初始化完成${NC}"
else
    echo -e "  ${YELLOW}完成（有 $errors 个警告）${NC}"
fi
echo "=========================================="
echo ""
echo "配置目录:"
echo "  AI_ROOT:        $AI_ROOT"
echo "  global_cursor:  $GLOBAL_CURSOR_DIR"
echo "  symlink 到:     $CURSOR_HOME/"
echo ""
echo "下一步:"
echo "  1. 重启 Cursor IDE 使全局命令生效"
echo "  2. 创建 workspace: bash $CALLER_SCRIPT_DIR/init-space.sh <name>"
echo "  3. 提交变更: cd $AI_DRIVEN_ROOT && git add -A && git commit && git push"
echo ""
