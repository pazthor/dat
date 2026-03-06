#!/usr/bin/env bash

# Selects and sources the appropriate prompt adapter based on DAT_PROMPT_ADAPTER
# or auto-detection.
#
# Usage: dat::adapter::prompt::load
# Sets: dat::adapter::prompt::select function

dat::adapter::prompt::load() {
  local -r adapter="${DAT_PROMPT_ADAPTER:-auto}"
  local -r prompt_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  case "$adapter" in
    rofi)
      if command -v rofi > /dev/null 2>&1; then
        source "$prompt_dir/rofi_prompt.sh"
        dat::adapter::prompt::select() {
          dat::adapter::prompt::rofi::select "$@"
        }
        return 0
      fi
      # Fall through to auto if rofi not available
      ;&
    gum)
      if command -v gum > /dev/null 2>&1; then
        source "$prompt_dir/gum_prompt.sh"
        dat::adapter::prompt::select() {
          dat::adapter::prompt::gum::select "$@"
        }
        return 0
      fi
      # Fall through to auto if gum not available
      ;&
    fzf)
      source "$prompt_dir/fzf_prompt.sh"
      return 0
      ;;
    auto)
      # Auto-detection priority: rofi (if GUI) -> gum -> fzf
      if [[ -n "${DISPLAY:-}" ]] && command -v rofi > /dev/null 2>&1; then
        source "$prompt_dir/rofi_prompt.sh"
        dat::adapter::prompt::select() {
          dat::adapter::prompt::rofi::select "$@"
        }
      elif command -v gum > /dev/null 2>&1; then
        source "$prompt_dir/gum_prompt.sh"
        dat::adapter::prompt::select() {
          dat::adapter::prompt::gum::select "$@"
        }
      else
        source "$prompt_dir/fzf_prompt.sh"
      fi
      ;;
    *)
      # Unknown adapter, default to fzf
      source "$prompt_dir/fzf_prompt.sh"
      ;;
  esac
}
