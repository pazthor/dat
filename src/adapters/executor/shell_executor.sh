#!/usr/bin/env bash

dat::adapter::executor::run() {
  local -r script_path="$1"
  shift

  "$script_path" "$@"
}
