---
name: session-save
description: Save session state with automatic secret scrubbing. Use to preserve work state when pausing.
argument-hint: [name]
disable-model-invocation: true
---

# /session-save Command

Save session state with automatic secret scrubbing.

## Session Name
$ARGUMENTS

## Execution
1. Collect session state (completed tasks, next actions, context)
2. Scrub 15+ secret patterns via `~/.claude/scripts/scrub-secrets.js`
3. Save to session file

## File Naming Options
```bash
# Option 1: With session ID (recommended for uniqueness)
.claude/sessions/${CLAUDE_SESSION_ID}-[name].md

# Option 2: With date (human-readable)
.claude/sessions/YYYY-MM-DD-[name].md
```

## Security (Auto-Scrub)
Patterns automatically removed before saving:
- API keys (OpenAI, Stripe, GitHub, AWS, Google)
- Database URLs with credentials
- JWT tokens, Bearer tokens
- Password/secret fields
- Private keys (RSA, SSH)
- Environment variables with secrets

## Session File Format
```markdown
---
session_id: ${CLAUDE_SESSION_ID}
date: YYYY-MM-DD HH:MM
name: [session-name]
project: [project-path]
---

# Session: [name]

## Completed Tasks
- [completed task list]

## Current State
[current state description]

## Next Actions
- [next action list]

## Context
- Files: [relevant files]
- Decisions: [decisions made]
```

## Output
```
Session saved: .claude/sessions/[filename].md

Security scan:
- Scrubbed: [N] potential secrets
- Clean: No secrets in final file

Resume with: /session-load [name]
```

## Examples
```
/session-save                    # Auto-generate name with session ID
/session-save auth-feature       # Named session
/session-save refactor-v2        # With version
```
