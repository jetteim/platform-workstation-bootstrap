#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
venv_path="${BRAIN_MLX_VENV:-$CODEX_HOME/mlx/brain-venv}"
llama_repo="${LLAMA_CPP_REPO:-https://github.com/jetteim/llama.cpp.git}"
llama_path="${LLAMA_CPP_PATH:-$AGENTS_HOME/vendor_imports/repos/llama.cpp}"

if ! command -v brew >/dev/null 2>&1; then
  echo "[brain-prereqs] Homebrew is required to install uv and cmake" >&2
  exit 1
fi

brew install uv cmake

mkdir -p "$(dirname "$venv_path")" "$(dirname "$llama_path")"
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
  git clone "$llama_repo" "$llama_path"
  echo "[brain-prereqs] cloned llama.cpp source mirror: $llama_path"
fi

"$venv_path/bin/python" - <<'PY'
import mlx.core as mx
print("[brain-prereqs] mlx device:", mx.default_device())
PY

echo "[brain-prereqs] ready: $venv_path"
