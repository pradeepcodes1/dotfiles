#!/usr/bin/env bash
# Show keybindings and tools side by side in a popup via nested tmux session
DOCS_DIR="$HOME/.local/share/chezmoi/docs"
SESSION="_kb_$$"
SOCKET="kb_$$"

# Allow nested tmux
unset TMUX

# Create detached session on a separate server (fully isolated)
tmux -L "$SOCKET" new-session -d -s "$SESSION" -x "$(tput cols)" -y "$(tput lines)" \
  "glow -p '${DOCS_DIR}/KEYBINDINGS.md'; tmux -L '$SOCKET' kill-session -t '$SESSION' 2>/dev/null"

# Add right pane for tools
tmux -L "$SOCKET" split-window -t "$SESSION" -h -l 50% \
  "glow -p '${DOCS_DIR}/TOOLS.md'; tmux -L '$SOCKET' kill-session -t '$SESSION' 2>/dev/null"

# Hide status bar, enable mouse, disable prefix so ROpt keys are ignored
tmux -L "$SOCKET" set-option -t "$SESSION" status off
tmux -L "$SOCKET" set-option -t "$SESSION" prefix None
tmux -L "$SOCKET" set-option -t "$SESSION" mouse on

# Focus left pane and attach
tmux -L "$SOCKET" select-pane -t "$SESSION":0.0
exec tmux -L "$SOCKET" attach-session -t "$SESSION"
