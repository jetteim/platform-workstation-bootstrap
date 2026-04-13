---
name: shaping-features
description: Use when a capability, epic, roadmap item, or architecture change needs feature-sized delivery packets with acceptance criteria, NFRs, enablers, dependencies, C4 impact, and story-slicing readiness.
---

# Shaping Features

## Overview

Features turn a capability into deliverable slices of value. Keep them concrete enough for planning, but not so small that they become implementation tasks.

Use `modeling-c4-architecture` when a feature changes system boundaries, data ownership, integrations, runtime topology, or major technology choices.

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
6. Prepare story slicing only for the next 1-3 features.

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

Proceed to `slicing-stories` only when:

- Acceptance criteria describe behavior, not implementation.
- NFRs are specific enough to test or review.
- Architecture impact is explicit.
- The story packet can stay within 7-10 active stories.

