#!/usr/bin/env bash

dat::application::run_installer() {
  local -r installer_name="${1:-}"
  local -r source_override="${2:-all}"
  shift 2 || true

  local resolved_path=""
  resolved_path="$(dat::application::resolve_installer "$installer_name" "$source_override")" || return "$?"

  dat::adapter::executor::run "$resolved_path" "$@" || return "$DAT_EXIT_EXEC_FAILED"
}
