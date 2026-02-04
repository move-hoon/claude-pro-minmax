---
name: session-load
description: Restore saved session state. Loads previous work context and next actions.
argument-hint: [name] or --list
disable-model-invocation: true
---

# /session-load Command

Restore saved session state.

## Session Name
$ARGUMENTS

## Execution
1. No arguments: Load most recent session
2. `[name]`: Load specified session
3. `--list`: Show available sessions

## Session Directory
```
.claude/sessions/
├── 2025-01-28-auth-feature.md
├── 2025-01-27-refactor-v2.md
└── 2025-01-26-api-update.md
```

## Load Process
1. Read session file
2. Set completed tasks context
3. Display next actions
4. Prepare relevant file references

## Output (Load)
```
📂 Loaded: [name] ([date])

State: [current state description]
Completed: [number of completed tasks]
Next: [next action]

Ready to continue.
```

## Output (List)
```
📋 Available sessions:

1. auth-feature (2025-01-28) - JWT auth in progress
2. refactor-v2 (2025-01-27) - API refactoring complete
3. api-update (2025-01-26) - Endpoint additions

Load with: /session-load [name]
```

## Examples
```
/session-load                    # Most recent
/session-load auth-feature       # Specific session
/session-load --list             # Show list
```
