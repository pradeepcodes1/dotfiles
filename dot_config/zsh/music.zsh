# function to create/switch to a tmux session and run a command only if it's not already running.
music() {
  local session_name="music"
  local target_command="ncspot"

  # 1. ensure the session exists. if not, create it detached.
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name"
  fi

  # 2. check if the target command is running in any pane of the session.
  # we use `list-panes` to inspect the running commands. `grep -q` is silent and fast.
  if ! tmux list-panes -s -t "$session_name" -f '#{pane_current_command}' | grep -q "$target_command"; then
    # if the command is not found, send the command to the first pane.
    tmux send-keys -t "${session_name}" "$target_command" c-m
  fi

  # 3. attach to or switch to the session.
  if [ -n "$TMUX" ]; then
    # we are inside tmux, so switch client.
    tmux switch-client -t "$session_name"
  else
    # we are not in tmux, so attach to the session.
    tmux attach-session -t "$session_name"
  fi
}
