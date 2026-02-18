# CPMM User Guide (Post-Install Operations)

This guide is for users who already read `README.md` and finished installation.
It is strictly an operations guide: what to run, when to run it, and what to do next.

## 0. Operating Contract (Read Once)

- One task, one primary command.
- Write task prompts with: scope + constraints + done condition.
- After every run, decide the next command immediately (do not idle in ambiguous state).

Result interpretation:
- `/review` returns `PASS` or `FAIL`.  
  `PASS` = proceed. `FAIL` = fix and rerun review on touched paths.
- `Repeated failure` for `/do` means: attempt 1 fails and attempt 2 fails (retries exhausted), including verification failure.
- Escalation is manual. CPMM suggests next command (`/do-sonnet` or `/plan`) on failure but does not auto-switch your command.
- If `/do` fails repeatedly, escalate to `/do-sonnet`, then `/do-opus` only if still blocked.
- If a critical-action confirmation appears, either confirm intentionally or stop.

## 1. First 2 Minutes in a New Session

1. Move to your project root.
2. Set your default model for routine work:
   ```bash
   /model haiku
   ```
3. (Optional) Load context only if needed:
   ```bash
   /load-context --list
   /load-context backend
   ```
4. Start execution with `/do` for the first concrete task.

## 2. Command Router (10-Second Choice)

| Situation | Use | Example |
|---|---|---|
| Small, clear task (1-3 files) | `/do` | `/do Fix null check in user service and add minimal test.` |
| Multi-file feature (4+ files) or unclear structure | `/plan` | `/plan Add JWT refresh flow with rotation.` |
| Same as above, but plan only | `/plan --no-build` | `/plan --no-build Propose DB migration strategy for billing.` |
| Need deep research (Sequential Thinking + Perplexity + Context7) | `/dplan` | `/dplan Analyze race conditions in payment retries.` |
| `/do` failed repeatedly on logic complexity | `/do-sonnet` (~3x Haiku) | `/do-sonnet Implement conflict-safe cache invalidation.` |
| Sonnet still fails or critical decision | `/do-opus` (~5x Haiku) | `/do-opus Resolve deadlock risk in transaction coordinator.` |
| Review changes before merge | `/review` | `/review src/auth/` |
| Security-focused review | `/review --security` | `/review --security src/auth/` |
| Save progress before stopping | `/session-save` | `/session-save auth-refresh` |
| Resume previous work by name | `/session-load` | `/session-load auth-refresh` |
| Resume latest session (no name needed) | `/session-load` | `/session-load` |
| List saved sessions first | `/session-load --list` | `/session-load --list` |
| Context getting noisy — get phase-specific compact guide | `/compact-phase` | `/compact-phase implementation` |
| Compact after deep planning | `/compact-phase deep-planning` | `/compact-phase deep-planning` |
| Long-running watch (tests/dev/build) | `/watch` | `/watch tests` |
| Long-running custom command | `/watch custom` | `/watch custom \"pnpm test:e2e --watch\"` |
| Load context template (≤2 recommended) | `/load-context` | `/load-context backend` |
| Load saved session context | `/load-context session` | `/load-context session` |
| Auto-analyze session for reusable patterns | `/learn` | `/learn` |
| Capture a specific pattern | `/learn` | `/learn "Use DTO mappers for API responses"` |
| Show learned patterns | `/learn --show` | `/learn --show` |
| Analyze recurring tool failures (default: last 50) | `/analyze-failures` | `/analyze-failures 100` |
| Fetch llms.txt docs (when Context7 lacks coverage) | `/llms-txt` | `/llms-txt nextjs` |

> **Notes:**
> - `/compact-phase` does **not** compact automatically. It outputs a `/compact [instructions]` command — copy and run it yourself.
> - `/review` checks 6 categories: **SEC** (Security) · **TYPE** (Type safety) · **PERF** (Performance) · **LOGIC** (Logic errors) · **STYLE** (Conventions) · **TEST** (Missing tests).
> - Loading 3+ contexts triggers a warning. Keep it to ≤2 for optimal performance.

## 2.1 Outcome Navigation (Goal -> Done Signal)

