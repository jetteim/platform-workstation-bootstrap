---
name: writing-diataxis-documentation
description: Guide the user through a dialogue-first Diátaxis workflow so each document serves a clear reader need as a tutorial, how-to guide, reference, or explanation. Use whenever creating, rewriting, restructuring, or reviewing technical or product documentation, including vague requests such as “write a doc on that thing,” README files, getting-started material, runbooks, troubleshooting guides, API/CLI reference, architecture and concept docs, ADRs, and documentation sites. Elicit missing audience, outcome, scope, evidence, and section-level input without asking for facts that can be discovered safely. Use alongside file-format or publishing skills; this agent-agnostic skill governs the authoring dialogue, documentation intent, information architecture, and prose rather than rendering or platform mechanics.
---

# Write Diátaxis Documentation

Shape documentation around what a reader needs at a particular moment. Keep factual verification, repository conventions, accessibility, and the user's requested format as independent requirements.

## Stay agent-agnostic

Express the workflow in terms of conversation, evidence, files, and outcomes rather than a particular agent, model, vendor, tool name, or interaction API. Use the host runtime's ordinary capabilities to inspect sources, ask one question, wait for the answer, edit the artifact, and verify it.

Use a native structured question interface when one is available and appropriate; otherwise ask the same question in plain text. If the runtime cannot inspect a needed source, ask the user to provide it or preserve a labeled placeholder. Do not silently weaken the evidence requirement because a tool is unavailable.

Treat adapter-specific metadata outside `SKILL.md` as optional integration. The authoring workflow and all references must remain portable.

## Start with an authoring dialogue

Treat an underspecified documentation prompt as the start of a collaborative authoring session. Inspect the available conversation, repository, product, and existing docs first. Then ask for only the consequential information that remains missing.

<DIALOGUE-GATE>
For a new document or material rewrite, do not write the polished draft until you have explored context, asked clarifying questions one at a time, recommended a content approach, presented the proposed outline in manageable sections, and received user approval. A short document can have a short design, but it still needs an explicit outline approval.

Treat a bounded copy edit, typo fix, format conversion, or explicitly approved existing outline as already designed. Do not restart the dialogue unless the requested change exposes a consequential ambiguity.
</DIALOGUE-GATE>

Move through these checkpoints:

1. **Brief** — establish the topic, intended reader, reader competence, situation, desired outcome, destination, and constraints.
2. **Mode** — propose the most likely Diátaxis mode and explain it in ordinary language. Ask for confirmation only when another plausible mode would materially change the document.
3. **Contract** — agree on scope, starting state, ending state, authoritative evidence, version assumptions, safety needs, and explicit exclusions.
4. **Approaches** — offer two or three plausible content designs with trade-offs, lead with a recommendation, and let the user choose. Skip artificial alternatives only when a mandated template or already-approved structure leaves no meaningful choice.
5. **Outline** — present sections appropriate to the selected approach and mode. Walk through every section, marking what is known, safely inferred, discoverable, or still needs user input. Ask for approval after each substantial outline section.
6. **Draft** — draft only after the outline is approved. Work section by section for complex or sensitive documents; draft as a whole for short, well-specified documents. Keep unresolved items visible rather than inventing them.
7. **Review** — verify facts and examples, self-review the reader journey, present the completed artifact, and ask the user to review it before treating the document as accepted.

Ask exactly one clarifying or approval question per message. Prefer a small set of concrete choices when useful, with the recommended choice first and its trade-off explained. Use an open question when the user's own words matter more than predefined options. Do not demand Diátaxis terminology from the user.

Do not ask for information already available in the task context or authoritative local sources. Do not invent domain facts, organizational policy, commands, outcomes, quotations, user opinions, or risk decisions. When the user asks for speed, delegates judgment, or cannot provide an answer, proceed with clearly labeled assumptions or placeholders and state their impact.

For the exact conversational states, section prompts, and stop conditions, read [dialogue-workflow.md](references/dialogue-workflow.md).

## Follow the workflow

1. Inspect the product and its existing documentation before drafting. Identify the audience, their assumed competence, their situation, and the outcome they need through evidence and dialogue.
2. Maintain a private authoring contract: `reader`, `need`, `mode`, `scope`, `entry state`, `exit state`, `evidence`, `confirmed decisions`, `assumptions`, and `open questions`. Do not add this contract to the published page unless it helps readers or maintainers.
3. Classify the primary need with the compass:
   - Does the reader need to act or to know?
   - Are they acquiring skill or applying existing skill?
