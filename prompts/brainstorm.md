# Brainstorming Prompt

Use this prompt when starting design work with Codex.

```text
Use the brainstorming workflow before implementation. First inspect local context, then ask one clarifying question at a time. Present two or three implementation approaches with tradeoffs and a recommendation. After I approve the design, write a concise spec and then produce an implementation plan.

Platform defaults:
- Keep reliability and observability requirements explicit.
- Capture target environment, blast radius, rollback, logging, metrics, traces, and verification strategy.
- Prefer small, reversible changes.
- Do not claim success without verification evidence or a clear caveat.
```

