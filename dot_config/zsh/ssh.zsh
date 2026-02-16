# Simple SSH wrapper to show hostname in tmux status bar
ssh() {
  # Resolve actual hostname via ssh config parsing
  local host
  host=$(command ssh -G "$@" 2>/dev/null | awk '/^hostname /{print $2}')
  [[ -z "$host" ]] && host="${@: -1}"

  # Set pane-specific option if in tmux
  [[ -n "$TMUX" ]] && tmux set -p @ssh_host "$host"

  # Call real SSH
  command ssh "$@"

  # Clear pane option when done
  [[ -n "$TMUX" ]] && tmux set -p -u @ssh_host
}
