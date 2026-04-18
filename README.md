# Platform Workstation Bootstrap

Reproducible setup notes and guardrails for my macOS platform engineering workstation.

This repository is intentionally explicit about:

- Agent-neutral rules, skills, prompts, hooks, and source mirrors under `~/.agents`.
- Adapter projections for Codex, Claude, plugins, and MCP dependencies.
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

`~/.agents` is the canonical agent-neutral layer. Codex and Claude are adapter targets projected from that layer.

Canonical rules include operating principles for honesty, verification, scoped action, target-state work, documented paths, competing hypotheses, reversible change, user ownership, and simple solutions.

`install-skills.sh` is the explicit skill installer. `install.sh` runs it automatically.

The skill install order mirrors the original upstream setup:

- Clone or update the Superpowers fork into `~/.codex/superpowers`.
- Install canonical Superpowers into `~/.agents/skills/superpowers` as a real directory on fresh installs.
- Replace a legacy `~/.agents/skills/superpowers` symlink with the canonical real directory during migration.
- Refuse unsafe `AGENTS_HOME`, `CODEX_HOME`, and `CLAUDE_HOME` overrides before creating directories.
- Install canonical shared skills under `~/.agents/skills`.
- Install source mirrors under `~/.agents/vendor_imports`.
- Project compatible skills into `~/.codex/skills` and `~/.claude/skills`.
- Sync managed skill destinations from staged trees so removed vendored files are pruned on reinstall.
- Install vendored Codex and plugin skill fallback copies.
- Clone the private platform observability/reliability model repos before installing their public engineering skills when GitHub access allows.
- Clone the observability pipeline skill repo and install its tool-agnostic pipeline workflow when GitHub access allows.
- Fall back to bundled observability/reliability reference summaries inside the skill bundles when private model repo refresh is unavailable.
- Clone the public architectural execution skill pipeline and install it from source when GitHub access allows.

`install.sh` installs:

- `~/.codex/hooks.json`
- `~/.agents/hooks/*` and `~/.agents/prompts/*`
- `~/.codex/hooks/*.py`, combining shared hook policy with the Codex event dispatcher
- source-backed skills and fallback skill bundles through `scripts/install-skills.sh`
- `~/.config/git/hooks/pre-commit`
- `git config --global core.hooksPath ~/.config/git/hooks`
- `features.codex_hooks = true`
- `features.multi_agent = true`

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

- `skills/superpowers/*`
- `skills/codex/*`
- `skills/plugins/github/*`
- `skills/plugins/google-drive/*`

The Superpowers `brainstorming` skill is included with its full bundle:

- `skills/superpowers/brainstorming/SKILL.md`
- `skills/superpowers/brainstorming/visual-companion.md`
- `skills/superpowers/brainstorming/spec-document-reviewer-prompt.md`
- `skills/superpowers/brainstorming/scripts/*`

`scripts/install-skills.sh` installs Superpowers from the forked source repo first. The vendored Superpowers copy is fallback material for offline or damaged-bootstrap cases.

It also installs vendored local Codex skills into `~/.codex/skills`, installs the external `brain` skill from its forked source mirror when available, installs the observability pipeline workflow from its source mirror when available, and places plugin-skill fallbacks under `~/.agents/skills`.
The architectural execution skill pipeline is installed from `jetteim/architectural-execution-skills` when the source mirror is available, with vendored fallback copies under `skills/codex/`.

## Important Repositories

The clean-machine path depends on these forks:

| Purpose | Upstream | Fork |
| --- | --- | --- |
| Codex CLI source/reference | `openai/codex` | `jetteim/codex` |
| OpenAI curated skills | `openai/skills` | `jetteim/skills` |
| Superpowers skills, including full brainstorming bundle | `obra/superpowers` | `jetteim/superpowers` |
| Playwright MCP server | `microsoft/playwright-mcp` | `jetteim/playwright-mcp` |
| MCP reference servers | `modelcontextprotocol/servers` | `jetteim/servers` |
| Local micro-model training skill | `diana-random1st/brain-skill` | `jetteim/brain-skill` |
| GGUF conversion for local model runs | `ggml-org/llama.cpp` | `jetteim/llama.cpp` |
| Platform observability model | owned repo | `jetteim/platform-observability-model` |
| Observability engineering skill | owned repo | `jetteim/observability-engineering` |
| Observability pipeline skills | owned repo | `jetteim/observability-pipeline-skills` |
| Platform reliability model | owned repo | `jetteim/platform-reliability-model` |
| Reliability engineering skill | owned repo | `jetteim/reliability-engineering` |
| Architectural execution skills | owned repo | `jetteim/architectural-execution-skills` |

## Why Keep A User-Wide Git Hook

Keep a global Git hook, but make it a safety net:

- Block high-confidence secrets.
- Block conflict markers.
- Block obvious private-key or environment files.
- Warn on oversized staged files.
- Delegate project-specific checks to `.githooks/pre-commit` or `.git/hooks/pre-commit.local`.

Language and repo-specific linting belongs in each repository. Global hooks should protect every repo without making unrelated work brittle.

## NPM Status

NPM is required by the current Codex setup because:

- Codex is installed globally as `@openai/codex`.
- MCP servers are configured via `npx`.

It is not treated as a generic platform dependency beyond Codex/MCP.
