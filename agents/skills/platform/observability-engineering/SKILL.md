---
name: observability-engineering
description: Use when building platform or application observability, defining SLOs, preparing telemetry backend artifacts, enforcing OpenTelemetry semantic conventions, creating alert dashboards, or migrating SRE rules.
---

# Observability Engineering

## Overview

Build observability from neutral intent. Treat backend monitors, dashboards, alert rules, admission policies, Helm values, and API calls as generated outputs.

When the local `platform-observability-model` repository is available, use it as the source of truth. Otherwise use the compact references bundled with this skill.

Preferred model path:

```text
~/Library/CloudStorage/OneDrive-Personal/Pet projects/platform-observability-model
```

## When To Use

Use this skill for:

- building infra observability for a Kubernetes-based platform
- preparing application observability for a service or product area
- defining SLOs and SLIs
- generating alerts, notifications, dashboards, rules, or backend API/IaC artifacts
- extending OpenTelemetry semantic conventions with org-wide attributes
- enforcing semantic conventions through CI, Helm, admission policy, or runtime checks
- migrating existing SRE rules into backend-neutral SLO and alert intent

Do not use this skill for one-off debugging of a single incident unless the task asks to improve the observability model or generated artifacts.

If the task is primarily about incident aftercare, postmortems, miss-policy, action items, resilience experiments, or operational readiness, use `reliability-engineering` instead. Use this skill only for the telemetry, SLO binding, alert, dashboard, or backend artifact portions.

## Core Rules

1. Start from intent, not backend syntax.
2. Use OpenTelemetry semantic conventions first.
3. Add organization-wide semantic attributes only when upstream conventions do not represent a required operational concept.
4. Keep implementation examples as evidence, not model architecture.
5. Classify signals as alert, notification, or finding before generating backend resources.
6. Page-worthy alerts must include action context, owner, playbook, and a dynamic decision dashboard.
7. Dashboards support incident response; they are not manual overview loops.
8. SRE rules are generated outputs from SLO and alert intent.

## Workflow

### 1. Load The Model

Check for the private model repo:

```bash
test -d "$HOME/Library/CloudStorage/OneDrive-Personal/Pet projects/platform-observability-model"
```

If present, read only the relevant files:

- `docs/intent/principles.md`
- `docs/usage-scenarios/service-onboarding-to-observability.md` when onboarding or preparing service observability
- `docs/intent/semantic-conventions.md`
- `docs/intent/alert-context-contract.md`
- `docs/intent/decision-dashboard-model.md`
- `docs/intent/slo-and-error-budget-model.md`
- `docs/intent/backend-generation-model.md`
- `docs/devex/*.md` when enforcement or developer workflow matters
- `docs/migration/*.md` when SRE rules are involved

If missing, use `references/observability-model-summary.md`.

When a usage scenario applies, follow it as the execution contract. The scenario defines expected inputs, outputs, refusal conditions, human review gates, and completion criteria.

### 2. Discover Current Reality

Inventory only what is needed for the request:

- service or platform ownership model
- Kubernetes workload, route, namespace, and Helm artifacts
- OpenTelemetry resource attributes and instrumentation
- existing metrics, logs, traces, RUM, synthetics, probes, and events
- current monitors, dashboards, rules, and playbooks
- CI, admission policy, and validation paths

Summarize current implementation as evidence. Do not let vendor-specific resources become the model.

### 3. Define Semantic Conventions

Create or update a semantic convention registry:

- baseline OpenTelemetry attributes
- org attributes with purpose, cardinality, owner, allowed values, and enforcement points
- migration behavior for old labels or tags
- generated projections for backend tags and dashboard variables

Reject high-cardinality resource attributes unless the intent explicitly marks them as event-only.

### 4. Build Observability Intent

Separate:

- `PlatformObservability`
- `ServiceObservability`
- `SLOIntent`
- `SLIQueryBinding`
- `AlertIntent`
- `NotificationIntent`
- `DecisionDashboardIntent`
- `GeneratedArtifactManifest`

Record instrumentation gaps instead of inventing fake telemetry bindings.

For service onboarding, produce the artifacts described by `docs/usage-scenarios/service-onboarding-to-observability.md`: service intent, semantic convention updates, SLO intent, SLI query bindings, alert or notification classifications, decision dashboard intent, generated artifact manifest, and enforcement recommendations.

### 5. Classify Alerts

Use this taxonomy:

- **Alert:** immediate action required, direct or highly probable impact, complete context.
- **Notification:** useful operational signal, no immediate human action.
- **Finding:** standard, policy, or telemetry drift handled through DevEx or backlog.

Do not page on job failures, restarts, partial replica loss, or telemetry drift by default. Promote them only when user impact, owner, playbook, and decision context are explicit.

### 6. Generate Backend Artifacts

For each backend target, generate from neutral intent:

- monitor or alert resources
- recording or query rules
- dashboard definitions
- routing metadata
- playbook links
- admission policies
- Helm values
- CI validation
- API call manifests

Generated artifacts must identify their source intent. If a backend cannot express the intent safely, report the gap.

### 7. Validate

Before claiming completion, check:

- every SLO has a telemetry binding or documented instrumentation gap
- every alert has ownership, impact, current state, change context, technical evidence, decision support, dashboard, and playbook
- every dashboard opens from alert dimensions, not manual overview assumptions
- semantic conventions are enforced at appropriate layers
- generated artifacts are reproducible from the model

## Common Mistakes

- Starting with a backend query language before defining the SLO.
- Copying vendor tags into the model instead of deriving them from semantic attributes.
- Treating dashboards as manual overview boards.
- Paging on symptoms that do not require immediate human action.
- Creating alerts without playbook actions or scoped dashboards.
- Migrating old SRE rules one-to-one instead of reclassifying them by intent.
