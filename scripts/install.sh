#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

# Canonical agent roots default under ~/.agents/rules.
install_tree() {
  local source="$1"
  local destination="$2"
  local label="$3"

  if [ ! -d "$source" ]; then
    echo "[install] missing source for ${label}: ${source}" >&2
    exit 1
  fi

  mkdir -p "$destination"
  cp -R "$source/." "$destination/"
  echo "[install] installed ${label}: ${destination}"
}

if [ "${SKIP_GITHUB_REFRESH:-0}" != "1" ]; then
  "$repo_root/scripts/refresh-github.sh"
fi

mkdir -p "$AGENTS_HOME/rules" "$AGENTS_HOME/hooks" "$AGENTS_HOME/prompts" "$CODEX_HOME/hooks" "$HOME/.config/git/hooks"

install_tree "$repo_root/agents/rules" "$AGENTS_HOME/rules" "agent rules"
if [ -d "$repo_root/agents/hooks" ]; then
  install_tree "$repo_root/agents/hooks" "$AGENTS_HOME/hooks" "agent hooks"
fi
if [ -d "$repo_root/agents/prompts" ]; then
  install_tree "$repo_root/agents/prompts" "$AGENTS_HOME/prompts" "agent prompts"
fi

codex_hooks_source="$repo_root/codex/hooks"
codex_hooks_json="$repo_root/codex/hooks.json"
codex_adapter_hooks_source="$repo_root/agents/adapters/codex/hooks"
codex_adapter_hooks_json="$repo_root/agents/adapters/codex/hooks.json"
# A broad find "$codex_adapter_hooks_source" -maxdepth 1 -name '*.py' check is not enough here.
if [ -f "$codex_adapter_hooks_source/codex_hook.py" ] &&
  [ -f "$codex_adapter_hooks_source/policy.py" ] &&
  [ -f "$codex_adapter_hooks_source/redact.py" ]; then
  codex_hooks_source="$codex_adapter_hooks_source"
fi
if [ -f "$codex_adapter_hooks_json" ]; then
  codex_hooks_json="$codex_adapter_hooks_json"
fi

cp "$codex_hooks_source/"*.py "$CODEX_HOME/hooks/"
chmod +x "$CODEX_HOME/hooks/codex_hook.py"
cp "$codex_hooks_json" "$CODEX_HOME/hooks.json"

"$repo_root/scripts/install-skills.sh"

cp "$repo_root/git/hooks/pre-commit" "$HOME/.config/git/hooks/pre-commit"
chmod +x "$HOME/.config/git/hooks/pre-commit"
git config --global core.hooksPath "$HOME/.config/git/hooks"

python3 - "$CODEX_HOME/config.toml" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
required_features = {
    "codex_hooks": "true",
    "multi_agent": "true",
}

if not path.exists():
    path.write_text(
        "[features]\n"
        + "".join(f"{key} = {value}\n" for key, value in required_features.items()),
        encoding="utf-8",
    )
    raise SystemExit(0)

text = path.read_text(encoding='utf-8')
if re.search(r'(?m)^\[features\]\s*$', text):
    for key, value in required_features.items():
        replacement = f"{key} = {value}"
        if re.search(rf'(?m)^{re.escape(key)}\s*=', text):
            text = re.sub(rf'(?m)^{re.escape(key)}\s*=.*$', replacement, text)
        else:
            text = re.sub(r'(?m)^\[features\]\s*$', f'[features]\n{replacement}', text, count=1)
else:
    text = (
        text.rstrip()
        + "\n\n[features]\n"
        + "".join(f"{key} = {value}\n" for key, value in required_features.items())
    )
path.write_text(text, encoding='utf-8')
PY

echo "[install] installed canonical agent layer, adapter projections, and global Git safety hook"
echo "[install] review agents/adapters/codex/config.example.toml before changing live $CODEX_HOME/config.toml further"
