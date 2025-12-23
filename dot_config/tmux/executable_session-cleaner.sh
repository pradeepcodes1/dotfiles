#!/bin/bash

current_session=$(tmux display-message -p '#S')
last_session=$(tmux show-option -gv @last_session 2>/dev/null)

# Update last session to current
tmux set-option -g @last_session "$current_session"

# If last session is empty, it's likely the first run, so just return
if [[ -z "$last_session" ]]; then
    exit 0
fi

# If last session is different from current
if [[ "$last_session" != "$current_session" ]]; then
    # Check if last session still exists
    if tmux has-session -t "$last_session" 2>/dev/null; then
        # Check window count
        window_count=$(tmux list-windows -t "$last_session" | wc -l | tr -d ' ')
        
        if [[ "$window_count" -eq 1 ]]; then
             # Prompt user to kill
             # We use run-shell -b to run in background, but we need to target the client.
             # The hook client-session-changed implies a client is attached.
             tmux confirm-before -p "Kill previous session '$last_session' (1 window)? (y/n)" "tmux kill-session -t '$last_session'"
        fi
    fi
fi
