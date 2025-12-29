#!/usr/bin/env bash
# Tmux copy mode with relative line numbers
# Shows scrollback in a popup with relative line numbers for easy vim-style navigation

set -euo pipefail

# Get the pane ID that triggered this popup (passed as argument)
target_pane="${1:?Pane ID required}"

# Get pane height to limit capture to visible + reasonable scrollback
pane_height=$(tmux display-message -t "$target_pane" -p '#{pane_height}')
scroll_limit=$((pane_height * 3)) # Capture 3x the visible height

# Get pane content with ANSI colors (limited to recent history)
pane_content=$(tmux capture-pane -t "$target_pane" -e -p -S -"$scroll_limit")

# Count total lines
total_lines=$(echo "$pane_content" | wc -l)

# Current line is at the bottom (line 0 in relative terms)
# Lines above are negative (going back in history)
# We'll show: -N for lines N above current, and the line content

# ANSI color codes
YELLOW='\033[33m'
DIM='\033[2m'
RESET='\033[0m'

# Create numbered content with relative line numbers and colors
# Line 0 is the most recent (bottom), negative numbers go up
numbered_content=$(echo "$pane_content" | awk -v total="$total_lines" \
  -v yellow="$YELLOW" -v dim="$DIM" -v reset="$RESET" '
{
    # Calculate relative line number (0 = bottom/most recent, negative = older)
    rel = NR - total
    printf "%s%+5d%s %s│%s %s\n", yellow, rel, reset, dim, reset, $0
}')

# Use fzf to select a line, starting from bottom (most recent)
selected=$(echo "$numbered_content" | fzf --ansi --no-sort --tac \
  --prompt="Jump to line (relative): " \
  --header="Select line to jump to in copy mode" \
  --preview-window=hidden \
  --bind="ctrl-u:half-page-up,ctrl-d:half-page-down" \
  2>/dev/null) || exit 0

# Extract the relative line number from selection (strip ANSI codes first)
rel_line=$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $1}')

# Enter copy mode on the target pane and jump to the selected line
# Copy mode starts at the bottom of visible area (our line 0)
tmux copy-mode -t "$target_pane"

# Move up by the absolute value of relative line
if [[ $rel_line -lt 0 ]]; then
  lines_up=$((rel_line * -1))
  tmux send-keys -t "$target_pane" -X -N "$lines_up" cursor-up
fi
