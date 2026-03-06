# Shell Completions for dat

Tab completion support for `dat` commands, installers, and options.

## Features

- Command completion: `list`, `run`, `self`, `update`
- Self subcommand completion: `status`, `update`, `install-dotfiles`
- Dynamic installer completion from `dat list`
- Option completion: `--json`, `--source`, `--force`, etc.
- Source completion: `dotfiles`, `dotly`

## Installation

### Bash

#### Option 1: User install (recommended)

Add to `~/.bashrc`:
```bash
source /path/to/dat/completions/dat.bash
```

Or if dat is installed via installer:
```bash
source "$DAT_HOME/completions/dat.bash"
```

#### Option 2: System-wide

```bash
sudo cp completions/dat.bash /etc/bash_completion.d/dat
```

#### Option 3: Homebrew (macOS with bash-completion)

```bash
cp completions/dat.bash $(brew --prefix)/etc/bash_completion.d/dat
```

### Zsh

#### Option 1: Add to fpath (recommended)

Add to `~/.zshrc` **before** `compinit`:
```zsh
fpath=(/path/to/dat/completions $fpath)
autoload -Uz compinit && compinit
```

Or with DAT_HOME:
```zsh
fpath=("$DAT_HOME/completions" $fpath)
autoload -Uz compinit && compinit
```

#### Option 2: Oh-My-Zsh

```bash
cp completions/dat.zsh ~/.oh-my-zsh/completions/_dat
```

Then reload completions:
```zsh
rm -f ~/.zcompdump; compinit
```

#### Option 3: Omarchy

```bash
mkdir -p ~/.config/zsh/completions
cp completions/dat.zsh ~/.config/zsh/completions/_dat
```

Add to `~/.zshrc`:
```zsh
fpath=(~/.config/zsh/completions $fpath)
```

## Verification

After installation, restart your shell and test:

```bash
# Command completion
dat <TAB>
# Should show: list, run, self, update, [installers...]

# Self command completion
dat self <TAB>
# Should show: status, update, install-dotfiles

# Option completion
dat list --<TAB>
# Should show: --json, --source

# Source completion
dat list --source <TAB>
# Should show: dotfiles, dotly

# install-dotfiles options
dat self install-dotfiles --<TAB>
# Should show: -i, --interactive, --dry-run, --force, --branch, etc.
```

## Troubleshooting

### Bash: Completions not working

1. Verify bash-completion is installed:
   ```bash
   # Debian/Ubuntu
   sudo apt-get install bash-completion
   
   # macOS
   brew install bash-completion@2
   ```

2. Ensure `~/.bashrc` sources the completion script after bash-completion loads

3. Reload shell or run:
   ```bash
   source ~/.bashrc
   ```

### Zsh: Completions not working

1. Verify completion system is enabled:
   ```zsh
   # Should be in ~/.zshrc
   autoload -Uz compinit && compinit
   ```

2. Clear completion cache:
   ```zsh
   rm -f ~/.zcompdump*
   exec zsh
   ```

3. Verify fpath includes completions directory:
   ```zsh
   echo $fpath
   ```

### Dynamic installer completion not working

1. Verify `dat` is in PATH:
   ```bash
   which dat
   ```

2. Test installer listing:
   ```bash
   dat list --json
   ```

3. If using a custom DOTFILES_PATH, ensure it's set before completion loads

## Examples

```bash
# Complete installer names
dat fz<TAB>        # → dat fzf
dat dot<TAB>       # → dat dotfiles

# Complete with source filter
dat --source dotl<TAB> wo<TAB>    # → dat --source dotly work

# Complete self commands
dat self inst<TAB>                # → dat self install-dotfiles

# Complete install-dotfiles options
dat self install-dotfiles --d<TAB> ~/dotfiles
# → dat self install-dotfiles --dry-run ~/dotfiles
```
