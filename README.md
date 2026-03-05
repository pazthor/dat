# dat

dat = Another doTfile.

`dat` is an app installer launcher built with a hexagonal-lite architecture in Bash.
It follows convention over configuration.

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
