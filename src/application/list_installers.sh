#!/usr/bin/env bash

dat::application::list_installers() {
  local -r source="${1:-all}"
  local path=""
  local name=""
  local -a names=()

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    name="$(basename "$path")"

    dat::domain::installer_name::is_valid "$name" || continue
    [[ -x "$path" ]] || continue

    names+=("$name")
  done < <(dat::adapter::catalog::list_paths "$source")

  if [[ "${#names[@]}" -eq 0 ]]; then
    return 0
  fi

  printf "%s\n" "${names[@]}" | awk '!seen[$0]++' | sort
}
