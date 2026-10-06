# Bootstrap maintenance

Use `agents/skills/platform` and `agents/skills/codex-curated` as the reviewed skill sources. Keep their union equal to `skills/codex`; plugin fallbacks live under `skills/plugins` and `agents/skills/plugins`. Native and remote plugin caches and the installed Codex `.system` directory belong to their providers. Exclude runtime system-skill markers from vendored snapshots.

Run `./scripts/verify.sh` for repository checks. It uses disposable fixtures and must not write to live agent homes. Run `./scripts/audit.sh` for a read-only workstation inventory; export only allowlisted metadata. A cache entry proves presence, not activation or hook trust.

Test installer changes with temporary homes and `SKIP_GITHUB_REFRESH=1 SKIP_SOURCE_REFRESH=1`. Back up managed live files before an authorized install. Do not refresh dependency forks merely to review local state.
