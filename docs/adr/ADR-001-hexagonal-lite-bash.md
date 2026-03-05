# ADR-001: Hexagonal-lite architecture in Bash

## Status
Accepted

## Context
`dat` must support multiple frontends (CLI first, then rofi/TUI) without rewriting core logic.

## Decision
Use a lightweight hexagonal approach:

- `domain` for business rules
- `application` for use cases
- `ports` for contracts
- `adapters` for I/O and UI

## Consequences
- Better frontend portability
- Slight indirection, kept minimal for Bash pragmatism
