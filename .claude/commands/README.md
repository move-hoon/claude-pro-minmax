> **[한국어 버전](README.ko.md)**

# Commands Directory

## Purpose
Contains slash command definitions for common workflows.

## Contents

| Command | Purpose | Key Feature |
|---------|---------|-------------|
| `do.md` | Batch execution | Plan+build+verify in ONE response. /do-sonnet for model override |
| `do-sonnet.md` | Execute with Sonnet | context: fork, model: sonnet |
| `do-opus.md` | Execute with Opus | context: fork, model: opus |
| `plan.md` | Complex tasks | @planner → @builder chain |
| `dplan.md` | Deep Planning | @dplanner (Sequential Thinking + Perplexity + Context7) |
| `review.md` | Code review | Read-only, categories |
| `learn.md` | Capture patterns | Auto-extract or explicit |
| `session-save.md` | Save state | Secret scrubbing |
| `session-load.md` | Resume work | Context restoration |
| `load-context.md` | Load context | Read tool, cost economy |
| `compact-phase.md` | Strategic compact | Phase-aware pruning |
| `watch.md` | tmux monitoring | Zero message cost |
| `llms-txt.md` | LLM Documentation | Fetch /llms.txt from URLs |
| `analyze-failures.md` | Analyze tool errors | Hybrid learning (log + analyze) |

## Command Categories

### Execution Commands
| Command | When to Use | Resource Usage |
|---------|-------------|----------------|
| `/do` | Simple-to-medium tasks (1-3 files). Batch plan+build+verify | Minimal (Haiku default) |
| `/do-sonnet` | Complex logic requiring deeper reasoning | Moderate (Sonnet) |
| `/do-opus` | Critical decisions, Sonnet failed | Higher (Opus—API pricing reflects cost) |
| `/plan` | Multi-file tasks, architecture decisions | Moderate (Sonnet → Haiku chain) |
| `/dplan` | Research-heavy, complex architecture | Higher (Sonnet + MCP tools) |

### Quality Assurance
| Command | When to Use | Resource Usage |
|---------|-------------|----------------|
| `/review` | Post-implementation quality check | Minimal (Haiku, read-only) |

### Session Management
| Command | When to Use | Resource Usage |
|---------|-------------|----------------|
| `/session-save` | Save work summary for later | Local script (zero API usage) |
| `/session-load` | Resume previous work | Minimal (Read tool for context) |

### Context Management
| Command | When to Use | Resource Usage |
|---------|-------------|----------------|
| `/load-context` | Load project context templates | Minimal (Read tool) |
| `/compact-phase` | Strategic context pruning | Guidance only (no execution) |

### Learning & Analysis
| Command | When to Use | Resource Usage |
|---------|-------------|----------------|
| `/learn` | Capture patterns for future reference | Minimal (Write to learned/) |
| `/analyze-failures` | Analyze accumulated tool failures | Moderate (requires LLM analysis) |

### Utilities
| Command | When to Use | Resource Usage |
|---------|-------------|----------------|
| `/watch` | Monitor long-running processes | Local tmux (zero API usage) |
| `/llms-txt` | Fetch LLM-optimized documentation | Minimal (WebFetch) |

## Workflow Examples

### Simple Feature Implementation
```bash
# 1. Direct execution for simple, well-defined tasks
/do Create a user service with CRUD operations

# 2. Review after implementation
/review src/services/user-service.ts
```
**Quota:** Low (Haiku execution + Haiku review)

### Complex Feature Implementation
```bash
# 1. Plan architecture first
/plan Add JWT authentication with refresh tokens

# 2. Planner designs → Builder implements → Auto-review
# (Agent chain handles this automatically)

# 3. Manual review if needed
/review src/auth/
```
**Quota:** Medium (Sonnet planning + Haiku implementation + Haiku review)

