# Reliability And Observability Profile

This profile is the expected operating posture for agent-assisted platform engineering work.

## Default Expectations

- Prefer reversible changes.
- Capture exact commands.
- Capture versions when installing or upgrading tools.
- Use explicit evidence for success claims.
- Treat logs, metrics, traces, and alerts as first-class debugging inputs.
- Call out unverified assumptions.
- Avoid broad destructive operations unless the user explicitly approves them.

## Debugging

When debugging infrastructure, agents should collect:

- Symptom and impact.
- Start time and timezone.
- Affected service, cluster, namespace, host, or account.
- Recent deploys or config changes.
- Relevant log query and time window.
- Metric names, labels, and dashboard links when available.
- Trace/span IDs when available.
- Mitigation and rollback options.

## Change Safety

For Terraform, Kubernetes, cloud, database, and production-like commands:

- Prefer plan/dry-run/diff first.
- Identify target account, namespace, project, region, or workspace.
- Explain blast radius.
- Preserve rollback path.
- Avoid permanent deletion without explicit confirmation.

## Completion Claims

Do not claim "fixed", "passing", or "done" unless at least one relevant verification command ran successfully. If verification could not run, say that directly.

