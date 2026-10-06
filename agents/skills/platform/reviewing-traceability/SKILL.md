---
name: reviewing-traceability
description: Check coherence between supplied outcome, architecture and delivery artifacts before execution; identify gaps and orphan decisions.
---

# Reviewing Traceability

Preserve the supplied artifact structure and selected abstraction level. Produce only what the current decision needs; one complete story or brief can be sufficient. Existing authorization covers routine local implementation and verification. Ask only about unresolved material choices or an expanded action.


## Overview

Use this skill as the integrity gate before implementation. The goal is not bureaucracy; it is to catch orphan work, missing architecture impact, vague value, and context overload before coding starts.

Use `superpowers:verification-before-completion` when installed; otherwise use an equivalent evidence-before-claims workflow before claiming the review is complete.

## Review Matrix

Create or inspect a compact matrix:

| Story / Plan Task | Feature | Capability | Value Outcome | C4 Element | Test / Evidence |
| --- | --- | --- | --- | --- | --- |
| <story or task> | <feature> | <capability> | <measure> | <container/component/relationship> | <test, metric, demo, command> |

## Checks

- Upward trace: each story or task traces to its supplied parents and intended value; absent hierarchy levels are not invented.
- Downward trace: every selected capability has at least one feature or an explicit reason to defer.
- Architecture trace: every feature with C4 impact has a view, decision, or explicit no-diagram rationale.
- NFR trace: every security, reliability, performance, compliance, or operability constraint has a test, review, or verification hook.
- Context budget: the selected active slice is understandable; retain the full backlog without imposing a numeric correctness gate.
- Enabler legitimacy: enabler work unblocks value, reduces delivery risk, or satisfies an explicit NFR.
- Execution readiness: `superpowers:writing-plans` or the equivalent implementation-planning workflow has enough file, test, command, and verification context.

## Findings Format

Lead with blockers and concrete fixes:

```markdown
# Traceability Review

## Blockers
- <gap> -> <specific fix>

## Important Gaps
- <gap> -> <specific fix>

## Accepted Deferrals
- <deferred item> because <reason>; revisit at <trigger>

## Ready Packet
- Value stream: <name>
- Capability: <name>
- Feature packet: <name>
- Story count: <n>
- Architecture views: <list>
- Verification hooks: <list>
```

## Stop Conditions

Do not proceed to implementation when:

- The active slice is too large to understand or verify and cannot be bounded.
- A story cannot be tied to user value, learning, NFR, or risk reduction.
- A major architecture dependency has no decision owner.
- Acceptance criteria cannot be tested or reviewed.
- The implementation plan would need the executor to invent missing product or architecture decisions.
