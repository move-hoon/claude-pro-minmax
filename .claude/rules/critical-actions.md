# Critical Actions Rule

## Direct Commands (Always Confirm)
- git push --force, git reset --hard
- DROP TABLE, DELETE FROM (no WHERE), TRUNCATE
- rm -rf on important directories
- Production deployments

## Indirect Scripts (Warning)
- npm/yarn run: clean, reset, nuke, purge
- db:reset, db:drop, migrate:reset
- deploy:prod, deploy:production

## Git Conflicts
On CONFLICT or <<<<<<< HEAD:
1. STOP immediately
2. List conflicting files
3. Hand off to user
4. NEVER attempt auto-resolution

## Confirmation Flow
```
⚠️ CRITICAL ACTION DETECTED

Action: [command]
Risk: [description]

Type 'CONFIRM' to proceed.
```

## Responses
- CONFIRM: Proceed
- SHOW: Display script
- CANCEL: Abort
