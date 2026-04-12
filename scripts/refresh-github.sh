#!/usr/bin/env bash
set -euo pipefail

owner="${GITHUB_OWNER:-jetteim}"

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

fork_or_sync() {
  local upstream="$1"
  local fork_name="$2"
  local branch="${3:-main}"
  local fork="${owner}/${fork_name}"

  echo "[github] refresh ${fork} from ${upstream}"
  gh repo view "$upstream" --json nameWithOwner,defaultBranchRef >/dev/null

  if gh repo view "$fork" --json nameWithOwner >/dev/null 2>&1; then
    gh repo sync "$fork" -b "$branch"
  else
    gh repo fork "$upstream" --clone=false
    gh repo sync "$fork" -b "$branch"
  fi
}

require gh
gh auth status
gh auth setup-git

fork_or_sync "obra/superpowers" "superpowers" "main"
fork_or_sync "openai/skills" "skills" "main"
fork_or_sync "openai/codex" "codex" "main"
fork_or_sync "microsoft/playwright-mcp" "playwright-mcp" "main"
fork_or_sync "modelcontextprotocol/servers" "servers" "main"
fork_or_sync "diana-random1st/brain-skill" "brain-skill" "main"
fork_or_sync "ggml-org/llama.cpp" "llama.cpp" "master"

ensure_owned_repo() {
  local name="$1"
  local visibility="$2"
  local description="$3"
  local repo="${owner}/${name}"

  echo "[github] ensure ${repo}"
  if gh repo view "$repo" --json nameWithOwner >/dev/null 2>&1; then
    return 0
  fi

  if [ "$visibility" = "private" ]; then
    gh repo create "$repo" --private --description "$description"
  else
    gh repo create "$repo" --public --description "$description"
  fi
}

ensure_owned_repo "platform-observability-model" "private" "Platform-agnostic observability intent model"
ensure_owned_repo "observability-engineering" "public" "Codex skill for platform-agnostic observability engineering"
ensure_owned_repo "platform-reliability-model" "private" "Platform-agnostic reliability intent model"
ensure_owned_repo "reliability-engineering" "public" "Codex skill for platform-agnostic reliability engineering"

echo "[github] refresh complete"
