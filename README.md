# Platform Workstation Bootstrap

Reproducible setup notes and guardrails for my macOS platform engineering workstation.

This repository is intentionally explicit about:

- Codex configuration, hooks, skills, plugins, and MCP dependencies.
- User-wide Git safety hooks.
- Reliability and observability-oriented defaults.
- External dependency forks to use on a clean development machine.

It is not a dotfiles dump. Secrets, tokens, auth databases, shell history, browser state, and live Codex transcripts must stay out of this repository.

## First Step

Always refresh GitHub and dependency forks first:

```bash
./scripts/refresh-github.sh
```

That script checks `gh auth status`, creates missing forks, and syncs known dependency forks from upstream.

## Install

```bash
./scripts/install.sh
./scripts/verify.sh
```

`install.sh` installs:

- `~/.codex/hooks.json`
- `~/.codex/hooks/*.py`
- `~/.config/git/hooks/pre-commit`
- `git config --global core.hooksPath ~/.config/git/hooks`

It does not overwrite live credentials or private config files.

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

`install.sh` installs vendored local Codex skills into `~/.codex/skills`, installs Superpowers skills into `~/.codex/superpowers/skills` on clean machines, and places plugin-skill fallbacks under `~/.agents/skills`.

## Important Repositories

The clean-machine path depends on these forks:

| Purpose | Upstream | Fork |
| --- | --- | --- |
| Codex CLI source/reference | `openai/codex` | `jetteim/codex` |
| OpenAI curated skills | `openai/skills` | `jetteim/skills` |
| Superpowers skills, including full brainstorming bundle | `obra/superpowers` | `jetteim/superpowers` |
| Playwright MCP server | `microsoft/playwright-mcp` | `jetteim/playwright-mcp` |
| MCP reference servers | `modelcontextprotocol/servers` | `jetteim/servers` |

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
