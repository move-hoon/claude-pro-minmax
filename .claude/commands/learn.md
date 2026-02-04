---
name: learn
description: Extract and save patterns from session. Captures recurring coding patterns, conventions, and preferences.
argument-hint: "[pattern]" or --show
disable-model-invocation: true
---

# /learn Command

Extract and save patterns from session.

## Input
$ARGUMENTS

## Execution
1. No arguments: Analyze current session for patterns
2. `"[pattern]"`: Save explicit pattern
3. `--show`: Display learned patterns list

## Storage Paths
```
~/.claude/skills/learned/YYYY-MM-DD-[pattern-name].md
.claude/rules/conventions.md   # CONVENTION type
.claude/rules/preferences.md   # PREFERENCE type
```

## Categories & Actions
| Category | Storage Location |
|----------|------------------|
| CONVENTION | Append to `.claude/rules/conventions.md` |
| PATTERN | Create new file in `~/.claude/skills/learned/` |
| PREFERENCE | Append to `.claude/rules/preferences.md` |

## Pattern File Format
```markdown
---
name: [pattern-name]
description: [pattern description]
---

# Pattern: [name]

## Problem
[Description of recurring issue]

## Solution
[How to solve it]

## Example
[Code example]
```

## Auto-Learning
Stop hook detects repeated modifications:
- Same file modified 3+ times → suggest pattern extraction
- Use `/learn` to manually confirm and save

## Examples
```
/learn                                    # Analyze session
/learn "Always use try-catch for API error handling"
/learn "Component filenames use PascalCase"
/learn --show                             # Show list
```
