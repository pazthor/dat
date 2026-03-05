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

## Update

```bash
"$HOME/.local/share/dat/scripts/self/update"
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
dat list
dat list --json
dat <app> [args...]
dat --source dotly <app>
```

## Default installers included

- `dat fzf`: installs `fzf` using the available package manager.
- `dat work [path] [--shell] [--no-start]`: prepares a work folder and auto-starts
  `ddev`/`docker compose` when project files are detected.

`dat work` runs in a child process, so it cannot change your current shell directory.
Use `--shell` if you want to drop into an interactive shell inside the selected folder.

## Environment

- `DOTFILES_PATH` (default: `~/.dotfiles`)
- `DOTLY_PATH` (default: `$DOTFILES_PATH/modules/dotly`)

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
