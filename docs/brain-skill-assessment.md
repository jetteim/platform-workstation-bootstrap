# Brain Skill Assessment

Date checked: 2026-04-11

Source: <https://github.com/diana-random1st/brain-skill>

Fork: <https://github.com/jetteim/brain-skill>

## Decision

Incorporate it as an optional external Codex skill.

It makes sense for this workstation because it is directly aligned with platform engineering work where small local classifiers can improve reliability, safety, and observability loops:

- command or tool risk classification before execution
- incident, alert, and CI-log triage
- local routing decisions when cloud LLM calls are too slow or expensive
- hook feedback loops that log decisions, collect outcomes, and retrain

It should not be treated as a default runtime dependency. The ML training path is heavy and should remain opt-in.

## Fit

Strong fit:

- The skill has clear use and non-use criteria.
- The pipeline is operationally structured: define, generate, train, eval, export, deploy.
- It includes deployment patterns for hooks, telemetry, feedback, and retraining.
- It supports local execution, which is useful for low-latency policy and routing decisions.

Risks:

- It depends on Apple Silicon ML tooling, MLX, llama.cpp, and model downloads.
- Some claimed model names and benchmark numbers should be treated as examples until locally reproduced.
- The skill references Diana-specific paths and commands. The bootstrap preserves the skill but does not assume the Diana toolchain exists.
- Safety claims depend on the surrounding hook implementation. This repo still keeps deterministic secret scanning and policy checks as the first line of defense.

## Incorporation

The bootstrap now:

- refreshes the upstream fork through `scripts/refresh-github.sh`
- clones the fork into `~/.codex/vendor_imports/repos/brain-skill`
- installs the live skill into `~/.codex/skills/brain`
- vendors a fallback copy under `skills/codex/brain`
- verifies the skill package through `scripts/test-brain-skill.sh`

The installer does not install `uv`, `mlx`, `mlx-lm`, `llama.cpp`, model weights, or Rust/Python inference services. Those remain project-specific decisions.
