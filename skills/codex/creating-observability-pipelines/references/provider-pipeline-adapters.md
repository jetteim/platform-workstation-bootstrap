# Provider Pipeline Adapter Reference

Use this reference when a neutral pipeline contract must be projected into concrete provider or runtime artifacts. The neutral contract remains authoritative. Provider artifacts are generated outputs and must not weaken redaction, routing, buffering, replay, quarantine, delivery, validation, or self-observability requirements without an explicit gap.

## Ownership Boundary

This skill owns provider adapters for telemetry movement:

- source collection and intake
- parsing, normalization, enrichment, redaction, sampling, and cardinality control
- deterministic routing, fan-out, quarantine, and dead-letter paths
- buffering, retry, backpressure, replay, and delivery behavior
- pipeline self-observability
- provider syntax, schema, and simulation validation commands

Delegate these outputs to `$observability-engineering`:

- SLOs and SLIs
- alert monitors and paging policy
- dashboards and notebooks
- backend query packs
- service catalog entries
- reliability reviews that consume pipeline telemetry

## PipelineProviderAdapterManifest

```yaml
PipelineProviderAdapterManifest:
  source_pipeline_artifacts:
    - PipelineIntent
    - SignalContract
    - PipelineTopology
    - TransformContract
    - RouteContract
    - BufferDeliveryPolicy
    - SelfObservabilityPlan
  provider_targets:
    - datadog-observability-pipelines
    - elastic-ecosystem
  generated_pipeline_artifacts:
    - provider pipeline config
    - transform tests or simulation requests
    - route and sink mapping
    - quarantine mapping
    - validation commands
  owned_by_pipeline_skill:
    - source-to-sink pipeline generation
    - redaction and transform projection
    - delivery and buffer gap reporting
    - malformed input quarantine behavior
    - provider syntax and simulation checks
  delegated_to_observability_engineering:
    - SLOs
    - dashboards
    - monitors
    - backend observability packs
  provider_gaps:
    - provider or runtime limitations that prevent faithful contract projection
  safety:
    target: generated provider pipeline files
    blast_radius: no remote apply unless explicitly requested
    rollback_path: revert generated provider pipeline version
    review_gate: validate syntax and simulate representative plus malformed events before apply
```

## Datadog Observability Pipelines

Provider target id: `datadog-observability-pipelines`.

Generate Datadog Observability Pipelines artifacts for source-to-sink telemetry movement only:

- source mapping from the neutral `PipelineTopology`
- parser, remap, redaction, sampling, and route steps from `TransformContract` and `RouteContract`
- primary sink and quarantine sink mapping
- buffer and retry gap report from `BufferDeliveryPolicy`
- pipeline health signals from `SelfObservabilityPlan`
- syntax or schema validation command

Use Terraform only when the provider schema has been verified for the desired resource. If generating Terraform, prefer explicit review output before remote apply. For example, only emit a `datadog_observability_pipeline` resource after checking that the installed provider version supports the required schema. If schema support is unknown, emit a provider gap and a validation request instead of inventing resource fields.

## Elastic Ecosystem

Provider target id: `elastic-ecosystem`.

Project the neutral contract into the smallest Elastic combination that preserves the contract:

- `elasticstack_elasticsearch_ingest_pipeline` for ingest processors that parse, normalize, redact, enrich, and route where supported
- Logstash pipeline config when durable buffering, richer conditionals, dead-letter queues, or output retry behavior are required
- Elastic Agent or Fleet policy handoff when collection and source ownership need to be managed outside ingest pipelines
- `_simulate` requests for ingest pipeline transform validation
- malformed-event and redaction test samples

Report gaps when Elasticsearch ingest pipelines alone cannot provide durable replay, at-least-once delivery, persistent buffering, or sink-outage handling. Do not claim those delivery properties unless the selected Elastic runtime actually provides them.

## Common Runtime Projections

- **OpenTelemetry Collector:** generate receivers, processors, exporters, connectors, health check extension, and pipeline graph; report gaps for durable replay unless paired with a queue or storage extension that satisfies the contract.
- **Vector:** generate sources, transforms, routes, sinks, disk buffers, acknowledgements, and internal metrics validation.
- **Fluent Bit:** generate inputs, filters, parsers, outputs, storage settings, and health checks; report gaps for complex routing or replay semantics if plugins cannot express them.

## Adapter Rules

- Provider artifacts are generated outputs, not the model.
- Keep the neutral `PipelineIntent`, `SignalContract`, and topology provider-independent.
- Do not include secrets, tokens, API keys, private endpoints, or credentials in generated artifacts.
- Keep source-to-sink lineage visible in provider output names and comments.
- Preserve redaction and quarantine behavior before data reaches primary sinks.
- Record any mismatch between neutral delivery guarantees and provider behavior in `provider_gaps`.
- Include validation commands for static syntax, schema validation, transform simulation, malformed input, redaction, and rollback.
