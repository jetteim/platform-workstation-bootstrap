# External Dependencies

## Forks

The bootstrap process expects these forks to exist and stay synced.

| Upstream | Fork | Why |
| --- | --- | --- |
| `obra/superpowers` | `jetteim/superpowers` | Superpowers skills, including `brainstorming` |
| `openai/skills` | `jetteim/skills` | OpenAI curated skills cache source |
| `openai/codex` | `jetteim/codex` | Codex CLI source/reference |
| `microsoft/playwright-mcp` | `jetteim/playwright-mcp` | `@playwright/mcp` repository |
| `modelcontextprotocol/servers` | `jetteim/servers` | MCP reference server repository |
| `diana-random1st/brain-skill` | `jetteim/brain-skill` | Optional local micro-model training skill |

`scripts/refresh-github.sh` creates or syncs these forks. `scripts/install-skills.sh` then clones or updates the forks into the local source mirror locations below.

| Fork | Local path | Role |
| --- | --- | --- |
| `jetteim/superpowers` | `~/.codex/superpowers` | Live native Codex skill source via `~/.agents/skills/superpowers` symlink |
| `jetteim/skills` | `~/.codex/vendor_imports/skills` | OpenAI skills provenance and reinstall source |
| `jetteim/codex` | `~/.codex/vendor_imports/repos/codex` | Codex source/reference mirror |
| `jetteim/playwright-mcp` | `~/.codex/vendor_imports/repos/playwright-mcp` | Playwright MCP source/reference mirror |
| `jetteim/servers` | `~/.codex/vendor_imports/repos/servers` | MCP reference server source mirror |
| `jetteim/brain-skill` | `~/.codex/vendor_imports/repos/brain-skill` | Brain skill source mirror; installs `skill/` to `~/.codex/skills/brain` |

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

- Superpowers local commit: `917e5f53b16b115b70a3a355ed5f4993b9f8b73d`
- OpenAI skills local commit: `0ed2046f287a92b5f4bcace213dcb3cc5f094cb9`
- Codex source mirror commit: `be13f03c396b54b85b858bd023bf930b06164e33`
- Playwright MCP source mirror commit: `d3782155c40aabc3945673998bdbae83cb0dc94c`
- MCP servers source mirror commit: `f4244583a6af9425633e433a3eec000d23f4e011`
- Brain skill source mirror commit: `73789527637114b2a3745b2da9afa64fa8c1b7fa`
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

`skills/superpowers/` comes from local Superpowers commit `917e5f53b16b115b70a3a355ed5f4993b9f8b73d`.

`skills/codex/` comes from the local Codex user skill directory, including system skills and installed document/spreadsheet/PDF/notebook skills.

`skills/codex/brain/` comes from `jetteim/brain-skill` commit `73789527637114b2a3745b2da9afa64fa8c1b7fa`.

`skills/plugins/github/` and `skills/plugins/google-drive/` come from the enabled OpenAI-curated plugin cache.

The vendored bundles are fallback/bootstrap material. Prefer refreshing the upstream forks first, then use these copies when a clean machine has not yet populated Codex skills or plugin caches.

For the line-by-line comparison with original install instructions, see `docs/original-install-comparison.md`.