### Research-Heavy Architecture
```bash
# 1. Deep planning with research tools
/dplan Analyze trade-offs between event sourcing and CQRS for our use case

# 2. Load relevant context after research
/load-context backend

# 3. Implement based on research findings
# (Use /plan or /do based on complexity)
```
**Quota:** High (Sonnet + Sequential Thinking + Perplexity + Context7)

### Debugging & Learning
```bash
# 1. Analyze recent failures
/analyze-failures 50

# 2. Extract patterns and create learned skills
/learn "Use type guards before accessing union properties"

# 3. Show learned patterns
/learn --show
```
**Quota:** Medium (LLM analysis of failure logs)

### Long Session Management
```bash
# 1. Load previous context
/session-load auth-feature

# 2. Work on tasks...

# 3. Save progress before break
/session-save auth-feature-v2

# 4. Compact context strategically
/compact-phase implementation
```
**Quota:** Low (mostly script-based operations)

## Command Comparison

### Execution: /do vs /do-sonnet vs /do-opus vs /plan vs /dplan

| Aspect | /do | /do-sonnet | /do-opus | /plan | /dplan |
|--------|-----|------------|----------|-------|--------|
| **Model** | Haiku (default) | Sonnet | Opus | Sonnet → Haiku | Sonnet + MCP |
| **Cost** | 1x | 5x | 25x | 6x | 10-15x |
| **Planning** | Internal (batch) | Internal (batch) | Internal (batch) | Architecture design | Deep research |
| **Use Case** | Simple tasks | Complex logic | Critical decisions | Multi-file features | Unknown unknowns |
| **Files Affected** | 1-2 | 1-3 | Any | 5+ | Any |
| **Questions** | No | No | No | ≤3 (with defaults) | Unlimited |
| **Research Tools** | No | No | No | No | Yes (Perplexity, Context7) |

**Decision Tree:**
```
Task Complexity
├─ Simple (1-2 files, clear requirements)
│   └─→ /do
│
├─ Moderate (3-5 files, some complexity)
│   ├─ Logic-heavy → /do-sonnet
│   └─ Multi-file → /plan
│
└─ Complex (5+ files, unclear approach)
    ├─ Known domain → /plan
    ├─ Needs research → /dplan
    └─ Critical/Sonnet failed → /do-opus
```

### Context: /session-save vs /load-context

| Aspect | /session-save | /load-context |
|--------|---------------|---------------|
| **Purpose** | Save entire session state | Load pre-defined templates |
| **Content** | Work history, decisions, code | Project structure, conventions |
| **Scope** | Session-specific | Project-wide patterns |
| **When** | End of work session | Start of new task |
| **Format** | Markdown summary | Structured context file |

**Use together:**
```bash
# Start of day
/session-load yesterday-work     # Resume from yesterday
/load-context backend             # Load project conventions

# End of day
/session-save today-progress      # Save for tomorrow
```

## Best Practices

### 1. Choose the Right Execution Command

**Use `/do` when:**
- Task is well-defined with clear requirements
- Affects 1-2 files only
- No architectural decisions needed
- Example: "Add validation to user input"

**Use `/plan` when:**
- Task affects 5+ files
- Requires architectural decisions
- Requirements need clarification
- Example: "Add multi-tenant support"

**Use `/dplan` when:**
- Unknown technology or pattern
- Need to evaluate multiple approaches
- Debugging complex race conditions
- Example: "Design distributed transaction handling"

**Use `/do-opus` when:**
- Task is critical (production hotfix)
- Sonnet failed after 2 retries
- Maximum reasoning capability needed
- Example: "Fix memory leak in production"

### 2. Strategic Context Management

**Compact early and often:**
```bash
# After planning phase
/compact-phase planning

# After implementation
/compact-phase implementation

# After review
/compact-phase review
```

**Load context selectively:**
```bash
# Don't load everything at once
/load-context backend     # ✓ Load what you need
/load-context frontend    # ✗ Don't load if not needed
```

