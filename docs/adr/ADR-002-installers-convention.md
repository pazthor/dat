# ADR-002: Installers convention

## Status
Accepted

## Context
Configuration-heavy onboarding slows adoption and increases maintenance.

## Decision
Use convention over configuration:

- Installers are executable files at `scripts/install/<app>`
- No mandatory config file in v1

## Consequences
- Faster onboarding
- Less flexibility for uncommon layouts, acceptable in v1
