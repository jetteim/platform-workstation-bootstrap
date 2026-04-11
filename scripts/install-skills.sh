#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_root="$repo_root/skills"

if [ ! -d "$skills_root" ]; then
  echo "[skills] missing vendored skills directory: $skills_root" >&2
  exit 1
fi

install_tree() {
  local source="$1"
  local destination="$2"
  local label="$3"

  if [ ! -d "$source" ]; then
    echo "[skills] missing source for ${label}: ${source}" >&2
    exit 1
  fi

  mkdir -p "$destination"
  cp -R "$source/." "$destination/"
  local count
  count="$(find "$destination" -name SKILL.md | wc -l | tr -d ' ')"
  echo "[skills] installed ${label}: ${count} skills -> ${destination}"
}

mkdir -p "$HOME/.codex/skills" "$HOME/.agents/skills"

install_tree "$skills_root/codex" "$HOME/.codex/skills" "Codex user/system skills"
install_tree "$skills_root/superpowers" "$HOME/.codex/superpowers/skills" "Superpowers skills"

if [ -L "$HOME/.agents/skills/superpowers" ] || [ ! -e "$HOME/.agents/skills/superpowers" ]; then
  rm -f "$HOME/.agents/skills/superpowers"
  ln -s "$HOME/.codex/superpowers/skills" "$HOME/.agents/skills/superpowers"
  echo "[skills] linked Superpowers skills -> ~/.agents/skills/superpowers"
else
  echo "[skills] ~/.agents/skills/superpowers exists and is not a symlink; leaving it unchanged" >&2
fi

install_tree "$skills_root/plugins/github" "$HOME/.agents/skills/plugin-github" "GitHub plugin skill fallback"
install_tree "$skills_root/plugins/google-drive" "$HOME/.agents/skills/plugin-google-drive" "Google Drive plugin skill fallback"

find "$HOME/.codex/skills" "$HOME/.codex/superpowers/skills" "$HOME/.agents/skills" \
  -type f -path "*/scripts/*" -exec chmod +x {} \; 2>/dev/null || true

total="$(find "$skills_root" -name SKILL.md | wc -l | tr -d ' ')"
echo "[skills] vendored skill inventory: ${total} skills"

