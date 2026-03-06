# dat

dat = Another doTfile.

`dat` is an app installer launcher built with a hexagonal-lite architecture in Bash.
It follows convention over configuration.

## Install

Using curl:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/pazthor/dat/main/installer)
```

Using wget:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/pazthor/dat/main/installer)
```

Install from a local repository:

```bash
DAT_REPOSITORY="/absolute/path/to/dat" bash /absolute/path/to/dat/installer
```

You can also use any git URL:

```bash
DAT_REPOSITORY="git@github.com:pazthor/dat.git" bash <(curl -fsSL https://raw.githubusercontent.com/pazthor/dat/main/installer)
```

Manual install:

```bash
git clone https://github.com/pazthor/dat.git "$HOME/.local/share/dat"
mkdir -p "$HOME/.local/bin"
ln -sfn "$HOME/.local/share/dat/bin/dat" "$HOME/.local/bin/dat"
```

If `~/.local/bin` is not in your `PATH`, add:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Shell Completions

Tab completion support for bash and zsh.

### Bash

Add to `~/.bashrc`:
```bash
source "$HOME/.local/share/dat/completions/dat.bash"
```

### Zsh

Add to `~/.zshrc` before `compinit`:
```zsh
fpath=("$HOME/.local/share/dat/completions" $fpath)
autoload -Uz compinit && compinit
```

See [completions/README.md](completions/README.md) for detailed installation instructions and troubleshooting.

## Update

```bash
dat self update
# alias:
dat update
# check only:
dat self update --check
```

## Uninstall

```bash
"$HOME/.local/share/dat/scripts/self/uninstall"
```

## Convention

Installers must be executable files in:

- `scripts/install/<app>` inside `DOTFILES_PATH`
- `scripts/install/<app>` inside `DOTLY_PATH`

Default source precedence is:

1. `DOTFILES_PATH`
2. `DOTLY_PATH`

## Usage

```bash
dat
dat run
dat list
dat list --json
dat self status
dat self update
dat self link-omarchy-env
dat update
dat <app> [args...]
dat --source dotly <app>
```

Running `dat` without arguments shows a home view with built-in commands and
available installers. In an interactive terminal, it also opens a selectable menu.

## Default installers included

- `dat dotfiles [path] [--force]`: installs a full dotfiles template structure.
- `dat fzf`: installs `fzf` using the available package manager.
- `dat work [path] [--shell] [--no-start]`: prepares a work folder and auto-starts
  `ddev`/`docker compose` when project files are detected.

`dat work` runs in a child process, so it cannot change your current shell directory.
Use `--shell` if you want to drop into an interactive shell inside the selected folder.

## Environment

- `DOTFILES_PATH` (default: `~/.dotfiles`)
- `DOTLY_PATH` (default: `$DOTFILES_PATH/modules/dotly`)
- `DAT_PROMPT_ADAPTER` (default: `auto`) - Prompt adapter to use: `auto`, `rofi`, `gum`, or `fzf`

## Integration

### dotly integration

`dat` follows the same installer convention used by dotly and checks both sources:

1. `DOTFILES_PATH/scripts/install/<app>`
2. `DOTLY_PATH/scripts/install/<app>`

If an installer exists in both places, `DOTFILES_PATH` takes precedence.

Example setup:

```bash
export DOTFILES_PATH="$HOME/.dotfiles"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"
```

Examples:

```bash
# Use precedence (dotfiles first)
dat node

# Force dotly source
dat --source dotly node

# List installers from dotly only
dat list --source dotly
```

### Omarchy integration

`dat` works well on Omarchy systems for both interactive and scripted workflows.
See [docs/omarchy.md](docs/omarchy.md) for a dedicated desktop + CI profile.

Quick setup on Omarchy:

```bash
dat self link-omarchy-env
```

Recommended environment setup:

```bash
export PATH="$HOME/.local/bin:$PATH"
export DOTFILES_PATH="$HOME/.dotfiles"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"
```

Prompt adapter selection on Omarchy:

```bash
# Auto mode prefers rofi when GUI is available
dat

# Force rofi prompt adapter
DAT_PROMPT_ADAPTER=rofi dat

# Force terminal adapter
DAT_PROMPT_ADAPTER=gum dat
```

Interactive and non-interactive examples:

```bash
# Interactive menu + picker
dat

# Non-interactive machine output
dat list --json

# Non-interactive execution
dat --source dotfiles fzf

# Install dotfiles from local path
dat self install-dotfiles ~/my-dotfiles
```

## Exit Codes

- `0` success
- `2` installer not found
- `3` installer exists but is not executable
- `4` adapter dependency unavailable
- `5` installer execution failed

## Architecture

- `src/domain`: business rules
- `src/application`: use cases (`list`, `resolve`, `run`)
- `src/ports`: shell port contracts
- `src/adapters`: filesystem catalog, prompt, executor, cli

## Development

```bash
bash tests/test_dat.sh
```
