---
name: reliability-engineering
description: Use when building reliability models, choosing SLIs/SLOs, assessing service reliability, handling incident aftercare, writing postmortems, creating action items, defining miss-policy, planning resilience experiments, or reviewing operational readiness.
---

# Reliability Engineering

## Overview

Build reliability from neutral intent. Treat ticket systems, chat channels, dashboards, backend APIs, and workflow automation as implementation targets.

When the private `platform-reliability-model` repository checkout is available, use it as the source of truth. Otherwise use the compact reference bundled with this skill.

Preferred model checkout from the workstation installer:

```text
${AGENTS_HOME:-$HOME/.agents}/vendor_imports/repos/platform-reliability-model
```

Legacy workspace checkout:

```text
~/Library/CloudStorage/OneDrive-Personal/Pet projects/platform-reliability-model
```

## When To Use

Use this skill for:

- service reliability onboarding
- SLI/SLO definition and review
- generating SLI/SLO candidates from measured service telemetry
- operational readiness reviews
- dependency resilience reviews
- incident record normalization
- postmortem writing or review
- contributing causes analysis
- lessons learned and action item extraction
- miss-policy definition or activation
- resilience experiment planning
- reliability model creation or migration

Do not use this skill for generating telemetry backend monitors, dashboards, or SLO query bindings directly. Use `observability-engineering` for that work and reference its outputs as reliability evidence.

## Core Rules

1. Separate incident response from incident aftercare.
2. Preserve evidence and timeline before drawing conclusions.
3. Analyze contributing causes, not blame.
4. Convert lessons into concrete action items.
5. Reject vague action items such as "be more careful".
6. Treat SLO misses and incidents as related but not identical.
7. Use miss-policy as a pre-agreed operating mode.
8. Use observability artifacts as evidence, not as the reliability model itself.
9. Reliability owns SLI/SLO choice, objective realism, calculation basis, error-budget policy, and miss-policy.

## Workflow

### 1. Load The Model

Resolve the private model repo in this order:

1. `${AGENTS_HOME:-$HOME/.agents}/vendor_imports/repos/platform-reliability-model`
2. `~/Library/CloudStorage/OneDrive-Personal/Pet projects/platform-reliability-model`
3. `references/reliability-model-summary.md`

Use this check:

```bash
model_repo="${AGENTS_HOME:-$HOME/.agents}/vendor_imports/repos/platform-reliability-model"
if [ ! -d "$model_repo/docs" ]; then
  model_repo="$HOME/Library/CloudStorage/OneDrive-Personal/Pet projects/platform-reliability-model"
fi
test -d "$model_repo/docs"
```

If a private checkout is present, read only the relevant files:

- `docs/intent/principles.md`
- `docs/intent/reliability-boundaries.md`
- `docs/usage-scenarios/service-reliability-onboarding.md` when onboarding or reviewing a service
- `docs/usage-scenarios/telemetry-derived-sli-slo-onboarding.md` when generating SLIs/SLOs from measured telemetry
- `docs/usage-scenarios/sli-slo-definition-and-review.md` when defining or reviewing SLIs/SLOs
- `docs/usage-scenarios/incident-to-postmortem-to-learning.md` when working on incidents or postmortems
- `docs/intent/service-level-definition-model.md`
- `docs/intent/sli-slo-selection-model.md`
- `docs/intent/error-budget-alerting-model.md`
- `docs/intent/reliability-recommendations-model.md`
- `docs/intent/incident-model.md`
- `docs/intent/postmortem-model.md`
- `docs/intent/contributing-causes-model.md`
- `docs/intent/action-item-model.md`
- `docs/intent/miss-policy-model.md`
- `docs/intent/dependency-resilience-model.md`
- `docs/intent/resilience-experiment-model.md`
- `docs/intent/relation-to-observability.md`

If no private checkout is present, use `references/reliability-model-summary.md` and state that the bundled reference fallback was used. Do not invent content from the private model.

