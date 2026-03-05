# ADR-003: Source precedence policy

## Status
Accepted

## Context
The same installer name can exist in both dotfiles and dotly sources.

## Decision
Default precedence is:

1. `DOTFILES_PATH`
2. `DOTLY_PATH`

Add `--source dotfiles|dotly` for explicit override.

## Consequences
- Deterministic behavior
- Easy local customization via dotfiles
