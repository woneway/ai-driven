#!/bin/bash
# =============================================================================
# setup-global.sh - 初始化全局 Cursor 配置
#
# 将 OpenSpec、Everything-Claude-Code 等工具的 skills/commands/rules
# 安装到 ~/.cursor/ 全局目录，避免每个项目重复初始化。
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
#   --dry-run          只显示将要执行的操作，不实际执行
#   --force            强制覆盖已有文件
#
# 示例:
#   bash scripts/setup-global.sh                                    # 安装全部
#   bash scripts/setup-global.sh --openspec-only                    # 只装 OpenSpec
#   bash scripts/setup-global.sh --ecc-langs "typescript python"    # 指定语言
#   bash scripts/setup-global.sh --dry-run                          # 预览
#
# 环境变量:
#   ECC_PATH           Everything Claude Code 项目路径
#   CURSOR_HOME        Cursor 全局配置目录（默认: ~/.cursor）
# =============================================================================

set -e

# === 颜色输出 ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# === 默认配置 ===
CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
ECC_LANGS="typescript"
INSTALL_OPENSPEC=true
INSTALL_ECC=true
DRY_RUN=false
FORCE=false
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
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            head -30 "$0" | tail -28
            exit 0
            ;;
        *)
            error "未知参数: $1"
            exit 1
            ;;
    esac
done

# === 辅助函数 ===
copy_file() {
    local src="$1" dst="$2"
    if $DRY_RUN; then
        echo "  [DRY-RUN] cp $src -> $dst"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
}

copy_dir() {
    local src="$1" dst="$2"
    if $DRY_RUN; then
        echo "  [DRY-RUN] cp -r $src/ -> $dst/"
        return
    fi
    mkdir -p "$dst"
    cp -r "$src/." "$dst/"
}

# === 开始 ===
echo ""
echo "=========================================="
echo "  AI-Driven 全局配置初始化"
echo "=========================================="
echo ""
info "Cursor 全局目录: $CURSOR_HOME"
$DRY_RUN && warn "DRY-RUN 模式：只显示操作，不实际执行"
echo ""

installed_openspec=0
installed_ecc=0

# =============================================================================
# 1. OpenSpec - 全局安装 commands 和 skills
# =============================================================================
if $INSTALL_OPENSPEC; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  1. OpenSpec"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 检查 openspec 是否已安装
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
        # 检查是否已有全局 opsx 命令
        existing_opsx=$(ls "$CURSOR_HOME/commands"/opsx-*.md 2>/dev/null | wc -l | tr -d ' ')
        if [ "$existing_opsx" -gt 0 ] && ! $FORCE; then
            info "已有 $existing_opsx 个 opsx 命令在全局目录"
            info "使用 --force 强制覆盖"
        fi

        if [ "$existing_opsx" -eq 0 ] || $FORCE; then
            # 在临时目录生成，然后只复制 commands 和 skills
            TMPDIR_OPSX=$(mktemp -d)
            trap "rm -rf $TMPDIR_OPSX" EXIT

            if ! $DRY_RUN; then
                info "生成 OpenSpec commands 和 skills..."
                if openspec init --tools cursor "$TMPDIR_OPSX" 2>/dev/null; then
                    # 复制 commands
                    cmd_count=0
                    for f in "$TMPDIR_OPSX/.cursor/commands"/opsx-*.md; do
                        [ -f "$f" ] || continue
                        copy_file "$f" "$CURSOR_HOME/commands/$(basename "$f")"
                        cmd_count=$((cmd_count + 1))
                    done
                    ok "已安装 $cmd_count 个 opsx 命令到 $CURSOR_HOME/commands/"

                    # 复制 skills
                    skill_count=0
                    for d in "$TMPDIR_OPSX/.cursor/skills"/openspec-*; do
                        [ -d "$d" ] || continue
                        copy_dir "$d" "$CURSOR_HOME/skills/$(basename "$d")"
                        skill_count=$((skill_count + 1))
                    done
                    ok "已安装 $skill_count 个 openspec skills 到 $CURSOR_HOME/skills/"

                    installed_openspec=$((cmd_count + skill_count))
                else
                    error "OpenSpec 初始化失败"
                fi
            else
                echo "  [DRY-RUN] openspec init --tools cursor <tmpdir>"
                echo "  [DRY-RUN] 复制 opsx-*.md -> $CURSOR_HOME/commands/"
                echo "  [DRY-RUN] 复制 openspec-* skills -> $CURSOR_HOME/skills/"
                installed_openspec=1
            fi
        fi
    fi
    echo ""
