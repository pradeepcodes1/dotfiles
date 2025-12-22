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

  if [[ ! -f "$color_file" ]]; then
    echo "Color file not found: $color_file" >&2
    return 1
  fi

  # Source the color file to get all variables
  source "$color_file"

  # Extract mode and transparent from comments
  local mode=$(grep '^# Mode:' "$color_file" | cut -d: -f2 | tr -d ' ')
  local transparent=$(grep '^# Transparent:' "$color_file" | cut -d: -f2 | tr -d ' ')

  export _DOTFILES_THEME_NAME="$theme_name"
  export _DOTFILES_THEME_MODE="$mode"
  export _DOTFILES_THEME_TRANSPARENT="$transparent"

  # Export nvim-specific vars if set
  [[ -n "$nvim_colorscheme" ]] && export _DOTFILES_NVIM_COLORSCHEME="$nvim_colorscheme"
  [[ -n "$nvim_lualine" ]] && export _DOTFILES_NVIM_LUALINE="$nvim_lualine"
  [[ -n "$nvim_background" ]] && export _DOTFILES_NVIM_BACKGROUND="$nvim_background"
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

  case "$arg" in
    "")
      theme_name="$(_theme_fzf_pick all)"
      [[ -z "$theme_name" ]] && return 0
      ;;
    toggle)
      if [[ "$_DOTFILES_THEME_MODE" == "dark" ]]; then
        theme_name="$_DOTFILES_LIGHT_THEME"
      else
        theme_name="$_DOTFILES_DARK_THEME"
      fi
      ;;
    light)
      theme_name="$(_theme_fzf_pick light)"
      [[ -z "$theme_name" ]] && return 0
      ;;
    dark)
      theme_name="$(_theme_fzf_pick dark)"
      [[ -z "$theme_name" ]] && return 0
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
      rm -f "$_DOTFILES_THEME_FILE"
      _init_theme
      _apply_theme
      echo "Reset to system theme: $_DOTFILES_THEME_NAME ($_DOTFILES_THEME_MODE mode)"
      return 0
      ;;
    *)
      theme_name="$arg"
      ;;
  esac

  # Load and apply the theme
  _load_theme_colors "$theme_name" || return 1

  # Persist
  mkdir -p "$(dirname "$_DOTFILES_THEME_FILE")"
  echo "$theme_name" > "$_DOTFILES_THEME_FILE"

  # Apply to all apps
  _apply_theme

  echo "Switched to: $_DOTFILES_THEME_NAME ($_DOTFILES_THEME_MODE mode)"
  echo "Note: Restart nvim/yazi for full effect."
}

# Apply theme to all apps
_apply_theme() {
  _update_zsh_prompt
  _update_alacritty_theme
  _update_ghostty_theme
  _update_tmux_theme
  _update_yazi_theme
  _update_fzf_theme
  _update_claude_theme
}

# Update zsh prompt using sourced color variables
_update_zsh_prompt() {
  # Colors are already sourced: prompt_dir, prompt_branch, etc.
  zstyle ':vcs_info:git:*' unstagedstr "%F{$prompt_unstaged}*%f"
  zstyle ':vcs_info:git:*' stagedstr "%F{$prompt_staged}+%f"
  zstyle ':vcs_info:git:*' formats " %F{$prompt_branch}(%b%u%c)%f"
  zstyle ':vcs_info:git:*' actionformats " %F{$prompt_branch}(%b|%a%u%c)%f"

  PROMPT="%F{$prompt_dir}%1~%f\${vcs_info_msg_0_} %F{$prompt_arrow}❯%f "
  RPROMPT="%F{$prompt_path}%~%f"
}

# Generate and apply Alacritty theme
_update_alacritty_theme() {
  local config="$HOME/.config/alacritty/alacritty.toml"
  local theme_file="$HOME/.config/alacritty/themes/${_DOTFILES_THEME_NAME}.toml"

  [[ ! -f "$config" ]] && return

  # Generate theme file from colors
  cat > "$theme_file" <<EOF
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

  # Update import line
  sed -i '' 's|^import = \[.*\]|import = ["~/.config/alacritty/themes/'"$_DOTFILES_THEME_NAME"'.toml"]|' "$config"
}

# Generate and apply Ghostty theme
_update_ghostty_theme() {
  local theme_dir="$HOME/.config/ghostty/themes"
  local theme_file="$theme_dir/current.conf"

  [[ ! -d "$HOME/.config/ghostty" ]] && return

  mkdir -p "$theme_dir"

  # Strip # from colors for Ghostty format (bg/fg don't use #, palette does)
  local bg_clean="${bg#\#}"
  local fg_clean="${fg#\#}"

  cat > "$theme_file" <<EOF
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
}

# Generate and apply tmux theme
_update_tmux_theme() {
  local theme_file="$HOME/.config/tmux/themes/${_DOTFILES_THEME_NAME}.conf"

  mkdir -p "$(dirname "$theme_file")"

  # Generate theme file from colors
  # Use ui_inactive for status bar bg to stand out from terminal bg
  cat > "$theme_file" <<EOF
# Tmux theme: $_DOTFILES_THEME_NAME
set -g status-style "fg=$ui_fg,bg=$ui_inactive"
set -g window-status-format "#[bg=$ui_border,fg=$ui_fg]  #I#F  "
set -g window-status-current-format "#[bg=$ui_active,fg=$ui_bg,bold]  #I#F  "
set -g pane-border-style "fg=$ui_border"
set -g pane-active-border-style "fg=$ui_active"
set -g message-style "fg=$ui_fg,bg=$ui_inactive"
set -g mode-style "fg=$ui_bg,bg=$ui_active"
EOF

  # Source if inside tmux
  if [[ -n "$TMUX" ]]; then
    tmux source-file "$theme_file" 2>/dev/null
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

  # Check for persisted theme
  if [[ -f "$_DOTFILES_THEME_FILE" ]]; then
    theme_name="$(< "$_DOTFILES_THEME_FILE")"
    if [[ -f "$_DOTFILES_COLORS_DIR/${theme_name}.sh" ]]; then
      _load_theme_colors "$theme_name"
      _update_zsh_prompt
      _update_fzf_theme
      return
    fi
  fi

  # Fall back to system detection
  local system_mode="$(_detect_macos_theme)"
  if [[ "$system_mode" == "dark" ]]; then
    theme_name="$_DOTFILES_DARK_THEME"
  else
    theme_name="$_DOTFILES_LIGHT_THEME"
  fi

  _load_theme_colors "$theme_name"
  _update_zsh_prompt
  _update_fzf_theme
}

_init_theme
