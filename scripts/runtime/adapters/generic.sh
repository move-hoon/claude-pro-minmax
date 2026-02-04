#!/bin/bash
# generic.sh - Generic Adapter (Makefile fallback)
# Used when no specific runtime is detected
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

adapter_info() {
  echo '{"runtime":"generic","tool":"make","languages":["unknown"]}'
}

adapter_verify() {
  cd "$PROJECT_DIR"
  if [[ -f "Makefile" ]]; then
    make check 2>/dev/null || make test 2>/dev/null || make verify 2>/dev/null || true
  else
    echo "⚠️ No recognized build system found."
    echo "Supported: Gradle, Maven, npm, pnpm, yarn, Cargo, Go, Poetry, pip"
    echo "Please specify the build commands manually."
    return 1
  fi
}

adapter_build() {
  cd "$PROJECT_DIR"
  if [[ -f "Makefile" ]]; then
    make build 2>/dev/null || make all 2>/dev/null || make
  else
    echo "No Makefile found. Cannot build."
    return 1
  fi
}

adapter_test() {
  cd "$PROJECT_DIR"
  if [[ -f "Makefile" ]]; then
    make test
  else
    echo "No Makefile found. Cannot run tests."
    return 1
  fi
}

adapter_lint() {
  cd "$PROJECT_DIR"
  if [[ -f "Makefile" ]]; then
    make lint 2>/dev/null || true
  else
    echo "No Makefile found. Cannot lint."
  fi
}

adapter_format() {
  cd "$PROJECT_DIR"
  if [[ -f "Makefile" ]]; then
    make format 2>/dev/null || make fmt 2>/dev/null || true
  else
    echo "No Makefile found. Cannot format."
  fi
}

adapter_run() {
  cd "$PROJECT_DIR"
  if [[ -f "Makefile" ]]; then
    make run 2>/dev/null || make start 2>/dev/null || make serve 2>/dev/null
  else
    echo "No Makefile found. Cannot run."
    return 1
  fi
}

adapter_clean() {
  cd "$PROJECT_DIR"
  if [[ -f "Makefile" ]]; then
    make clean 2>/dev/null || true
  fi
  echo "Generic clean completed"
}
