#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$PATH"
export DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.dotfiles}"
export DOTLY_PATH="${DOTLY_PATH:-$DOTFILES_PATH/modules/dotly}"

if [[ -n "${CI:-}" ]]; then
  if command -v gum >/dev/null 2>&1; then
    export DAT_PROMPT_ADAPTER="gum"
  elif command -v fzf >/dev/null 2>&1; then
    export DAT_PROMPT_ADAPTER="fzf"
  else
    export DAT_PROMPT_ADAPTER="auto"
  fi
else
  if command -v rofi >/dev/null 2>&1; then
    export DAT_PROMPT_ADAPTER="rofi"
  elif command -v gum >/dev/null 2>&1; then
    export DAT_PROMPT_ADAPTER="gum"
  elif command -v fzf >/dev/null 2>&1; then
    export DAT_PROMPT_ADAPTER="fzf"
  else
    export DAT_PROMPT_ADAPTER="auto"
  fi
fi
