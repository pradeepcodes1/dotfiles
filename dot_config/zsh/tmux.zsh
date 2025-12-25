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

        # Loop to show session selector when tmux exits
        while true; do
            # Show interactive session selector with fzf
            if command -v fzf &>/dev/null; then
                # Clear screen to hide login message
                clear

                # Get list of existing sessions sorted by last used (most recent first)
                local sessions=$(tmux list-sessions -F "#{session_last_attached} #{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null | sort -rn | cut -d' ' -f2-)

                # Create fzf options with existing sessions + special options
                local choice=$(
                    {
                        echo "+ Create new session"
                        [[ -n "$sessions" ]] && echo "× Kill all sessions"
                        [[ -n "$sessions" ]] && echo "$sessions"
                    } | fzf --height=40% --border --prompt="Select tmux session (Ctrl-d to delete): " \
                           --reverse --no-info --margin=0,25% \
                           --header="Enter: attach | Ctrl-d: kill session | ESC: exit" \
                           --bind="ctrl-d:execute-silent(echo {1} | grep -q '^×$' || tmux kill-session -t {1} 2>/dev/null)+reload({
                               echo '+ Create new session'
                               sessions=\$(tmux list-sessions -F '#{session_last_attached} #{session_name}: #{session_windows} windows (#{session_attached} attached)' 2>/dev/null | sort -rn | cut -d' ' -f2-)
                               [[ -n \"\$sessions\" ]] && echo '× Kill all sessions'
                               [[ -n \"\$sessions\" ]] && echo \"\$sessions\"
                           })"
                )

                if [[ -n "$choice" ]]; then
                    if [[ "$choice" == "+ Create new session"* ]]; then
                        # Recalculate next available number right before creating
                        next_num=$(_find_next_session_num)
                        tmux new-session -s "$next_num"
                    elif [[ "$choice" == "× Kill all sessions"* ]]; then
                        # Kill all sessions and continue loop
                        tmux list-sessions -F "#{session_name}" 2>/dev/null | while read -r sess; do
                            tmux kill-session -t "$sess" 2>/dev/null
                        done
                        continue
                    else
                        # Extract session name (everything before the first colon)
                        local session_name="${choice%%:*}"
                        tmux attach-session -t "$session_name"
                    fi
                    # After tmux exits, loop back to show selector again
                else
                    # User cancelled - exit shell
                    exit 0
                fi
            else
                # Fallback if fzf is not available
                local next_num=$(_find_next_session_num)
                tmux attach-session 2>/dev/null || tmux new-session -s "$next_num"
                # After tmux exits, loop back to show selector again
            fi
        done
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

