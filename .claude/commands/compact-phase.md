---
name: compact-phase
description: Strategic phase-based context pruning. Removes unnecessary context based on planning, implementation, or review phase.
argument-hint: planning | implementation | review | deep-planning
disable-model-invocation: true
---

# /compact-phase Command

Strategic phase-based context pruning.

## Phase
$ARGUMENTS

## Execution
This command provides the appropriate `/compact` instruction for your current phase. Copy and run the suggested command:

```bash
# After planning phase
/compact Keep: decisions, task list, architecture choices. Discard: exploration attempts, rejected alternatives, research notes.

# After implementation phase
/compact Keep: final code, tests, working solutions. Discard: debug attempts, failed approaches, intermediate versions.

# After review phase
/compact Keep: final state, confirmed issues, applied fixes. Discard: iteration history, superseded feedback.

# After deep planning phase
/compact Keep: validated logic, research sources, architecture diagram. Discard: internal monologue, failed research queries, temporary notes.
```

> Note: This command guides you to run `/compact` with the right instructions. It does not automatically compact context.

## Phase-Specific Rules

| Phase | Keep | Discard |
|-------|------|---------|
| planning | Decisions, task list | Exploration, reviewed alternatives |
| implementation | Final code, tests | Debug attempts, intermediate versions |
| review | Final state, issue list | Iteration history |
| deep-planning | Validated logic, final plan | Intermediate thoughts, raw search results |

## Cost Savings
- planning → implementation: ~40% context reduction
- implementation → review: ~30% context reduction
- review → complete: ~50% context reduction

## Output
```
Compact: [phase] phase completed

Kept:
- [retained items]

Discarded:
- [removed items]

Context reduced: [X]% → [Y]%
```

## When to Use
```
/plan feature-x          # Plan
/compact-phase planning  # Prune exploration

/do implement task-1     # Implement
/do implement task-2
/compact-phase implementation  # Prune debug attempts

/review src/             # Review
/compact-phase review    # Prune iterations

/dplan analyze-race      # Deep Plan
/compact-phase deep-planning # Keep verified logic, discard raw thoughts
```
