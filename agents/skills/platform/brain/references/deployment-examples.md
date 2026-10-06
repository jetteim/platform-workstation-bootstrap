# Illustrative deployment patterns

These external designs are examples, not measured bootstrap behavior or permission to retrain/install hooks. Keep deterministic safety checks authoritative; uncertain model output must not bypass them. Confidence thresholds need calibration on held-out data.

## Closed-Loop Deployment via Hooks

Brain models don't just run in isolation — they integrate into the agent lifecycle through hooks, forming a closed feedback loop: **train → deploy → classify → log → feedback → retrain**.

### Hook Integration Pattern

```
┌─ PreToolUse Hook ──────────────────────────────────────────┐
│  Agent calls Bash/MCP tool                                  │
│  → Hook receives JSON: {tool_name, tool_input}              │
│  → Brain model classifies (measure on target hardware)          │
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
- **Minimize evidence** — retain only authorized synthetic or sanitized telemetry; never raw commands, secrets or personal payloads
- **Redact before logging** — secrets scanner runs before any telemetry/pulse events
- **Advisory vs blocking** — router suggests, guard blocks. Different risk profiles.
