# Tool-Agnostic Pipeline Concepts

## Component Graph

An observability pipeline is a directed graph of signal movement and signal change. A simple graph is source, transform, buffer, and sink. Real graphs often include fan-in, fan-out, routing, sampling, quarantine, replay, and fallback edges.

The graph is part of the system design, not an implementation detail. It determines data freshness, trust, loss behavior, incident evidence quality, and cost.

## Sources

Sources ingest signals from applications, infrastructure, control planes, audit systems, probes, synthetic checks, and existing stores. Source contracts define schema, timestamp semantics, identity, environment, ownership, sensitivity, expected volume, and malformed-data behavior.

## Transforms

Transforms change signals. Common transforms parse, normalize, enrich, redact, sample, aggregate, drop fields, rename fields, reduce cardinality, derive attributes, classify sensitivity, or convert schemas.

Every transform should have sample input, expected output, error behavior, and a validation path. A transform that drops or samples data must declare why the loss is acceptable.

## Routes

Routes select downstream paths. Route criteria should be deterministic and based on contract fields such as signal type, owner, environment, sensitivity, severity, destination, or cost class.

Routes must define unmatched behavior. Unmatched signals should not disappear silently.

## Buffers And Delivery

Buffers change operational semantics. They can improve resilience, but they also introduce latency, storage pressure, replay behavior, ordering questions, and loss modes.

Delivery policy must name the guarantee, retry behavior, timeout behavior, capacity, saturation behavior, backpressure behavior, replay expectations, and sink idempotency assumptions.

## Sinks

Sinks are downstream consumers. A sink may be a storage system, analysis engine, incident system, archive, quarantine path, or test harness.

Sink contracts define accepted schema, authentication boundary, delivery guarantee, batch behavior, rejection behavior, and expected self-observability.

## Self-Observability

Pipeline self-observability answers whether the pipeline itself is trustworthy. Define health and quality signals for ingest, transform, route, buffer, and delivery stages.

Minimum useful signals:

- received, emitted, dropped, quarantined, retried, and failed count
- bytes in and out
- processing latency and end-to-end latency
- queue depth, buffer occupancy, oldest item age, and spill usage
- parse, redaction, route, and delivery error count
- freshness lag
- component health and configuration version
- backpressure and sink availability

## Validation Layers

Use multiple validation layers because each catches different failures:

- contract review catches ambiguous intent
- static validation catches syntax and schema problems
- transform tests catch data-shape regressions
- replay tests catch representative behavior against real samples
- negative tests catch malformed input, sensitivity leaks, and cardinality explosions
- failure injection catches sink outages, saturated buffers, and retry storms
- canary rollout catches production integration surprises
