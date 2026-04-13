# Codebase Exploration Rules

Use these rules before editing or deeply inspecting a repository.

1. Build a context map before exploring a codebase.
2. Use `rg` or grep first, then read targeted files or sections.
3. Read a file once when possible; do not reread just to refresh memory.
4. For large files, use offsets or ranges instead of full-file reads.
5. Do not repeat the same search query over the same paths and patterns; cache and reuse search results within the task.
