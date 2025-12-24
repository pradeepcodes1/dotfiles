# Theme management for CLI tools
# Colors are defined in ~/.config/colors/<theme>.sh

# Directories
_DOTFILES_COLORS_DIR="$HOME/.config/colors"
_DOTFILES_THEME_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme"

# Default themes for each mode
_DOTFILES_DARK_THEME="kanagawa-dragon"
_DOTFILES_LIGHT_THEME="kanagawa-lotus"

# Yazi flavor mapping (theme name -> yazi flavor name)
typeset -A _DOTFILES_YAZI_FLAVORS
_DOTFILES_YAZI_FLAVORS=(
  [kanagawa-dragon]="kanagawa-dragon"
  [kanagawa-wave]="kanagawa"
  [kanagawa-lotus]="kanagawa-lotus"
  [catppuccin-mocha]="catppuccin-mocha"
  [catppuccin-latte]="catppuccin-latte"
  [gruvbox-dark]="gruvbox-dark"
  [gruvbox-light]="gruvbox-dark"
  [everforest-dark]="everforest-medium"
  [everforest-light]="everforest-medium"
  [nightfox]="catppuccin-mocha"
  [dawnfox]="catppuccin-latte"
)

# Bat theme mapping (theme name -> bat theme name)
typeset -A _DOTFILES_BAT_THEMES
_DOTFILES_BAT_THEMES=(
  [kanagawa-dragon]="TwoDark"
  [kanagawa-wave]="TwoDark"
  [kanagawa-lotus]="OneHalfLight"
  [catppuccin-mocha]="Catppuccin Mocha"
  [catppuccin-latte]="Catppuccin Latte"
  [gruvbox-dark]="gruvbox-dark"
  [gruvbox-light]="gruvbox-light"
  [everforest-dark]="TwoDark"
  [everforest-light]="OneHalfLight"
  [nightfox]="Catppuccin Mocha"
  [dawnfox]="Catppuccin Latte"
)

# Detect macOS appearance
_detect_macos_theme() {
  if defaults read -g AppleInterfaceStyle &>/dev/null; then
    echo "dark"
  else
    echo "light"
  fi
}

# Load colors from theme file
_load_theme_colors() {
  local theme_name="$1"
  local color_file="$_DOTFILES_COLORS_DIR/${theme_name}.sh"

  debug_log "theme" "_load_theme_colors: theme_name='$theme_name'"
  debug_log "theme" "_load_theme_colors: color_file='$color_file'"

  if [[ ! -f "$color_file" ]]; then
    error_log "theme" "Color file not found: $color_file"
    return 1
  fi

  debug_log "theme" "_load_theme_colors: sourcing color file..."
  # Source the color file to get all variables
  source "$color_file"

  # Extract mode and transparent from comments
  local mode=$(grep '^# Mode:' "$color_file" | cut -d: -f2 | tr -d ' ')
  local transparent=$(grep '^# Transparent:' "$color_file" | cut -d: -f2 | tr -d ' ')

  debug_log "theme" "_load_theme_colors: extracted mode='$mode' transparent='$transparent'"

  export _DOTFILES_THEME_NAME="$theme_name"
  export _DOTFILES_THEME_MODE="$mode"
  export _DOTFILES_THEME_TRANSPARENT="$transparent"

  debug_log "theme" "_load_theme_colors: exported vars (name='$_DOTFILES_THEME_NAME' mode='$_DOTFILES_THEME_MODE')"

  # Export nvim-specific vars if set
  [[ -n "$nvim_colorscheme" ]] && export _DOTFILES_NVIM_COLORSCHEME="$nvim_colorscheme"
  [[ -n "$nvim_lualine" ]] && export _DOTFILES_NVIM_LUALINE="$nvim_lualine"
  [[ -n "$nvim_background" ]] && export _DOTFILES_NVIM_BACKGROUND="$nvim_background"

  debug_log "theme" "_load_theme_colors: complete"
}

