#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_root="$repo_root/skills"

if [ ! -d "$skills_root" ]; then
  echo "[skills] missing vendored skills directory: $skills_root" >&2
  exit 1
fi

SUPERPOWERS_REPO="${SUPERPOWERS_REPO:-https://github.com/jetteim/superpowers.git}"
OPENAI_SKILLS_REPO="${OPENAI_SKILLS_REPO:-https://github.com/jetteim/skills.git}"
CODEX_REPO="${CODEX_REPO:-https://github.com/jetteim/codex.git}"
PLAYWRIGHT_MCP_REPO="${PLAYWRIGHT_MCP_REPO:-https://github.com/jetteim/playwright-mcp.git}"
MCP_SERVERS_REPO="${MCP_SERVERS_REPO:-https://github.com/jetteim/servers.git}"
BRAIN_SKILL_REPO="${BRAIN_SKILL_REPO:-https://github.com/jetteim/brain-skill.git}"
LLAMA_CPP_REPO="${LLAMA_CPP_REPO:-https://github.com/jetteim/llama.cpp.git}"
USE_VENDORED_FALLBACK="${USE_VENDORED_FALLBACK:-1}"

clone_or_update() {
  local repo="$1"
  local destination="$2"
  local branch="$3"
  local label="$4"

  if [ -d "$destination/.git" ]; then
    if [ -n "$(git -C "$destination" status --porcelain)" ]; then
      echo "[skills] ${label} has local changes; leaving checkout unchanged: ${destination}" >&2
      return 2
    fi
    git -C "$destination" remote set-url origin "$repo" || return 1
    git -C "$destination" fetch origin "$branch" || return 1
    if ! git -C "$destination" checkout "$branch"; then
      git -C "$destination" checkout -B "$branch" "origin/$branch" || return 1
    fi
    git -C "$destination" pull --ff-only origin "$branch" || return 1
    echo "[skills] updated ${label}: ${destination}"
    return 0
  fi

  if [ -e "$destination" ]; then
    echo "[skills] ${label} destination exists but is not a git checkout: ${destination}" >&2
    return 2
  fi

  mkdir -p "$(dirname "$destination")"
  git clone --branch "$branch" "$repo" "$destination" || return 1
  echo "[skills] cloned ${label}: ${destination}"
}

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

chmod_shebang_scripts() {
  local root="$1"

  [ -d "$root" ] || return 0
  while IFS= read -r -d '' file; do
    if IFS= read -r first_line <"$file"; then
      case "$first_line" in
        '#!'*) chmod +x "$file" ;;
      esac
    fi
  done < <(find "$root" -type f -path "*/scripts/*" -print0)
}

mkdir -p "$HOME/.codex/skills" "$HOME/.agents/skills"

superpowers_ready=0
if clone_or_update "$SUPERPOWERS_REPO" "$HOME/.codex/superpowers" "main" "Superpowers repo"; then
  superpowers_ready=1
elif [ -d "$HOME/.codex/superpowers/skills" ]; then
  superpowers_ready=1
elif [ "$USE_VENDORED_FALLBACK" = "1" ]; then
  install_tree "$skills_root/superpowers" "$HOME/.codex/superpowers/skills" "vendored Superpowers fallback"
  superpowers_ready=1
else
  echo "[skills] Superpowers install failed and fallback is disabled" >&2
  exit 1
fi

install_tree "$skills_root/codex" "$HOME/.codex/skills" "Codex user/system skills"

if [ "$superpowers_ready" = "1" ] && { [ -L "$HOME/.agents/skills/superpowers" ] || [ ! -e "$HOME/.agents/skills/superpowers" ]; }; then
  rm -f "$HOME/.agents/skills/superpowers"
  ln -s "$HOME/.codex/superpowers/skills" "$HOME/.agents/skills/superpowers"
  echo "[skills] linked Superpowers skills -> ~/.agents/skills/superpowers"
else
  echo "[skills] ~/.agents/skills/superpowers exists and is not a symlink; leaving it unchanged" >&2
fi

install_tree "$skills_root/plugins/github" "$HOME/.agents/skills/plugin-github" "GitHub plugin skill fallback"
install_tree "$skills_root/plugins/google-drive" "$HOME/.agents/skills/plugin-google-drive" "Google Drive plugin skill fallback"

if ! clone_or_update "$OPENAI_SKILLS_REPO" "$HOME/.codex/vendor_imports/skills" "main" "OpenAI skills source mirror"; then
  echo "[skills] OpenAI skills source mirror was not refreshed; vendored Codex skills remain installed" >&2
fi

mkdir -p "$HOME/.codex/vendor_imports/repos"
for mirror in \
  "$CODEX_REPO|$HOME/.codex/vendor_imports/repos/codex|main|Codex source mirror" \
  "$PLAYWRIGHT_MCP_REPO|$HOME/.codex/vendor_imports/repos/playwright-mcp|main|Playwright MCP source mirror" \
  "$MCP_SERVERS_REPO|$HOME/.codex/vendor_imports/repos/servers|main|MCP servers source mirror" \
  "$BRAIN_SKILL_REPO|$HOME/.codex/vendor_imports/repos/brain-skill|main|Brain skill source mirror" \
  "$LLAMA_CPP_REPO|$HOME/.codex/vendor_imports/repos/llama.cpp|master|llama.cpp source mirror"; do
  IFS='|' read -r mirror_repo mirror_destination mirror_branch mirror_label <<<"$mirror"
  if ! clone_or_update "$mirror_repo" "$mirror_destination" "$mirror_branch" "$mirror_label"; then
    echo "[skills] ${mirror_label} was not refreshed; continuing with configured package install path" >&2
  fi
done

if [ -d "$HOME/.codex/vendor_imports/repos/brain-skill/skill" ]; then
  install_tree "$HOME/.codex/vendor_imports/repos/brain-skill/skill" "$HOME/.codex/skills/brain" "Brain skill from source mirror"
elif [ -d "$skills_root/codex/brain" ]; then
  install_tree "$skills_root/codex/brain" "$HOME/.codex/skills/brain" "vendored Brain skill fallback"
fi

chmod_shebang_scripts "$HOME/.codex/skills"
chmod_shebang_scripts "$HOME/.codex/superpowers/skills"
chmod_shebang_scripts "$HOME/.agents/skills"

total="$(find "$skills_root" -name SKILL.md | wc -l | tr -d ' ')"
echo "[skills] vendored skill inventory: ${total} skills"
