#!/bin/zsh

# --- CONFIGURATION ---
 local FRAMES=("(-.-)" "(o.-)" "(o.o)" "(-.o)")
#local FRAMES=("\\(^o^)/" "\\(^-^)/")
local COUNTER_FILE="/tmp/tmux_spinner_counter"
# --- END CONFIGURATION ---

local NUM_FRAMES=${#FRAMES[@]}
local CURRENT_COUNTER=0
if [ -f "$COUNTER_FILE" ]; then
    CURRENT_COUNTER=$(cat "$COUNTER_FILE")
fi

echo "${FRAMES[$(( (CURRENT_COUNTER % NUM_FRAMES) + 1 ))]}"
echo "$((CURRENT_COUNTER + 1))" > "$COUNTER_FILE"
