# Platform Workstation Bootstrap

Reproducible setup notes and guardrails for my macOS platform engineering workstation.

This repository is intentionally explicit about:

- Agent-neutral rules, prompts, hooks, and source mirrors under `~/.agents`.
- Adapter-local skills for Codex and Claude, plus plugin-provided skills where available.
- User-wide Git safety hooks.
- Reliability and observability-oriented defaults.
- External dependency forks to use on a clean development machine.

It is not a dotfiles dump. Secrets, tokens, auth databases, shell history, browser state, and live Codex transcripts must stay out of this repository.

## First Step

Always refresh GitHub and dependency forks first:

```bash
./scripts/refresh-github.sh
```

That script checks `gh auth status`, runs `gh auth setup-git` so private HTTPS clones can use GitHub CLI credentials, creates missing forks, and syncs known dependency forks from upstream.

## Install

```bash
gh auth login
./scripts/refresh-github.sh
./scripts/install.sh
./scripts/verify.sh
```

`~/.agents` is the canonical rules, hooks, prompts, and source-mirror layer. Codex and Claude keep their active skills in their own adapter homes.

Canonical rules include operating principles for honesty, verification, scoped action, target-state work, documented paths, competing hypotheses, reversible change, user ownership, and simple solutions.

`install-skills.sh` is the explicit skill installer. `install.sh` runs it automatically.

The skill install order mirrors the original upstream setup:

- Enable Superpowers through the native Codex plugin `superpowers@openai-curated`.
- Do not clone or project Superpowers from `~/.codex/superpowers`; use the native plugin as its only install source.
- Refuse unsafe `AGENTS_HOME`, `CODEX_HOME`, and `CLAUDE_HOME` overrides before creating directories.
- Keep `~/.agents/skills` as a managed empty directory after the duplicate-skill cleanup.
- Install source mirrors under `~/.agents/vendor_imports`.
- Install cleaned local Codex skills into `~/.codex/skills`: platform/document skills plus local Google Drive helper skills that extend the native plugin.
- Preserve the local Codex ZenMoney receipt categorization, savings, and category review skills.
- Install `engineering-agent-ready-clis` for designing, auditing, retrofitting, and testing CLIs used by AI agents.
- Install `writing-diataxis-documentation` for every documentation creation, revision, audit, or restructuring task.
- Install Claude fallback skills into `~/.claude/skills`, where native Codex plugins are not available.
- Sync managed skill destinations from staged trees so removed vendored files are pruned on reinstall.
- Keep vendored Codex and plugin skill fallback copies in the repo for clean-machine bootstrap, Claude fallback, and audit.
- Clone the private platform observability/reliability model repos before installing their public engineering skills when GitHub access allows.
- Clone the observability pipeline skill repo and install its tool-agnostic pipeline workflow when GitHub access allows.
- Clone the deterministic `slo-rules-engine` source mirror before installing `reliability-engineering`, so reliability generation can use `sre-rules` instead of hand-written provider artifacts.
- Fall back to bundled observability/reliability reference summaries inside the skill bundles when private model repo refresh is unavailable.
- Clone the public architectural execution skill pipeline and install it from source when GitHub access allows.
- Clone the public Diátaxis documentation skill and install it from source when GitHub access allows.

`install.sh` installs:

- `~/.codex/hooks.json`
- `~/.agents/hooks/*` and `~/.agents/prompts/*`
- `~/.codex/hooks/*.py`, combining shared hook policy with the Codex event dispatcher
- source-backed skills and cleaned fallback skill projections through `scripts/install-skills.sh`
- `~/.config/git/hooks/pre-commit`
- `git config --global core.hooksPath ~/.config/git/hooks`
- `features.hooks = true`
- `features.multi_agent = true`
- `features.plugins = true`
- `plugins."superpowers@openai-curated".enabled = true`

It does not overwrite live credentials or private config files.

Dirty source mirrors are refreshed neither destructively nor used as source-backed skill inputs; the installer falls back to vendored canonical copies when a mirror has local changes.

See `docs/original-install-comparison.md` for the upstream install-step comparison.

Optional Brain/MLX validation:

```bash
./scripts/install-brain-prereqs.sh
./scripts/run-brain-mlx-smoke.sh
./scripts/test-brain-skill.sh
```

This installs the local MLX training environment under `~/.codex/mlx`, mirrors `llama.cpp`, trains a small Kubernetes command-risk classifier, fuses the adapter, and exports a Q8 GGUF model under `~/.codex/mlx/runs/k8s-risk-classifier`.

