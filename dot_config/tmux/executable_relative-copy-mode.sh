#!/usr/bin/env bash
# Tmux copy mode with relative line numbers
# Shows scrollback in a popup with relative line numbers for easy vim-style navigation

set -euo pipefail

# Get pane content (visible + scrollback)
pane_content=$(tmux capture-pane -p -S -1000)

# Count total lines
total_lines=$(echo "$pane_content" | wc -l)

# Get pane height to calculate cursor position (bottom of visible area)
pane_height=$(tmux display-message -p '#{pane_height}')

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

# Extract the relative line number from selection
rel_line=$(echo "$selected" | awk '{print $1}')

# Enter copy mode and jump to the selected line
# The relative number tells us how many lines to go up from bottom
tmux copy-mode

# Go to bottom first, then move up by the absolute value of relative line
if [[ $rel_line -lt 0 ]]; then
  # Negative means go up from bottom
  lines_up=$((rel_line * -1))
  # Go to end of history first
  tmux send-keys -X history-bottom
  # Then go up the required number of lines
  if [[ $lines_up -gt 0 ]]; then
    tmux send-keys -X -N "$lines_up" cursor-up
  fi
fi
