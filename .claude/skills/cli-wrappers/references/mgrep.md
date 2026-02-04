# mgrep Reference

## Why mgrep?
50% fewer tokens than grep/ripgrep

## Usage
```bash
mgrep "pattern" src/          # Local
mgrep -t ts "interface"       # Type filter
mgrep --web "Next.js docs"    # Web search
mgrep "TODO|FIXME" --include "*.ts"
```

## vs grep
| Tool | Tokens |
|------|--------|
| grep | ~2000 |
| mgrep | ~1000 |
