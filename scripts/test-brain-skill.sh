#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
skill_path="$codex_home/skills/brain/SKILL.md"
mirror_path="$codex_home/vendor_imports/repos/brain-skill"

require_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    echo "[brain-test] missing file: $path" >&2
    exit 1
  fi
}

require_contains() {
  local path="$1"
  local pattern="$2"
  if ! grep -q "$pattern" "$path"; then
    echo "[brain-test] missing pattern in $path: $pattern" >&2
    exit 1
  fi
}

require_file "$repo_root/skills/codex/brain/SKILL.md"
require_file "$repo_root/skills/codex/brain/references/mlx-pipeline.md"
require_file "$repo_root/skills/codex/brain/references/rust-embedding.md"
require_file "$repo_root/skills/codex/brain/references/python-sidecar.md"
require_file "$repo_root/docs/brain-skill-smoke-test.md"
require_file "$skill_path"

require_contains "$repo_root/skills/codex/brain/SKILL.md" '^name: brain$'
require_contains "$repo_root/skills/codex/brain/SKILL.md" 'Closed-Loop Deployment via Hooks'
require_contains "$repo_root/docs/brain-skill-smoke-test.md" 'Outcome Score: 32/35'

if [ -d "$mirror_path/.git" ]; then
  echo "[brain-test] source mirror: present"
else
  echo "[brain-test] source mirror: missing; install.sh should create it on connected machines" >&2
fi

missing_prereqs=0
for command in uv cmake; do
  if command -v "$command" >/dev/null 2>&1; then
    echo "[brain-test] prereq ${command}: present"
  else
    echo "[brain-test] prereq ${command}: missing"
    missing_prereqs=1
  fi
done

set +e
python3 - <<'PY'
missing = []
for mod in ("mlx", "mlx_lm"):
    try:
        __import__(mod)
    except Exception:
        missing.append(mod)
if missing:
    print("[brain-test] prereq python modules: missing " + ", ".join(missing))
    raise SystemExit(2)
print("[brain-test] prereq python modules: present")
PY
module_status=$?
set -e
if [ "$module_status" -eq 2 ]; then
  missing_prereqs=1
elif [ "$module_status" -ne 0 ]; then
  exit "$module_status"
fi

llama_count="$( { find "$HOME" -maxdepth 4 -type d -name 'llama.cpp' -print 2>/dev/null || true; } | wc -l | tr -d ' ')"
if [ "$llama_count" = "0" ]; then
  echo "[brain-test] prereq llama.cpp checkout: missing"
  missing_prereqs=1
else
  echo "[brain-test] prereq llama.cpp checkout: present"
fi

echo "[brain-test] package checks passed"
if [ "$missing_prereqs" = "1" ]; then
  echo "[brain-test] full MLX training run: blocked by missing heavy prerequisites"
else
  echo "[brain-test] full MLX training run: prerequisites present"
fi
