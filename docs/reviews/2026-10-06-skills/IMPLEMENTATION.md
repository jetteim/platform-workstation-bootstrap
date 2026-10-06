# Skill review implementation — 6 October 2026

Publication follow-through: source commits have been pushed to `main`; bootstrap records those committed revisions. See [PUBLICATION.md](PUBLICATION.md). The initial implementation evidence below predates publication. ZenMoney publication was separately checked on an isolated staged tree: 86 application tests passed, 1 hosted test skipped; pre-existing correction work remains uncommitted.

All selected actions A1–A12 were implemented in the six local repositories. S2 now separates curated CLI creation from the local readiness audit/retrofit. S1 and S3 produced the approved coverage/migration and ownership proposals; they do not archive repositories or remove working fallbacks.

The bootstrap's authored source snapshots and projections are synchronized. There are now **41 distinct canonical skill packages**, **82 physical bootstrap manifests** and **95 manifests across the six reviewed repos**. The added package is the reviewed curated `cli-creator`, including its reference, UI metadata and license.

## Changes

| Action | Result |
| --- | --- |
| A1 | Reliability owns SLI/SLO selection, objectives and error budgets; observability binds reviewed intent and generates backend artifacts; pipelines own collection/delivery. Source manifests, detailed workflow references and READMEs agree. |
| A2 | New observability/pipeline contracts, fixtures and Elastic examples use `deployment.environment.name`. Packaged compatibility guidance preserves explicit legacy mappings, marks `service.owner` as an organization extension and requires target convention version/stability metadata. No emitter or live backend was migrated. |
| A3 | Slides stops after the requested outcome is verified, permits a read-only check for an already-correct slide, refreshes live geometry and requires actual pixel inspection. Further writes need a remaining defect. Detailed layout guidance moved into conditional references; inherited pass quotas were removed. |
| A4 | Local PPTX edits preserve the requested local workflow. Import requires an explicit or established Google Slides destination; conversion/fidelity verification remains. |
| A5 | Added a standard-library opt-in fresh-run evaluator, 61 synthetic scenario definitions, capture schema and offline protocol tests. Captures record prompt, revision/package digest, model/runtime, timestamp/run ID, transport trace, structured artifact, result and elapsed time. Existing saved-output checks explicitly report fixture validation. The runner is executable adapter infrastructure; it does not include a certified model/runtime adapter or establish a model baseline. |
| A6 | Shortened observability, pipeline and reliability entrypoints while preserving detailed workflows. Explicit model/engine roots take precedence; missing explicit roots are errors, bundled fallback is disclosed and unavailable generators remain gaps. ZenMoney storage/preference/comment rules are packaged inside each relevant skill, with financial safety retained in the entrypoints. |
| A7 | Architecture counts are optional working-size heuristics. Preserve supplied hierarchy/backlogs and choose a bounded active slice. Companions/plans/tests are proportional; settled authorization does not require routine reapproval. Unique value-stream, capability, C4 and acceptance/traceability contracts remain. |
| A8 | Shortened authored architecture, ZenMoney, Google helper and PR-comment discovery descriptions. Minimal receipt prompts and adjacent workflow distinctions remain. Provider system descriptions were left intact. |
| A9 | Declared the configured `zenmoney-receipts` MCP identity in all three ZenMoney UI manifests; added nine optional UI manifests for authored architecture/observability/reliability skills. Google helpers check operation-specific connected app capabilities without inventing an MCP server or reconnecting accounts. |
| A10 | Brain separates the measured Qwen3-0.6B smoke recipe from external examples, qualifies benchmark claims, and uses selected tokenizer metadata rather than universal token IDs. Added a local metadata inspector and synthetic consistency tests. Training, export, downloads and live hook replacement were not run. |
| A11 | Added complete reviewed-package hashes, local source revision/digest records, lifecycle/provenance inventory and a drift gate. Unexpected canonical/source/projection differences fail; recorded refinements are retained. Missing sibling sources are reported for portable use and can be required explicitly. |
| A12 | GitHub CI fixes continue within existing authorization; read-only requests remain read-only. Authorized Drive comments split into bounded batches within the same scope, with duplicate prevention on uncertain retries. Financial exact-preview and external-message authorization remain. |
| S1 | Architecture README marks a partial sunset candidate and links a bounded pilot/coverage proposal. Notion and goal-tool overlap does not replace the unique local core or authorize remote artifacts. |
| S2 | Added pinned curated `cli-creator` with local routing, secret-handling and installation-scope refinements. Narrowed `engineering-agent-ready-clis` to explicit audits, verification, retrofit and CLI/MCP parity. Both reject secret command flags. |
| S3 | Recorded provider/source ownership and conditional maintenance-retirement proposals for PDF/Jupyter/system/GitHub fallbacks. Pinned offline packages and deliberate local refinements remain available. |

