# External Dependencies

## Forks

The bootstrap process expects these forks to exist and stay synced.

| Upstream | Fork | Why |
| --- | --- | --- |
| `openai/skills` | `jetteim/skills` | OpenAI curated skills cache source |
| `openai/codex` | `jetteim/codex` | Codex CLI source/reference |
| `microsoft/playwright-mcp` | `jetteim/playwright-mcp` | `@playwright/mcp` repository |
| `modelcontextprotocol/servers` | `jetteim/servers` | MCP reference server repository |
| `diana-random1st/brain-skill` | `jetteim/brain-skill` | Optional local micro-model training skill |
| `ggml-org/llama.cpp` | `jetteim/llama.cpp` | GGUF conversion/export tooling for brain-skill runs |

`scripts/refresh-github.sh` creates or syncs these forks. `scripts/install-skills.sh` then clones or updates the forks into the local source mirror locations below.

## Owned Repositories

The bootstrap also expects these owned repositories. They are not forks.

| Repository | Visibility | Why |
| --- | --- | --- |
| `jetteim/platform-observability-model` | Private | Platform-agnostic observability intent model |
| `jetteim/observability-engineering` | Public | Codex skill for building observability from the model |
| `jetteim/observability-pipeline-skills` | Public | Codex skill for tool-agnostic observability pipeline contracts |
| `jetteim/platform-reliability-model` | Private | Platform-agnostic reliability intent model |
| `jetteim/reliability-engineering` | Public | Codex skill for building reliability from the model |
| `jetteim/architectural-execution-skills` | Public | Codex skill pipeline from value stream and architecture to implementation |

| Fork | Local path | Role |
| --- | --- | --- |
| `jetteim/skills` | `~/.agents/vendor_imports/skills` | OpenAI skills provenance and reinstall source |
| `jetteim/codex` | `~/.agents/vendor_imports/repos/codex` | Codex source/reference mirror |
| `jetteim/playwright-mcp` | `~/.agents/vendor_imports/repos/playwright-mcp` | Playwright MCP source/reference mirror |
| `jetteim/servers` | `~/.agents/vendor_imports/repos/servers` | MCP reference server source mirror |
| `jetteim/brain-skill` | `~/.agents/vendor_imports/repos/brain-skill` | Brain skill source mirror; installs `skill/` to `~/.codex/skills/brain` |
| `jetteim/llama.cpp` | `~/.agents/vendor_imports/repos/llama.cpp` | llama.cpp source mirror for GGUF conversion |
| `jetteim/platform-observability-model` | `~/.agents/vendor_imports/repos/platform-observability-model` | Private source-of-truth observability model |
| `jetteim/observability-engineering` | `~/.agents/vendor_imports/repos/observability-engineering` | Observability engineering skill source mirror |
| `jetteim/observability-pipeline-skills` | `~/.agents/vendor_imports/repos/observability-pipeline-skills` | Observability pipeline skill source mirror |
| `jetteim/platform-reliability-model` | `~/.agents/vendor_imports/repos/platform-reliability-model` | Private source-of-truth reliability model |
| `jetteim/reliability-engineering` | `~/.agents/vendor_imports/repos/reliability-engineering` | Reliability engineering skill source mirror |
| `jetteim/architectural-execution-skills` | `~/.agents/vendor_imports/repos/architectural-execution-skills` | Architectural execution skills source mirror |

Canonical v1 skill sources are copied under `agents/skills/platform/`, `agents/skills/plugins/`, and `agents/skills/codex-curated/`. Superpowers is provided by the Codex plugin `superpowers@openai-curated`, not by a local source checkout.

`agents/skills/platform` includes the architectural execution pipeline: `orchestrating-architecture-execution`, value stream discovery, capability shaping, feature shaping, C4 modeling, story slicing, and traceability review.

The installer uses HTTPS clone URLs by default so a clean machine does not need SSH keys before bootstrap. GitHub CLI authentication is still required for fork refresh.

## NPM Packages

Current Codex MCP config uses:

- `@playwright/mcp@latest`
- `@modelcontextprotocol/server-github`
- `@modelcontextprotocol/server-memory`

