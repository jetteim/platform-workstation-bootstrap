# Local Setup Assessment

Date: 2026-04-11

## Host

- OS: macOS 15.7.3, build 24G419
- Kernel: Darwin 24.6.0, arm64
- Homebrew: 5.0.16
- Git: Apple Git 2.50.1
- GitHub CLI: 2.87.3
- Codex CLI: 0.120.0

## Codex

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

`features.codex_hooks` was available but disabled at assessment time.

## Skills And Plugins

Local Superpowers source is mirrored at `~/.codex/superpowers/skills`. The agent-agnostic bootstrap migrates `~/.agents/skills/superpowers` to a real canonical directory and replaces legacy symlinks during install.

External provenance:

- Superpowers: `https://github.com/obra/superpowers.git`, local commit `eafe962b18f6c5dc70fb7c8cc7e83e61f4cdde06`
- OpenAI skills: `https://github.com/openai/skills.git`, local commit `c207989386b30063bcecaf6b1977d761b244732e`

Enabled OpenAI-curated plugins:

- GitHub
- Google Drive

## Git

Global Git config:

```text
core.hooksPath=/Users/maximlee/.config/git/hooks
```

No `/etc/gitconfig` system config was present.

Global `user.name` and `user.email` were not set. Keep that intentional if identity differs by repository.

The existing global `pre-commit` hook handled conflict markers, trailing whitespace, and several language linters. It did not scan secrets and did not delegate to repo-local hooks.

## Engineering Tools On PATH

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

## Runtime Package Managers

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
