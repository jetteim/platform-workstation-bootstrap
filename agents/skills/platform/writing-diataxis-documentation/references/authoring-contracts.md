# Authoring contracts

Use only the section for the selected primary mode, then apply the cross-mode checks at the end.

## Contents

- [Tutorial](#tutorial)
- [How-to guide](#how-to-guide)
- [Reference](#reference)
- [Explanation](#explanation)
- [Cross-mode checks](#cross-mode-checks)

## Tutorial

### Contract

Create a managed learning experience for a learner who lacks basic competence. Let the learner acquire familiarity and confidence through successful action. Take responsibility for the path, safety, and expected result.

### Shape

1. Name the concrete result the learner will create or experience.
2. State a small, controlled set of prerequisites and use one known-good environment.
3. Lead through a single end-to-end path in small steps.
4. Produce a visible, comprehensible result early and repeatedly.
5. Say what the learner should see, notice, or check after each meaningful action.
6. Finish with a recognizable accomplishment and, when relevant, a safe cleanup or restart path.
7. Link to separate how-to, reference, and explanation pages for follow-on needs.

### Write

- Use direct, unambiguous sequencing such as “First…”, “Now…”, and “Next…”.
- Use an inclusive tutor voice when it feels natural.
- Describe expected output and timing precisely enough to reassure the learner.
- Point out observations that close the loop between action and result.
- Explain only what is necessary to keep the learner moving; link to deeper context.
- Prefer concrete names, values, tools, and environments over generalized abstractions.

### Avoid

- Do not offer multiple paths, optional stacks, or a survey of alternatives on the primary journey.
- Do not assume troubleshooting expertise or leave important gaps for the learner to infer.
- Do not turn the lesson into a feature tour or theoretical lecture.
- Do not optimize for completing valuable production work; optimize for a safe learning encounter.

### Verify

- Run the tutorial from its declared starting state in the supported environment.
- Confirm every promised result and example output.
- Confirm a learner can recover or restart without harm.
- Observe a representative learner when feasible; author familiarity hides missing steps.
- Re-test the full journey after changes because local edits can break later steps.

## How-to guide

### Contract

Help an already-competent practitioner accomplish a specific real-world goal. Guide their work without teaching the domain from first principles.

### Shape

1. Title the page for the goal, usually “How to …”.
2. Define the situation, desired result, assumptions, and prerequisites.
3. Start at a meaningful point in the reader's work and end when the goal is achieved and verified.
4. Give an executable sequence in the order that best supports the reader's actions and thinking.
5. Include conditions, branches, warnings, rollback, and troubleshooting only where the real situation requires them.
6. Link to reference for exhaustive options and to explanation for reasons or trade-offs.

### Write

- Use imperative actions and conditional instructions.
- Organize around the user's goal, even when the path crosses several tools or subsystems.
- Assume domain competence while stating product-specific or risky prerequisites.
- Preserve flow: minimize context switching, delayed outcomes, and unresolved mental state.
- Prefer practical sufficiency over exhaustive coverage.
- Include verification that demonstrates the requested outcome, not merely that a command exited successfully.

### Avoid

- Do not document buttons or commands with no user purpose.
- Do not turn the guide into a beginner lesson.
- Do not embed a complete API, flag, or configuration catalog.
- Do not force every real-world case into one linear path; expose relevant branches.
- Do not claim universal applicability when environment-specific judgment is required.

### Verify

- Execute the primary path where safe and feasible.
- Test consequential branches, failure signs, rollback, and idempotency where relevant.
- Confirm the steps solve the stated user problem in the declared environment.
- Check that warnings appear before the action that creates risk.

## Reference

### Contract

Provide authoritative facts that a competent practitioner can consult while working. Optimize for accuracy, completeness within scope, consistency, and retrieval.

### Shape

1. Mirror the stable conceptual or product structure when it helps readers navigate both together.
2. Use a predictable schema for comparable items.
3. State signatures, types, fields, defaults, constraints, states, compatibility, errors, side effects, and limitations as applicable.
4. Add concise examples only to illustrate correct use or interpretation.
5. Link outward to task guides and conceptual discussion.

### Write

- Use neutral, precise, factual language.
- Favor stable headings, tables, definitions, and consistent ordering.
- Distinguish required, optional, defaulted, deprecated, experimental, and unsupported behavior.
- State normative warnings and invariants plainly.
- Generate facts from code or schemas where the project supports it, then verify generated output.

### Avoid

- Do not tell an extended task story.
- Do not speculate, persuade, or hide opinions as facts.
- Do not expand an example into a tutorial or explanation.
- Do not mirror implementation structure when it would expose irrelevant internals rather than the product's useful conceptual structure.

### Verify

- Compare every factual field with the current authoritative source.
- Check completeness against the declared surface, not against an undefined ideal.
- Test examples and confirm version applicability.
- Check identical concepts use identical names and formats across the reference set.

## Explanation

### Contract

Help a reader deepen or connect their understanding after stepping back from immediate work. Illuminate a bounded topic, commonly through a “why” question.

### Shape

1. Define the topic and the question the page will illuminate.
2. Establish context and the bigger picture.
3. Connect causes, constraints, history, design decisions, consequences, and related concepts.
4. Compare alternatives and perspectives when they deepen understanding.
5. Bound the discussion deliberately and link to procedures or factual catalogs elsewhere.

### Write

- Use a discursive structure rather than a task sequence.
- Make reasoning and causal relationships explicit.
- Mark judgments, interpretations, and uncertainty honestly.
- Use examples, analogies, counterexamples, and diagrams to clarify connections.
- Explain why a choice exists and what follows from it, not merely what the choice is.

### Avoid

- Do not turn the page into operational steps.
- Do not bury the central question under an unbounded survey of everything related.
- Do not duplicate authoritative catalogs that belong in reference.
- Do not present one perspective as objective truth when alternatives matter.

### Verify

- Confirm factual premises independently even though the page admits perspective.
- Check that the reasoning connects evidence to conclusions.
- Ensure trade-offs and material counterexamples are represented fairly.
- Ask whether the reader finishes with a clearer mental model, not merely more facts.

## Cross-mode checks

### Distinguish neighboring modes

- Tutorial vs. how-to: both direct action. Choose tutorial for acquiring competence in a controlled path; choose how-to for applying competence to a real task with possible branches.
- Reference vs. explanation: both convey knowledge. Choose reference for facts consulted during work; choose explanation for context and reasoning considered during study.
- Tutorial vs. explanation: both serve learning. Choose tutorial when action carries the learning; choose explanation when reflection carries it.
- How-to vs. reference: both serve work. Choose how-to for a goal-directed sequence; choose reference for facts the reader selects and applies.

### Link instead of blend

Use links as hand-offs between needs:

- Tutorial → how-to: “Now apply this in your own environment.”
- Tutorial/how-to → reference: “See all options and constraints.”
- Tutorial/how-to → explanation: “Understand why this design works.”
- Explanation/reference → how-to: “Put this knowledge into practice.”

Use descriptive link text that names the destination need. Do not use links to excuse missing steps that are necessary for the current page's contract.