4. Select one primary mode:

   | Reader need | Acquiring skill | Applying skill |
   | --- | --- | --- |
   | Act | Tutorial | How-to guide |
   | Know | Explanation | Reference |

5. Read [authoring-contracts.md](references/authoring-contracts.md) for the selected mode. Apply its contract and QA checklist.
6. Compare meaningful content approaches, recommend one, and let the user choose.
7. Build a mode-appropriate outline, present it progressively, and obtain user approval before drafting. Resolve each section through available evidence, safe inference, or focused user input.
8. Keep the page focused. Move substantial material that serves another need into a separately titled section or page, and link to it at the point of need.
9. Verify the result against current source material and runnable examples where applicable. Then review flow from the reader's perspective, return to dialogue for unresolved gaps, and request user review of the completed document.

If the request is to audit, migrate, or reorganize an existing documentation set, also read [auditing-and-structure.md](references/auditing-and-structure.md).

## Apply the compass at passage level

Classify by the reader's need, not by the current filename, heading, or layout. A document can be a landing page that routes to several modes. A code example can illustrate reference, teach within a tutorial, or solve a task in a how-to guide.

When intent is unclear, infer it from the requested outcome and nearby repository conventions. Ask the user only when different plausible intents would materially change the deliverable.

Recognize common defaults without treating them as laws:

- Quickstarts and first-use walkthroughs are usually tutorials.
- Runbooks, recipes, migration procedures, and troubleshooting flows are usually how-to guides.
- API, CLI, configuration, schema, and compatibility pages are usually reference.
- Concept, rationale, architecture, trade-off, and background pages are usually explanation.
- READMEs and documentation home pages often orient readers and route them to purpose-built pages.
- ADRs usually combine an explanation of the decision with a concise factual record; keep the decision, status, and consequences easy to consult.

## Prevent mode contamination

Do not combine modes merely for completeness. Preserve the reader's momentum:

- Keep extended theory and alternatives out of task steps; link to explanation.
- Keep exhaustive option lists out of tutorials and how-to guides; link to reference.
- Keep procedural journeys out of reference; use only short illustrative examples.
- Keep factual catalogs and step-by-step instructions from taking over explanation.

Use small local transitions when a split would be disproportionate, but keep the primary mode unmistakable.

## Preserve existing constraints

Treat Diátaxis as an authoring lens, not a mandatory folder tree. Do not create four empty top-level sections or perform a wholesale rewrite unless the task calls for it. Improve existing documentation in coherent, reviewable increments.

Follow local style guides, templates, terminology, versioning, localization, and build conventions. If they conflict with Diátaxis, preserve explicit project requirements and use the framework where compatible.

Use companion skills when relevant:

- Use document, PDF, spreadsheet, slide, or publishing skills for their native formats.
- Use domain skills to establish technical facts.
- Use this skill to decide which reader need the documentation serves and how the material should flow.

## Verify quality

Check functional quality first:

- Confirm commands, interfaces, defaults, constraints, outputs, links, and examples against authoritative sources.
- Cover the stated scope without claiming broader completeness.
- Use consistent terminology and structure.
- Make prerequisites, safety warnings, version assumptions, and limitations explicit where relevant.
- Record unverified claims as caveats instead of presenting them as facts.

Then check experiential quality:

- Confirm the page answers one recognizable reader need.
- Remove interruptions that belong to another mode.
- Order information around the reader's actions or questions.
- Anticipate likely confusion, branches, and failure signs without overwhelming the primary path.
- Make adjacent needs discoverable through purposeful links.

Diátaxis supports fit and flow; it does not by itself guarantee accuracy, completeness, accessibility, visual quality, or usability. Verify those separately.

## Credit the framework

This skill operationalizes the Diátaxis framework by Daniele Procida. Its guidance is adapted from [diataxis.fr](https://diataxis.fr/) and the [Diátaxis source repository](https://github.com/evildmp/diataxis-documentation-framework), licensed under CC BY-SA 4.0. See [sources.md](references/sources.md) for the pages used.
