---
name: discovering-value-streams
description: Frame an unclear initiative around customer outcomes, value-stream boundaries, flow and measures before delivery decomposition.
---

# Discovering Value Streams

Preserve the supplied artifact structure and selected abstraction level. Produce only what the current decision needs; one complete story or brief can be sufficient. Existing authorization covers routine local implementation and verification. Ask only about unresolved material choices or an expanded action.


## Overview

Frame the work as a flow of value before decomposing it into capabilities, features, or stories. The output is a value stream brief that explains why the work exists and what must improve.

Use an available design-discovery workflow only when unresolved intent needs it when the goal, customer, or flow is ambiguous.

## Process

1. Identify the customer or beneficiary.
2. Name the trigger that starts the stream and the outcome that ends it.
3. Map the major activities needed to explain the flow; 5–9 is an optional starting heuristic, not a quota.
4. Identify current friction: waits, handoffs, rework, quality failures, risk, toil, or missing feedback.
5. Define outcome measures before solution measures.
6. Mark systems, teams, regulations, and operational constraints that shape delivery.
7. Propose only supported capability candidates; use 3–7 as a working-size heuristic when helpful.

## Value Stream Brief

```markdown
# Value Stream: <name>

**Customer / beneficiary:** <who receives value>
**Trigger:** <event that starts the stream>
**Outcome:** <observable end state>
**Why now:** <business, customer, risk, or operational reason>

## Flow
1. <major activity>
2. <major activity>
3. <major activity>

## Friction
- <delay, handoff, defect, risk, toil, missing feedback>

## Measures
- Outcome: <customer/business/operational measure>
- Flow: <lead time, load, quality, predictability, or recovery measure>
- Guardrail: <security, reliability, cost, compliance, usability>

## Boundaries
- In scope: <products, channels, systems, teams>
- Out of scope: <explicit exclusions>

## Candidate Capabilities
- <capability candidate and benefit hypothesis>
```

## Gate Before Capabilities

Proceed to `shaping-capabilities` when installed, or to an equivalent capability-shaping workflow, only when:

- The stream has one clear customer or beneficiary.
- The beginning and end are observable.
- Measures are not just delivery activity counts.
- Capability candidates describe abilities the organization or product needs, not implementation tasks.
