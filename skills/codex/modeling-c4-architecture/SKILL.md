---
name: modeling-c4-architecture
description: Use when architecture boundaries, integrations, ownership, containers, components, deployment, dependencies, or stakeholder communication need C4-style views tied to value streams, capabilities, features, stories, or implementation plans.
---

# Modeling C4 Architecture

## Overview

Use C4 as a zoom model for architecture decisions. Draw only the views needed to answer the current delivery question.

Do not create diagrams as decoration. Every view must change scoping, sequencing, ownership, risk, or implementation planning.

## Choose The View

| Question | View |
| --- | --- |
| Who uses this, and what systems does it touch? | System context |
| What deployable/runtime parts make up the system? | Container |
| Which internal parts own responsibilities inside a container? | Component |
| How does behavior move across elements? | Dynamic |
| Where does it run and how does it fail or scale? | Deployment |
| Which classes/functions matter for implementation? | Code, only when useful |

## Process

1. Name the decision the diagram must support.
2. Choose the lowest zoom level that answers it.
3. Define scope and audience before drawing.
4. Use stable names for people, systems, containers, and components.
5. Label relationships with intent and protocol/data when relevant.
6. Attach risks, NFRs, and dependencies directly to affected elements.
7. Feed architecture decisions back into capability, feature, and story artifacts.

## C4 Decision Brief

```markdown
# Architecture View: <name>

**Parent artifact:** <value stream | capability | feature | story packet>
**Question:** <decision this view answers>
**Audience:** <business, product, engineering, ops, security, compliance>
**C4 level:** <context | container | component | dynamic | deployment | code>

## Elements
- <person/system/container/component>: <responsibility>

## Relationships
- <source> -> <target>: <interaction, data, protocol, reason>

## Decisions
- <decision and consequence>

## Risks / NFRs
- <risk or NFR tied to element or relationship>

## Downstream Impact
- Capability: <impact>
- Feature: <impact>
- Story / test: <impact>
```

## Gate

Architecture is ready for execution when:

- Each diagram has a named question and audience.
- The selected level is neither too broad nor too detailed.
- Containers/components map to ownership and implementation boundaries.
- NFRs and risks are reflected in features, stories, or tests.

