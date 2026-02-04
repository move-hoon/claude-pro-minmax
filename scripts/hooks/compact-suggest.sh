#!/bin/bash
# compact-suggest.sh - PostToolUse Hook (After Edit/Write completion)
# Suggests compaction at logical breakpoints
# Official Docs: additionalContext in PostToolUse is delivered to Claude
set -euo pipefail

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')

COUNTER_FILE="/tmp/claude-tool-count-$SESSION_ID"
THRESHOLD=${COMPACT_THRESHOLD:-50}

# Increment counter
count=$(($(cat "$COUNTER_FILE" 2>/dev/null || echo 0) + 1))
echo "$count" > "$COUNTER_FILE"

# Suggestion when threshold is reached (exactly once, delivered to Claude via JSON stdout)
if [ "$count" -eq "$THRESHOLD" ]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "[COMPACT] $THRESHOLD tool calls reached. Consider /compact to save context."
  }
}
EOF
fi

exit 0
