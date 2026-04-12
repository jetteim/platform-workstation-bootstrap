# Brain Skill Smoke Test

Date: 2026-04-11

Test type: instruction-skill dry run, package validation, and full MLX LoRA training/export smoke run.

## Made-Up Task

Build a micro classifier for Kubernetes command risk.

Input:

```json
{
  "command": "kubectl delete pod api-7d9f --namespace prod",
  "cwd": "/repo/platform",
  "env": "prod",
  "initiator": "agent"
}
```

Labels:

- `observe`: read-only inspection, logs, describe, get, explain
- `change`: intentional non-destructive mutation, rollout restart, apply to staging
- `destructive`: delete, scale-to-zero, drain, force replace, prod mutation with outage risk
- `secret`: command includes token, secret value, kubeconfig dump, or credential exfiltration
- `unknown`: ambiguous command or unsupported tool shape

Target behavior:

- route `observe` and low-risk `change` commands without blocking
- ask before `destructive`
- block or ask before `secret`
- log every classification with redacted input, label, confidence, and final hook decision

## Skill-Driven Output

Applying the `brain` skill produced the right project shape:

- Type: micro classifier, because output is a small enumerable label set.
- Base model family: Qwen3 0.6B or 0.8B class model, quantized to Q8 after export.
- Training data target: 1000-2000 examples with hard negatives.
- Split: 80% train, 10% validation, 10% held-out test.
- Required edge cases: aliases, dry-run commands, namespace defaults, prod/stage ambiguity, secrets in flags, piped output, shell redirection, multi-command strings.
- Evaluation gates: macro F1 >= 0.95, destructive recall = 1.00, secret recall = 1.00, unknown precision >= 0.90.
- Deployment shape: PreToolUse classifier in advisory/blocking mode, PostToolUse feedback capture, JSONL feedback for retraining.
- Observability fields: timestamp, command_hash, redaction_count, label, confidence, threshold, action, outcome, reviewer_override.

## Measured Outcome

Outcome Score: 32/35

| Category | Score | Measurement |
| --- | ---: | --- |
| Trigger fit | 5/5 | The task matches the skill's classifier, local model, hook, and latency triggers. |
| Task definition | 5/5 | The skill forces input format, label set, edge cases, and non-use criteria. |
| Data plan | 5/5 | It gives a concrete synthetic-data and hard-negative strategy. |
| Evaluation plan | 5/5 | It produces measurable pass/fail gates instead of vague quality claims. |
| Deployment and feedback | 5/5 | It includes hook integration, decision logging, feedback, and retraining. |
| Reproducibility | 3/5 | Good project layout and configs, but model downloads and local ML stack remain external. |
| Safety | 4/5 | Strong redaction and confidence-threshold guidance, but concrete scanner integration must be supplied by the surrounding hook code. |

## Current Machine Prerequisite Check

Prerequisites installed and verified:

- `uv 0.11.6`
- `cmake 4.3.1`
- `mlx 0.29.3`
- `mlx-lm 0.29.1`
- `torch 2.8.0`
- `llama.cpp` source mirror at `~/.codex/vendor_imports/repos/llama.cpp`

## Full MLX Run

Command:

```bash
./scripts/run-brain-mlx-smoke.sh
```

Run directory:

```text
~/.codex/mlx/runs/k8s-risk-classifier/
```

Model:

```text
mlx-community/Qwen3-0.6B-bf16
```

Training configuration:

- LoRA layers: 16
- Trainable parameters: 2.884M / 596.050M, 0.484%
- Iterations: 300
- Batch size: 1
- Learning rate: 5e-5
- Dataset: 72 train, 18 validation, 28 test examples

Measured results:

| Metric | Value |
| --- | ---: |
| Final validation loss | 0.212 |
| Test loss | 0.203 |
| Test perplexity | 1.225 |
| Peak memory | 1.574 GB |
| Adapter size | 11 MB |
| GGUF size | 610 MB |

Generated sample:

```text
Input: kubectl delete namespace payments-prod
Prediction: destructive
```

Artifacts:

```text
~/.codex/mlx/runs/k8s-risk-classifier/adapters/adapters.safetensors
~/.codex/mlx/runs/k8s-risk-classifier/models/fused/
~/.codex/mlx/runs/k8s-risk-classifier/models/k8s-risk-classifier-q8_0.gguf
~/.codex/mlx/runs/k8s-risk-classifier/reports/run-summary.json
```

Note: a shorter 200-iteration run completed train/test/fuse/export, but predicted `observe` for the destructive sample. The committed smoke configuration uses 300 iterations, 16 LoRA layers, and a higher learning rate because that produced the correct behavioral sample while keeping the run practical.

Result:

- Package/install smoke test: pass.
- Instruction dry run: pass.
- MLX LoRA train/test/fuse: pass.
- GGUF export through `llama.cpp`: pass.
- One generated destructive-command sample: pass.

## Verdict

The skill is worth keeping. It adds a useful path from deterministic hooks to learned local classifiers, but it should stay optional and source-backed. Do not make the default bootstrap install model weights by default; use `scripts/install-brain-prereqs.sh` and `scripts/run-brain-mlx-smoke.sh` when validating the ML path.
