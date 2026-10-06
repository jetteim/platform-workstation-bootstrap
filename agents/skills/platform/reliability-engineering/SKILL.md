---
name: reliability-engineering
description: Choose or review SLIs, SLOs and error-budget policy; assess readiness, incident learning and bounded resilience experiments. Use for reliability intent rather than telemetry backend implementation.
---

# Reliability Engineering

Reliability owns user-visible service quality, SLI/SLO choice, objective realism, calculation basis, error-budget policy and miss-policy. Preserve requested scope and existing authorization; failure is normal, but experiments must be bounded.

## Choose the relevant mode

Use [model-resolution.md](references/model-resolution.md) to locate a caller-configured model checkout. When unavailable, use [reliability-model-summary.md](references/reliability-model-summary.md) and disclose the fallback.

- For service onboarding, SLI/SLO selection and readiness, read the relevant sections of [workflows.md](references/workflows.md). Inventory measured telemetry and historical behavior before proposing objectives.
- For incidents, read its incident/postmortem section. Preserve impact and timeline evidence, distinguish incident response from aftercare, analyze contributing causes without blame, and create owned, verifiable action items.
- For directed or ambient resilience experiments, read its experiment section. Define hypothesis, failure model, exposure, abort conditions, pause authority and evidence before selecting an injection mechanism.
- For executable provider generation, read [sre-rules-generation.md](references/sre-rules-generation.md). Prefer the deterministic `sre-rules` engine from a reviewed neutral definition; report unavailable generators or unsupported providers as gaps.
- For Terraform, read [provider-handoff.md](references/provider-handoff.md). Hand neutral intent to `observability-engineering`; do not hand-write provider Terraform here. If that companion is absent, emit the complete handoff and name the missing capability.

## Essential contract

- Choose SLIs from the user's point of view. Define success, objective ratio, window, measured scope and observations-based versus time-slice calculation explicitly; keep low-volume and dependency behavior visible.
- Reality-check objectives against history, consumer expectations and instrumentation quality. Deferring an objective is preferable to inventing telemetry or a target.
- Every miss-policy needs trigger, response, authority and exit condition. Every action item needs owner, evidence and a verification method.
- Resilience experiments require explicit scope, safety preconditions, maximum impact, abort/rollback and review of accepted risks. Planning is not permission to inject failures.
- `observability-engineering` owns telemetry query bindings, alerts, dashboards and backend projections. `creating-observability-pipelines` owns collection/delivery topology. Use their outputs as evidence rather than duplicating their models; provide equivalent bounded handoffs if unavailable.
- Capture target, command, timestamp, output path, signal names, rollback and verification result. Distinguish intended, generated, fixture-validated and live-verified behavior.
- Prefer plan/dry-run/diff before live apply. Existing authorization settles ordinary local work; live provider mutation or failure injection must be within explicitly authorized scope.

Return the smallest useful neutral intent, decisions, owned actions, handoffs and evidence gaps for the requested mode.
