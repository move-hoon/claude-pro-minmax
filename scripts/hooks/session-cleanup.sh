#!/bin/bash
# session-cleanup.sh - SessionEnd Hook
# Save session summary + Secret scrubbing on session end (0 tokens)
# Hardened Hook

set -euo pipefail

INPUT=$(cat)

# Check jq dependency
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
fi

# Set project directories
SESSION_DIR="$HOME/.claude/sessions"
SCRUBBER="$HOME/.claude/scripts/scrub-secrets.js"

mkdir -p "$SESSION_DIR"

# Save session summary
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
REASON=$(echo "$INPUT" | jq -r '.reason // "other"')
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SUMMARY_FILE="$SESSION_DIR/${TIMESTAMP}-session-end.md"

# Git change summary
GIT_SUMMARY=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
  CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
  STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  GIT_SUMMARY="Branch: $BRANCH, Changed: $CHANGED_FILES, Staged: $STAGED_FILES"
else
  GIT_SUMMARY="Not a git repository"
fi

# Create summary file
cat > "$SUMMARY_FILE" <<EOF
---
type: session-end
session_id: $SESSION_ID
reason: $REASON
timestamp: $(date +"%Y-%m-%d %H:%M:%S")
---

# Session End Summary

## Session Info
- ID: $SESSION_ID
- End Reason: $REASON
- Time: $(date +"%H:%M:%S")

## Git Status
$GIT_SUMMARY

## Working Directory
$(pwd)

## Context for Next Session
[Reference this file with /session-load in the next session]
EOF

echo "[SessionEnd] Summary saved: $SUMMARY_FILE" >&2

# ===== Existing: Secret Scrubbing =====
# Skip if scrubber does not exist
[ ! -f "$SCRUBBER" ] && exit 0

# Scrub session files modified within last 5 minutes (*.md)
find "$SESSION_DIR" -name "*.md" -mmin -5 -print0 2>/dev/null | while IFS= read -r -d '' file; do
  if [ -f "$file" ]; then
    temp_file=$(mktemp)
    if node "$SCRUBBER" < "$file" > "$temp_file" 2>/dev/null; then
      mv "$temp_file" "$file"
    else
      rm -f "$temp_file"
    fi
  fi
done

exit 0
