---
name: observability-engineering
description: Build or review instrumentation, telemetry bindings, alerts, dashboards, and backend artifacts. Use reliability-engineering for SLO objectives and creating-observability-pipelines for delivery topology.
---

# Observability Engineering

Build from neutral intent and measured telemetry. Backend resources are generated outputs. Preserve the user's selected stack, scope and existing authorization.

## Route the work

- Choosing SLIs, SLO objectives, calculation basis, error budgets or miss-policy belongs to `reliability-engineering` when available. This skill implements reviewed telemetry/query bindings and backend projections.
- Collector topology, transforms, routes, buffers and delivery guarantees belong to `creating-observability-pipelines` when available.
- Keep one-off incident debugging outside this workflow unless the user requests instrumentation or artifact improvements.
- If a companion is unavailable, carry out the bounded equivalent contract when possible; otherwise state the missing capability. Do not omit requested work silently.

## Load only relevant guidance

Use [model-resolution.md](references/model-resolution.md) for a caller-configured model checkout or the bundled [model summary](references/observability-model-summary.md). State when the fallback is used; do not invent private-model content.

Use the applicable section of [workflows.md](references/workflows.md): discovery and semantic conventions for instrumentation; infrastructure/service onboarding for readiness; alert classification and generation for backend outputs. Read [provider-terraform-adapters.md](references/provider-terraform-adapters.md) only for provider Terraform. Read [semantic-conventions.md](references/semantic-conventions.md) when authoring or migrating attributes and bindings.

## Essential contract

1. Inventory actual signal names, ownership and instrumentation gaps before writing bindings. Missing telemetry is not evidence of health.
2. Prefer supported OpenTelemetry conventions. Declare org extensions with purpose, owner, allowed values, cardinality and enforcement; capture convention version/stability and migration behavior.
3. Separate immediate-action alerts, operational notifications and backlog findings. Paging needs user impact, owner, actionable playbook and a scoped dynamic decision dashboard.
4. Preserve source-to-sink lineage and pipeline requirements when they affect evidence; avoid duplicating pipeline implementation.
5. Map each generated artifact to source intent. Report unsupported provider/API semantics instead of weakening the contract or inventing fields. Keep credentials out of artifacts and command arguments.
6. Validate syntax, relevant signal/query bindings, alert context and rendering/plan behavior as available. A fixture comparison is not live provider verification.
7. Capture target, command, timestamp, output path, metric/log/trace names, rollback path and verification evidence for reliability-sensitive work. Prefer plan/dry-run/diff before any authorized apply; do not infer live mutation permission from artifact generation.

Return only the requested intent, bindings, artifacts, evidence and material gaps. Verification and diagrams should be proportional to the actual change.
