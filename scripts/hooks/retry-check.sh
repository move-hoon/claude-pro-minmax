#!/bin/bash
# retry-check.sh - Stop Hook (For Builder Subagent)
# Enforce 2-Retry Cap (0 tokens, ~50 tokens on block)
# Hardened Hook

set -euo pipefail

INPUT=$(cat)

# check stop_hook_active - to prevent infinite loops
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
  exit 0  # Already continuing from stop hook result - do not intervene
fi

# Get transcript path
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  # Extract tool_result from last 50 lines (sufficient buffer) and check if last 2 are both errors
  # tail: optimizes performance by not reading the entire file
  # jq: parses JSONL to extract is_error field
  CONSECUTIVE_ERRORS=$(tail -n 50 "$TRANSCRIPT_PATH" | jq -r 'select(.type=="tool_result") | .is_error // false' | tail -n 2 | grep -c "true")
  
  # Escalate on 2 consecutive failures
  if [ "$CONSECUTIVE_ERRORS" -ge 2 ]; then
    echo "RETRY_CAP: 2 consecutive failures detected. Escalation to --sonnet, @planner, or @dplanner is recommended." >&2
    exit 2
  fi
fi

exit 0
