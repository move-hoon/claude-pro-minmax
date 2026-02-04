---
name: dplan
description: Deep planning with @dplanner. Use for extremely complex tasks requiring Sequential Thinking, Perplexity research, and Context7 documentation.
argument-hint: [complex feature description]
context: fork
agent: dplanner
---

# /dplan Command

**"Deep Plan"** - Runs in **@dplanner** subagent context.

## Purpose
Invokes the **Deep Planner** for high-complexity architectural design and research.
Unlike `/plan`, this command utilizes `sequential-thinking`, `perplexity`, and `context7` for maximum depth.

## Arguments
$ARGUMENTS

## Flow
1. Forks conversation to **@dplanner** context.
2. **@dplanner**:
   - Analyzes request.
   - Uses Sequential Thinking for logic verification.
   - Uses Perplexity for web research.
   - Uses Context7 for library documentation.
   - Produces a comprehensive "Deep Plan".
3. Returns plan to main conversation.

## When to Use
- **New Architecture**: "Design microservices event bus"
- **Complex Debugging**: "Analyze race condition in payment module"
- **Tech Stack Research**: "Compare Redux vs Zustand for our specific needs"

## Output Format
See `@dplanner` documentation for detailed output structure.
