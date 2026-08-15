# Dialogue workflow

Use this state model to guide a documentation task from a vague request to a verified draft. Move forward as soon as a state has enough information; do not turn the workflow into a questionnaire.

## Contents

- [State 0: Inspect](#state-0-inspect)
- [State 1: Establish the brief](#state-1-establish-the-brief)
- [State 2: Propose the mode](#state-2-propose-the-mode)
- [State 3: Establish the contract](#state-3-establish-the-contract)
- [State 4: Compare approaches](#state-4-compare-approaches)
- [State 5: Walk and approve the outline](#state-5-walk-and-approve-the-outline)
- [State 6: Draft](#state-6-draft)
- [State 7: Review and close](#state-7-review-and-close)
- [Question discipline](#question-discipline)

## State 0: Inspect

Before asking questions, inspect the conversation and available sources for:

- what “that thing” refers to
- existing docs, style guides, templates, and neighboring pages
- intended delivery format and repository location
- current product behavior, interfaces, terminology, and version
- earlier decisions about audience, scope, and tone

Record each needed input as one of:

- **confirmed** — stated by the user or authoritative source
- **discoverable** — obtainable safely from in-scope sources
- **inferable** — a low-risk assumption that can be stated and corrected
- **blocked** — requires user or stakeholder judgment

Research discoverable inputs before questioning the user. Ask about blocked inputs. State inferable inputs before relying on them when they could alter structure or meaning.

## State 1: Establish the brief

Obtain enough information to answer:

1. Who will read this, and what can they already do or understand?
2. What should they be able to do or understand after reading?
3. What subject, product, version, or decision is in scope?
4. Where will the document live, and what local conventions apply?

For a vague prompt, a strong first question is:

> I can guide this from outline to final draft. Who is the reader, and what should they be able to do or understand when they finish?

Ask about destination or format in a later message only when it affects the result. Do not ask the user to classify the document as tutorial, how-to, reference, or explanation.

Exit this state when the reader and desired outcome are clear enough to distinguish action from knowledge and learning from work.

## State 2: Propose the mode

State the mode as a reader-centered recommendation:

- **Tutorial:** “This sounds like a guided first learning experience.”
- **How-to guide:** “This sounds like a task guide for someone who already knows the basics.”
- **Reference:** “This sounds like a factual page people will consult while working.”
- **Explanation:** “This sounds like a conceptual page that explains why and how the pieces fit.”

Continue without a confirmation question when the evidence is strong. Ask the user to choose only when competing needs imply materially different documents. If both needs matter, recommend separate linked pages and ask which to produce first.

Exit this state with one primary mode for the current page.

## State 3: Establish the contract

Resolve the fields that affect correctness:

- scope and exclusions
- entry state and prerequisites
- promised exit state
- source of truth and evidence availability
- product or policy version
- safety, permissions, rollback, or compliance requirements
- terminology, tone, length, and publishing constraints

Ask only about fields that matter to this document. For example, rollback is important for a production runbook but usually irrelevant to a conceptual overview.

When evidence is unavailable, offer an explicit choice: provide the source, accept labeled placeholders, or narrow the claim.

Exit this state when the document can make a bounded promise without fabricating facts.

## State 4: Compare approaches

For a new document or material rewrite, propose two or three genuinely different content designs. Vary scope, page boundaries, reader journey, or depth—not cosmetic headings.

Lead with the recommended approach and explain why it best fits the reader need. For example:

1. **One focused page — recommended:** fastest path for one clear need; links out for adjacent needs.
2. **Landing page plus focused child pages:** better when several distinct audiences or modes must be served; costs more to create and maintain.
3. **Incremental revision of the existing page set:** smallest review surface; leaves some structural debt temporarily.

Ask one choice question and wait. Skip this state only when the user has already approved a structure or a mandatory template leaves no meaningful alternative; state that reason briefly.

Exit this state with an approved content approach.

## State 5: Walk and approve the outline

Propose a short outline, then walk through every part. Present it in sections scaled to complexity. After each substantial outline section, ask one approval question and wait. If the user rejects or revises it, update the outline and seek approval again before moving forward.

For each planned document section, say what is already known and ask for input only where the content is blocked. Do not draft polished prose while the outline is under review.

### Tutorial section prompts

- **Outcome:** What concrete result should the learner see?
- **Prerequisites:** Which exact environment and starting state can be made reliable?
- **Guided path:** What single known-good sequence should they follow?
- **Expected results:** What should appear after each meaningful step?
- **Observations:** What should the learner notice to form the intended mental connections?
- **Finish and recovery:** What counts as success, and how can they clean up or restart safely?

### How-to section prompts

- **Goal and applicability:** In what real situation should someone use this guide?
- **Prerequisites:** What competence, access, state, and inputs are assumed?
- **Primary path:** What is the safest useful sequence?
- **Branches:** Which real conditions change the path?
- **Risk handling:** What warnings, rollback, and failure signs matter?
- **Verification:** What evidence proves the user's goal was achieved?

### Reference section prompts

- **Surface and authority:** What interface, version, or schema is authoritative?
- **Item structure:** Which repeated fields make entries predictable?
- **Coverage:** What is included and explicitly excluded?
- **Semantics:** What types, defaults, constraints, states, errors, and side effects must be stated?
- **Examples:** Which minimal examples clarify use without becoming a procedure?
- **Lifecycle:** What is deprecated, experimental, versioned, or unsupported?

### Explanation section prompts

- **Central question:** What should become clearer, and why does it matter?
- **Context:** What larger system, history, or constraint frames the topic?
- **Connections:** Which concepts or mechanisms need to be joined into a mental model?
- **Rationale:** Which causes, decisions, and consequences must be explained?
- **Perspectives:** Which alternatives, trade-offs, counterexamples, or opinions matter?
- **Boundary:** Where should the discussion stop, and where should readers go next?

For landing pages and READMEs, walk through orientation, audience entry points, the smallest useful start, and links to each relevant reader need.

Exit this state only when every planned section is confirmed, supported by a discoverable source, safely inferable, explicitly deferred, or removed from scope, and the user has approved the complete outline.

## State 6: Draft

Choose the drafting cadence based on risk and complexity:

- Draft short, low-risk documents as a whole after the outline is settled.
- Draft long, policy-heavy, safety-sensitive, or stakeholder-dependent documents section by section.
- Pause after a section only when feedback can prevent substantial rework or resolve a blocked decision.

Keep a working ledger of confirmed facts, assumptions, placeholders, and citations. Do not expose the full ledger unless useful, but never hide unresolved uncertainty in polished prose.

When presenting a draft, distinguish content questions from copy-editing preferences. Ask the user first about gaps that change correctness, scope, or reader success.

## State 7: Review and close

Review in this order:

1. **Evidence:** Are facts, commands, outputs, examples, and links verified?
2. **Contract:** Does the draft keep its promise to the chosen reader?
3. **Mode:** Does another documentation mode interrupt the primary need?
4. **Flow:** Does each section prepare the reader for the next?
5. **Gaps:** Which unresolved items require a user decision or source?
6. **Handoffs:** Can readers find adjacent tutorial, task, reference, or conceptual needs?

Fix self-review findings before handoff. Present the completed artifact and ask the user to review it. Do not describe the document as accepted until the user approves it; if they request changes, revise, re-run the relevant checks, and ask for review again.

Ask a focused content question before handoff only when an unresolved item blocks a trustworthy result. Otherwise finish the draft and list material assumptions or deferred follow-ups briefly.

## Question discipline

- Use the host runtime's native question UI when helpful; otherwise use plain conversational text.
- Ask exactly one clarifying or approval question per message.
- Lead with the question that removes the most uncertainty.
- Prefer two or three concrete choices when they make the answer easier; lead with the recommended choice and explain the trade-off.
- Prefer questions with concrete impact over broad invitations such as “Anything else?”
- Use open questions when the user's own language, goals, or evidence matters more than a menu.
- Do not repeat a question the user already answered implicitly or explicitly.
- Do not stop merely because more detail would be nice; stop only when missing input would make the result misleading, unsafe, or structurally different.
- Let the user say “use your judgment.” Proceed with visible, reversible assumptions.
