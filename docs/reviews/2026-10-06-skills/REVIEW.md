# Skill repository review — 6 October 2026

Implementation update: the user selected all actions. See [IMPLEMENTATION.md](IMPLEMENTATION.md) for the completed changes, bootstrap follow-through and verification limits. The audit below records the pre-implementation baseline; its original review changed only the report/evidence, with repositories unchanged at that time.

## Findings at a glance

The skills are structurally valid and contain useful domain constraints. The main gaps are conflicting routing, obsolete telemetry examples, unnecessary fixed workflows, lengthy discovery descriptions, and limited behavioral validation. Existing financial confirmation, recovery, evidence-locality, and tenant boundaries should be preserved.

| Repository | Skill files | Assessment | Sunset status | Suggested actions |
| --- | ---: | --- | --- | --- |
| `architectural-execution-skills` | 7 | Clear artifact contracts and selective routing; arbitrary count gates and repeated companion-workflow guidance need simplification. | **Sunset candidate, partial scope:** planning/story/traceability overlaps with `notion-spec-to-implementation`; outcome framing overlaps with `define-goal`. Retain C4 and value-stream/capability expertise unless replacement coverage is demonstrated. | A5, A7, A8, A9; S1 |
| `observability-engineering` | 1 | Strong intent/provider boundary. Source routing conflicts with the improved bootstrap copy; some examples use a deprecated attribute. | **Keep.** Curated `sentry` reads issues/events; it does not replace neutral instrumentation, alert, dashboard, or IaC design. | A1, A2, A5, A6, A9 |
| `observability-pipeline-skills` | 1 | Strong lineage, delivery, redaction, failure-path and provider-gap contracts. Some attributes and the SLO handoff are outdated. | **Keep.** No similar source-to-sink pipeline-authoring skill found in the current curated catalog. | A1, A2, A5, A6 |
| `reliability-engineering` | 1 | Useful reliability/observability split and deterministic generator preference. Entry point carries too much conditional detail. | **Keep.** No curated replacement for SLI/SLO selection, error-budget policy, postmortems, or resilience planning found. | A5, A6, A9 |
| `zenmoney-receipts` | 3 | Strong preview/apply/recovery and financial evidence boundaries. Two entry points repeat lengthy storage rules; dependencies are implicit. | **Keep.** No ZenMoney-specific replacement found. Generic analytics skills do not supply the financial transaction workflow. | A5, A6, A8, A9 |
| `platform-workstation-bootstrap` | 80 | 40 distinct skill names, each represented twice. Canonical/projection pairs agree. It also contains locally refined external fallbacks and provider system snapshots. | **Sunset candidate, selected skill maintenance only:** CLI creation and several existing curated copies overlap. The bootstrap itself remains needed. | A1–A12 as applicable; S2, S3 |

There are 93 physical `SKILL.md` files across these six Git checkouts and 40 distinct skill names. Bootstrap duplicates are intentional projections, not evidence that 80 skills are active. Other Git projects in this folder had no `SKILL.md` and were excluded. Private model repositories are dependencies, not standalone skill packages.

## Current best-practice baseline

OpenAI's September guidance favors concise discovery descriptions, task-specific instructions, progressive disclosure, preserved user intent, and fewer rigid rules that create unnecessary work. These are design criteria, not a mandatory file length or universal rewrite requirement. [Rethinking skills and prompts](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra).

