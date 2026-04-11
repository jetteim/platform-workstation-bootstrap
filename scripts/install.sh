#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "${SKIP_GITHUB_REFRESH:-0}" != "1" ]; then
  "$repo_root/scripts/refresh-github.sh"
fi

mkdir -p "$HOME/.codex/hooks" "$HOME/.config/git/hooks"

cp "$repo_root/codex/hooks/"*.py "$HOME/.codex/hooks/"
chmod +x "$HOME/.codex/hooks/codex_hook.py"
cp "$repo_root/codex/hooks.json" "$HOME/.codex/hooks.json"

"$repo_root/scripts/install-skills.sh"

cp "$repo_root/git/hooks/pre-commit" "$HOME/.config/git/hooks/pre-commit"
chmod +x "$HOME/.config/git/hooks/pre-commit"
git config --global core.hooksPath "$HOME/.config/git/hooks"

python3 - "$HOME/.codex/config.toml" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
if not path.exists():
    path.write_text('[features]\ncodex_hooks = true\n', encoding='utf-8')
    raise SystemExit(0)

text = path.read_text(encoding='utf-8')
if re.search(r'(?m)^\[features\]\s*$', text):
    if re.search(r'(?m)^codex_hooks\s*=', text):
        text = re.sub(r'(?m)^codex_hooks\s*=.*$', 'codex_hooks = true', text)
    else:
        text = re.sub(r'(?m)^\[features\]\s*$', '[features]\ncodex_hooks = true', text, count=1)
else:
    text = text.rstrip() + '\n\n[features]\ncodex_hooks = true\n'
path.write_text(text, encoding='utf-8')
PY

echo "[install] installed Codex hooks, vendored skills, and global Git safety hook"
echo "[install] review codex/config.example.toml before changing live ~/.codex/config.toml further"
