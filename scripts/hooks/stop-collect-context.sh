#!/bin/bash
# stop-collect-context.sh - Stop Hook
# Collect additional context on tool failure (0 tokens)
# Optional: Activated when additional context is needed besides PostToolUseFailure
# Hardened Hook

set -euo pipefail

INPUT=$(cat)

# Check jq dependency
if ! command -v jq &> /dev/null; then
    exit 0  # Silently skip if jq is missing
fi

# check stop_hook_active - to prevent infinite loops
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
[ "$STOP_HOOK_ACTIVE" = "true" ] && exit 0

# Transcript path
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
[ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ] && exit 0

# Check for error in recent tool_result
LAST_ERROR=$(tail -100 "$TRANSCRIPT_PATH" 2>/dev/null | jq -s '[.[] | select(.type=="tool_result" and .is_error==true)] | last' 2>/dev/null || echo "null")

if [ "$LAST_ERROR" != "null" ] && [ "$LAST_ERROR" != "" ]; then
  TOOL_NAME=$(echo "$LAST_ERROR" | jq -r '.tool_name // "unknown"')
  ERROR_MSG=$(echo "$LAST_ERROR" | jq -r '.error // "unknown"')

  LOG_DIR="$HOME/.claude/logs"
  mkdir -p "$LOG_DIR"
  CONTEXT_FILE="$LOG_DIR/failure-contexts.jsonl"

  # Save context (JSONL format)
  echo "$LAST_ERROR" >> "$CONTEXT_FILE"
fi

exit 0
