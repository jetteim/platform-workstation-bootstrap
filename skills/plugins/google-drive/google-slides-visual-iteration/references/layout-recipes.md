# Visual layout recipes

Load for crowded text, repeated cards, metrics or shape/line edits. These are conditional recipes, not minimum edit counts.

## Slide-Level Heuristics

Apply these in order:

1. Legibility
- No clipped text.
- No elements touching or nearly touching unless intentionally grouped.
- Keep comfortable padding between text and container edges.
- Text inside a box, card, or shape should not sit uncomfortably close to that container's border. If the padding looks cramped in the thumbnail, treat it as a defect and fix it.

2. Structure
- Align related elements to a shared left edge, center line, or grid.
- Normalize spacing between repeated items.
- Remove accidental overlaps before style refinements.
- When a container or shape is too small for its text, prefer resizing the container or redistributing the layout over tolerating cramped text padding.
- When multiple cards or panels are presented as siblings, keep their header text, icon blocks, and first body lines aligned on consistent horizontal and vertical planes.

3. Balance
- Avoid slides that are top-heavy or left-heavy unless it is a deliberate composition.
- Resize or reposition oversized images/shapes that dominate the slide without helping the message.

4. Consistency
- Keep repeated bullets, labels, captions, and card headings consistent in weight, alignment, and spacing unless the difference is intentional.
- If a row or family of elements should look parallel, treat one-off bolding, indentation, or sizing differences as defects to fix.
- If three or more boxes read as a set, treat mismatched header heights, top padding, or body-start positions as alignment defects even when the text itself is different lengths.

5. Restraint
- Do not churn the whole slide if one local fix is enough.
- Do not invent new decorative elements unless the user explicitly wants a redesign.
- Do not treat compression as polish. A slide that only fits because everything was squeezed tighter is still broken.
- Do not stop after a cosmetic near-fix. If the text is still cramped against a border, still visually crowded, or still obviously misaligned, keep editing.

## Editing Guidance For Raw Slides Requests

The Slides connector exposes raw `batch_update` requests. That means:
- Always inspect the current slide before editing.
- Keep the tool loop local to the current slide: one slide thumbnail in, one slide edit pass, one verification thumbnail out.
- Use object IDs from the live slide state, not guessed IDs.
- Distinguish shape styling from line styling before writing. A colored arrow may be a filled shape, a line with arrowheads, or an image; the request family must match the element type.
- For fills and borders, start with `updateShapeProperties`. For connector or line strokes, start with `updateLineProperties`.
- When replacing a screenshot placeholder with a source chart, reuse the current image geometry as the starting insertion footprint instead of inventing a new layout.
- If nearby text updated but the accent bar, arrow, or border stayed stale, treat the slide as incomplete rather than “mostly done.”
- Prefer reversible, geometric edits first: transform, size, alignment, deletion only when clearly safe.
- If a text box is too dense, try resizing, redistributing, or reflowing the slide before shortening the text.
- If the only apparent fix is to compress all the content tighter, stop and reconsider the layout pattern instead of blindly applying that edit.
