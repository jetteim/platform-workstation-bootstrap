# Codebase Exploration Rules

Scale exploration to the requested change.

1. Build a context map before exploring a codebase when boundaries, dependencies, or ownership affect the change. For a bounded edit, inspect the relevant files and callers.
2. Use `rg` or grep first, then read targeted files or sections.
3. Reuse inspected context; reread when files changed or evidence is missing.
4. For large files, use offsets or ranges instead of full-file reads.
5. Do not repeat the same search query over the same paths and patterns; cache and reuse search results within the task.
