#!/bin/bash

pane_content=$(tmux capture-pane -p -S - -e | sed '$ d')

printf "%s" "$pane_content" | fzf --reverse | pbcopy
