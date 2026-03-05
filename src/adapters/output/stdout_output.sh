#!/usr/bin/env bash

dat::adapter::output::info() {
  printf "%s\n" "$1"
}

dat::adapter::output::error() {
  printf "%s\n" "$1" >&2
}
