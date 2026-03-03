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
  [[ -f "$PROJECT_DIR/package.json" ]] || return 1
  if command -v jq &>/dev/null; then
    jq -e ".scripts.\"$script\"" "$PROJECT_DIR/package.json" &>/dev/null
  else
    grep -q "\"$script\":" "$PROJECT_DIR/package.json" 2>/dev/null
  fi
}

adapter_info() {
  local pm=$(_detect_pm)
  echo "{\"runtime\":\"node\",\"tool\":\"$pm\",\"languages\":[\"typescript\",\"javascript\"]}"
}

adapter_verify() {
  ( cd "$PROJECT_DIR"
    # Type check if TypeScript
    if [[ -f tsconfig.json ]]; then
      npx --no-install tsc --noEmit 2>&1 || true
    fi

    # Lint
    if _has_script "lint"; then
      _run run lint 2>&1 || true
    elif [[ -f .eslintrc.js ]] || [[ -f .eslintrc.json ]] || [[ -f eslint.config.js ]] || [[ -f eslint.config.mjs ]]; then
      npx --no-install eslint . 2>&1 || true
    fi

    # Test
    if _has_script "test"; then
      _run test 2>&1 || true
    fi
  )
}

adapter_build() {
  ( cd "$PROJECT_DIR"
    if _has_script "build"; then
      _run run build
    else
      echo "No build script found in package.json"
    fi
  )
}

adapter_test() {
  ( cd "$PROJECT_DIR"
    if _has_script "test"; then
      _run test
    elif [[ -f vitest.config.ts ]] || [[ -f vitest.config.js ]]; then
      npx --no-install vitest run
    elif [[ -f jest.config.js ]] || [[ -f jest.config.ts ]]; then
      npx --no-install jest
    else
      echo "No test runner found"
    fi
  )
}

adapter_lint() {
  ( cd "$PROJECT_DIR"
    if _has_script "lint"; then
      _run run lint
    else
      npx --no-install eslint . 2>&1 || true
    fi
  )
}

adapter_format() {
  ( cd "$PROJECT_DIR"
    if _has_script "format"; then
      _run run format
    else
      npx --no-install prettier --write . 2>&1 || true
    fi
  )
}

adapter_run() {
  ( cd "$PROJECT_DIR"
    if _has_script "dev"; then
      _run run dev
    elif _has_script "start"; then
      _run start
    else
      echo "No dev or start script found"
    fi
  )
}

adapter_clean() {
  ( cd "$PROJECT_DIR"
    rm -rf node_modules dist build .next out .nuxt .output .turbo 2>&1 || true
    echo "Cleaned node_modules, dist, build, .next, out, .nuxt, .output, .turbo"
  )
}
