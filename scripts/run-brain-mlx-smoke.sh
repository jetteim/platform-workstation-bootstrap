#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
venv_path="${BRAIN_MLX_VENV:-$CODEX_HOME/mlx/brain-venv}"
run_root="${BRAIN_MLX_RUN_ROOT:-$CODEX_HOME/mlx/runs/k8s-risk-classifier}"
model="${BRAIN_MLX_MODEL:-mlx-community/Qwen3-0.6B-bf16}"
iters="${BRAIN_MLX_ITERS:-300}"
llama_cpp_path="${LLAMA_CPP_PATH:-$AGENTS_HOME/vendor_imports/repos/llama.cpp}"

python_bin="$venv_path/bin/python"

if [ ! -x "$python_bin" ]; then
  echo "[brain-mlx] missing MLX venv: $venv_path" >&2
  echo "[brain-mlx] run scripts/install-brain-prereqs.sh first" >&2
  exit 1
fi

mkdir -p "$run_root/data" "$run_root/models" "$run_root/reports"

"$python_bin" - "$run_root" <<'PY'
from pathlib import Path
import json
import random
import sys

root = Path(sys.argv[1])
data = root / "data"
data.mkdir(parents=True, exist_ok=True)

system = (
    "Classify a Kubernetes or shell command for platform safety. "
    "Return exactly one label: observe, change, destructive, secret, unknown."
)

examples = [
    ("kubectl get pods -n prod", "observe"),
    ("kubectl describe deployment api -n prod", "observe"),
    ("kubectl logs deployment/api -n prod --tail=100", "observe"),
    ("kubectl top pods -n payments", "observe"),
    ("kubectl explain deployment.spec.strategy", "observe"),
    ("helm status billing -n prod", "observe"),
    ("kubectl rollout status deployment/api -n prod", "observe"),
    ("kubectl auth can-i delete pods -n prod", "observe"),
    ("kubectl apply -f deployment.yaml -n staging", "change"),
    ("kubectl rollout restart deployment/api -n staging", "change"),
    ("kubectl scale deployment worker --replicas=3 -n staging", "change"),
    ("helm upgrade billing ./chart -n staging", "change"),
    ("kubectl annotate deployment api owner=platform -n staging", "change"),
    ("kubectl patch deployment api -n staging --type merge -p '{\"spec\":{\"replicas\":4}}'", "change"),
    ("kubectl label namespace staging owner=platform", "change"),
    ("kubectl create configmap app-config --from-file=config.yaml -n staging", "change"),
    ("kubectl delete pod api-7d9f --namespace prod", "destructive"),
    ("kubectl delete namespace payments-prod", "destructive"),
    ("kubectl scale deployment api --replicas=0 -n prod", "destructive"),
    ("kubectl drain node ip-10-0-1-5 --ignore-daemonsets", "destructive"),
    ("kubectl replace --force -f deployment.yaml -n prod", "destructive"),
    ("helm uninstall billing -n prod", "destructive"),
    ("kubectl delete pvc data-postgres-0 -n prod", "destructive"),
    ("kubectl rollout undo deployment/api -n prod", "destructive"),
    ("kubectl create secret generic app --from-literal=token=abcd1234abcd1234", "secret"),
    ("kubectl get secret db-password -o yaml", "secret"),
    ("cat ~/.kube/config | pbcopy", "secret"),
    ("echo AWS_SECRET_ACCESS_KEY=abcd1234abcd1234", "secret"),
    ("kubectl describe secret prod-api-token -n prod", "secret"),
    ("printenv GITHUB_TOKEN", "secret"),
    ("cat .env.production", "secret"),
    ("curl -H 'Authorization: Bearer abcd1234abcd1234' https://example.invalid", "secret"),
    ("terraform plan", "unknown"),
    ("make deploy", "unknown"),
    ("python cleanup.py --env prod", "unknown"),
    ("kubectl do the safe thing", "unknown"),
    ("restart prod maybe", "unknown"),
    ("helm magic billing", "unknown"),
    ("kubectl something something", "unknown"),
    ("", "unknown"),
]

augmented = []
for command, label in examples:
    augmented.append((command, label))
    if command:
        augmented.append((f"sudo {command}", label if label in {"secret", "destructive"} else "unknown"))
        augmented.append((f"{command} --dry-run=server", "observe" if label in {"change", "destructive"} else label))

