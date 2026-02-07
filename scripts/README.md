> **[한국어 버전](README.ko.md)**

# Scripts Directory

## Purpose
Contains deterministic scripts for operations that shouldn't be "prompted" - they should be "coded".

**Philosophy:** "Don't prompt what you can code."

## Universal Scripts

| Script | Purpose | Benefit |
|--------|---------|---------|
| `verify.sh` | Runtime-adaptive verification (build+test+lint) | Deterministic execution, no prompting needed |
| `build.sh` | Runtime-adaptive build | Auto-detects runtime, eliminates model guessing |
| `test.sh` | Runtime-adaptive test | Direct execution, 100% accuracy |
| `lint.sh` | Runtime-adaptive lint | Local processing, instant results |

## Runtime Detection Layer

```
runtime/
├── detect.sh         # Auto-detect project runtime (JSON output)
└── adapters/
    ├── _interface.sh # Adapter contract definition
    ├── jvm.sh        # Java/Kotlin (Gradle/Maven)
    ├── node.sh       # TypeScript/JS (npm/pnpm/yarn/bun)
    ├── go.sh         # Go modules
    ├── rust.sh       # Cargo
    ├── python.sh     # pip/poetry/uv
    ├── generic.sh    # Makefile fallback
    └── _template.sh  # Template for new adapters
```

## Utility Scripts

| Script | Purpose | Benefit |
|--------|---------|---------|
| `scrub-secrets.js` | Remove secrets from text | Security + no token exposure |
| `analyze-failures.sh` | Analyze tool failure logs and extract patterns | Preprocesses logs before LLM analysis |
| `create-branch.sh` | Deterministic branch creation | Consistent naming, no guessing |
| `commit.sh` | Conventional commit format | Enforces convention automatically |
| `snapshot.sh` | Atomic rollback for `/do` commands | Deterministic `git stash` with depth guard + label safety |

## Hooks Directory

| Hook Script | Event | Purpose | Execution Cost |
|-------------|-------|---------|----------------|
| `hooks/critical-action-check.sh` | PreToolUse | Block dangerous commands | Local (zero), blocking message if triggered |
| `hooks/post-edit-format.sh` | PostToolUse | Auto-format edited files | Local (zero) |
| `hooks/compact-suggest.sh` | PostToolUse | 3-tier compact warnings (25 advisory / 50 warning / 75 critical) | Local (zero), ~30 tokens per tier |
| `hooks/notification.sh` | Notification | Desktop alerts | Local (zero) |
| `hooks/session-start.sh` | SessionStart | Env setup + budget reminder + session notify | Local (zero), ~40 input tokens for budget context |
| `hooks/session-cleanup.sh` | SessionEnd | Scrub secrets from sessions | Local (zero) |
| `hooks/retry-check.sh` | Stop | 2-retry cap (builder) | Local (zero), escalation message if triggered |
| `hooks/readonly-check.sh` | PreToolUse | Read-only (reviewer) | Local (zero), blocking message if triggered |
| `hooks/tool-failure-log.sh` | PostToolUseFailure | Log tool failures | Local (zero) |

**Note:** Hook execution itself is free (runs locally). Only their output messages (when displayed to Claude) consume minimal input tokens.

## scrub-secrets.js

**Purpose:** Scan and replace 15+ secret patterns.

**Usage:**
```bash
# Pipe input
cat session.md | node scrub-secrets.js > clean.md

# Used automatically by /session-save
```

**Patterns detected:**
- OpenAI, Anthropic, Stripe, GitHub, AWS keys
- Database URLs with credentials
- JWT tokens
- Password/secret fields
- Private keys (PEM)

## create-branch.sh

**Purpose:** Deterministic branch naming.

**Usage:**
```bash
./create-branch.sh feature user-profile
# Creates: feature/user-profile

./create-branch.sh fix login-bug
# Creates: fix/login-bug
```

**Types:** feature, fix, hotfix, refactor, chore

## analyze-failures.sh

**Purpose:** Analyze accumulated tool failure logs and extract recurring patterns.

**Usage:**
```bash
# Analyze last 50 failures
./analyze-failures.sh 50

# Used by /analyze-failures command
# Preprocesses logs before LLM analysis
```

**Output:** Formatted failure summary ready for LLM analysis

## commit.sh

**Purpose:** Conventional commit formatting.

**Usage:**
```bash
./commit.sh feat auth "add JWT refresh tokens"
# Commits: feat(auth): add JWT refresh tokens
```

**Types:** feat, fix, docs, style, refactor, perf, test, chore

## Why Scripts?

| Approach | Execution Cost | Accuracy | Speed |
|----------|---------------|----------|-------|
| Prompt Claude | Consumes quota | Model-dependent | Requires API round-trip |
| Shell script | Local (zero) | Deterministic (100%) | Instant |

**Advantage:** Scripts handle deterministic operations locally without consuming quota, freeing Claude to focus on creative/reasoning tasks.

## Adding Custom Scripts

```bash
#!/bin/bash
# my-script.sh - Description

set -e  # Exit on error

# Your deterministic logic here
```

Make executable:
```bash
chmod +x ~/.claude/scripts/my-script.sh
```

