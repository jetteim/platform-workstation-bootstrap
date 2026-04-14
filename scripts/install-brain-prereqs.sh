#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
validate_home_dir() {
  local name="$1"
  local path
  local default_path

  path="$(python3 -c 'import os, sys; print(os.path.abspath(os.path.expanduser(sys.argv[1])))' "$2")"

  case "$path" in
    /*) ;;
    *)
      echo "[brain-prereqs] ${name} must be an absolute path: ${path}" >&2
      exit 1
      ;;
  esac

  case "$name" in
    AGENTS_HOME) default_path="$(python3 -c 'import os, sys; print(os.path.abspath(sys.argv[1]))' "$HOME/.agents")" ;;
    CODEX_HOME) default_path="$(python3 -c 'import os, sys; print(os.path.abspath(sys.argv[1]))' "$HOME/.codex")" ;;
    *)
      echo "[brain-prereqs] unknown managed home variable: ${name}" >&2
      exit 1
      ;;
  esac

  case "$path" in
    "$default_path"|"$default_path"/*|/tmp/*|/var/folders/*) ;;
    *)
      echo "[brain-prereqs] refusing unsafe ${name}: ${path}" >&2
      exit 1
      ;;
  esac

  echo "$path"
}

reject_symlink_path() {
  local path="$1"
  local label="$2"
  local current="$path"

  while [ "$current" != "/" ] && [ "$current" != "$HOME" ] && [ "$current" != "/tmp" ] && [ "$current" != "/var/folders" ]; do
    if [ -L "$current" ]; then
      echo "[brain-prereqs] refusing symlinked ${label}: ${current}" >&2
      exit 1
    fi
    current="$(dirname "$current")"
  done
}

ensure_directory() {
  local destination="$1"
  local label="$2"

  reject_symlink_path "$destination" "$label"
  mkdir -p "$destination"
  reject_symlink_path "$destination" "$label"
}

CODEX_HOME="$(validate_home_dir "CODEX_HOME" "$CODEX_HOME")"
AGENTS_HOME="$(validate_home_dir "AGENTS_HOME" "$AGENTS_HOME")"
reject_symlink_path "$CODEX_HOME" "CODEX_HOME"
reject_symlink_path "$AGENTS_HOME" "AGENTS_HOME"

venv_path="${BRAIN_MLX_VENV:-$CODEX_HOME/mlx/brain-venv}"
llama_repo="${LLAMA_CPP_REPO:-https://github.com/jetteim/llama.cpp.git}"
llama_path="${LLAMA_CPP_PATH:-$AGENTS_HOME/vendor_imports/repos/llama.cpp}"
reject_symlink_path "$venv_path" "MLX venv path"
reject_symlink_path "$llama_path" "llama.cpp path"

if ! command -v brew >/dev/null 2>&1; then
  echo "[brain-prereqs] Homebrew is required to install uv and cmake" >&2
  exit 1
fi

brew install uv cmake

ensure_directory "$(dirname "$venv_path")" "MLX venv parent"
ensure_directory "$(dirname "$llama_path")" "llama.cpp parent"
if [ -x "$venv_path/bin/python" ]; then
  echo "[brain-prereqs] using existing venv: $venv_path"
else
  uv venv "$venv_path"
fi
uv pip install --python "$venv_path/bin/python" \
  mlx-lm \
  pyyaml \
  numpy \
  huggingface_hub \
  safetensors \
  transformers \
  torch \
  sentencepiece \
  protobuf

if [ -d "$llama_path/.git" ]; then
  reject_symlink_path "$llama_path" "llama.cpp path"
  if [ -n "$(git -C "$llama_path" status --porcelain)" ]; then
    echo "[brain-prereqs] llama.cpp has local changes; leaving checkout unchanged: $llama_path" >&2
  else
    git -C "$llama_path" remote set-url origin "$llama_repo"
    git -C "$llama_path" fetch origin master
    git -C "$llama_path" checkout master
    git -C "$llama_path" pull --ff-only origin master
    echo "[brain-prereqs] updated llama.cpp source mirror: $llama_path"
  fi
elif [ -e "$llama_path" ]; then
  echo "[brain-prereqs] llama.cpp path exists but is not a git checkout: $llama_path" >&2
  exit 1
else
  reject_symlink_path "$llama_path" "llama.cpp destination"
  git clone "$llama_repo" "$llama_path"
  echo "[brain-prereqs] cloned llama.cpp source mirror: $llama_path"
fi

"$venv_path/bin/python" - <<'PY'
import mlx.core as mx
print("[brain-prereqs] mlx device:", mx.default_device())
PY

echo "[brain-prereqs] ready: $venv_path"
