---
name: shaping-features
description: Shape a capability into bounded, testable feature packets with acceptance criteria, NFRs and architecture impact.
---

# Shaping Features

Preserve the supplied artifact structure and selected abstraction level. Produce only what the current decision needs; one complete story or brief can be sufficient. Existing authorization covers routine local implementation and verification. Ask only about unresolved material choices or an expanded action.


## Overview

Features turn a capability into deliverable slices of value. Keep them concrete enough for planning, but not so small that they become implementation tasks.

Use `modeling-c4-architecture` when installed; otherwise use an equivalent C4 architecture-modeling workflow when a feature changes system boundaries, data ownership, integrations, runtime topology, or major technology choices.

## Feature Tests

A good feature:

- Delivers observable value or validated learning.
- Is small enough for one delivery increment in the local context.
- Has acceptance criteria and NFRs.
- Names dependencies and rollout constraints.
- Can be split into a small story packet without losing its vertical value.

## Process

1. Restate the parent capability and benefit hypothesis.
2. Split by user outcome, journey step, risk reduction, data lifecycle, integration boundary, or rollout segment.
3. Separate user-facing features from enabler features.
4. Attach NFRs where they constrain design, not as generic quality slogans.
5. Note C4 impact: context, container, component, deployment, or none.
6. Prepare stories for the selected active feature slice; 1–3 features is a heuristic, not a quota.

## Feature Packet

```markdown
# Feature: <name>

**Parent capability:** <name>
**Value:** <who benefits and how>
**Feature type:** <user | business | platform | operational | enabler>
**C4 impact:** <system context | container | component | deployment | none>

## Acceptance Criteria
- Given <context>, when <action>, then <observable result>.
- Given <context>, when <failure or edge case>, then <safe result>.

## NFRs
- <security, reliability, performance, scalability, maintainability, usability, compliance>

## Dependencies
- <system, team, data, decision, migration, rollout>

## Story Slice Candidates
- <vertical slice candidate>
- <enabler slice candidate if needed>
```

## Gate Before Stories

Proceed to `slicing-stories` when installed, or to an equivalent story-slicing workflow, only when:

- Acceptance criteria describe behavior, not implementation.
- NFRs are specific enough to test or review.
- Architecture impact is explicit.
- The active story packet is understandable and bounded for this team; 7–10 is a heuristic, not a readiness gate.
