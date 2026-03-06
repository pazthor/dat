#!/usr/bin/env bash
# Bash completion for dat

_dat_completions() {
  local cur prev words cword
  _init_completion || return

  local commands="list run self update"
  local self_commands="status update install-dotfiles"
  local sources="dotfiles dotly"

  case "${words[1]}" in
    list)
      case "$prev" in
        --source) COMPREPLY=($(compgen -W "$sources" -- "$cur")) ;;
        *) COMPREPLY=($(compgen -W "--json --source" -- "$cur")) ;;
      esac
      ;;
    self)
      case "${words[2]}" in
        install-dotfiles)
          case "$prev" in
            --branch) ;; # Expect user input
            *) COMPREPLY=($(compgen -W "--force --branch --dry-run --no-omarchy --config -i --interactive" -- "$cur")) ;;
          esac
          ;;
        update)
          case "$prev" in
            *) COMPREPLY=($(compgen -W "--check" -- "$cur")) ;;
          esac
          ;;
        *) COMPREPLY=($(compgen -W "$self_commands" -- "$cur")) ;;
      esac
      ;;
    run)
      case "$prev" in
        --source) COMPREPLY=($(compgen -W "$sources" -- "$cur")) ;;
        *) COMPREPLY=($(compgen -W "--source" -- "$cur")) ;;
      esac
      ;;
    update)
      case "$prev" in
        *) COMPREPLY=($(compgen -W "--check" -- "$cur")) ;;
      esac
      ;;
    --source)
      COMPREPLY=($(compgen -W "$sources" -- "$cur"))
      ;;
    *)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--help --source" -- "$cur"))
      elif [[ "$cword" -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$commands --help" -- "$cur"))
      else
        # Dynamic installer completion
        local installers
        installers=$(dat list --json 2>/dev/null | tr -d '[]"' | tr ',' ' ')
        if [[ -n "$installers" ]]; then
          COMPREPLY=($(compgen -W "$installers" -- "$cur"))
        fi
      fi
      ;;
  esac
}

complete -F _dat_completions dat
