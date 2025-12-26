# Nix flake environment switcher
# Uses fzf to select profiles (home + flake) and opens a tmux pane

# Base directories (can be overridden for testing)
FLAKES_DIR="${FLAKES_DIR:-${HOME}/nix}"
NIX_HOMES_DIR="${NIX_HOMES_DIR:-${HOME}/.nix-homes}"
NIX_PROFILES_FILE="${NIX_PROFILES_FILE:-${HOME}/.config/nix-profiles.json}"

# Config files/directories to symlink from real home
NIX_CONFIG_SYMLINKS=(
    ".config"
    ".zshrc"
    ".zprofile"
    ".env"
    ".oh-my-zsh"
    ".gnupg"
    "nix"
    "Library/Keychains"
)

# Ensure profiles file exists
_nix_ensure_profiles() {
    if [[ ! -f "$NIX_PROFILES_FILE" ]]; then
        mkdir -p "$(dirname "$NIX_PROFILES_FILE")"
        echo '[]' > "$NIX_PROFILES_FILE"
    fi
}

# Set up symlinks in new home directory
# Returns 0 if setup was performed (first run), 1 if skipped
_nix_setup_home() {
    local new_home="$1"
    local real_home="$2"

    # Check if directory is empty (or only has .nix-profile etc)
    local file_count=$(find "$new_home" -maxdepth 1 -type f -o -type l 2>/dev/null | wc -l)
    if [[ $file_count -gt 0 ]]; then
        return 1  # Not empty, skip setup
    fi

    info_log "nix" "Setting up symlinks in $new_home..."
    for item in "${NIX_CONFIG_SYMLINKS[@]}"; do
        local src="${real_home}/${item}"
        local dst="${new_home}/${item}"
        if [[ -e "$src" ]] && [[ ! -e "$dst" ]]; then
            mkdir -p "$(dirname "$dst")"
            ln -s "$src" "$dst"
            debug_log "nix" "Linked: $item"
        fi
    done
    return 0  # First run setup completed
}

# Run first-time setup tasks (mise install, nvim plugins)
_nix_first_run_setup() {
    local home_path="$1"

    info_log "nix" "Running first-time setup..."

    # Install mise-managed tools
    if command -v mise &>/dev/null; then
        info_log "nix" "Installing mise tools..."
        # Trust all mise configs to prevent prompts in flake environments
        HOME="$home_path" MISE_YES=1 mise trust --all 2>/dev/null || true
        HOME="$home_path" MISE_YES=1 mise install --yes
    fi

    # Install nvim plugins via lazy.nvim
    if command -v nvim &>/dev/null; then
        info_log "nix" "Installing nvim plugins..."
        HOME="$home_path" nvim --headless "+Lazy! sync" +qa 2>/dev/null
    fi

    info_log "nix" "First-time setup complete!"
}

