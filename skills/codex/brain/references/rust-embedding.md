# Rust Embedding — Micro-Brain Deployment

Embed a GGUF model directly into a Rust binary. No server, no startup overhead beyond model load. Best for hooks, daemons, and real-time pipelines.

## Dependencies

```toml
[dependencies]
llama-cpp-2 = { version = "0.1", features = ["metal"] }
```

Build: `cargo build --release`
Sign: `codesign --force --sign "$IDENTITY" --options runtime <binary>`
Model: copy GGUF to `~/.diana/models/<name>.gguf`

## Qwen3 ChatML Token Construction

**CRITICAL: Qwen3 ChatML special tokens must be raw token IDs.**

`<|im_start|>` and `<|im_end|>` are special tokens inserted by ID. Text content is tokenized separately. The `<think>\n\n</think>\n\n` prefix suppresses Qwen3's thinking mode at inference time.

```rust
// Qwen3 ChatML special token IDs
const IM_START: i32 = 151644; // <|im_start|>
const IM_END: i32 = 151645;   // <|im_end|>
const NEWLINE: i32 = 198;     // \n

let im_start = LlamaToken::new(IM_START);
let im_end = LlamaToken::new(IM_END);
let nl = LlamaToken::new(NEWLINE);

// Tokenize text parts
let system_label = model.str_to_token("system", AddBos::Never)?;
let system_text = model.str_to_token(&system_prompt, AddBos::Never)?;
let user_label = model.str_to_token("user", AddBos::Never)?;
let user_text = model.str_to_token(&input, AddBos::Never)?;
let assistant_label = model.str_to_token("assistant", AddBos::Never)?;
let think_suffix = model.str_to_token("<think>\n\n</think>\n\n", AddBos::Never)?;

// Build: <|im_start|>system\n{sp}<|im_end|>\n<|im_start|>user\n{cmd}<|im_end|>\n<|im_start|>assistant\n<think>...</think>\n\n
let mut tokens = Vec::new();
tokens.push(im_start);
tokens.extend_from_slice(&system_label);
tokens.push(nl);
tokens.extend_from_slice(&system_text);
tokens.push(im_end);
tokens.push(nl);
tokens.push(im_start);
tokens.extend_from_slice(&user_label);
tokens.push(nl);
tokens.extend_from_slice(&user_text);
tokens.push(im_end);
tokens.push(nl);
tokens.push(im_start);
tokens.extend_from_slice(&assistant_label);
tokens.push(nl);
tokens.extend_from_slice(&think_suffix);
```

## Greedy Single-Token Decoding

For classification, sample exactly one token greedily:

```rust
let mut candidates = ctx.token_data_array_ith(batch.n_tokens() - 1);
let token = candidates.sample_token_greedy();
let bytes = model.token_to_piece_bytes(token, 32, true, None)?;
```

## SIGABRT Warning — Resource Cleanup

**IMPORTANT:** Drop all llama resources (backend, model, ctx) BEFORE `process::exit()`. Use a scoped block. Otherwise SIGABRT from Metal cleanup.

```rust
fn main() {
    let result = {
        // All llama resources inside this block
        let backend = LlamaBackend::init().unwrap();
        let model = LlamaModel::load_from_file(&backend, model_path, &params).unwrap();
        let ctx = model.new_context(&backend, ctx_params).unwrap();
        // ... inference ...
        result_label
    }; // backend, model, ctx dropped here — Metal cleanup runs safely

    process::exit(if result == "expected" { 0 } else { 1 });
}
```

## Keyword Pre-filter Optimization

For embedded routers that run on every command (hooks), add a keyword pre-filter to skip model load when the input clearly doesn't match any class:

```rust
fn needs_ml(input: &str) -> bool {
    let lower = input.to_lowercase();
    const SKILL_KEYWORDS: &[&str] = &["keyword1", "keyword2", /* ... */];
    SKILL_KEYWORDS.iter().any(|kw| lower.contains(kw))
}
```

This saves ~600ms on commands that obviously don't need routing. The diana-router uses this pattern: trivial skip = ~7ms vs ML inference = ~560ms.

## Model Path

```rust
// Model path convention
let model_path = dirs::home_dir()
    .unwrap()
    .join(".diana/models/<name>-q8.gguf");
```

If model not found: check `~/.diana/models/<name>.gguf` — this is the production location for all GGUF models.

## Reference Implementation

Full working implementation: `examples/rust-embed/src/main.rs`
Dependencies: `examples/rust-embed/Cargo.toml`
