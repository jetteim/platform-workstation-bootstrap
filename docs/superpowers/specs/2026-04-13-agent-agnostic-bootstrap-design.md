# Agent-Agnostic Bootstrap Design

Date: 2026-04-13

## Purpose

`platform-workstation-bootstrap` should install a reusable agent workstation profile that works for Codex, Claude, and future coding agents. The repository currently treats Codex as the main model and uses `~/.codex` as the source of truth for skills, hooks, and source mirrors. The new model makes `~/.agents` the canonical installed layer and treats Codex and Claude as adapters that receive projected copies or generated config.

## Goals

- Make `~/.agents` the canonical local home for reusable rules, skills, prompts, hooks, and source mirrors.
- Keep Codex fully working through an adapter projection into `~/.codex`.
- Add a Claude adapter projection into `~/.claude`.
- Persist durable codebase exploration guidance as agent-neutral rules.
- Promote the installed architectural execution skill pipeline into the shared platform skill layer.
- Keep the migration incremental and non-destructive.
- Preserve existing secret, reliability, observability, and global Git safety behavior.

## Non-Goals

- Do not delete the existing `skills/` or `codex/` source paths in the first implementation.
- Do not migrate heavy Brain/MLX runtime outputs in the first implementation.
- Do not make plugin fallback skills a substitute for enabling an agent's native plugin or app system.
- Do not force-reset dirty source mirrors or overwrite user-owned adapter paths.

## Architecture

The bootstrap has two layers.

The canonical layer is agent-neutral. It owns reusable process rules, codebase exploration guidance, skills, prompts, hook policy logic where it is not tied to one client, and source mirrors. It installs to `~/.agents` and is usable even when Codex is not installed.

The adapter layer maps canonical assets into each agent's expected filesystem and config. Codex remains supported through `~/.codex/skills`, `~/.codex/hooks.json`, `~/.codex/hooks/*.py`, and `~/.codex/config.toml`. Claude receives `~/.claude/skills` plus generated rule material from canonical rules. Future agents add a new adapter directory and projection script rather than another full skill universe.

## Repository Layout

Introduce a canonical source tree:

```text
agents/
  rules/
    codebase-exploration.md
    reliability-observability.md
    secrets-and-safety.md
  skills/
    superpowers/
    platform/
    plugins/
    codex-curated/
  hooks/
    policy.py
    redact.py
  prompts/
  adapters/
    codex/
      hooks.json
      hooks/codex_hook.py
      config.example.toml
    claude/
      CLAUDE.md.template
```

The installed architectural execution skills belong under `agents/skills/platform` in v1:

- `orchestrating-architecture-execution`
- `discovering-value-streams`
- `shaping-capabilities`
- `shaping-features`
- `modeling-c4-architecture`
- `slicing-stories`
- `reviewing-traceability`

The existing `skills/` and `codex/` trees remain available during the first migration. They act as compatibility aliases or fallback sources while scripts move to the canonical `agents/` model.

## Local Install Layout

Canonical paths:

```text
~/.agents/rules
~/.agents/skills
~/.agents/hooks
~/.agents/prompts
~/.agents/vendor_imports
```

Adapter paths:

```text
~/.codex/skills
~/.codex/hooks.json
~/.codex/hooks
~/.codex/config.toml
~/.claude/skills
```

The canonical layer is installed first. Adapter projections are derived from that canonical layer.

## Install Flow

1. `refresh-github.sh` refreshes dependency forks as it does today.
2. `install.sh` creates the canonical `~/.agents` tree.
3. The shared skill installer installs all reusable skills into `~/.agents/skills`.
4. Source mirrors move from `~/.codex/vendor_imports` to `~/.agents/vendor_imports`.
5. The Codex adapter projects compatible skills and adapter files into `~/.codex`.
6. The Claude adapter projects compatible skills and generated rule material into `~/.claude`.
7. Verification checks both the canonical inventory and enabled adapter projections.

For v1, keep `scripts/install-skills.sh` as the public skill-install entrypoint and add helper functions or a small projection script rather than renaming the entrypoint. This preserves the current documented command surface while changing the model underneath it.

## Skill Compatibility

Skill compatibility is explicit rather than inferred from current paths.

- Shared skills install to `~/.agents/skills` and may be projected to Codex and Claude.
- Codex-only skills or references remain marked Codex-only until rewritten.
- Plugin fallback skills remain shared instruction bundles, while plugin enablement remains adapter-specific.
- Architectural execution, reliability, observability, and process skills are shared platform skills unless an individual skill has agent-specific tool assumptions.

A compatibility manifest defines what each adapter receives. The manifest gives future agents a clear projection contract and avoids assuming every canonical asset works in every agent.

## Rules

Add durable agent-neutral rule files under `agents/rules`.

`agents/rules/codebase-exploration.md` must include:

1. Build a context map before exploring a codebase.
2. Use `rg` or grep first, then read targeted files or sections.
3. Read a file once when possible; do not reread just to refresh memory.
4. For large files, use offsets or ranges instead of full-file reads.
5. Do not repeat the same search query over the same paths and patterns; cache and reuse search results within the task.

Rule wording says "agent" unless the rule is adapter-specific. Adapter projections wrap the shared rules in the format expected by the target agent.

For Claude v1, generate a user-visible rule template at `agents/adapters/claude/CLAUDE.md.template` and install skills into `~/.claude/skills`. Do not auto-write project-local `CLAUDE.md` files from the default installer.

## Hooks

Hook policy logic moves toward shared `agents/hooks`. Codex event dispatch remains in the Codex adapter because Codex hook event names and payloads are client-specific.

The first migration preserves current behavior:

- Secret and credential redaction.
- Destructive command blocking for high-confidence cases.
- Reliability and observability advisory context.
- Completion evidence checks where the agent supports hook-based stop events.

## Brain/MLX Runtime

Brain/MLX remains opt-in. The first migration moves source mirrors such as `llama.cpp` toward `~/.agents/vendor_imports/repos`, but keeps existing runtime outputs under `~/.codex/mlx` unless a later design explicitly covers runtime relocation.

This avoids a risky heavy-path migration while still correcting source provenance.

## Error Handling

- Dirty source mirrors are skipped, not reset.
- Existing non-symlink or user-owned adapter directories are left unchanged unless explicitly managed by the installer.
- Missing optional source mirrors fall back to vendored canonical copies.
- Adapter projection failures report the adapter and path that failed.
- The installer continues with optional adapters only when the canonical layer is healthy.

## Verification

Verification proves:

- Canonical `agents/` source paths exist for rules, skills, hooks, prompts, and adapters.
- Install scripts parse successfully.
- Scripts reference canonical install paths: `~/.agents/skills`, `~/.agents/rules`, and `~/.agents/vendor_imports`.
- Codex adapter files compile and the existing hook smoke test still works.
- Claude adapter templates exist and include shared rule guidance.
- The architectural execution skill pipeline exists in the shared platform skill layer.
- Vendored skill inventory remains above the existing threshold.
- Existing safety checks remain intact.

## Migration Plan

The implementation is staged:

1. Add canonical `agents/` source paths and manifests while leaving current paths intact.
2. Copy current reusable skill sources into `agents/skills` during the first migration rather than generating them dynamically at install time.
3. Teach installers to populate `~/.agents`.
4. Project Codex from canonical paths while preserving existing Codex behavior.
5. Add Claude projection for skills and rule templates.
6. Update docs and verification.
7. Remove old path assumptions only after verification and a clean install audit.
