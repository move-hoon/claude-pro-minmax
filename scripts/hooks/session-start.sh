#!/bin/bash
# session-start.sh - SessionStart Hook
# 1. Set environment variables (using CLAUDE_ENV_FILE)
# 2. Notify previous session context (opt-in: CLAUDE_SESSION_NOTIFY=1)
# Official Docs: Environment variables can be persisted via CLAUDE_ENV_FILE in SessionStart
set -euo pipefail

# 1. Set environment variables (0 tokens) - Always runs
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  # Example: project-specific environment variables
  # echo 'export NODE_ENV=development' >> "$CLAUDE_ENV_FILE"
  # echo 'export DEBUG=true' >> "$CLAUDE_ENV_FILE"
  
  # Load .env.local if exists (Security: values are not exposed)
  ENV_LOCAL="${CLAUDE_PROJECT_DIR:-.}/.env.local"
  if [ -f "$ENV_LOCAL" ]; then
    # Extract only variable names and export (values are loaded at runtime)
    grep -v '^#' "$ENV_LOCAL" | grep '=' | while read -r line; do
      var_name="${line%%=*}"
      echo "export $var_name=\"\${$var_name:-}\"" >> "$CLAUDE_ENV_FILE"
    done
  fi
fi

# 2. Previous session notification (opt-in, ~30 tokens)
if [ "${CLAUDE_SESSION_NOTIFY:-0}" = "1" ]; then
  SESSION_DIR="$HOME/.claude/sessions"
  RECENT=$(find "$SESSION_DIR" -name "*.md" -mtime -7 2>/dev/null | sort -r | head -1)

  if [ -n "$RECENT" ] && [ -f "$RECENT" ]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "📂 Previous session found: $(basename "$RECENT"). To restore: /session-load $(basename "$RECENT" .md)"
  }
}
EOF
  fi
fi

# 3. Failure log notification (opt-in, ~30 tokens)
if [ "${CLAUDE_FAILURE_NOTIFY:-0}" = "1" ]; then
  LOG_FILE="$HOME/.claude/logs/tool-failures.log"
  if [ -f "$LOG_FILE" ]; then
    FAILURE_COUNT=$(wc -l < "$LOG_FILE" 2>/dev/null | tr -d ' ')
    if [ "$FAILURE_COUNT" -gt 10 ]; then
      cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "⚠️ ${FAILURE_COUNT} tool failures accumulated. To analyze: /analyze-failures"
  }
}
EOF
    fi
  fi
fi

exit 0
