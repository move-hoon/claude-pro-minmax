---
name: review
description: Code review using @reviewer agent. Checks security, type safety, performance, and logic errors. Use after code changes for quality verification.
argument-hint: [file or directory] or --security [target] or --all
context: fork
agent: reviewer
allowed-tools: Read, Grep, Glob
---

# /review Command

Code review. Runs in @reviewer subagent context (read-only).

## Target
$ARGUMENTS

## Options
- Default: Review specified file/directory
- `--security`: Security-focused review
- `--all`: Review all changes

## Execution
This command runs in forked @reviewer context:
- Isolated from main conversation
- Read-only access (enforced by agent)
- Results summarized and returned

## Categories
- **SEC**: Security (highest priority)
- **TYPE**: Type safety
- **PERF**: Performance
- **LOGIC**: Logic errors
- **STYLE**: Coding conventions
- **TEST**: Missing tests

## Output Format (Pass)
```
PASS - [X files reviewed, no issues]
```

## Output Format (Fail)
```
FAIL - [N issues]

1. [SEC] file:line - [issue] → [fix]
2. [TYPE] file:line - [issue] → [fix]

Auto-fix: [command if available]
```

## Rules
- Max 5 issues per file
- Must include fix suggestion
- Must check for secrets
- **READ-ONLY** - no file modifications (enforced by context: fork + agent: reviewer)
