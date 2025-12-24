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
        result=$(zoxide query -l | grep -i "$*" | fzf --height 40% --reverse --header "Jump to: $*")
    fi

    if [ -n "$result" ]; then
        builtin cd "$result"
    fi
}

# zz - Quick jump to frequently used directories
# This is an alias for zoxide's interactive mode
alias zz='zi'

# cdf - cd to the directory of a file
# Usage: cdf path/to/file.txt
function cdf() {
    if [ -f "$1" ]; then
        builtin cd "$(dirname "$1")"
    else
        echo "Error: '$1' is not a file"
        return 1
    fi
}

# up - Go up N directories
# Usage: up [N] (default: 1)
function up() {
    local levels=${1:-1}
    local path=""
    for ((i=0; i<levels; i++)); do
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

# fzf-cd - Browse and cd using fzf (searches from current directory)
# Usage: fcd [starting_directory]
function fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git ${1:-.} 2>/dev/null | fzf --height 40% --reverse --header "Browse directories")
    if [ -n "$dir" ]; then
        builtin cd "$dir"
    fi
}

# Alias for quick access
alias fzcd='fcd'

# cdls - cd and ls in one command
# Usage: cdls directory
function cdls() {
    builtin cd "$@" && ls
}

# bd - Go back to a specific parent directory by name
# Usage: bd dirname
# Example: If in /a/b/c/d, 'bd b' takes you to /a/b
function bd() {
    if [ $# -eq 0 ]; then
        echo "Usage: bd <parent_directory_name>"
        return 1
    fi

    local old_dir="$PWD"
    local new_dir=""

    # Walk up the directory tree looking for matching parent
    while [ "$PWD" != "/" ]; do
        builtin cd ..
        if [ "$(basename "$PWD")" = "$1" ]; then
            new_dir="$PWD"
            break
        fi
    done

    if [ -n "$new_dir" ]; then
        zoxide add "$new_dir"
        return 0
    else
        builtin cd "$old_dir"
        echo "Error: No parent directory named '$1' found"
        return 1
    fi
}

# Show zoxide stats
alias zstats='zoxide query -l -s'

# Common directory shortcuts (customize these to your needs)
# Uncomment and modify as needed:
# alias dev='cd /Volumes/dev'
# alias repos='cd ~/repos'
# alias dotfiles='cd ~/.local/share/chezmoi'
# alias downloads='cd ~/Downloads'

# Enhanced cd completion with zoxide
# This provides better autocomplete using zoxide's database
function _zoxide_cd_completion() {
    local -a matches
    matches=(${(f)"$(zoxide query -l)"})
    _describe 'directory' matches
}

# Note: The standard zoxide initialization in plugins.zsh already provides:
# - z <query>     : Jump to directory matching query
# - zi            : Interactive directory picker (if fzf is available)
# This file enhances cd to use zoxide under the hood while maintaining familiar syntax
