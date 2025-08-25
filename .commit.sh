#!/bin/bash

cd "$(chezmoi source-path)" || exit

DIFF_CONTENT=$(git diff HEAD)
[ -z "$DIFF_CONTENT" ] && exit 0

PROMPT="Write a conventional git commit message for this dotfiles diff. Output only the raw message text.
---
$DIFF_CONTENT"

COMMIT_MSG=$(echo "$PROMPT" | gemini)
[ -z "$COMMIT_MSG" ] && echo "Gemini failed. Aborting." && exit 1

git add -A

clear
echo -e "\033[1;32m$COMMIT_MSG\033[0m"
echo "---"
git diff --staged --color=always | less -R

read -p "Push? (y/N) " -n 1 -r; echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  git commit -m "$COMMIT_MSG" && git push origin main
else
  git reset HEAD -- && echo "Aborted."
fi
