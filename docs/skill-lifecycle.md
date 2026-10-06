# Skill ownership and sunset candidates

Reviewed 6 October 2026 against the official curated catalog at `openai/skills@49f948faa9258a0c61caceaf225e179651397431` (39 entries). Installed plugins are a separate catalog. Similarity marks a candidate for coverage review; it does not authorize deletion or archive a repository.

| Scope | Lifecycle | Decision and replacement limits |
| --- | --- | --- |
| Architecture planning/story/task tracking | S1 partial sunset candidate | Retain value streams, capability shaping, C4 and local traceability. Delegate Notion tasks to curated `notion-spec-to-implementation` only when the user chose Notion and authorized remote artifacts. `define-goal` supplies goal-tool framing, not the full architecture pipeline. Pilot one bounded initiative, compare outcome/architecture/acceptance/traceability coverage and tool requirements, then choose migration separately. |
| Ordinary new CLI creation | S2 overlapping maintenance retired locally | Use reviewed curated `cli-creator` for new composable CLIs. Retain `engineering-agent-ready-clis` for explicit audit/retrofit, adversarial input/output paths and CLI/MCP schema parity. Both forbid secret flags. No readiness audit is implied by ordinary creation. |
| PDF/Jupyter offline snapshots | S3 redundant custom-maintenance candidate | Retain pinned offline packaging, scripts, assets and licenses. Entry points matched the reviewed curated catalog. Adopt reviewed upstream updates rather than maintain an independent workflow fork; removal needs proof the target runtime reliably supplies equivalent packages offline. |
| OpenAI Docs and other system skills | S3 provider ownership | Provider-managed installed `.system` stays provider-owned. Bootstrap snapshots are offline fallbacks/provenance, not independently active plugin replacements. Do not rewrite caches or infer activation from cache presence. |
| GitHub local fallbacks | S3 conditional candidate | Retain intentional app/gh/thread/scope refinements until provider coverage demonstrates parity. Compare authorization, batching, mixed-worktree safety and Action-log access before replacing. |
| Brain, Diátaxis, ZenMoney, Google helpers, observability/pipelines/reliability | Keep | No equivalent curated domain workflow found. Generic analytics, Sentry, Notion or Figma skills do not establish replacement coverage. |

S1 migration acceptance: the pilot preserves customer outcome, ownership, chosen hierarchy, unique C4 decisions, testable acceptance and evidence links without mandatory remote work. Keep local packages available for rollback. Do not archive the architecture repo based solely on overlapping task tracking.

S3 cleanup acceptance: document runtime/provider ownership, supported offline fallback, preserved assets/licenses and intentional differences; compare activation and behavior on the relevant scenarios before removing a maintained fallback. No live installations, plugin-cache changes, fork refresh, remote archive or publication were performed.

`agents/manifests/skill-snapshots.json` records complete reviewed package digests, source revision/digest when a local source exists, and projection targets. `scripts/check-skill-drift.py` rejects unreviewed canonical/source/projection drift and requires an explanation for a recorded source refinement. Missing sibling checkouts are reported for portable bootstrap verification; use `--require-sources` in this workspace. Updating a digest is a review decision, not an automatic refresh. Compare source changes against refinements before adoption.

Codex's six Google helpers receive their shared Slides references during projection without installing a duplicate core Google Drive entrypoint. Disposable-home verification checks these installed resource links. Google dependencies are connected app actions, so no fictional MCP server is declared; ZenMoney uses its configured `zenmoney-receipts` MCP identity.
