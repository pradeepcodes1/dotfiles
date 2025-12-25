#!/bin/bash

# Auto-exit Ghostty when closing the last window in a tmux session
# This script is called by the pane-exited hook in tmux.conf

# Get current session and window count
session_name=$(tmux display-message -p '#{session_name}')
window_count=$(tmux list-windows -t "$session_name" 2>/dev/null | wc -l)
term_program=$(tmux show-environment TERM_PROGRAM 2>/dev/null | cut -d= -f2)

# If this is the last window and we're in Ghostty, detach the client
# This will cause the exec'd tmux process to exit, which closes Ghostty
if [ "$window_count" -eq 1 ] && [ "$term_program" = "ghostty" ]; then
    tmux detach-client
fi
