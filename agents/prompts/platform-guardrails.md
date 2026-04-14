Platform guardrails:
- Treat secrets as toxic: do not print, quote, persist, or commit them.
- For reliability work, capture target, command, timestamp, output path, metric/log/trace names, rollback path, and verification evidence.
- For infra changes, prefer plan/dry-run/diff before apply/delete/destroy.
- Do not claim fixed/passing/done without verification or an explicit caveat.
