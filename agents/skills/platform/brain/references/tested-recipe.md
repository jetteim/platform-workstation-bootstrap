# Tested bootstrap recipe versus examples

The bootstrap smoke path recorded on 11 April 2026 uses `mlx-community/Qwen3-0.6B-bf16`, 300 iterations, 16 LoRA layers, batch size 1 and learning rate 5e-5. The authoritative implementation is bootstrap `scripts/run-brain-mlx-smoke.sh`; evidence and exact limitations are in `docs/brain-skill-smoke-test.md`. Its single destructive-command inference is smoke evidence, not classification accuracy or safety certification.

Other Qwen3 model/config and latency tables in the pipeline/deployment references are illustrative external examples. Select the same base/tokenizer in data formatting, training, fusion, evaluation and export; do not substitute a similarly named model family silently. Derive chat templates and special token IDs from the selected tokenizer and preserve them through GGUF conversion. Disable thinking through supported model/template options and test actual output; an empty think prefix is a model-specific example, not a universal guarantee.

Before training, inspect the selected config and tokenizer metadata locally and record the model identifier, revision when available, tool versions, split/leakage checks and measured hardware. Training, downloads and deployment remain opt-in. Timings and targets require measurements on the actual task and hardware.

Use the packaged `scripts/tokenizer-metadata.py <local-model-directory>` to inspect chat-template digest and ChatML IDs without loading weights or downloading anything. The helper reports unsupported ChatML or inconsistent/missing metadata instead of substituting universal IDs. The runtime must still verify tokenizer/GGUF parity.
