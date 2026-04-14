---
name: orchestrating-architecture-execution
description: Use when an idea, initiative, architecture change, roadmap item, epic, or vague product request needs to become a coherent pipeline of value stream, capability, feature, story, architecture, spec, plan, implementation, and verification artifacts.
---

# Orchestrating Architecture Execution

## Overview

Use this skill as the router for an architecture-to-execution pipeline. Treat SAFe and C4 as useful abstraction vocabularies, not as ceremony to reproduce.

Core principle: keep each level human-sized, then hand off to the existing workflow skills that already handle brainstorming, specs, implementation plans, TDD, plan execution, and verification.

## Pipeline

| Level | Use skill | Output | Exit gate |
| --- | --- | --- | --- |
| Direction | `discovering-value-streams` | Value stream brief | Customer, outcome, trigger, measures, and major flow steps are explicit |
| Scope | `shaping-capabilities` | Capability map | Each capability changes business or operational ability, not just a component |
| Delivery | `shaping-features` | Feature packets | Each feature is valuable, testable, bounded, and has architecture impact noted |
| Architecture | `modeling-c4-architecture` | C4 decision views | Diagrams answer specific stakeholder questions at the right zoom level |
| Implementation | `slicing-stories` | Story packets and spec handoff | No more than 7-10 active stories are needed to hold the implementation context |
| Integrity | `reviewing-traceability` | Traceability review | Every story traces upward and every architecture decision traces downward |
| Code | Existing workflow skills | Design spec, plan, implementation | Use `brainstorming`, `writing-plans`, plan execution, `test-driven-development`, and `verification-before-completion` or your runtime's equivalents |

## Routing Rules

Start at the highest level that is unclear. Do not create all artifacts by default.

- If the user brings an idea or product direction, start with `discovering-value-streams`.
- If the user brings an outcome but not delivery scope, use `shaping-capabilities`.
- If the user brings a capability or epic-like chunk, use `shaping-features`.
- If architecture boundaries, ownership, integration, data, or deployment are unclear, use `modeling-c4-architecture` before story slicing.
- If the user brings a feature and wants implementation, use `slicing-stories`, then hand off to `writing-plans`.
- Before implementation, use `reviewing-traceability` when there is more than one abstraction level or more than 7-10 stories.

## Complementary Workflow Skills

Do not reimplement these workflows:

- **Required when shaping ambiguous levels:** Use `brainstorming` or an equivalent design-discovery workflow.
- **Required when turning approved specs into implementation work:** Use `writing-plans` or an equivalent implementation-planning workflow.
- **Required when coding features or fixes:** Use `test-driven-development` or an equivalent test-first workflow.
- **Recommended for executing plans:** Use parallel task execution when independent tasks are available; otherwise use a sequential plan-execution workflow.
- **Required before claiming completion:** Use `verification-before-completion` or an equivalent evidence-before-claims workflow.

## Anti-Cliches

Reject these failure modes:

- Story factory: many shallow stories with no value trace.
- Architecture theater: diagrams that do not change a decision.
- SAFe cosplay: roles, events, and labels copied without helping execution.
- SDD paperwork: specs that describe everything except the next executable slice.
- Context overload: more than 7-10 active stories or decisions in the human working set.

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
