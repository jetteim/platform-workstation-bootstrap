---
name: google-slides-import-presentation
description: "Convert a local PPT, PPTX or ODP to native Google Slides when that destination is explicit or established; verify the imported deck."
---

# Google Slides Import Presentation

## Overview

Use this skill when the source material is a presentation file rather than an existing Google Slides deck. The goal is to create a native Google Slides copy first, then continue work on the imported deck.

## Required Tooling

Confirm the runtime exposes:
- `import_presentation`
- `get_presentation` or `get_presentation_text`
- `get_slide_thumbnail` when visual verification matters

If `import_presentation` is unavailable, stop and say the file cannot be converted into native Google Slides from Codex.

## Workflow

1. Confirm the input file.
- Accept `.ppt`, `.pptx`, or `.odp`.
- Use the uploaded file path directly when available.

2. Import the presentation.
- Use `import_presentation` to create a new native Google Slides deck.
- If the user gives a destination title, use it. Otherwise keep the imported title.

3. Read the imported deck.
- Capture the resulting presentation ID or URL, slide count, and major slide titles.
- Treat the imported deck as the new source of truth for follow-on work.

4. Verify enough to hand it off safely.
- Compare the imported slide count to the source file when that information is available.
- Use thumbnails for spot checks when layout fidelity matters or the user plans formatting cleanup next.

5. Hand off to the right next skill.
- Use the available `google-slides` skill for general summaries or edits; if absent, perform the bounded read/edit workflow with the available connected actions.
- Use [google-slides-visual-iteration](../google-slides-visual-iteration/SKILL.md) for post-import slide formatting cleanup.
- Use [google-slides-template-migration](../google-slides-template-migration/SKILL.md) when the imported deck should move onto a branded template.
- If import drift requires visible layout cleanup on a slide, follow [visual-change-loop](../google-drive/references/slides/visual-change-loop.md) until the requested outcome is verified, without unnecessary additional writes.

## Rules

- Treat import as conversion into a new native Google Slides deck, not in-place editing of the original file.
- Preserve source slide order and content by default.
- Do not promise perfect fidelity for animations, transitions, SmartArt, or other Office-specific features.
- If import introduces layout drift, fix it in the native Google Slides deck rather than editing the source file.
- A request to "edit this PPTX" preserves the local file workflow unless Google Slides conversion is explicit or already established. Use an available local presentation workflow, or explain the missing capability; do not upload/import by assumption.

## Output

- Return the resulting deck title and link or ID when the runtime exposes it.
- Call out any obvious import drift or unsupported formatting that needs follow-up.
- If no further edit was requested, stop after confirming that the native deck is ready.

## Example Requests

- "Import this PPTX into Google Slides so I can edit it."
- "Convert this deck to native Google Slides and then summarize the first five slides."
- "Bring this ODP into Google Slides and clean up any layout drift."

## Light Fallback

If the file is missing, unreadable, or the runtime cannot import it, say that presentation import may be unavailable or the provided file may be invalid, then ask for a valid local file or a connected Google Slides deck instead.

## Connected capability boundary

Check the runtime exposes the exact reads and mutations needed for this operation. These skills use the Google Drive app/plugin; do not invent a Google MCP server or automatically connect an account. Missing tooling permits a bounded explanation or supplied-file analysis, not fabricated IDs, writes or verification.
