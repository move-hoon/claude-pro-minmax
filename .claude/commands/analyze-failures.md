---
name: analyze-failures
description: Analyze accumulated tool failure logs to extract recurring patterns and suggest improvements.
argument-hint: [limit] (default: 50)
disable-model-invocation: false
---

# /analyze-failures Command

Analyze tool failure logs to identify recurring errors and suggest patterns for the `/learn` command.

## Input
- `limit` (optional): Number of recent failures to analyze. Default is 50.

## Execution
Run the bash script to parse `~/.claude/logs/tool-failures.log`:

```bash
bash ~/.claude/scripts/analyze-failures.sh "$ARGUMENTS"
```

## How It Works
1. **Collection**: Failures are automatically logged by `~/.claude/scripts/hooks/tool-failure-log.sh` (Zero-cost).
2. **Analysis**: This command uses `awk` to aggregate and count errors locally (Zero-cost for generation).
3. **Insight**: The output summary is added to context, allowing Claude to offer specific advice if needed.

## Output Example
```markdown
## Failure Analysis

**Total failures logged**: 120
**Analyzing last**: 50

### Top Failures
1. **Edit tool**: "old_string not found" (15 failures)
2. **Grep tool**: "pattern syntax error" (8 failures)

### Most Problematic Tools
- **Edit tool**: 25 failures
- **Grep tool**: 12 failures

💡 **Recommendations**:
- Review frequent failures and update your approach
- Consider saving learned patterns with `/learn [pattern]`
```

## Difference from `/learn`
- **`/analyze-failures`**: **Quantitative**. Looks at *past errors* from logs. "What went wrong?"
- **`/learn`**: **Qualitative**. Extracts *successful patterns* from current context. "What went right?"
