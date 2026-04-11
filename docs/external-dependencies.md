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

- Superpowers local commit: `eafe962b18f6c5dc70fb7c8cc7e83e61f4cdde06`
- OpenAI skills local commit: `c207989386b30063bcecaf6b1977d761b244732e`
- Codex CLI npm package: `@openai/codex@0.120.0`
- Playwright MCP npm package: `@playwright/mcp@0.0.70`
- MCP memory server npm package: `@modelcontextprotocol/server-memory@2026.1.26`
- MCP GitHub server npm package: `@modelcontextprotocol/server-github@2025.4.8`

