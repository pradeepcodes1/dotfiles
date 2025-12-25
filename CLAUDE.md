# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **chezmoi** dotfiles repository for managing personal development environment configurations across macOS systems. Chezmoi uses a source-state directory (`~/.local/share/chezmoi`) to manage dotfiles in their home directory, supporting templating, encryption, and machine-specific configurations.

## Essential Commands

### Chezmoi Operations
```bash
# Apply dotfiles to the system
chezmoi apply

# See what would change without applying
chezmoi diff

# Edit a file in the source directory
chezmoi edit ~/.zshrc

# Add a new file to be managed
chezmoi add ~/.config/some-tool/config

# Update dotfiles from source directory
chezmoi apply --verbose

# Re-run scripts (useful after modifying .chezmoiscripts)
chezmoi apply --force

# Check what chezmoi would do
chezmoi status
```

### Development Workflow
```bash
# CRITICAL WORKFLOW: When modifying dotfiles, ALWAYS follow this sequence:
# 1. Edit files in the source directory (dot_*, etc.)
# 2. Add changed files to git FIRST
# 3. Then run bootstrap.sh to apply
git add <changed-files>
./bootstrap.sh

# NEVER run `chezmoi apply --force` directly - always add to git first
# This prevents merge conflicts and ensures proper state management

# View what would change without applying:
chezmoi diff

# View rendered template before applying:
chezmoi execute-template < dot_config/brew/packages.tmpl

# Edit config using the config-edit shell function:
config-edit  # Opens nix shell, then run ./bootstrap.sh to apply
```

## Architecture & Structure

### File Naming Convention
Chezmoi uses special prefixes to determine how files are processed:
- `dot_` → becomes `.` (e.g., `dot_zshrc` → `~/.zshrc`)
- `.tmpl` suffix → processed as Go template
- `executable_` → file is made executable
- `run_after_` → script runs after applying dotfiles

### Key Configuration Systems

#### 1. Shell Configuration (Zsh)
- **Entry point**: `dot_zshrc` sources modular configs from `~/.config/zsh/*.zsh`
- **Custom modules** in `dot_config/zsh/`:
  - `00-logging.zsh` - Centralized logging system (sourced first alphabetically)
  - `basics.zsh.tmpl` - Basic environment setup and eza aliases
  - `navigation.zsh` - Smart directory navigation with zoxide integration
  - `plugins.zsh` - Zsh plugin configuration (autosuggestions, zoxide)
  - `theme.zsh` - Theme management system
  - `tmux.zsh` - Auto-attaches tmux sessions per Aerospace workspace
  - `cp.zsh` - Competitive programming toolkit (`cpt` command)
  - `music.zsh` - Music player shortcuts

#### 2. Tool Version Management (mise)
- **Config**: `dot_config/mise/config.toml`
- Manages runtime versions for: bun, go, java, node, protobuf, python, zig
- Activated in `.zshrc` via `eval "$(mise activate zsh)"`

#### 3. Package Management
- **Homebrew packages**: `dot_config/brew/packages.tmpl`
- **Install script**: `.chezmoiscripts/run_after_a-packages.sh.tmpl` installs Homebrew
- **Tracking script**: `.chezmoiscripts/run_after_b-brew.sh.tmpl` warns about untracked packages
- Ignores tracking for: `chezmoi`, `gcc`, `mise` (managed separately)

#### 4. Neovim Configuration
- **Structure**: Modular Lua configuration using lazy.nvim
- **Entry**: `dot_config/nvim/init.lua`
  - Loads `core/` modules (options, keymaps, cmp, notes)
  - Auto-bootstraps lazy.nvim plugin manager
  - Loads all plugins from `lua/plugins/`
- **Core modules**:
  - `core/keymaps.lua` - Keybindings (space leader, telescope, LSP)
  - `core/options.lua` - Editor options
  - `core/cmp.lua` - Autocompletion setup
  - `core/notes.lua` - Note-taking setup
- **LSP**: Configured via `lua/lsp/` and `lua/plugins/masonlsp.lua`
- **Special features**:
  - Transparent background support
  - Auto-readonly for library files (node_modules, site-packages, etc.)
  - Workspace-aware session management
  - Custom diffview workflow (`<leader>gr`, `<leader>gd`, `<leader>gc`)

#### 5. Tmux Configuration
- **Config**: `dot_config/tmux/tmux.conf.tmpl`
- **Prefix**: Changed to `C-l` (not default `C-b`)
- **Scripts**:
  - `tmux-fzf-search.sh` - FZF-based scrollback search
  - `tmux-spinner.sh` - Status bar spinner
- **Integration**: Auto-attaches to Aerospace workspace-named sessions (see `dot_config/zsh/tmux.zsh`)

#### 6. Secret Management
- Uses `pass` (password-store) for secrets
- Template files use `{{ pass "path/to/secret" }}` syntax
- Examples in `dot_env.tmpl` for API keys and AWS credentials