### 3. Learning from Failures

**Analyze failures regularly:**
```bash
# Weekly analysis
/analyze-failures 100

# After difficult debugging session
/analyze-failures 20
```

**Capture patterns immediately:**
```bash
# Right after solving a tricky issue
/learn "Use AbortController for cancellable fetch requests"
```

### 4. Session Management

**Save at natural breakpoints:**
- End of work session
- Before switching tasks
- After major milestone
- Before experimental changes

**Load when resuming:**
- Start of work session
- Switching back to previous task
- Need context from past work

### 5. Pro Plan Optimization

**Minimize high-cost commands:**
- Use `/do` instead of `/plan` when possible
- Use `/do-sonnet` instead of `/do-opus` when possible
- Use `/plan` instead of `/dplan` when research isn't critical

**Batch operations:**
```bash
# ✗ Multiple separate /do calls
/do Create user model
/do Create user controller
/do Create user tests

# ✓ Single /plan call
/plan Create user module with model, controller, and tests
```

**Use zero-cost tools:**
- `/session-save`, `/session-load` (script-based)
- `/watch` (tmux-based)
- `/compact-phase` (guidance only)

## Usage Examples

```bash
# Direct execution (simple tasks)
/do Create a user service
/do-sonnet Implement complex caching logic

# Complex tasks (planning needed)
/plan Add user authentication with JWT
/dplan Analyze potential deadlocks in transaction manager

# Code review
/review src/auth/
/review --security

# Learning
/learn "Always use zod for validation"
/learn --show
/analyze-failures 50

# Sessions
/session-save auth-feature
/session-load

# Context
/load-context backend
/load-context frontend

# Phases
/compact-phase implementation
/watch tests
/llms-txt https://docs.example.com
```

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| `/do-sonnet` and `/do-opus` as separate commands | Frontmatter `model:` field only works with `context: fork`. Separate commands guarantee actual model switch via subagent |
| `/plan` uses `agent: planner`, `/review` uses `agent: reviewer` | These commands need specific tool restrictions. `planner` is read-only (no Write/Edit). `reviewer` is also read-only. The `agent:` field applies that agent's tools/permissions |
| `/load-context` with `disable-model-invocation: false` | Must be `false` so Claude can auto-invoke this command. If `true`, Claude cannot use Read tool to load context files |
| `/compact-phase` as guidance only | Claude Code's `/compact` requires user input. This command provides phase-specific prompts to copy-paste |

## Adding Custom Commands

Create a new `.md` file with **frontmatter** (required for official compliance):

```markdown
---
name: your-command
description: What this command does and when to use it
argument-hint: [required-arg] or --flag [optional]
disable-model-invocation: true
---

# /your-command Command

## Purpose
What this command does.

## Input
$ARGUMENTS

## Execution
1. Step one
2. Step two

## Output
\`\`\`
Expected output format
\`\`\`

## Examples
\`\`\`bash
/your-command example
\`\`\`
```

### Frontmatter Fields

| Field | Required | Description |
|-------|:--------:|-------------|
| `name` | Yes | Command name (lowercase, hyphens) |
| `description` | Yes | When to use this command (for Claude auto-invocation) |
| `argument-hint` | No | Shows in autocomplete |
| `disable-model-invocation` | No | `true` = manual only, `false` = Claude can auto-invoke |
| `allowed-tools` | No | Restrict tools (e.g., `Read, Grep`) |
| `model` | No | Force model (`sonnet`, `haiku`, `opus`) |
| `context` | No | `fork` = run in subagent context |
| `agent` | No | Subagent type when `context: fork` (e.g., `planner`, `reviewer`) |
| `hooks` | No | Lifecycle hooks (`PreToolUse`, `PostToolUse`, `Stop`) |

### Location
- Global: `~/.claude/commands/` (all projects)
- Project: `./.claude/commands/` (this project only)
