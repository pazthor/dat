#!/usr/bin/env bash

dat::adapter::catalog::dotfiles_root() {
  local -r dotfiles_default="$HOME/.dotfiles"
  printf "%s" "${DOTFILES_PATH:-$dotfiles_default}"
}

dat::adapter::catalog::dotly_root() {
  local -r dotfiles_root="$(dat::adapter::catalog::dotfiles_root)"
  local -r dotly_default="$dotfiles_root/modules/dotly"
  printf "%s" "${DOTLY_PATH:-$dotly_default}"
}

dat::adapter::catalog::source_dir() {
  local -r source="$1"

  case "$source" in
  dotfiles) printf "%s/scripts/install" "$(dat::adapter::catalog::dotfiles_root)" ;;
  dotly) printf "%s/scripts/install" "$(dat::adapter::catalog::dotly_root)" ;;
  *) return 1 ;;
  esac
}

dat::adapter::catalog::list_paths() {
  local -r source="${1:-all}"
  local dirs=()

  if [[ "$source" == "all" ]]; then
    dirs+=("$(dat::adapter::catalog::source_dir dotfiles)")
    dirs+=("$(dat::adapter::catalog::source_dir dotly)")
  else
    dirs+=("$(dat::adapter::catalog::source_dir "$source")")
  fi

  local dir=""
  local file=""

  shopt -s nullglob
  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || continue

    for file in "$dir"/*; do
      [[ -f "$file" ]] || continue
      printf "%s\n" "$file"
    done
  done
  shopt -u nullglob
}
