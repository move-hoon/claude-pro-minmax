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
2. **Snapshot**: `scripts/snapshot.sh push` → outputs `SNAPSHOT=true` or `SNAPSHOT=false`
3. **Internal Planning** (no agent call): Identify files to modify, changes needed, verify approach
4. **Execute all changes** in a single pass
5. Verify with `scripts/verify.sh` (runtime-adaptive)
6. **On Success**: `scripts/snapshot.sh drop` (auto-checks label — safe no-op if no snapshot)
7. **On Failure (2 retries exhausted)**: `scripts/snapshot.sh pop` (restores snapshot or `git checkout .` fallback). Then escalate.

## Batch Execution
This command handles plan+build+verify in ONE response.
- Do NOT spawn @planner — plan internally
- Do NOT ask for confirmation between steps
- Do NOT split work across multiple messages
- Result: user sends 1 message, receives 1 complete response

## Atomic Rollback
All rollback logic is in `scripts/snapshot.sh` (deterministic, not model-reasoned):
- **`push`**: Depth guard + labeled stash. Returns `SNAPSHOT=true/false`.
- **`drop`**: Label check before drop. Safe no-op if no cpmm stash exists.
- **`pop`**: Label check before pop. Falls back to `git checkout .` if no cpmm stash.
- Cost: 0 API tokens (local git operation)
- Limitation: Untracked (new) files are NOT stashed. For full cleanup after failure: `git clean -fd`

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
