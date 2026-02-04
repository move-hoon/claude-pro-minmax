#!/bin/bash
# _template.sh - Template for New Adapters
# Copy this file to create a new adapter
#
# Steps to add a new language:
# 1. cp _template.sh elixir.sh
# 2. Implement all adapter_* functions
# 3. Add detection pattern to ../detect.sh
# Done! Core scripts unchanged (OCP).
#
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# Return adapter metadata as JSON
adapter_info() {
  echo '{"runtime":"RUNTIME_NAME","tool":"TOOL_NAME","languages":["LANGUAGE"]}'
}

# Run full verification (compile + test + lint)
adapter_verify() {
  echo "TODO: Implement verify for RUNTIME_NAME"
  echo "Example: mix compile && mix test"
  exit 1
}

# Build the project
adapter_build() {
  echo "TODO: Implement build for RUNTIME_NAME"
  echo "Example: mix release"
  exit 1
}

# Run tests
adapter_test() {
  echo "TODO: Implement test for RUNTIME_NAME"
  echo "Example: mix test"
  exit 1
}

# Run linter
adapter_lint() {
  echo "TODO: Implement lint for RUNTIME_NAME"
  echo "Example: mix credo"
  exit 1
}

# Format code
adapter_format() {
  echo "TODO: Implement format for RUNTIME_NAME"
  echo "Example: mix format"
  exit 1
}

# Clean build artifacts
adapter_clean() {
  echo "TODO: Implement clean for RUNTIME_NAME"
  echo "Example: mix clean"
  exit 1
}

# Optional: Run dev server
adapter_run() {
  echo "TODO: Implement run for RUNTIME_NAME"
  echo "Example: mix phx.server"
  exit 1
}
