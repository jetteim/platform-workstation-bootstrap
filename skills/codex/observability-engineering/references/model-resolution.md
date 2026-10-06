# Model resolution

Use the caller's supplied checkout path first, or `OBSERVABILITY_MODEL_ROOT` when set. Do not interpret a repository URL as a local checkout or fetch a private repository as part of a skill invocation.

The packaged helper `scripts/resolve-model.py` emits bounded JSON and never writes or contacts a service. Pass `--root <path>` for an explicit checkout, or `--workspace-root <path>` to check a workspace. Otherwise it checks `${AGENTS_HOME:-$HOME/.agents}/vendor_imports/repos/platform-observability-model`, the current workspace, and the legacy `~/Library/CloudStorage/OneDrive-Personal/Pet projects/platform-observability-model` location.

An explicitly selected but unavailable checkout is an error: report that path and offer the bundled reference; do not silently substitute another private model. With no explicit location and no checkout, use the packaged model summary and state that fallback was used. Read only the applicable private usage scenario and intent files, never the whole model by default. A directory's presence is not evidence that every scenario exists; missing scenario files are a reported gap.

The helper validates a `docs/` directory for models. In reliability, `--kind engine` resolves `SRE_RULES_ENGINE_ROOT` or `slo-rules-engine` and checks executable `bin/rules-ctl`. An unavailable generator is a generation gap, not permission to invent executable provider output.
