# AGENTS Guide for `dat`
This file guides coding agents working in this repository.
Follow these commands and conventions unless a maintainer says otherwise.

## 1) Project Context
- Language: Bash.
- Main CLI: `bin/dat`.
- Architecture: hexagonal-lite.
- Layer layout:
  - `src/domain` business rules and constants.
  - `src/application` use cases.
  - `src/ports` contracts.
  - `src/adapters` CLI, prompt, executor, catalog, output.
- Built-in installer scripts: `scripts/install/*`.
- Self-management scripts: `scripts/self/*`.

## 2) Rule Files Check
- `.cursorrules`: not present.
- `.cursor/rules/`: not present.
- `.github/copilot-instructions.md`: not present.
- Use this file + existing code as the active policy.

## 3) Build / Lint / Test Commands
Run from repo root.

### Full quality gate (same spirit as CI)
```bash
shfmt -i 2 -sr -d installer bin src scripts tests
bash -lc 'shopt -s globstar nullglob; shellcheck installer bin/dat src/**/*.sh scripts/install/* scripts/self/* tests/test_dat.sh'
bash tests/test_dat.sh
```

### Formatting
Check format:
```bash
shfmt -i 2 -sr -d installer bin src scripts tests
```
Write format:
```bash
shfmt -i 2 -sr -w installer bin src scripts tests
```

### Lint
```bash
bash -lc 'shopt -s globstar nullglob; shellcheck installer bin/dat src/**/*.sh scripts/install/* scripts/self/* tests/test_dat.sh'
```

### Tests
All tests:
```bash
bash tests/test_dat.sh
```
Single test file (currently same as all tests):
```bash
bash tests/test_dat.sh
```
Single scenario debugging (no per-case runner exists yet):
```bash
DOTLY_PATH="$PWD" DOTFILES_PATH="/tmp/none" bin/dat list
DAT_HOME="$PWD" bin/dat self status
```

## 4) CI Reference
CI file: `.github/workflows/ci.yml`.
CI runs:
1. `shfmt -i 2 -sr -d installer bin src scripts tests`
2. `shellcheck installer bin/dat src/**/*.sh scripts/install/* scripts/self/* tests/test_dat.sh`
3. `bash tests/test_dat.sh`
If local and CI differ, match CI behavior exactly.

## 5) Formatting and File Style
- Use `#!/usr/bin/env bash`.
- Use `set -euo pipefail` for executable scripts.
- Prefer ASCII; avoid unusual Unicode in code.
- Follow `.editorconfig`:
  - 2-space indentation for shell files.
  - LF endings.
  - UTF-8 encoding.
  - final newline required.
- Use `shfmt` as canonical formatting tool.

## 6) Imports, Paths, and Structure
- Source dependencies near top of file.
- Build robust paths from `BASH_SOURCE[0]` when locating project files.
- Keep import order in CLI adapter consistent:
  1. domain
  2. adapters
  3. application
- Do not introduce hidden sourcing side effects.

## 7) Naming Conventions
- Function names should be namespaced, e.g. `dat::cli::main`.
- Prefer `dat::layer::action` style for discoverability.
- Variables use `snake_case`.
- Env defaults/constants use uppercase (`DAT_HOME`, `DAT_BRANCH`).
- Use descriptive names; avoid cryptic abbreviations.

## 8) Types and Data Contracts (Bash)
- Treat values as strings unless arrays are needed.
- Use arrays when items may contain spaces.
- Use newline-separated output for list contracts.
- Keep stable machine output for public interfaces (`dat list --json`).

## 9) Error Handling and Exit Codes
- Print errors to stderr.
- Fail with actionable messages.
- Preserve exit code contract:
  - `0` success
  - `2` not found / invalid option
  - `3` not executable
  - `4` adapter dependency unavailable
  - `5` execution failed
- Avoid swallowing errors silently.

## 10) CLI and UX Conventions
- Keep `--help` output accurate after any command change.
- Non-interactive mode must be deterministic.
- Interactive flows may use `fzf`, but fallback mode must still work.
- Keep convention-over-configuration defaults.

## 11) Architectural Guardrails
- Put business decisions in `domain` and `application`.
- Put IO/FS/process/prompt logic in `adapters`.
- Keep ports thin and explicit.
- Prefer incremental extension over large rewrites.

## 12) Script Guidelines
For `scripts/install/*`:
- Must be executable.
- Prefer support for `-h` / `--help`.
- Should be idempotent where possible.
- Detect missing dependencies and fail clearly.
For `scripts/self/*`:
- Keep git operations safe and explicit.
- Prefer fast-forward-only update behavior.
- Do not auto-hide dirty/diverged repository states.

## 13) Agent Workflow
1. Read related files before editing.
2. Make the smallest coherent change.
3. Run format, lint, and tests.
4. Update `README.md` when UX/commands change.
5. Update `CHANGELOG.md` for user-facing behavior.

## 14) Useful Local Debug Patterns
- Override env vars to test behavior safely:
  - `DAT_HOME`
  - `DOTFILES_PATH`
  - `DOTLY_PATH`
- Use temp directories for installer smoke tests.
- Validate both scripted and interactive flows (`dat list --json`, `dat`).
Keep this guide updated as CI commands and conventions evolve.
