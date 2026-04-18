# Provider Terraform Adapters

Use this reference only after neutral observability and reliability intent exists. Provider resources are generated outputs, not the model.

## Adapter Contract

Every provider adapter must record:

- target provider, account/space/project, and owning team
- source intent artifacts and the neutral fields each resource implements
- blast radius of generated files and remote apply
- rollback path, usually revert generated Terraform plus restore previous state or import
- verification evidence: command, timestamp, output path, and affected metric/log/trace/event names
- provider/API gaps that prevent faithful generation

Never write secrets into generated Terraform. Use variables or provider-supported environment variables.

## Datadog Terraform

Use when the target is Datadog and the request asks for Terraform output.

Generate from neutral intent to:

- `datadog_service_level_objective` for SLO intent and reliability objectives
- `datadog_monitor` for alert intent, burn-rate signals, and action context
- `datadog_dashboard` or `datadog_dashboard_json` for decision dashboards
- `datadog_service_definition_yaml` when service ownership metadata is required
- `datadog_observability_pipeline` only when the pipeline contract explicitly targets Datadog Observability Pipelines

Required checks:

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan -refresh=false -out=tfplan
```

Datadog generated files must include tags derived from semantic attributes such as `service.name`, `deployment.environment`, `service.owner`, and source-intent IDs.

## Elastic Terraform

Use when the target is Elastic Stack or Elastic Cloud and the request asks for Terraform output.

Generate from neutral intent to:

- `elasticstack_kibana_space` for the target observability workspace when needed
- `elasticstack_kibana_slo` for SLO intent when the target stack version supports the required indicator type
- `elasticstack_kibana_action_connector` for notification connectors
- `elasticstack_kibana_alerting_rule` only after validating the exact Kibana rule type parameters against the target version
- saved-object import/API handoff for dashboards when Terraform provider support is insufficient or unstable

Required checks:

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan -refresh=false -out=tfplan
```

Elastic generated files must report gaps when dashboard, alert, or SLO semantics cannot be expressed safely by the provider version in use.
