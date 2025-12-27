# Nix flake environment switcher
# Uses nix-tui for interactive profile management

# Base directories (can be overridden for testing)
export FLAKES_DIR="${FLAKES_DIR:-${HOME}/nix}"
export NIX_HOMES_DIR="${NIX_HOMES_DIR:-${HOME}/.nix-homes}"
export NIX_PROFILES_FILE="${NIX_PROFILES_FILE:-${HOME}/.config/nix-profiles.json}"

# Main function to switch to a nix flake environment
flake() {
    # Check if nix-tui is available
    if ! command -v nix-tui &>/dev/null; then
        error_log "nix" "nix-tui not found. Run: mise exec go -- go build -o ~/.local/bin/nix-tui ~/.local/share/chezmoi/cmd/nix-tui"
        return 1
    fi

    # Run the TUI, capture JSON output (TUI renders to stderr, JSON to stdout)
    local result
    result=$(nix-tui)

    # No output means user cancelled
    if [[ -z "$result" ]]; then
        return 0
    fi

    # Parse JSON result
    local action
    action=$(echo "$result" | jq -r '.action')

    case "$action" in
        "switch")
            local home_path flakes profile_name
            home_path=$(echo "$result" | jq -r '.home')
            flakes=$(echo "$result" | jq -r '.flakes | join(" ")')
            profile_name=$(echo "$result" | jq -r '.profile')

            info_log "nix" "Switching to environment: ${profile_name}"

            # Update tmux pane HOME display
            if [[ -n "$TMUX" ]]; then
                tmux set-option -p @pane_home "$home_path"
            fi

            # Set environment and exec new shell with new HOME
            export REAL_HOME="$HOME"
            export FLAKE_ENV="$flakes"
            export HOME="$home_path"
            export MISE_YES=1  # Auto-approve mise prompts in flake environments
            cd "$HOME"
            exec zsh
            ;;

        "cancel")
            return 0
            ;;

        "error")
            local err
            err=$(echo "$result" | jq -r '.error')
            error_log "nix" "$err"
            return 1
            ;;

        *)
            # For delete/edit actions, TUI handles everything
            return 0
            ;;
    esac
}

# Alias for backward compatibility
flake-rm() {
    flake
}
