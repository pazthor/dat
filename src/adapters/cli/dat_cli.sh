#!/usr/bin/env bash

DAT_CLI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAT_SRC_ROOT="$(cd "$DAT_CLI_DIR/../.." && pwd)"
DAT_PROJECT_ROOT="$(cd "$DAT_SRC_ROOT/.." && pwd)"

source "$DAT_SRC_ROOT/domain/exit_codes.sh"
source "$DAT_SRC_ROOT/domain/installer_name.sh"
source "$DAT_SRC_ROOT/domain/source_precedence.sh"

source "$DAT_SRC_ROOT/adapters/catalog/filesystem_catalog.sh"
source "$DAT_SRC_ROOT/adapters/executor/shell_executor.sh"
source "$DAT_SRC_ROOT/adapters/output/stdout_output.sh"
source "$DAT_SRC_ROOT/adapters/prompt/prompt_selector.sh"

# Load the appropriate prompt adapter
dat::adapter::prompt::load

source "$DAT_SRC_ROOT/application/list_installers.sh"
source "$DAT_SRC_ROOT/application/resolve_installer.sh"
source "$DAT_SRC_ROOT/application/run_installer.sh"

dat::cli::usage() {
  cat <<'EOF'
Usage:
  dat
  dat run [--source dotfiles|dotly]
  dat list [--json] [--source dotfiles|dotly]
  dat self status
  dat self update [--check]
  dat self install-dotfiles <source> [target] [--force] [--branch <branch>]
  dat self link-omarchy-env [--force] [--target <path>]
  dat update [--check]
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

dat::cli::is_interactive() {
  [[ -t 0 && -t 1 ]]
}

dat::cli::self_script_path() {
  local -r name="$1"
  printf "%s/scripts/self/%s" "$DAT_PROJECT_ROOT" "$name"
}

dat::cli::run_self_script() {
  local -r script_name="$1"
  shift

  local -r script_path="$(dat::cli::self_script_path "$script_name")"
  if [[ ! -f "$script_path" ]]; then
    dat::adapter::output::error "Self command not found: $script_name"
    return "$DAT_EXIT_NOT_FOUND"
  fi

  if [[ ! -x "$script_path" ]]; then
    dat::adapter::output::error "Self command not executable: $script_name"
    return "$DAT_EXIT_NOT_EXECUTABLE"
  fi

  "$script_path" "$@"
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

dat::cli::print_home() {
  local -r source="${1:-all}"
  local installers=""
  installers="$(dat::application::list_installers "$source")"

  cat <<'EOF'
dat home

Available commands:
  list
  self status
  self update
  self update --check
  self install-dotfiles <source> [target]
  self link-omarchy-env
  run

Examples:
  dat <app>
  dat self update
  dat self install-dotfiles ~/my-dotfiles
  dat self link-omarchy-env
  dat list --json
EOF

  printf "\nInstaller source: %s\n" "$source"
  printf "Available installers:\n"
  if [[ -z "$installers" ]]; then
    printf "  (none)\n"
  else
    while IFS= read -r installer; do
      [[ -n "$installer" ]] || continue
      printf "  %s\n" "$installer"
    done <<<"$installers"
  fi
}

dat::cli::interactive_home_menu() {
  local -r source="${1:-all}"
  local installers=""
  installers="$(dat::application::list_installers "$source")"

  local options=""
  options+="command: list"
  options+=$'\n'
  options+="command: self status"
  options+=$'\n'
  options+="command: self update"
  options+=$'\n'
  options+="command: self update --check"
  options+=$'\n'
  options+="command: self install-dotfiles"
  options+=$'\n'
  options+="command: self link-omarchy-env"

  if [[ -n "$installers" ]]; then
    while IFS= read -r installer; do
      [[ -n "$installer" ]] || continue
      options+=$'\n'
      options+="installer: $installer"
    done <<<"$installers"
  fi

  local selected=""
  selected="$(dat::adapter::prompt::select "$options")" || return "$DAT_EXIT_ADAPTER_MISSING"

  case "$selected" in
  "command: list")
    dat::cli::list_command list
    ;;
  "command: self status")
    dat::cli::run_self_script status
    ;;
  "command: self update")
    dat::cli::run_self_script update
    ;;
  "command: self update --check")
    dat::cli::run_self_script update --check
    ;;
  "command: self install-dotfiles")
    dat::adapter::output::info "Usage: dat self install-dotfiles <source> [target] [--force] [--branch <branch>]"
    dat::adapter::output::info "Run 'dat self install-dotfiles --help' for more details"
    ;;
  "command: self link-omarchy-env")
    dat::cli::run_self_script link-omarchy-env
    ;;
  installer:*)
    local installer_name="${selected#installer: }"
    dat::application::run_installer "$installer_name" "$source"
    ;;
  *)
    dat::adapter::output::error "Unknown selection: $selected"
    return "$DAT_EXIT_NOT_FOUND"
    ;;
  esac
}

dat::cli::self_command() {
  local subcommand="${1:-}"
  shift || true

  case "$subcommand" in
  status)
    dat::cli::run_self_script status "$@"
    ;;
  update)
    dat::cli::run_self_script update "$@"
    ;;
  install-dotfiles)
    dat::cli::run_self_script install-dotfiles "$@"
    ;;
  link-omarchy-env)
    dat::cli::run_self_script link-omarchy-env "$@"
    ;;
  "")
    dat::adapter::output::error "Missing self subcommand: use 'status', 'update', 'install-dotfiles', or 'link-omarchy-env'"
    return "$DAT_EXIT_NOT_FOUND"
    ;;
  *)
    dat::adapter::output::error "Unknown self subcommand: $subcommand"
    return "$DAT_EXIT_NOT_FOUND"
    ;;
  esac
}

dat::cli::run_command() {
  local source="$1"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
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

  dat::cli::pick_and_run "$source"
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
    dat::cli::print_home "$source"

    if dat::cli::is_interactive; then
      printf "\n"
      dat::cli::interactive_home_menu "$source"
      return "$?"
    fi

    return "$DAT_EXIT_OK"
  fi

  case "$1" in
  list)
    dat::cli::list_command "$@"
    return "$?"
    ;;
  run)
    dat::cli::run_command "$source" "${@:2}"
    return "$?"
    ;;
  self)
    shift
    dat::cli::self_command "$@"
    return "$?"
    ;;
  update)
    shift
    dat::cli::run_self_script update "$@"
    return "$?"
    ;;
  esac

  local installer_name="$1"
  shift

  dat::application::run_installer "$installer_name" "$source" "$@"
  return "$?"
}
