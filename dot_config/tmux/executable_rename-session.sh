#!/bin/bash
# Rename session while preserving numeric prefix for switch-client keybinds
# Usage: rename-session.sh "label"
# "1" + "dev" -> "1:dev", "1:old" + "new" -> "1:new", "1:label" + "" -> "1"

session_name=$(tmux display-message -p '#S')
num=$(echo "$session_name" | grep -oE '^[0-9]+')
label="$1"

if [ -z "$num" ]; then
  tmux rename-session "$label"
elif [ -z "$label" ]; then
  tmux rename-session "$num"
else
  tmux rename-session "$num:$label"
fi
