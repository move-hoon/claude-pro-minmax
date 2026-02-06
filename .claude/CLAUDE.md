# Claude Code Pro Plan Kernel
# IMMUTABLE KERNEL

## IDENTITY
Pro Plan constraints. Every message = quota. Optimize for Pass@1.

## PRINCIPLES

### Message Economy
- Batch operations in single response, no round-trips
- Assume → Execute → User corrects
- No preamble: Skip "I'll help you..." → Execute immediately

### Value Per Message
- Output costs 5x Input — keep agent responses short
- `CLI --json | jq` > MCP tools (filtered output reduces tokens)
- `mgrep` > `grep` (faster, less output)
- Load context: `/load-context [type]` (Read tool)
- **Learned Patterns**: Always index `~/.claude/skills/learned/*.md` at session start to reuse previous insights and prevent rework.

### Pass@1 + 2-Retry Cap
- Internal verification before output
- Maximum 2 retries
- 2 failures → STOP + Escalate

### Code > Prompt
- Deterministic logic → Scripts
- Project Metadata → Always use `~/.claude/scripts/runtime/detect.sh` for runtime/build tool detection. Never read build files (pom.xml, build.gradle, package.json, tsconfig.json) manually for this purpose.
- Filenames, branches → Scripts, not reasoning

## VERIFICATION

| Change Type | Verification |
|-------------|-------------|
| Config, Docs, Styles (<5 lines) | Syntax check only |
| Logic changes | `scripts/verify.sh` |
| New features | `scripts/verify.sh` + tests |

⚠️ Never call build tools directly:
- ❌ `npm test`, `./gradlew test`, `cargo test`
- ✅ `scripts/verify.sh`

## AGENTS

| Role | Agent | Model | Questions |
|------|-------|-------|-----------|
| Quick Planning | @planner | Sonnet | ≤3 (with defaults) |
| Deep Planning (w/ Research) | @dplanner | Sonnet | Unlimited |
| Implementation | @builder | Haiku | None → Escalate |
| Quality Review | @reviewer | Haiku | None → Escalate |

@dplanner tools: `sequential-thinking`, `perplexity`, `context7`

## DEFAULT WORKFLOW
- Simple (1-3 files): `/do` — batch plan+build+verify in one shot
- Medium (4-5 files): `/plan` — @planner → @builder sequential
- Complex (5+ files, research): `/dplan` — @dplanner → @planner → @builder

## SECRETS
Never persist to session files: `sk-*`, `ghp_*`, `AKIA*`, JWT, passwords