#### 7. Backup System
- **Script**: `.chezmoiscripts/run_after_d-backup.sh.tmpl`
- Uses **restic** for backups
- Configured via `pass` for repository location
- Auto-initializes repository if needed
- Retention policy: 7 daily, 4 weekly, 6 monthly

### Workspace Management
This setup uses **Aerospace** (tiling window manager) with tight tmux integration:
- Each Aerospace workspace gets a corresponding tmux session
- Terminal (Ghostty) auto-attaches to workspace-specific tmux session on launch
- Prevents session name conflicts and enables workspace-isolated terminal sessions

## Important Patterns

### When Adding New Dotfiles
1. Add file to chezmoi: `chezmoi add ~/.config/tool/config`
2. Edit in source: `chezmoi edit ~/.config/tool/config`
3. Apply changes: `./bootstrap.sh` (from the chezmoi source directory)

### When Adding Secrets
Use `pass` and template syntax instead of hardcoding:
```
{{ pass "category/secret-name" }}
```

### When Adding Homebrew Packages
Add to `dot_config/brew/packages.tmpl` to track installations

### When Adding Language Runtimes
Add to `dot_config/mise/config.toml` instead of using version managers like nvm, rbenv, etc.

### Navigation Helpers (navigation.zsh)
The `navigation.zsh` module provides smart directory navigation with zoxide integration:

**Smart cd wrapper:**
- `cd <path>` - Enhanced cd that automatically tracks directories in zoxide
- `cd <fuzzy>` - If path doesn't exist, tries fuzzy matching via zoxide

**Interactive navigation:**
- `zi [query]` - Interactive directory picker with fzf (or fuzzy search with query)
- `zz` - Alias for `zi` (quick access)

**Directory utilities:**
- `mkcd <path>` - Create directory and cd into it
- `cdf <file>` - cd to the directory containing a file
- `up [N]` - Go up N directories (default: 1)
- `bd <dirname>` - Go back to a specific parent directory by name
- `fcd [start]` - Browse and cd using fzf from starting directory
- `cdls <dir>` - cd and ls in one command

**Zoxide shortcuts:**
- `zstats` - Show zoxide statistics (most used directories)

All cd operations are automatically tracked in zoxide for intelligent fuzzy matching.

### Debugging & Logging
The repository includes a centralized logging system for all scripts:

**Console Logging:**
```bash
# Enable debug logging
export DEBUG_DOTFILES=1

# Enable verbose debug logging with timestamps
export DEBUG_DOTFILES=2

# Run commands to see debug output
theme toggle
```

**File Logging:**
```bash
# Log to file in addition to console
export DOTFILES_LOG_FILE="$HOME/.local/state/dotfiles/debug.log"

# Combine with debug mode
export DEBUG_DOTFILES=1
export DOTFILES_LOG_FILE="$HOME/.local/state/dotfiles/debug.log"
theme toggle

# View the log file
tail -f ~/.local/state/dotfiles/debug.log

# Note: Logs are automatically rotated when they exceed 10MB
# Old logs are saved as debug.log.old
```

**In Scripts:**
```bash
# Available logging functions (automatically loaded from 00-logging.zsh)
debug_log "component" "Debug message"     # Only shows if DEBUG_DOTFILES >= 1
info_log "component" "Info message"       # Only shows if DEBUG_DOTFILES >= 1
warn_log "component" "Warning message"    # Always shows
error_log "component" "Error message"     # Always shows

# Log command execution with timing
log_command "component" "description" command args...
```

**Log Levels:**
- **DEBUG** 🔍 (cyan) - Detailed execution flow, only when `DEBUG_DOTFILES >= 1`
- **INFO** ℹ️ (green) - Informational messages, only when `DEBUG_DOTFILES >= 1`
- **WARN** ⚠️ (yellow) - Warnings, always shown
- **ERROR** ❌ (red) - Errors, always shown

**File Format:**
Console logs use colors and emojis. File logs are plain text with full timestamps:
```
[2025-12-24 14:40:32] [DEBUG] [theme] Loading colors: 'kanagawa-dragon'
[2025-12-24 14:40:33] [INFO] [theme] Theme applied successfully
[2025-12-24 14:40:34] [WARN] [theme] Yazi flavor not installed
[2025-12-24 14:40:35] [ERROR] [theme] Failed to write config file
```

**Components using logging:**
- `theme.zsh` - Theme switching and application
- Add logging to your custom scripts for better debugging

### Nvim Plugin Management
- Add new plugins in `dot_config/nvim/lua/plugins/`
- Each plugin gets its own file
- Lazy.nvim auto-loads all files in the plugins/ directory
- Plugin configs use lazy.nvim spec format

### Missing Tools
If a script requires a tool that is missing, use `nix` to install it temporarily or permanently.
Example: `nix shell nixpkgs#toolname` or add to `dot_config/mise/config.toml`.

## Conditional Logic in Templates

Templates can use chezmoi template variables:
```
{{ if eq .chezmoi.os "darwin" }}
# macOS specific
{{ end }}
```

Common variables: `.chezmoi.os`, `.chezmoi.hostname`, `.chezmoi.username`