fi

# =============================================================================
# 2. Everything Claude Code - 全局安装 rules/skills/commands
# =============================================================================
if $INSTALL_ECC; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  2. Everything Claude Code"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 查找 ECC 路径
    ECC_DIR=""
    if [ -n "$ECC_PATH_ARG" ]; then
        ECC_DIR="$ECC_PATH_ARG"
    elif [ -n "${ECC_PATH:-}" ]; then
        ECC_DIR="$ECC_PATH"
    else
        # 自动查找常见位置
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

        # 使用 ECC 自带的 install.sh 安装到 Cursor 全局
        # ECC 的 install.sh --target cursor 安装到当前目录的 .cursor/
        # 我们需要安装到 ~/.cursor/，所以直接复制

        ECC_CURSOR_SRC="$ECC_DIR/.cursor"

        if [ -d "$ECC_CURSOR_SRC" ]; then
            # --- Rules ---
            if [ -d "$ECC_CURSOR_SRC/rules" ]; then
                rule_count=0
                # common rules
                for f in "$ECC_CURSOR_SRC/rules"/common-*.md; do
                    [ -f "$f" ] || continue
                    fname="$(basename "$f")"
                    if [ ! -f "$CURSOR_HOME/rules/$fname" ] || $FORCE; then
                        copy_file "$f" "$CURSOR_HOME/rules/$fname"
                        rule_count=$((rule_count + 1))
                    fi
                done
                # language-specific rules
                for lang in $ECC_LANGS; do
                    for f in "$ECC_CURSOR_SRC/rules"/${lang}-*.md; do
                        [ -f "$f" ] || continue
                        fname="$(basename "$f")"
                        if [ ! -f "$CURSOR_HOME/rules/$fname" ] || $FORCE; then
                            copy_file "$f" "$CURSOR_HOME/rules/$fname"
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
                    if [ ! -d "$CURSOR_HOME/skills/$skill_name" ] || $FORCE; then
                        copy_dir "$d" "$CURSOR_HOME/skills/$skill_name"
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
                    if [ ! -f "$CURSOR_HOME/commands/$fname" ] || $FORCE; then
                        copy_file "$f" "$CURSOR_HOME/commands/$fname"
                        cmd_count=$((cmd_count + 1))
                    fi
                done
                [ $cmd_count -gt 0 ] && ok "已安装 $cmd_count 个 commands"
                [ $cmd_count -eq 0 ] && info "commands 已是最新（使用 --force 强制覆盖）"
            fi

            installed_ecc=1
        else
            warn "ECC 目录中未找到 .cursor/ 子目录"
            warn "尝试使用 ECC 的 install.sh..."
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

# 检查 OpenSpec commands
opsx_count=$(ls "$CURSOR_HOME/commands"/opsx-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$opsx_count" -ge 8 ]; then
    ok "OpenSpec commands: $opsx_count 个"
else
    warn "OpenSpec commands: $opsx_count 个（预期 10 个）"
    errors=$((errors + 1))
fi

# 检查 OpenSpec skills
opsx_skills=$(ls -d "$CURSOR_HOME/skills"/openspec-* 2>/dev/null | wc -l | tr -d ' ')
if [ "$opsx_skills" -ge 8 ]; then
    ok "OpenSpec skills: $opsx_skills 个"
else
    warn "OpenSpec skills: $opsx_skills 个（预期 10 个）"
    errors=$((errors + 1))
fi

# 检查 ECC 核心文件
ecc_skills=$(ls -d "$CURSOR_HOME/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')
ecc_commands=$(ls "$CURSOR_HOME/commands"/*.md 2>/dev/null | wc -l | tr -d ' ')
ecc_rules=$(ls "$CURSOR_HOME/rules"/*.md 2>/dev/null | wc -l | tr -d ' ')

ok "全局 skills: $ecc_skills 个"
ok "全局 commands: $ecc_commands 个"
ok "全局 rules: $ecc_rules 个"

echo ""
echo "=========================================="
if [ $errors -eq 0 ]; then
    echo -e "  ${GREEN}全局配置初始化完成${NC}"
else
    echo -e "  ${YELLOW}完成（有 $errors 个警告）${NC}"
fi
echo "=========================================="
echo ""
echo "全局目录: $CURSOR_HOME/"
echo ""
echo "下一步:"
echo "  1. 重启 Cursor IDE 使全局命令生效"
echo "  2. 创建 workspace: bash .cursor/skills/ai-driven-management/scripts/init-space.sh <name>"
echo ""
