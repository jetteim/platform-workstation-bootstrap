# Skill Trigger Examples

This is a practical prompt map for the vendored skills in this workstation bootstrap. Codex still decides from each skill's `description` field, but these examples make the expected activation surface explicit.

## Core Workflow Skills

| Skill | Example prompts that should trigger it |
| --- | --- |
| `using-superpowers` | "Start work on this repo", "Help me debug this", "Implement this change" |
| `brainstorming` | "Design a new incident dashboard", "Add a new hook behavior", "Think through a reliability feature before coding" |
| `writing-plans` | "Write an implementation plan for migrating hooks", "Plan the clean-machine bootstrap work" |
| `executing-plans` | "Execute this plan step by step", "Continue from this implementation plan" |
| `test-driven-development` | "Fix this bug", "Add this feature", "Implement validation for hook policies" |
| `systematic-debugging` | "A test is failing", "The hook blocks a valid file", "The MLX run crashes" |
| `verification-before-completion` | "Before you finish, verify it", "Commit only after checks pass", "Confirm this is working" |
| `requesting-code-review` | "Review the changes before merge", "Check this branch for risks" |
| `receiving-code-review` | "Address this review comment", "A reviewer says this is wrong; assess it" |
| `finishing-a-development-branch` | "This branch is ready; what next?", "Prepare this work for PR or merge" |
| `using-git-worktrees` | "Start isolated work on this feature", "Use a clean worktree for the refactor" |
| `dispatching-parallel-agents` | "Split these independent repo audits", "Run separate investigations for hooks and docs" |
| `subagent-driven-development` | "Execute this multi-part implementation with independent workers" |
| `writing-skills` | "Create a new skill", "Improve this SKILL.md", "Verify a skill before installing" |

## Local Model And AI Tooling

| Skill | Example prompts that should trigger it |
| --- | --- |
| `brain` | "Train a micro classifier for risky kubectl commands", "Fine-tune a local model for alert triage", "Build a local command router", "Export a GGUF classifier" |
| `observability-engineering` | "Build observability for this platform", "Define SLOs for this service", "Generate telemetry backend artifacts", "Migrate sre-rules into SLO intents", "Enforce OpenTelemetry semantic conventions" |
| `openai-docs` | "What is the current OpenAI API for responses?", "How do I upgrade this prompt to GPT-5.4?", "Which current OpenAI model should I use?" |
| `imagegen` | "Generate a transparent icon", "Create a raster illustration", "Edit this image into variants" |
| `skill-installer` | "Install a skill from openai/skills", "List curated skills", "Install this skill from a GitHub URL" |
| `skill-creator` | "Help me design a new skill", "What should go into a SKILL.md?" |
| `plugin-creator` | "Scaffold a Codex plugin", "Create plugin.json and plugin folders" |

## File Format Skills

| Skill | Example prompts that should trigger it |
| --- | --- |
| `doc` | "Edit this DOCX and preserve formatting", "Render-check a Word document" |
| `pdf` | "Extract tables from this PDF", "Create a PDF and visually verify it" |
| `spreadsheet` | "Create an XLSX report", "Preserve formulas while editing this spreadsheet", "Format this CSV into workbook tabs" |
| `jupyter-notebook` | "Create a notebook for this experiment", "Edit this `.ipynb` tutorial" |

## GitHub Skills

| Skill | Example prompts that should trigger it |
| --- | --- |
| `github` | "Summarize this PR", "Find recent issues in this repo", "Orient me in this GitHub repository" |
| `gh-address-comments` | "Address unresolved PR review comments", "Fix requested changes on PR 42" |
| `gh-fix-ci` | "Debug failing GitHub Actions", "Fix the failed CI checks on this PR" |
| `yeet` | "Commit, push, and open a draft PR", "Publish this branch to GitHub" |

## Google Drive Skills

| Skill | Example prompts that should trigger it |
| --- | --- |
| `google-drive` | "Find that Drive file", "Export this Drive document", "Organize these shared files" |
| `google-docs` | "Rewrite this Google Doc section", "Edit a table in this Doc", "Find paragraph indexes" |
| `google-drive-comments` | "Leave comments on this Doc", "Resolve Drive comments", "Reply to comment threads" |
| `google-sheets` | "Inspect this Google Sheet", "Search rows", "Update this range" |
| `google-sheets-formula-builder` | "Build a lookup formula", "Fix this broken Sheets formula", "Roll out a spill formula" |
| `google-sheets-chart-builder` | "Create a chart from this sheet", "Repair the chart series", "Move and resize this chart" |
| `google-slides` | "Summarize this deck", "Create a Google Slides presentation", "Update slide text" |
| `google-slides-import-presentation` | "Import this PPTX into Google Slides", "Convert this ODP to native Slides" |
| `google-slides-template-migration` | "Move this deck onto a new template", "Rebuild slides using this branded template" |
| `google-slides-template-surgery` | "Batch-fix structural layout defects", "Repair repeated template issues in Slides" |
| `google-slides-visual-iteration` | "Make this deck visually cleaner", "Fix slide alignment and overflow", "Iterate with thumbnails until it looks right" |

## Notes

- Some names appear from both standalone and plugin skill locations, for example `gh-fix-ci`. Prefer the plugin-backed variant when the task is clearly about GitHub app context.
- The `brain` skill is installed as an optional heavy path. Default bootstrap installs the skill instructions; `scripts/install-brain-prereqs.sh` installs the MLX/GGUF runtime.
- Trigger examples are intentionally user-facing prompts, not internal implementation details.
