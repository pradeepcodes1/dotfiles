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
# IMPORTANT: Always use bootstrap.sh to apply changes (runs chezmoi apply in nix shell)
./bootstrap.sh

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
  - `tmux.zsh` - Auto-attaches tmux sessions per Aerospace workspace
  - `cp.zsh` - Competitive programming toolkit (`cpt` command)
  - `basics.zsh.tmpl` - Basic environment setup
  - `music.zsh` - Music player shortcuts
  - `plugins.zsh` - Zsh plugin configuration

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
- Terminal (Alacritty) auto-attaches to workspace-specific tmux session on launch
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
