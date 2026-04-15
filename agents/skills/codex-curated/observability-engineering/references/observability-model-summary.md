# Observability Model Summary

Use this file when the private `platform-observability-model` repository is unavailable.

## Principles

- Observability starts from intent.
- OpenTelemetry semantic conventions are the baseline.
- Org semantic extensions must be explicit, low-cardinality by default, and enforceable.
- Alerts require immediate action and complete context.
- Notifications are useful but not urgent.
- Findings are policy or standards drift.
- Dashboards are incident decision surfaces, not manual overview loops.
- Backend resources are generated artifacts.
- Infra observability covers hosting, routing, capacity, control-plane, telemetry pipeline, policy, event, inventory, and change signals.
- Infrastructure alert context contract has the same rigor as application alert context.
- Telemetry pipelines must declare source-to-sink lineage, transformation contracts, buffer and delivery policy, validation, and self-observability when they affect SLOs, incident response, security, audit, cost, or backend generation.

## Required Alert Context

Every page-worthy alert needs:

- identity: app, service, environment, namespace, workload, version, deployment
- ownership: team, routing key, escalation, criticality
- impact: capability, route/page/API/journey, affected traffic or users, SLO impact
- current state: value, threshold, duration, first detected, last healthy, trend
- change context: deployments, config, Helm values, policy, dependencies, CI runs
- evidence: traffic, errors, latency, saturation, readiness, events, logs, traces, RUM
- decision support: likely failure mode, recommended action, playbook, incident state
- dynamic dashboard: pre-scoped time window and variables

## Unified SLO Interface

SLO intent should define:

- target application and service
- user journey or capability
- SLI type and success condition
- objective and window
- evaluation basis
- telemetry binding
- burn-rate policy
- alert routing
- decision dashboard
- playbook action

Backend rules are generated from this interface.

## Infra Observability Readiness Pattern

When preparing infrastructure observability:

1. Establish platform owner, escalation, environments, and topology boundaries.
2. Inventory signal layers: platform, cluster, namespace, node, workload, pod, container, route, network, telemetry pipeline, policy, event, inventory, and change.
3. Check metadata coverage for stable identity, readable names, owner, environment, workload, route, node, cluster, version, and change context.
4. Define topology correlation across metrics, logs, traces, events, inventory, routes, workloads, owners, and changes.
5. Define telemetry pipeline topology and health for source health, collector health, receiver health, processor health, queue pressure, buffer pressure, dropped metrics/logs/spans, redaction failures, cardinality-limit actions, exporter errors, acknowledgement status, sampling, freshness, and backend delivery.
6. Apply infrastructure alert context contract before paging: identity, ownership, impact, current state, change context, evidence, decision support, dashboard, and playbook.
7. Classify isolated restarts, node pressure, quota pressure, collector drops, policy drift, and metadata drift as notifications or findings unless impact and action are explicit.
8. Generate backend artifacts only after neutral intent, classification, context, and dashboard requirements are complete.

## Telemetry Pipeline Pattern

When telemetry pipeline behavior matters:

1. Map sources, processors, sinks, buffers, acknowledgement boundaries, and fallback or quarantine paths.
2. Require source-to-sink lineage for every delivered or discarded signal.
3. Define component contracts for accepted signal types, emitted signal types, required semantic attributes, enrichment, redaction, routing, and failure behavior.
4. Choose delivery policy by purpose: best-effort diagnostic telemetry can tolerate loss; SLO, audit, security, and incident-critical telemetry needs explicit durability, retry, and acknowledgement policy.
5. Define buffer behavior for backpressure: block, drop newest, drop oldest, sample, or quarantine.
6. Require pipeline self-observability for source ingestion, processor errors, queue depth, buffer age, dropped telemetry, sink latency, retries, delivery failures, configuration version, and validation status.
7. Validate topology, component references, transformation unit tests, redaction, cardinality limits, and risky parser or routing changes before deployment.

## Reliability Boundary

Incident aftercare, postmortems, miss-policy, action items, resilience experiments, and operational readiness belong to the reliability model. Use observability work only for telemetry, SLO bindings, alert context, decision dashboards, and backend artifacts.

## Usage Scenario Pattern

When onboarding a service, work as an intent-first process with human review gates:

1. Establish stable service identity, owner, criticality, telemetry tier, and data classification.
2. Apply OpenTelemetry semantic conventions and minimal org extensions.
3. Define service observability intent.
4. Define SLO intent.
5. Bind SLOs to existing telemetry or record instrumentation gaps.
6. Classify signals as alerts, notifications, or findings.
7. Require full alert context before paging.
8. Define a dynamic decision dashboard scoped from alert dimensions.
9. Generate backend artifacts from approved intent.
10. Enforce through local validation, CI, Helm, admission policy, and runtime drift checks.
