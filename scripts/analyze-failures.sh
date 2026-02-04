#!/bin/bash
# analyze-failures.sh
# Failure log analysis and pattern extraction
# Usage: bash scripts/analyze-failures.sh [limit]

set -euo pipefail

LIMIT="${1:-50}"
LOG_FILE="$HOME/.claude/logs/tool-failures.log"

if [ ! -f "$LOG_FILE" ]; then
  echo "✅ No failure logs found. Your tools are working perfectly!"
  exit 0
fi

TOTAL_COUNT=$(wc -l < "$LOG_FILE" | tr -d ' ')

if [ "$TOTAL_COUNT" -eq 0 ]; then
  echo "✅ No failure logs found. Your tools are working perfectly!"
  exit 0
fi

echo "## Failure Analysis"
echo ""
echo "**Total failures logged**: $TOTAL_COUNT"
echo "**Analyzing last**: $LIMIT"
echo ""

# Extract and analyze the last N entries
FAILURES=$(tail -"$LIMIT" "$LOG_FILE")

echo "### Top Failures"
echo ""

# Group errors by tool and calculate frequency
echo "$FAILURES" | awk -F'|' '
{
  # Extract tool name from first field (after "Tool: ")
  tool = $1
  sub(/.*Tool: /, "", tool)
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", tool)

  # Extract error from second field (after "Error: ")
  error = $2
  sub(/.*Error: /, "", error)
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", error)

  # Normalize error messages to find patterns
  if (error ~ /old_string.*not found/) {
    error = "old_string not found"
  } else if (error ~ /pattern.*syntax/) {
    error = "pattern syntax error"
  } else if (error ~ /permission denied/i) {
    error = "permission denied"
  } else if (error ~ /file not found|no such file/i) {
    error = "file not found"
  } else if (error ~ /timeout/i) {
    error = "timeout"
  } else if (error ~ /exceeds maximum.*size/) {
    error = "file size exceeds limit"
  }

  # Store tool and error separately
  key = NR
  tool_map[key] = tool
  error_map[key] = error

  # Count occurrences
  combo = tool ":::" error
  count[combo]++
  tool_count[tool]++
}
END {
  # Create sorted array by count
  n = 0
  for (c in count) {
    sorted[n] = count[c] ":::" c
    n++
  }

  # Bubble sort by count (descending)
  for (i = 0; i < n; i++) {
    for (j = i + 1; j < n; j++) {
      split(sorted[i], a, ":::")
      split(sorted[j], b, ":::")
      if (a[1] + 0 < b[1] + 0) {
        temp = sorted[i]
        sorted[i] = sorted[j]
        sorted[j] = temp
      }
    }
  }

  # Print top 10
  limit = (n < 10) ? n : 10
  for (i = 0; i < limit; i++) {
    split(sorted[i], parts, ":::")
    cnt = parts[1]
    tool = parts[2]
    err = parts[3]
    printf "%d. **%s**: \"%s\" (%d times)\n", i+1, tool, err, cnt
  }

  print ""
  print "### Most Problematic Tools"
  print ""

  # Create sorted array for tools
  m = 0
  for (t in tool_count) {
    tool_sorted[m] = tool_count[t] ":::" t
    m++
  }

  # Bubble sort by tool count (descending)
  for (i = 0; i < m; i++) {
    for (j = i + 1; j < m; j++) {
      split(tool_sorted[i], a, ":::")
      split(tool_sorted[j], b, ":::")
      if (a[1] + 0 < b[1] + 0) {
        temp = tool_sorted[i]
        tool_sorted[i] = tool_sorted[j]
        tool_sorted[j] = temp
      }
    }
  }

  # Print top 5 tools
  tool_limit = (m < 5) ? m : 5
  for (i = 0; i < tool_limit; i++) {
    split(tool_sorted[i], parts, ":::")
    printf "- **%s**: %d failures\n", parts[2], parts[1]
  }
}'

echo ""
echo "---"
echo ""
echo "💡 **Recommendations**:"
echo ""
echo "- Review frequent failures and update your approach"
echo "- Consider saving learned patterns with \`/learn [pattern]\`"
echo "- Use \`/do-sonnet\` or \`/plan\` for complex tasks to reduce trial-and-error"
echo ""
echo "📝 **Clear logs**: \`rm $LOG_FILE\`"
