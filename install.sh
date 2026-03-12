#!/bin/bash
# Claude Pro MinMax - Installation Script
set -e

# Error handler: print failure line and exit message
_on_error() { echo ""; echo "❌ Installation failed at line $1. Check output above."; }
trap '_on_error $LINENO' ERR

# Guard unsupported invocations (`curl | bash`, process substitution)
if [[ -z "${BASH_SOURCE[0]}" || "${BASH_SOURCE[0]}" == "bash" ]]; then
  echo "❌ This script cannot be run via 'curl | bash'."
  echo "   Please clone the repository first:"
  echo "   git clone https://github.com/move-hoon/claude-pro-minmax.git && cd claude-pro-minmax && bash install.sh"
  exit 1
fi
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -f "$SCRIPT_DIR/.claude/CLAUDE.md" ] || [ ! -f "$SCRIPT_DIR/package.json" ]; then
  echo "❌ This script must be run from a cloned CPMM repository directory."
  echo "   Please run:"
  echo "   git clone https://github.com/move-hoon/claude-pro-minmax.git && cd claude-pro-minmax && bash install.sh"
  exit 1
fi

# Marker-based detection for Install vs Update
CPMM_MARKER="$HOME/.claude/.cpmm-version"
IS_UPDATE=false
if [ -f "$CPMM_MARKER" ]; then IS_UPDATE=true; fi

# Legacy CPMM detection (marker was introduced after early releases)
LEGACY_CPMM=false
if [ "$IS_UPDATE" = false ] && [ -d "$HOME/.claude" ]; then
  if [ -f "$HOME/.claude/CLAUDE.md" ] &&
     [ -f "$HOME/.claude/settings.json" ] &&
     [ -f "$HOME/.claude/commands/do.md" ] &&
     [ -f "$HOME/.claude/commands/do-opus.md" ]; then
    LEGACY_CPMM=true
  fi
fi

# Header message: show Install vs Update mode
if [ "$IS_UPDATE" = true ]; then
  echo "🔄 Updating Claude Pro MinMax (CPMM)"
  INSTALLED_VERSION=$(head -1 "$CPMM_MARKER" 2>/dev/null || echo "unknown")
  echo "   Current version: $INSTALLED_VERSION"
else
  echo "🚀 Installing Claude Pro MinMax (CPMM)"
fi

# Backup existing ~/.claude (Fresh Install Only)
HAS_EXISTING_RTK_HOOK=false
if [ -f "$HOME/.claude/settings.json" ] && grep -q "rtk-rewrite.sh" "$HOME/.claude/settings.json" 2>/dev/null; then
  HAS_EXISTING_RTK_HOOK=true
fi

if [ "$IS_UPDATE" = false ] && [ -d "$HOME/.claude" ]; then
  if [ -d "$HOME/.claude.pre-cpmm" ]; then
    echo "⚠️  ~/.claude.pre-cpmm already exists, skipping backup."
    echo "   User data preserved. Reinstalling CPMM files in-place..."
    # No rm -rf — user data (learned/, plans/, projects/, sessions/) is safe
  elif [ "$LEGACY_CPMM" = true ]; then
    echo "⚠️  Detected legacy CPMM installation without marker, skipping backup."
    echo "   User data preserved. Reinstalling CPMM files in-place..."
    # No rm -rf — user data (learned/, plans/, projects/, sessions/) is safe
  else
    mv "$HOME/.claude" "$HOME/.claude.pre-cpmm"
    echo "📦 Backed up ~/.claude → ~/.claude.pre-cpmm"
  fi
fi

# Create required directories (user-owned dirs are never rm-rf'd)
# NITPICK #11: only create dirs not managed by rm-rf below
mkdir -p "$HOME/.claude/rules" "$HOME/.claude/skills/learned"
mkdir -p "$HOME/.claude/"{sessions,plans,projects}