| Goal | Start Command | Done Signal | Next Action |
|---|---|---|---|
| Ship a small fix | `/do` | Code + verification complete | `/review [path]` |
| Implement a complex feature | `/plan` | Plan approved and implemented | `/review --all` |
| Get architecture only | `/plan --no-build` | Actionable plan returned | Execute with `/do` or `/do-sonnet` |
| Investigate deep uncertainty | `/dplan` | Validated options returned | Choose option and execute |
| Run security gate | `/review --security` | Security review PASS | Merge/release flow |
| Pause safely | `/session-save` | Session file saved | Resume with `/session-load` |
| Resume unknown previous state | `/session-load --list` | Target session identified | `/session-load [name]` |
| Reduce noisy context | `/compact-phase` | Context pruned by phase | Continue current workflow |

## 3. Scenario Runbooks

### Scenario 1: Quick Bug Fix

Use when: one bug, clear scope, limited files.

```bash
/model haiku
/do Fix off-by-one error in pagination and add a regression test.
/review src/pagination/
```

If `/do` fails twice:
```bash
/do-sonnet Fix off-by-one error in pagination and add a regression test.
```

### Scenario 2: New Feature Across Multiple Files

Use when: new feature, touching several modules.

```bash
/plan Add password reset flow (API, service, email template, tests).
```

After planner returns the plan:
1. Approve and run implementation flow.
2. Run:
   ```bash
   /review src/auth/
   ```

### Scenario 3: Plan Before Coding (No Build Yet)

Use when: you need design agreement first.

```bash
/plan --no-build Design multi-tenant workspace isolation.
```

Then execute selected tasks with `/do` or `/do-sonnet`.

### Scenario 4: Unknown Domain or High-Complexity Decision

Use when: architecture uncertainty, race conditions, distributed behavior.

```bash
/dplan Validate idempotency + locking strategy for payment retries.
```

Then turn the accepted plan into execution tasks.

### Scenario 5: `/do` Keeps Failing

Use when: same task fails after retries.

Order:
1. Retry with clearer task statement.
2. Escalate to Sonnet:
   ```bash
   /do-sonnet [same task, clearer constraints]
   ```
3. If still blocked and critical:
   ```bash
   /do-opus [same task + failure context]
   ```
4. If still failing: split task into smaller chunks and rerun from Haiku/Sonnet.

### Scenario 6: Pre-Merge Quality Gate

Use when: implementation is complete.

```bash
/review --all
/review --security src/
```

Fix findings, then rerun `/review` on touched paths.

### Scenario 7: Security-Critical Change

Use when: auth, permissions, secrets, payments.

```bash
/plan Add role-based permission checks for admin endpoints.
/review --security src/auth/
/review --security src/api/
```

### Scenario 8: Long Test or Build Monitoring

Use when: watch mode or lengthy process is needed.

```bash
/watch tests
# or
/watch dev
# or
/watch build
```

Useful tmux controls:
- Detach: `Ctrl+b d`
- Reattach: `tmux attach -t claude-watch-tests`
- List sessions: `tmux ls`
- Stop session: `tmux kill-session -t claude-watch-tests`

Custom monitor example:
```bash
/watch custom "pnpm test:e2e --watch"
```

### Scenario 9: Stop Work and Resume Later

Before stopping:
```bash
/session-save checkout-refactor
```

> **Security:** `/session-save` automatically scrubs secrets (API keys, tokens, passwords — 15+ patterns) before writing the session file. No manual sanitization needed.

When returning:
```bash
/session-load --list
/session-load checkout-refactor
```

### Scenario 10: Switching Work Context (Backend <-> Frontend)

Use when: task focus changes significantly.

```bash
/load-context --list
/load-context frontend
/load-context session
/compact-phase planning
```

Load only the contexts needed for the current task.

### Scenario 11: Repeated Mistakes or Rework

Use when: similar fix appears repeatedly.

```bash
/learn "Always validate request DTO before service call"
/learn --show
```

### Scenario 12: Tool Errors Keep Repeating

Use when: edit/grep/tool failures are frequent.

```bash
/analyze-failures 100
```

Then convert stable lessons into explicit `/learn` patterns.

### Scenario 13: Need Fast Official Library Docs

Use when: syntax/API uncertainty during implementation.

```bash
/llms-txt nextjs
/llms-txt prisma
/llms-txt https://example.com/llms.txt
```

### Scenario 14: Context Is Bloated Mid-Project

Use when: conversation drift, noisy context, slower output quality.

```bash
/compact-phase planning
# or
/compact-phase implementation
# or
/compact-phase review
# or
/compact-phase deep-planning
```

