# Installability Audit - 2026-04-12

This audit checks whether the bootstrap repository can refresh its external dependencies, install its user-wide assets, install the optional Brain/MLX path, and verify the full local-model workflow on the current workstation.

## Result

Status: pass.

The default bootstrap path is installable. The optional Brain/MLX prerequisites are installable. Vendored source mirrors were refreshed. A full MLX LoRA training run completed, fused, exported to GGUF, and produced the expected sample classification.

## Commands Run

| Area | Command | Result |
| --- | --- | --- |
| Repository freshness | `git pull --ff-only` | Passed; repository was already up to date before local audit edits. |
| GitHub authentication | `gh auth refresh -h github.com -s workflow` | Passed; needed because the Codex fork sync includes workflow files. |
| Fork and mirror refresh | `./scripts/refresh-github.sh` | Passed after GitHub auth refresh. Forks/syncs include OpenAI skills, Codex, Playwright MCP, MCP servers, Brain skill, and llama.cpp. Superpowers is now a Codex plugin, not a forked install source. |
| Default install | `SKIP_GITHUB_REFRESH=1 ./scripts/install.sh` | Passed; refreshed local mirrors, installed vendored skills, Codex config, hooks, and symlinks. |
| Brain prerequisites | `./scripts/install-brain-prereqs.sh` | Passed; installed or reused Homebrew packages, MLX virtualenv packages, and the llama.cpp source mirror. |
| Brain skill package checks | `./scripts/test-brain-skill.sh` | Passed; found the Brain skill, MLX virtualenv, MLX packages, and llama.cpp checkout. |
| Full Brain/MLX training | `./scripts/run-brain-mlx-smoke.sh` | Passed; details below. |
| Repository verification | `./scripts/verify.sh` | Passed. |
| Workstation audit | `./scripts/audit.sh` | Passed in unrestricted context; GitHub auth is valid with `repo` and `workflow` scopes. |

## Refreshed Source Mirrors

| Dependency | Fork | Local mirror | Commit checked |
| --- | --- | --- | --- |
| OpenAI skills | `jetteim/skills` | `~/.codex/vendor_imports/skills` | `0ed2046f287a92b5f4bcace213dcb3cc5f094cb9` |
| Codex | `jetteim/codex` | `~/.codex/vendor_imports/repos/codex` | `3895ddd6b1caf80cd77d6fd44e3ce55bd290ef18` |
| Playwright MCP | `jetteim/playwright-mcp` | `~/.codex/vendor_imports/repos/playwright-mcp` | `d3782155c40aabc3945673998bdbae83cb0dc94c` |
| MCP servers | `jetteim/servers` | `~/.codex/vendor_imports/repos/modelcontextprotocol-servers` | `f4244583a6af9425633e433a3eec000d23f4e011` |
| Brain skill | `jetteim/brain-skill` | `~/.codex/vendor_imports/repos/brain-skill` | `73789527637114b2a3745b2da9afa64fa8c1b7fa` |
| llama.cpp | `jetteim/llama.cpp` | `~/.codex/vendor_imports/repos/llama.cpp` | `ff5ef8278615a2462b79b50abdf3cc95cfb31c6f` |

## Brain/MLX Prerequisites

The Brain heavy path now has a dedicated installer:

```bash
./scripts/install-brain-prereqs.sh
```

It installs or reuses:

- Homebrew packages: `uv`, `cmake`
- Python virtualenv: `${CODEX_HOME:-~/.codex}/mlx/brain-venv`
- Python packages: `mlx-lm`, `pyyaml`, `numpy`, `huggingface_hub`, `safetensors`, `transformers`, `sentencepiece`, `protobuf`, `torch`
- GGUF converter source mirror: `~/.codex/vendor_imports/repos/llama.cpp`

The MLX import check reported the Apple GPU device through the Brain virtualenv.

## Full MLX Training Run

Command:

```bash
./scripts/run-brain-mlx-smoke.sh
```

Run directory:

```text
~/.codex/mlx/runs/k8s-risk-classifier
```

Training configuration:

- Base model: `mlx-community/Qwen3-0.6B-bf16`
- Task: Kubernetes command risk classifier
- Labels: `observe`, `change`, `destructive`, `secret`, `unknown`
- Dataset: 72 train records, 18 validation records, 28 test records
- LoRA layers: 16
- Iterations: 300
- Learning rate: `5e-5`
- Trainable parameters: 2.884M / 596.050M, or 0.484%

Observed results:

- Final validation loss: `0.212`
- Test loss: `0.203`
- Test perplexity: `1.225`
- Peak memory: `1.574 GB`
- Sample prompt: `kubectl delete namespace payments-prod`
- Sample prediction: `destructive`

Generated artifacts:

- Adapter: `~/.codex/mlx/runs/k8s-risk-classifier/adapters/adapters.safetensors`
- Fused model: `~/.codex/mlx/runs/k8s-risk-classifier/models/fused`
- GGUF export: `~/.codex/mlx/runs/k8s-risk-classifier/models/k8s-risk-classifier-q8_0.gguf`
- Summary: `~/.codex/mlx/runs/k8s-risk-classifier/reports/run-summary.json`

The script uses the llama.cpp converter for GGUF export because `mlx_lm fuse --export-gguf` did not support the selected Qwen3 architecture during this audit.

## Installability Notes

- The default installer intentionally does not run the heavy MLX path. It installs the Brain skill instructions, while `scripts/install-brain-prereqs.sh` installs model-training prerequisites.
- GitHub refresh needs the `workflow` OAuth scope because the Codex fork can sync GitHub Actions workflow files.
- `./scripts/audit.sh` should be run in the same unrestricted context as GitHub refresh when checking keychain-backed `gh` auth. A sandboxed audit can report a false invalid-token status because it cannot access the keychain normally.
- The full MLX run should be run outside restrictive sandboxing on this Mac. Sandboxed MLX import previously failed in Metal initialization; the unrestricted Brain virtualenv check passed.
- A non-fatal `urllib3` LibreSSL warning may appear from the macOS system Python. It did not block install or verification.
- The Kubernetes classifier is a pipeline smoke test, not a production-ready risk model.
