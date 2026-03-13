# Custom Keybindings

Reference for custom keyboard shortcuts configured in this dotfiles repo.

# Neovim

**Leader**: `Space`

# Navigation & Search

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
| `<leader>`\` | Search open buffers              |

# File Manager (Yazi)

| Key         | Action                    |
| ----------- | ------------------------- |
| `<leader>e` | Open yazi in cwd          |
| `<leader>-` | Open yazi at current file |
| `<C-Up>`    | Resume last yazi session  |

# LSP

| Key          | Action                |
| ------------ | --------------------- |
| `gd`         | Goto definition       |
| `gD`         | Goto declaration      |
| `gr`         | Goto references       |
| `K`          | Hover documentation   |
| `?`          | Open diagnostic float |
| `]d` / `[d`  | Next/prev diagnostic  |
| `<leader>rn` | Rename symbol         |
| `<leader>ca` | Code action           |
| `<leader>lc` | Close quickfix list   |
| `<leader>lh` | Toggle inlay hints    |
| `<leader>ud` | Toggle diagnostics    |

# Treesitter

| Key          | Action                         |
| ------------ | ------------------------------ |
| `<CR>`       | Start incremental selection    |
| `<Tab>`      | Expand selection to next node  |
| `<S-Tab>`    | Shrink selection to prev node  |
| `af` / `if`  | Select around/inside function  |
| `ac` / `ic`  | Select around/inside class     |
| `aa` / `ia`  | Select around/inside parameter |
| `]m` / `[m`  | Next/prev function start       |
| `]]` / `[[`  | Next/prev class start          |
| `]M` / `[M`  | Next/prev function end         |
| `]a` / `[a`  | Next/prev parameter            |
| `<leader>sp` | Swap parameter with next       |
| `<leader>sP` | Swap parameter with previous   |

# Buffer Management (BarBar)

| Key                 | Action                      |
| ------------------- | --------------------------- |
| `bk`                | Buffer pick (interactive)   |
| `<leader>q`         | Close current buffer        |
| `<leader>1-9`       | Goto buffer 1-9             |
| `<leader>0`         | Pin buffer                  |
| `<leader>!@#$%^&*(` | Move buffer to position 1-9 |

# Git (Diffview)

| Key          | Action             |
| ------------ | ------------------ |
| `<leader>gr` | Review all changes |
| `<leader>df` | Diff current file  |
| `<leader>gc` | Close diffview     |

# Splits

| Key               | Action           |
| ----------------- | ---------------- |
| `<leader>\|`      | Split vertical   |
| `<leader>\`       | Split horizontal |
| `<leader>x`       | Close split      |
| `<leader><Arrow>` | Navigate splits  |

# TODO Navigation

| Key  | Action                |
| ---- | --------------------- |
| `]t` | Next TODO comment     |
| `[t` | Previous TODO comment |

# Scrolling (Neoscroll)

| Key             | Action                  |
| --------------- | ----------------------- |
| `<C-u/d>`       | Smooth half-page scroll |
| `<C-b/f>`       | Smooth full-page scroll |
| `<ScrollWheel>` | Smooth mouse scroll     |

# Other Neovim

| Key                | Action                         |
| ------------------ | ------------------------------ |
| `<Alt-Left/Right>` | Word navigation in insert mode |
| `<leader>Q`        | Quit Neovim                    |
| `<leader>.`        | Toggle scratch buffer          |
| `<leader>S`        | Select scratch buffer          |
| `<leader>z`        | Zen mode                       |

---

# Tmux

**Prefix**: `Ctrl+l` (or Right Option via Karabiner)

# Windows

| Key   | Action                       |
| ----- | ---------------------------- |
| `c`   | New window (in current path) |
| `;`   | Previous window              |
| `'`   | Next window                  |
| `w`   | Popup window picker          |
| `1-9` | Select window 1-9            |

# Panes

| Key  | Action                               |
| ---- | ------------------------------------ |
| `h`  | Navigate pane left                   |
| `j`  | Navigate pane down                   |
| `l`  | Navigate pane right                  |
| `\|` | Split horizontal (40%, current path) |
| `-`  | Split vertical (40%, current path)   |
| `z`  | Zoom/unzoom pane                     |
| `x`  | Kill pane (with centered message)    |
| `+`  | Grow pane                            |
| `_`  | Shrink pane                          |

# Sessions

| Key   | Action                                    |
| ----- | ----------------------------------------- |
| `c`   | New session (Shift+ROpt+c)                |
| `1-9` | Switch to session 1-9 (Shift+ROpt+num)    |
| `x`   | Kill session (Shift+ROpt+x, with confirm) |
| `R`   | Rename session (preserves number prefix)  |
| `d`   | Detach                                    |
| `s`   | Choose session                            |

# Copy & Tools

| Key | Action                                   |
| --- | ---------------------------------------- |
| `[` | Copy mode                                |
| `/` | Copy mode with relative line numbers     |
| `y` | Copy command block by number from scroll |
| `k` | Show keybindings + tools popup           |
| `P` | Process explorer popup                   |
| `n` | Notification center (windows with bells) |
| `b` | Toggle status bar                        |
| `r` | Reload config                            |

---

# Aerospace (Window Manager)

# Focus & Move

| Key                 | Action                         |
| ------------------- | ------------------------------ |
| `Alt+h/j/k/l`       | Focus left/down/up/right       |
| `Alt+Shift+h/j/k/l` | Move window left/down/up/right |
| `Alt+.`             | Focus next window (DFS)        |
| `Alt+Shift+.`       | Focus prev window (DFS)        |

# Resize

| Key     | Action        |
| ------- | ------------- |
| `Alt+-` | Shrink window |
| `Alt+=` | Grow window   |

# Workspaces

| Key             | Action                             |
| --------------- | ---------------------------------- |
| `Alt+1-9`       | Switch to workspace 1-9            |
| `Alt+a-z`       | Switch to workspace A-Z (except t) |
| `Alt+Tab`       | Toggle last workspace              |
| `Alt+Shift+1-9` | Move window to workspace 1-9       |
| `Alt+Shift+a-z` | Move window to workspace A-Z       |
| `Alt+Shift+Tab` | Move workspace to next monitor     |

# Layouts

| Key     | Action                               |
| ------- | ------------------------------------ |
| `Alt+/` | Toggle tiles horizontal/vertical     |
| `Alt+,` | Toggle accordion horizontal/vertical |

# Service Mode (`Alt+Shift+;`)

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

# Ghostty

| Key         | Action                |
| ----------- | --------------------- |
| `Alt+Left`  | Move back one word    |
| `Alt+Right` | Move forward one word |
