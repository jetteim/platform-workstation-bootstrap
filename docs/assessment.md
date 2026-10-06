# Local Setup Assessment

## Reviewed state — 2026-10-06

Target: configured local skills, Codex harness assets, Claude fallback assets, and the global Git safety hook. The installed workstation is the evidence for current state; reviewed repository snapshots define the reinstall target. `manifests/local-state.json` was captured at `2026-10-06T12:45:47Z` after installation.

The final executable and npm inventory report Codex `0.160.1`, model `gpt-6.1-sol`, and high reasoning effort. All three reviewed feature flags and the GitHub, Google Drive, and Superpowers native plugins are enabled. There are 31 local Codex skills and 28 Claude fallback skills. Claude has a rule template, with no active user `CLAUDE.md` or settings file. Remote cache versions are recorded as presence, not activation. Two source mirrors have existing local changes: `platform-reliability-model` and `reliability-engineering`; they were preserved.

### Findings and changes

| Finding | Reviewed behavior |
| --- | --- |
| Broad CLI and model-training triggers; overlapping SLO ownership | Shorter descriptions; reliability owns objectives and error budgets, observability owns telemetry bindings, pipeline work has its own route. |
| Documentation outline approvals conflicted with delegated work | Consequential missing decisions still need dialogue; bounded updates and delegated judgment proceed through verification. |
| Full context map required for every edit | Exploration follows the size and dependencies of the requested change. |
| Source refresh could replace reviewed refinements | Repository snapshots install by default; `USE_SOURCE_SKILLS=1` is an explicit alternative. |
| Installer rewrote user feature and plugin choices | Parsed TOML defaults fill missing settings and preserve explicit choices; fixture reinstall verifies this. |
| Codex regenerates system skills at startup | Existing `.system` files survive reinstall. Runtime markers are excluded from vendored snapshots; the obsolete plugin-creator bundle remains in Git history. |
| Stop hook could repeatedly request continuation | Respect `stop_hook_active`; request at most one evidence correction per turn. Restore session context after compaction. |
| Logs stored redacted payloads; Git scanner wrote matches to temporary files | Hook logs keep decision metadata only. Staged blobs are scanned in memory with escaped filenames; matched content is neither printed nor persisted. |
| Archived GitHub reference server duplicated the native plugin | Set the previously absent legacy-server `enabled` flag to false; keep its connection settings and preserve any future explicit enable choice. |
| Verification coupled text assertions to live mirrors and logs | Eight disposable behavioral fixtures cover config preservation, hooks, staged secrets/conflicts/submodules, hook delegation, installer safety, projection parity, and reinstall pruning. |

