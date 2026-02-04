#!/bin/bash
# pre-compact.sh - PreCompact Hook
# Automatically save state before context compaction (0 tokens)
# Hardened Hook

set -euo pipefail

INPUT=$(cat)

# Check jq dependency
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
fi

SESSION_DIR="$HOME/.claude/sessions"
mkdir -p "$SESSION_DIR"

# Compaction trigger type (manual/auto)
TRIGGER=$(echo "$INPUT" | jq -r '.trigger // "unknown"')
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# Create state file
STATE_FILE="$SESSION_DIR/${TIMESTAMP}-pre-compact.md"

cat > "$STATE_FILE" <<EOF
---
type: pre-compact
trigger: $TRIGGER
session_id: $SESSION_ID
timestamp: $(date +"%Y-%m-%d %H:%M:%S")
---

# Pre-Compact State

## Trigger
- Type: $TRIGGER
- Time: $(date +"%H:%M:%S")

## Working Directory
$(pwd)

## Git Status
$(git status --short 2>/dev/null || echo "Not a git repository")

## Recent Modified Files
$(find . -type f \( -name "*.md" -o -name "*.ts" -o -name "*.js" -o -name "*.sh" -o -name "*.json" \) -mmin -30 2>/dev/null | head -10 || echo "No recent files")

## Context Hint
[Claude: Refer to this file to resume work after compaction]
EOF

echo "[PreCompact] State saved: $STATE_FILE" >&2
exit 0
