#!/bin/bash
# create-branch.sh - Deterministic branch creation
set -e
TYPE=$1; NAME=$2
case $TYPE in
  feature|f) PREFIX="feature" ;;
  fix|b) PREFIX="fix" ;;
  hotfix|h) PREFIX="hotfix" ;;
  refactor|r) PREFIX="refactor" ;;
  chore|c) PREFIX="chore" ;;
  *) echo "Use: feature, fix, hotfix, refactor, chore"; exit 1 ;;
esac
[ -z "$NAME" ] && echo "Usage: $0 <type> <name>" && exit 1
git checkout -b "${PREFIX}/$(echo $NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
