# Skills Directory (Facade Pattern Optimization)

> **[한국어 버전](README.ko.md)**

## Purpose
This directory contains reusable skill definitions designed for **Maximum Value Per Message** using the Facade Pattern. It prevents excessive context loading by separating high-level interfaces from verbose technical details.

## Structure (Facade Pattern)

```text
skills/
└── skill-name/
    ├── SKILL.md           # Interface (Thin: ~30-50 lines)
    └── references/        # Implementation (Verbose: Loaded on-demand)
        ├── api-docs.md
        └── cli-patterns.md
```

## How It Works: The "On-Demand" Strategy

Instead of loading extensive documentation every time, Claude starts with only the **Interface (SKILL.md)**.

1. **Phase 1 (Lightweight)**: Claude reads the compact `SKILL.md` interface.
2. **Phase 2 (Trigger)**: When a specific task matches a "Trigger Condition" defined in the interface, Claude explicitly loads the reference file.
3. **Phase 3 (Execution)**: Claude uses the detailed info only for that specific turn, then it can be discarded during `/compact`.

## Skill Inventory

| Skill | Purpose | Key Benefit |
| :--- | :--- | :--- |
| `cli-wrappers` | Replaces heavy MCP servers with slim CLI patterns. | Significantly reduces output tokens. |
| `learned` | Stores project-specific patterns via `/learn`. | Prevents rework & repeat questions. |

## Adding a Custom Skill

### 1. File Template: `SKILL.md`
```markdown
# [Skill Name] Interface

## Purpose
Short description of what this skill does.

## Quick Reference
- Fast fact 1
- Fast fact 2

## Reference Loading Protocol
Claude **MUST** use the `read_file` tool to load these files ONLY when the conditions are met:

- **Logic Details**: Load `.claude/skills/[skill]/references/logic.md` when writing core logic.
- **CLI Patterns**: Load `.claude/skills/[skill]/references/cli.md` when running shell commands.
```

### 2. File Template: `references/*.md`
Contains the heavy stuff: Full API docs, long code examples, error message tables.

## Best Practices
1. **The 50-Line Rule**: If `SKILL.md` exceeds 50 lines, move details to `references/`.
2. **Explicit Triggers**: Use bold text like **"Claude MUST load..."** to ensure the model follows the pattern.
3. **Relative Paths**: Always provide the full path from the project root (e.g., `.claude/skills/...`) to avoid tool failures.