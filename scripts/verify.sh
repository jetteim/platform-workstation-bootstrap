#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PYTHONPYCACHEPREFIX="${PYTHONPYCACHEPREFIX:-${TMPDIR:-/tmp}/platform-bootstrap-pycache}"
mkdir -p "$PYTHONPYCACHEPREFIX"

for script in "$repo_root/scripts/"*.sh "$repo_root/git/hooks/pre-commit"; do
  bash -n "$script"
done
python3 -m compileall -q "$repo_root/agents/hooks" "$repo_root/agents/adapters/codex/hooks" \
  "$repo_root/codex/hooks" "$repo_root/scripts" "$repo_root/git/hooks/scan-staged.py"
python3 "$repo_root/scripts/test-harness.py"
echo "[verify] ok"