> **How it works:** `/compact-phase` outputs a tailored `/compact [instructions]` command — copy and run it to perform the actual compaction. The system also auto-compacts at 75% context usage (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=75`).

## 4. Daily Operating Loops

### A. Standard Development Loop

1. `/model haiku`
2. `/do [task]`
3. `/review [changed path]`
4. Repeat
5. `/session-save [name]` before stop

### B. Complex Feature Loop

1. `/plan [feature]`
2. Approve plan
3. Implement tasks
4. `/review --all`
5. `/review --security [critical paths]`

### C. Research-to-Execution Loop

1. `/dplan [problem]`
2. Select accepted design
3. Execute via `/do` or `/do-sonnet`
4. Validate with `/review`

## 5. Escalation Rules (Operational)

**Cost ratio:** Haiku (1x) · Sonnet (~3x) · Opus (~5x)

- Default execution: `Haiku + /do`
- Escalate only when needed:
  1. `/do-sonnet` (~3x cost)
  2. `/do-opus` (~5x cost)
- Do not stay on high-cost model after the blocker is resolved.
- Move back to Haiku/Sonnet for routine follow-up work.

## 6. Copy/Paste Task Templates

### Small fix
```bash
/do Fix [bug] in [file/path]. Add minimal test. Keep diff small.
```

### Complex implementation
```bash
/plan Implement [feature]. Include affected files, migration impact, and test plan.
```

### Deep investigation
```bash
/dplan Investigate [issue]. Compare at least two design options with risks.
```

### Security review
```bash
/review --security [path]
```

### Review result interpretation
- `PASS`: proceed to merge/release flow.
- `FAIL`: fix listed items, then rerun `/review` on touched paths.

### End of day
```bash
/session-save [feature-name]
```

## 7. Anti-Patterns to Avoid

- Running `/do-opus` by default.
- Splitting one coherent task into many tiny `/do` calls when one call would do.
- Skipping `/review` before merge on non-trivial changes.
- Loading many contexts unnecessarily.
- Continuing in a noisy session without compaction.
- Ignoring rollback aftermath without checking modified/untracked files.

## 8. Quick Recovery Playbook

| Problem | Immediate Action |
|---|---|
| `/do` failed twice | Retry with clearer scope, then `/do-sonnet` |
| Sonnet failed on critical task | `/do-opus` with explicit constraints |
| Output quality degrades over time | `/compact-phase [current phase]` |
| Need to stop now | `/session-save [name]` |
| Can't remember prior progress | `/session-load --list` then load target |
| Repeated tool errors | `/analyze-failures` + `/learn` |

If rollback happened during `/do` failure:
1. Check `git status`.
2. Keep intended files.
3. Remove leftover scratch files manually if needed.

## 9. Background System Behaviors

These hooks run automatically. No commands needed — just know what the messages mean.

| Trigger | What Happens | You'll See |
|---|---|---|
| Session start | Displays Pro Plan strategy (cost ratios, message targets) | `📊 Pro Plan Strategy: ~45 msg/5h...` |
| 25 Write/Edit events | Compact advisory | `[COMPACT-ADVISORY] 25 tool calls...` |
| 50 Write/Edit events | Compact warning | `[COMPACT-WARNING] 50 tool calls...` |
| 75 Write/Edit events | Compact critical | `[COMPACT-CRITICAL] 75 tool calls...` |
| 75% context usage | Auto-compact fires (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=75`) | Automatic context reduction |
| Tool failure (every) | Logged to `~/.claude/logs/tool-failures.log` | Silent (view with `/analyze-failures`) |
| File edit | Auto-format (prettier / black / gofmt / rustfmt) | Silent |
| Before `/compact` | Pre-compact hook saves state to `~/.claude/sessions/` | Silent |
| Session end | Auto-summary saved + secrets scrubbed | Silent |
| Builder retry cap (2×) | Stops builder subagent, suggests escalation | `RETRY_CAP: 2 consecutive failures detected.` |

**Optional env settings** (`.claude/settings.json` → `env`):

| Variable | Default | Description |
|---|---|---|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `75` | Context % threshold for auto-compact |
| `CLAUDE_SESSION_NOTIFY` | `0` | Set `1` to detect prior sessions on start |
| `CLAUDE_FAILURE_NOTIFY` | `0` | Set `1` to auto-suggest `/analyze-failures` after 10+ cumulative failures |
