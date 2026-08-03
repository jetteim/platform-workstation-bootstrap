# Agent-Ready CLI Contract

## Contents

1. Intent
2. Capability model
3. Command surface
4. Functional requirements
5. Security requirements
6. Operational and quality requirements
7. Acceptance test matrix
8. Retrofit order
9. Sources and provenance

## Intent

Optimize the machine path for predictability, expressiveness, bounded context use, and defense-in-depth. Keep human discoverability and convenience as an independent concern. Assume an agent can act quickly with malformed, hallucinated, double-encoded, or instruction-bearing data; make the CLI the enforcement boundary.

The target is not merely “JSON output.” It is an end-to-end contract covering discovery, input, validation, request construction, mutation preview, response handling, auth, knowledge packaging, and typed integrations.

## Capability model

| Capability | Features | Outcome |
| --- | --- | --- |
| Deterministic machine I/O | JSON/NDJSON, structured errors, clean stdout, stable exit codes | Parse without heuristics |
| Expressive request input | Full JSON params/body via flag, file, or stdin; convenience flags retained | Preserve nested API semantics |
| Runtime contract discovery | `schema`, `describe`, or JSON help with types, required fields, scopes, and enums | Avoid stale, preloaded documentation |
| Context economy | Field masks, bounded lists, cursors, explicit page caps, incremental streaming | Limit token and memory use |
| Agent-specific input hardening | Canonical paths, safe output root, control-character rejection, resource-ID validation, one-time URL encoding | Stop hallucinations before I/O |
| Mutation control | Narrow write verbs, dry-run/preview, explicit target, idempotency where supported | Validate safely before acting |
| Response trust boundary | Untrusted-data labeling, sanitization policy, redaction, bounded excerpts | Reduce prompt-injection and secret exposure |
| Agent knowledge packaging | Focused `SKILL.md` bundles with safe ordering and invariants | Provide procedural knowledge at invocation time |
| Multi-surface parity | CLI, MCP stdio JSON-RPC, extensions, and automation adapters generated from one core schema | Avoid drift and shell ambiguity |
| Headless operation | Environment or credential-file auth, service identities, noninteractive diagnostics | Work without browser or TTY |

## Command surface

Prefer a discover → resolve → read/context → draft/preview → write flow.

- `doctor`: report version, config presence, auth source category, endpoint reachability, and missing setup. Never print a secret.
- `list`/`search`: default to a small limit and return a continuation value.
- `resolve`: convert names, URLs, slugs, or permalinks to stable resource IDs.
- `get`/`context`: retrieve exact objects or a bounded neighborhood around an anchor.
- explicit writes: use verbs such as `create`, `update`, `delete`, `upload`, `schedule`, `retry`, or `submit`.
- `schema`/`describe`: return the effective machine contract at runtime.
- `request`/`api`: provide a raw escape hatch without bypassing auth, validation, redaction, timeouts, or error normalization. Start read-only; enable raw mutations only after mutation-policy parity is verified.

Use one source of truth for command metadata, schema output, request validation, MCP tool definitions, and skill generation where practical.

## Functional requirements

| ID | Requirement | Minimum acceptance evidence |
| --- | --- | --- |
| F-01 | Support structured output on every agent-relevant command through an explicit selector such as `--output json`; optionally support a documented environment setting or structured non-TTY default. | Success, empty, and failure samples parse as JSON in every supported selection path. |
| F-02 | Define a stable JSON envelope or documented API pass-through policy. | Schema and examples cover success and errors. |
| F-03 | Emit one complete JSON value, or one documented NDJSON value per record/page. | A streaming parser consumes output incrementally. |
| F-04 | Send only result data to stdout in machine mode; send diagnostics to stderr. | Captured streams show no contamination. |
| F-05 | Accept full nested params and request bodies via JSON flag, file, or stdin for API-backed operations. | A nested fixture reaches the request builder without loss. |
| F-06 | Keep convenience flags if useful and define conflicts and precedence. | Ambiguous mixed input fails with a structured error. |
| F-07 | Expose machine-readable command or API schemas at runtime. | Output includes types, required fields, enums, nested shapes, and auth scopes when available. |
| F-08 | Support field projection on reads when the provider supports it. | Tests prove omitted fields are not returned. |
| F-09 | Bound list/search breadth by default and expose cursor/offset plus explicit page or item caps. | Unqualified list cannot fetch without bound. |
| F-10 | Stream expanded pagination as NDJSON or an equivalently incremental format. | Multiple pages are processed without a top-level aggregate buffer. |
| F-11 | Provide a fully local, side-effect-free dry-run or preview for every mutation. | Instrumentation records no provider call, remote mutation, or output-file write. |
| F-12 | Make dry-run run the same parsing, validation, resolution, and request construction as live mode. | Planned request equals the live request fixture except execution metadata. |
| F-13 | Provide noninteractive `doctor` diagnostics even when auth is missing. | Missing auth returns structured remediation, not a prompt or crash. |
| F-14 | Ship focused, versioned, discoverable skills for repeated workflows, API surfaces, and non-obvious invariants such as field projection, dry-run, and user confirmation before writes/deletes. | A supported agent can discover and load the skill, and trigger tests exercise its safety rules. |
| F-15 | Generate typed agent surfaces such as MCP stdio JSON-RPC tools from the same effective contract when MCP or extensions exist. | Contract tests show CLI/MCP request parity. |

## Security requirements

