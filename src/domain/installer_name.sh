#!/usr/bin/env bash

dat::domain::installer_name::is_valid() {
  local -r name="${1:-}"
  [[ "$name" =~ ^[a-z0-9][a-z0-9._-]*$ ]]
}
