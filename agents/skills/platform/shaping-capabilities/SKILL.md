---
name: shaping-capabilities
description: Use when a value stream, strategic outcome, portfolio item, or epic-sized change needs to be decomposed into capability increments, business hypotheses, dependencies, architecture concerns, and feature candidates.
---

# Shaping Capabilities

## Overview

Capabilities describe meaningful abilities needed to improve a value stream. They are larger than features, but still need evidence, boundaries, and a route to implementation.

Use `superpowers:brainstorming` when installed; otherwise use an equivalent design-discovery workflow to explore competing capability options before locking scope.

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
5. Keep 3-7 capabilities active; park the rest.
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
