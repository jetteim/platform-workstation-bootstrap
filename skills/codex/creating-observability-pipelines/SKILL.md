---
name: creating-observability-pipelines
description: Create, review or migrate telemetry collection, transforms, routing, buffering and delivery. Use for source-to-sink pipeline contracts and self-observability across runtimes.
---

# Creating Observability Pipelines

Start from a neutral source-to-sink contract; collector, stream and backend configurations are projections of it. Preserve the selected stack and requested scope.

Use `reliability-engineering` for SLI/SLO selection, objectives and error budgets; use `observability-engineering` for reviewed query bindings, alerts and dashboards. If a companion is absent, produce an equivalent bounded handoff or report the capability gap.

## Pipeline contract

1. Bound purpose, signals, ownership, sensitivity, consumers, failure tolerance and rollback.
2. Map source-to-sink lineage, transforms, routes, buffers and sinks. Name acknowledgement boundaries and every place signals can be dropped, duplicated, delayed, reordered, sampled or redacted.
3. Define schema, timestamps, correlation, cardinality, provenance and redaction. Distinguish contract requirements from runtime guarantees.
4. Declare capacity, saturation, retry/backoff, delivery, replay, deduplication and backpressure policies. Never promise guarantees the runtime and sink cannot enforce together.
5. Expose pipeline health, including traffic, losses/quarantine, freshness, processing latency, queue depth/age, configuration state and delivery errors.
6. Generate only requested artifacts. Validate syntax, representative/malformed transforms, redaction, sink outage and buffer saturation as appropriate; label unexecuted checks rather than claiming delivery was proven.

Read [workflows.md](references/workflows.md) for detailed transform, delivery, self-observability and validation contracts. Read [pipeline-contract.md](references/pipeline-contract.md) for artifact shapes, [provider-pipeline-adapters.md](references/provider-pipeline-adapters.md) for a named runtime/provider, and [tool-agnostic-concepts.md](references/tool-agnostic-concepts.md) only when concept clarification is needed. Attribute migration follows [semantic-conventions.md](references/semantic-conventions.md).

Keep unsupported provider behavior explicit. For reliability-sensitive work capture target, command, timestamp, output path, metric/log/trace/event names, rollback path and result. Prefer plan/dry-run/diff before authorized apply; contract generation does not authorize a live change.