| ID | Requirement | Minimum acceptance evidence |
| --- | --- | --- |
| S-01 | Treat all agent input and remote response content as untrusted. | Threat model covers both request and response directions. |
| S-02 | Canonicalize filesystem paths and confine writes to an explicit allowed root, normally the working directory. | Absolute, relative, symlink, and encoded traversal cases stay contained or fail. |
| S-03 | Reject disallowed control characters before logging, file access, or network access. | Tests cover NUL and non-whitespace C0 controls. |
| S-04 | Validate resource IDs and path segments against their schema; reject embedded query/fragment markers and unexpected pre-encoding. | Cases containing `?`, `#`, and disallowed `%` fail before transport. |
| S-05 | Perform URL path-segment encoding exactly once at the HTTP boundary. | Fixtures distinguish raw legal values from double-encoded inputs. |
| S-06 | Validate host, scheme, and base-path overrides; do not let an ID become an arbitrary URL. | SSRF-style and base-path escape cases fail. |
| S-07 | Keep secrets out of arguments by default, stdout, stderr, JSON errors, logs, dry-run output, and telemetry. | Canary credentials do not appear in captured artifacts. |
| S-08 | Prefer environment, credential-file, provider-default, or service-identity auth suitable for headless use. | Noninteractive auth path works without browser redirection. |
| S-09 | Redact or sanitize remote content before it enters agent context when the threat warrants it; otherwise bound it, neutralize terminal controls, and label and delimit it explicitly as untrusted data. | Prompt-injection, ANSI/control-data, and oversized fixtures remain inert and identifiable as data. |
| S-10 | Apply the same validation, authorization, redaction, and mutation policy to raw and typed surfaces. | Bypass tests against raw API and MCP paths fail safely. |
| S-11 | Require an explicit resource target and matching noninteractive confirmation for destructive actions; support provider idempotency or optimistic concurrency when available. | Wrong-target and retry/conflict tests cannot delete, duplicate, or overwrite silently. |

## Operational and quality requirements

| ID | Requirement | Minimum acceptance evidence |
| --- | --- | --- |
| Q-01 | Keep output schemas deterministic and versioned or backward-compatible. | Golden/contract tests detect shape drift. |
| Q-02 | Use documented nonzero exit codes for invalid input, auth, network, provider, parse, and incomplete-transfer failures. | Test matrix asserts each class. |
| Q-03 | Disable prompts, pagers, color, and interactive auth in machine mode. | Non-TTY smoke test completes unattended. |
| Q-04 | Bound retries, timeouts, pages, bytes, and concurrency; make expansion explicit. | Defaults and maximums appear in schema/help and tests. |
| Q-05 | Include request/resource IDs and safe remediation in errors without leaking payloads or credentials. | Failure fixtures are actionable and redacted. |
| Q-06 | Keep schema introspection current with the effective provider/API version. | Version drift test or generated-contract check exists. |
| Q-07 | Install the binary on `PATH` and smoke-test it outside its source directory. | `command -v`, help, and `doctor` pass from a temporary directory. |
| Q-08 | Preserve existing human behavior or document intentional compatibility changes during retrofit. | Before/after compatibility tests pass or migration is explicit. |

## Acceptance test matrix

Use a fake transport, fixtures, and a temporary output root for deterministic proof.

| Area | Cases |
| --- | --- |
| Output | success, empty, validation error, auth error, provider error, interrupted stream, no ANSI/progress on stdout |
| Input | nested arrays/objects, Unicode, stdin/file input, malformed JSON, raw-plus-convenience conflict, oversized body |
| Schema | every command represented, required fields, enums, nested references, scopes, schema/API version |
| Breadth | default limit, explicit limit, cursor resume, max pages, partial-page failure, NDJSON validity |
| Paths | `../`, absolute path, symlink escape, encoded traversal, nonexistent parent, allowed in-root path |
| Resource IDs | query marker, fragment marker, percent encoding, control characters, legal reserved-looking value defined by schema |
| Dry-run | invalid request, valid create/update/delete, generated ID resolution, zero transport mutation, redacted output |
| Responses | huge object projection, secret redaction, HTML/control data, embedded prompt injection, binary/download metadata |
| Auth | missing, env, credential file, provider default, conflicting sources, expired credential, no browser/TTY |
| Surface parity | CLI versus MCP schema, validation failure, auth, error envelope, dry-run, raw escape hatch |
| Packaging | skill discovery, trigger examples, safe ordering, field-mask rule, write-approval rule, stale-command detection |

Fuzz after the deterministic corpus passes. Seed fuzzing with traversal variants, mixed encodings, delimiters, C0 controls, very long identifiers, and nested JSON depth/size limits.

## Retrofit order

1. Structured output and errors.
2. Input and path hardening.
3. Runtime schema discovery.
4. Field projection and bounded/streaming pagination.
5. Dry-run for every mutation.
6. Agent knowledge packaging.
7. MCP or other typed integration from the same core.
8. Response sanitization and explicit untrusted-data boundaries.

Ship each step with contract tests. Do not expand mutation reach before its validation and dry-run boundary exists.

## Sources and provenance

This contract synthesizes:

- Justin Poehnelt, [You Need to Rewrite Your CLI for AI Agents](https://justin.poehnelt.com/posts/rewrite-your-cli-for-ai-agents/), March 4, 2026. The article is published under CC BY-SA 4.0 and supplies the core intent, retrofit sequence, and agent-specific failure model.
- Justin Poehnelt, [`agent-dx-cli-scale`](https://github.com/jpoehnelt/skills/tree/main/agent-dx-cli-scale). Its useful contribution is a reusable multi-axis readiness assessment; this skill uses independently written requirements and adds evidence gates.
- OpenAI, [`cli-creator`](https://github.com/openai/skills/tree/main/skills/.curated/cli-creator). Useful additions include discover/resolve/read/write command composition, `doctor`, stable JSON/error contracts, bounded pagination, auth precedence, raw escape hatches, and out-of-tree smoke testing.

Treat these sources as design evidence. Verify requirements against the target CLI and provider instead of assuming every API supports every feature.
