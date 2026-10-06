---
name: google-slides-visual-iteration
description: "Inspect and polish a connected Google Slides deck: alignment, spacing, overflow, crops and visual consistency. Use rendered slides plus current geometry for requested visual cleanup."
---

# Google Slides Visual Iteration

Preserve the requested deck, slide scope and content. Use this for visual polish; use `google-slides-template-surgery` for recurring structural defects and `google-slides-template-migration` for a chosen new template. Import a local presentation only when Google Slides is the explicit or established destination.

## Capability and scope

Check for presentation reads, `get_slide`, `get_slide_thumbnail` and `batch_update` before editing. These are connected Google Drive app actions, not a presumed MCP server. Do not reconnect accounts automatically. If edits are unavailable, provide a bounded diagnosis; if rendering is unavailable, label structural checks separately from visual verification.

Inventory the requested slides and keep a coverage checklist for deck-wide work. Respect selected priority and scope; keep changes slide-local unless a verified repeated fix is safer. Use live slide/object IDs, fresh geometry before each write and a fresh revision token in `write_control` when supported.

## Visual loop

1. Read the slide structure and inspect its rendered thumbnail. Use LARGE for dense layouts. An image pointer, URL or successful tool response is not evidence that rendered pixels were inspected. Open the image through a supported host path; if that fails, retrieve a supported image/export or state the verification limit.
2. Identify concrete remaining defects: clipping and collisions first, then alignment, spacing, hierarchy and requested consistency. Briefly explain meaningful changes. If the slide already meets the requested outcome, mark it checked without writing.
3. Make one coherent, reversible edit for the defect. Prefer resizing, moving, reflowing and consistent styles before shrinking text or changing content. Do not delete real content or split slides without appropriate scope. Match shape, line and image request families to the live element type.
4. Re-read affected content/geometry and inspect a fresh rendered thumbnail after the write. Verify the actual correction, content preservation and absence of regressions. Tool success alone does not establish visual quality.
5. Write again only for a specific remaining defect. Stop when the requested result is verified, additional changes are subjective, or iterations cease improving it. Explain unresolved constraints; there is no minimum number of writes. For recurring structural problems, pilot a repair on one representative slide before expanding within the authorized scope.

Use [layout-recipes.md](references/layout-recipes.md) for card/text geometry and non-text styling, [batch-update-recipes](../google-slides-template-surgery/references/batch-update-recipes.md) for raw requests, and [sheets-chart-replacement](../google-drive/references/slides/sheets-chart-replacement.md) only for chart swaps. The reusable [visual-change-loop](../google-drive/references/slides/visual-change-loop.md) follows the same outcome-based stopping rule.

Return changed and checked slide coverage, verified fixes and remaining limitations. Do not claim visual completion when the final render was inaccessible.

## Connected capability boundary

Check the runtime exposes the exact reads and mutations needed for this operation. These skills use the Google Drive app/plugin; do not invent a Google MCP server or automatically connect an account. Missing tooling permits a bounded explanation or supplied-file analysis, not fabricated IDs, writes or verification.
