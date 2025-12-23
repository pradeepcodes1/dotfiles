# Nix flake environment switcher
# Uses fzf to select profiles (home + flake) and opens a tmux pane

# Base directories
FLAKES_DIR="${HOME}/nix"
NIX_HOMES_DIR="${HOME}/.nix-homes"
NIX_PROFILES_FILE="${HOME}/.config/nix-profiles.json"

# Config files/directories to symlink from real home
NIX_CONFIG_SYMLINKS=(
    ".config"
    ".zshrc"
    ".zprofile"
    ".env"
    ".oh-my-zsh"
    ".p10k.zsh"
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

    echo "Setting up symlinks in $new_home..."
    for item in "${NIX_CONFIG_SYMLINKS[@]}"; do
        local src="${real_home}/${item}"
        local dst="${new_home}/${item}"
        if [[ -e "$src" ]] && [[ ! -e "$dst" ]]; then
            mkdir -p "$(dirname "$dst")"
            ln -s "$src" "$dst"
            echo "  Linked: $item"
        fi
    done
    return 0  # First run setup completed
}

# Run first-time setup tasks (mise install, nvim plugins)
_nix_first_run_setup() {
    local home_path="$1"

    echo "Running first-time setup..."

    # Install mise-managed tools
    if command -v mise &>/dev/null; then
        echo "Installing mise tools..."
        HOME="$home_path" mise install --yes
    fi

    # Install nvim plugins via lazy.nvim
    if command -v nvim &>/dev/null; then
        echo "Installing nvim plugins..."
        HOME="$home_path" nvim --headless "+Lazy! sync" +qa 2>/dev/null
    fi

    echo "First-time setup complete!"
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
    echo "Creating new profile..."

    # Get profile name (becomes home dir name)
    echo -n "Home name: "
    read profile_name

    if [[ -z "$profile_name" ]]; then
        echo "Home name required"
        return 1
    fi

    # Home is always under ~/.nix-homes/<name>
    local home_path="${NIX_HOMES_DIR}/${profile_name}"

    # Multi-select flakes with fzf
    local available_flakes=($(_nix_list_flakes))
    if [[ ${#available_flakes[@]} -eq 0 ]]; then
        echo "No flakes found in $FLAKES_DIR"
        return 1
    fi

    local selected_flakes
    selected_flakes=$(printf '%s\n' "${available_flakes[@]}" | fzf --multi --prompt="Select flakes (TAB=multi, ENTER=confirm): " --height=40% --reverse)

    if [[ -z "$selected_flakes" ]]; then
        echo "No flakes selected"
        return 1
    fi

    # Convert newline-separated to array
    local flakes_array=("${(@f)selected_flakes}")

    # Save the profile
    _nix_add_profile "$home_path" "$profile_name" "${flakes_array[@]}"
    echo "Profile '$profile_name' saved with flakes: ${flakes_array[*]}"

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
        echo "Error: Could not determine home or flakes"
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
    echo "Applying flakes: ${flakes_array[*]}"

    for flake_name in "${flakes_array[@]}"; do
        local flake_path="${FLAKES_DIR}/${flake_name}"

        if [[ ! -d "$flake_path" ]]; then
            echo "Warning: Flake '$flake_name' not found at $flake_path, skipping"
            continue
        fi

        # Install the flake to profile (if not already installed)
        if ! nix profile list --profile "${home_path}/.nix-profile" 2>/dev/null | grep -q "${flake_path}"; then
            echo "Installing flake: $flake_name..."
            nix profile install "${flake_path}" --profile "${home_path}/.nix-profile"
        else
            echo "Flake already installed: $flake_name"
        fi
    done

    # Upgrade all packages in profile
    echo "Upgrading nix profile..."
    nix profile upgrade '.*' --profile "${home_path}/.nix-profile" 2>/dev/null || true

    # Run first-time setup if this is a new home
    if [[ $is_first_run -eq 1 ]]; then
        _nix_first_run_setup "$home_path"
    fi

    echo "Switching to environment: ${profile_name}"

    # Update tmux pane HOME display
    if [[ -n "$TMUX" ]]; then
        tmux set-option -p @pane_home "$home_path"
    fi

    # Set environment and exec new shell with new HOME
    export REAL_HOME="$real_home"
    export FLAKE_ENV="${flakes_array[*]}"
    export HOME="$home_path"
    cd "$HOME"
    exec zsh
}

# Remove a profile
flake-rm() {
    _nix_ensure_profiles

    local profiles
    profiles=$(jq -r '.[] | .name' "$NIX_PROFILES_FILE" 2>/dev/null)

    if [[ -z "$profiles" ]]; then
        echo "No profiles to remove"
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

    echo "Profile '$selected' removed"
}
