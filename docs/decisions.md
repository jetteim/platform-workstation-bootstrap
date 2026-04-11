# Setup Decisions

## GitHub Refresh Comes First

Every clean-machine setup starts with:

```bash
./scripts/refresh-github.sh
```

Rationale:

- GitHub auth and fork availability are prerequisites for reproducible setup.
- Forks make the setup resilient if upstream repositories move, disappear, or change unexpectedly.
- Fork sync is cheap and makes later install steps deterministic.

## Keep Global Git Hooks Narrow

The global Git hook is a safety net, not a project CI replacement.

Global checks:

- High-confidence secret patterns.
- Private key blocks.
- Conflict marker blocks.
- Accidental secret file blocks.
- Oversized staged file warnings.
- Delegation to project-local hooks.

Project-local checks:

- Language linting.
- Formatting.
- Unit tests.
- Terraform plan validation.
- Repository-specific policy.

## Codex Hooks Default Policy

Codex hooks block only high-confidence risk:

- Prompt contains obvious credentials or private keys.
- Shell command prints or exfiltrates known credential files.
- Shell command is clearly destructive at filesystem root or system level.
- Shell command disables permissions broadly.

Everything else is logged and, when useful, sent back as advisory context.

## Reliability And Observability Bias

For platform engineering work, generated guidance should push toward:

- Evidence before success claims.
- Reproducible commands.
- Log paths and timestamps.
- Metrics, traces, spans, and alert names when debugging.
- Rollback and blast-radius notes for infra changes.
- Explicit caveats when verification was not run.

