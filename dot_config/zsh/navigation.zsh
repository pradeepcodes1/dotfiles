# Smart Navigation with zoxide integration
# This file provides enhanced directory navigation using zoxide

# Ensure zoxide is available
if ! command -v zoxide &>/dev/null; then
  return
fi

# Override cd to use zoxide for tracking
# This makes cd smart while maintaining familiar behavior
function cd() {
  if [ $# -eq 0 ]; then
    # cd with no args goes to home
    builtin cd ~ && zoxide add "$(pwd)"
  elif [ -d "$1" ]; then
    # If argument is a valid directory, use builtin cd
    builtin cd "$1" && zoxide add "$(pwd)"
  else
    # Otherwise, try zoxide query (fuzzy matching)
    local result
    result=$(zoxide query "$@" 2>/dev/null)
    if [ -n "$result" ]; then
      builtin cd "$result"
    else
      # Fallback to builtin cd (will show error if path invalid)
      builtin cd "$@"
    fi
  fi
}

# zi - Interactive directory jump using fzf
# Usage: zi [query]
function zi() {
  local result
  if [ $# -eq 0 ]; then
    # No arguments - show interactive picker
    result=$(zoxide query -l | fzf --height 40% --reverse --header "Jump to directory")
  else
    # With arguments - fuzzy search zoxide database
    result=$(zoxide query -l | grep -iF "$*" | fzf --height 40% --reverse --header "Jump to: $*")
  fi

  if [ -n "$result" ]; then
    builtin cd "$result"
  fi
}

# cdf - cd to the directory of a file
# Usage: cdf path/to/file.txt
function cdf() {
  if [ -f "$1" ]; then
    builtin cd "$(dirname "$1")"
  else
    error_log "nav" "'$1' is not a file"
    return 1
  fi
}

# up - Go up N directories
# Usage: up [N] (default: 1)
function up() {
  local levels=${1:-1}
  local path=""
  for ((i = 0; i < levels; i++)); do
    path="../$path"
  done
  builtin cd "$path"
}

# mkcd - Create directory and cd into it
# Usage: mkcd path/to/new/dir
function mkcd() {
  if [ $# -ne 1 ]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi
  mkdir -p "$1" && builtin cd "$1"
}

# cdls - cd and ls in one command
# Usage: cdls directory
function cdls() {
  builtin cd "$@" && ls
}
