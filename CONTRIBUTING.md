# Contributing

Thanks for contributing.

## Rules

- Keep architecture hexagonal-lite and pragmatic.
- Follow convention over configuration.
- Keep Bash portable and simple.

## Local checks

```bash
shfmt -i 2 -sr -d installer bin src scripts tests
bash -lc 'shopt -s globstar nullglob; shellcheck installer bin/dat src/**/*.sh scripts/install/example scripts/self/* tests/test_dat.sh'
bash tests/test_dat.sh
```
