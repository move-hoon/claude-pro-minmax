---
name: watch
description: Long-running process monitoring with tmux. Watch tests, dev server, or build process. Zero message cost.
argument-hint: tests | dev | build | custom "[cmd]"
disable-model-invocation: true
allowed-tools: Bash(tmux:*)
---

# /watch Command

Process monitoring with tmux.

## Target
$ARGUMENTS

## Execution
```bash
# tests: Watch test execution
tmux new-session -d -s claude-watch-tests "scripts/test.sh --watch"

# dev: Watch dev server
tmux new-session -d -s claude-watch-dev "scripts/build.sh --dev"

# build: Watch build process
tmux new-session -d -s claude-watch-build "scripts/build.sh"

# custom: User-defined command
tmux new-session -d -s claude-watch-custom "[cmd]"
```

## Preset Types
| Type | Command | Session Name |
|------|---------|--------------|
| tests | `scripts/test.sh --watch` | claude-watch-tests |
| dev | `scripts/build.sh --dev` | claude-watch-dev |
| build | `scripts/build.sh` | claude-watch-build |
| custom | User-defined | claude-watch-custom |

## tmux Controls
- `Ctrl+b d`: Detach (background)
- `tmux attach -t [name]`: Reattach
- `tmux ls`: List sessions
- `tmux kill-session -t [name]`: Kill session

## Cost Savings
Before: 5 check cycles = 15 messages
With /watch: 5 check cycles = 1 message

## Output
```
📺 Started: claude-watch-[type]
Command: [executed command]

Controls:
- Attach: tmux attach -t claude-watch-[type]
- Detach: Ctrl+b d
- Kill: tmux kill-session -t claude-watch-[type]
```
