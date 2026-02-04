# GitHub CLI Reference

## Pull Requests
```bash
gh pr list --json number,title,state | jq -c '.[]'
gh pr create --title "feat: X" --body "desc"
gh pr view 123 --json title,body | jq '.'
gh pr merge 123 --squash
gh pr checks 123 --json name,state | jq -c '.[]'
```

## Issues
```bash
gh issue list --json number,title | jq -c '.[]'
gh issue create --title "X" --body "desc"
```

## Key: Always --json | jq, never raw output
