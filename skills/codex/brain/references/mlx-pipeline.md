# MLX Pipeline — Full 6-Phase Reference

Complete pipeline for training dedicated local models on Apple Silicon.

## Phase 1: Define the Task

Create project directory:

```bash
mkdir -p ~/src/<project-name>/{data,models,adapters}
```

**For micro (classification):**
- Input format: what the model receives (one line of text, JSON, etc.)
- Output format: ONLY the label/value, no explanation
- Label set: exhaustive list of valid outputs
- Edge cases: ambiguous inputs and their correct labels

**For medium (generation):**
- Input format: what the model receives (raw text, with context prefix, etc.)
- Output format: what the model produces (cleaned text, translated text, etc.)
- Scope: what transformations are in-scope, what's out-of-scope
- Quality bar: when is output "good enough"? (exact match? semantic equivalence?)

### System Prompt Design (medium)

The system prompt is critical for generative tasks. It must be:
- Concise — every token in system prompt = slower inference
- Unambiguous — list exactly what to do and what NOT to do
- With examples — 2-3 inline examples in the system prompt improve quality dramatically

Template:
```
You are a text [task] model. Given [input description], output [output description].

Rules:
- [Rule 1]
- [Rule 2]
- Do NOT [anti-pattern]

Examples:
Input: [example input 1]
Output: [example output 1]

Input: [example input 2]
Output: [example output 2]
```

## Phase 2: Generate Training Data

Use one of these generators (in order of preference):

| Generator | Cost | Best for | Notes |
|-----------|------|----------|-------|
| AWS Bedrock (Nova 2 Lite) | ~$0.10/1K examples | Bilingual data, safe content | Content filter blocks adversarial/red-zone content |
| OpenRouter (Gemini Flash) | ~$0.05/1K examples | Technical commands, code | Largest context window |
| LM Studio (local) | Free | Iteration, privacy | Requires beefy GPU, slower |

### AWS Bedrock (recommended for bilingual)

```python
import boto3, json

session = boto3.Session(profile_name="default", region_name="us-east-1")
bedrock = session.client("bedrock-runtime")

def call_llm(prompt, temperature=0.8, max_tokens=4000):
    body = {
        "messages": [{"role": "user", "content": [{"text": prompt}]}],
        "inferenceConfig": {"temperature": temperature, "maxTokens": max_tokens},
    }
    resp = bedrock.invoke_model(
        modelId="us.amazon.nova-2-lite-v1:0",
        contentType="application/json", accept="application/json",
        body=json.dumps(body),
    )
    return json.loads(resp["body"].read())["output"]["message"]["content"][0]["text"].strip()
```

**Caveat:** Nova's content filter blocks generation of adversarial/injection examples. For red-zone/attack data, use hand-crafted seeds with duplication instead of LLM generation.

Reference: `examples/generate_dataset.py`, `examples/generate_dataset.py`

### OpenRouter (Gemini Flash)

```python
LMSTUDIO_URL = "http://localhost:1234/v1/chat/completions"
LMSTUDIO_MODEL = "qwen/qwen3-next-80b"  # or whatever is loaded
```

### LM Studio (local)

```python
LMSTUDIO_URL = "http://localhost:1234/v1/chat/completions"
LMSTUDIO_MODEL = "qwen/qwen3-next-80b"  # or whatever is loaded
```

### Qwen3 ChatML Data Format

JSONL with 3-message chat format. Assistant content MUST include `<think>\n\n</think>\n\n` prefix:

```json
{"messages": [
  {"role": "system", "content": "<system prompt>"},
  {"role": "user", "content": "<input>"},
  {"role": "assistant", "content": "<think>\n\n</think>\n\n<label or output>"}
]}
```

**Why the `<think>` prefix?** Qwen3 has a built-in thinking mode. Without suppression, inference outputs `<think>...reasoning...</think>` before the answer, making it slow and unpredictable. Adding the empty think block in training teaches the model to skip reasoning and output directly.

### Generation Strategy

**Micro (classification):**
- Write 3-5 seed examples per class (hand-crafted, known correct)
- Ask the large model to generate 30-50 diverse examples per class
- Generate 2-3x negative examples (class "none" / "other")
- Add hard negatives — inputs with confusing keywords that should NOT match
- Deduplicate, shuffle, split 80/10/10 (train/valid/test)
- Target: 1000-2000 total examples. More classes = more examples needed.

