# Dotfiles Theme System

Centralized color definitions for all CLI tools. Each theme has one source file that drives colors across:
- Terminal (Alacritty)
- Shell prompt (Zsh)
- Tmux status bar
- Neovim colorscheme + lualine
- Yazi file manager
- fzf fuzzy finder

## Usage

```bash
theme                 # fzf picker for all themes
theme dark            # fzf picker for dark themes only
theme light           # fzf picker for light themes only
theme toggle          # quick switch between default dark/light
theme <name>          # switch to specific theme
theme list            # list available themes
theme status          # show current theme info
theme reset           # revert to system-detected theme
```

## Adding a New Theme

Create `<theme-name>.sh` with the following structure:

```sh
# Theme: <theme-name>
# Mode: dark|light
# Transparent: 1|0

# Terminal colors (used by Alacritty)
bg="#..."
fg="#..."

# Normal ANSI colors
black="#..."
red="#..."
green="#..."
yellow="#..."
blue="#..."
magenta="#..."
cyan="#..."
white="#..."

# Bright ANSI colors
bright_black="#..."
bright_red="#..."
bright_green="#..."
bright_yellow="#..."
bright_blue="#..."
bright_magenta="#..."
bright_cyan="#..."
bright_white="#..."

# Prompt colors (used by Zsh)
prompt_dir="#..."       # current directory
prompt_branch="#..."    # git branch name
prompt_unstaged="#..."  # unstaged changes indicator (*)
prompt_staged="#..."    # staged changes indicator (+)
prompt_arrow="#..."     # prompt arrow (❯)
prompt_path="#..."      # right prompt path

# UI colors (used by Tmux)
ui_bg="#..."            # status bar background
ui_fg="#..."            # status bar foreground
ui_accent="#..."        # accent color
ui_border="#..."        # pane border
ui_active="#..."        # active window/pane
ui_inactive="#..."      # inactive window/pane

# Neovim (optional - for themes needing special handling)
nvim_colorscheme="..."  # vim colorscheme name
nvim_lualine="..."      # lualine theme name
nvim_background="..."   # "dark" or "light" (only if colorscheme needs it)
```

## Header Comments

The first three lines must be:
```sh
# Theme: <name>
# Mode: dark|light
# Transparent: 1|0
```

These are parsed by `theme.zsh` to determine theme metadata:
- **Mode**: Controls system theme detection fallback
- **Transparent**: If `1`, enables transparent background in Alacritty/Neovim

## Color Guidelines

### Terminal Colors
Follow standard ANSI color semantics:
- `black/bright_black`: backgrounds, muted text
- `red/bright_red`: errors, deletions
- `green/bright_green`: success, additions
- `yellow/bright_yellow`: warnings, modifications
- `blue/bright_blue`: info, links
- `magenta/bright_magenta`: special, search
- `cyan/bright_cyan`: secondary info
- `white/bright_white`: primary text

### Prompt Colors
- Keep `prompt_dir` and `prompt_arrow` visually prominent
- Use semantic colors: red for unstaged, yellow/green for staged
- `prompt_path` should be muted (it's secondary info)

### UI Colors
- `ui_active` should contrast well with `ui_bg`
- `ui_inactive` should be subtle but visible
- `ui_border` typically matches `ui_inactive`

## Available Themes

| Theme | Mode | Transparent |
|-------|------|-------------|
| kanagawa-dragon | dark | yes |
| kanagawa-wave | dark | yes |
| kanagawa-lotus | light | no |
| catppuccin-mocha | dark | yes |
| catppuccin-latte | light | no |
| gruvbox-dark | dark | yes |
| gruvbox-light | light | no |
| everforest-dark | dark | yes |
| everforest-light | light | no |
| nightfox | dark | yes |
| dawnfox | light | no |

## How It Works

1. `theme.zsh` sources the selected color file
2. All variables become available in the shell
3. App-specific configs are generated:
   - **Alacritty**: `~/.config/alacritty/themes/<theme>.toml`
   - **Tmux**: `~/.config/tmux/themes/<theme>.conf`
4. Environment variables are exported for apps that read them:
   - `_DOTFILES_THEME_NAME`
   - `_DOTFILES_THEME_MODE`
   - `_DOTFILES_THEME_TRANSPARENT`
   - `_DOTFILES_NVIM_COLORSCHEME`
   - `_DOTFILES_NVIM_LUALINE`
   - `_DOTFILES_NVIM_BACKGROUND`

## Persistence

Theme choice is persisted to `~/.local/state/dotfiles/theme` and restored on new shells.
Use `theme reset` to clear and revert to macOS system appearance detection.
