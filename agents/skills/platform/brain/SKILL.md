---
name: brain
description: "Build dedicated local models — from tiny classifiers (micro) to text generators (medium). MLX LoRA fine-tune on Apple Silicon, GGUF export, deploy via Rust or Python sidecar. Triggers: 'brain', 'micro-brain', 'medium-brain', 'finetune', 'train a model', 'classifier', 'local generation', 'натренировать модель'."
---

# Brain — Dedicated Local Models

Build a local model fine-tuned for one task. From fast classifiers (micro) to short-text generators (medium). When a large model is overkill, too slow, or too expensive for production.

## When to Use

**Micro (classification):**
- Task needs precise, repeatable output — not creative generation
- Output space is small and enumerable (labels, scores, structured fields)
- Latency matters — embedded inference, hooks, real-time pipelines
- A large model gets it right but is too expensive/slow

Examples: command routing, intent classification, sentiment scoring, entity extraction, format validation, triage/priority assignment.

**Medium (generation):**
- Task requires text output (rewriting, correction, translation, paraphrasing)
- Output is short (1-100 tokens) — not essays, not long-form
- Latency budget: 200-600ms acceptable
- Must run locally, no API calls
- Training data can be generated as (input, output) pairs

Examples: STT text cleanup, grammar correction, filler removal, text normalization, short translation, formatting adaptation.

## When NOT to Use

- Output is long-form (>100 tokens) → use cloud LLM
- Task needs world knowledge or reasoning → use cloud LLM
- Zero training data available and can't generate synthetic → use cloud LLM
- Not for image generation, speech synthesis, or tasks where cloud LLM quality is critical.

## Pipeline Overview

```
1. DEFINE   Task spec + label set / input-output format + eval criteria
2. GENERATE Training data via large model (LM Studio / OpenRouter)
3. TRAIN    MLX LoRA fine-tune
4. EVAL     Accuracy / quality on held-out test set
5. EXPORT   GGUF quantization (Q8 or Q4)
6. DEPLOY   Embed in Rust binary (micro) or Python sidecar (medium)
```

See `references/mlx-pipeline.md` for full pipeline details, code templates, and GGUF export.

## Micro vs Medium

| Aspect | Micro | Medium |
|--------|-------|--------|
| Model | Qwen3.5-0.8B | Qwen3.5-2B to 4B |
| Task | Classification, routing, scoring | Text rewriting, translation, summarization |
| Training iters | 1000, batch 4 | 2000, batch 2 |
| LoRA rank | 16 | 32 |
| Training data | 1000-2000 examples | 2000-5000 examples |
| Output | Single token (greedy) | Multi-token generation |
| Eval target | Accuracy >95% | Exact match >60%, close >90% |
| Deploy | Rust embedding | Python sidecar |
| Latency | <10ms (after load) / ~560ms total | 50-200ms (after load) |
| GGUF size | 812 MB (Q8) | ~2 GB (Q8) |

## Quick Start

### Micro (classifier)

```bash
mkdir -p ~/src/<project>/{data,models,adapters}
# Generate data → see references/mlx-pipeline.md
uv run mlx_lm.lora --config lora_config.yaml   # lora_layers:16, rank:16, batch:4, iters:1000
uv run mlx_lm.fuse --model "Qwen/Qwen3.5-0.8B" --adapter-path adapters-qwen --save-path models/<name>-fused
python llama.cpp/convert_hf_to_gguf.py models/<name>-fused --outtype q8_0
cp models/<name>-fused/*.gguf ~/.diana/models/<name>.gguf
# Embed in Rust → see references/rust-embedding.md
```

### Medium (generator)

```bash
mkdir -p ~/src/<project>/{data,models,adapters}
# Generate data → see references/mlx-pipeline.md
uv run mlx_lm.lora --config lora_config.yaml   # lora_layers:24, rank:32, batch:2, iters:2000
uv run mlx_lm.fuse --model "Qwen/Qwen3-1.7B" --adapter-path adapters --save-path models/<name>-fused
python llama.cpp/convert_hf_to_gguf.py models/<name>-fused --outtype q8_0
cp models/<name>-fused/*.gguf ~/.diana/models/<name>.gguf
# Serve via Python sidecar → see references/python-sidecar.md
```

## Troubleshooting

**Model outputs `<think>` reasoning before answer:**
Ensure all training examples have `<think>\n\n</think>\n\n` prefix in assistant content. Without it, Qwen3 will reason before answering. Special tokens `<|im_start|>` (151644) / `<|im_end|>` (151645) must be raw token IDs in Rust.

**SIGABRT on process::exit() (Rust):**
Drop all llama resources (backend, model, ctx) before calling `process::exit()`. Use a scoped block. See `references/rust-embedding.md`.

**Metal errors on load:**
`ggml_metal_device_init: tensor API disabled` is normal on pre-M5. Inference still works.

