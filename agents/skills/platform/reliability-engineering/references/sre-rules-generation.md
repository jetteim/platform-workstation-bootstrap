# SRE Rules Generation Reference

Use this reference when reliability work needs executable SLI/SLO, alert, route, dashboard, or provider artifact generation. The deterministic generator is `sre-rules`, implemented by the `slo-rules-engine` checkout and its `bin/rules-ctl` CLI.

## Boundary

Reliability still owns the neutral model:

- service reliability boundary
- SLI semantics
- SLO objective and window
- calculation basis
- miss-policy
- reliability recommendations
- resilience experiment evidence needs

`sre-rules` owns deterministic generation from a reviewed service definition:

- provider manifests
- SLO definitions
- burn-rate alert context
- missing-telemetry alerts
- notification route catalog entries
- dashboard manifests
- model reports
- reality-check and apply dry-run plans where supported

Provider Terraform remains outside this skill. If the user asks for Terraform, emit a `ReliabilityProviderHandoff` for `observability-engineering` unless a future deterministic provider explicitly supports that output.

## Resolve The Engine

Look for `slo-rules-engine` in this order:

```bash
sre_rules_root="${SRE_RULES_ENGINE_ROOT:-${AGENTS_HOME:-$HOME/.agents}/vendor_imports/repos/slo-rules-engine}"
if [ ! -x "$sre_rules_root/bin/rules-ctl" ]; then
  sre_rules_root="$HOME/Library/CloudStorage/OneDrive-Personal/Pet projects/slo-rules-engine"
fi
test -x "$sre_rules_root/bin/rules-ctl"
```

If no checkout is available, do not fabricate generated artifacts. Output an `SreRulesGenerationGap` with the missing checkout path and the generation commands that should be run after installation.

## Required Generation Flow

For an accepted service definition:

```bash
bin/rules-ctl validate examples/services/checkout.rb
bin/rules-ctl model-report examples/services/checkout.rb
bin/rules-ctl providers list
bin/rules-ctl generate --provider datadog examples/services/checkout.rb
bin/rules-ctl generate --provider prometheus_stack examples/services/checkout.rb
bin/rules-ctl generate --provider sloth examples/services/checkout.rb
bin/rules-ctl generate-routes --integration notification_router examples/services/checkout.rb
```

Use `rules-ctl model-report` as the review gate before provider generation. It confirms that provider-independent reliability intent exists before translation.

Use `rules-ctl generate --provider` only for providers listed by `rules-ctl providers list`. Supported providers in the current engine include:

- `datadog`
- `prometheus_stack`
- `sloth`

Supported delivery integration:

- `notification_router`

Unsupported providers must be reported as gaps. For example, an Elastic request currently needs a handoff to `observability-engineering` or a future `sre-rules` provider contribution.

## SreRulesGenerationPlan

```yaml
SreRulesGenerationPlan:
  generator: sre-rules
  engine_checkout: ${AGENTS_HOME:-$HOME/.agents}/vendor_imports/repos/slo-rules-engine
  source_definition: examples/services/checkout.rb
  review_gate:
    - bin/rules-ctl validate examples/services/checkout.rb
    - bin/rules-ctl model-report examples/services/checkout.rb
  provider_targets:
    supported:
      - datadog
      - prometheus_stack
      - sloth
    unsupported:
      - elastic
  generation_commands:
    - bin/rules-ctl generate --provider datadog examples/services/checkout.rb
    - bin/rules-ctl generate --provider prometheus_stack examples/services/checkout.rb
    - bin/rules-ctl generate --provider sloth examples/services/checkout.rb
    - bin/rules-ctl generate-routes --integration notification_router examples/services/checkout.rb
  generated_outputs:
    - provider manifests
    - burn-rate alerts
    - missing-telemetry alerts
    - dashboard manifests
    - route catalog entries
  gaps:
    - Elastic provider generation requires a future sre-rules provider or observability-engineering handoff.
    - Terraform generation remains delegated unless deterministic provider support is added.
  safety:
    blast_radius: generated files and reviewable manifests only
    rollback_path: revert generated artifact commit or restore previous output directory
    live_apply_requires_explicit_confirmation: true
```

## Safety Rules

- Do not generate provider artifacts by hand when `sre-rules` can generate them.
- Do not run `rules-ctl apply --confirm` without explicit user approval.
- Prefer `rules-ctl apply --dry-run` when state management is requested.
- Do not include credentials, API keys, internal hostnames, or private metric selectors in generated examples.
- Keep provider warnings and unsupported fields visible in the final output.
- Preserve the neutral reliability model as the source of truth even when generated provider output exists.
