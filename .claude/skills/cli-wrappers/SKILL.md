---
name: cli-wrappers
description: Use CLI tools instead of MCP to save tokens. Provides JSON output patterns for gh, mgrep, psql, etc.
---

# CLI Wrappers Skill

## Purpose
Replace MCPs with CLI. ALWAYS use JSON output + jq.

## GitHub (gh)
```bash
gh pr list --json number,title | jq -c '.[]'
gh pr create --title "feat: X" --body "desc"
gh issue list --json number,title | jq -c '.[]'
```
Full reference: `@references/github-cli.md`

## Search (mgrep)
```bash
mgrep "pattern" src/
mgrep -t py "class"      # Python
mgrep -t java "public"   # Java
mgrep -t go "func"       # Go
mgrep --web "docs query"
```
Full reference: `@references/mgrep.md`

## Database
```bash
psql -t -A -F',' -c "SELECT..."
```

## Benefits
| Tool | Benefit |
|------|---------|
| gh pr list | JSON output reduces verbosity significantly |
| psql | CSV format eliminates table formatting overhead |