## Included Skills

This repo vendors full installable skill bundles, not only prompts:

- `skills/codex/*`
- `skills/plugins/github/*`
- `skills/plugins/google-drive/*`

Codex gets Superpowers from `superpowers@openai-curated`. Obsolete vendored Superpowers trees were removed; previous snapshots remain in Git history.

`manifests/codex-skills.txt` records installed local skills and skill bundles present in the native and remote plugin caches, including Data Analytics, Deep Research, templates, and plugin management. Cache presence does not establish that a skill is enabled or exposed in a session. Remote plugins are not vendored or installed by this repository.

`scripts/install-skills.sh` leaves `~/.agents/skills` empty, installs vendored and source-backed local Codex skills into `~/.codex/skills`, installs only the local Google Drive helper skills under `~/.codex/skills/plugin-google-drive`, and places full plugin-skill fallbacks under `~/.claude/skills` for Claude.
`agents/skills/codex-curated/` contains Codex-only system, document, and ZenMoney skills. Shared platform skills live under `agents/skills/platform/` and are staged once for each adapter.
The architectural execution skill pipeline is installed from `jetteim/architectural-execution-skills` when the source mirror is available, with vendored fallback copies under `skills/codex/`.
The agent-ready CLI skill is canonical under `agents/skills/platform/engineering-agent-ready-clis/`, projected to Codex and Claude, and vendored under `skills/codex/engineering-agent-ready-clis/` for clean-machine bootstrap.
The agent-agnostic Diátaxis documentation skill is installed from `jetteim/diataxis-documentation-skill`, projected unchanged to Codex and Claude, and vendored under `skills/codex/writing-diataxis-documentation/` for clean-machine bootstrap. It uses a Superpowers-style dialogue: one question at a time, recommended content approaches, progressive outline approval, a gate before drafting, and final user review.

## Important Repositories

The clean-machine path depends on these forks:

| Purpose | Upstream | Fork |
| --- | --- | --- |
| Codex CLI source/reference | `openai/codex` | `jetteim/codex` |
| OpenAI curated skills | `openai/skills` | `jetteim/skills` |
| Playwright MCP server | `microsoft/playwright-mcp` | `jetteim/playwright-mcp` |
| MCP reference servers | `modelcontextprotocol/servers` | `jetteim/servers` |
| Local micro-model training skill | `diana-random1st/brain-skill` | `jetteim/brain-skill` |
| GGUF conversion for local model runs | `ggml-org/llama.cpp` | `jetteim/llama.cpp` |
| Platform observability model | owned repo | `jetteim/platform-observability-model` |
| Observability engineering skill | owned repo | `jetteim/observability-engineering` |
| Observability pipeline skills | owned repo | `jetteim/observability-pipeline-skills` |
| Platform reliability model | owned repo | `jetteim/platform-reliability-model` |
| Deterministic SRE rules engine | owned repo | `jetteim/slo-rules-engine` |
| Reliability engineering skill | owned repo | `jetteim/reliability-engineering` |
| Architectural execution skills | owned repo | `jetteim/architectural-execution-skills` |
| Diátaxis documentation skill | owned repo | `jetteim/diataxis-documentation-skill` |

## Why Keep A User-Wide Git Hook

Keep a global Git hook, but make it a safety net:

- Block high-confidence secrets.
- Block conflict markers.
- Block obvious private-key or environment files.
- Warn on oversized staged files.
- Delegate project-specific checks to `.githooks/pre-commit` or `.git/hooks/pre-commit.local`.

Language and repo-specific linting belongs in each repository. Global hooks should protect every repo without making unrelated work brittle.

## Compare With Local State

Run `./scripts/audit.sh` for a read-only JSON inventory of installed packages, skill hashes, plugin cache versions, and source-mirror commits/dirty status. The captured baseline is `manifests/local-state.json`; compare it with fresh output, ignoring `observed_at`. The audit excludes credentials and private runtime configuration values.

Both Codex config examples capture the reviewed local model, MCP commands, project trust entries, and tool approval policies. They contain machine-specific paths and require review before use elsewhere. UI counters and hook trust state are excluded.

## NPM Status

NPM is required by the current Codex setup because:

- Codex is installed globally as `@openai/codex`.
- MCP servers are configured via `npx`.

It is not treated as a generic platform dependency beyond Codex/MCP.
