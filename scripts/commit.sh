#!/bin/bash
# commit.sh - Conventional commit
set -e
TYPE=$1; SCOPE=$2; MSG=$3
case $TYPE in feat|fix|docs|style|refactor|perf|test|chore) ;; *) echo "Invalid type: $TYPE"; exit 1 ;; esac
[ -z "$SCOPE" ] || [ -z "$MSG" ] && echo "Usage: $0 <type> <scope> <msg>" && exit 1
git commit -m "${TYPE}(${SCOPE}): ${MSG}"
