---
name: plan
description: Complex task planning with @planner to @builder chain. Use when affecting 4+ files, requiring architecture decisions, unclear requirements, or new feature implementation.
argument-hint: [feature description] or --no-build [description]
context: fork
agent: planner
---

# /plan Command

For complex tasks. Runs in @planner subagent context.

## Feature Request
$ARGUMENTS

## Options
- Default: Plan then implement
- `--no-build`: Plan only, no implementation

## Flow
1. This command runs in forked @planner context
2. @planner: Architecture analysis, task breakdown
3. Results returned to main conversation
4. User confirmation (no auto-proceed)
5. @builder: Implementation (after approval)
6. @reviewer: Post-implementation review (skipped if --no-build)

## When to Use
- Affecting 4+ files
- Architecture decisions needed
- Unclear requirements
- New feature implementation

## When NOT to Use
- Simple bug fix → use `/do`
- Single file change → use `/do`
- Clear task → use `/do`

## Advanced Usage
For extremely complex tasks requiring deep research or logic verification (e.g., verifying race conditions), consider using **`@dplanner`** directly instead of `/plan`.
```bash
@dplanner Analyze potential deadlocks in transaction manager
```

## Output Format
```
## Architecture: [feature name]

### Design Decision
[One paragraph]

### Task Breakdown
1. [task] → @builder
2. [task] → @builder

### Files Affected
- CREATE: path/file
- MODIFY: path/file

### Proceed?
[y/n]
```