**Training loss doesn't decrease:**
- Learning rate too low (try 5e-5) or too high (try 5e-6)
- Data format wrong: Qwen3 needs 3-message format (system + user + assistant) with `<think>` prefix in assistant content
- max_seq_length too short (truncating important content)

**High accuracy on train, low on test (micro):**
- Overfitting. Reduce iters, increase data diversity.
- Data leakage: check train/test split has no duplicates.

**Model hallucinates / adds content not in input (medium):**
- Add more identity examples (clean input → same clean output, ~15-20% of training data)
- Lower temperature to 0.0 for inference
- Add explicit "Do NOT add information" rule to system prompt

**Model truncates output (medium):**
- Increase `max_tokens` in generation
- Check `max_seq_length` in training config — must cover longest expected input+output

**Out of memory during training:**
- Enable `grad_checkpoint: true`
- Reduce `batch_size` to 1
- Reduce `max_seq_length` if inputs are short

**Training loss plateaus above 1.0:**
- Learning rate too low → try 1e-5
- Data format wrong → verify ChatML structure
- Too few examples → add more training data

## Closed-Loop Deployment via Hooks

Brain models don't just run in isolation — they integrate into the agent lifecycle through hooks, forming a closed feedback loop: **train → deploy → classify → log → feedback → retrain**.

### Hook Integration Pattern

```
┌─ PreToolUse Hook ──────────────────────────────────────────┐
│  Agent calls Bash/MCP tool                                  │
│  → Hook receives JSON: {tool_name, tool_input}              │
│  → Brain model classifies (GGUF, <10ms after load)          │
│  → Decision: allow / block / ask                            │
│  → Log decision to guard.jsonl (ALL decisions, not just blocks) │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─ PostToolUse Hook ─────────────────────────────────────────┐
│  Tool execution completes                                   │
│  → Feedback hook collects outcome (exit_code, errored?)     │
│  → Matches with router telemetry (which skill was routed)   │
│  → Logs to feedback.jsonl: {cmd, routed_skill, errored}     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─ Retrain Cycle ────────────────────────────────────────────┐
│  diana dev hook judge --export train.jsonl                   │
│  → Reviews feedback.jsonl for misclassifications            │
│  → Exports corrected training data                          │
│  → MLX LoRA fine-tune with new data                         │
│  → GGUF export → replace model in ~/.diana/models/          │
│  → Next hook invocation uses updated model                  │
└─────────────────────────────────────────────────────────────┘
```

### Example: Guard Brain (Destructive Command Classifier)

```rust
// PreToolUse hook — loaded once, classified on every Bash command
static GUARD_BRAIN: OnceLock<MicroBrain> = OnceLock::new();

let config = BrainConfig::new(SYSTEM_PROMPT, &["safe", "destructive"])
    .with_max_tokens(5);
let brain = MicroBrain::load_default("diana-guard-q8", config);

// Classify with confidence threshold
let (label, confidence) = brain.classify_with_confidence(command)?;
if label == "destructive" && confidence >= 0.85 {
    // Block: return "ask" decision to Claude Code
    // Log: append to guard.jsonl for feedback
}
```

### Example: Router Brain (Skill Classifier)

```rust
// PreToolUse hook — routes Bash commands to skills
// "git push origin main" → "diana-commit" skill
// "kubectl get pods" → no skill (passthrough)

let (skill, confidence) = router.classify(command)?;
// Advisory only — injects suggestion, doesn't block
// PostToolUse feedback hook logs whether the routing was correct
```

### Key Design Decisions

- **OnceLock + Box::leak** — model loaded once per process, never dropped (avoids GGML Metal destructor race)
- **Confidence threshold** — only act on classifications above 85% confidence
- **Log everything** — both allow and block decisions go to jsonl for training data
- **Redact before logging** — secrets scanner runs before any telemetry/pulse events
- **Advisory vs blocking** — router suggests, guard blocks. Different risk profiles.

## Reference Projects

| Project | Type | Task | Model | Accuracy | Latency | Data source |
|---------|------|------|-------|----------|---------|-------------|
| diana-router | Micro | Bash → skill routing (10 classes + none) | Qwen3 0.6B Q8 | 97.5% (282 test), 100% edge cases | ~560ms | OpenRouter (Gemini Flash) |
| diana-voice-intent | Micro | STT transcript → intent (7 classes) | Qwen3 0.6B Q8 | 97.8% (2720 examples) | ~300ms | AWS Bedrock (Nova 2 Lite) |
| diana-security-gate | Micro | Action → security zone (green/yellow/red) | Qwen3 0.6B Q8 | 98.1%, red recall 100% | ~300ms | AWS Bedrock (Nova 2 Lite) |

**Source locations:**
- `~/src/<project>/` — skill router (generate_dataset.py, eval.py, lora_qwen.yaml)
- `~/src/<project>/` — voice intent classifier
- `~/src/<project>/generate_security_dataset.py` — security gate dataset
- `~/src/<project>/lora_security.yaml` — security gate training config

See `references/` for detailed pipeline, Rust embedding, and Python sidecar docs.
