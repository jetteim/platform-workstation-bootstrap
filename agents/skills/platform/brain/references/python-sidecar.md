# Python Sidecar — Medium-Brain Deployment

Run the model as a persistent Python process. Loads model once, serves requests over stdin/stdout or HTTP. Best for Tauri apps, daemons, or any context where cold-start latency matters.

## Deployment Options

### Option A: Python sidecar (recommended for Tauri apps)

Run as a sidecar process that loads the model once and serves requests over stdin/stdout.

```python
#!/usr/bin/env python3
"""Medium-brain inference server."""

from mlx_lm import load, generate
import sys
import json

MODEL_PATH = "models/<name>-fused"  # or GGUF path

model, tokenizer = load(MODEL_PATH)

SYSTEM_PROMPT = """<your system prompt>"""

def infer(input_text: str) -> str:
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": input_text},
    ]
    prompt = tokenizer.apply_chat_template(messages, add_generation_prompt=True, tokenize=False)
    prompt += "<think>\n\n</think>\n\n"
    return generate(model, tokenizer, prompt=prompt, max_tokens=200, temp=0.0)

# Simple JSON-line protocol over stdin/stdout
for line in sys.stdin:
    req = json.loads(line)
    result = infer(req["text"])
    print(json.dumps({"result": result}, ensure_ascii=False), flush=True)
```

### Option B: LM Studio local server

Import the fused model directory into LM Studio. Use OpenAI-compatible API at localhost:1234. Good for prototyping — adds ~200ms overhead vs direct inference.

### Option C: Embed in Rust via llama-cpp (advanced)

Same pattern as micro-brain's Rust embedding (see `rust-embedding.md`), but:
- Model is larger (1.8GB GGUF) — longer cold start (~2s)
- Generation loop needed (not just single-token greedy)
- Recommend keeping model loaded in memory (daemon or sidecar)

Qwen3 ChatML special tokens are the same:
```rust
const IM_START: i32 = 151644;
const IM_END: i32 = 151645;
const NEWLINE: i32 = 198;
```

## System Prompt Design

The system prompt is critical for generative tasks:
- Concise — every token adds latency
- Unambiguous — explicit rules + anti-patterns
- With 2-3 inline examples — dramatically improves quality

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

## Identity-Mapping Examples

Include ~15-20% of training data as identity pairs (clean input -> same clean output). Without these, the model will hallucinate "corrections" on already-correct text.

Example for STT cleanup task:
```json
{"messages": [
  {"role": "system", "content": "<system prompt>"},
  {"role": "user", "content": "The meeting starts at three o'clock."},
  {"role": "assistant", "content": "<think>\n\n</think>\n\nThe meeting starts at three o'clock."}
]}
```

These teach the model: "if input is already clean, output it unchanged."

## Performance Expectations

| Model | GGUF | Cold start | Inference (30 tok) | RAM |
|-------|------|------------|-------------------|-----|
| Qwen3 0.6B Q8 | 634 MB | ~1s | ~200ms | ~1 GB |
| Qwen3 1.7B Q8 | 1.8 GB | ~2s | ~400ms | ~2.5 GB |
| Qwen3 1.7B Q4 | 1.1 GB | ~1.5s | ~350ms | ~1.8 GB |
| Qwen3 4B Q8 | 4.2 GB | ~3s | ~700ms | ~5 GB |

Latency = time to generate ~30 output tokens on M3 Max. Actual depends on output length.

## Reference Projects

- `examples/` — STT cleanup task (Qwen3 1.7B)
  - `generate_data.py` — data generation via LM Studio
  - `lora_config.yaml` — MLX LoRA config (Qwen3 1.7B)
  - `eval.py` — evaluation script
  - `serve.py` — inference sidecar server