**Medium (generation):**
1. Define input categories — group by difficulty/type
2. Generate diverse inputs — ask the large model to create realistic inputs
3. Generate gold outputs — ask the large model to produce the correct output for each input
4. Validate pairs — spot-check 5-10% manually for quality
5. Add edge cases — short inputs, empty inputs, already-correct inputs (identity mapping)
6. Include ~15-20% identity examples (clean input → same clean output). Without these, the model will hallucinate "corrections" on clean text.
- Target: 2000-5000 total examples for generative tasks.

**Script template (medium):**

```python
#!/usr/bin/env python3
"""Generate training data for medium-brain seq2seq task."""

import json
import random
import httpx
from pathlib import Path

random.seed(42)

LMSTUDIO_URL = "http://localhost:1234/v1/chat/completions"
LMSTUDIO_MODEL = "qwen/qwen3-next-80b"

SYSTEM_PROMPT = """<your system prompt here>"""

CATEGORIES = {
    "category_1": {
        "description": "Description of this input type",
        "seeds": [
            {"input": "...", "output": "..."},
        ],
        "count": 200,
    },
}

def call_llm(messages, temperature=0.8, max_tokens=2000):
    body = {
        "model": LMSTUDIO_MODEL,
        "messages": messages,
        "temperature": temperature,
        "max_tokens": max_tokens,
    }
    resp = httpx.post(LMSTUDIO_URL, json=body, timeout=120)
    resp.raise_for_status()
    return resp.json()["choices"][0]["message"]["content"].strip()

def make_example(input_text, output_text):
    return {
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": input_text},
            {"role": "assistant", "content": f"<think>\n\n</think>\n\n{output_text}"},
        ]
    }

def generate():
    all_examples = []
    for cat_name, cat in CATEGORIES.items():
        # ... generate diverse inputs and outputs via LLM ...
        pass

    random.shuffle(all_examples)
    n = len(all_examples)
    splits = {
        "train": all_examples[:int(n*0.8)],
        "valid": all_examples[int(n*0.8):int(n*0.9)],
        "test": all_examples[int(n*0.9):],
    }
    data_dir = Path("data")
    data_dir.mkdir(exist_ok=True)
    for name, data in splits.items():
        path = data_dir / f"{name}.jsonl"
        with open(path, "w") as f:
            for ex in data:
                f.write(json.dumps(ex, ensure_ascii=False) + "\n")
        print(f"{name}: {len(data)} examples -> {path}")

if __name__ == "__main__":
    generate()
```

Reference for micro: `examples/generate_dataset.py` — supports `--model-family=qwen`.

## Phase 3: Train with MLX LoRA

### Base Model Selection

| Model | Params | GGUF Q8 | Use case |
|-------|--------|---------|----------|
| `Qwen/Qwen3-0.6B` | 596M | 634 MB | **Micro standard.** Classification, routing (<20 classes) |
| `Qwen/Qwen3-1.7B` | 1.7B | ~1.8 GB | **Medium standard.** Short text rewriting, correction |
| `Qwen/Qwen3-4B` | 4B | ~4.2 GB | Complex rewriting, multi-language, longer output |
| `unsloth/gemma-3-270m-it` | 268M | 285 MB | Legacy. Smaller but less capable |

### lora_config.yaml — Micro (Qwen3 0.6B)

```yaml
model: "Qwen/Qwen3-0.6B"
data: "data"

lora_layers: 16
lora_parameters:
  keys: ["self_attn.q_proj", "self_attn.v_proj", "self_attn.k_proj", "self_attn.o_proj", "mlp.gate_proj", "mlp.up_proj", "mlp.down_proj"]
  rank: 16
  alpha: 32
  scale: 10.0
  dropout: 0.05

batch_size: 4
iters: 1000
learning_rate: 1e-5
max_seq_length: 512

adapter_path: "adapters-qwen"
```

### lora_config.yaml — Medium (Qwen3 1.7B)

```yaml
model: "Qwen/Qwen3-1.7B"
train: true
data: "data"
seed: 42

lora_layers: 24
lora_parameters:
  keys: ["self_attn.q_proj", "self_attn.v_proj", "self_attn.k_proj", "self_attn.o_proj", "mlp.gate_proj", "mlp.up_proj", "mlp.down_proj"]
  rank: 32
  alpha: 64
  scale: 10.0
  dropout: 0.05

batch_size: 2
iters: 2000
learning_rate: 5e-6
steps_per_report: 50
steps_per_eval: 200
save_every: 500
val_batches: 25
max_seq_length: 512
grad_checkpoint: true

adapter_path: "adapters"
test: true
test_batches: -1
```

