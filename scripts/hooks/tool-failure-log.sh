#!/bin/bash
# tool-failure-log.sh - PostToolUseFailure Hook
# Logging and escalation recommendations on tool failure (0 tokens)
# Hardened Hook

set -euo pipefail

INPUT=$(cat)

# Check jq dependency
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
fi

# Parsing
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
ERROR_MSG=$(echo "$INPUT" | jq -r '.error // "unknown error"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# Log directory
LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/tool-failures.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Record log
echo "[$TIMESTAMP] Tool: $TOOL_NAME | Error: $ERROR_MSG | Session: $SESSION_ID" >> "$LOG_FILE"

# Check for identical tool failures within last 5 minutes (from log file)
if [ -f "$LOG_FILE" ]; then
  FIVE_MIN_AGO=$(date -v-5M +"%Y-%m-%d %H:%M:%S" 2>/dev/null || date -d "5 minutes ago" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "")
  if [ -n "$FIVE_MIN_AGO" ]; then
    RECENT_FAILURES=$(grep "$TOOL_NAME" "$LOG_FILE" 2>/dev/null | tail -10 | wc -l | tr -d ' ')
  else
    RECENT_FAILURES=$(grep -c "$TOOL_NAME" "$LOG_FILE" 2>/dev/null || echo 0)
  fi
else
  RECENT_FAILURES=1
fi

# Recommend escalation on 3 or more failures
if [ "$RECENT_FAILURES" -ge 3 ]; then
  echo "[ToolFailure] Tool $TOOL_NAME failed ${RECENT_FAILURES} times. Escalation to @planner or @dplanner recommended." >&2
fi
