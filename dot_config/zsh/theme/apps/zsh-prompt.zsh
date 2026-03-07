# Zsh prompt — centered active prompt with transient collapse
#
# Active:    [padding] ~/path (branch) ❯ _
# Executed:  ~/path
#            > cmd
#            (output)
#            · 3s
# Cancelled: > cmd ✗

zstyle ':vcs_info:git:*' unstagedstr "%F{$prompt_unstaged}*%f"
zstyle ':vcs_info:git:*' stagedstr "%F{$prompt_staged}+%f"
zstyle ':vcs_info:git:*' formats " %F{$prompt_branch}(%b%u%c)%f"
zstyle ':vcs_info:git:*' actionformats " %F{$prompt_branch}(%b|%a%u%c)%f"

# Theme colors (captured at source time)
_prompt_muted="$prompt_path"
_prompt_dir_color="$prompt_dir"
_prompt_arrow_color="$prompt_arrow"

# Prompt content
_prompt_current=" "

# State
_PROMPT_CMD_RAN=0
_PROMPT_CMD_START=0
_PROMPT_CLEAR_PENDING=0
_prompt_cmd_num=0

# --- Helpers ---

_prompt_set_active() {
  _prompt_current="%F{$_prompt_dir_color}%~%f${vcs_info_msg_0_} %F{$_prompt_arrow_color}❯%f "
}

# --- Hooks ---

# accept-line: collapse empty input to blank line
_prompt_accept_line() {
  if [[ -z "$BUFFER" ]]; then
    _prompt_current=" "
    zle .reset-prompt
  fi
  zle .accept-line
}
zle -N accept-line _prompt_accept_line

# preexec: print path, then collapse prompt to "> cmd"
_prompt_preexec() {
  local escaped_cmd="${1//\%/%%}"
  (( _prompt_cmd_num++ ))
  print -n '\e[1A\e[G\e[J'
  print -P "\n%F{$_prompt_muted}${_prompt_cmd_num} %~%f"
  print -P "%F{$_prompt_muted}>%f ${escaped_cmd}"

  _PROMPT_CMD_START=$SECONDS
  _PROMPT_CMD_RAN=1
  [[ "$1" == "clear" && -n "$TMUX" ]] && _PROMPT_CLEAR_PENDING=1
}

# precmd: print exec time after output, then set active prompt
_prompt_precmd() {
  if (( _PROMPT_CLEAR_PENDING )); then
    _PROMPT_CLEAR_PENDING=0
    command tmux clear-history
    _PROMPT_CMD_RAN=0
    _prompt_cmd_num=0
    _prompt_set_active
    return
  fi
  if (( _PROMPT_CMD_RAN )); then
    local elapsed=$(( SECONDS - _PROMPT_CMD_START ))
    _PROMPT_CMD_RAN=0
    local time_str="${elapsed}s"
    (( elapsed >= 60 )) && time_str="$(( elapsed / 60 ))m $(( elapsed % 60 ))s"
    print -P "%F{$_prompt_muted}⏱ ${time_str}%f\n"
  fi
  _prompt_set_active
}

# Register hooks (dedup for theme reload safety)
precmd_functions=(${precmd_functions:#_prompt_precmd})
precmd_functions+=(_prompt_precmd)
preexec_functions=(${preexec_functions:#_prompt_preexec})
preexec_functions+=(_prompt_preexec)

# --- Terminal handling ---

TRAPINT() {
  if zle; then
    local buf="${BUFFER//\%/%%}"
    print -n '\e[G\e[2K'
    print -P "%F{$_prompt_muted}>%f ${buf} %F{red}✗%f"
    _prompt_current=" "
    zle .reset-prompt
  fi
  return $(( 128 + $1 ))
}

TRAPWINCH() {
  if [[ -o zle ]]; then
    _prompt_set_active
    zle .reset-prompt
  fi
}

_prompt_clear_screen() {
  zle .clear-screen
  [[ -n "$TMUX" ]] && command tmux clear-history
}
zle -N clear-screen _prompt_clear_screen

# --- PROMPT ---
PROMPT='${_prompt_current}'
RPROMPT=''
