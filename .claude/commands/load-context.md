---
name: load-context
description: Load project context files. Reads backend, frontend, or session context into conversation.
argument-hint: [type] or --list
disable-model-invocation: false
---

# /load-context Command

Load project context using Read tool.

## Input
$ARGUMENTS

## Execution
1. `[type]`: Read `.claude/contexts/[type]-context.md` file into conversation
2. `--list`: List available context files in `.claude/contexts/`

## Context Types & Files
| Type | File |
|------|------|
| backend | `.claude/contexts/backend-context.md` |
| frontend | `.claude/contexts/frontend-context.md` |
| session | Most recent file from `.claude/sessions/` |

## Cost Economy
Warning when more than 2 contexts loaded in a session:
```
⚠️ WARNING: 3 contexts loaded (backend, frontend, session)
Consider starting a new session or using /compact-phase to reduce context.
```

## Output
```
📂 Context loaded: [type]

Content from: .claude/contexts/[type]-context.md
[actual file content displayed]
```

## Examples
```
/load-context backend           # Read backend context file
/load-context frontend          # Read frontend context file
/load-context --list            # List available context files
```
