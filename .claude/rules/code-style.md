# Code Style Rules

## Files (Language-Agnostic)
- Max 300 lines
- One component/class per file
- Consistent naming per language conventions

## General Principles
- Strict typing (TypeScript strict, Kotlin null-safety, Rust ownership)
- No dynamic typing escapes (`any`, `Object`, `interface{}`)
- Explicit return types where language supports

## Functions/Methods
- Max 50 lines
- Single responsibility
- Early returns / guard clauses
- Meaningful names (verb + noun)

## Formatting
- Use `~/.claude/scripts/runtime/adapters/*.sh` → `adapter_format()`
- Prettier (JS/TS), ktlint (Kotlin), gofmt (Go), rustfmt (Rust), black (Python)
