#!/bin/bash
# detect.sh - Runtime Detection with Monorepo Support
# OCP Runtime-Adaptive Architecture
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
TARGET_DIR="$PROJECT_DIR"

# Parse --path argument for Monorepo support
while [[ $# -gt 0 ]]; do
  case $1 in
    --path) TARGET_DIR="$PROJECT_DIR/$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Detection priority order
detect_runtime() {
  local dir="$1"
  
  # JVM (Gradle > Maven)
  [[ -f "$dir/build.gradle.kts" ]] && echo '{"runtime":"jvm","tool":"gradle-kts","adapter":"jvm.sh"}' && return
  [[ -f "$dir/build.gradle" ]] && echo '{"runtime":"jvm","tool":"gradle","adapter":"jvm.sh"}' && return
  [[ -f "$dir/pom.xml" ]] && echo '{"runtime":"jvm","tool":"maven","adapter":"jvm.sh"}' && return
  
  # Node (detect package manager)
  if [[ -f "$dir/package.json" ]]; then
    [[ -f "$dir/pnpm-lock.yaml" ]] && echo '{"runtime":"node","tool":"pnpm","adapter":"node.sh"}' && return
    [[ -f "$dir/yarn.lock" ]] && echo '{"runtime":"node","tool":"yarn","adapter":"node.sh"}' && return
    [[ -f "$dir/bun.lockb" ]] && echo '{"runtime":"node","tool":"bun","adapter":"node.sh"}' && return
    echo '{"runtime":"node","tool":"npm","adapter":"node.sh"}' && return
  fi
  
  # Rust
  [[ -f "$dir/Cargo.toml" ]] && echo '{"runtime":"rust","tool":"cargo","adapter":"rust.sh"}' && return
  
  # Go
  [[ -f "$dir/go.mod" ]] && echo '{"runtime":"go","tool":"go","adapter":"go.sh"}' && return
  
  # Python (check lock files first for accurate tool detection)
  if [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/setup.py" ]] || [[ -f "$dir/requirements.txt" ]]; then
    [[ -f "$dir/poetry.lock" ]] && echo '{"runtime":"python","tool":"poetry","adapter":"python.sh"}' && return
    [[ -f "$dir/uv.lock" ]] && echo '{"runtime":"python","tool":"uv","adapter":"python.sh"}' && return
    [[ -f "$dir/Pipfile.lock" ]] && echo '{"runtime":"python","tool":"pipenv","adapter":"python.sh"}' && return
    echo '{"runtime":"python","tool":"pip","adapter":"python.sh"}' && return
  fi
  
  # Generic fallback
  echo '{"runtime":"generic","tool":"make","adapter":"generic.sh"}'
}

detect_runtime "$TARGET_DIR"