The current [OpenAI skill guidance](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) supports focused descriptions, progressive disclosure, and task-sized instruction workflows. [Plugin skill guidance](https://developers.openai.com/plugins/build/skills) separates workflow instructions from live authentication and controlled actions. These informed trigger and ownership changes; provider plugin instructions remain provider-managed.

[Codex hook documentation](https://learn.chatgpt.com/docs/hooks) defines compaction matching, Stop continuation state, and hook trust review. Installation does not establish trust: review changed definitions with `/hooks`. [Claude guidance](https://code.claude.com/docs/en/best-practices) supports concise persistent rules and loading specialized skills on demand; the inactive template is reported separately. The [MCP reference project](https://github.com/modelcontextprotocol/servers#archived) lists the GitHub server as archived, while [GitHub maintains its own server](https://github.com/github/github-mcp-server).

### Verification and rollback

- `./scripts/audit.sh`: read-only inventory, captured before review and after install; the committed result is `manifests/local-state.json`.
- `SKIP_GITHUB_REFRESH=1 SKIP_SOURCE_REFRESH=1 USE_SOURCE_SKILLS=0 ./scripts/install.sh`: exit 0; output `/tmp/platform-bootstrap-install.log`. No dependency mirrors were refreshed.
- `./scripts/verify.sh`: exit 0, eight tests passed; output `/tmp/platform-bootstrap-verify.log`. Tests use temporary homes and Git configuration, without production access.
- Direct byte/hash comparisons: installed rules, hooks, prompts, local skill snapshots, Claude platform skills, and allowlisted configuration examples matched repository assets.
- Installer dry-run diff: only `mcp_servers.github.enabled` was added as false; other fields were equal. Final live configuration matched the allowlisted examples.
- Decision log: `~/.codex/hook-logs/YYYY-MM-DD.jsonl`; fields `ts`, `event`, `decision`, `reason`, and `invalid_payload`. No metrics or traces were involved in this review.
- Pre-change managed assets and a restore script: `/tmp/platform-bootstrap-rollback-20261006T123857Z/restore.py`. Run `python3` on that script to restore the managed files and remove the added legacy-server flag. It excludes credentials, live configuration contents, source mirrors, and old logs. This temporary backup is retained for rollback until the next validated reinstall.

Checks establish file/configuration parity and fixture behavior. They do not establish automatic skill-selection quality, remote plugin availability in every session, hook trust, or live MCP/API behavior. Routing examples in `docs/skill-trigger-examples.md` include positive and negative cases for future runtime evaluation. Existing hook logs were not inspected or altered. CLI startup changed provider-managed system skills during review, so the final snapshot was checked again rather than inferring permanent removal from an intermediate inventory.

## Historical assessment — 2026-04-11

The following records the original assessment and is superseded by the reviewed state above.

### Host

- OS: macOS 15.7.3, build 24G419
- Kernel: Darwin 24.6.0, arm64
- Homebrew: 5.0.16
- Git: Apple Git 2.50.1
- GitHub CLI: 2.87.3
- Codex CLI: 0.120.0

### Codex

Current user config is `~/.codex/config.toml`.

Observed settings:

- `model = "gpt-5.4"`
- `model_reasoning_effort = "high"`
- Trusted project roots:
  - `/Users/maximlee`
  - `/Users/maximlee/Library/CloudStorage/OneDrive-Personal/NEW_WORK`
  - `/Users/maximlee/Library/CloudStorage/OneDrive-Personal/Pet projects/telegram-message-cleaner`
  - `/Users/maximlee/Library/CloudStorage/OneDrive-Personal/Pet projects/video/poc-macbook`
- MCP servers:
  - `playwright`: `npx -y @playwright/mcp@latest`
  - `github`: `npx -y @modelcontextprotocol/server-github`
  - `memory`: `npx -y @modelcontextprotocol/server-memory`
- Plugins:
  - `github@openai-curated`
  - `google-drive@openai-curated`
  - `superpowers@openai-curated`

Hook feature flags were available but disabled at assessment time. Current bootstrap config uses `features.hooks`.

### Skills And Plugins

Superpowers is enabled through the native Codex plugin `superpowers@openai-curated`. The bootstrap no longer installs Superpowers from `~/.codex/superpowers` or projects it into local Codex skills.

External provenance:

- OpenAI skills: `https://github.com/openai/skills.git`, local commit `c207989386b30063bcecaf6b1977d761b244732e`

Enabled OpenAI-curated plugins:

- GitHub
- Google Drive
- Superpowers

### Git

Global Git config:

```text
core.hooksPath=/Users/maximlee/.config/git/hooks
```

No `/etc/gitconfig` system config was present.

Global `user.name` and `user.email` were not set. Keep that intentional if identity differs by repository.

The existing global `pre-commit` hook handled conflict markers, trailing whitespace, and several language linters. It did not scan secrets and did not delegate to repo-local hooks.

### Engineering Tools On PATH

Present:

- `terraform`
- `tflint`
- `go`
- `node`
- `npm`
- `python3`
- `pip3`
- `ruby`
- `gem`
- `make`
- `jq`
- `rg`
- `eslint`
- `markdownlint`
- `gh`
- `codex`

Not present at assessment time:

- `docker`
- `kubectl`
- `helm`
- `k9s`
- `stern`
- `kind`
- `minikube`
- `promtool`
- `otelcol`
- `k6`
- `shellcheck`
- `ruff`
- `gitleaks`
- `trufflehog`
- `detect-secrets`
- `pre-commit`
- `git-secrets`

### Runtime Package Managers

Homebrew formulae included:

- `gh 2.87.3`
- `go 1.26.0`
- `node@22 22.22.0`
- `ruby 4.0.1`
- `terraform 1.5.7`
- `tflint` installed via Go at `~/go/bin/tflint`
- `ripgrep 15.1.0`

Global npm packages:

- `@openai/codex@0.120.0`
- `eslint@10.0.2`
- `markdownlint-cli@0.48.0`

User pip packages:

- `pip 26.0.1`
- `pypdf 6.8.0`
- `Pyrogram 2.0.106`
- `TgCrypto 1.2.5`
