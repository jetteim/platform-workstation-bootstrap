---
name: orchestrating-architecture-execution
description: Route an initiative from unclear intent to the smallest useful architecture and delivery artifacts, then verified execution.
---

# Orchestrating Architecture Execution

Preserve the supplied artifact structure and selected abstraction level. Produce only what the current decision needs; one complete story or brief can be sufficient. Existing authorization covers routine local implementation and verification. Ask only about unresolved material choices or an expanded action.


## Overview

Use this skill as the router for an architecture-to-execution pipeline. Treat SAFe and C4 as useful abstraction vocabularies, not as ceremony to reproduce.

Core principle: keep each level human-sized, then hand off to installed workflow skills that already handle brainstorming, specs, implementation plans, TDD, plan execution, and verification.

Use the named skill at each level when it is installed. If a named skill is not available in the agent runtime, use the equivalent workflow implied by that level's artifact and exit gate.

## Pipeline

| Level | Use skill | Output | Exit gate |
| --- | --- | --- | --- |
| Direction | `discovering-value-streams` | Value stream brief | Customer, outcome, trigger, measures, and major flow steps are explicit |
| Scope | `shaping-capabilities` | Capability map | Each capability changes business or operational ability, not just a component |
| Delivery | `shaping-features` | Feature packets | Each feature is valuable, testable, bounded, and has architecture impact noted |
| Architecture | `modeling-c4-architecture` | C4 decision views | Diagrams answer specific stakeholder questions at the right zoom level |
| Implementation | `slicing-stories` | Story packets and spec handoff | The active slice is bounded and the acceptance criteria are testable |
| Integrity | `reviewing-traceability` | Traceability review | Every story traces upward and every architecture decision traces downward |
| Code | Complementary workflow skills | Design spec, plan, implementation | Use available workflows proportional to the task, with evidence before completion |

## Routing Rules

Start at the highest level that is unclear. Do not create all artifacts by default.

- If the user brings an idea or product direction, start with `discovering-value-streams` when installed; otherwise use an equivalent value-stream discovery workflow.
- If the user brings an outcome but not delivery scope, use `shaping-capabilities` when installed; otherwise use an equivalent capability-shaping workflow.
- If the user brings a capability or epic-like chunk, use `shaping-features` when installed; otherwise use an equivalent feature-shaping workflow.
- If architecture boundaries, ownership, integration, data, or deployment are unclear, use `modeling-c4-architecture` when installed; otherwise use an equivalent C4 architecture-modeling workflow before story slicing.
- If the user brings a feature and wants implementation, use `slicing-stories` when installed; otherwise use an equivalent story-slicing workflow, then hand off to `superpowers:writing-plans` when installed or an equivalent implementation-planning workflow.
- Before implementation, use `reviewing-traceability` when installed; otherwise use an equivalent traceability-review workflow when there is more than one abstraction level or a complex active slice.

## Complementary workflows

Use available discovery, planning, implementation and verification workflows when they improve this task. Do not require a companion package, a test-first ritual or delegation for routine reversible work. Use tests appropriate to the behavior and risk; obtain evidence before claiming completion.

Existing authorization covers ordinary implementation and local verification. Ask only for an unresolved material decision or a newly expanded action. Do not produce all hierarchy levels or require routine reapproval. Delegation requires authorization from the session or applicable instructions.

## Anti-Cliches

Reject these failure modes:

- Story factory: many shallow stories with no value trace.
- Architecture theater: diagrams that do not change a decision.
- SAFe cosplay: roles, events, and labels copied without helping execution.
- SDD paperwork: specs that describe everything except the next executable slice.
- Context overload: an active slice too large to understand and verify.

## Artifact Shape

Keep artifacts compact. Prefer this structure:

```markdown
# <Artifact Name>

**Parent:** <upstream artifact>
**Decision:** <what this artifact decides>
**Outcome:** <customer/business/operational result>
**Scope:** <included / excluded>
**Architecture impact:** <C4 level, affected systems, risks>
**Implementation handoff:** <features, stories, tests, or plan path>
**Evidence:** <metric, demo, test, or verification command>
**Open questions:** <only blockers, not a parking lot>
```
