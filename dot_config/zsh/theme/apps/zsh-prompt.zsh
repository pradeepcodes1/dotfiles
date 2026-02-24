# Zsh prompt — centered active prompt with transient collapse
#
# Active:    [padding] ~/path (branch) ❯ _
# Collapsed: > cmd                  ~/path
# Separator: ──────────────────────── Xs

zstyle ':vcs_info:git:*' unstagedstr "%F{$prompt_unstaged}*%f"
zstyle ':vcs_info:git:*' stagedstr "%F{$prompt_staged}+%f"
zstyle ':vcs_info:git:*' formats " %F{$prompt_branch}(%b%u%c)%f"
zstyle ':vcs_info:git:*' actionformats " %F{$prompt_branch}(%b|%a%u%c)%f"

# Theme colors (captured at source time)
_prompt_muted="$prompt_path"
_prompt_dir_color="$prompt_dir"
_prompt_arrow_color="$prompt_arrow"

# Prompt content variables (swapped between active/collapsed)
_prompt_current=" "
_rprompt_current=""

# State
_PROMPT_CMD_RAN=0
_PROMPT_CMD_START=0
_PROMPT_CLEAR_PENDING=0

# --- Helpers ---

# Recalculate centering padding for current terminal width
_prompt_calc_pad() {
  local w=$(( COLUMNS * 60 / 100 ))
  (( w < 40 )) && w=40
  (( w > 80 )) && w=80
  _prompt_pad=$(( (COLUMNS - w) / 3 ))
  (( _prompt_pad < 0 )) && _prompt_pad=0
  _prompt_sp=""
  (( _prompt_pad > 0 )) && _prompt_sp="$(printf '%*s' "$_prompt_pad" '')"
}

# Set prompt content to centered active form
_prompt_set_active() {
  _prompt_current="${_prompt_sp}%F{$_prompt_dir_color}%~%f${vcs_info_msg_0_} %F{$_prompt_arrow_color}❯%f "
  _rprompt_current=""
}

# --- Hooks ---

# accept-line: collapse empty input to blank line
_prompt_accept_line() {
  if [[ -z "$BUFFER" ]]; then
    _prompt_current=" "
    _rprompt_current=""
    zle .reset-prompt
  fi
  zle .accept-line
}
zle -N accept-line _prompt_accept_line

# preexec: collapse centered prompt to "> cmd ~/path" via escape sequences
_prompt_preexec() {
  local escaped_cmd="${1//\%/%%}"
  local path_text
  path_text="$(print -P '%~')"
  local left="> $1"
  local gap=$(( COLUMNS - ${#left} - ${#path_text} ))
  (( gap < 2 )) && gap=2
  local spaces="$(printf '%*s' "$gap" '')"
  print -n '\e[1A\e[G\e[2K'
  print -P "%F{$_prompt_muted}>%f ${escaped_cmd}${spaces}%F{$_prompt_muted}${path_text}%f"

  _PROMPT_CMD_START=$SECONDS
  _PROMPT_CMD_RAN=1
  [[ "$1" == "clear" && -n "$TMUX" ]] && _PROMPT_CLEAR_PENDING=1
}

# precmd: draw separator line with exec time, then set active prompt
_prompt_precmd() {
  if (( _PROMPT_CLEAR_PENDING )); then
    _PROMPT_CLEAR_PENDING=0
    command tmux clear-history
    _PROMPT_CMD_RAN=0
    _prompt_calc_pad
    _prompt_set_active
    return
  fi
  if (( _PROMPT_CMD_RAN )); then
    local elapsed=$(( SECONDS - _PROMPT_CMD_START ))
    _PROMPT_CMD_RAN=0
    local time_str="${elapsed}s"
    (( elapsed >= 60 )) && time_str="$(( elapsed / 60 ))m $(( elapsed % 60 ))s"
    local time_display=" ${time_str} "
    local line_len=$(( COLUMNS - ${#time_display} ))
    local line="$(printf '%*s' "$line_len" '' | tr ' ' '─')"
    print -P "%F{$_prompt_muted}${line} ${time_str} %f"
  fi
  _prompt_calc_pad
  _prompt_set_active
}

# Register hooks (dedup for theme reload safety)
precmd_functions=(${precmd_functions:#_prompt_precmd})
precmd_functions+=(_prompt_precmd)
preexec_functions=(${preexec_functions:#_prompt_preexec})
preexec_functions+=(_prompt_preexec)

# --- Terminal handling ---

TRAPWINCH() {
  _prompt_calc_pad
  _prompt_set_active
  [[ -o zle ]] && zle reset-prompt 2>/dev/null
}

_prompt_clear_screen() {
  zle .clear-screen
  [[ -n "$TMUX" ]] && command tmux clear-history
}
zle -N clear-screen _prompt_clear_screen

# --- PROMPT ---
PROMPT='${_prompt_current}'
RPROMPT='${_rprompt_current}'