**Key differences micro vs medium:**
- `lora_layers: 24` vs 16 — more layers for richer representation
- `rank: 32` vs 16 — more capacity for generation
- `batch_size: 2` vs 4 — 1.7B uses more VRAM per batch
- `iters: 2000` vs 1000 — generative tasks need more training
- `learning_rate: 5e-6` vs 1e-5 — lower LR, larger model
- `grad_checkpoint: true` — saves memory for 1.7B

**Run:**

```bash
uv run mlx_lm.lora --config lora_config.yaml
```

**Watch for:**
- Micro: training loss should drop to <0.3 for classification
- Medium: training loss should drop to <0.5 for text rewriting
- Val loss should track train loss (no divergence = no overfit)
- If val loss rises while train drops: reduce iters, increase data, add dropout

## Phase 4: Evaluate

**Fuse adapters first:**

```bash
# Micro
uv run mlx_lm.fuse \
    --model "Qwen/Qwen3-0.6B" \
    --adapter-path adapters-qwen \
    --save-path models/<name>-qwen-fused

# Medium
uv run mlx_lm.fuse \
    --model "Qwen/Qwen3-1.7B" \
    --adapter-path adapters \
    --save-path models/<name>-fused
```

**Micro eval target metrics:**
- Overall accuracy: >95% for binary, >90% for multi-class
- Per-class accuracy: no class below 80%
- Zero "INVALID" predictions (model outputs only valid labels)

Reference: `examples/eval.py`

**Medium eval (generative — more nuanced):**

```python
#!/usr/bin/env python3
from pathlib import Path
import json
from mlx_lm import load, generate

model, tokenizer = load("models/<name>-fused")
test_data = [json.loads(l) for l in Path("data/test.jsonl").read_text().splitlines()]
results = {"exact": 0, "close": 0, "wrong": 0, "total": 0}

for ex in test_data:
    messages = ex["messages"][:2]  # system + user only
    prompt = tokenizer.apply_chat_template(messages, add_generation_prompt=True, tokenize=False)
    prompt += "<think>\n\n</think>\n\n"
    output = generate(model, tokenizer, prompt=prompt, max_tokens=200, temp=0.0)
    # compare output vs expected...
    results["total"] += 1

print(f"Exact: {results['exact']}/{results['total']}")
```

**Medium eval target metrics:**
- Exact match: >60% (text rewriting is harder than classification)
- Exact + semantically close: >90%
- Wrong (meaning changed, hallucination, garbled): <5%
- Identity preservation: >95% (clean input → same clean output)

## Phase 5: Export to GGUF

```bash
# Qwen3 uses BPE — no special tokenizer.model needed
python llama.cpp/convert_hf_to_gguf.py \
    models/<name>-fused \
    --outtype q8_0
# Output: models/<name>-fused/<name>-Q8_0.gguf
cp models/<name>-fused/*.gguf ~/.diana/models/<name>.gguf
```

**Quantization guide:**
- Q8_0: best accuracy. Micro ~634MB, Medium ~1.8GB. Default choice.
- Q4_K_M: good balance. Saves ~40% RAM with minor quality loss.
- Q4_0: smallest, some accuracy loss. Avoid for generative tasks.

## Phase 6: Deploy

- **Micro** -> Rust embedding: see `rust-embedding.md`
- **Medium** -> Python sidecar: see `python-sidecar.md`
- **Both** -> LM Studio: import fused model directory, use OpenAI-compatible API at localhost:1234.

## Qwen3 ChatML Special Token IDs

```
<|im_start|>  = 151644
<|im_end|>    = 151645
\n            = 198
```

These are special tokens and must be inserted as raw token IDs in Rust (not tokenized as text). See `rust-embedding.md` for full implementation.

## Performance Reference

| Model | GGUF | Cold start | Inference (30 tok) | RAM |
|-------|------|------------|-------------------|-----|
| Qwen3 0.6B Q8 | 634 MB | ~1s | ~200ms | ~1 GB |
| Qwen3 1.7B Q8 | 1.8 GB | ~2s | ~400ms | ~2.5 GB |
| Qwen3 1.7B Q4 | 1.1 GB | ~1.5s | ~350ms | ~1.8 GB |
| Qwen3 4B Q8 | 4.2 GB | ~3s | ~700ms | ~5 GB |

Latency = time to generate ~30 output tokens on M3 Max.
