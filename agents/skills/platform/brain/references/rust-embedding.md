<!-- Reviewed examples: model-dependent templates/IDs/configs and external timings, not bootstrap benchmark results. See tested-recipe.md. -->
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

Inspect the selected local tokenizer with `python3 scripts/tokenizer-metadata.py <model-directory>` (relative to the installed skill). Use its actual chat template. The helper reports ChatML support and IDs only; do not apply this example to a tokenizer without ChatML. Verify that exported GGUF IDs match before inference.

`<|im_start|>` and `<|im_end|>` are special tokens inserted by ID. Text content is tokenized separately. An empty think prefix is a model-specific training example, not a universal suppression guarantee. Prefer the selected template’s supported option and verify the actual output.

```rust
// chat_tokens is loaded from validated selected-tokenizer metadata,
// checked against the GGUF vocabulary. Do not supply hardcoded IDs.
let im_start = LlamaToken::new(chat_tokens.im_start);
let im_end = LlamaToken::new(chat_tokens.im_end);
let nl = model.str_to_token("\n", AddBos::Never)?;

// Tokenize text parts
let system_label = model.str_to_token("system", AddBos::Never)?;
let system_text = model.str_to_token(&system_prompt, AddBos::Never)?;
let user_label = model.str_to_token("user", AddBos::Never)?;
let user_text = model.str_to_token(&input, AddBos::Never)?;
let assistant_label = model.str_to_token("assistant", AddBos::Never)?;
// generation_suffix comes from the selected model template/config.
let think_suffix = model.str_to_token(&generation_suffix, AddBos::Never)?;

// Build: <|im_start|>system\n{sp}<|im_end|>\n<|im_start|>user\n{cmd}<|im_end|>\n<|im_start|>assistant\n<think>...</think>\n\n
let mut tokens = Vec::new();
tokens.push(im_start);
tokens.extend_from_slice(&system_label);
tokens.extend_from_slice(&nl);
tokens.extend_from_slice(&system_text);
tokens.push(im_end);
tokens.extend_from_slice(&nl);
tokens.push(im_start);
tokens.extend_from_slice(&user_label);
tokens.extend_from_slice(&nl);
tokens.extend_from_slice(&user_text);
tokens.push(im_end);
tokens.extend_from_slice(&nl);
tokens.push(im_start);
tokens.extend_from_slice(&assistant_label);
tokens.extend_from_slice(&nl);
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
