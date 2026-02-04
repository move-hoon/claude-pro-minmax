#!/bin/bash
# node.sh - Node Adapter (npm/pnpm/yarn/bun)
# Supports TypeScript, JavaScript, React, Next.js, Vite
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

_detect_pm() {
  [[ -f "$PROJECT_DIR/pnpm-lock.yaml" ]] && echo "pnpm" && return
  [[ -f "$PROJECT_DIR/yarn.lock" ]] && echo "yarn" && return
  [[ -f "$PROJECT_DIR/bun.lockb" ]] && echo "bun" && return
  echo "npm"
}

_run() {
  local pm=$(_detect_pm)
  case $pm in
    pnpm) pnpm "$@" ;;
    yarn) yarn "$@" ;;
    bun) bun "$@" ;;
    *) npm "$@" ;;
  esac
}

_has_script() {
  local script="$1"
  [[ -f "$PROJECT_DIR/package.json" ]] && \
    grep -q "\"$script\":" "$PROJECT_DIR/package.json" 2>/dev/null
}

adapter_info() {
  local pm=$(_detect_pm)
  echo "{\"runtime\":\"node\",\"tool\":\"$pm\",\"languages\":[\"typescript\",\"javascript\"]}"
}

adapter_verify() {
  # Type check if TypeScript
  if [[ -f "$PROJECT_DIR/tsconfig.json" ]]; then
    npx tsc --noEmit 2>/dev/null || true
  fi
  
  # Lint
  if _has_script "lint"; then
    _run run lint 2>/dev/null || true
  elif [[ -f "$PROJECT_DIR/.eslintrc.js" ]] || [[ -f "$PROJECT_DIR/.eslintrc.json" ]] || [[ -f "$PROJECT_DIR/eslint.config.js" ]] || [[ -f "$PROJECT_DIR/eslint.config.mjs" ]]; then
    npx eslint . 2>/dev/null || true
  fi
  
  # Test
  if _has_script "test"; then
    _run test 2>/dev/null || true
  fi
}

adapter_build() {
  if _has_script "build"; then
    _run run build
  else
    echo "No build script found in package.json"
  fi
}

adapter_test() {
  if _has_script "test"; then
    _run test
  elif [[ -f "$PROJECT_DIR/vitest.config.ts" ]] || [[ -f "$PROJECT_DIR/vitest.config.js" ]]; then
    npx vitest run
  elif [[ -f "$PROJECT_DIR/jest.config.js" ]] || [[ -f "$PROJECT_DIR/jest.config.ts" ]]; then
    npx jest
  else
    echo "No test runner found"
  fi
}

adapter_lint() {
  if _has_script "lint"; then
    _run run lint
  else
    npx eslint . 2>/dev/null || true
  fi
}

adapter_format() {
  if _has_script "format"; then
    _run run format
  else
    npx prettier --write . 2>/dev/null || true
  fi
}

adapter_run() {
  if _has_script "dev"; then
    _run run dev
  elif _has_script "start"; then
    _run start
  else
    echo "No dev or start script found"
  fi
}

adapter_clean() {
  rm -rf node_modules dist build .next out .nuxt .output .turbo 2>/dev/null || true
  echo "Cleaned node_modules, dist, build, .next, out"
}
