#!/bin/bash
# snapshot.sh - Atomic rollback helper for /do commands
# Deterministic git stash with label-based safety guard
# Usage: scripts/snapshot.sh push|pop|drop [label]
set -euo pipefail

ACTION="${1:-}"
LABEL="${2:-cpmm-do}"
STASH_ID="${LABEL}-$(date +%s)"

case "$ACTION" in
  push)
    BEFORE=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    git stash push -m "$STASH_ID" 2>/dev/null || true
    AFTER=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    if [ "$AFTER" -gt "$BEFORE" ]; then
      echo "SNAPSHOT=true"
    else
      echo "SNAPSHOT=false"
    fi
    ;;
  pop)
    # Check if top stash is ours (cpmm-labeled) before popping
    TOP=$(git stash list -1 2>/dev/null || echo "")
    if echo "$TOP" | grep -q "cpmm-"; then
      git stash pop 2>/dev/null && echo "RESTORED" || echo "RESTORE_FAILED"
    else
      # No cpmm snapshot — discard tracked changes only
      git checkout . 2>/dev/null && echo "CHECKOUT_CLEAN" || echo "CLEAN_FAILED"
    fi
    ;;
  drop)
    # Check if top stash is ours (cpmm-labeled) before dropping
    TOP=$(git stash list -1 2>/dev/null || echo "")
    if echo "$TOP" | grep -q "cpmm-"; then
      git stash drop 2>/dev/null && echo "DROPPED" || echo "DROP_FAILED"
    else
      echo "NO_SNAPSHOT"
    fi
    ;;
  *)
    echo "Usage: scripts/snapshot.sh push|pop|drop [label]" >&2
    exit 1
    ;;
esac
