# Reliability Model Summary

Use this file when the private `platform-reliability-model` repository is unavailable.

## Principles

- Reliability is socio-technical.
- Incident response and postmortem aftercare are different workflows.
- Analysis must be blameless and evidence-backed.
- SLI/SLO selection is a core reliability decision.
- Action items must directly follow from analysis.
- SLO misses and incidents are related but not identical.
- Miss-policy is a pre-agreed operating mode.
- Resilience experiments are hypothesis-driven and risk-aware.
- Ambient failure experiments create regular, bounded disruption so teams treat the principle that failure is normal as a design constraint.
- Observability provides evidence and generated artifacts; reliability owns risk, learning, and operational change.

## Service Reliability Pattern

1. Establish service identity, owner, escalation, criticality, and capabilities.
2. Inventory dependencies and failure modes.
3. Inventory measured telemetry and historical behavior.
4. Generate candidate SLIs and SLOs from telemetry that represents user-visible quality.
5. Mark telemetry gaps where the right reliability signal is missing.
6. Choose candidate SLIs from user-visible quality signals.
7. Define SLI instances when one indicator has multiple measured scopes.
8. Define SLO success conditions, objective ratios, windows, and calculation basis.
9. Reality-check SLOs against history, dependencies, users, product goals, and repair capability.
10. Assess graceful degradation, cache-on-failure, timeout, retry, circuit breaker, workload isolation, error reporting, and rollback strategies.
11. Identify directed or ambient resilience experiment candidates for assumptions that should be proven regularly.
12. Define operational readiness.
13. Create action items for gaps.

## SLI/SLO Pattern

1. Identify users and consumers.
2. Identify user-visible quality dimensions.
3. Inventory measured telemetry and group it by latency, traffic, errors, saturation, freshness, availability, and user journeys.
4. Generate candidates from measured telemetry, but reject metrics that cannot be explained as service quality.
5. Choose unqualified SLIs from latency, traffic, errors, saturation, or user journeys.
6. Define success in the SLO.
7. Define SLI instances when one indicator has multiple measured targets or scopes.
8. Record measurement details that affect interpretation.
9. Check historical behavior.
10. Check dependency behavior and dependency SLOs.
11. Choose an objective ratio that leaves meaningful error budget.
12. Choose observations-based or time-slice-based calculation.
13. Define burn-rate and miss-policy expectations.
14. Hand telemetry binding and backend generation to observability.

## Reliability Recommendations Pattern

Review dependency inventory, graceful degradation, cache-on-failure, asynchronous behavior, circuit breakers, timeout tuning, error reporting, workload isolation, release safety, and playbooks.

## Ambient Resilience Experiment Pattern

1. Classify the experiment as ambient failure when the goal is repeated resilience pressure rather than a one-time directed test.
2. State the hypothesis and expected behavior in user-visible or consumer-visible terms.
3. Define the target class: own workload, dependency, platform primitive, data path, or control plane.
4. Define the failure mode: restart, timeout, error response, latency, partial capacity loss, stale data, or dependency unavailability.
5. Define exposure, cadence, jitter, target selection policy, exclusion windows, and maximum concurrent impact.
6. Define safety preconditions, abort criteria, accepted risks, and pause or skip authority.
7. Tie evidence to SLOs, user journeys, dependency behavior, retries, circuit breakers, fallback paths, logs, and traces.
8. Convert failed expectations into owned action items with verification methods.

## Incident To Learning Pattern

1. Normalize incident record.
2. Confirm impact and urgency.
3. Build chronological timeline.
4. Preserve evidence.
5. Document resolution.
6. Evaluate impact.
7. Analyze trigger, enabling components, and response timeline.
8. Classify contributing causes.
9. Write reusable lessons.
10. Create owned, verifiable action items.