When a usage scenario applies, follow it as the execution contract. The scenario defines expected inputs, outputs, refusal conditions, human review gates, and completion criteria.

### 2. Classify The Task

Classify the work before producing output:

- service reliability profile
- telemetry-derived SLI/SLO onboarding
- SLI/SLO definition or review
- operational readiness review
- dependency resilience review
- incident record
- postmortem analysis
- action item extraction
- miss-policy
- resilience experiment
- reliability review

### 3. Gather Evidence

Inventory only what is needed:

- service ownership and escalation
- affected capabilities and users
- measured service telemetry and historical behavior
- dependencies and failure modes
- timeline events
- deployments and changes
- observability evidence
- response communications
- resolution steps
- prior incidents and action items

Preserve links, screenshots, logs, traces, metrics, and relevant notes before retention expires.

### 4. Build Reliability Intent

Produce neutral objects as needed:

- `ServiceReliabilityProfile`
- `ServiceLevelDefinition`
- `DependencyProfile`
- `OperationalReadinessCheck`
- `IncidentRecord`
- `TimelineEvent`
- `PostmortemAnalysis`
- `ContributingCause`
- `ReliabilityActionItem`
- `MissPolicy`
- `ResilienceExperiment`

Record gaps instead of inventing missing facts.

### 5. Define Or Review SLIs And SLOs

When the task involves service reliability, always check whether SLI/SLO work is needed.

Follow these rules:

- inventory measured telemetry before generating candidates
- map measured telemetry to latency, traffic, errors, saturation, freshness, availability, and user journeys
- reject telemetry that cannot be explained as user-visible service quality
- choose SLIs from the user's point of view
- keep SLIs unqualified; define success in the SLO
- consider latency, traffic, errors, saturation, and user journeys
- define SLI instances when one indicator has multiple measured scopes
- record measurement details that affect interpretation, including active probe interval and timeout
- check historical behavior before accepting objectives
- check dependencies and dependency SLOs
- check user and product expectations
- choose realistic objectives with meaningful error budgets
- choose observations-based or time-slice-based calculation deliberately
- use time-slice-based calculation when very low volume would make one or two failures trigger alerts
- define miss-policy with trigger, response, authority, and exit condition
- hand telemetry query binding and backend artifact generation to `observability-engineering`

### 6. Analyze And Review

For incidents and postmortems:

- build a chronological timeline
- evaluate impact and urgency
- identify trigger and enabling components
- compare response timestamps
- preserve evidence
- write lessons as reusable guidance
- create action items that directly follow from analysis

For service reliability:

- identify dependencies
- review SLI/SLO rationale and calculation basis
- review graceful degradation
- review timeout, retry, and circuit breaker policy
- review cache-on-failure and asynchronous degradation options
- review rollback and release safety
- review workload isolation for critical and slow paths
- review error reporting quality
- review observability/SLO support
- propose action items for gaps

### 7. Use Observability Deliberately

When the reliability work needs telemetry, SLOs, alert context, or decision dashboards:

1. Describe the reliability need.
2. Hand the telemetry/backend artifact work to the observability model.
3. Reference the generated observability artifact as evidence or an action item.

Do not duplicate the observability model inside reliability output.

### 8. Validate

Before claiming completion, check:

- service reliability output includes SLI/SLO rationale or explicitly defers it
- every SLO has success condition, objective ratio, window, calculation basis, and reality-check notes
- incidents include impact, urgency, affected entities, and timeline
- postmortems include resolution, impact, contributing causes, lessons, and action items
- action items have owner, evidence, category, and verification method
- miss-policy has trigger, response, authority, and exit condition
- resilience experiments have hypothesis, safety preconditions, abort criteria, and evidence plan
- accepted risks are explicit

## Common Mistakes

- Treating a postmortem as a chronology without learning.
- Calling a trigger the root cause too early.
- Creating action items that do not follow from analysis.
- Using blame or vague advice as lessons.
- Treating an SLO miss as automatically identical to an incident.
- Lowering an SLO without consumer impact review and an expiration or review date.
