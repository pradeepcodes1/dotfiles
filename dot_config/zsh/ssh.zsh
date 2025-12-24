# Simple SSH wrapper to show hostname in tmux status bar
ssh() {
  # Extract full user@hostname (last argument)
  local host="${@: -1}"

  # Set pane-specific option if in tmux
  [[ -n "$TMUX" ]] && tmux set -p @ssh_host "$host"

  # Call real SSH
  command ssh "$@"

  # Clear pane option when done
  [[ -n "$TMUX" ]] && tmux set -p -u @ssh_host
}