## Bootstrap follow-through

Updated reviewed canonical roots under `agents/skills/platform`, `agents/skills/codex-curated` and `agents/skills/plugins`, and matching `skills/codex` / `skills/plugins` projections. Updated the CLI projection/inventory and external dependency/lifecycle documentation.

Codex helper installation now bundles shared Slides references without installing a duplicate core Google Drive skill over the native plugin. The disposable-home installer test verifies installed helper resource links, byte equality, reinstall/pruning and preservation of provider system state. Existing runtime `.system` and active plugin caches were not edited.

ZenMoney maintenance is recorded as F-029 / D-022. Pre-existing local evidence correction work was preserved. F-025/F-026 remain paused; F-027's actual synthetic host baseline remains planned.

## Verification

| Check | Verified result and limit |
| --- | --- |
| All package frontmatter and entrypoint resources | **95 passed**, 91 UI manifests parsed; no missing linked resources or whitespace/conflict findings. Provider system snapshots remain unchanged. |
| Four dedicated `./scripts/validate.sh` commands | **Passed**: YAML/provider fixture contracts, package resources, scenario definitions and six runner simulation tests per packaged runner. Observability/reliability also pass explicit-root/fallback/engine resolver tests. |
| Bootstrap `./scripts/verify.sh` | **Passed**: 8 installer/hook/config tests, 6 runner simulations, 2 drift tests and 2 tokenizer tests, plus syntax/compile and 41-package drift checks. |
| Bootstrap `check-skill-drift.py --require-sources` | **Passed**, all local source packages available and identical to reviewed snapshots. Deliberate/unrecorded drift handling is tested separately with fixtures. |
| ZenMoney `npm run check` | **Passed**: 91 application tests, 1 hosted integration test skipped; typecheck/build, correction CLI, 39-tool MCP/private backend smoke, 10 saved receipt cases, repository/package verification and six runner simulations. |
| Fresh-run capture proof | Simulation subprocesses produce fresh UUID captures with revision/package hashes; changed adapter output fails the invariant; saved fixtures remain unchanged; existing capture files cannot be overwritten. Trace safety does not accept claimed success in place of confirmed/verified mutation evidence. |

The 61 scenario definitions are **not 61 completed model runs**. The initial implementation performed no real model evaluation, personal receipt query, live financial mutation, provider apply, deployment, live installation or repository archival. Commits and pushes were authorized subsequently and are recorded in PUBLICATION.md. The generic adapter runner is not a security sandbox; actual adapters need isolated fake tools and independent trace/artifact extraction. Dynamic tokenizer tests use synthetic metadata; no downloaded model/tokenizer parity is claimed. Provider-backed Terraform plans and hosted integration remain separate checks.

Verification outputs and targets/commands/timestamps are in `evidence/implementation-checks.json` and `evidence/implementation-packages.json`. Final worktree inventory is in `evidence/implementation-repo-state.json`. These contain engineering metadata and synthetic outputs only. Telemetry guidance affected metric/log/trace/event field mapping for `deployment.environment.name`; no live signal was changed.

Rollback: reverse only the selected local guidance/tooling/packaging diffs, restore matching bootstrap projections and reviewed hashes together, and preserve all pre-existing ZenMoney work. Do not use a blanket reset of a mixed worktree.

Relevant ongoing references: bootstrap `docs/skill-lifecycle.md`, architecture `docs/curated-migration-proposal.md`, each repository's `docs/skill-evaluation.md`, and bootstrap `agents/manifests/skill-snapshots.json`.
