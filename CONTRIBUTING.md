# Contributing to Claude Pro MinMax (CPMM)

Thank you for considering a contribution to CPMM. Whether it's a bug report, a new slash command, or a documentation fix — all contributions are welcome regardless of skill level.

> CPMM is a **quota-first workflow layer** for Claude Code. Every design decision optimizes for more validated tasks per quota window.

## Table of Contents

- [Ways to Contribute](#ways-to-contribute)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Design Principles](#design-principles)
- [What We Look For](#what-we-look-for)
- [Submitting Changes](#submitting-changes)
- [Code Guidelines](#code-guidelines)
- [Documentation](#documentation)

## Ways to Contribute

- **Report bugs** — something broken during install or in a Claude Code session
- **Suggest features** — new commands, hooks, or routing strategies that save quota
- **Improve docs** — fix typos, clarify instructions, add examples
- **Share data** — if you've measured quota impact with `/usage`, your findings help everyone

## Getting Started

### Prerequisites

- Node.js ≥ 18
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed globally
- (Optional) [mgrep](https://www.npmjs.com/package/@mixedbread/mgrep) — reduces CLI output tokens by ~50%

### Setup

```bash
git clone https://github.com/move-hoon/claude-pro-minmax.git
cd claude-pro-minmax
bash install.sh
```

Verify your setup:

```bash
cpmm doctor
```

To test changes during development, re-run `bash install.sh` after editing — it copies configs to `~/.claude/`.

## Project Structure

CPMM is not a typical npm library. The core product is **workflow configuration** — markdown files, shell scripts, and a thin CLI.

> For the complete file tree, see [README.md — Project Structure](README.md#-project-structure).

| Directory | Purpose |
|-----------|---------|
| `.claude/agents/` | Agent definitions (AI behavior) |
| `.claude/commands/` | User-facing slash commands |
| `.claude/rules/` | Always-loaded behavior rules |
| `.claude/skills/` | On-demand tool capabilities |
| `scripts/hooks/` | Local hooks (zero API cost) |
| `scripts/runtime/` | Runtime auto-detection and adapters |
| `bin/cpmm.js` | CLI entry point (self-contained) |
| `install.sh` | One-click installer |

## Design Principles

1. **Quota-first** — Every feature must justify its cost. If it burns more quota than it saves, it doesn't belong.
2. **Fewer turns > cheaper model** — Sonnet in 1 turn can cost less than Haiku in 3. Quota impact depends on model choice, turn count, and output size — not model alone.
3. **Empirical, not theoretical** — Anthropic doesn't publish quota formulas. When documenting quota impact, back it with `/usage` deltas. Ideas and suggestions don't need data — just flag them as untested.

## What We Look For

**Good fits:**
- New slash commands or hooks that reduce quota waste
- Improvements to failure recovery (fewer wasted turns)
- Output control enhancements (shorter agent responses, better filtering)
- Bug fixes in `install.sh` or `bin/cpmm.js`
- Documentation improvements

**We don't accept:**
- Features unrelated to quota efficiency or Claude Code workflows
- Changes that increase default output verbosity
- Stylistic refactors with no functional impact
- External runtime dependencies in `bin/cpmm.js`

## Submitting Changes

### Bug Reports

[Open an issue](https://github.com/move-hoon/claude-pro-minmax/issues/new) with:
- What you expected vs. what happened
- OS, Node version, Claude Code version
- Output from `cpmm doctor`
- Steps to reproduce

### Feature Requests

[Open an issue](https://github.com/move-hoon/claude-pro-minmax/issues/new) describing:
- The quota or workflow problem you're solving
- Why existing commands don't cover it
- Measurement data (if available) — `/usage` deltas before and after

### Pull Requests

1. Fork the repo and create a branch: `git checkout -b feat/your-feature`
2. Make your changes
3. Test with `cpmm doctor` and a real Claude Code session
4. Ensure both `README.md` and `README.ko.md` are updated if your change affects docs
5. Submit a PR with a clear description of **what changed** and **why**

We aim to review PRs within 7 days. For significant changes, open an issue first to align on direction.

## Code Guidelines

- Follow the style of existing code — consistency matters more than rules
- JS (`bin/cpmm.js`): no external runtime dependencies — keep it self-contained
- Commit messages: use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`)

## Documentation

CPMM maintains bilingual documentation:

| File | Language |
|------|----------|
| `README.md` | English |
| `README.ko.md` | Korean |
| `docs/USER-MANUAL.md` | English |
| `docs/USER-MANUAL.ko.md` | Korean |

If your change affects user-facing docs, please update **both language versions** or note in your PR that a translation is needed.

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
