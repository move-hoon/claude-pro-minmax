---
name: do-opus
description: Direct execution with Opus model for critical decisions. Use for the most complex tasks requiring maximum reasoning.
argument-hint: [task]
context: fork
model: opus
---

# /do-opus Command

Direct execution with Opus model via subagent.

## Task
$ARGUMENTS

## Protocol
1. Check CRITICAL_ACTIONS → confirm if found
2. **Snapshot**: `scripts/snapshot.sh push cpmm-opus`
3. Execute immediately (no planner)
4. Verify with `scripts/verify.sh` (runtime-adaptive)
5. **On Success**: `scripts/snapshot.sh drop`
6. **On Failure (2 retries)**: `scripts/snapshot.sh pop`. Then STOP + escalate.

## Verification (Runtime-Adaptive)
| Type | Verification |
|------|--------------|
| Config/Docs/Styles | Syntax only |
| Logic changes | `scripts/verify.sh` |

DO NOT call build tools directly. Use `scripts/verify.sh`.

## Cost Note
Opus is the most expensive model. Use only when:
- Sonnet also failed on the task
- Critical architectural decisions
- Tasks requiring maximum reasoning depth

## Escalation
```
Attempt 1 → FAIL → Attempt 2 → FAIL → STOP
                                     → Report error
                                     → Suggest: Break task into smaller pieces
```
