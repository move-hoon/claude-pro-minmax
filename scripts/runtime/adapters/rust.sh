#!/bin/bash
# rust.sh - Rust Adapter
# Supports Cargo
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

adapter_info() {
  echo '{"runtime":"rust","tool":"cargo","languages":["rust"]}'
}

adapter_verify() {
  cd "$PROJECT_DIR"
  cargo check && cargo test && (cargo clippy 2>/dev/null || true)
}

adapter_build() {
  cd "$PROJECT_DIR"
  cargo build
}

adapter_test() {
  cd "$PROJECT_DIR"
  cargo test
}

adapter_lint() {
  cd "$PROJECT_DIR"
  if command -v cargo-clippy &>/dev/null || cargo clippy --version &>/dev/null; then
    cargo clippy
  else
    echo "clippy not installed, skipping lint"
  fi
}

adapter_format() {
  cd "$PROJECT_DIR"
  cargo fmt
}

adapter_run() {
  cd "$PROJECT_DIR"
  cargo run
}

adapter_clean() {
  cd "$PROJECT_DIR"
  cargo clean
}