# List available flakes
_nix_list_flakes() {
    for dir in "$FLAKES_DIR"/*/; do
        if [[ -f "${dir}flake.nix" ]]; then
            basename "$dir"
        fi
    done
}

# Add a new profile (supports multiple flakes)
_nix_add_profile() {
    local home_path="$1"
    local profile_name="$2"
    shift 2
    local flakes=("$@")  # remaining args are flake names

    _nix_ensure_profiles

    # Convert flakes array to JSON array
    local flakes_json=$(printf '%s\n' "${flakes[@]}" | jq -R . | jq -s .)

    # Add profile using jq
    local tmp=$(mktemp)
    jq --arg name "$profile_name" \
       --arg home "$home_path" \
       --argjson flakes "$flakes_json" \
       '. += [{"name": $name, "home": $home, "flakes": $flakes}]' \
       "$NIX_PROFILES_FILE" > "$tmp" && mv "$tmp" "$NIX_PROFILES_FILE"
}

# Create a new profile interactively
_nix_create_profile() {
    info_log "nix" "Creating new profile..."

    # Get profile name (becomes home dir name)
    echo -n "Home name: "
    read profile_name

    if [[ -z "$profile_name" ]]; then
        error_log "nix" "Home name required"
        return 1
    fi

    # Home is always under ~/.nix-homes/<name>
    local home_path="${NIX_HOMES_DIR}/${profile_name}"

    # Multi-select flakes with fzf
    local available_flakes=($(_nix_list_flakes))
    if [[ ${#available_flakes[@]} -eq 0 ]]; then
        error_log "nix" "No flakes found in $FLAKES_DIR"
        return 1
    fi

    local selected_flakes
    selected_flakes=$(printf '%s\n' "${available_flakes[@]}" | fzf --multi --prompt="Select flakes (TAB=multi, ENTER=confirm): " --height=40% --reverse)

    if [[ -z "$selected_flakes" ]]; then
        warn_log "nix" "No flakes selected"
        return 1
    fi

    # Convert newline-separated to array
    local flakes_array=("${(@f)selected_flakes}")

    # Save the profile
    _nix_add_profile "$home_path" "$profile_name" "${flakes_array[@]}"
    info_log "nix" "Profile '$profile_name' saved with flakes: ${flakes_array[*]}"

    # Return the profile for immediate use (flakes joined by comma)
    local flakes_str="${(j:,:)flakes_array}"
    echo "$profile_name|$home_path|$flakes_str"
}

# Main function to switch to a nix flake environment
flake() {
    _nix_ensure_profiles

    # Build list: saved profiles + "New profile" option
    # Handle both old format (single flake) and new format (flakes array)
    local profiles
    profiles=$(jq -r '.[] |
        if .flakes then
            "\(.name) [\(.flakes | join(", "))] → \(.home)"
        else
            "\(.name) [\(.flake)] → \(.home)"
        end' "$NIX_PROFILES_FILE" 2>/dev/null)

    local options
    if [[ -n "$profiles" ]]; then
        options=$(printf '%s\n%s' "$profiles" "[+] New profile...")
    else
        options="[+] New profile..."
    fi

    # Select with fzf
    local selected
    selected=$(echo "$options" | fzf --prompt="Select profile: " --height=40% --reverse)

    if [[ -z "$selected" ]]; then
        return 0
    fi

    local home_path flakes_csv profile_name

    if [[ "$selected" == "[+] New profile..." ]]; then
        # Create new profile
        local result
        result=$(_nix_create_profile)
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        # Parse the result (last line contains: name|home|flakes_csv)
        local last_line=$(echo "$result" | tail -1)
        profile_name=$(echo "$last_line" | cut -d'|' -f1)
        home_path=$(echo "$last_line" | cut -d'|' -f2)
        flakes_csv=$(echo "$last_line" | cut -d'|' -f3)
    else
        # Extract profile name from selection
        profile_name=$(echo "$selected" | sed 's/ \[.*//')

        # Get home and flakes from profile (handle both old and new format)
        home_path=$(jq -r --arg name "$profile_name" '.[] | select(.name == $name) | .home' "$NIX_PROFILES_FILE")
        flakes_csv=$(jq -r --arg name "$profile_name" '.[] | select(.name == $name) |
            if .flakes then .flakes | join(",") else .flake end' "$NIX_PROFILES_FILE")
    fi

    if [[ -z "$home_path" ]] || [[ -z "$flakes_csv" ]]; then
        error_log "nix" "Could not determine home or flakes"
        return 1
    fi

    # Convert CSV to array
    local flakes_array=("${(@s:,:)flakes_csv}")

    # Store original HOME
    local real_home="$HOME"

    # Ensure home directory exists
    mkdir -p "$home_path"

    # Set up symlinks if home is empty (track if first run)
    local is_first_run=0
    if _nix_setup_home "$home_path" "$real_home"; then
        is_first_run=1
    fi

    # Install/upgrade each flake
    info_log "nix" "Applying flakes: ${flakes_array[*]}"

    for flake_name in "${flakes_array[@]}"; do
        local flake_path="${FLAKES_DIR}/${flake_name}"

        if [[ ! -d "$flake_path" ]]; then
            warn_log "nix" "Flake '$flake_name' not found at $flake_path, skipping"
            continue
        fi

        # Install the flake to profile (if not already installed)
        if ! nix profile list --profile "${home_path}/.nix-profile" 2>/dev/null | grep -q "${flake_path}"; then
            info_log "nix" "Installing flake: $flake_name..."
            # Use priority 10 to allow conflicts (higher = lower priority, existing packages win)
            if ! nix profile add "${flake_path}" --profile "${home_path}/.nix-profile" --priority 10 2>&1; then
                warn_log "nix" "Failed to install flake '$flake_name', continuing..."
            fi
        else
            debug_log "nix" "Flake already installed: $flake_name"
        fi
    done

    # Upgrade all packages in profile
    info_log "nix" "Upgrading nix profile..."
    nix profile upgrade '.*' --profile "${home_path}/.nix-profile" 2>/dev/null || true

    # Run first-time setup if this is a new home
    if [[ $is_first_run -eq 1 ]]; then
        _nix_first_run_setup "$home_path"
    else
        # Trust mise configs on every run (in case new configs were added)
        if command -v mise &>/dev/null; then
            HOME="$home_path" MISE_YES=1 mise trust --all 2>/dev/null || true
        fi
    fi

    info_log "nix" "Switching to environment: ${profile_name}"

    # Update tmux pane HOME display
    if [[ -n "$TMUX" ]]; then
        tmux set-option -p @pane_home "$home_path"
    fi

    # Set environment and exec new shell with new HOME
    export REAL_HOME="$real_home"
    export FLAKE_ENV="${flakes_array[*]}"
    export HOME="$home_path"
    export MISE_YES=1  # Auto-approve mise prompts in flake environments
    cd "$HOME"
    exec zsh
}

# Remove a profile
flake-rm() {
    _nix_ensure_profiles

    local profiles
    profiles=$(jq -r '.[] | .name' "$NIX_PROFILES_FILE" 2>/dev/null)

    if [[ -z "$profiles" ]]; then
        info_log "nix" "No profiles to remove"
        return 0
    fi

    local selected
    selected=$(echo "$profiles" | fzf --prompt="Remove profile: " --height=40% --reverse)

    if [[ -z "$selected" ]]; then
        return 0
    fi

    local tmp=$(mktemp)
    jq --arg name "$selected" 'del(.[] | select(.name == $name))' \
        "$NIX_PROFILES_FILE" > "$tmp" && mv "$tmp" "$NIX_PROFILES_FILE"

    info_log "nix" "Profile '$selected' removed"
}
