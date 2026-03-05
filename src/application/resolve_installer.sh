#!/usr/bin/env bash

dat::application::resolve_installer() {
  local -r installer_name="${1:-}"
  local -r source_override="${2:-all}"

  dat::domain::installer_name::is_valid "$installer_name" || return "$DAT_EXIT_NOT_FOUND"

  local -a sources=()
  if [[ "$source_override" == "all" ]]; then
    while IFS= read -r src; do
      sources+=("$src")
    done < <(dat::domain::source_precedence::ordered_sources)
  else
    dat::domain::source_precedence::is_valid "$source_override" || return "$DAT_EXIT_NOT_FOUND"
    sources+=("$source_override")
  fi

  local source=""
  local dir=""
  local candidate=""
  for source in "${sources[@]}"; do
    dir="$(dat::adapter::catalog::source_dir "$source")"
    candidate="$dir/$installer_name"

    [[ -e "$candidate" ]] || continue

    if [[ ! -x "$candidate" ]]; then
      return "$DAT_EXIT_NOT_EXECUTABLE"
    fi

    case "$candidate" in
    "$dir"/*)
      printf "%s\n" "$candidate"
      return "$DAT_EXIT_OK"
      ;;
    *)
      return "$DAT_EXIT_NOT_FOUND"
      ;;
    esac
  done

  return "$DAT_EXIT_NOT_FOUND"
}
