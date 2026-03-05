#!/usr/bin/env bash

DAT_CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAT_SRC_ROOT="$(cd "$DAT_CLI_DIR/../.." && pwd)"

source "$DAT_SRC_ROOT/domain/exit_codes.sh"
source "$DAT_SRC_ROOT/domain/installer_name.sh"
source "$DAT_SRC_ROOT/domain/source_precedence.sh"

source "$DAT_SRC_ROOT/adapters/catalog/filesystem_catalog.sh"
source "$DAT_SRC_ROOT/adapters/executor/shell_executor.sh"
source "$DAT_SRC_ROOT/adapters/output/stdout_output.sh"
source "$DAT_SRC_ROOT/adapters/prompt/fzf_prompt.sh"

source "$DAT_SRC_ROOT/application/list_installers.sh"
source "$DAT_SRC_ROOT/application/resolve_installer.sh"
source "$DAT_SRC_ROOT/application/run_installer.sh"

dat::cli::usage() {
  cat <<'EOF'
Usage:
  dat
  dat list [--json] [--source dotfiles|dotly]
  dat [--source dotfiles|dotly] <app> [args...]
  dat -h | --help
EOF
}

dat::cli::print_json_list() {
  local -a values=("$@")
  local index=0

  printf "["
  while ((index < ${#values[@]})); do
    printf '"%s"' "${values[$index]}"
    if ((index + 1 < ${#values[@]})); then
      printf ","
    fi
    index=$((index + 1))
  done
  printf "]\n"
}

dat::cli::list_command() {
  shift

  local source="all"
  local as_json=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --json)
      as_json=true
      ;;
    --source)
      source="${2:-}"
      shift
      ;;
    *)
      dat::adapter::output::error "Unknown option: $1"
      return "$DAT_EXIT_NOT_FOUND"
      ;;
    esac

    shift
  done

  if [[ "$source" != "all" ]] && ! dat::domain::source_precedence::is_valid "$source"; then
    dat::adapter::output::error "Invalid source: $source"
    return "$DAT_EXIT_NOT_FOUND"
  fi

  local installers=""
  installers="$(dat::application::list_installers "$source")"

  if [[ -z "$installers" ]]; then
    if $as_json; then
      printf "[]\n"
    fi
    return "$DAT_EXIT_OK"
  fi

  if $as_json; then
    local -a names=()
    local line=""
    while IFS= read -r line; do
      [[ -n "$line" ]] || continue
      names+=("$line")
    done <<<"$installers"

    dat::cli::print_json_list "${names[@]}"
  else
    printf "%s\n" "$installers"
  fi

  return "$DAT_EXIT_OK"
}

dat::cli::pick_and_run() {
  local -r source="${1:-all}"

  local installers=""
  installers="$(dat::application::list_installers "$source")"
  if [[ -z "$installers" ]]; then
    dat::adapter::output::error "No installers found"
    return "$DAT_EXIT_NOT_FOUND"
  fi

  local selected=""
  selected="$(dat::adapter::prompt::select "$installers")" || return "$DAT_EXIT_ADAPTER_MISSING"

  dat::application::run_installer "$selected" "$source"
}

dat::cli::main() {
  local source="all"

  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    dat::cli::usage
    return "$DAT_EXIT_OK"
  fi

  if [[ "${1:-}" == "--source" ]]; then
    source="${2:-}"
    shift 2
  fi

  if [[ "$source" != "all" ]] && ! dat::domain::source_precedence::is_valid "$source"; then
    dat::adapter::output::error "Invalid source: $source"
    return "$DAT_EXIT_NOT_FOUND"
  fi

  if [[ $# -eq 0 ]]; then
    dat::cli::pick_and_run "$source"
    return "$?"
  fi

  if [[ "$1" == "list" ]]; then
    dat::cli::list_command "$@"
    return "$?"
  fi

  local installer_name="$1"
  shift

  dat::application::run_installer "$installer_name" "$source" "$@"
  return "$?"
}
