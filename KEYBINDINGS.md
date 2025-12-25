# Custom Keybindings

Reference for custom keyboard shortcuts configured in this dotfiles repo.

## Neovim

**Leader**: `Space`

### Navigation & Search

| Key          | Action                           |
| ------------ | -------------------------------- |
| `jk`         | Exit insert/visual mode          |
| `<Esc><Esc>` | Clear search highlighting        |
| `<leader>/`  | Fuzzy find in current buffer     |
| `<leader>ff` | Find files (compact, no preview) |
| `<leader>fg` | Live grep (search in files)      |
| `<leader>fs` | Find symbols in file             |
| `<leader>fw` | Find symbols in workspace        |
| `<leader>fr` | Recent files                     |
| `<leader>ft` | Find TODOs                       |
| `<leader>p`  | Projects picker                  |

### File Manager (Yazi)

| Key         | Action                    |
| ----------- | ------------------------- |
| `<leader>e` | Open yazi in cwd          |
| `<leader>-` | Open yazi at current file |
| `<C-Up>`    | Resume last yazi session  |

### LSP

| Key          | Action                |
| ------------ | --------------------- |
| `gd`         | Goto definition       |
| `?`          | Open diagnostic float |
| `<leader>lr` | Rename symbol         |
| `<leader>la` | Code action           |
| `<leader>lc` | Close quickfix list   |

### Buffer Management (BarBar)

| Key                 | Action                      |
| ------------------- | --------------------------- |
| `bk`                | Buffer pick (interactive)   |
| `<leader>q`         | Close current buffer        |
| `<leader>1-9`       | Goto buffer 1-9             |
| `<leader>0`         | Goto last buffer            |
| `<leader>!@#$%^&*(` | Move buffer to position 1-9 |

### Git (Diffview)

| Key          | Action                 |
| ------------ | ---------------------- |
| `<leader>gr` | Review all changes     |
| `<leader>gd` | Diff current file only |
| `<leader>gc` | Close diffview         |

### TODO Navigation

| Key  | Action                |
| ---- | --------------------- |
| `]t` | Next TODO comment     |
| `[t` | Previous TODO comment |

### Scrolling (Neoscroll)

| Key             | Action                  |
| --------------- | ----------------------- |
| `<C-u/d>`       | Smooth half-page scroll |
| `<C-b/f>`       | Smooth full-page scroll |
| `<ScrollWheel>` | Smooth mouse scroll     |

### Other

| Key                | Action                         |
| ------------------ | ------------------------------ |
| `<Alt-Left/Right>` | Word navigation in insert mode |
| `<leader>Q`        | Quit Neovim                    |

---

## Tmux

**Prefix**: `Ctrl+l` (or Right Option via Karabiner)

### Windows

| Key   | Action                       |
| ----- | ---------------------------- |
| `c`   | New window (in current path) |
| `;`   | Previous window              |
| `'`   | Next window                  |
| `w`   | Choose window                |
| `1-9` | Select window 1-9            |

### Panes

| Key       | Action                               |
| --------- | ------------------------------------ |
| `h/j/k/l` | Navigate panes (vim-style)           |
| `\|`      | Split horizontal (40%, current path) |
| `-`       | Split vertical (40%, current path)   |
| `z`       | Zoom/unzoom pane                     |
| `x`       | Kill pane                            |

### Sessions

| Key | Action                                     |
| --- | ------------------------------------------ |
| `d` | Detach                                     |
| `s` | Choose session                             |
| `X` | Kill session (confirm, then switch/create) |

### Other

| Key | Action                                    |
| --- | ----------------------------------------- |
| `[` | Copy mode                                 |
| `h` | FZF search scrollback + copy to clipboard |
| `b` | Toggle status bar                         |
| `r` | Reload config                             |

---

## Aerospace (Window Manager)

### Focus & Move

| Key                 | Action                         |
| ------------------- | ------------------------------ |
| `Alt+h/j/k/l`       | Focus left/down/up/right       |
| `Alt+Shift+h/j/k/l` | Move window left/down/up/right |

### Resize

| Key     | Action        |
| ------- | ------------- |
| `Alt+-` | Shrink window |
| `Alt+=` | Grow window   |

### Workspaces

| Key             | Action                             |
| --------------- | ---------------------------------- |
| `Alt+1-9`       | Switch to workspace 1-9            |
| `Alt+a-z`       | Switch to workspace A-Z (except t) |
| `Alt+Tab`       | Toggle last workspace              |
| `Alt+Shift+1-9` | Move window to workspace 1-9       |
| `Alt+Shift+a-z` | Move window to workspace A-Z       |
| `Alt+Shift+Tab` | Move workspace to next monitor     |

### Layouts

| Key     | Action                               |
| ------- | ------------------------------------ |
| `Alt+/` | Toggle tiles horizontal/vertical     |
| `Alt+,` | Toggle accordion horizontal/vertical |

### Service Mode (`Alt+Shift+;`)

| Key                 | Action                           |
| ------------------- | -------------------------------- |
| `Esc`               | Reload config, exit              |
| `r`                 | Reset layout (flatten)           |
| `f`                 | Toggle floating/tiling           |
| `Backspace`         | Close all windows except current |
| `Alt+Shift+h/j/k/l` | Join with adjacent window        |
| `Up/Down`           | Volume up/down                   |
| `Shift+Down`        | Mute                             |

---

## Ghostty

| Key         | Action                |
| ----------- | --------------------- |
| `Alt+Left`  | Move back one word    |
| `Alt+Right` | Move forward one word |
