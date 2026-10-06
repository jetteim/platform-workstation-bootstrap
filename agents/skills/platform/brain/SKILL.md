---
name: brain
description: "Train and export dedicated local text classifiers or short-text generators with MLX LoRA on Apple Silicon. Use for local model training or GGUF deployment; ordinary classification questions do not require this skill."
---

# Brain — Dedicated Local Models

Use a dedicated local model when a bounded task, held-out data and measured latency/quality justify it. Preserve the user's selected model and deployment target. Ordinary classification questions do not require training.

1. Define task, labels/output contract, allowed inputs, baseline and acceptance criteria. Keep deterministic rules authoritative for safety decisions; model predictions are advisory unless a separately validated policy specifies otherwise.
2. Prepare authorized data with provenance, privacy boundaries and nonoverlapping train/validation/test splits. Synthetic examples are useful but do not establish real-world accuracy. Never log raw secrets, personal payloads or commands as training evidence.
3. Read [tested-recipe.md](references/tested-recipe.md) to distinguish the measured bootstrap smoke recipe from illustrative configs. For data/config/training/export read [mlx-pipeline.md](references/mlx-pipeline.md). Keep model and tokenizer consistent across all stages; derive chat templates and token IDs from the selected tokenizer.
4. Train only within the requested scope. Evaluate against the held-out task and deterministic baseline; report sample size, class errors, uncertainty, resource use and measured latency. Do not inherit accuracy or timings from reference tables.
5. Export only after evaluation. Read [rust-embedding.md](references/rust-embedding.md) for embedded deployment or [python-sidecar.md](references/python-sidecar.md) for a sidecar. Verify exported tokenizer/output parity and measure the target runtime before claims.
6. Use [deployment-examples.md](references/deployment-examples.md) only for hook integration. Maintain deterministic guardrails, calibrated fallbacks, evidence minimization and rollback. Training is not permission to replace live models or install hooks.

Missing dependencies should produce a precise setup gap or a dry-run plan; do not download models or retrain merely to validate this skill. Return requested artifacts, config provenance, actual measurements and limits.
