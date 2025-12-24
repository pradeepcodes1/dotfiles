# Yazi Keybindings Reference

Comprehensive keyboard shortcuts for Yazi file manager.

## Table of Contents
- [Navigation](#navigation)
- [File Operations](#file-operations)
- [Selection](#selection)
- [Tabs](#tabs)
- [Search & Filter](#search--filter)
- [Sorting](#sorting)
- [Visual Mode](#visual-mode)
- [Shell & Commands](#shell--commands)
- [Help & Quit](#help--quit)

---

## Navigation

### Basic Movement
| Key | Action |
|-----|--------|
| `j` / `↓` | Move cursor down |
| `k` / `↑` | Move cursor up |
| `h` / `←` | Go to parent directory |
| `l` / `→` / `Enter` | Enter directory or open file |

### Quick Movement
| Key | Action |
|-----|--------|
| `g` | Go to top of list |
| `G` | Go to bottom of list |
| `Ctrl-u` | Move up half a page |
| `Ctrl-d` | Move down half a page |
| `Ctrl-b` | Move up one full page |
| `Ctrl-f` | Move down one full page |

### Directory Navigation
| Key | Action |
|-----|--------|
| `~` | Go to home directory |
| `-` | Go to previous directory |
| `z` | Jump to directory using zoxide |

---

## File Operations

### Basic Operations
| Key | Action |
|-----|--------|
| `o` | Open file with default application |
| `O` | Open file interactively (choose application) |
| `e` | Edit file (using $EDITOR) |
| `Enter` | Open file or enter directory |

### File Management
| Key | Action |
|-----|--------|
| `y` | Yank (copy) selected files |
| `x` | Cut selected files |
| `p` | Paste files |
| `P` | Paste files (overwrite) |
| `d` | Delete selected files (move to trash) |
| `D` | Permanently delete files (bypass trash) |
| `a` | Create new file or directory |
| `r` | Rename file/directory |

### Advanced Operations
| Key | Action |
|-----|--------|
| `c` | Copy selected files to... |
| `m` | Move selected files to... |
| `.` | Toggle hidden files |
| `z` | Show file info |
| `Ctrl-s` | Symlink selected files |

---

## Selection

### Single Selection
| Key | Action |
|-----|--------|
| `Space` | Toggle selection of current file |
| `v` | Enter visual mode |
| `V` | Enter visual mode (unset existing selection) |

### Multiple Selection
| Key | Action |
|-----|--------|
| `Ctrl-a` | Select all files in current directory |
| `Ctrl-r` | Inverse selection |
| `Esc` | Cancel selection |

---

## Tabs

| Key | Action |
|-----|--------|
| `t` | Create new tab |
| `1-9` | Switch to tab 1-9 |
| `[` / `Shift-Tab` | Switch to previous tab |
| `]` / `Tab` | Switch to next tab |
| `{` | Move current tab left |
| `}` | Move current tab right |
| `w` | Close current tab |

---

## Search & Filter

### Search
| Key | Action |
|-----|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n` | Jump to next search result |
| `N` | Jump to previous search result |

### Filter
| Key | Action |
|-----|--------|
| `f` | Filter files (interactive) |
| `Ctrl-s` | Search files by content (ripgrep) |

---

## Sorting

| Key | Action |
|-----|--------|
| `s` | Sort files interactively |
| `S` | Reverse sort order |

**Sort Options:**
- By name (alphabetical)
- By modified time
- By created time
- By size
- By extension
- Natural (numbers sorted correctly)

---

## Visual Mode

Enter visual mode with `v` or `V`, then:

| Key | Action |
|-----|--------|
| `j` / `k` | Extend selection up/down |
| `y` | Yank (copy) selected files |
| `x` | Cut selected files |
| `d` | Delete selected files |
| `Esc` | Exit visual mode |

---

## Shell & Commands

| Key | Action |
|-----|--------|
| `:` | Execute shell command |
| `!` | Execute shell command (blocking) |
| `;` | Execute command for selected files |
| `Ctrl-z` | Suspend yazi (return with `fg`) |

### Common Shell Commands
- `:chmod +x` - Make file executable
- `:mkdir dirname` - Create directory
- `;nvim` - Edit all selected files

---

## Help & Quit

| Key | Action |
|-----|--------|
| `?` / `F1` | Show help |
| `q` | Quit current tab |
| `Q` | Quit all tabs and yazi |

---

## Tips & Tricks

### Quick Actions
1. **Bulk rename**: Select files (`Space`), press `r`, edit in editor
2. **Quick preview**: Files are previewed in right pane automatically
3. **Open in terminal**: `;` then enter shell command
4. **Copy path**: `y` then `p` in another app
5. **Multiple operations**: Select with `v`, then `y`/`x`/`d` for batch operations

### Integration with Shell
The `y()` wrapper function in your zsh config allows:
```bash
# Change directory on yazi exit
y        # Launch yazi, navigate, and cd to that directory on exit
```

### File Preview
Yazi automatically previews:
- Text files
- Images (with proper terminal support)
- PDFs (with ueberzug/kitty/iterm2)
- Archives
- Videos (thumbnails)

### Performance
- Use `/` search for quick file finding
- Use `f` filter to narrow down visible files
- Use `z` for quick directory jumping (zoxide integration)
- Use tabs (`t`) to keep multiple locations open

### Hidden Files
- Press `.` to toggle visibility of hidden files (dotfiles)
- Yazi respects `.gitignore` patterns in git repositories

---

## Configuration

Your yazi configuration is managed by:
- **Theme**: `~/.config/yazi/theme.toml` (managed by `theme.zsh`)
- **Flavors**: `~/.config/yazi/flavors/` (installable themes)

To change themes:
```bash
theme toggle          # Toggle between light/dark
theme set <name>      # Set specific theme
```

---

## Resources

- [Official Yazi Documentation](https://yazi-rs.github.io/)
- [Yazi GitHub](https://github.com/sxyazi/yazi)
- Your theme integration: `~/.config/zsh/theme.zsh`
