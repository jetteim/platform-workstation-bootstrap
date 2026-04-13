#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_root="$repo_root/skills"
agents_root="$repo_root/agents"
canonical_skills_root="$agents_root/skills"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
# Canonical skills install under ~/.agents/skills; ~/.agents/vendor_imports is reserved for mirror migration.

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
PLATFORM_OBSERVABILITY_MODEL_REPO="${PLATFORM_OBSERVABILITY_MODEL_REPO:-https://github.com/jetteim/platform-observability-model.git}"
OBSERVABILITY_ENGINEERING_REPO="${OBSERVABILITY_ENGINEERING_REPO:-https://github.com/jetteim/observability-engineering.git}"
PLATFORM_RELIABILITY_MODEL_REPO="${PLATFORM_RELIABILITY_MODEL_REPO:-https://github.com/jetteim/platform-reliability-model.git}"
RELIABILITY_ENGINEERING_REPO="${RELIABILITY_ENGINEERING_REPO:-https://github.com/jetteim/reliability-engineering.git}"
ARCHITECTURAL_EXECUTION_SKILLS_REPO="${ARCHITECTURAL_EXECUTION_SKILLS_REPO:-https://github.com/jetteim/architectural-execution-skills.git}"
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

prepare_canonical_destination() {
  local destination="$1"
  local label="$2"

  if [ -L "$destination" ]; then
    rm "$destination"
    echo "[skills] replaced legacy symlink for ${label}: ${destination}"
  fi
}

