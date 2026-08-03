# Agent-Ready CLI Assessment Rubric

Use evidence from source, tests, captured streams, and no-side-effect execution. Do not award a level from documentation or flag names alone. Mark missing evidence `unknown` and score it as 0 until verified.

## Levels

- **0 — absent or unknown**: no verified support.
- **1 — partial**: works on a subset of commands or relies on conventions the agent must infer.
- **2 — complete**: consistent, documented, and contract-tested across the relevant surface.
- **3 — defended**: complete plus adversarial tests, safe defaults, and drift/parity controls.

## Axes

| Axis | 1 — Partial | 2 — Complete | 3 — Defended |
| --- | --- | --- | --- |
| Machine interface | Some JSON output | Stable structured success/errors, clean streams, exit contract | Non-TTY defaults or explicit machine mode plus NDJSON streaming and schema drift tests |
| Expressive input | JSON on some writes | Full nested params/body on all API-backed operations with defined precedence | Size/depth limits, canonical parsing, request-builder parity, and raw-path bypass tests |
| Runtime discoverability | Partial JSON help/describe | Complete machine schema with types and required fields | Live/generated versioned schema with enums, scopes, nested references, and drift detection |
| Context economy | Some limits or field selection | Bounded lists, continuations, projections, explicit expansion | Incremental streaming, hard page/byte caps, partial-failure semantics, and skill guidance |
| Input hardening | Generic type validation | Control, traversal, resource-ID, encoding, and output-root checks before I/O | Canonicalization/symlink/SSRF fuzz corpus with proof no transport or file write occurred |
| Mutation safety | Dry-run on some writes | Dry-run on every mutation with explicit narrow write verbs | Request parity, redaction, idempotency/concurrency controls, and zero-side-effect proof |
| Response trust | Ad hoc redaction | Secrets redacted and remote text explicitly delimited as untrusted data | Sanitization or equivalent policy tested with prompt-injection, huge, malformed, and control-data fixtures |
| Knowledge and surface parity | Basic context file | Discoverable focused skills; CLI/MCP share schema and validation | Generated/versioned skills or parity checks prevent drift across CLI, MCP, extensions, and automation |

## Mandatory gates

Call the CLI **agent-ready** only when all of the following are verified:

- machine interface, expressive input, runtime discoverability, and context economy are at least level 2;
- input hardening and mutation safety are at least level 2;
- no destructive command lacks dry-run or an equivalent provider preview;
- secret-redaction tests pass;
- external content has an explicit untrusted-data boundary;
- every `unknown` affecting auth, mutation, filesystem writes, or raw/MCP bypasses is resolved.

Call the CLI **agent-first** only when every axis is at least level 2 and at least six axes are level 3, including input hardening and mutation safety.

## Report format

For each axis, report:

```text
Axis:
Level:
Evidence:
Unknowns:
Risk:
Smallest next improvement:
Verification command or test:
```

Finish with:

- readiness label: human-only, agent-tolerant, agent-ready, or agent-first;
- mandatory-gate failures;
- top three improvements ordered by risk reduction and dependency;
- compatibility and rollback notes;
- exact verification evidence needed to change the rating.

Do not average away a zero on a security or mutation axis. A total score may be included as a secondary summary (`0–24`), never as the readiness decision.