random.seed(42)
random.shuffle(augmented)

def record(command: str, label: str) -> dict:
    return {
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": command},
            {"role": "assistant", "content": f"<think>\n\n</think>\n\n{label}"},
        ]
    }

records = [record(command, label) for command, label in augmented]
splits = {
    "train": records[:72],
    "valid": records[72:90],
    "test": records[90:],
}
for name, rows in splits.items():
    with (data / f"{name}.jsonl").open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=True) + "\n")

summary = {
    "task": "kubernetes command risk micro-classifier",
    "labels": ["observe", "change", "destructive", "secret", "unknown"],
    "records": {name: len(rows) for name, rows in splits.items()},
}
(root / "reports" / "dataset-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
print(json.dumps(summary, indent=2))
PY

cat >"$run_root/lora_config.yaml" <<YAML
model: "$model"
train: true
data: "$run_root/data"
fine_tune_type: lora
num_layers: 16
batch_size: 1
iters: $iters
learning_rate: 5e-5
steps_per_report: 10
steps_per_eval: 20
val_batches: -1
test_batches: -1
max_seq_length: 256
adapter_path: "$run_root/adapters"
seed: 42
YAML

echo "[brain-mlx] training model=$model iters=$iters"
"$python_bin" -m mlx_lm lora --config "$run_root/lora_config.yaml" --train --test 2>&1 | tee "$run_root/reports/train.log"

echo "[brain-mlx] fuse adapter"
"$python_bin" -m mlx_lm fuse \
  --model "$model" \
  --adapter-path "$run_root/adapters" \
  --save-path "$run_root/models/fused" 2>&1 | tee "$run_root/reports/fuse.log"

echo "[brain-mlx] export gguf"
if [ ! -f "$llama_cpp_path/convert_hf_to_gguf.py" ]; then
  echo "[brain-mlx] missing llama.cpp converter: $llama_cpp_path/convert_hf_to_gguf.py" >&2
  exit 1
fi
"$python_bin" "$llama_cpp_path/convert_hf_to_gguf.py" \
  "$run_root/models/fused" \
  --outfile "$run_root/models/k8s-risk-classifier-q8_0.gguf" \
  --outtype q8_0 2>&1 | tee "$run_root/reports/export-gguf.log"

echo "[brain-mlx] sample inference"
"$python_bin" -m mlx_lm generate \
  --model "$model" \
  --adapter-path "$run_root/adapters" \
  --system-prompt "Classify a Kubernetes or shell command for platform safety. Return exactly one label: observe, change, destructive, secret, unknown." \
  --prompt "kubectl delete namespace payments-prod" \
  --max-tokens 8 \
  --temp 0 \
  --chat-template-config '{"enable_thinking": false}' \
  --verbose False | tee "$run_root/reports/sample-prediction.txt"

"$python_bin" - "$run_root" <<'PY'
from pathlib import Path
import json
import re
import sys

root = Path(sys.argv[1])
train_log = (root / "reports" / "train.log").read_text(encoding="utf-8", errors="replace")
test_losses = [float(value) for value in re.findall(r"Test loss ([0-9.]+)", train_log)]
val_losses = [float(value) for value in re.findall(r"Val loss ([0-9.]+)", train_log)]
summary = {
    "train_log_present": bool(train_log.strip()),
    "final_validation_loss": val_losses[-1] if val_losses else None,
    "test_loss": test_losses[-1] if test_losses else None,
    "adapter_exists": (root / "adapters" / "adapters.safetensors").exists(),
    "fused_model_files": sorted(p.name for p in (root / "models" / "fused").glob("*")) if (root / "models" / "fused").exists() else [],
    "gguf_exists": (root / "models" / "k8s-risk-classifier-q8_0.gguf").exists(),
    "sample_prediction": (root / "reports" / "sample-prediction.txt").read_text(encoding="utf-8", errors="replace").strip(),
}
(root / "reports" / "run-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
print(json.dumps(summary, indent=2))
if not summary["adapter_exists"] or not summary["gguf_exists"]:
    raise SystemExit(1)
PY

echo "[brain-mlx] reports: $run_root/reports"
