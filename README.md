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

For a clean-machine install, refresh GitHub and dependency forks first. A read-only review starts with `./scripts/audit.sh` and does not sync forks:

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

The installer uses reviewed skill snapshots by default:

- Enable Superpowers through the native Codex plugin `superpowers@openai-curated`.
- Do not clone or project Superpowers from `~/.codex/superpowers`; use the native plugin as its only install source.
- Refuse unsafe `AGENTS_HOME`, `CODEX_HOME`, and `CLAUDE_HOME` overrides before creating directories.
- Keep `~/.agents/skills` as a managed empty directory after the duplicate-skill cleanup.
- Install source mirrors under `~/.agents/vendor_imports`.
- Preserve existing Codex-managed `.system` skills and their runtime state; bundled system skills seed an empty home only.
- Install cleaned local Codex skills into `~/.codex/skills`: platform/document skills plus local Google Drive helper skills that extend the native plugin.
- Install the reviewed local Codex ZenMoney receipt categorization, savings, and category review skills. Reinstallation replaces managed skill trees; back up intentional local changes first.
- Install `engineering-agent-ready-clis` for designing, auditing, retrofitting, and testing CLIs used by AI agents.
- Install `writing-diataxis-documentation` for technical documentation work; use dialogue only for consequential unresolved decisions and honor delegated judgment.
- Install Claude fallback skills into `~/.claude/skills`, where native Codex plugins are not available.
- Sync managed skill destinations from staged trees so removed vendored files are pruned on reinstall.
- Keep vendored Codex and plugin skill fallback copies in the repo for clean-machine bootstrap, Claude fallback, and audit.
- Clone the private platform observability/reliability model repos before installing their public engineering skills when GitHub access allows.
- Clone the observability pipeline skill repo and install its tool-agnostic pipeline workflow when GitHub access allows.
- Clone the deterministic `slo-rules-engine` source mirror before installing `reliability-engineering`, so reliability generation can use `sre-rules` instead of hand-written provider artifacts.
- Fall back to bundled observability/reliability reference summaries inside the skill bundles when private model repo refresh is unavailable.
- Maintain the architectural execution skill source mirror; install the reviewed repo snapshot.
- Maintain the Diátaxis documentation skill source mirror; install the reviewed repo snapshot.

`install.sh` installs:

- `~/.codex/hooks.json`
- `~/.agents/hooks/*` and `~/.agents/prompts/*`
- `~/.codex/hooks/*.py`, combining shared hook policy with the Codex event dispatcher
- reviewed skills and cleaned fallback skill projections through `scripts/install-skills.sh`
- `~/.config/git/hooks/pre-commit`
- `~/.config/git/hooks/scan-staged.py`, which inspects staged blobs in memory
- `git config --global core.hooksPath ~/.config/git/hooks`
- missing feature defaults: `hooks = true`, `multi_agent = true`, `plugins = true`
- missing native plugin defaults: GitHub, Google Drive, and Superpowers enabled
- `enabled = false` for the archived `@modelcontextprotocol/server-github` duplicate when no explicit enable choice exists

It preserves explicit model, feature, plugin, skill, and credential choices. The config updater parses TOML before and after editing and writes only when defaults are missing. The current executable and npm package both report Codex `0.160.1`. Python 3.11+ supplies `tomllib`; the macOS system Python uses the installed pip TOML parser.

Dirty source mirrors are never refreshed destructively. Set `USE_SOURCE_SKILLS=1` only when intentionally installing clean source-mirror skill versions in place of the reviewed snapshots; this can replace local refinements. Use `SKIP_GITHUB_REFRESH=1 SKIP_SOURCE_REFRESH=1 ./scripts/install.sh` to reinstall the reviewed setup offline. For fixture installs, set `AGENTS_HOME`, `CODEX_HOME`, `CLAUDE_HOME`, and `GIT_HOOKS_HOME` to directories beneath `/tmp`, and set `GIT_CONFIG_GLOBAL` to a fixture file to isolate Git configuration.

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

`scripts/install-skills.sh` leaves `~/.agents/skills` empty, installs reviewed local Codex skills into `~/.codex/skills`, installs only the local Google Drive helper skills under `~/.codex/skills/plugin-google-drive`, and places full plugin-skill fallbacks under `~/.claude/skills` for Claude.
`agents/skills/codex-curated/` contains Codex-only system, document, and ZenMoney skills. Shared platform skills live under `agents/skills/platform/` and are staged once for each adapter.
The architectural execution skill pipeline originates in `jetteim/architectural-execution-skills`; reviewed copies live under `agents/skills/platform/` and `skills/codex/`. Upstream refresh and skill installation are separate choices.
The agent-ready CLI skill is canonical under `agents/skills/platform/engineering-agent-ready-clis/`, projected to Codex and Claude, and vendored under `skills/codex/engineering-agent-ready-clis/` for clean-machine bootstrap.
The agent-agnostic Diátaxis documentation skill originates in `jetteim/diataxis-documentation-skill`. The reviewed local version is projected to Codex and Claude and mirrored under `skills/codex/writing-diataxis-documentation/`. It matches content to a reader need, asks one question at a time when needed, and continues under delegated judgment when evidence settles the brief and outline.

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

Run `./scripts/audit.sh` for a read-only JSON inventory of installed packages, skill hashes, plugin cache versions, and source-mirror commits/dirty status. The captured baseline is `manifests/local-state.json`; compare it with fresh output, ignoring `observed_at`. The audit excludes credentials and private runtime configuration values except allowlisted model, reasoning effort, feature flags, and known native plugin booleans, and known MCP enabled flags. It records rule/template presence separately from activation. Remote plugin cache presence and native plugin enabled flags do not establish session exposure or hook trust.

Both Codex config examples capture the reviewed local model, MCP commands, project trust entries, and tool approval policies. They contain machine-specific paths and require review before use elsewhere. UI counters and hook trust state are excluded. Review new or changed hook definitions using `/hooks`; hook installation does not establish trust. Hook logs retain timestamps, event names, decisions, and fixed reasons, with no prompt, command, tool-output, or transcript payloads. Secret detection remains a heuristic safety net, and the Stop evidence check requests at most one correction per turn.

Claude currently has local skill fallbacks and a `CLAUDE.md.template`; neither an active `~/.claude/CLAUDE.md` nor `settings.json` is present. The template is a proposed integration, not evidence that Claude loads shared rules.

`./scripts/verify.sh` checks syntax, skill projections, and disposable behavioral fixtures for hooks, staged-content scanning, config preservation, and offline install/reinstall. It does not read live hook logs or depend on source-mirror cleanliness. See [the assessment](docs/assessment.md) for current findings, source guidance, and verification limits.

## NPM Status

NPM is required by the current Codex setup because:

- Codex is installed globally as `@openai/codex`.
- MCP servers are configured via `npx`.

It is not treated as a generic platform dependency beyond Codex/MCP.