install_canonical_tree() {
  local source="$1"
  local destination="$2"
  local label="$3"

  prepare_canonical_destination "$destination" "$label"
  install_tree "$source" "$destination" "$label"
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

mkdir -p "$AGENTS_HOME/skills" "$AGENTS_HOME/vendor_imports/repos" "$CODEX_HOME/skills" "$CLAUDE_HOME/skills"

if command -v gh >/dev/null 2>&1; then
  gh auth setup-git >/dev/null 2>&1 || true
fi

install_canonical_tree "$canonical_skills_root/superpowers" "$AGENTS_HOME/skills/superpowers" "canonical Superpowers skills"
install_canonical_tree "$canonical_skills_root/plugins/github" "$AGENTS_HOME/skills/plugin-github" "canonical GitHub plugin fallback skills"
install_canonical_tree "$canonical_skills_root/plugins/google-drive" "$AGENTS_HOME/skills/plugin-google-drive" "canonical Google Drive plugin fallback skills"
install_canonical_tree "$canonical_skills_root/platform" "$AGENTS_HOME/skills" "canonical platform skills"

superpowers_ready=0
if clone_or_update "$SUPERPOWERS_REPO" "$CODEX_HOME/superpowers" "main" "Superpowers repo"; then
  superpowers_ready=1
elif [ -d "$CODEX_HOME/superpowers/skills" ]; then
  superpowers_ready=1
elif [ "$USE_VENDORED_FALLBACK" = "1" ]; then
  install_tree "$skills_root/superpowers" "$CODEX_HOME/superpowers/skills" "vendored Superpowers fallback"
  superpowers_ready=1
else
  echo "[skills] Superpowers install failed and fallback is disabled" >&2
  exit 1
fi

install_tree "$canonical_skills_root/codex-curated" "$CODEX_HOME/skills" "Codex curated/user skills"
install_tree "$AGENTS_HOME/skills" "$CODEX_HOME/skills" "Codex projection from canonical skills"

if [ "$superpowers_ready" = "1" ] && { [ -L "$AGENTS_HOME/skills/superpowers" ] || [ ! -e "$AGENTS_HOME/skills/superpowers" ]; }; then
  rm -f "$AGENTS_HOME/skills/superpowers"
  ln -s "$CODEX_HOME/superpowers/skills" "$AGENTS_HOME/skills/superpowers"
  echo "[skills] linked Superpowers skills -> $AGENTS_HOME/skills/superpowers"
elif [ "$superpowers_ready" = "1" ]; then
  echo "[skills] $AGENTS_HOME/skills/superpowers exists and is not a symlink; leaving it unchanged" >&2
fi

install_tree "$AGENTS_HOME/skills/superpowers" "$CODEX_HOME/skills/superpowers" "Codex Superpowers projection"

install_tree "$skills_root/plugins/github" "$AGENTS_HOME/skills/plugin-github" "GitHub plugin skill fallback"
install_tree "$skills_root/plugins/google-drive" "$AGENTS_HOME/skills/plugin-google-drive" "Google Drive plugin skill fallback"

if ! clone_or_update "$OPENAI_SKILLS_REPO" "$CODEX_HOME/vendor_imports/skills" "main" "OpenAI skills source mirror"; then
  echo "[skills] OpenAI skills source mirror was not refreshed; vendored Codex skills remain installed" >&2
fi

mkdir -p "$CODEX_HOME/vendor_imports/repos"
for mirror in \
  "$CODEX_REPO|$CODEX_HOME/vendor_imports/repos/codex|main|Codex source mirror" \
  "$PLAYWRIGHT_MCP_REPO|$CODEX_HOME/vendor_imports/repos/playwright-mcp|main|Playwright MCP source mirror" \
  "$MCP_SERVERS_REPO|$CODEX_HOME/vendor_imports/repos/servers|main|MCP servers source mirror" \
  "$BRAIN_SKILL_REPO|$CODEX_HOME/vendor_imports/repos/brain-skill|main|Brain skill source mirror" \
  "$LLAMA_CPP_REPO|$CODEX_HOME/vendor_imports/repos/llama.cpp|master|llama.cpp source mirror" \
  "$PLATFORM_OBSERVABILITY_MODEL_REPO|$CODEX_HOME/vendor_imports/repos/platform-observability-model|main|Platform observability model source mirror" \
  "$OBSERVABILITY_ENGINEERING_REPO|$CODEX_HOME/vendor_imports/repos/observability-engineering|main|Observability engineering skill source mirror" \
  "$PLATFORM_RELIABILITY_MODEL_REPO|$CODEX_HOME/vendor_imports/repos/platform-reliability-model|main|Platform reliability model source mirror" \
  "$RELIABILITY_ENGINEERING_REPO|$CODEX_HOME/vendor_imports/repos/reliability-engineering|main|Reliability engineering skill source mirror" \
  "$ARCHITECTURAL_EXECUTION_SKILLS_REPO|$CODEX_HOME/vendor_imports/repos/architectural-execution-skills|main|Architectural execution skills source mirror"; do
  IFS='|' read -r mirror_repo mirror_destination mirror_branch mirror_label <<<"$mirror"
  if ! clone_or_update "$mirror_repo" "$mirror_destination" "$mirror_branch" "$mirror_label"; then
    echo "[skills] ${mirror_label} was not refreshed; continuing with configured package install path" >&2
  fi
done

if [ -d "$CODEX_HOME/vendor_imports/repos/brain-skill/skill" ]; then
  install_tree "$CODEX_HOME/vendor_imports/repos/brain-skill/skill" "$CODEX_HOME/skills/brain" "Brain skill from source mirror"
elif [ -d "$skills_root/codex/brain" ]; then
  install_tree "$skills_root/codex/brain" "$CODEX_HOME/skills/brain" "vendored Brain skill fallback"
fi

if [ -d "$CODEX_HOME/vendor_imports/repos/observability-engineering/skill/observability-engineering" ]; then
  install_tree "$CODEX_HOME/vendor_imports/repos/observability-engineering/skill/observability-engineering" "$CODEX_HOME/skills/observability-engineering" "Observability engineering skill from source mirror"
elif [ -d "$skills_root/codex/observability-engineering" ]; then
  install_tree "$skills_root/codex/observability-engineering" "$CODEX_HOME/skills/observability-engineering" "vendored Observability engineering skill fallback"
fi

if [ -d "$CODEX_HOME/vendor_imports/repos/reliability-engineering/skill/reliability-engineering" ]; then
  install_tree "$CODEX_HOME/vendor_imports/repos/reliability-engineering/skill/reliability-engineering" "$CODEX_HOME/skills/reliability-engineering" "Reliability engineering skill from source mirror"
elif [ -d "$skills_root/codex/reliability-engineering" ]; then
  install_tree "$skills_root/codex/reliability-engineering" "$CODEX_HOME/skills/reliability-engineering" "vendored Reliability engineering skill fallback"
fi

if [ -d "$CODEX_HOME/vendor_imports/repos/architectural-execution-skills/skills" ]; then
  install_tree "$CODEX_HOME/vendor_imports/repos/architectural-execution-skills/skills" "$CODEX_HOME/skills" "Architectural execution skills from source mirror"
else
  for architectural_skill in \
    discovering-value-streams \
    modeling-c4-architecture \
    orchestrating-architecture-execution \
    reviewing-traceability \
    shaping-capabilities \
    shaping-features \
    slicing-stories; do
    if [ -d "$skills_root/codex/$architectural_skill" ]; then
      install_tree "$skills_root/codex/$architectural_skill" "$CODEX_HOME/skills/$architectural_skill" "vendored ${architectural_skill} skill fallback"
    fi
  done
fi

chmod_shebang_scripts "$CODEX_HOME/skills"
chmod_shebang_scripts "$CODEX_HOME/superpowers/skills"
chmod_shebang_scripts "$AGENTS_HOME/skills"

total="$(find "$skills_root" -name SKILL.md | wc -l | tr -d ' ')"
echo "[skills] vendored skill inventory: ${total} skills"
