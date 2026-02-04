#!/bin/bash
# readonly-check.sh - PreToolUse Hook (For Reviewer Subagent)
# Block Write/Edit operations (0 tokens, ~50 tokens on block)
# Hardened Hook

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Block writing tools
case "$TOOL_NAME" in
  Write|Edit|NotebookEdit)
    echo "READONLY: Reviewer agent cannot modify files. Read-only access only." >&2
    exit 2
    ;;
esac

exit 0