# Copy core configurations
cp "$SCRIPT_DIR/.claude/CLAUDE.md" "$HOME/.claude/"
cp "$SCRIPT_DIR/.claude/settings.json" "$HOME/.claude/"
# Copy settings.local.json from example template (only if not already present)
if [ ! -f "$HOME/.claude/settings.local.json" ] && [ -f "$SCRIPT_DIR/.claude/settings.local.example.json" ]; then
    cp "$SCRIPT_DIR/.claude/settings.local.example.json" "$HOME/.claude/settings.local.json"
fi

shopt -s nullglob

# agents/, commands/, contexts/ — fully CPMM managed: rm-rf to remove stale files
# EDGE CASE #6: these dirs are CPMM-only; user files should not be placed here
rm -rf "$HOME/.claude/agents" && mkdir -p "$HOME/.claude/agents"
_agent_files=("$SCRIPT_DIR/.claude/agents/"*.md)
if [ ${#_agent_files[@]} -gt 0 ]; then
  for agent in "${_agent_files[@]}"; do
    filename=$(basename "$agent")
    [[ "$filename" == README* ]] && continue
    [[ "$filename" == USER-MANUAL* ]] && continue
    cp "$agent" "$HOME/.claude/agents/"
  done
fi

rm -rf "$HOME/.claude/commands" && mkdir -p "$HOME/.claude/commands"
_cmd_files=("$SCRIPT_DIR/.claude/commands/"*.md)
if [ ${#_cmd_files[@]} -gt 0 ]; then
  for cmd in "${_cmd_files[@]}"; do
    filename=$(basename "$cmd")
    [[ "$filename" == README* ]] && continue
    [[ "$filename" == USER-MANUAL* ]] && continue
    cp "$cmd" "$HOME/.claude/commands/"
  done
fi

rm -rf "$HOME/.claude/contexts" && mkdir -p "$HOME/.claude/contexts"
_ctx_files=("$SCRIPT_DIR/.claude/contexts/"*.md)
if [ ${#_ctx_files[@]} -gt 0 ]; then
  for ctx in "${_ctx_files[@]}"; do
    filename=$(basename "$ctx")
    [[ "$filename" == README* ]] && continue
    [[ "$filename" == USER-MANUAL* ]] && continue
    cp "$ctx" "$HOME/.claude/contexts/"
  done
fi

# rules/ — language.md is user-owned: remove stale CPMM rules, preserve language.md
# BUG #2: rules loop is now inside nullglob block to prevent literal glob expansion
find "$HOME/.claude/rules/" -name "*.md" ! -name "language.md" -delete 2>/dev/null || true
for rule in "$SCRIPT_DIR/.claude/rules/"*.md; do
  [[ -f "$rule" ]] || continue  # nullglob guard (no-op with nullglob, safety net)
  filename=$(basename "$rule")
  [ "$filename" = "language.md" ] && continue
  [[ "$filename" == README* ]] && continue
  [[ "$filename" == USER-MANUAL* ]] && continue
  cp "$rule" "$HOME/.claude/rules/"
done

shopt -u nullglob

# cli-wrappers/ and scripts/ — fully CPMM managed: rm-rf to remove stale files
if [ -d "$SCRIPT_DIR/.claude/skills/cli-wrappers" ]; then
  rm -rf "$HOME/.claude/skills/cli-wrappers"
  cp -R "$SCRIPT_DIR/.claude/skills/cli-wrappers" "$HOME/.claude/skills/"
fi
# sessions/ dir created above; example files stay in repo only (not installed)
if [ -d "$SCRIPT_DIR/scripts" ]; then
  rm -rf "$HOME/.claude/scripts"
  cp -R "$SCRIPT_DIR/scripts" "$HOME/.claude/scripts"
fi

# Copy MCP Configuration
MCP_CONFIG_PRESENT=false
if [ -f "$SCRIPT_DIR/.claude.json" ]; then
  MCP_CONFIG_PRESENT=true

  if [ "$IS_UPDATE" = false ]; then
    if [ -f "$HOME/.claude.json" ]; then
      echo "📦 Backing up existing ~/.claude.json → ~/.claude.json.bak"
      cp "$HOME/.claude.json" "$HOME/.claude.json.bak"
    fi
    cp "$SCRIPT_DIR/.claude.json" "$HOME/.claude.json"
    echo "✅ Installed .claude.json to ~/.claude.json (User Scope)"
  elif [ ! -f "$HOME/.claude.json" ]; then
    cp "$SCRIPT_DIR/.claude.json" "$HOME/.claude.json"
    echo "✅ Restored missing ~/.claude.json from repository template"
  fi

  # Fresh install: enforce symlink. Update: restore only when missing (do not overwrite existing file/link).
  if [ "$IS_UPDATE" = false ]; then
    if [ ! -L "$HOME/.mcp.json" ] || [ "$(readlink "$HOME/.mcp.json" 2>/dev/null)" != "$HOME/.claude.json" ]; then
      ln -sf "$HOME/.claude.json" "$HOME/.mcp.json"
      echo "✅ Ensured .mcp.json → .claude.json symlink"
    fi
  elif [ ! -e "$HOME/.mcp.json" ] && [ ! -L "$HOME/.mcp.json" ]; then
    ln -s "$HOME/.claude.json" "$HOME/.mcp.json"
    echo "✅ Restored missing .mcp.json → .claude.json symlink"
  fi
fi

# Perplexity setup + language selection (Fresh Install Only)
if [ "$IS_UPDATE" = false ]; then
  # EDGE CASE #8: check stdin is truly a terminal (not /dev/tty char-device trick)
  # [ -c /dev/tty ] is always true on Linux/macOS — use [ -t 0 ] alone
  if [ "$MCP_CONFIG_PRESENT" = true ] && [ -t 0 ]; then
    if ! command -v jq &> /dev/null; then
      echo "⚠️  Skipping Perplexity setup (jq not installed). Install jq and re-run to configure."
    else
      echo ""
      echo "🔍 Perplexity API Setup (Recommended for /dplan)"
      echo -n "   Enter your API Key (Press Enter to skip): "
      read -rs PERPLEXITY_KEY < /dev/tty || PERPLEXITY_KEY=""
      echo "" # Newline for silent read

      if [ -n "$PERPLEXITY_KEY" ]; then
        # Enable Perplexity (use env var to avoid key exposure in process list)
        # EDGE CASE #10: write to tmp then atomically rename; trap cleans up on failure
        PERPLEXITY_API_KEY="$PERPLEXITY_KEY" jq \
          '.mcpServers.perplexity = .mcpServers._perplexity_disabled_by_default |
           .mcpServers.perplexity.env.PERPLEXITY_API_KEY = env.PERPLEXITY_API_KEY |
           del(.mcpServers._perplexity_disabled_by_default)' \
          "$HOME/.claude.json" > "$HOME/.claude.json.tmp"
        mv "$HOME/.claude.json.tmp" "$HOME/.claude.json"
        # BUG #5: unset both variables
        unset PERPLEXITY_KEY PERPLEXITY_API_KEY
        echo "✅ Perplexity API Key configured!"
      else
        # Skip: Completely remove the disabled block to keep config clean
        echo "⚠️  Skipping Perplexity setup. Disabling feature..."
        jq 'del(.mcpServers._perplexity_disabled_by_default)' \
          "$HOME/.claude.json" > "$HOME/.claude.json.tmp"
        mv "$HOME/.claude.json.tmp" "$HOME/.claude.json"
        echo "   (Feature removed from config. Add manually to functionality if needed)"
      fi
    fi
  fi

  # Language Selection (Interactive - Fresh Install Only)
  if [ -t 0 ]; then
    echo ""
    echo "🌍 Output Language"
    echo "   1) English (default)"
    echo "   2) 한국어 (Korean)"
    echo "   3) 日本語 (Japanese)"
    echo "   4) 中文 (Chinese)"
    echo -n "   Select [1-4]: "
    read -r LANG_CHOICE < /dev/tty || LANG_CHOICE="1"

    case $LANG_CHOICE in
      2)
        cat > "$HOME/.claude/rules/language.md" <<'LANGEOF'
# Language Policy
Respond in Korean (한국어). Code, commands, technical terms in English.
LANGEOF
        echo "✅ Output language: Korean"
        ;;
      3)
        cat > "$HOME/.claude/rules/language.md" <<'LANGEOF'
# Language Policy
Respond in Japanese (日本語). Code, commands, technical terms in English.
LANGEOF
        echo "✅ Output language: Japanese"
        ;;
      4)
        cat > "$HOME/.claude/rules/language.md" <<'LANGEOF'
# Language Policy
Respond in Chinese (中文). Code, commands, technical terms in English.
LANGEOF
        echo "✅ Output language: Chinese"
        ;;
      *)
        # English: no language.md needed (Claude defaults to English)
        rm -f "$HOME/.claude/rules/language.md"
        echo "✅ Output language: English"
        ;;
    esac
  fi
fi

# EDGE CASE #9: guard find against missing dir (scripts/ may not exist on minimal installs)
# Make scripts executable (Recursive)
if [ -d "$HOME/.claude/scripts" ]; then
  find "$HOME/.claude/scripts" -name "*.sh" -exec chmod +x {} \;
  find "$HOME/.claude/scripts" -name "*.js" -exec chmod +x {} \;
fi

# Write installation marker
# SEC #4: avoid node -p with interpolated $SCRIPT_DIR (injection risk); use node -e with argument
PROJECT_VERSION=$(node -e "try{process.stdout.write(require(process.argv[1]).version)}catch(e){process.exit(1)}" \
  "$SCRIPT_DIR/package.json" 2>/dev/null || \
  grep '"version"' "$SCRIPT_DIR/package.json" 2>/dev/null | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/' || \
  echo "unknown")
printf '%s\ninstalled:%s\n' "$PROJECT_VERSION" "$(date)" > "$CPMM_MARKER"

# Old backup cleanup hint
OLD_BACKUPS=$(find "$HOME" -maxdepth 1 -name ".claude-backup-*" -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$OLD_BACKUPS" -gt 0 ]; then
  echo ""
  echo "💡 Old backups detected: $OLD_BACKUPS directory(ies) named ~/.claude-backup-*"
  echo "   Review and remove: rm -rf ~/.claude-backup-*"
fi

# Final success message showing mode
echo ""
if [ "$IS_UPDATE" = true ]; then
  echo "✅ Update complete!"
else
  echo "✅ Installation complete!"
fi
echo ""
echo "Quick Start:"
echo "  claude"
echo "  > /plan Design a new feature"
echo "  > /dplan Analyze complex architecture"
echo "  > /do Implement the login page"
echo ""
echo "Dependency Check:"
echo "  cpmm setup       # install missing deps (jq, mgrep, tmux) + attempt optional RTK install"
echo "  cpmm doctor      # check status only"
echo ""
if command -v rtk >/dev/null 2>&1; then
  echo "RTK (Optional Integration):"
  echo "  Installed: rtk"
  echo "  Enable hook: rtk init -g --hook-only"
  echo "  Recommended Bash hook order in ~/.claude/settings.json:"
  echo "    1) ~/.claude/scripts/hooks/critical-action-check.sh  (timeout: 5)"
  echo "    2) ~/.claude/hooks/rtk-rewrite.sh                    (timeout: 10)"
  echo "  Rollback: rtk init -g --uninstall"
  echo ""
fi
if [ "$HAS_EXISTING_RTK_HOOK" = true ]; then
  echo "RTK Update Note:"
  echo "  An RTK hook was detected before this CPMM update."
  echo "  Because CPMM reinstalled ~/.claude/settings.json, re-check RTK hook order and timeout."
  echo "  Run: cpmm doctor"
  echo ""
fi
echo "Language:"
echo "  To change language: edit ~/.claude/rules/language.md"
echo "  To use English: rm ~/.claude/rules/language.md"
