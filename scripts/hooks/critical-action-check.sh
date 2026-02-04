#!/bin/bash
# critical-action-check.sh - PreToolUse Hook
# Block dangerous commands (0 tokens, ~50 tokens on block)
# Hardened Hook + Multi-Runtime

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# If not a Bash tool or no command, skip
[ -z "$COMMAND" ] && exit 0

# 1. Direct Dangerous Commands (CRITICAL)
DIRECT_PATTERNS=(
  'rm -rf /'
  'rm -rf ~'
  'rm -rf \.'
  'git push.*--force'
  'git reset --hard'
  'DROP TABLE'
  'TRUNCATE'
)

for pattern in "${DIRECT_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -iE "$pattern" > /dev/null 2>&1; then
    echo "CRITICAL: Blocked dangerous command: $COMMAND" >&2
    exit 2
  fi
done

# Block DELETE FROM without WHERE (Separate handling as ERE does not support negative lookahead)
if echo "$COMMAND" | grep -iE 'DELETE FROM' > /dev/null 2>&1; then
  if ! echo "$COMMAND" | grep -iE 'WHERE' > /dev/null 2>&1; then
    echo "CRITICAL: Blocked DELETE FROM without WHERE clause: $COMMAND" >&2
    exit 2
  fi
fi

# 2. Indirect Dangerous Scripts (WARNING -> BLOCK)
# Multi-runtime support
INDIRECT_PATTERNS=(
  'npm run.*\b(clean|reset|nuke|purge)\b'
  'yarn.*\b(clean|reset|nuke|purge)\b'
  'pnpm.*\b(clean|reset|nuke|purge)\b'
  './gradlew.*\b(clean)\b'
  'gradle.*\b(clean)\b'
  'mvn.*\b(clean)\b'
  'cargo.*\b(clean)\b'
  'go.*\b(clean)\b'
  '\b(db:reset|db:drop|migrate:reset)\b'
  '\b(deploy:prod|deploy:production)\b'
)

for pattern in "${INDIRECT_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -iE "$pattern" > /dev/null 2>&1; then
    echo "WARNING: Blocked indirect dangerous script: $COMMAND" >&2
    exit 2
  fi
done

# 3. Detect Git Conflict
if echo "$COMMAND" | grep -E '(CONFLICT|<<<<<<<|>>>>>>>)' > /dev/null 2>&1; then
  echo "CONFLICT: Git conflict detected. Manual resolution required." >&2
  exit 2
fi

exit 0
