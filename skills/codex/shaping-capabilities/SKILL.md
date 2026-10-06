---
name: shaping-capabilities
description: Turn an outcome or epic into capability increments with hypotheses, dependencies and feature candidates.
---

# Shaping Capabilities

Preserve the supplied artifact structure and selected abstraction level. Produce only what the current decision needs; one complete story or brief can be sufficient. Existing authorization covers routine local implementation and verification. Ask only about unresolved material choices or an expanded action.


## Overview

Capabilities describe meaningful abilities needed to improve a value stream. They are larger than features, but still need evidence, boundaries, and a route to implementation.

Use an available design-discovery workflow only when unresolved intent needs it to explore competing capability options before locking scope.

## Capability Tests

A good capability:

- Changes what customers, operators, teams, or systems can do.
- Has a measurable benefit hypothesis.
- Can be split into feature-sized delivery packets.
- Names architectural runway, integration, data, security, reliability, and compliance needs.
- Avoids being a disguised component name.

## Process

1. Restate the parent value stream outcome.
2. Generate capability options from friction points, missing abilities, risk controls, and feedback gaps.
3. Classify each as business-facing, platform-facing, operational, or enabler.
4. Identify dependencies and architecture questions early.
5. Keep a manageable active capability slice; 3–7 is a heuristic. Preserve supplied backlogs and park only work outside the chosen slice.
6. Choose the next capability by value, risk reduction, learning, and dependency order.

## Capability Brief

```markdown
# Capability: <name>

**Parent value stream:** <name>
**Benefit hypothesis:** If <ability exists>, then <customer/business/operational result> will improve because <reason>.
**Primary users / actors:** <people, systems, teams>
**Capability type:** <business | platform | operational | enabler>

## Scope
- Includes: <abilities and scenarios>
- Excludes: <explicit non-goals>

## Measures
- Outcome: <measure>
- Learning: <what must be validated>
- Guardrail: <quality, security, reliability, cost, compliance>

## Dependencies
- Upstream: <capabilities, systems, decisions>
- Downstream: <teams, systems, rollout constraints>

## Architecture Questions
- <question that may require C4 context/container/component view>

## Feature Candidates
- <feature candidate and reason>
```

## Gate Before Features

Proceed to `shaping-features` when installed, or to an equivalent feature-shaping workflow, only when:

- The capability is phrased as an ability, not a task.
- The benefit hypothesis can be tested.
- Key architecture questions have owners or are explicitly deferred.
- Feature candidates can fit into a bounded delivery increment.
