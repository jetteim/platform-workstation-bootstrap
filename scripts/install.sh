#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

validate_home_dir() {
  local name="$1"
  local path="$2"
  local default_path

  case "$path" in
    /*) ;;
    *)
      echo "[install] ${name} must be an absolute path: ${path}" >&2
      exit 1
      ;;
  esac

  case "$name" in
    AGENTS_HOME) default_path="$HOME/.agents" ;;
    CODEX_HOME) default_path="$HOME/.codex" ;;
    CLAUDE_HOME) default_path="$HOME/.claude" ;;
    *)
      echo "[install] unknown managed home variable: ${name}" >&2
      exit 1
      ;;
  esac

  case "$path" in
    "$default_path"|"$default_path"/*|/tmp/*|/var/folders/*) ;;
    *)
      echo "[install] refusing unsafe ${name}: ${path}" >&2
      exit 1
      ;;
  esac
}

reject_symlink_path() {
  local path="$1"
  local label="$2"
  local current="$path"

  while [ "$current" != "/" ] && [ "$current" != "$HOME" ] && [ "$current" != "/tmp" ] && [ "$current" != "/var/folders" ]; do
    if [ -L "$current" ]; then
      echo "[install] refusing symlinked ${label}: ${current}" >&2
      exit 1
    fi
    current="$(dirname "$current")"
  done
}

# Canonical agent roots default under ~/.agents.
install_tree() {
  local source="$1"
  local destination="$2"
  local label="$3"

  if [ ! -d "$source" ]; then
    echo "[install] missing source for ${label}: ${source}" >&2
    exit 1
  fi
  case "$destination" in
    ""|"/"|"$HOME"|"$AGENTS_HOME"|"$CODEX_HOME"|"$CLAUDE_HOME")
      echo "[install] refusing to clear unsafe destination for ${label}: ${destination}" >&2
      exit 1
      ;;
  esac

  reject_symlink_path "$destination" "$label destination"
  mkdir -p "$destination"
  reject_symlink_path "$destination" "$label destination"
  find "$destination" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
  cp -R "$source/." "$destination/"
  echo "[install] installed ${label}: ${destination}"
}

validate_home_dir "AGENTS_HOME" "$AGENTS_HOME"
validate_home_dir "CODEX_HOME" "$CODEX_HOME"
validate_home_dir "CLAUDE_HOME" "$CLAUDE_HOME"
reject_symlink_path "$AGENTS_HOME" "AGENTS_HOME"
reject_symlink_path "$CODEX_HOME" "CODEX_HOME"
reject_symlink_path "$CLAUDE_HOME" "CLAUDE_HOME"

if [ "${SKIP_GITHUB_REFRESH:-0}" != "1" ]; then
  "$repo_root/scripts/refresh-github.sh"
fi

mkdir -p "$AGENTS_HOME/rules" "$AGENTS_HOME/hooks" "$AGENTS_HOME/prompts" "$CODEX_HOME/hooks" "$HOME/.config/git/hooks"

install_tree "$repo_root/agents/rules" "$AGENTS_HOME/rules" "agent rules"
install_tree "$repo_root/agents/hooks" "$AGENTS_HOME/hooks" "agent hooks"
install_tree "$repo_root/agents/prompts" "$AGENTS_HOME/prompts" "agent prompts"
mkdir -p "$CLAUDE_HOME"
cp "$repo_root/agents/adapters/claude/CLAUDE.md.template" "$CLAUDE_HOME/CLAUDE.md.template"
echo "[install] installed Claude rule template: $CLAUDE_HOME/CLAUDE.md.template"

canonical_hooks_source="$repo_root/agents/hooks"
codex_dispatcher_source="$repo_root/codex/hooks/codex_hook.py"
codex_hooks_json="$repo_root/codex/hooks.json"
codex_adapter_hooks_source="$repo_root/agents/adapters/codex/hooks"
codex_adapter_hooks_json="$repo_root/agents/adapters/codex/hooks.json"
if [ ! -f "$canonical_hooks_source/policy.py" ] || [ ! -f "$canonical_hooks_source/redact.py" ]; then
  echo "[install] missing canonical hook policy files under $canonical_hooks_source" >&2
  exit 1
fi
if [ -f "$codex_adapter_hooks_source/codex_hook.py" ]; then
  codex_dispatcher_source="$codex_adapter_hooks_source/codex_hook.py"
fi
if [ -f "$codex_adapter_hooks_json" ]; then
  codex_hooks_json="$codex_adapter_hooks_json"
fi

cp "$canonical_hooks_source/policy.py" "$CODEX_HOME/hooks/policy.py"
cp "$canonical_hooks_source/redact.py" "$CODEX_HOME/hooks/redact.py"
cp "$codex_dispatcher_source" "$CODEX_HOME/hooks/codex_hook.py"
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
