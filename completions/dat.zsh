#compdef dat

_dat() {
  local -a commands self_commands sources
  commands=(
    'list:List available installers'
    'run:Run installer interactively'
    'self:Self-management commands'
    'update:Update dat'
  )
  self_commands=(
    'status:Show dat status'
    'update:Update dat from origin'
    'install-dotfiles:Install dotfiles from source'
    'link-omarchy-env:Link Omarchy env profile'
  )
  sources=(dotfiles dotly)

  _arguments -C \
    '1: :->command' \
    '*:: :->args'

  case $state in
    command)
      _describe -t commands 'dat commands' commands
      # Dynamic installer completion
      local -a installers
      installers=(${(f)"$(dat list 2>/dev/null)"})
      if (( ${#installers[@]} > 0 )); then
        _describe -t installers 'installers' installers
      fi
      ;;
    args)
      case $words[1] in
        list)
          _arguments \
            '--json[Output as JSON]' \
            '--source[Filter by source]:source:(dotfiles dotly)'
          ;;
        self)
          _arguments '1: :->self_cmd' '*:: :->self_args'
          case $state in
            self_cmd)
              _describe -t self_commands 'self commands' self_commands
              ;;
            self_args)
              case $words[1] in
                install-dotfiles)
                  _arguments \
                    '-i[Interactive mode]' \
                    '--interactive[Interactive mode]' \
                    '--dry-run[Preview changes]' \
                    '--force[Overwrite existing]' \
                    '--branch[Git branch]:branch:' \
                    '--no-omarchy[Skip omarchy integration]' \
                    '--config[Show config file]' \
                    '1:source:_files -/' \
                    '2:target:_files -/'
                  ;;
                update)
                  _arguments '--check[Check only, no update]'
                  ;;
                link-omarchy-env)
                  _arguments \
                    '--force[Replace existing target]' \
                    '--target[Custom target path]:target:_files'
                  ;;
              esac
              ;;
          esac
          ;;
        run)
          _arguments '--source[Filter by source]:source:(dotfiles dotly)'
          ;;
        update)
          _arguments '--check[Check only, no update]'
          ;;
        *)
          # Dynamic installer completion for direct invocation
          local -a installers
          installers=(${(f)"$(dat list 2>/dev/null)"})
          if (( ${#installers[@]} > 0 )); then
            _describe -t installers 'installers' installers
          fi
          ;;
      esac
      ;;
  esac
}

_dat "$@"
