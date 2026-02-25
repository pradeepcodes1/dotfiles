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
config-edit  # Opens nix shell with dev tools in chezmoi source dir
config-apply # Shortcut: runs bootstrap.sh from anywhere
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

- **Entry point**: `dot_zshrc` sources modular configs from `~/.config/zsh/*.zsh` (lazy-loads `cp.zsh`, `backup.zsh`, `log-viewer.zsh` via stub functions)
- **Custom modules** in `dot_config/zsh/`:
  - `00-logging.zsh` - Centralized logging system (sourced first alphabetically)
  - `basics.zsh.tmpl` - Basic environment setup and eza aliases
  - `log-viewer.zsh` - Log viewing utilities (dotlog, dotlog-stats, dotlog-clean)
  - `navigation.zsh` - Smart directory navigation with zoxide integration
  - `plugins.zsh` - Zsh plugin configuration (fzf-tab, autosuggestions, syntax-highlighting, zoxide, atuin, carapace)
  - `theme.zsh.tmpl` - Theme management, sources modular `theme/` subdirectory
  - `tmux.zsh` - Auto-attaches tmux sessions per Aerospace workspace
  - `cp.zsh` - Competitive programming toolkit (`cpt` command)
  - `nix.zsh` - Nix flake environment switcher (`flake`, `flake-rm` commands)
  - `ssh.zsh` - SSH wrapper that shows hostname in tmux status bar
  - `backup.zsh` - Backup function using restic (`backup-system` command)
  - `config-edit.zsh.tmpl` - Config editing environment (`config-edit`, `config-apply` commands)
- **Theme system** in `dot_config/zsh/theme/`:
  - `init.zsh.tmpl` / `config.zsh.tmpl` / `core.zsh.tmpl` - Theme loading and core color definitions
  - `command.zsh.tmpl` - `theme` command for switching themes at runtime
  - `apps/` - Per-app theme integration (bat, claude, eza, fzf, ghostty, tmux, yazi, zsh-prompt)

#### 2. Tool Version Management (mise)

- **Config**: `dot_config/mise/config.toml`
- Manages runtime versions for: bun, go, java, node, protobuf, python, zig
- Activated in `.zshrc` via `eval "$(mise activate zsh)"`

#### 3. Package Management

