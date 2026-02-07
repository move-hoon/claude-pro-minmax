> **[한국어 버전](README.ko.md)**

# Sessions Directory

## Purpose
Stores session state files created by `/session-save`. Enables continuity across sessions.

## Session Lifecycle

```mermaid
flowchart TB
    %% Style definitions %%
    classDef command fill:#e8f5e9,stroke:#43a047,stroke-width:2px;
    classDef file fill:#fff3e0,stroke:#fb8c00,stroke-width:2px;
    classDef process fill:#e3f2fd,stroke:#1e88e5,stroke-width:2px;
    classDef hook fill:#ffebee,stroke:#e53935,stroke-width:2px;
    classDef builtin fill:#f3e5f5,stroke:#8e24aa,stroke-width:2px;
    classDef note fill:#fffde7,stroke:#fdd835,stroke-width:1px,stroke-dasharray: 3 3;

    %% Main Session Flow %%
    Start((🚀 Session Start)):::process
    Start --> Work[🔨 Working on Tasks]:::process
    
    Work --> Decision{Save Session?}:::process
    Decision -->|Yes| SaveCmd[/"💾 /session-save auth-feature"/]:::command
    Decision -->|No| Continue[Continue Working]:::process
    Continue --> Work
    
    %% Save Process %%
    SaveCmd --> Collect["📋 Collect State<br/>• Completed tasks<br/>• Current state<br/>• Next actions<br/>• Key files"]:::process
    Collect --> Scrub{{"🔐 scrub-secrets.js<br/>Remove 15+ secret patterns"}}:::hook
    Scrub --> Write["✍️ Write to<br/>.claude/sessions/<br/>2025-01-28-auth-feature.md"]:::file
    Write --> Notify["✅ Session saved!<br/>Scrubbed: N secrets"]:::note
    
    %% Load Process %%
    Notify -.->|"Later..."| LoadStart((📂 New Session)):::process
    LoadStart --> LoadCmd[/"📂 /session-load auth-feature"/]:::command
    LoadCmd --> Read["📖 Read session file"]:::process
    Read --> Restore["🔄 Restore Context<br/>• Set completed tasks<br/>• Load next actions<br/>• Reference key files"]:::process
    Restore --> Ready["✅ Ready to continue!"]:::note
    
    %% Built-in Alternative %%
    subgraph BuiltInCLI["🔧 Alternative: Built-in CLI"]
        direction TB
        BuiltinNote["For exact conversation replay<br/>(not human-readable summary)"]:::note
        CLI1["claude -c / --continue<br/>→ Resume most recent"]:::builtin
        CLI2["claude -r abc123 / --resume abc123<br/>→ Resume specific session"]:::builtin
        JSONL["~/.claude/projects/*.jsonl<br/>(raw conversation history)"]:::file
        CLI1 --> JSONL
        CLI2 --> JSONL
    end
```

### Custom vs Built-in Sessions

| Feature | `/session-save` + `/session-load` | `claude --continue` |
|---------|-----------------------------------|---------------------|
| **Format** | Human-readable `.md` | Raw `.jsonl` |
| **Location** | `.claude/sessions/` (project) | `~/.claude/projects/` (global) |
| **Content** | Summary (tasks, decisions, next steps) | Full conversation transcript |
| **Secret Scrubbing** | ✅ Automatic | ❌ Not scrubbed |
| **Best For** | Sharing context, documentation | Exact conversation replay |

### When to Use What?

| Situation | Recommended | Why |
|-----------|-------------|-----|
| Short break (same day) | `claude -c` | Fast, exact conversation resume |
| Long break (next day) | `/session-load` | Load only key context, reduce cost |
| Share context with team | `/session-save` | Human-readable `.md` for sharing |
| After working with secrets | `/session-save` | Auto-scrubbing for safety |
| Need exact conversation | `claude --resume` | Full transcript replay |

### Recommended Workflow

```
📅 Day 1 Morning: Start new task
📅 Day 1 Afternoon: After lunch → claude -c (quick resume with built-in CLI)
📅 Day 1 Evening: /session-save feature-v1 (save work summary)

📅 Day 2: /session-load feature-v1 (start fresh with clean context)
📅 Day 2 Afternoon: claude -c (quick resume same day)
📅 Day 2 Evening: /session-save feature-v2 (save progress)
```

> **💡 Tip**: These two systems are **complementary, not competing**. Use both based on the situation!

## File Naming

```
YYYY-MM-DD-[name].md
```

Examples:
- `2025-01-27-auth-jwt.md`
- `2025-01-27-payment-integration.md`

## Security

**All session files are automatically scrubbed before writing.**

Scrubbed patterns include:
- API keys (OpenAI, Anthropic, Stripe, GitHub, AWS)
- Database URLs with credentials
- JWT tokens
- Password fields
- Private keys

## Usage

```bash
# Save current session
/session-save auth-feature

# Load most recent
/session-load

# Load specific session
/session-load auth-feature

# List available sessions
/session-load --list
```

## Session File Format

```markdown
# Session: [name]
Date: [timestamp]
Duration: [messages]
Security: [items scrubbed]

## Context
- Project: [name]
- Branch: [branch]
- Focus: [description]

## Completed
- [x] [task]

## In Progress
- [ ] [task] - [status]

## Decisions Made
- [decision]: [reasoning]

## Next Steps
1. [action]

## Key Files
- [file]: [why relevant]

## Loaded Contexts
- [type]: [status]

## Learned Patterns
- [pattern]
```

## Maintenance

```bash
# List sessions
ls -la .claude/sessions/

# Delete old sessions (>30 days)
find .claude/sessions/ -mtime +30 -delete

# Manual scrub (if needed)
node ~/.claude/scripts/scrub-secrets.js < session.md > clean.md
```

## Claude Built-in Session Commands

In addition to custom `/session-save` and `/session-load`, Claude Code has built-in session features:

| Command | Purpose |
|---------|---------|
| `claude -c` / `--continue` | Resume most recent session |
| `claude -r "id"` / `--resume "id"` | Resume specific session by ID |
| `claude --resume` | Show recent sessions to select |

> **Note:** Built-in sessions are stored in `~/.claude/projects/.../*.jsonl`. Custom `/session-save` creates human-readable `.md` summaries in `.claude/sessions/`.

## Best Practices

1. Save after completing logical phases
2. Save before long breaks (>4 hours)
3. Use descriptive names
4. Prune old sessions periodically
5. **Ensure scripts are executable**: `chmod +x ~/.claude/scripts/hooks/*.sh`

