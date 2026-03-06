# Omarchy integration

Use this profile split to keep desktop behavior interactive with `rofi` while keeping CI deterministic and non-interactive.

## Fast setup

Create a symlink to dat's maintained Omarchy profile:

```bash
dat self link-omarchy-env
```

This links `~/.config/omarchy/env/dat.sh` to `templates/omarchy/dat.sh`.

## Environment profile (managed template)

```bash
# Managed by dat: templates/omarchy/dat.sh
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
```

## Recommended command split

```bash
# Desktop operator flow
dat

# Script/CI flow
dat list --json
dat --source dotfiles fzf
```

## Why this split

- Desktop sessions get fast launcher UX through `rofi`.
- CI and automation avoid interactive UI dependencies.
- Commands remain reproducible with explicit source selection.

## Rofi/launcher recommendations

- Use `rofi` as a command launcher for operator-driven tasks where you want quick choice and visibility.
- Keep launcher entries simple, for example: `dat`, `dat run`, `dat list`, `dat self status`, `dat self update --check`.
- Prefer direct `dat <app>` commands when you already know the installer name and want fewer clicks.
- Use the terminal fallback (`gum` or `fzf`) for SSH sessions, TTY-only sessions, or minimal environments.

## Where dat fits (and where it does not)

- Fits well for reproducible setup/install flows backed by scripts in `scripts/install/<app>`.
- Fits as a thin orchestration layer for dotfiles and module installers (`DOTFILES_PATH` and `DOTLY_PATH`).
- Fits for mixed workflows: interactive selection on desktop and machine-readable output in automation.
- Does not fit for long-running service supervision, dependency graph solving, or full system configuration management.
- Does not fit when a task is not scriptable as an idempotent installer; use native tools directly in those cases.
