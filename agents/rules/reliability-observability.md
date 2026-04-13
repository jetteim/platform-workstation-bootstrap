# Reliability And Observability Rules

- For reliability work, capture target, command, timestamp, output path, metric/log/trace names, rollback path, and verification evidence.
- For infra changes, prefer plan, dry-run, or diff before apply, delete, or destroy.
- Do not claim fixed, passing, or complete without verification or an explicit caveat.
- Record concrete evidence: command, timestamp, output path, and the names of relevant telemetry.
