#!/usr/bin/env bash

dat::adapter::prompt::gum::select() {
  local -r options="${1:-}"

  if ! command -v gum > /dev/null 2>&1; then
    return "$DAT_EXIT_ADAPTER_MISSING"
  fi

  printf "%s\n" "$options" | gum choose --header="Select installer"
}
