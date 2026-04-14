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

validate_home_dir() {
  local name="$1"
  local path="$2"
  local default_path

  case "$path" in
    /*) ;;
    *)
      echo "[skills] ${name} must be an absolute path: ${path}" >&2
      exit 1
      ;;
  esac

  case "$name" in
    AGENTS_HOME) default_path="$HOME/.agents" ;;
    CODEX_HOME) default_path="$HOME/.codex" ;;
    CLAUDE_HOME) default_path="$HOME/.claude" ;;
    *)
      echo "[skills] unknown managed home variable: ${name}" >&2
      exit 1
      ;;
  esac

  case "$path" in
    "$default_path"|"$default_path"/*|/tmp/*|/var/folders/*) ;;
    *)
      echo "[skills] refusing unsafe ${name}: ${path}" >&2
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
      echo "[skills] refusing symlinked ${label}: ${current}" >&2
      exit 1
    fi
    current="$(dirname "$current")"
  done
}

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

clean_git_mirror() {
  local destination="$1"

  [ -d "$destination/.git" ] || return 1
  [ -z "$(git -C "$destination" status --porcelain)" ]
}

require_source_dir() {
  local source="$1"
  local label="$2"

  if [ ! -d "$source" ]; then
    echo "[skills] missing source for ${label}: ${source}" >&2
    exit 1
  fi
}

clear_destination() {
  local destination="$1"

  case "$destination" in
    ""|"/"|"$HOME"|"$AGENTS_HOME"|"$CODEX_HOME"|"$CLAUDE_HOME")
      echo "[skills] refusing to clear unsafe destination: ${destination}" >&2
      exit 1
      ;;
  esac

  reject_symlink_path "$destination" "managed destination"
  mkdir -p "$destination"
  reject_symlink_path "$destination" "managed destination"
  find "$destination" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
}

sync_tree() {
  local source="$1"
  local destination="$2"
  local label="$3"

  require_source_dir "$source" "$label"
  clear_destination "$destination"
  cp -R "$source/." "$destination/"
}

install_tree() {
  local source="$1"
  local destination="$2"
  local label="$3"

  sync_tree "$source" "$destination" "$label"
  local count
  count="$(find "$destination" -name SKILL.md | wc -l | tr -d ' ')"
  echo "[skills] installed ${label}: ${count} skills -> ${destination}"
}

stage_tree() {
  local source="$1"
  local destination="$2"
  local label="$3"

  sync_tree "$source" "$destination" "$label"
}

stage_skill_collection() {
  local source="$1"
  local destination="$2"
  local label="$3"
  local skill_dir

  require_source_dir "$source" "$label"
  mkdir -p "$destination"
  while IFS= read -r -d '' skill_dir; do
    stage_tree "$skill_dir" "$destination/$(basename "$skill_dir")" "$label $(basename "$skill_dir")"
  done < <(find "$source" -mindepth 1 -maxdepth 1 -type d -print0)
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

ARCHITECTURAL_SKILLS=(
  discovering-value-streams
  modeling-c4-architecture
  orchestrating-architecture-execution
  reviewing-traceability
  shaping-capabilities
  shaping-features
  slicing-stories
)

project_codex_skills() {
  stage_skill_collection "$canonical_skills_root/codex-curated" "$codex_skills_stage" "Codex curated/user skills"
  stage_skill_collection "$agent_skills_stage" "$codex_skills_stage" "Codex projection from canonical skills"
  stage_tree "$agent_skills_stage/superpowers" "$codex_skills_stage/superpowers" "Codex Superpowers projection"
  install_tree "$codex_skills_stage" "$CODEX_HOME/skills" "Codex skills"
}

validate_home_dir "AGENTS_HOME" "$AGENTS_HOME"
validate_home_dir "CODEX_HOME" "$CODEX_HOME"
validate_home_dir "CLAUDE_HOME" "$CLAUDE_HOME"
reject_symlink_path "$AGENTS_HOME" "AGENTS_HOME"
reject_symlink_path "$CODEX_HOME" "CODEX_HOME"
reject_symlink_path "$CLAUDE_HOME" "CLAUDE_HOME"

mkdir -p "$AGENTS_HOME/skills" "$AGENTS_HOME/vendor_imports/repos" "$CODEX_HOME/skills" "$CLAUDE_HOME/skills"
stage_root="$(mktemp -d "${TMPDIR:-/tmp}/platform-bootstrap-skills.XXXXXX")"
trap 'rm -rf "$stage_root"' EXIT
agent_skills_stage="$stage_root/agents-skills"
codex_skills_stage="$stage_root/codex-skills"
claude_skills_stage="$stage_root/claude-skills"
mkdir -p "$agent_skills_stage" "$codex_skills_stage" "$claude_skills_stage"

if command -v gh >/dev/null 2>&1; then
  gh auth setup-git >/dev/null 2>&1 || true
fi

prepare_canonical_destination "$AGENTS_HOME/skills/superpowers" "canonical Superpowers skills"
stage_tree "$canonical_skills_root/superpowers" "$agent_skills_stage/superpowers" "canonical Superpowers skills"
stage_tree "$canonical_skills_root/plugins/github" "$agent_skills_stage/plugin-github" "canonical GitHub plugin fallback skills"
stage_tree "$canonical_skills_root/plugins/google-drive" "$agent_skills_stage/plugin-google-drive" "canonical Google Drive plugin fallback skills"
stage_skill_collection "$canonical_skills_root/platform" "$agent_skills_stage" "canonical platform skills"

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

if [ "$superpowers_ready" = "1" ]; then
  echo "[skills] canonical Superpowers is installed as a real directory: $AGENTS_HOME/skills/superpowers"
fi

stage_tree "$skills_root/plugins/github" "$agent_skills_stage/plugin-github" "GitHub plugin skill fallback"
stage_tree "$skills_root/plugins/google-drive" "$agent_skills_stage/plugin-google-drive" "Google Drive plugin skill fallback"

if ! clone_or_update "$OPENAI_SKILLS_REPO" "$AGENTS_HOME/vendor_imports/skills" "main" "OpenAI skills source mirror"; then
  echo "[skills] OpenAI skills source mirror was not refreshed; vendored Codex skills remain installed" >&2
fi

mkdir -p "$AGENTS_HOME/vendor_imports/repos"
for mirror in \
  "$CODEX_REPO|$AGENTS_HOME/vendor_imports/repos/codex|main|Codex source mirror" \
  "$PLAYWRIGHT_MCP_REPO|$AGENTS_HOME/vendor_imports/repos/playwright-mcp|main|Playwright MCP source mirror" \
  "$MCP_SERVERS_REPO|$AGENTS_HOME/vendor_imports/repos/servers|main|MCP servers source mirror" \
  "$BRAIN_SKILL_REPO|$AGENTS_HOME/vendor_imports/repos/brain-skill|main|Brain skill source mirror" \
  "$LLAMA_CPP_REPO|$AGENTS_HOME/vendor_imports/repos/llama.cpp|master|llama.cpp source mirror" \
  "$PLATFORM_OBSERVABILITY_MODEL_REPO|$AGENTS_HOME/vendor_imports/repos/platform-observability-model|main|Platform observability model source mirror" \
  "$OBSERVABILITY_ENGINEERING_REPO|$AGENTS_HOME/vendor_imports/repos/observability-engineering|main|Observability engineering skill source mirror" \
  "$PLATFORM_RELIABILITY_MODEL_REPO|$AGENTS_HOME/vendor_imports/repos/platform-reliability-model|main|Platform reliability model source mirror" \
  "$RELIABILITY_ENGINEERING_REPO|$AGENTS_HOME/vendor_imports/repos/reliability-engineering|main|Reliability engineering skill source mirror" \
  "$ARCHITECTURAL_EXECUTION_SKILLS_REPO|$AGENTS_HOME/vendor_imports/repos/architectural-execution-skills|main|Architectural execution skills source mirror"; do
  IFS='|' read -r mirror_repo mirror_destination mirror_branch mirror_label <<<"$mirror"
  if ! clone_or_update "$mirror_repo" "$mirror_destination" "$mirror_branch" "$mirror_label"; then
    echo "[skills] ${mirror_label} was not refreshed; continuing with configured package install path" >&2
  fi
done

if clean_git_mirror "$AGENTS_HOME/vendor_imports/repos/brain-skill" &&
  [ -d "$AGENTS_HOME/vendor_imports/repos/brain-skill/skill" ]; then
  stage_tree "$AGENTS_HOME/vendor_imports/repos/brain-skill/skill" "$agent_skills_stage/brain" "Brain skill from source mirror"
elif [ -d "$canonical_skills_root/platform/brain" ]; then
  stage_tree "$canonical_skills_root/platform/brain" "$agent_skills_stage/brain" "vendored Brain skill fallback"
fi

if clean_git_mirror "$AGENTS_HOME/vendor_imports/repos/observability-engineering" &&
  [ -d "$AGENTS_HOME/vendor_imports/repos/observability-engineering/skill/observability-engineering" ]; then
  stage_tree "$AGENTS_HOME/vendor_imports/repos/observability-engineering/skill/observability-engineering" "$agent_skills_stage/observability-engineering" "Observability engineering skill from source mirror"
elif [ -d "$canonical_skills_root/platform/observability-engineering" ]; then
  stage_tree "$canonical_skills_root/platform/observability-engineering" "$agent_skills_stage/observability-engineering" "vendored Observability engineering skill fallback"
fi

if clean_git_mirror "$AGENTS_HOME/vendor_imports/repos/reliability-engineering" &&
  [ -d "$AGENTS_HOME/vendor_imports/repos/reliability-engineering/skill/reliability-engineering" ]; then
  stage_tree "$AGENTS_HOME/vendor_imports/repos/reliability-engineering/skill/reliability-engineering" "$agent_skills_stage/reliability-engineering" "Reliability engineering skill from source mirror"
elif [ -d "$canonical_skills_root/platform/reliability-engineering" ]; then
  stage_tree "$canonical_skills_root/platform/reliability-engineering" "$agent_skills_stage/reliability-engineering" "vendored Reliability engineering skill fallback"
fi

if clean_git_mirror "$AGENTS_HOME/vendor_imports/repos/architectural-execution-skills" &&
  [ -d "$AGENTS_HOME/vendor_imports/repos/architectural-execution-skills/skills" ]; then
  stage_skill_collection "$AGENTS_HOME/vendor_imports/repos/architectural-execution-skills/skills" "$agent_skills_stage" "Architectural execution skills from source mirror"
else
  for architectural_skill in "${ARCHITECTURAL_SKILLS[@]}"; do
    if [ -d "$canonical_skills_root/platform/$architectural_skill" ]; then
      stage_tree "$canonical_skills_root/platform/$architectural_skill" "$agent_skills_stage/$architectural_skill" "vendored ${architectural_skill} skill fallback"
    fi
  done
fi

install_tree "$agent_skills_stage" "$AGENTS_HOME/skills" "canonical agent skills"
project_codex_skills
stage_skill_collection "$agent_skills_stage" "$claude_skills_stage" "Claude skill projection from canonical skills"
install_tree "$claude_skills_stage" "$CLAUDE_HOME/skills" "Claude skills"

chmod_shebang_scripts "$CODEX_HOME/skills"
chmod_shebang_scripts "$CODEX_HOME/superpowers/skills"
chmod_shebang_scripts "$AGENTS_HOME/skills"

total="$(find "$skills_root" -name SKILL.md | wc -l | tr -d ' ')"
echo "[skills] vendored skill inventory: ${total} skills"
