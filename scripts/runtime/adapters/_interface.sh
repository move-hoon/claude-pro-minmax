#!/bin/bash
# _interface.sh - Adapter Interface Contract
# All adapters MUST implement these functions
#
# Usage: source this file to verify adapter compliance
# 
# Required functions:
#   adapter_info()    - Return adapter metadata as JSON
#   adapter_verify()  - Run full verification (build + test + lint)
#   adapter_build()   - Build project
#   adapter_test()    - Run tests
#   adapter_lint()    - Run linter
#   adapter_format()  - Format code
#   adapter_clean()   - Clean build artifacts
#
# Optional functions:
#   adapter_run()     - Run dev server

REQUIRED_FUNCTIONS=(
  "adapter_info"
  "adapter_verify"
  "adapter_build"
  "adapter_test"
  "adapter_lint"
  "adapter_format"
  "adapter_clean"
)

verify_adapter() {
  local adapter_file="$1"
  local missing=()
  
  source "$adapter_file"
  
  for func in "${REQUIRED_FUNCTIONS[@]}"; do
    if ! declare -f "$func" > /dev/null 2>&1; then
      missing+=("$func")
    fi
  done
  
  if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: Adapter missing functions: ${missing[*]}" >&2
    return 1
  fi
  
  echo "✓ Adapter $adapter_file implements all required functions"
  return 0
}

# If called directly with an argument, verify that adapter
if [ $# -gt 0 ]; then
  verify_adapter "$1"
fi
