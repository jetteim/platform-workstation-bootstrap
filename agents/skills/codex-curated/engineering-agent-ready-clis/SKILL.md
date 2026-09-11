---
name: engineering-agent-ready-clis
description: Design, review, retrofit, and test command-line interfaces that AI agents can use predictably and safely. Use when creating or auditing a CLI, exposing an API through a CLI or MCP server, adding structured JSON or NDJSON I/O, raw payload support, runtime schema discovery, bounded responses, headless authentication, adversarial input validation, dry-run behavior, response sanitization, agent skills, or an agent-readiness migration plan.
---

# Engineer Agent-Ready CLIs

Treat the agent as a fast, fallible, untrusted operator. Preserve human ergonomics, but build a deterministic machine contract and defense-in-depth underneath it.

Read [references/agent-cli-contract.md](references/agent-cli-contract.md) before designing, implementing, or reviewing a CLI. Read [references/assessment-rubric.md](references/assessment-rubric.md) when scoring readiness or prioritizing retrofit work.

## Establish the target

Classify the task as one or more of:

- **Design**: define a new command and machine interface.
- **Retrofit**: add agent-safe paths without breaking the human interface.
- **Audit**: collect evidence and identify gaps without changing code.
- **Verify**: test an implementation against explicit requirements.

Name the binary, source system, primary agent jobs, dangerous operations, auth model, and supported execution surfaces. Separate observed behavior, documented behavior, and proposed behavior.

Build toward these invariants:

1. Emit deterministic structured success and error output.
2. Accept expressive structured input without lossy flag translation.
3. Expose a machine-readable runtime contract.
4. Bound and project responses to protect agent context.
5. Reject hallucinated or adversarial inputs before I/O.
6. Preview every mutation without side effects.
7. Treat external response content as untrusted data.
8. Package non-obvious operating rules as discoverable skills.
9. Keep CLI, MCP, extension, and automation surfaces on one validated core contract.

## Gather evidence

Inspect the implementation, tests, generated API schema, and help output. Run only read-only, fixture-backed, or dry-run checks unless the user authorized a live write.

For an existing CLI, capture:

- top-level and command-level help;
- JSON success and failure examples with secrets removed;
- exit codes and stdout/stderr separation;
- auth precedence and noninteractive behavior;
- discovery, resolve, exact-read, bounded-list, write, and raw-request paths;
- schema or describe output;
- pagination, field selection, download/output-path behavior, and timeouts;
- validation location and proof that invalid input causes no network or file write;
- dry-run parity with live request construction;
- response sanitization or untrusted-content boundaries;
- shipped agent instructions and multi-surface parity.

Do not infer a capability from a flag name. Mark untested claims `unknown`.

## Design the command contract

Sketch the surface before coding. Prefer composable product nouns and narrow verbs:

```text
tool --json doctor
tool --json accounts list --limit 20
tool --json channels resolve --name alerts
tool --json messages get <id> --fields id,subject
tool --json drafts create --body-file request.json --dry-run
tool --json schema messages.create
tool --json request get /v1/me
```

Include:

- discovery commands for top-level containers;
- resolve commands that turn user input into stable IDs;
- exact reads and bounded list/search commands;
- one explicit verb per write action;
- a raw API escape hatch that retains validation, auth, redaction, and error handling;
- `doctor` that reports setup state without revealing credentials;
- raw payload and convenience-flag precedence rules;
- stable JSON envelopes, documented exit codes, and stdout/stderr rules.

Do not hide mutations behind broad verbs such as `fix`, `auto`, or `debug`.
Expose raw reads first. Reject raw mutations until they share the typed commands' validation, dry-run, confirmation, authorization, redaction, and timeout policies.

## Implement in risk order

For a retrofit, prefer this sequence:

1. Add stable JSON success and error output.
2. Harden inputs and output paths before adding reach.
3. Add `schema`, `describe`, or JSON help.
4. Add field projection, bounded pagination, and streaming.
5. Add side-effect-free dry-run to every mutation.
6. Ship focused agent skills that encode invariants and safe ordering.
7. Add MCP or other typed surfaces from the same schema and validation core.
8. Add response sanitization or an explicit untrusted-content boundary.

Keep human convenience flags and output where useful. Provide an agent path in the same binary rather than forcing a separate implementation.

Support an explicit output selector such as `--output json`. Where it fits the existing CLI, also support a documented environment setting or structured output by default when stdout is not a TTY. Never make output-mode inference ambiguous.

## Verify adversarially

Test the exact acceptance cases in the contract reference. At minimum, verify:

- JSON parses on success, empty results, and every error class;
- machine stdout contains no progress text, color, or prompts;
- pagination is bounded by default and streamable when expanded;
- structured payloads preserve nested values and reject ambiguous flag conflicts;
- traversal, control characters, embedded query/fragment markers, and pre-encoded path segments fail before I/O;
- output paths remain inside the allowed root after canonicalization;
- dry-run performs the same validation and request construction without provider calls or local writes;
- auth diagnostics expose source category, never secret values;
- hostile remote text stays bounded, terminal-safe data and cannot become agent instructions;
- CLI and typed surfaces apply the same validation and authorization rules.

Use fixtures or an instrumented fake transport to prove “before I/O” and “zero side effects.” Fuzz the input boundary after deterministic cases pass.

## Assess and hand off

Apply the evidence-gated rubric. A high total cannot compensate for missing mutation safety or input hardening.

Return the smallest useful artifact set:

- intent and primary agent jobs;
- observed capability matrix with evidence and unknowns;
- target command contract;
- requirement and acceptance-test mapping;
- threat model for input hallucination and response prompt injection;
- prioritized retrofit plan with compatibility and rollback notes;
- verification commands and results.

Do not call a CLI agent-ready until all mandatory readiness gates have verified evidence.
