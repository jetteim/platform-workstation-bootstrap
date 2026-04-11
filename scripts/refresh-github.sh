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

fork_or_sync "obra/superpowers" "superpowers" "main"
fork_or_sync "openai/skills" "skills" "main"
fork_or_sync "openai/codex" "codex" "main"
fork_or_sync "microsoft/playwright-mcp" "playwright-mcp" "main"
fork_or_sync "modelcontextprotocol/servers" "servers" "main"

echo "[github] refresh complete"

