#!/bin/bash
# Flat window picker using display-menu — press number to jump directly
current=$(tmux display-message -p '#{session_name}:#{window_index}')
args=(-T "Windows")
i=1
while IFS=$'\t' read -r target name cmd; do
  if [ $i -le 9 ]; then
    shortcut="$i"
  else
    shortcut=""
  fi
  # Show pane title if it's not a default/hostname
  win_label=""
  title=$(tmux display-message -t "$target" -p '#{pane_title}')
  case "$title" in
    zsh | bash | fish | "" | *.[Ll]ocal | *-[Mm]ac[Bb]ook*) ;;
    *) win_label=" $title" ;;
  esac
  if [ "$target" = "$current" ]; then
    label="${shortcut}  ${target}${win_label} *"
  else
    label="${shortcut}  ${target}${win_label}"
  fi
  args+=("$label" "$shortcut" "switch-client -t '${target}'")
  i=$((i + 1))
done < <(tmux list-windows -a -F "#{session_name}:#{window_index}	#{window_name}	#{pane_current_command}")

tmux display-menu "${args[@]}"
