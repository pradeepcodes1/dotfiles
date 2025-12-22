## TODO: Avoid attaching to the "music" session
## Automatically enter tmux with a cool session name
## Only run this script if we are NOT already inside a tmux session.
#if [[ -z "$TMUX" ]]; then
#
#    # Try to attach to the last-used session. If that command fails...
#    tmux attach-session || {
#        # ...create a new session with a cool, random name.
#        
#        # Define lists of cool words
#        local adjectives=(Crimson Cobalt Azure Shadow Golden Iron Nova Quantum)
#        local nouns=(Jaguar Phoenix Wyvern Falcon Sentinel Matrix Nexus Relay)
#
#        # Pick a random word from each list and combine them
#        local session_name="${adjectives[$((RANDOM % ${#adjectives[@]}))]}-${nouns[$((RANDOM % ${#nouns[@]}))]}}"
#
#        # Create the new, named session
#        tmux new-session -s "$session_name"
#    }
#fi

#!/bin/bash

if command -v tmux &>/dev/null; then
    if [[ -z "$TMUX" \
      && ( "$TERM_PROGRAM" == "alacritty" || "$TERM_PROGRAM" == "ghostty" ) ]]; then
        tmux
    fi

    # Store HOME in pane-specific option so status bar can read it
    if [[ -n "$TMUX" ]]; then
        tmux set-option -p @pane_home "$HOME"
    fi

    # Garbage collect unattached tmux sessions (keep threshold sessions max)
    local threshold=5
    local sessions=$(tmux list-sessions -F "#{session_name}:#{session_attached}" 2>/dev/null)
    local total=$(echo "$sessions" | wc -l | tr -d ' ')

    if [[ $total -gt $threshold ]]; then
        echo "$sessions" | while IFS=: read -r name attached; do
            # Skip attached sessions and special sessions
            [[ "$attached" == "1" || "$name" == "music" ]] && continue
            # Delete unattached session
            tmux kill-session -t "$name" 2>/dev/null
            total=$((total - 1))
            [[ $total -le $threshold ]] && break
        done
    fi
fi

