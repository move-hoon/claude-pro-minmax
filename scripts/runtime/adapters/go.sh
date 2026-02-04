#!/bin/bash
# go.sh - Go Adapter
# Supports Go modules
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

adapter_info() {
  echo '{"runtime":"go","tool":"go","languages":["go"]}'
}

adapter_verify() {
  cd "$PROJECT_DIR"
  go build ./... && go test ./... && go vet ./...
}

adapter_build() {
  cd "$PROJECT_DIR"
  go build ./...
}

adapter_test() {
  cd "$PROJECT_DIR"
  go test ./...
}

adapter_lint() {
  cd "$PROJECT_DIR"
  # Try golangci-lint first, fallback to go vet
  if command -v golangci-lint &>/dev/null; then
    golangci-lint run
  else
    go vet ./...
  fi
}

adapter_format() {
  cd "$PROJECT_DIR"
  gofmt -w .
}

adapter_run() {
  cd "$PROJECT_DIR"
  go run .
}

adapter_clean() {
  cd "$PROJECT_DIR"
  go clean
  rm -rf bin/ 2>/dev/null || true
}
