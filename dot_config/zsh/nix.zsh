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
    "nix"
)

# Ensure profiles file exists
_nix_ensure_profiles() {
    if [[ ! -f "$NIX_PROFILES_FILE" ]]; then
        mkdir -p "$(dirname "$NIX_PROFILES_FILE")"
        echo '[]' > "$NIX_PROFILES_FILE"
    fi
}

# Set up symlinks in new home directory
_nix_setup_home() {
    local new_home="$1"
    local real_home="$2"

    # Check if directory is empty (or only has .nix-profile etc)
    local file_count=$(find "$new_home" -maxdepth 1 -type f -o -type l 2>/dev/null | wc -l)
    if [[ $file_count -gt 0 ]]; then
        return 0  # Not empty, skip setup
    fi

    echo "Setting up symlinks in $new_home..."
    for item in "${NIX_CONFIG_SYMLINKS[@]}"; do
        local src="${real_home}/${item}"
        local dst="${new_home}/${item}"
        if [[ -e "$src" ]] && [[ ! -e "$dst" ]]; then
            ln -s "$src" "$dst"
            echo "  Linked: $item"
        fi
    done
}

# List available flakes
_nix_list_flakes() {
    for dir in "$FLAKES_DIR"/*/; do
        if [[ -f "${dir}flake.nix" ]]; then
            basename "$dir"
        fi
    done
}

# Add a new profile
_nix_add_profile() {
    local home_path="$1"
    local flake_name="$2"
    local profile_name="$3"

    _nix_ensure_profiles

    # Add profile using jq
    local tmp=$(mktemp)
    jq --arg name "$profile_name" \
       --arg home "$home_path" \
       --arg flake "$flake_name" \
       '. += [{"name": $name, "home": $home, "flake": $flake}]' \
       "$NIX_PROFILES_FILE" > "$tmp" && mv "$tmp" "$NIX_PROFILES_FILE"
}

# Create a new profile interactively
_nix_create_profile() {
    echo "Creating new profile..."

    # Get profile name
    echo -n "Profile name: "
    read profile_name

    if [[ -z "$profile_name" ]]; then
        echo "Profile name required"
        return 1
    fi

    # Home is always under ~/.nix-homes/<name>
    local home_path="${NIX_HOMES_DIR}/${profile_name}"

    # Select flake with fzf
    local flakes=($(_nix_list_flakes))
    if [[ ${#flakes[@]} -eq 0 ]]; then
        echo "No flakes found in $FLAKES_DIR"
        return 1
    fi

    local flake_name
    flake_name=$(printf '%s\n' "${flakes[@]}" | fzf --prompt="Select flake: " --height=40% --reverse)

    if [[ -z "$flake_name" ]]; then
        echo "No flake selected"
        return 1
    fi

    # Save the profile
    _nix_add_profile "$home_path" "$flake_name" "$profile_name"
    echo "Profile '$profile_name' saved!"

    # Return the profile for immediate use
    echo "$profile_name|$home_path|$flake_name"
}

# Main function to switch to a nix flake environment
flake() {
    _nix_ensure_profiles

    # Build list: saved profiles + "New profile" option
    local profiles
    profiles=$(jq -r '.[] | "\(.name) [\(.flake)] → \(.home)"' "$NIX_PROFILES_FILE" 2>/dev/null)

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

    local home_path flake_name

    if [[ "$selected" == "[+] New profile..." ]]; then
        # Create new profile
        local result
        result=$(_nix_create_profile)
        if [[ $? -ne 0 ]]; then
            return 1
        fi
        # Parse the result (last line contains: name|home|flake)
        local last_line=$(echo "$result" | tail -1)
        home_path=$(echo "$last_line" | cut -d'|' -f2)
        flake_name=$(echo "$last_line" | cut -d'|' -f3)
    else
        # Extract profile name from selection
        local profile_name=$(echo "$selected" | sed 's/ \[.*//')

        # Get home and flake from profile
        home_path=$(jq -r --arg name "$profile_name" '.[] | select(.name == $name) | .home' "$NIX_PROFILES_FILE")
        flake_name=$(jq -r --arg name "$profile_name" '.[] | select(.name == $name) | .flake' "$NIX_PROFILES_FILE")
    fi

    if [[ -z "$home_path" ]] || [[ -z "$flake_name" ]]; then
        echo "Error: Could not determine home or flake"
        return 1
    fi

    # Store original HOME
    local real_home="$HOME"
    local flake_path="${FLAKES_DIR}/${flake_name}"

    # Ensure home directory exists
    mkdir -p "$home_path"

    # Set up symlinks if home is empty
    _nix_setup_home "$home_path" "$real_home"

    # Install/upgrade flake before switching
    echo "Applying flake: ${flake_name} from ${flake_path}"

    # Install the flake to profile (if not already installed)
    if ! nix profile list --profile "${home_path}/.nix-profile" 2>/dev/null | grep -q "${flake_path}"; then
        echo "Installing flake..."
        nix profile install "${flake_path}" --profile "${home_path}/.nix-profile"
    fi

    # Upgrade all packages in profile
    echo "Upgrading nix profile..."
    nix profile upgrade '.*' --profile "${home_path}/.nix-profile" 2>/dev/null || true

    echo "Switching to environment: ${profile_name:-$flake_name}"

    # Update tmux pane HOME display
    if [[ -n "$TMUX" ]]; then
        tmux set-option -p @pane_home "$home_path"
    fi

    # Set environment and exec new shell with new HOME
    export REAL_HOME="$real_home"
    export FLAKE_ENV="$flake_name"
    export FLAKE_PATH="$flake_path"
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
