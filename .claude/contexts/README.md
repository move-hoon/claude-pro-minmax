> **[한국어 버전](README.ko.md)**

# Contexts Directory

## Purpose
Contains **project reference data** for lazy loading. These are NOT loaded automatically—use `/load-context` to load them on demand.

Context files are static project information (API endpoints, DB schema, env vars). They differ from sessions, which track in-progress work state.

| | Contexts | Sessions |
|--|----------|----------|
| **Nature** | Static project reference data | In-progress work state |
| **Changes** | Only when project structure changes | Every session |
| **Examples** | API endpoints, DB schema, env vars | Progress, decisions, next steps |
| **Save needed** | No (files are already persisted) | Yes (`/session-save` each time) |

## Contents

| File | Purpose | When to Load |
|------|---------|--------------|
| `backend-context.md` | API endpoints, DB schema, env vars | Backend development |
| `frontend-context.md` | Components, state, routes | Frontend development |

## Usage

```bash
# Load when starting work
/load-context backend

# Check what's available
/load-context --list

# Switch focus
/load-context frontend
```

## Why Lazy Loading?

1. **Prompt Cache Efficiency:** CLAUDE.md stays immutable, maximizing cache hits
2. **Cost Economy:** Only load what you need (Pro Plan: every message = quota)
3. **Focused Context:** Avoid loading frontend schema during backend work

## Instruction Hierarchy

> **Important:** `/load-context` uses the Read tool, so content loads at **tool output level** — the lowest priority in Claude's instruction hierarchy.

```
System prompt (highest)  ← CLAUDE.md, rules/, --system-prompt
User messages            ← Your prompts
Tool output (lowest)     ← /load-context, @file, Read tool
```

**What this means:**
- Context files are **reference data** Claude uses — this is fine at tool output level
- **Strict rules** Claude must follow → put in `.claude/rules/` instead (auto-loaded, system prompt level)
- For advanced use: `claude --system-prompt "$(cat context.md)"` injects at system prompt level

**Alternative — `@import` in CLAUDE.md:**
```markdown
# In CLAUDE.md
- @.claude/contexts/backend-context.md
```
This loads at system prompt level, but loads **every session** (no lazy loading). Use only for always-needed context.

## Template

```markdown
# [Project] Context

## Tech Stack
- Runtime: [...]
- Framework: [...]
- Database: [...]

## API Endpoints
| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| ... | ... | ... | ... | ... |

## Key Information
- ...

## Recent Changes
- [date]: [change]
```

## Best Practices

1. Keep context files under 100 lines
2. Update after major changes
3. Don't include secrets (they'll be scrubbed anyway)
4. Focus on **reference data** Claude needs to know
5. Put **behavioral rules** in `.claude/rules/` instead — higher instruction priority
6. Avoid loading more than 2 contexts per session