Skill workflows should expose relevant supporting resources, have clear inputs and outcomes, and declare required MCP dependencies where the packaging/runtime supports them. UI metadata is optional; its absence does not invalidate a skill. [Build skills](https://developers.openai.com/plugins/build/skills).

Evaluation should use actual captured agent runs and assess activation, observable results, and efficiency. Checking saved example outputs remains useful fixture validation but cannot establish current agent behavior. [Testing skills with evals](https://developers.openai.com/blog/eval-skills).

The curated comparison uses the official `openai/skills/skills/.curated` catalog, fetched during this audit and pinned to `49f948faa9258a0c61caceaf225e179651397431` (commit dated 24 June 2026): **39 skills**. All 39 entry points were fetched; all descriptions were compared, and relevant workflows were inspected. Newer official guidance and locally reviewed improvements can supersede an older curated snapshot. [Pinned curated catalog](https://github.com/openai/skills/tree/49f948faa9258a0c61caceaf225e179651397431/skills/.curated).

Installed curated plugins are a separate catalog. They were not treated as entries in `openai/skills/.curated`, and their cache presence was not treated as activation.

## Selectable changes

Priority P1 means a concrete correctness, scope, or unnecessary-work problem; P2 means maintainability or discovery improvement. These were the proposed actions at audit time; current status is recorded in [IMPLEMENTATION.md](IMPLEMENTATION.md).

| ID | Priority | Suggested change | Repositories affected |
| --- | --- | --- | --- |
| **A1** | P1 | Make reliability own SLI/SLO choice and objectives; observability owns bindings and backend artifacts; pipelines own delivery/topology. Bring the source skill into agreement with the bootstrap's corrected routing. | Observability, pipelines, bootstrap |
| **A2** | P1 | Modernize OpenTelemetry examples to `deployment.environment.name`, with explicit compatibility notes for older instrumentation/backend mappings. Record conventions version/stability when generating artifacts. | Observability, pipelines, bootstrap |
| **A3** | P1 | Replace mandatory three-write Slides loops with outcome-based verification; fix the thumbnail-success/actual-image-inspection ambiguity. | Bootstrap Google Drive helpers/fallbacks |
| **A4** | P1 | Respect the requested presentation product: “edit this PPTX” must not automatically mean upload/import to Google Slides. | Bootstrap presentation import skill |
| **A5** | P1 | Separate static fixture validation from behavioral skill evaluation; add representative activation/nonactivation and failure scenarios with fresh captured outputs. | Four dedicated skill repos, ZenMoney, bootstrap wiring |
| **A6** | P2 | Move mode-specific detail into references; make private model/generator resolution configurable and preserve stand-alone fallbacks. | Observability, pipelines, reliability, ZenMoney; bootstrap copies |
| **A7** | P2 | Convert architecture count limits into configurable heuristics and remove routine reapproval/companion-workflow ceremony. | Architecture, bootstrap |
| **A8** | P2 | Shorten long descriptions while preserving discriminating triggers and boundaries. | Architecture, ZenMoney, bootstrap helpers |
| **A9** | P2 | Declare required tool dependencies where supported; add focused capability checks and useful missing-tool behavior. Optional UI metadata for authored skills lacking it. | ZenMoney, bootstrap Google helpers; architecture, observability and reliability UI |
| **A10** | P2 | Reconcile Brain model/tokenizer/config examples and qualify benchmark claims; preserve the existing measured smoke path and deterministic safety checks. | Bootstrap Brain snapshot |
| **A11** | P2 | Add a review gate for drift between source repos and reviewed bootstrap snapshots, distinguishing intentional refinements from accidental divergence. | Bootstrap |
| **A12** | P2 | Remove unnecessary second approvals in locally maintained GitHub CI/comment fallbacks when the user already authorized the fixes; handle batch limits without expanding scope. | Bootstrap GitHub/Drive fallbacks |

### A1 — Resolve ownership and source drift

Evidence: the source `observability-engineering/skill/observability-engineering/SKILL.md` description and “When To Use” list still include defining SLOs/SLIs. Its bootstrap copy already says to use reliability for choosing SLIs, objectives and error budgets. The source/bootstrap entrypoint diff is limited to these routing refinements. The pipeline skill's self-observability section also asks observability to turn signals into SLOs, while the reliability skill says it owns SLI/SLO choice.

Implement: adopt the corrected routing in the source, clarify the pipeline's reliability/observability handoff, and adjust README/validator expectations that currently enforce the old wording. Retain intentional bootstrap refinements. Verification: structural validation, existing fixture checks, and routing cases for “choose an SLO,” “bind an existing SLO,” and “design collector buffering.”

### A2 — Update deprecated telemetry examples

Evidence: `deployment.environment` appears in the observability provider adapter reference and Elastic example queries, and in pipeline contracts, examples and saved scenarios. OpenTelemetry marks it deprecated and replaces it with stable `deployment.environment.name`. [Deployment attribute registry](https://opentelemetry.io/docs/specs/semconv/registry/attributes/deployment/).

Implement: use the current name in new neutral contracts and examples; document legacy input/mapping behavior instead of assuming existing live data changes with a documentation edit. Mark organization-specific attributes such as `service.owner` as extensions. Select version/stability against the target instrumentation rather than blindly upgrading an existing emitter. [Version selection](https://opentelemetry.io/docs/specs/semconv/configuration/version-selection/).

Verification: check consistent contract/fixture names and generated queries; run existing validators. Provider-backed query/plan checks remain separate when the necessary environment is available. This action changes skill guidance/examples, not live telemetry.

### A3 — Make Slides edits stop when verified

Evidence: `google-slides-visual-iteration/SKILL.md` mandates at least three full edit loops per slide; `google-drive/references/slides/visual-change-loop.md` expressly requires three write-and-verify loops even when earlier passes are acceptable. General Slides and import/migration instructions also inherit the rule. The visual skill is approximately 25.5 KB. Its YAML default prompt describes a different pass count from the body.

Implement: preserve live IDs, fresh geometry, concurrency controls, thumbnail inspection and scope coverage; require another write only for a remaining verified defect. Use fresh review without writing when the result is already correct. Move detailed chart/card/layout recipes into conditional references. Resolve metadata consistently.

Also distinguish “thumbnail tool returned successfully” from “the agent inspected rendered pixels.” When an image pointer/URL is not actually inspectable, retrieve it through an available supported path or report the verification limit; do not assert visual completion from metadata.

Verification: cases for a one-pass correction, an already-correct slide, a persistent overlap, an inaccessible image artifact, and a repeated layout defect. Check content preservation and absence of needless additional mutations.

### A4 — Preserve presentation destination and source format

Evidence: `google-slides-import-presentation/SKILL.md` says to import first whenever the user says “edit this PPTX.” That broadens a local file edit into creation of a cloud artifact.

Implement: trigger import for an explicit Google Slides/conversion request or an already-established Google Slides workflow. Preserve a requested local PPTX edit; use a suitable available file workflow or explain the missing capability. Keep import verification and fidelity caveats for actual imports.

Verification: a local PPTX edit does not call import; an explicit “convert to Google Slides” request does; a previous destination decision is preserved.

### A5 — Evaluate behavior rather than only saved fixtures

Evidence: the four dedicated repos' `run-exercise.sh` scripts compare committed `.actual.yaml` files against `.expected.yaml`; they never invoke an agent. Their validators additionally enforce literal phrases. ZenMoney's `evaluate-receipts.mjs` compares prefilled `candidate` and `expected` objects from one corpus; it does not extract a fresh receipt interpretation. This does not diminish its separate application tests.

Implement: label existing checks as fixtures/contracts; introduce an opt-in behavioral evaluator that records prompt, skill revision, model/runtime, tool trace, artifact output and result. Cover direct/indirect triggers, neighboring tasks that should not activate, missing dependencies, conflicting user instructions, ambiguity, and unsupported operations. Score observable invariants instead of matching headings. Use synthetic receipts and fake transports for financial writes; never exercise live financial mutation as a skill test.

Verification: prove the evaluator consumes newly generated output, detects a deliberate failed invariant, and leaves fixture files untouched. Keep model execution separate from ordinary offline checks so routine verification remains predictable. Implementation can provide the runner and scenario suite first; a model-backed run must be reported separately from static validation.

### A6 — Reduce loaded context without losing constraints

Evidence: reliability's entry point is approximately 13 KB/287 lines; observability's is approximately 12 KB/204 lines. Both inline private checkout paths, mode inventories and substantial provider/workflow detail. The receipt and category skills duplicate long storage/preference/comment policies. Pipeline guidance routes SLO work ambiguously.

Implement: retain purpose, routing, essential invariants and explicit reference-loading triggers in each entry point; move incident, SLO, resilience, provider and storage details into packaged references. Use a caller-supplied model/generator location first, then supported defaults and bundled fallback. Keep legacy workstation paths as compatibility information. A missing companion skill should produce an equivalent bounded workflow or a precise missing capability, not silent omission.

For ZenMoney, keep exact financial confirmation, uncertain-write recovery, personal-evidence locality and verified-success rules readily visible. Package shared references inside each installed skill or another explicitly guaranteed bundle path; do not introduce broken sibling dependencies.

Verification: representative modes load the relevant reference, fallback works without private repos, and existing safety invariants remain observable.

### A7 — Make architecture guidance proportional to the task

Evidence: discovery mandates 5–9 activities and 3–7 capabilities; capability shaping caps active choices at 3–7; story/traceability skills block on more than 10 active stories. Several skills repeatedly prescribe Superpowers handoffs and approval gates. The orchestrator already correctly says not to generate all artifacts by default.

Implement: preserve the user's existing artifact structure and selected abstraction level. Treat counts as optional working-size heuristics or local policy when explicitly required; permit a smaller complete packet. Preserve testable acceptance criteria, material decision ownership and upward/downward traceability. Use available companion workflows only when they improve the current task. Existing implementation authorization should not require another ritual approval.

Verification: one-story work, a supplied eleven-item backlog with a bounded active slice, an implementation-ready feature, and an unclear initiative. Each should get the smallest useful artifact set.

### A8 — Improve discovery precision

Evidence: bootstrap's Google Slides description is 621 characters, receipt categorization 557, visual iteration 409, and PR-comment handling 387. These are valid but spend discovery budget on examples/procedure. Architecture descriptions also enumerate many artifact levels. Provider-managed descriptions are observed but excluded from proposed local editing.

Implement: name the outcome and the distinguishing trigger; keep exclusions that prevent likely misrouting. Move synonym lists, methods and examples into the body. Preserve the explicitly desired minimal-prompt receipt trigger and distinguish Slides import, template migration, structural cleanup and visual polish.

Verification: selection cases across adjacent skills and retained explicit `$skill-name` invocation. No arbitrary character count becomes a correctness gate.

### A9 — Make packaging dependencies explicit

Evidence: all three ZenMoney YAML files contain UI metadata only; Google helper YAML similarly omits tool dependencies despite requiring connected tools. Architecture's seven source skills, observability and reliability have no UI file. That absence is optional metadata, not a structural defect.

Implement: declare the actual supported MCP dependency in the intended plugin/package where supported, using the existing configured server identity and transport. Do not invent an endpoint or reconnect accounts automatically. Include operation-specific capability checks. Keep implicit invocation defaults unchanged. Optionally add concise display names/default prompts to the authored skills missing them.

Verification: parse metadata, resolve supported dependency identifiers, and exercise missing-tool cases. No connection change, authentication flow or provider cache rewrite is part of this action.

### A10 — Refresh Brain's examples and evidence labels

Evidence: the entry point's comparison table names Qwen3.5 variants while quick-start/reference configs and measured bootstrap smoke documentation use other Qwen3 models. It presents fixed tokenizer IDs, sample accuracy and latency numbers without inline provenance. The bootstrap's existing assessment already correctly treats external benchmarks as examples and preserves deterministic checks as the primary safety boundary.

Implement: separate the tested bootstrap recipe from illustrative model families; resolve chat templates/token IDs from the selected tokenizer rather than applying one model's constants universally. Label model/hardware/sample-dependent timings and targets. Move detailed deployment/hook examples out of the main entry point. Preserve training as opt-in.

Verification: package/reference consistency and lightweight config/tokenizer checks against the selected recipe. Full retraining/model downloads are not necessary for this documentation action and must not be claimed to have run.

### A11 — Maintain source/snapshot drift deliberately

Evidence: every same-name pair inside the bootstrap has identical entrypoint hashes. Cross-repository comparison found one divergence: observability's improved routing in the bootstrap. Bootstrap documentation already records observed revisions and explains reviewed snapshots; this is not a missing-provenance finding. Source refresh is separately opt-in and can replace local refinements.

Implement: extend the existing provenance/check path to record which source differences are intentional and fail or flag unexpected drift. Add a curated-overlap/lifecycle inventory, with approved local refinements and provider-managed ownership noted. Compare before adopting updates; do not blindly reset a reviewed skill to upstream.

Verification: identical projections pass; an unrecorded divergent fixture is reported; an intentional recorded refinement is retained. Existing provider-owned system bundles and active plugin caches stay provider-managed.

### A12 — Preserve delegated authorization in fallbacks

Evidence: the maintained GitHub CI fallback requires explicit approval again at planning step 6 even when the user asked to fix the CI. Drive comments asks before splitting a requested batch solely because of a tool action limit.

Implement: continue already-authorized local fixes and divide an explicitly requested comment set into bounded batches within the same scope. Ask only about unresolved material choices or newly expanded/external actions. Preserve financial exact-preview gates, comment/publication authorization, scope checks in mixed worktrees and draft-PR behavior. Apply only to maintained local fallback sources; active provider plugin changes need their own ownership path.

Verification: authorized CI fixes proceed through local verification; read-only reviews stay read-only; larger authorized comment sets stay within the requested targets and content.

## Sunset candidates and selectable sunset work

These flags are recorded in this report, not as repository deletions or archival operations. Similarity is a reason to evaluate retirement, not proof that a replacement preserves the full workflow.

| ID | Flagged repository/scope | Current curated overlap | Replacement gap and suggested disposition |
| --- | --- | --- | --- |
| **S1** | `architectural-execution-skills`: implementation planning, story/task tracking, some traceability and outcome framing | [Notion spec to implementation](https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.curated/notion-spec-to-implementation/SKILL.md); [Define goal](https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.curated/define-goal/SKILL.md) | **Partial, conditional candidate.** Notion workflow requires Notion and creates remote pages/tasks; goal definition has a narrower goal-tool scope. Neither covers C4, value streams or capability shaping. Prefer retaining the unique core and delegating overlapping work only when the user chose the matching system. Select S1 to prepare a coverage/migration proposal; no basis yet to archive the whole repo. |
| **S2** | `platform-workstation-bootstrap`: ordinary new-CLI creation inside `engineering-agent-ready-clis` | [CLI creator](https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.curated/cli-creator/SKILL.md) | **Material partial candidate.** Curated skill covers composable CLI creation, discovery, JSON, auth, bounded lists and preview writes. Local skill adds retrofit/audit, adversarial input and path checks, schema/MCP parity, and evidence-gated readiness. Curated guidance also allows token flags, unlike workstation secret rules. Prefer curated creation plus a narrowed local audit/retrofit skill; preserve stricter local constraints. Select S2 to implement this split after coverage checks. |
| **S3** | `platform-workstation-bootstrap`: maintaining `pdf`, `jupyter-notebook`, GitHub fallbacks and OpenAI Docs as independent forks | [PDF](https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.curated/pdf/SKILL.md), [Jupyter](https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.curated/jupyter-notebook/SKILL.md), and same-name curated GitHub/OpenAI Docs skills | **Exact/modified overlap.** PDF and Jupyter entrypoints already match current curated bytes; pinned offline copies may remain useful. GitHub fallbacks contain deliberate connector/thread refinements; system OpenAI Docs belongs to the provider. Retire redundant custom maintenance where appropriate, preserve provenance and necessary fallback packaging. Select S3 for a provider/source ownership cleanup plan, not wholesale deletion. |

No curated match was found for Brain's local MLX training, Diátaxis documentation shaping, ZenMoney operations, or the Google Slides/Sheets-specific helpers. Generic Notion documentation, Figma design and security-review skills serve different workflows. Generic Sentry error inspection does not justify sunsetting observability engineering or reliability engineering.

## Verification and practical limits

| Check | Result | What it establishes |
| --- | --- | --- |
| Skill Creator `quick_validate.py` over all 93 skill directories | 93 passed | Frontmatter, naming/description limits and unfinished scaffold checks; not behavior |
| Dedicated architecture validator | Passed | File/YAML/phrase checks and one saved scenario contract |
| Dedicated observability validator | Passed | Static checks and two saved scenario contracts; live provider plans not enabled |
| Dedicated pipeline validator | Passed | Static checks and three saved scenario contracts |
| Dedicated reliability validator | Passed | Static checks and one saved scenario contract; external generator validation not enabled |
| Bootstrap `./scripts/verify.sh` | Passed, 8 tests | Shell/Python checks and offline fixture behavior, including skill projections |
| Local resource/UI scan | No actionable missing entrypoint references/icons found | Skill Creator's fenced example paths produced expected scan false positives |
| Repository state before/after | Unchanged in all six repos | No review edits were introduced into those worktrees |

ZenMoney already contained unrelated user changes before the audit; they were preserved. Its full application test suite was not run for this read-only skill review. No fresh model behavioral eval, private-model compatibility certification, live service access, financial data query, provider apply or deployment was performed. Script/reference review was targeted, not an exhaustive code security audit.

Evidence is in `evidence/local-inventory.json`, `evidence/curated-catalog.json`, `evidence/skill-validation.json`, `evidence/*-checks.json`, and `evidence/final-repo-state.json`. The pinned public curated entrypoints were inspected during the audit; their transient raw cache remains in the local workspace review directory and is not part of this saved report. `INVENTORY.md` lists every distinct bootstrap skill and its action mapping. Check outputs distinguish static scenario validation from actual runtime evidence.

## Bootstrap follow-through after selected implementation

For every selected action, update the relevant source repository when it exists here, then its reviewed canonical bootstrap source under `agents/skills/platform`, `agents/skills/codex-curated`, or `agents/skills/plugins`. Keep matching `skills/codex` or `skills/plugins` projections consistent. Update projection manifests, source provenance and installation wiring only when the selected change requires it. Test installer changes with disposable homes and `SKIP_GITHUB_REFRESH=1 SKIP_SOURCE_REFRESH=1`; finish with `./scripts/verify.sh` and relevant skill checks.

Rollback is a targeted reversal of the selected local diff, preserving unrelated work. Installing into live agent homes, updating active third-party plugins, pushing changes and archiving remote repos are separate actions; none is implied by selecting a guidance edit.

Suggested first batch: **A1, A2, A3, A4**. Add **A5** for stronger future behavioral evidence. Select any other IDs individually; S1 and S3 produce migration/ownership proposals, while S2 proposes a concrete skill split with coverage checks. No whole-repository archival is currently recommended.
