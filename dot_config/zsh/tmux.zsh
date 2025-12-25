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
    if [[ -z "$TMUX" && "$TERM_PROGRAM" == "ghostty" ]]; then

        # Function to find the smallest available session number
        _find_next_session_num() {
            local next_num=1
            local existing_nums=($(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -E '^[0-9]+$' | sort -n))

            # Find first gap in numbering
            for num in "${existing_nums[@]}"; do
                if [[ $num -eq $next_num ]]; then
                    ((next_num++))
                elif [[ $num -gt $next_num ]]; then
                    break
                fi
            done

            echo "$next_num"
        }

        # Show interactive session selector with fzf
        if command -v fzf &>/dev/null; then
            # Get list of existing sessions
            local sessions=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null)

            # Create fzf options with existing sessions + new session option
            local choice=$(
                {
                    echo "+ Create new session"
                    [[ -n "$sessions" ]] && echo "$sessions"
                } | fzf --height=40% --border --prompt="Select tmux session: " \
                       --header="↑/↓: navigate | Enter: select | Esc: cancel" \
                       --reverse --no-info
            )

            if [[ -n "$choice" ]]; then
                if [[ "$choice" == "+ Create new session"* ]]; then
                    # Recalculate next available number right before creating
                    next_num=$(_find_next_session_num)
                    tmux new-session -s "$next_num"
                else
                    # Extract session name (everything before the first colon)
                    local session_name="${choice%%:*}"
                    tmux attach-session -t "$session_name"
                fi
            else
                # User cancelled - exit shell
                exit 0
            fi
        else
            # Fallback if fzf is not available
            local next_num=$(_find_next_session_num)
            tmux attach-session 2>/dev/null || tmux new-session -s "$next_num"
        fi
    fi

    # Store HOME in pane-specific option so status bar can read it
    if [[ -n "$TMUX" ]]; then
        tmux set-option -p @pane_home "$HOME"
    fi

    # Garbage collect unattached tmux sessions (keep threshold sessions max)
    # Sort by creation time (oldest first) to remove old sessions before new ones
    local threshold=3
    local sessions=$(tmux list-sessions -F "#{session_created}:#{session_name}:#{session_attached}" 2>/dev/null | sort -n)
    local total=$(echo "$sessions" | wc -l | tr -d ' ')

    if [[ $total -gt $threshold ]]; then
        echo "$sessions" | while IFS=: read -r created name attached; do
            # Skip attached sessions and special sessions
            [[ "$attached" == "1" || "$name" == "music" ]] && continue
            # Delete unattached session
            tmux kill-session -t "$name" 2>/dev/null
            total=$((total - 1))
            [[ $total -le $threshold ]] && break
        done
    fi
fi

