#!/bin/bash
# Claude Pro MinMax - Installation Script
set -e
echo "🚀 Installing Claude Pro MinMax (CPMM)"

# Check for dependencies
if ! command -v jq &> /dev/null; then
    echo "⚠️ Warning: jq is not installed. Some features (JSON output, token savings) may not work."
    echo "  Install with: brew install jq"
fi

# Check for mgrep (Critical for token savings)
if ! command -v mgrep &> /dev/null; then
    echo "⚠️ Warning: mgrep is not installed. This is critical for 50% token savings."
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
# Copy settings.local.json if it exists (contains Pro Plan overrides)
if [ -f "$SCRIPT_DIR/.claude/settings.local.json" ]; then
    cp "$SCRIPT_DIR/.claude/settings.local.json" ~/.claude/
fi
cp "$SCRIPT_DIR/.claude/agents/"*.md ~/.claude/agents/
cp "$SCRIPT_DIR/.claude/commands/"*.md ~/.claude/commands/
cp "$SCRIPT_DIR/.claude/rules/"*.md ~/.claude/rules/
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
