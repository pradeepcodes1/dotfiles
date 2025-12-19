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

if [[ -z "$TMUX" \
  && "$TERM_PROGRAM" == "alacritty" ]]; then

# Get the focused workspace name from the Aerospace CLI using jq
WORKSPACE_NAME=$(aerospace list-workspaces --focused)

# Check if a tmux session with the workspace name already exists
# The `2>/dev/null` silences the "can't find session" error
if tmux has-session -t "$WORKSPACE_NAME" 2>/dev/null; then
  # If session exists, attach to it
  tmux attach-session -t "$WORKSPACE_NAME"
else
  # If session does not exist, create it with the workspace name
  tmux new-session -s "$WORKSPACE_NAME"
fi
fi
