---
name: do
description: Direct execution without planner overhead. Use for simple bug fixes, single file changes, or clear tasks.
argument-hint: [task]
disable-model-invocation: true
---

# /do Command

Direct execution. No agent overhead.

## Task
$ARGUMENTS

## Model Selection
- Default: current session model
- For stronger model: use `/do-sonnet [task]` or `/do-opus [task]`

## Protocol
1. Check CRITICAL_ACTIONS → confirm if found
2. **Internal Planning** (no agent call): Identify files to modify, changes needed, verify approach
3. **Execute all changes** in a single pass
4. Verify with `scripts/verify.sh` (runtime-adaptive)
5. STOP + escalate after 2 retries

## Batch Execution
This command handles plan+build+verify in ONE response.
- Do NOT spawn @planner — plan internally
- Do NOT ask for confirmation between steps
- Do NOT split work across multiple messages
- Result: user sends 1 message, receives 1 complete response

## Verification (Runtime-Adaptive)
| Type | Verification |
|------|--------------|
| Config/Docs/Styles | Syntax only |
| Logic changes | `scripts/verify.sh` |

DO NOT call build tools directly. Use `scripts/verify.sh`.

## Escalation
```
Attempt 1 → FAIL → Attempt 2 → FAIL → STOP
                                     → Report error
                                     → Suggest: /do-sonnet or /plan
```
