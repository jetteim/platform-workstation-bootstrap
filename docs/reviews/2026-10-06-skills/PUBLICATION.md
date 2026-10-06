# Published skill maintenance — 6 October 2026

The user authorized saving the review, committing and pushing the skill-maintenance changes, then updating and pushing bootstrap. Five source commits were pushed successfully to `origin/main` before recording their revisions here.

| Source repository | Published commit |
| --- | --- |
| `architectural-execution-skills` | [`026d845`](https://github.com/jetteim/architectural-execution-skills/commit/026d8454037edfbd6670c599f82ebdc7362255ce) |
| `observability-engineering` | [`290d684`](https://github.com/jetteim/observability-engineering/commit/290d68402d30a3091ddc32235218bf0f053d0c6a) |
| `observability-pipeline-skills` | [`bc40b5c`](https://github.com/jetteim/observability-pipeline-skills/commit/bc40b5c8991e491199a2d14d1c7602451f95da50) |
| `reliability-engineering` | [`2266054`](https://github.com/jetteim/reliability-engineering/commit/2266054410119aa7f2edcb676732d8f83396da8a) |
| `zenmoney-receipts` | [`a22449d`](https://github.com/jetteim/zenmoney-receipts/commit/a22449d3fb76e307fee36658c4ad10f70404967d) |

The bootstrap commit containing this document includes synchronized skill packages/projections, the creation/audit split, source provenance, lifecycle proposals, installer resource fixes, evaluator tooling and these saved review reports. Its SHA is available in Git history; it is not self-embedded in its contents. The final remote SHA is checked after push.

Verification before source publication: all four dedicated validators passed; all commits passed the staged safety hook. ZenMoney's isolated staged tree passed `npm run check` with 86 application tests, 1 hosted test skipped, build/typecheck, 39-tool MCP/private-backend smoke, 10 fixture cases, six runner simulations and package verification. This snapshot excludes earlier local receipt-memory correction code, tests, documentation and its CLI check. Those changes remain in the working tree. The earlier implementation check's 91-test count applies to that mixed working tree only.

Bootstrap verification uses `./scripts/verify.sh` with disposable homes and `python3 scripts/check-skill-drift.py --require-sources`. Source package bytes match the newly committed versions, and provider-owned runtime/cache boundaries remain intact. See `evidence/publication.json` for sanitized publication metadata. No live install, financial mutation, deployment, model training or model-backed evaluation is part of publication.

Rollback: use scoped reverts of the named maintenance commits and restore bootstrap source/projection provenance together. Preserve unrelated local work; do not reset the mixed ZenMoney checkout.
