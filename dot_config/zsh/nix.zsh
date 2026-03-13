# Nix flake environment switcher
# Adds flake packages to the current session via `nix shell`

FLAKES_DIR="${FLAKES_DIR:-${HOME}/nix}"

# List available flake names (basenames of dirs containing flake.nix)
_nix_list_flakes() {
    # Get flakes already installed in the nix profile (permanent)
    local -a profile_flakes
    profile_flakes=($(nix profile list 2>/dev/null | grep "Original flake URL" | sed 's|.*/||' | sed 's|?.*||'))

    for dir in "$FLAKES_DIR"/*/; do
        local name=$(basename "$dir")
        # Skip flakes already in the permanent nix profile
        (( ${profile_flakes[(Ie)$name]} )) && continue
        if [[ -f "${dir}flake.nix" ]]; then
            echo "$name"
        fi
    done
}

# Extract description from a flake.nix file
_nix_flake_desc() {
    sed -n 's/.*description = "\(.*\)";/\1/p' "$FLAKES_DIR/$1/flake.nix" 2>/dev/null
}

# Main command: enter a nix shell with one or more flakes
#   flake                  → interactive fzf picker (multi-select)
#   flake <name> [name..]  → direct mode
flake() {
    local flake_names=()
    local flake_paths=()
    local current_flakes=()

    # Parse currently active flakes (tmux pane option is authoritative)
    local current_env=""
    if [[ -n "$TMUX" ]]; then
        current_env=$(tmux display -p '#{@flake_env}' 2>/dev/null)
    fi
    [[ -z "$current_env" && -n "$FLAKE_ENV" ]] && current_env="$FLAKE_ENV"
    if [[ -n "$current_env" ]]; then
        current_flakes=(${(s:,:)current_env})
    fi

    if [[ $# -gt 0 ]]; then
        # Direct args mode
        flake_names=("$@")
    else
        # Interactive fzf mode — put currently selected flakes at top
        local selected_lines=()
        local unselected_lines=()

        for name in $(_nix_list_flakes); do
            local desc=$(_nix_flake_desc "$name")
            local line="${name}\t${desc}"
            if (( ${current_flakes[(Ie)$name]} )); then
                selected_lines+=("$line")
            else
                unselected_lines+=("$line")
            fi
        done

        local all_lines=("${selected_lines[@]}" "${unselected_lines[@]}")

        if [[ ${#all_lines[@]} -eq 0 ]]; then
            error_log "nix" "No flakes found in $FLAKES_DIR"
            return 1
        fi

        # Build fzf load bind to pre-select current flakes (placed at top)
        local fzf_bind_args=()
        if [[ ${#selected_lines[@]} -gt 0 ]]; then
            local bind_seq="load:toggle"
            for i in $(seq 2 ${#selected_lines[@]}); do
                bind_seq+="+down+toggle"
            done
            bind_seq+="+first"
            fzf_bind_args=(--bind "$bind_seq")
        fi

        local nix_system
        nix_system=$(nix eval --raw nixpkgs#system 2>/dev/null)
        local preview_script="$HOME/.config/zsh/nix-flake-preview.sh"

        # Track selection state in a file (fzf can't distinguish 0 vs 1 selected)
        local sel_file=$(mktemp)
        trap "rm -f '$sel_file'" EXIT INT TERM
        printf '%s\n' "${current_flakes[@]}" > "$sel_file"

        # Tab bind: toggle in fzf + update tracking file + refresh preview
        local tab_bind="tab:toggle+execute-silent(if grep -qxF {1} $sel_file 2>/dev/null; then grep -vxF {1} $sel_file > ${sel_file}.tmp && mv ${sel_file}.tmp $sel_file; else echo {1} >> $sel_file; fi)+refresh-preview"

        local selected
        selected=$(printf '%b\n' "${all_lines[@]}" | column -t -s $'\t' | \
            fzf --multi \
                --header="TAB=toggle  ENTER=confirm" \
                --preview="$preview_script ${FLAKES_DIR} ${nix_system} $sel_file {1}" \
                --preview-label="packages" \
                --reverse --height=40% \
                --bind "$tab_bind" \
                "${fzf_bind_args[@]}")
        local fzf_exit=$?

        # Esc/Ctrl-C: cancel
        if [[ $fzf_exit -ne 0 ]]; then
            return 0
        fi

        # Enter with nothing selected: exit flake env if active
        if [[ -z "$selected" ]]; then
            if [[ -n "$current_env" ]]; then
                [[ -n "$TMUX" ]] && tmux set -p -u @flake_env
                info_log "nix" "Exiting flake environment"
                exec env -u FLAKE_ENV zsh
            fi
            return 0
        fi

        # Extract first word (name) from each selected line
        while IFS= read -r line; do
            flake_names+=($(echo "$line" | awk '{print $1}'))
        done <<< "$selected"
    fi

    # Validate and build paths
    for name in "${flake_names[@]}"; do
        if [[ ! -f "$FLAKES_DIR/$name/flake.nix" ]]; then
            error_log "nix" "Flake not found: $FLAKES_DIR/$name"
            return 1
        fi
        flake_paths+=("$FLAKES_DIR/$name")
    done

    local flake_csv="${(j:,:)flake_names}"

    # Set tmux pane option (authoritative source for current selection)
    [[ -n "$TMUX" ]] && tmux set -p @flake_env "$flake_csv"

    info_log "nix" "Entering nix shell: ${flake_names[*]}"
    export FLAKE_ENV="$flake_csv"
    exec nix shell "${flake_paths[@]}" --command zsh
}
