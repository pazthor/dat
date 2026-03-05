#!/usr/bin/env bash

dat::domain::source_precedence::ordered_sources() {
  printf "%s\n" "dotfiles" "dotly"
}

dat::domain::source_precedence::is_valid() {
  local -r source="${1:-}"
  [[ "$source" == "dotfiles" || "$source" == "dotly" ]]
}
