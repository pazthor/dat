#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAT_BIN="$ROOT_DIR/bin/dat"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [[ "$expected" != "$actual" ]]; then
    fail "$message (expected='$expected' actual='$actual')"
  fi
}

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

DOTFILES_FIXTURE="$TEMP_DIR/dotfiles"
DOTLY_FIXTURE="$TEMP_DIR/dotly"

mkdir -p "$DOTFILES_FIXTURE/scripts/install" "$DOTLY_FIXTURE/scripts/install"

cat >"$DOTLY_FIXTURE/scripts/install/node" <<'EOF'
#!/usr/bin/env bash
echo "dotly-node:$*"
EOF

cat >"$DOTFILES_FIXTURE/scripts/install/node" <<'EOF'
#!/usr/bin/env bash
echo "dotfiles-node:$*"
EOF

cat >"$DOTLY_FIXTURE/scripts/install/docker" <<'EOF'
#!/usr/bin/env bash
echo "dotly-docker"
EOF

cat >"$DOTLY_FIXTURE/scripts/install/not_executable" <<'EOF'
#!/usr/bin/env bash
echo "should not run"
EOF

chmod +x "$DOTLY_FIXTURE/scripts/install/node"
chmod +x "$DOTFILES_FIXTURE/scripts/install/node"
chmod +x "$DOTLY_FIXTURE/scripts/install/docker"

list_output="$(DOTFILES_PATH="$DOTFILES_FIXTURE" DOTLY_PATH="$DOTLY_FIXTURE" "$DAT_BIN" list)"

if ! grep -q '^docker$' <<<"$list_output"; then
  fail "docker should be listed"
fi
if ! grep -q '^node$' <<<"$list_output"; then
  fail "node should be listed"
fi
if grep -q '^not_executable$' <<<"$list_output"; then
  fail "non-executable should not be listed"
fi

json_output="$(DOTFILES_PATH="$DOTFILES_FIXTURE" DOTLY_PATH="$DOTLY_FIXTURE" "$DAT_BIN" list --json)"
assert_eq '["docker","node"]' "$json_output" "json list should be stable"

run_output="$(DOTFILES_PATH="$DOTFILES_FIXTURE" DOTLY_PATH="$DOTLY_FIXTURE" "$DAT_BIN" node abc)"
assert_eq 'dotfiles-node:abc' "$run_output" "dotfiles should have precedence"

dotly_output="$(DOTFILES_PATH="$DOTFILES_FIXTURE" DOTLY_PATH="$DOTLY_FIXTURE" "$DAT_BIN" --source dotly node zz)"
assert_eq 'dotly-node:zz' "$dotly_output" "source override should use dotly"

set +e
DOTFILES_PATH="$DOTFILES_FIXTURE" DOTLY_PATH="$DOTLY_FIXTURE" "$DAT_BIN" missing >/dev/null 2>&1
missing_code=$?
set -e
assert_eq "2" "$missing_code" "missing installer should return code 2"

set +e
DOTFILES_PATH="$DOTFILES_FIXTURE" DOTLY_PATH="$DOTLY_FIXTURE" "$DAT_BIN" --source invalid node >/dev/null 2>&1
invalid_source_code=$?
set -e
assert_eq "2" "$invalid_source_code" "invalid source should return code 2"

echo "OK"
