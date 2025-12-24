# Keybinding Cheatsheet

Comprehensive reference for all keyboard shortcuts across Neovim, Tmux, and Aerospace.

## Table of Contents
- [Neovim](#neovim)
  - [General](#general)
  - [Leader Key](#leader-key)
  - [Telescope (Fuzzy Finder)](#telescope-fuzzy-finder)
  - [LSP (Language Server)](#lsp-language-server)
  - [Buffer Management (BarBar)](#buffer-management-barbar)
  - [Git (Diffview)](#git-diffview)
- [Tmux](#tmux)
  - [Prefix Key](#prefix-key)
  - [Window Management](#window-management)
  - [Pane Management](#pane-management)
  - [Session Management](#session-management)
  - [Copy Mode](#copy-mode)
- [Aerospace (Window Manager)](#aerospace-window-manager)
  - [Focus Windows](#focus-windows)
  - [Move Windows](#move-windows)
  - [Workspaces](#workspaces)
  - [Layouts](#layouts)
  - [Service Mode](#service-mode)

---

## Neovim

### General
| Key | Action | Mode |
|-----|--------|------|
| `jk` | Exit insert/visual mode | Insert/Visual |
| `Esc` `Esc` | Clear search highlighting | Normal |
| `Alt+Left` | Move back one word | Insert |
| `Alt+Right` | Move forward one word | Insert |
| `?` | Open diagnostic float | Normal |

### Leader Key
**Leader**: `Space`

### Telescope (Fuzzy Finder)
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer (NvimTree) |
| `<leader>ff` | Find files (no preview, compact) |
| `<leader>fg` | Live grep (search in files) |
| `<leader>/` | Smart buffer search (fuzzy find in current file) |
| `<leader>fs` | Find symbols in current file |
| `<leader>fw` | Find symbols in workspace |
| `<leader>fr` | Recent files (oldfiles) |
| `<leader>p` | Projects picker |

### LSP (Language Server)
| Key | Action |
|-----|--------|
| `gd` | Goto definition |
| `<leader>lr` | Rename symbol |
| `<leader>la` | Code action |
| `<leader>lc` | Clear quickfix list |

### Buffer Management (BarBar)
| Key | Action |
|-----|--------|
| `bk` | Buffer pick (interactive) |
| `<leader>q` | Close current buffer |
| `<leader>1-9` | Goto buffer 1-9 |
| `<leader>0` | Goto last buffer |
| `<leader>!@#$%^&*(` | Move buffer to position 1-9 |

### Git (Diffview)
| Key | Action |
|-----|--------|
| `<leader>gr` | Review all changes (DiffviewOpen) |
| `<leader>gd` | Diff current file only |
| `<leader>gc` | Close diffview |

### System
| Key | Action |
|-----|--------|
| `<leader>Q` | Quit Neovim (`:qa`) |

---

## Tmux

### Prefix Key
**Prefix**: `Ctrl+l` (traditional) or **Right Option + key** (via Karabiner)

All bindings below use Right Option (ROpt) directly without prefix.

### Window Management
| Key | Action |
|-----|--------|
| `ROpt+c` | New window (in current path) |
| `ROpt+;` | Previous window |
| `ROpt+'` | Next window |
| `ROpt+w` | Choose window (interactive) |
| `ROpt+1-9` | Select window 1-9 |
| `ROpt+X` | Kill current session (confirm, then switch/create) |

### Pane Management
| Key | Action |
|-----|--------|
| `ROpt+h` | Select left pane |
| `ROpt+j` | Select pane below |
| `ROpt+k` | Select pane above |
| `ROpt+l` | Select right pane |
| `ROpt+\|` | Split horizontally (40% width, current path) |
| `ROpt+-` | Split vertically (40% height, current path) |
| `ROpt+z` | Zoom/unzoom pane |
| `ROpt+x` | Kill pane |
| `ROpt+r` | Reload tmux config |

### Session Management
| Key | Action |
|-----|--------|
| `ROpt+d` | Detach from session |
| `ROpt+s` | Choose session (interactive) |

### Copy Mode
| Key | Action |
|-----|--------|
| `ROpt+[` | Enter copy mode |
| `ROpt+h` | FZF search scrollback + copy to clipboard |
| `ROpt+b` | Toggle status bar |

### Mouse
- **Enabled**: Scrolling, pane selection, window selection
- **Copy mode**: Mouse drag selects without auto-scrolling to output

---

## Aerospace (Window Manager)

### Focus Windows
| Key | Action |
|-----|--------|
| `Alt+h` | Focus left |
| `Alt+j` | Focus down |
| `Alt+k` | Focus up |
| `Alt+l` | Focus right |

### Move Windows
| Key | Action |
|-----|--------|
| `Alt+Shift+h` | Move window left |
| `Alt+Shift+j` | Move window down |
| `Alt+Shift+k` | Move window up |
| `Alt+Shift+l` | Move window right |

### Resize Windows
| Key | Action |
|-----|--------|
| `Alt+-` | Shrink window (smart -50) |
| `Alt+=` | Grow window (smart +50) |

### Workspaces
| Key | Action |
|-----|--------|
| `Alt+1-9` | Switch to workspace 1-9 |
| `Alt+a-z` | Switch to workspace A-Z (excluding t) |
| `Alt+Tab` | Workspace back-and-forth (toggle last) |
| `Alt+Shift+1-9` | Move window to workspace 1-9 |
| `Alt+Shift+a-z` | Move window to workspace A-Z |
| `Alt+Shift+Tab` | Move workspace to next monitor |

### Layouts
| Key | Action |
|-----|--------|
| `Alt+/` | Toggle tiles horizontal/vertical |
| `Alt+,` | Toggle accordion horizontal/vertical |

### Service Mode
Enter service mode with `Alt+Shift+;`, then:

| Key | Action |
|-----|--------|
| `Esc` | Reload config and exit service mode |
| `r` | Reset layout (flatten workspace tree) |
| `f` | Toggle floating/tiling layout |
| `Backspace` | Close all windows except current |
| `Alt+Shift+h/j/k/l` | Join with left/down/up/right |
| `Up` | Volume up |
| `Down` | Volume down |
| `Shift+Down` | Mute (volume set 0) |

---

## Tips & Tricks

### Neovim
- The leader key (`Space`) is your primary navigation hub
- Use `<leader>ff` for quick file finding without previews
- Use `<leader>/` instead of `/` for fuzzy searching in current buffer
- Buffer navigation with numbers (`<leader>1-9`) is faster than cycling

### Tmux
- Right Option keybindings eliminate the need for prefix in most cases
- Use `ROpt+h` for FZF scrollback search - extremely powerful for finding past output
- Pane splits (`|` and `-`) automatically open in current directory
- Session management integrates with Aerospace workspaces

### Aerospace
- Each workspace automatically gets a corresponding tmux session
- Use `Alt+Tab` to quickly toggle between last two workspaces
- Service mode (`Alt+Shift+;`) provides advanced window management
- Workspaces A-Z allow for named organizational schemes (e.g., C for Code, M for Music)

### Integration Patterns
1. **Workspace-based workflow**: Use Aerospace workspaces (1-9, A-Z) for different projects
2. **Tmux sessions**: Auto-created per Aerospace workspace for terminal isolation
3. **Neovim projects**: Use `<leader>p` to quickly switch between project directories
4. **Git workflow**: Use `<leader>gr` for review, `<leader>gd` for focused file diffs
