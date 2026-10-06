---
name: slicing-stories
description: Slice a feature into implementation-ready stories with testable acceptance criteria and a bounded execution context.
---

# Slicing Stories

Preserve the supplied artifact structure and selected abstraction level. Produce only what the current decision needs; one complete story or brief can be sufficient. Existing authorization covers routine local implementation and verification. Ask only about unresolved material choices or an expanded action.


## Overview

Create stories as the final human-readable bridge before implementation. Stories are not the whole system memory; they are a small context packet for the next executable slice.

Use a focused discovery step only for unresolved story intent. Once material decisions are settled, use an implementation plan proportional to the task within the user’s existing authorization.

## Story Budget

Keep the active packet understandable. One complete story is sufficient; 7–10 is an optional working-size heuristic. Preserve larger supplied backlogs and select a bounded active slice by journey, risk or rollout instead of blocking on the total count.

## Slice Types

- User story: visible behavior for a user or beneficiary.
- Enabler story: architecture, infrastructure, exploration, migration, compliance, or quality work needed for user value.
- Spike: timeboxed learning with an explicit decision output.
- Hardening story: only when tied to a concrete NFR, defect class, or operational risk.

## Process

1. Restate feature value and acceptance criteria.
2. Split vertically by thin observable behavior first.
3. Add enabler stories only when they unblock user stories or reduce delivery risk.
4. Write acceptance criteria as testable examples.
5. Attach likely test type: unit, contract, integration, e2e, performance, security, operational verification.
6. Produce an implementation handoff packet.

## Story Format

```markdown
## Story: <name>

As <user/actor>,
I want <behavior>,
so that <value>.

**Parent feature:** <name>
**Type:** <user | enabler | spike | hardening>
**Acceptance criteria:**
- Given <context>, when <action>, then <observable result>.

**Test hook:** <unit | contract | integration | e2e | performance | security | operational>
**Architecture touchpoint:** <C4 element, container, component, or none>
**Dependencies:** <other stories, decisions, data, systems>
```

## Implementation Handoff

When a planning handoff is useful, prepare:

```markdown
# Implementation Packet: <feature>

**Supplied parent chain:** <existing relevant parents; do not invent absent levels>
**Architecture context:** <C4 views and decisions>
**Active stories:** <bounded active slice>
**Out of scope:** <explicit exclusions>
**Verification evidence:** <commands, tests, demos, metrics>
**Risks:** <only risks that affect implementation order or test strategy>
```

## Gate Before Planning

Proceed to implementation planning only when:

- The packet is small enough to reason about.
- Every story has a parent feature and test hook.
- Enabler work is tied to a user story, NFR, or architecture decision.
- The packet contains enough concrete context for the chosen implementation workflow.
