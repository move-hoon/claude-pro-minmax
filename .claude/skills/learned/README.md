# Learned Patterns Database

This directory serves as the **Long-Term Memory** for your Claude Code environment. It stores recurring patterns, specific architectural decisions, and coding style preferences extracted through the `/learn` command.

## Core Concept: The Knowledge Cycle

1. **Detection**: During a session, you (or the `Stop hook`) identify a reusable pattern.
2. **Extraction**: You run `/learn` to formalize that insight.
3. **Persistence**: The pattern is saved as a Markdown file with specific metadata.
4. **Resurrection**: In future sessions, Claude automatically indexes these files, ensuring it doesn't repeat past mistakes or ask the same questions.

## Usage & Implementation

### 1. Manual Learning
If you notice a convention you want to keep:
`> /learn "Always use useServerSideProps for data fetching in /pages"`

### 2. Session Analysis
If you've just finished a complex task and want to extract the "how-to":
`> /learn`
Claude will analyze the transcript and propose patterns to save.

### 3. Management
`> /learn --show` (Lists all active patterns)

## Categorization Logic

| Category | Storage Target | Purpose |
| :--- | :--- | :--- |
| **CONVENTION** | `.claude/rules/` | Structural rules (e.g., Folder structure, Naming). |
| **PATTERN** | **This folder** | Reusable logic blocks (e.g., Auth flow, Error handling). |
| **PREFERENCE** | `.claude/rules/` | Personal taste (e.g., "I prefer trailing commas"). |

## Pattern File Structure

Every learned file follows this high-efficiency schema for LLM ingestion:

```markdown
---
name: auth-error-handling
category: PATTERN
tags: [auth, nextjs, security]
---
# Pattern: Centralized Auth Error Handling

## Problem
Auth errors were being handled inconsistently across different API routes.

## Solution
Use the `handleAuthError` utility located in `src/utils/auth`.

## Example
```typescript
try {
  // ... auth logic
} catch (e) {
  return handleAuthError(e);
}
```
```

## ⚠️ Important Notes
- **No Secrets**: The `/learn` command automatically triggers `scrub-secrets.js` to ensure no API keys or tokens are stored in the patterns.
- **Project Specific**: While saved in your user home, these patterns are indexed based on project context.