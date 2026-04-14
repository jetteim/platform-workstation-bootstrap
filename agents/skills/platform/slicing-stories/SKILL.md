---
name: slicing-stories
description: Use when a feature or implementation-ready slice needs to become a human-sized story packet, acceptance tests, enabler work, spec handoff, implementation-plan input, and execution context without overwhelming the user.
---

# Slicing Stories

## Overview

Create stories as the final human-readable bridge before implementation. Stories are not the whole system memory; they are a small context packet for the next executable slice.

Use `superpowers:brainstorming` when installed; otherwise use an equivalent design-discovery workflow for unclear story intent. Use `superpowers:writing-plans` when installed; otherwise use an equivalent implementation-planning workflow once the story packet is approved.

## Story Budget

Keep the active packet to 7-10 stories maximum. If more are needed, split the feature again or create separate packets by journey step, component boundary, risk, or rollout cohort.

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

Before calling `superpowers:writing-plans` or the equivalent implementation-planning workflow, prepare:

```markdown
# Implementation Packet: <feature>

**Parent chain:** <value stream> -> <capability> -> <feature>
**Architecture context:** <C4 views and decisions>
**Active stories:** <7-10 max>
**Out of scope:** <explicit exclusions>
**Verification evidence:** <commands, tests, demos, metrics>
**Risks:** <only risks that affect implementation order or test strategy>
```

## Gate Before Planning

Proceed to implementation planning only when:

- The packet is small enough to reason about.
- Every story has a parent feature and test hook.
- Enabler work is tied to a user story, NFR, or architecture decision.
- The implementation packet is enough for `superpowers:writing-plans` or the equivalent implementation-planning workflow to create a concrete plan.