- **Homebrew packages**: `dot_config/brew/packages.tmpl`
- **Install script**: `.chezmoiscripts/run_after_20-install-packages.sh.tmpl` runs `brew bundle`
- **Tools script**: `.chezmoiscripts/run_after_30-setup-tools.sh.tmpl` sets up uv, mise, yazi flavors

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
  - `core/logging.lua` - JSON logging to shared dotfiles log
  - `core/jdt.lua` - Java decompiled class buffer support (jdt:// URI handling)
- **LSP**: `lua/lsp/common.lua` (shared capabilities/on_attach) + `lua/plugins/masonlsp.lua`
- **Plugins** (each in `lua/plugins/`):
  - Layout: `edgy.lua` (panel orchestrator), `aerial.lua` (symbol outline), `dapui.lua` (debug UI), `neotest.lua` (test runner), `neck-pain.lua` (center editor)
  - UI: `barbar.lua` (tab bar, jdt:// support), `lualine.lua` (statusline), `noice.lua` (UI enhancements), `notify.lua` (notifications), `neoscroll.lua` (smooth scroll), `smear.lua` (cursor animation), `themes.lua` (theme loading)
  - Code: `conform.lua` (formatting), `copilot.lua` (GitHub Copilot), `avante.lua` (Claude AI), `nvim-treesitter.lua`, `todo-comments.lua`, `gitsigns.lua`
  - Tools: `yazi.lua` (file manager), `session.lua` (session management), `mason.lua` (LSP installer)
  - `init.lua` - Core plugins: snacks.nvim (dashboard, indent, zen mode), telescope, project.nvim, diffview, nvim-autopairs, Comment.nvim, nvim-java, nvim-cmp, venv-selector
- **View keybinds** (`<leader>v*`):
  - `<leader>vs` - Toggle symbol outline
  - `<leader>vd` - Toggle debug UI
  - `<leader>vt` - Toggle test summary
  - `<leader>vc` - Close all sidebars
- **Test keybinds** (`<leader>t*`):
  - `<leader>tt` - Run nearest test
  - `<leader>tf` - Run file tests
  - `<leader>td` - Debug nearest test (via DAP)
  - `<leader>to` / `<leader>tO` - Test output / output panel
  - `<leader>tS` - Stop test
- **Debug keybinds** (`<leader>d*`):
  - `<leader>db` - Toggle breakpoint
  - `<leader>dc` - Continue/start
  - `<leader>do` / `<leader>di` / `<leader>dO` - Step over/into/out
  - `<leader>dr` - Toggle REPL
  - `<leader>dl` - Run last
  - `<leader>dx` - Terminate session
  - `<leader>de` - Eval expression
- **Special features**:
  - Transparent background support
  - Auto-readonly for library files (node_modules, site-packages, etc.)
  - Workspace-aware session management
  - Custom diffview workflow (`<leader>gr`, `<leader>df`, `<leader>gc`)

#### 5. Tmux Configuration

- **Config**: `dot_config/tmux/tmux.conf.tmpl`
- **Prefix**: Changed to `C-l` (not default `C-b`)
- **Integration**: Auto-attaches to Aerospace workspace-named sessions (see `dot_config/zsh/tmux.zsh`)
- **Helper scripts** in `dot_config/tmux/`:
  - `executable_ghostty-exit-handler.sh` - Prevents session detach when last pane exits in Ghostty
  - `executable_session-cleaner.sh` - Cleans up empty sessions on session switch
  - `executable_relative-copy-mode.sh` - Copy mode with relative line numbers
- **Key bindings** (ROpt = Right Option via Karabiner):
  - Windows: `ROpt+c` new, `ROpt+;/'` prev/next, `ROpt+1-9` select, `ROpt+w` choose
  - Panes: `h/j/k/l` navigate, `|/-` split, `+/_` resize, `z` zoom, `x` kill
  - Sessions: `ROpt+d` detach, `ROpt+s` choose, `X` kill session
  - Copy: `ROpt+[` copy mode, `ROpt+/` copy mode with relative line numbers
  - Other: `r` reload config, `b` toggle status bar
- **Features**: renumber-windows on close, theme sourcing from `~/.config/tmux/themes/`, C-k passthrough for Ghostty

#### 6. Ghostty Configuration

- **Config**: `dot_config/ghostty/config`
- Font: JetBrainsMono NF, size 18
- Theme integration via `themes/current.conf` (managed by theme.zsh)
- Keybindings for word navigation (Alt+Left/Right)

#### 7. Karabiner Configuration

- **Config**: `dot_config/private_karabiner/private_karabiner.json` (encrypted)
- Maps Right Option + key combos to tmux prefix sequences
- Keybind to launch Ghostty terminal

#### 8. Secret Management

- Uses `pass` (password-store) for secrets
- Template files use `{{ pass "path/to/secret" }}` syntax
- Examples in `dot_env.tmpl` for API keys and AWS credentials

#### 9. Backup System

- **Shell function**: `backup-system` in `dot_config/zsh/backup.zsh` (lazy-loaded)
- Uses **restic** for backups
- Configured via `pass` for repository location and backup sources
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

Centralized JSON logging across shell, Go, and Neovim.

**Enable Logging:**

```bash
# Console output (colors)
export DEBUG_DOTFILES=1      # Enable debug/info
export DEBUG_DOTFILES=2      # Add timestamps

# JSON file logging (enabled by default in .zshrc)
# Logs to: ~/.local/state/dotfiles/logs/dotfiles.jsonl
```

**Shell Functions:**

```bash
debug_log "component" "message"   # DEBUG level
info_log "component" "message"    # INFO level
warn_log "component" "message"    # WARN (always shown)
error_log "component" "message"   # ERROR (always shown)
log_command "comp" "desc" cmd...  # Timed command execution
```

**Neovim (Lua):**

```lua
local log = require("core.logging")
log.debug("lsp", "Server starting")
log.info("theme", "Applied", { scheme = "kanagawa" })
log.warn("plugin", "Deprecated API")
log.error("treesitter", "Parse failed", { error = err })
log.timed("treesitter", "Parsing", function() ... end)
```

**Log Viewer (requires jq):**

```bash
dotlog              # Last 50 entries, colorized
dotlog -f           # Follow mode (tail)
dotlog -l ERROR     # Filter by level
dotlog -c theme     # Filter by component
dotlog -s nvim      # Filter by source (shell/nvim/go)
dotlog --today      # Today only
dotlog-stats        # Statistics
dotlog-search "pattern"  # Search logs
```

**JSON Schema:**

```json
{
  "ts": "2025-12-26T10:30:45.000Z",
  "level": "INFO",
  "component": "theme",
  "msg": "Applied",
  "source": "shell",
  "pid": 12345
}
```

**Config:** `~/.config/dotfiles/logging.conf`

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