# Get list of available themes from color files
_get_available_themes() {
  for f in "$_DOTFILES_COLORS_DIR"/*.sh; do
    [[ -f "$f" ]] && basename "$f" .sh
  done
}

# Interactive theme picker using fzf
_theme_fzf_pick() {
  local filter="$1"  # "all", "light", or "dark"
  local themes_list=()

  for theme in $(_get_available_themes); do
    local color_file="$_DOTFILES_COLORS_DIR/${theme}.sh"
    local mode=$(grep '^# Mode:' "$color_file" | cut -d: -f2 | tr -d ' ')
    local current=""
    [[ "$theme" == "$_DOTFILES_THEME_NAME" ]] && current="*"

    if [[ "$filter" == "all" ]] || [[ "$filter" == "$mode" ]]; then
      themes_list+=("$current$theme [$mode]")
    fi
  done

  local selected
  selected=$(printf '%s\n' "${themes_list[@]}" | sort | fzf --prompt="Select theme: " --height=40% --reverse)

  if [[ -n "$selected" ]]; then
    local theme_name="${selected#\*}"
    theme_name="${theme_name%% \[*}"
    echo "$theme_name"
  fi
}

# Main theme command
theme() {
  local arg="${1:-}"
  local theme_name

  debug_log "theme" "Entry: arg='$arg'"
  debug_log "theme" "Current: name='$_DOTFILES_THEME_NAME' mode='$_DOTFILES_THEME_MODE'"

  case "$arg" in
    "")
      debug_log "theme" "Mode: interactive (fzf all)"
      theme_name="$(_theme_fzf_pick all)"
      debug_log "theme" "Selected: '$theme_name'"
      [[ -z "$theme_name" ]] && { debug_log "theme" "Aborted: no selection"; return 0; }
      ;;
    toggle)
      debug_log "theme" "Mode: toggle"
      if [[ "$_DOTFILES_THEME_MODE" == "dark" ]]; then
        theme_name="$_DOTFILES_LIGHT_THEME"
        debug_log "theme" "Toggling dark->light: '$theme_name'"
      else
        theme_name="$_DOTFILES_DARK_THEME"
        debug_log "theme" "Toggling light->dark: '$theme_name'"
      fi
      ;;
    light)
      debug_log "theme" "Mode: interactive (fzf light)"
      theme_name="$(_theme_fzf_pick light)"
      debug_log "theme" "Selected: '$theme_name'"
      [[ -z "$theme_name" ]] && { debug_log "theme" "Aborted: no selection"; return 0; }
      ;;
    dark)
      debug_log "theme" "Mode: interactive (fzf dark)"
      theme_name="$(_theme_fzf_pick dark)"
      debug_log "theme" "Selected: '$theme_name'"
      [[ -z "$theme_name" ]] && { debug_log "theme" "Aborted: no selection"; return 0; }
      ;;
    list)
      echo "Available themes:"
      for theme in $(_get_available_themes); do
        local color_file="$_DOTFILES_COLORS_DIR/${theme}.sh"
        local mode=$(grep '^# Mode:' "$color_file" | cut -d: -f2 | tr -d ' ')
        local current=""
        [[ "$theme" == "$_DOTFILES_THEME_NAME" ]] && current=" (current)"
        echo "  $theme [$mode]$current"
      done
      return 0
      ;;
    status)
      echo "Theme: $_DOTFILES_THEME_NAME"
      echo "Mode: $_DOTFILES_THEME_MODE"
      echo "Transparent: $_DOTFILES_THEME_TRANSPARENT"
      [[ -f "$_DOTFILES_THEME_FILE" ]] && echo "Persisted: yes" || echo "Persisted: no (using system)"
      return 0
      ;;
    reset)
      debug_log "theme" "Mode: reset"
      rm -f "$_DOTFILES_THEME_FILE"
      debug_log "theme" "Removed: $_DOTFILES_THEME_FILE"
      _init_theme
      _apply_theme
      echo "Reset to system theme: $_DOTFILES_THEME_NAME ($_DOTFILES_THEME_MODE mode)"
      return 0
      ;;
    *)
      debug_log "theme" "Mode: direct (name='$arg')"
      theme_name="$arg"
      ;;
  esac

  # Load and apply the theme
  debug_log "theme" "Loading colors: '$theme_name'"
  if ! _load_theme_colors "$theme_name"; then
    error_log "theme" "Failed to load theme '$theme_name'"
    return 1
  fi
  debug_log "theme" "Loaded: name='$_DOTFILES_THEME_NAME' mode='$_DOTFILES_THEME_MODE' transparent='$_DOTFILES_THEME_TRANSPARENT'"

  # Persist
  local theme_dir="$(dirname "$_DOTFILES_THEME_FILE")"
  debug_log "theme" "Persisting to: $_DOTFILES_THEME_FILE"
  mkdir -p "$theme_dir"
  if echo "$theme_name" > "$_DOTFILES_THEME_FILE"; then
    debug_log "theme" "Persisted: success (contents='$(cat "$_DOTFILES_THEME_FILE")')"
  else
    error_log "theme" "Failed to persist to $_DOTFILES_THEME_FILE"
  fi

  # Apply to all apps
  debug_log "theme" "Applying to all apps..."
  _apply_theme

  echo "Switched to: $_DOTFILES_THEME_NAME ($_DOTFILES_THEME_MODE mode)"
  echo "Note: Restart nvim/yazi for full effect."
}

# Apply theme to all apps
_apply_theme() {
  debug_log "theme" "_apply_theme: starting..."

  debug_log "theme" "_apply_theme: updating zsh prompt..."
  _update_zsh_prompt

  debug_log "theme" "_apply_theme: updating alacritty..."
  _update_alacritty_theme

  debug_log "theme" "_apply_theme: updating ghostty..."
  _update_ghostty_theme

  debug_log "theme" "_apply_theme: updating tmux..."
  _update_tmux_theme

  debug_log "theme" "_apply_theme: updating yazi..."
  _update_yazi_theme

  debug_log "theme" "_apply_theme: updating fzf..."
  _update_fzf_theme

  debug_log "theme" "_apply_theme: updating claude..."
  _update_claude_theme

  debug_log "theme" "_apply_theme: updating bat..."
  _update_bat_theme

  debug_log "theme" "_apply_theme: complete"
}

# Update bat theme
_update_bat_theme() {
  local bat_config="$HOME/.config/bat/config"
  local bat_theme="${_DOTFILES_BAT_THEMES[$_DOTFILES_THEME_NAME]}"

  debug_log "theme" "_update_bat_theme: theme='$_DOTFILES_THEME_NAME' bat_theme='$bat_theme'"

  # Default to TwoDark if not mapped
  [[ -z "$bat_theme" ]] && bat_theme="TwoDark"

  mkdir -p "$(dirname "$bat_config")"
  if echo "--theme=\"$bat_theme\"" > "$bat_config"; then
    debug_log "theme" "_update_bat_theme: wrote to $bat_config"
  else
    error_log "theme" "_update_bat_theme: failed to write $bat_config"
  fi
}

# Update zsh prompt using sourced color variables
_update_zsh_prompt() {
  debug_log "theme" "_update_zsh_prompt: updating prompt colors..."

  # Colors are already sourced: prompt_dir, prompt_branch, etc.
  zstyle ':vcs_info:git:*' unstagedstr "%F{$prompt_unstaged}*%f"
  zstyle ':vcs_info:git:*' stagedstr "%F{$prompt_staged}+%f"
  zstyle ':vcs_info:git:*' formats " %F{$prompt_branch}(%b%u%c)%f"
  zstyle ':vcs_info:git:*' actionformats " %F{$prompt_branch}(%b|%a%u%c)%f"

  PROMPT="%F{$prompt_dir}%1~%f\${vcs_info_msg_0_} %F{$prompt_arrow}❯%f "
  RPROMPT="%F{$prompt_path}%~%f"

  debug_log "theme" "_update_zsh_prompt: prompt updated"
}

# Generate and apply Alacritty theme
_update_alacritty_theme() {
  local config="$HOME/.config/alacritty/alacritty.toml"
  local theme_file="$HOME/.config/alacritty/themes/${_DOTFILES_THEME_NAME}.toml"

  debug_log "theme" "_update_alacritty_theme: config='$config' theme_file='$theme_file'"

  if [[ ! -f "$config" ]]; then
    debug_log "theme" "_update_alacritty_theme: config not found, skipping"
    return
  fi

  # Generate theme file from colors
  mkdir -p "$(dirname "$theme_file")"
  if cat > "$theme_file" <<EOF
[colors.primary]
background = "$bg"
foreground = "$fg"

[colors.normal]
black = "$black"
red = "$red"
green = "$green"
yellow = "$yellow"
blue = "$blue"
magenta = "$magenta"
cyan = "$cyan"
white = "$white"

[colors.bright]
black = "$bright_black"
red = "$bright_red"
green = "$bright_green"
yellow = "$bright_yellow"
blue = "$bright_blue"
magenta = "$bright_magenta"
cyan = "$bright_cyan"
white = "$bright_white"
EOF
  then
    debug_log "theme" "_update_alacritty_theme: wrote theme file"
  else
    error_log "theme" "_update_alacritty_theme: failed to write theme file"
    return 1
  fi

  # Update import line
  if sed -i '' 's|^import = \[.*\]|import = ["~/.config/alacritty/themes/'"$_DOTFILES_THEME_NAME"'.toml"]|' "$config"; then
    debug_log "theme" "_update_alacritty_theme: updated import in config"
  else
    error_log "theme" "_update_alacritty_theme: failed to update import"
  fi
}

# Generate and apply Ghostty theme
_update_ghostty_theme() {
  local theme_dir="$HOME/.config/ghostty/themes"
  local theme_file="$theme_dir/current.conf"

  debug_log "theme" "_update_ghostty_theme: theme_file='$theme_file'"

  if [[ ! -d "$HOME/.config/ghostty" ]]; then
    debug_log "theme" "_update_ghostty_theme: ghostty config not found, skipping"
    return
  fi

  mkdir -p "$theme_dir"

  # Strip # from colors for Ghostty format (bg/fg don't use #, palette does)
  local bg_clean="${bg#\#}"
  local fg_clean="${fg#\#}"

  if cat > "$theme_file" <<EOF
# Ghostty theme: $_DOTFILES_THEME_NAME
# Auto-generated by theme system

background = $bg_clean
foreground = $fg_clean

# Normal colors
palette = 0=$black
palette = 1=$red
palette = 2=$green
palette = 3=$yellow
palette = 4=$blue
palette = 5=$magenta
palette = 6=$cyan
palette = 7=$white

# Bright colors
palette = 8=$bright_black
palette = 9=$bright_red
palette = 10=$bright_green
palette = 11=$bright_yellow
palette = 12=$bright_blue
palette = 13=$bright_magenta
palette = 14=$bright_cyan
palette = 15=$bright_white
EOF
  then
    debug_log "theme" "_update_ghostty_theme: wrote theme file"
  else
    error_log "theme" "_update_ghostty_theme: failed to write theme file"
  fi
}

# Generate and apply tmux theme
_update_tmux_theme() {
  local theme_file="$HOME/.config/tmux/themes/${_DOTFILES_THEME_NAME}.conf"

  debug_log "theme" "_update_tmux_theme: theme_file='$theme_file'"

  mkdir -p "$(dirname "$theme_file")"

  # Generate theme file from colors
  # Use ui_inactive for status bar bg to stand out from terminal bg
  if cat > "$theme_file" <<EOF
# Tmux theme: $_DOTFILES_THEME_NAME
set -g status-style "fg=$ui_fg,bg=$ui_inactive"
set -g window-status-format "#[bg=$ui_border,fg=$ui_fg]  #I#F  "
set -g window-status-current-format "#[bg=$ui_active,fg=$ui_bg,bold]  #I#F  "
set -g pane-border-style "fg=$ui_border"
set -g pane-active-border-style "fg=$ui_active"
set -g message-style "fg=$ui_fg,bg=$ui_inactive"
set -g mode-style "fg=$ui_bg,bg=$ui_active"
EOF
  then
    debug_log "theme" "_update_tmux_theme: wrote theme file"
  else
    error_log "theme" "_update_tmux_theme: failed to write theme file"
    return 1
  fi

  # Source if inside tmux
  if [[ -n "$TMUX" ]]; then
    debug_log "theme" "_update_tmux_theme: sourcing in active tmux session..."
    if tmux source-file "$theme_file" 2>/dev/null; then
      debug_log "theme" "_update_tmux_theme: sourced successfully"
    else
      error_log "theme" "_update_tmux_theme: failed to source in tmux"
    fi
  else
    debug_log "theme" "_update_tmux_theme: not in tmux, skipping source"
  fi
}

# Update yazi theme
_update_yazi_theme() {
  local yazi_config="$HOME/.config/yazi/theme.toml"
  local flavor="${_DOTFILES_YAZI_FLAVORS[$_DOTFILES_THEME_NAME]}"

  [[ -z "$flavor" ]] && return

  if [[ ! -d "$HOME/.config/yazi/flavors/${flavor}.yazi" ]]; then
    echo "Note: yazi flavor '$flavor' not installed" >&2
    return
  fi

  if [[ "$_DOTFILES_THEME_MODE" == "dark" ]]; then
    echo "[flavor]\ndark = \"$flavor\"" > "$yazi_config"
  else
    echo "[flavor]\nlight = \"$flavor\"" > "$yazi_config"
  fi
}

# Update Claude CLI theme
_update_claude_theme() {
  local claude_config="$HOME/.claude.json"
  local mode="$_DOTFILES_THEME_MODE"

  [[ ! -f "$claude_config" ]] && return

  # Update theme using sed (jq may not be available)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/"theme": *"[^"]*"/"theme": "'"$mode"'"/' "$claude_config"
  else
    sed -i 's/"theme": *"[^"]*"/"theme": "'"$mode"'"/' "$claude_config"
  fi
}

# Update fzf theme
_update_fzf_theme() {
  # Use transparent bg (-1) if theme supports it, otherwise use theme bg
  local fzf_bg="-1"
  [[ "$_DOTFILES_THEME_TRANSPARENT" != "1" ]] && fzf_bg="$bg"

  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --color=fg:$fg,bg:$fzf_bg,hl:$magenta \
    --color=fg+:$fg,bg+:$ui_inactive,hl+:$ui_active \
    --color=info:$bright_black,prompt:$ui_accent,pointer:$ui_accent \
    --color=marker:$green,spinner:$ui_accent,header:$bright_black"
}

# Initialize on shell startup
_init_theme() {
  local theme_name

  debug_log "theme" "_init_theme: starting..."
  debug_log "theme" "_init_theme: theme_file='$_DOTFILES_THEME_FILE'"

  # Check for persisted theme
  if [[ -f "$_DOTFILES_THEME_FILE" ]]; then
    theme_name="$(< "$_DOTFILES_THEME_FILE")"
    debug_log "theme" "_init_theme: found persisted theme='$theme_name'"

    if [[ -f "$_DOTFILES_COLORS_DIR/${theme_name}.sh" ]]; then
      debug_log "theme" "_init_theme: loading persisted theme..."
      _load_theme_colors "$theme_name"
      _update_zsh_prompt
      _update_fzf_theme
      debug_log "theme" "_init_theme: complete (persisted)"
      return
    else
      warn_log "theme" "_init_theme: persisted theme file not found, falling back"
    fi
  else
    debug_log "theme" "_init_theme: no persisted theme, using system detection"
  fi

  # Fall back to system detection
  local system_mode="$(_detect_macos_theme)"
  debug_log "theme" "_init_theme: system mode='$system_mode'"

  if [[ "$system_mode" == "dark" ]]; then
    theme_name="$_DOTFILES_DARK_THEME"
  else
    theme_name="$_DOTFILES_LIGHT_THEME"
  fi

  debug_log "theme" "_init_theme: using default theme='$theme_name'"
  _load_theme_colors "$theme_name"
  _update_zsh_prompt
  _update_fzf_theme
  debug_log "theme" "_init_theme: complete (system default)"
}

_init_theme
