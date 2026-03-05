#!/usr/bin/env bash

dat::adapter::prompt::select() {
  local -r options="${1:-}"

  if command -v fzf >/dev/null 2>&1; then
    printf "%s\n" "$options" | fzf --height 100%
    return "$?"
  fi

  local -a lines=()
  local line=""
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    lines+=("$line")
  done <<<"$options"

  [[ "${#lines[@]}" -gt 0 ]] || return 1

  local i=1
  for line in "${lines[@]}"; do
    printf "%s) %s\n" "$i" "$line"
    i=$((i + 1))
  done

  local selected_index=""
  read -r -p "Select installer number: " selected_index

  if [[ ! "$selected_index" =~ ^[0-9]+$ ]] || ((selected_index < 1 || selected_index > ${#lines[@]})); then
    return 1
  fi

  printf "%s\n" "${lines[$((selected_index - 1))]}"
}
