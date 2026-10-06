# Detailed workflows

Load only the section for the current task. Explicit user scope and delegated authorization take precedence over workflow suggestions.

## Workflow

### 1. Load the relevant model

Use [model-resolution.md](model-resolution.md) to locate a configured checkout or a bundled fallback.

If a private checkout is present, read only the relevant files:

- `docs/intent/principles.md`
- `docs/usage-scenarios/infra-observability-readiness.md` when building or reviewing infrastructure observability
- `docs/usage-scenarios/service-onboarding-to-observability.md` when onboarding or preparing service observability
- `docs/intent/infra-observability.md` when building or reviewing infrastructure observability
- `docs/intent/telemetry-pipeline-model.md` when collector, routing, transformation, buffering, delivery, or telemetry quality matters
- `docs/intent/semantic-conventions.md`
- `docs/intent/alert-context-contract.md`
- `docs/intent/decision-dashboard-model.md`
- `docs/intent/slo-and-error-budget-model.md`
- `docs/intent/backend-generation-model.md`
- `docs/devex/*.md` when enforcement or developer workflow matters
- `docs/migration/*.md` when SRE rules are involved

If no private checkout is present, use `references/observability-model-summary.md` and state that the bundled reference fallback was used. Do not invent content from the private model.

When a usage scenario applies, follow it as the execution contract. The scenario defines expected inputs, outputs, refusal conditions, human review gates, and completion criteria.

### 2. Discover Current Reality

Inventory only what is needed for the request:

- service or platform ownership model
- Kubernetes workload, route, namespace, and Helm artifacts
- OpenTelemetry resource attributes and instrumentation
- existing metrics, logs, traces, RUM, synthetics, probes, and events
- current monitors, dashboards, rules, and playbooks
- CI, admission policy, and validation paths
- topology correlation across metrics, logs, traces, events, inventory, routes, workloads, owners, and changes
- telemetry pipeline health for collectors, receivers, processors, queues, exporters, sampling, dropped data, freshness, and backend delivery
- telemetry pipeline topology across sources, processors, sinks, buffers, acknowledgement boundaries, and fallback or quarantine paths

Summarize current implementation as evidence. Do not let vendor-specific resources become the model.

### 3. Define Semantic Conventions

Create or update a semantic convention registry:

- baseline OpenTelemetry attributes
- org attributes with purpose, cardinality, owner, allowed values, and enforcement points
- migration behavior for old labels or tags
- generated projections for backend tags and dashboard variables

Reject high-cardinality resource attributes unless the intent explicitly marks them as event-only.

### 4. Build Observability Intent

Reference the reviewed reliability-owned SLI/SLO choice, objective and error-budget policy. `SLOIntent` below carries that source intent into bindings and backend projections; choosing new objectives belongs to reliability-engineering. Pipeline artifacts similarly carry the reviewed collection/delivery contract rather than redefining its guarantees here.

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

When telemetry pipeline work matters, also define pipeline topology, component contracts, delivery policy, buffer policy, transformation tests, self-observability, and validation requirements. Record generation gaps when a target pipeline engine or backend cannot enforce required redaction, cardinality, delivery, or validation behavior.

When `creating-observability-pipelines` is available and the request needs an implementable pipeline contract, use it to produce `PipelineIntent`, `SignalContract`, `PipelineTopology`, `TransformContract`, `RouteContract`, `BufferDeliveryPolicy`, `SelfObservabilityPlan`, `ValidationPlan`, and `GeneratedArtifactManifest` outputs. Then map those outputs back into this skill's SLO, alert, dashboard, semantic convention, and backend-generation artifacts as needed.

For infrastructure observability, produce the artifacts described by `docs/usage-scenarios/infra-observability-readiness.md`: platform observability intent, infrastructure signal inventory, metadata coverage assessment, topology correlation requirements, telemetry pipeline topology and health requirements, infrastructure alert context contract, decision dashboard intent, signal classifications, instrumentation gaps, enforcement gaps, and generated artifact manifest or backend generation request.

For service onboarding, produce the artifacts described by `docs/usage-scenarios/service-onboarding-to-observability.md`: service intent, semantic convention updates, SLO intent, SLI query bindings, telemetry pipeline requirements or generation gaps, alert or notification classifications, decision dashboard intent, generated artifact manifest, and enforcement recommendations.

### 5. Classify Alerts

Use this taxonomy:

- **Alert:** immediate action required, direct or highly probable impact, complete context.
- **Notification:** useful operational signal, no immediate human action.
- **Finding:** standard, policy, or telemetry drift handled through DevEx or backlog.

Do not page on job failures, restarts, partial replica loss, or telemetry drift by default. Promote them only when user impact, owner, playbook, and decision context are explicit.

For infrastructure signals, also keep these defaults:

- classify isolated restarts, node pressure, quota pressure, collector drops, policy drift, and metadata drift as notifications or findings unless they have direct or highly probable impact
- promote route-to-zero-ready-backend, platform-wide scheduling failure, control-plane unavailability, critical telemetry loss, or capacity exhaustion only when owner, action, playbook, and scoped dashboard are complete
- treat missing telemetry as its own signal; do not infer healthy infrastructure from absent data

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
- telemetry pipeline configuration and validation tests

Generated artifacts must identify their source intent. If a backend cannot express the intent safely, report the gap.

For Datadog or Elastic Terraform output, load `references/provider-terraform-adapters.md` before generating files. Keep provider resources as adapters from `ObservabilityIntent`, `SloIntent`, `AlertContextContract`, `DecisionDashboardIntent`, pipeline artifacts, and reliability evidence. Do not embed secrets; capture target, blast radius, rollback path, and verification evidence.

### 7. Validate

Before claiming completion, check:

- every SLO has a telemetry binding or documented instrumentation gap
- every alert has ownership, impact, current state, change context, technical evidence, decision support, dashboard, and playbook
- every dashboard opens from alert dimensions, not manual overview assumptions
- semantic conventions are enforced at appropriate layers
- generated artifacts are reproducible from the model
- provider Terraform adapters reference neutral source intent, keep credentials as variables or environment-derived values, include syntax/plan validation commands, and report provider/API gaps
- telemetry pipeline work includes source-to-sink lineage, transformation contracts, delivery policy, buffer policy, validation, and self-observability checks
- infrastructure work includes metadata coverage, topology correlation, telemetry pipeline health, and infrastructure alert context contract checks

## Common Mistakes

- Starting with a backend query language before obtaining the reviewed reliability-owned SLO intent.
- Copying vendor tags into the model instead of deriving them from semantic attributes.
- Treating dashboards as manual overview boards.
- Paging on symptoms that do not require immediate human action.
- Creating alerts without playbook actions or scoped dashboards.
- Migrating old SRE rules one-to-one instead of reclassifying them by intent.
- Treating telemetry collectors, transforms, buffers, and sinks as invisible implementation details when their failure changes observability truth.
