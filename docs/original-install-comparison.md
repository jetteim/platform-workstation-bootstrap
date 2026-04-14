# Original Install Comparison

Date checked: 2026-04-11

This compares the bootstrap repository against the current install instructions in the original dependency repositories. The clean-machine rule is:

1. Refresh GitHub forks.
2. Install from forked source repositories where the original project expects a clone.
3. Configure package-based tools exactly as their original docs recommend.
4. Use vendored skill copies only as fallback or to recreate the current local user overlay.

## Agent-Agnostic Bootstrap

The current bootstrap installs `~/.agents` first, then projects compatible assets into Codex and Claude. Codex remains a supported adapter, not the canonical model for shared rules, skills, hooks, prompts, or source mirrors.

## Superpowers

Original source: <https://github.com/obra/superpowers/blob/main/.codex/INSTALL.md>

Original Codex install:

```bash
git clone https://github.com/obra/superpowers.git ~/.codex/superpowers
mkdir -p ~/.agents/skills
ln -s ~/.codex/superpowers/skills ~/.agents/skills/superpowers
```

Then restart Codex. For subagent skills, the Codex guide also documents:

```toml
[features]
multi_agent = true
```

Bootstrap match:

- Uses the fork `https://github.com/jetteim/superpowers.git` as the primary clone source.
- Keeps the source checkout at `~/.codex/superpowers`.
- Installs canonical Superpowers into `~/.agents/skills/superpowers` as a real directory on fresh installs.
- Replaces a legacy `~/.agents/skills/superpowers` symlink with a canonical real directory during migration.
- Stages and syncs managed skill projections so removed files from the source tree are pruned on reinstall.
- Refuses unsafe `AGENTS_HOME`, `CODEX_HOME`, and `CLAUDE_HOME` overrides before creating directories.
- Sets `features.multi_agent = true` alongside `features.codex_hooks = true`.
- Uses vendored `skills/superpowers/` only if no usable clone exists and `USE_VENDORED_FALLBACK=1`.

Important: the installer does not force-reset an existing dirty `~/.codex/superpowers` checkout. It skips repo refresh in that case so local edits are not discarded. For source-backed skills under `~/.agents/vendor_imports/repos`, dirty mirrors are not used as install inputs; vendored canonical copies are used instead.

## OpenAI Skills

Original source: <https://github.com/openai/skills>

Original install model:

- `skills/.system` skills are installed automatically by recent Codex versions.
- Curated and experimental skills are installed through `$skill-installer`.
- Restart Codex after adding skills.

Bootstrap match:

- Refreshes the fork `https://github.com/jetteim/skills.git` into `~/.agents/vendor_imports/skills` for provenance and future reinstall work.
- Installs the currently captured local Codex skill overlay from `skills/codex/` into `~/.codex/skills`.
- Keeps the vendored overlay explicit because this repo is meant to reproduce the current workstation, not only the default Codex distribution.

Intentional difference: installing `skills/codex/` may overwrite user-level copies of system skills. That is acceptable for this bootstrap because the repo is the declared source of truth for this workstation profile. A future stricter mode can skip `.system` and rely fully on Codex's built-in system skills.

## Codex CLI

Original source: <https://github.com/openai/codex>

Original install options:

```bash
npm install -g @openai/codex
brew install --cask codex
```

Bootstrap match:

- Does not install Codex itself. Codex is a prerequisite for running this repo through Codex.
- Records the current source fork at `https://github.com/jetteim/codex.git`.
- Mirrors that fork to `~/.agents/vendor_imports/repos/codex` for clean-machine source reference.
- Preserves the current operational path where npm supplies `@openai/codex`.

## Playwright MCP

Original source: <https://github.com/microsoft/playwright-mcp>

Original Codex install:

```bash
codex mcp add playwright npx "@playwright/mcp@latest"
```

Equivalent TOML:

```toml
[mcp_servers.playwright]
command = "npx"
args = ["@playwright/mcp@latest"]
```

Bootstrap match:

- Keeps Playwright MCP package execution through `npx`.
- Uses `args = ["-y", "@playwright/mcp@latest"]` in the example config so a fresh npm cache does not prompt interactively.
- Mirrors `https://github.com/jetteim/playwright-mcp.git` under `~/.agents/vendor_imports/repos/playwright-mcp` for source provenance.

## MCP Reference Servers

Original source: <https://github.com/modelcontextprotocol/servers>

Original TypeScript server usage:

```bash
npx -y @modelcontextprotocol/server-memory
```

Original MCP client config pattern:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

Bootstrap match:

- Uses `npx -y @modelcontextprotocol/server-memory`.
- Uses `npx -y @modelcontextprotocol/server-github`.
- Mirrors `https://github.com/jetteim/servers.git` under `~/.agents/vendor_imports/repos/servers`.

Note: `@modelcontextprotocol/server-github` did not expose repository metadata in npm during the original assessment. The package still follows the MCP server package pattern and is documented as an npm package dependency.

## OpenAI-Curated Plugins

Current Codex config:

```toml
[plugins."github@openai-curated"]
enabled = true

[plugins."google-drive@openai-curated"]
enabled = true
```

Bootstrap match:

- Keeps plugin enablement in `codex/config.example.toml`.
- Vendors plugin skill fallback copies under `skills/plugins/`.
- Installs fallback copies to `~/.agents/skills/plugin-github` and `~/.agents/skills/plugin-google-drive`.

Intentional difference: plugin fallback skills are not a replacement for enabling plugins. They only preserve the local skill instructions if plugin cache hydration changes or is temporarily unavailable.

## Brain Skill

Original source: <https://github.com/diana-random1st/brain-skill>

Original install:

```bash
git clone https://github.com/diana-random1st/brain-skill.git
cd brain-skill && ./install.sh
```

Original installer behavior:

- If `~/.claude/skills` exists, install to `~/.claude/skills/brain`.
- Else if `~/.codex/skills` exists, install to `~/.codex/skills/brain`.
- Else create `~/.claude/skills` and install there.
- Copy the repository `skill/` directory into the target.

Bootstrap match:

- Uses the fork `https://github.com/jetteim/brain-skill.git`.
- Mirrors the full repo to `~/.agents/vendor_imports/repos/brain-skill`.
- Installs `skill/` to `~/.codex/skills/brain`, which matches the Codex branch of the original installer.
- Vendors the same `skill/` directory under `skills/codex/brain` for fallback installs.
- Keeps heavy ML prerequisites in explicit script `scripts/install-brain-prereqs.sh`.
- Mirrors `https://github.com/jetteim/llama.cpp.git` to `~/.agents/vendor_imports/repos/llama.cpp` for GGUF conversion.

Assessment and smoke-test results:

- `docs/brain-skill-assessment.md`
- `docs/brain-skill-smoke-test.md`

## Clean-Machine Sequence

Use this order:

```bash
gh auth login
./scripts/refresh-github.sh
./scripts/install.sh
./scripts/verify.sh
```

Restart Codex after `install.sh` so native skill discovery and plugin cache state are reloaded.

## Current Gaps To Keep Explicit

- Codex itself still needs one of the original install methods before this repo can be used interactively: npm, Homebrew cask, or release binary.
- npm is required by the current MCP setup because `npx` launches Playwright, GitHub, and memory MCP servers.
- The installer intentionally avoids force-resetting dirty source mirrors. If a clean reinstall is required, inspect the dirty checkout and clean it manually before rerunning the installer.
