---
name: do-sonnet
description: Direct execution with Sonnet model for complex logic. Use when default /do fails or task requires deeper reasoning.
argument-hint: [task]
context: fork
model: sonnet
---

# /do-sonnet Command

Direct execution with Sonnet model via subagent.

## Task
$ARGUMENTS

## Protocol
1. Check CRITICAL_ACTIONS → confirm if found
2. **Snapshot**: `scripts/snapshot.sh push cpmm-sonnet`
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
Sonnet costs ~12x more than Haiku. Use only when:
- Default `/do` failed after 2 retries
- Task requires complex reasoning or multi-step logic
- Architecture-level code changes

## Escalation
```
Attempt 1 → FAIL → Attempt 2 → FAIL → STOP
                                     → Report error
                                     → Suggest: /plan for architecture review
```
