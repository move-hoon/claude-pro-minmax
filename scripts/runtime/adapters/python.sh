#!/bin/bash
# python.sh - Python Adapter
# Supports pip, poetry, uv
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

_detect_tool() {
  [[ -f "$PROJECT_DIR/poetry.lock" ]] && echo "poetry" && return
  [[ -f "$PROJECT_DIR/uv.lock" ]] && echo "uv" && return
  [[ -f "$PROJECT_DIR/Pipfile.lock" ]] && echo "pipenv" && return
  echo "pip"
}

_run() {
  local tool=$(_detect_tool)
  case $tool in
    poetry) poetry run "$@" ;;
    uv) uv run "$@" ;;
    pipenv) pipenv run "$@" ;;
    *) python -m "$@" ;;
  esac
}

adapter_info() {
  local tool=$(_detect_tool)
  echo "{\"runtime\":\"python\",\"tool\":\"$tool\",\"languages\":[\"python\"]}"
}

adapter_verify() {
  cd "$PROJECT_DIR"
  local tool=$(_detect_tool)
  
  # Type check with mypy
  case $tool in
    poetry) poetry run mypy . 2>/dev/null || true ;;
    uv) uv run mypy . 2>/dev/null || true ;;
    *) python -m mypy . 2>/dev/null || true ;;
  esac
  
  # Run tests
  case $tool in
    poetry) poetry run pytest ;;
    uv) uv run pytest ;;
    *) python -m pytest ;;
  esac
}

adapter_build() {
  cd "$PROJECT_DIR"
  local tool=$(_detect_tool)
  
  case $tool in
    poetry) poetry build ;;
    uv) uv build 2>/dev/null || python -m build ;;
    *) python -m build ;;
  esac
}

adapter_test() {
  cd "$PROJECT_DIR"
  local tool=$(_detect_tool)
  
  case $tool in
    poetry) poetry run pytest ;;
    uv) uv run pytest ;;
    *) python -m pytest ;;
  esac
}

adapter_lint() {
  cd "$PROJECT_DIR"
  # Try ruff first (faster), then flake8
  if command -v ruff &>/dev/null; then
    ruff check .
  elif command -v flake8 &>/dev/null; then
    flake8 .
  else
    _run flake8 . 2>/dev/null || true
  fi
}

adapter_format() {
  cd "$PROJECT_DIR"
  # Try ruff format first, then black
  if command -v ruff &>/dev/null; then
    ruff format .
  elif command -v black &>/dev/null; then
    black .
  else
    _run black . 2>/dev/null || true
  fi
}

adapter_run() {
  cd "$PROJECT_DIR"
  local tool=$(_detect_tool)
  
  if [[ -f "$PROJECT_DIR/manage.py" ]]; then
    # Django
    _run python manage.py runserver
  elif [[ -f "$PROJECT_DIR/app.py" ]]; then
    _run python app.py
  elif [[ -f "$PROJECT_DIR/main.py" ]]; then
    _run python main.py
  else
    echo "No entry point found (manage.py, app.py, main.py)"
  fi
}

adapter_clean() {
  cd "$PROJECT_DIR"
  rm -rf __pycache__ .pytest_cache .mypy_cache .ruff_cache dist build *.egg-info .eggs 2>/dev/null || true
  find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
  echo "Cleaned Python cache and build directories"
}
