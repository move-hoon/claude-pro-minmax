#!/bin/bash
# verify.sh - Universal Verify
# Delegates to runtime-specific adapter
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="$SCRIPT_DIR/runtime"

# Detect runtime
RUNTIME=$("$RUNTIME_DIR/detect.sh" "$@")

# Parse JSON - prefer jq, fallback to bash
parse_json() {
  local key="$1"
  if command -v jq &>/dev/null; then
    echo "$RUNTIME" | jq -r ".$key"
  else
    # Fallback: simple bash parsing for {"key":"value"} format
    echo "$RUNTIME" | sed 's/.*"'"$key"'":"\([^"]*\)".*/\1/'
  fi
}

ADAPTER=$(parse_json adapter)
RUNTIME_NAME=$(parse_json runtime)
TOOL_NAME=$(parse_json tool)

echo "🔍 Detected: $RUNTIME_NAME ($TOOL_NAME)"

# Source adapter
source "$RUNTIME_DIR/adapters/$ADAPTER"

# Execute
echo "🔧 Running verification..."
adapter_verify