The `@modelcontextprotocol/server-github` package did not expose repository metadata during assessment. It is documented as a package dependency and associated with the MCP server family.

## Pinning Policy

For repeatable setup:

- Prefer fork URL plus commit SHA for source dependencies.
- Prefer exact npm package versions for executable dependencies.
- Use `@latest` only for tools where freshness is intentionally preferred over repeatability.

Current local pins:

- OpenAI skills local commit: `4c4058ebf44f6734e62c70ab4a81246d4d093fc8`
- Codex source mirror commit: `5e3ee5eddfa5333f2e0b011880abf0cbf92bd295`
- Playwright MCP source mirror commit: `ae27b8638aaf3a6be17d378964ae683864d20440`
- MCP servers source mirror commit: `acedea0c24b3e20d7265f87b8b2afe2e0c6eb2f4`
- Brain skill source mirror commit: `73789527637114b2a3745b2da9afa64fa8c1b7fa`
- llama.cpp source mirror commit: `a9883db8ee021cf16783016a60996d41820b5195`
- Platform observability model mirror commit: `123d65763d84aec699fb6d2281e278df56e03625`
- Observability engineering skill mirror commit: `47c7cbae453fac68062796c3a110913e30483127`
- Observability pipeline skills mirror commit: `fbf6149ae62868ae6847cb0f3fd52459e5c62a46`
- Platform reliability model mirror commit: `9b56152c4cb716865dd2b196bcbb849d453f1df2`
- SLO rules engine mirror commit: `4a5260bfb03231c11ab8f847262b3a8ad579cd5b`
- Reliability engineering skill mirror commit: `6785e245425ef5c84c57270fffc352000c893b8c`
- Architectural execution skills mirror commit: `bb211111e000e679a8b5c12ea4cc9ae94790e719`
- Codex CLI npm package: `@openai/codex@0.120.0`
- Codex Homebrew cask present: `codex 0.111.0`
- Playwright MCP npm package: `@playwright/mcp@0.0.70`
- MCP memory server npm package: `@modelcontextprotocol/server-memory@2026.1.26`
- MCP GitHub server npm package: `@modelcontextprotocol/server-github@2025.4.8`

## Vendored Skill Bundles

This repository vendors full copies of the installed skill bundles so a clean machine can bootstrap from the repository even before plugin caches or external checkouts are populated.

Vendored paths:

```text
skills/superpowers/
skills/codex/
skills/plugins/github/
skills/plugins/google-drive/
```

`skills/superpowers/` is retained as archived fallback/reference material. The active Codex install path is the `superpowers@openai-curated` plugin.

`skills/codex/` comes from the local Codex user skill directory, including system skills and installed document/spreadsheet/PDF/notebook skills.

`skills/codex/brain/` comes from `jetteim/brain-skill` commit `73789527637114b2a3745b2da9afa64fa8c1b7fa`.

`skills/codex/observability-engineering/` comes from the local public skill repo and is installed as a fallback when the source mirror is unavailable.

`skills/codex/creating-observability-pipelines/` comes from the local public skill repo and is installed as a fallback when the source mirror is unavailable.

`skills/codex/reliability-engineering/` comes from the local public skill repo and is installed as a fallback when the source mirror is unavailable.

`skills/codex/orchestrating-architecture-execution/` and its companion value-stream, capability, feature, C4, story-slicing, and traceability skills come from `jetteim/architectural-execution-skills` and are installed as fallbacks when the source mirror is unavailable.

`skills/plugins/github/` and `skills/plugins/google-drive/` come from the enabled OpenAI-curated plugin cache.

The vendored bundles are fallback/bootstrap material. Prefer refreshing the upstream forks first, then use these copies when a clean machine has not yet populated Codex skills or plugin caches.

Managed skill destinations are synced from staged bootstrap trees, not overlaid indefinitely. Reinstalling prunes files that were removed from the managed source bundles.

Dirty source mirrors are preserved but skipped as install inputs. This prevents local mirror edits from leaking into projected skills while keeping those edits available for manual recovery.

For the line-by-line comparison with original install instructions, see `docs/original-install-comparison.md`.
