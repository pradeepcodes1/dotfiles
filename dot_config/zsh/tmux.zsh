# Exit the current Alacritty instance when the tmux session exits.
# This logic only runs if a new terminal window is opened and you are not
# already inside a Tmux session.
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  # List of cool names for your sessions
  declare -a names=(
    "matrix" "terminus" "nexus" "hydra" "cipher"
    "kronos" "ghost" "orbital" "quasar" "epsilon"
  )

  found_session=false

  # Find the first available name and create a new session
  for name in "${names[@]}"; do
    if ! tmux has-session -t "$name" &> /dev/null; then
      tmux new-session -s "$name"
      found_session=true
      break
    fi
  done

  # Fallback to a timestamped session if all names are in use
  if [ "$found_session" = false ]; then
    tmux new-session -s "tmux-$(date +%s)"
  fi
  
  # This is the core "hack."
  # The `exit` command will only be reached when the `tmux` command above finishes.
  # This happens when you kill the session or detach from it.
  exit
fi