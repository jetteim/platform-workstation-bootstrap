---
name: creating-observability-pipelines
description: Use when creating, reviewing, or migrating telemetry pipelines that collect, transform, route, buffer, validate, and deliver logs, metrics, traces, events, or profiles across tool-agnostic observability systems.
---

# Creating Observability Pipelines

## Overview

Create observability pipelines as neutral contracts between telemetry producers and telemetry consumers. Treat implementation files for collectors, routers, stream processors, gateways, and backends as generated outputs from the pipeline contract.

Use `$observability-engineering` first when the request includes SLOs, SLIs, semantic conventions, alerts, dashboards, generated backend artifacts, or platform observability intent. Use this skill for pipeline topology, component contracts, delivery policy, validation, and pipeline self-observability.

When a request names a concrete provider or runtime, keep the source pipeline contract tool-agnostic and generate provider adapters as a separate projection. This skill owns provider artifacts for telemetry movement: sources, transforms, routes, buffers, delivery, quarantine, validation, and pipeline self-observability. Delegate SLOs, dashboards, monitors, and backend observability artifacts to `$observability-engineering`.

## Core Model

Every pipeline has these parts:

- **Sources:** where signals enter, including applications, infrastructure, control planes, probes, audit streams, and synthetic checks.
- **Transforms:** parsing, normalization, enrichment, redaction, sampling, aggregation, cardinality control, and schema conversion.
- **Routes:** deterministic branching by signal type, owner, environment, severity, sensitivity, destination, or cost class.
- **Buffers:** memory, disk, queue, stream, or batch boundaries with explicit loss, retry, backpressure, and replay behavior.
- **Sinks:** where signals leave the pipeline, including stores, analysis engines, incident systems, archives, quarantine paths, or test harnesses.
- **Self-observability:** metrics, logs, traces, events, and health checks that explain whether the pipeline itself can be trusted.

## Workflow

### 1. Bound The Pipeline

Capture the purpose, signal types, owners, environments, consumers, retention needs, sensitivity level, cost constraints, failure tolerance, and rollback path.

Classify the pipeline's role:

- **Reliability-critical:** affects SLOs, paging evidence, incident response, or error-budget decisions.
- **Security or audit-critical:** affects detection, forensics, compliance, or immutable records.
- **Operational analytics:** supports troubleshooting, capacity, cost, or product analysis without direct paging impact.
- **Exploratory:** safe to lose, reshape, sample, or disable without operational harm.

### 2. Model Source-To-Sink Lineage

Draw the component graph before choosing implementation syntax:

```text
source -> transform -> route -> buffer -> sink
```

For fan-in, fan-out, replay, sampling, quarantine, and fallback paths, name each edge and the contract it preserves or changes. Mark acknowledgement boundaries and places where data can be dropped, duplicated, delayed, reordered, or redacted.

### 3. Define Signal Contracts

For each signal family, define:

- schema and required fields
- timestamp source and freshness expectations
- resource and scope attributes
- correlation keys across logs, metrics, traces, events, and profiles
- cardinality limits and event-only fields
- sensitivity class and redaction rules
- provenance fields that identify source, pipeline version, and transform stage
- malformed-event behavior

### 4. Specify Transform And Route Contracts

For every transform and route, record:

- input contract
- output contract
- deterministic behavior
- failure behavior
- redaction and cardinality checks
- sample input and expected output
- validation command or test harness

Do not hide lossy behavior in implementation details. Sampling, aggregation, truncation, deduplication, enrichment misses, parsing failures, and quarantine routing are contract decisions.

### 5. Define Delivery Policy

Choose delivery behavior explicitly:

- delivery guarantee: best effort, at-most-once, at-least-once, effectively-once, or durable archive
- buffer type, capacity, spill behavior, and saturation behavior
- retry, timeout, batching, compression, and backoff policy
- ordering, deduplication, replay, and idempotency expectations
- backpressure behavior toward upstream components
- fallback, quarantine, and dead-letter behavior
- cost controls for volume, retention, egress, and high-cardinality data

### 6. Add Pipeline Self-Observability

Every non-trivial pipeline must expose its own health. At minimum, define telemetry for:

- records or bytes received, emitted, dropped, quarantined, retried, and failed
- end-to-end latency and per-stage processing latency
- queue depth, buffer occupancy, spill usage, and oldest buffered item age
- parse, transform, redaction, route, and delivery errors
- freshness lag by source and sink
- configuration version, reload status, and component health
- backpressure state and sink availability

Use `$observability-engineering` to turn these signals into SLOs, alerts, dashboards, and backend artifacts when they affect operations.

### 7. Generate Implementation Artifacts

Only after the contract is clear, generate implementation artifacts for the chosen stack. Generated artifacts must include:

- source contract references
- topology and component names
- transform and route tests
- delivery and buffer policy
- self-observability signal names
- rollback instructions
- validation evidence

If the target stack cannot express required redaction, delivery, buffering, replay, validation, or self-observability behavior, report the gap instead of weakening the contract silently.

For concrete provider requests, also produce a `PipelineProviderAdapterManifest` that maps the neutral contract to provider artifacts and validation commands. Use `references/provider-pipeline-adapters.md` for Datadog Observability Pipelines, Elastic ecosystem, OpenTelemetry Collector, Vector, Fluent Bit, or similar provider/runtime projections.

### 8. Validate Before Completion

Before claiming completion, produce evidence for:

- static syntax or schema validation
- source-to-sink topology review
- transform tests with representative and malformed samples
- redaction and sensitivity tests
- cardinality and volume checks
- delivery, retry, backpressure, and buffer behavior
- failure-path tests for sink outage, malformed input, and saturated buffer
- self-observability signal presence
- rollback path

For reliability-sensitive work, include target, command, timestamp, output path, metric/log/trace/event names, rollback path, and verification result.

## Expected Outputs

Produce only the outputs needed for the request:

- `PipelineIntent`
- `SignalContract`
- `PipelineTopology`
- `TransformContract`
- `RouteContract`
- `BufferDeliveryPolicy`
- `SelfObservabilityPlan`
- `ValidationPlan`
- `GeneratedArtifactManifest`
- `PipelineProviderAdapterManifest` when provider-specific pipeline artifacts are requested

Use `references/pipeline-contract.md` when a concrete checklist or artifact shape is needed. Use `references/provider-pipeline-adapters.md` when named providers or runtimes require generated pipeline artifacts. Use `references/tool-agnostic-concepts.md` when the request needs concept clarification.

## Common Mistakes

- Starting from implementation syntax before defining source-to-sink lineage.
- Treating transforms as code snippets instead of contracts with tests.
- Losing sensitivity, owner, environment, or provenance metadata during normalization.
- Treating buffers as invisible even though they change loss, latency, replay, and cost.
- Routing telemetry without a declared delivery policy.
- Ignoring pipeline self-observability until the pipeline fails.
- Claiming delivery guarantees that the chosen stack or sink cannot actually enforce.
- Mixing provider pipeline generation with SLO, dashboard, monitor, or backend artifact generation that belongs in `$observability-engineering`.
