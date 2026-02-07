#!/bin/bash
# Claude Pro MinMax - Installation Script
set -e
echo "🚀 Installing Claude Pro MinMax (CPMM)"

# Check for dependencies
if ! command -v jq &> /dev/null; then
    echo "⚠️ Warning: jq is not installed. Some features (JSON output, cost optimization) may not work."
    echo "  Install with: brew install jq"
fi

# Check for mgrep (Critical for output reduction)
if ! command -v mgrep &> /dev/null; then
    echo "⚠️ Warning: mgrep is not installed. This is critical for 50% output reduction."
    echo "  Install with: npm install -g @mixedbread/mgrep && mgrep install-claude-code"
fi

# Backup and Clean existing ~/.claude (True Overwrite)
if [ -d ~/.claude ]; then
    BACKUP_DIR=~/.claude-backup-$(date +"%Y%m%d-%H%M%S")
    echo "📦 Backing up and clearing existing ~/.claude → $BACKUP_DIR"
    mv ~/.claude "$BACKUP_DIR"
    echo "  Clean overwrite enabled. Old settings preserved in backup."
fi

# Create fresh directories
mkdir -p ~/.claude/{agents,commands,rules,skills/cli-wrappers/references,contexts,sessions,scripts}

# Copy configurations
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp "$SCRIPT_DIR/.claude/CLAUDE.md" ~/.claude/
cp "$SCRIPT_DIR/.claude/settings.json" ~/.claude/
if [ -f "$SCRIPT_DIR/.claudeignore" ]; then
    cp "$SCRIPT_DIR/.claudeignore" ~/.claude/
fi
# Copy settings.local.json from example template (users customize after install)
if [ -f "$SCRIPT_DIR/.claude/settings.local.example.json" ]; then
    cp "$SCRIPT_DIR/.claude/settings.local.example.json" ~/.claude/settings.local.json
fi
cp "$SCRIPT_DIR/.claude/agents/"*.md ~/.claude/agents/
cp "$SCRIPT_DIR/.claude/commands/"*.md ~/.claude/commands/
for rule in "$SCRIPT_DIR/.claude/rules/"*.md; do
  filename=$(basename "$rule")
  [ "$filename" = "language.md" ] && continue
  cp "$rule" ~/.claude/rules/
done
cp -R "$SCRIPT_DIR/.claude/skills/"* ~/.claude/skills/
cp "$SCRIPT_DIR/.claude/contexts/"*.md ~/.claude/contexts/
cp "$SCRIPT_DIR/.claude/sessions/"*.md ~/.claude/sessions/
cp -R "$SCRIPT_DIR/scripts/"* ~/.claude/scripts/

# Clean up documentation files from ~/.claude to prevent parsing errors
# (The 'find' command below removes all README/USER-MANUAL files from the installed directory)
find ~/.claude -name "README*" -delete
find ~/.claude -name "USER-MANUAL*" -delete

# Copy MCP Configuration (User Scope - ~/.claude.json)
if [ -f "$SCRIPT_DIR/.claude.json" ]; then
    if [ -f ~/.claude.json ]; then
        echo "📦 Backing up existing ~/.claude.json → ~/.claude.json.bak"
        cp ~/.claude.json ~/.claude.json.bak
    fi
    cp "$SCRIPT_DIR/.claude.json" ~/.claude.json
    echo "✅ Installed .claude.json to ~/.claude.json (User Scope)"

    # Create .mcp.json symlink (Force recreate to ensure it's a link)
    if [ -e ~/.mcp.json ] || [ -L ~/.mcp.json ]; then
        rm ~/.mcp.json
    fi
    ln -s ~/.claude.json ~/.mcp.json
    echo "✅ Created .mcp.json → .claude.json symlink (Ensured Link)"
    # Interactive Perplexity Setup (Read from /dev/tty for curl support)
    if [ -t 0 ] || [ -c /dev/tty ]; then
        echo ""
        echo "🔍 Perplexity API Setup (Recommended for /dplan)"
        echo -n "   Enter your API Key (Press Enter to skip): "
        read -rs PERPLEXITY_KEY < /dev/tty || PERPLEXITY_KEY=""
        echo "" # Newline for silent read

        if [ -n "$PERPLEXITY_KEY" ]; then
            # Enable Perplexity (Rename key and inject API Key)
            # Use jq for reliable JSON editing
            jq --arg key "$PERPLEXITY_KEY" \
               '.mcpServers.perplexity = .mcpServers._perplexity_disabled_by_default | 
                .mcpServers.perplexity.env.PERPLEXITY_API_KEY = $key | 
                del(.mcpServers._perplexity_disabled_by_default)' \
               ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
            echo "✅ Perplexity API Key configured!"
        else
            # Skip: Completely remove the disabled block to keep config clean
            echo "⚠️  Skipping Perplexity setup. Disabling feature..."
            jq 'del(.mcpServers._perplexity_disabled_by_default)' ~/.claude.json > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json
            echo "   (Feature removed from config. Add manually to functionality if needed)"
        fi
        # No temp file cleanup needed for jq approach as we mv content
    fi
fi

# Language Selection (Interactive)
if [ -t 0 ] || [ -c /dev/tty ]; then
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
      cat > ~/.claude/rules/language.md <<'LANGEOF'
# Language Policy
Respond in Korean (한국어). Code, commands, technical terms in English.
LANGEOF
      echo "✅ Output language: Korean"
      ;;
    3)
      cat > ~/.claude/rules/language.md <<'LANGEOF'
# Language Policy
Respond in Japanese (日本語). Code, commands, technical terms in English.
LANGEOF
      echo "✅ Output language: Japanese"
      ;;
    4)
      cat > ~/.claude/rules/language.md <<'LANGEOF'
# Language Policy
Respond in Chinese (中文). Code, commands, technical terms in English.
LANGEOF
      echo "✅ Output language: Chinese"
      ;;
    *)
      # English: no language.md needed (Claude defaults to English)
      rm -f ~/.claude/rules/language.md
      echo "✅ Output language: English"
      ;;
  esac
fi

# Make scripts executable (Recursive)
find ~/.claude/scripts -name "*.sh" -exec chmod +x {} \;
find ~/.claude/scripts -name "*.js" -exec chmod +x {} \;

echo "✅ Installation complete!"
echo ""
echo "Quick Start:"
echo "  claude"
echo "  > /plan Design a new feature"
echo "  > /dplan Analyze complex architecture"
echo "  > /do Implement the login page"
echo ""
echo "Language:"
echo "  To change language: edit ~/.claude/rules/language.md"
echo "  To use English: rm ~/.claude/rules/language.md"
