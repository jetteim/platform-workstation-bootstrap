# Pipeline Contract Reference

Use this reference when a pipeline task needs a concrete artifact shape.

## PipelineIntent

```yaml
name: checkout-observability-pipeline
purpose: Normalize and deliver checkout service telemetry for reliability analysis.
owners:
  service: checkout
  platform: observability-platform
role: reliability-critical
signals:
  - logs
  - metrics
  - traces
environments:
  - production
consumers:
  - incident-response
  - slo-analysis
rollback:
  strategy: revert-to-previous-pipeline-version
  max_time: 15m
```

## SignalContract

```yaml
signal: logs
required_fields:
  - timestamp
  - service.name
  - deployment.environment
  - severity
  - message
  - trace.id
cardinality_limits:
  service.name: bounded-service-registry
  deployment.environment: bounded-environment-list
  user.id: event-only
sensitivity:
  default: internal
  redacted_fields:
    - request.headers.authorization
    - payment.card.number
malformed_behavior:
  action: quarantine
  reason: preserve evidence without polluting primary stores
```

## PipelineTopology

```yaml
sources:
  app_runtime_logs:
    signal: logs
    owner: checkout
    expected_volume: 2500 events/min
transforms:
  normalize_common_fields:
    input: app_runtime_logs
    output: normalized_logs
  redact_sensitive_fields:
    input: normalized_logs
    output: redacted_logs
routes:
  reliability_logs:
    input: redacted_logs
    match: severity in ["error", "warn"] or has(trace.id)
  quarantine:
    input: redacted_logs
    match: schema.valid == false
buffers:
  reliability_delivery_buffer:
    input: reliability_logs
    type: durable
sinks:
  reliability_store:
    input: reliability_delivery_buffer
  quarantine_store:
    input: quarantine
```

## TransformContract

```yaml
name: redact_sensitive_fields
input_contract: normalized_logs
output_contract: redacted_logs
behavior:
  - remove payment.card.number
  - replace request.headers.authorization with "[redacted]"
failure_behavior:
  malformed_input: quarantine
  missing_field: continue
tests:
  representative_sample: examples/log-with-payment-fields.json
  expected_output: examples/log-with-redacted-fields.json
  negative_cases:
    - authorization header must not reach any primary sink
```

## BufferDeliveryPolicy

```yaml
name: reliability_delivery_buffer
delivery_guarantee: at-least-once
capacity: 30m of peak production traffic
saturation_behavior: apply-backpressure-before-dropping
retry:
  timeout: 10s
  backoff: exponential
  max_elapsed: 20m
ordering: not guaranteed
deduplication: downstream idempotency key is event.id
replay: supported for retained buffer window
```

## SelfObservabilityPlan

```yaml
signals:
  - pipeline.records.received
  - pipeline.records.emitted
  - pipeline.records.dropped
  - pipeline.records.quarantined
  - pipeline.delivery.errors
  - pipeline.buffer.occupancy
  - pipeline.buffer.oldest_item_age
  - pipeline.freshness.lag
  - pipeline.config.version
dashboards:
  - incident pipeline trust dashboard scoped by service, environment, source, and sink
alerts:
  - handled through observability-engineering when these signals affect paging evidence
```

## ValidationPlan

```yaml
static_validation:
  command: run the chosen stack's config/schema validation
transform_tests:
  command: run transform contract tests with representative and malformed samples
replay_tests:
  command: replay bounded production samples into a non-production sink
failure_tests:
  cases:
    - sink unavailable
    - buffer saturated
    - malformed source event
    - sensitivity field present
completion_evidence:
  target: checkout production telemetry pipeline
  command: ./scripts/validate-pipeline.sh checkout
  timestamp: 2026-04-18T00:00:00Z
  output_path: artifacts/checkout-pipeline-validation.txt
  rollback_path: revert-to-previous-pipeline-version
```
