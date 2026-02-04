> **[한국어 버전](README.ko.md)**

# Rules Directory

## Purpose
Contains always-loaded rules that Claude follows. These are loaded automatically on every session.

## Contents

| File | Purpose | Priority |
|------|---------|----------|
| `critical-actions.md` | HITL confirmation for dangerous commands | HIGHEST |
| `security.md` | Security best practices | HIGH |
| `code-style.md` | Code conventions | MEDIUM |
| `language.md` | Force output language | LOW |

## Critical Actions

The most important rule file. Defines:

1. **Direct Dangerous Commands:**
   - `git push --force`
   - `DROP TABLE`, `DELETE FROM` (no WHERE)
   - `rm -rf` on important directories

2. **Indirect Script Detection:**
   - `npm run clean`, `reset`, `nuke`
   - `yarn db:reset`, `db:drop`

3. **Git Conflict Handling:**
   - Immediate detection
   - Handoff to user (no auto-resolution)

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| No frontmatter in rule files | Rules like `critical-actions.md` and `security.md` are intentionally global. No `paths` restriction needed |
| `critical-actions.md` as plain markdown | Hook-based blocking (`critical-action-check.sh`) handles enforcement. Rule file is documentation for Claude's understanding |
| Separate `security.md` from `critical-actions.md` | Critical actions = blocking dangerous commands. Security = coding best practices. Different purposes |

## Usage

Rules are loaded automatically. No explicit command needed.

## Scope-Specific Rules (Advanced)

You can restrict rules to specific files using the `paths` frontmatter. This is useful for monorepos or mixed-language projects.

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "lib/**/*.ts"
---
# API Rules
...
```

## Advanced Organization

- **Subdirectories**: Group rules into folders (e.g., `rules/frontend/`, `rules/backend/`).
- **Symlinks**: Link to shared rule sets for consistency across projects.

## Adding Custom Rules

Create a new `.md` file:

```markdown
---
# Optional: Apply only to specific files
paths:
  - "**/*.ts"
---

# [Rule Name] Rules

## Purpose
What this rule enforces.

## ALWAYS Do
- ...

## NEVER Do
- ...
```

## Precedence

```
~/.claude/rules/*.md          (User-level, loaded first)
./project/.claude/rules/*.md  (Project-level, overrides user-level)
```

Project rules have **higher priority**. If a project rule file has the same name as a user rule file (e.g., `code-style.md`), the project version completely replaces the user version.

Project rules can override global rules if they have the same filename.

