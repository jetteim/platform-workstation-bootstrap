#!/usr/bin/env bash
set -euo pipefail

echo "== host =="
sw_vers || true
uname -a || true

echo
echo "== core tools =="
for cmd in git gh brew codex node npm python3 ruby go terraform tflint jq rg; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '%-12s %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf '%-12s missing\n' "$cmd"
  fi
done

echo
echo "== git global config =="
git config --global --list --show-origin || true

echo
echo "== codex features =="
codex features list || true

echo
echo "== codex config =="
sed -n '1,220p' "$HOME/.codex/config.toml" 2>/dev/null || true

echo
echo "== github auth =="
gh auth status || true

