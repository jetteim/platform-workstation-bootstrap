# Agent-Agnostic Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `~/.agents` the canonical install layer for reusable workstation rules, skills, prompts, hooks, and source mirrors, then project that layer into Codex and Claude adapters.

**Architecture:** Introduce a canonical `agents/` source tree in the repo, install it to `~/.agents`, and project compatible assets into `~/.codex` and `~/.claude`. Keep existing `skills/` and `codex/` paths as compatibility sources during v1, while moving installer behavior and verification toward the canonical model.

**Tech Stack:** Bash install scripts, Python hook dispatcher/policy modules, Markdown rule and plan docs, existing `scripts/verify.sh` shell verification.

---

## File Structure

- Create: `agents/rules/codebase-exploration.md` for durable codebase exploration rules.
- Create: `agents/rules/reliability-observability.md` for shared reliability and observability guidance currently embedded in Codex hooks.
- Create: `agents/rules/secrets-and-safety.md` for shared secret-handling and destructive-action guidance.
- Create: `agents/manifests/skill-projections.tsv` for adapter compatibility and projection routing.
- Create: `agents/adapters/claude/CLAUDE.md.template` for Claude-visible shared rules.
- Create: `agents/adapters/codex/README.md` to document Codex adapter projection.
- Copy into: `agents/adapters/codex/hooks.json`, `agents/adapters/codex/config.example.toml`, and `agents/adapters/codex/hooks/*.py` from current `codex/`.
- Copy into: `agents/skills/superpowers`, `agents/skills/platform`, `agents/skills/plugins`, and `agents/skills/codex-curated` from current vendored skill sources.
- Modify: `scripts/install-skills.sh` to install canonical skills into `~/.agents/skills`, clone mirrors under `~/.agents/vendor_imports`, and project adapter-compatible skills.
- Modify: `scripts/install.sh` to install canonical rules/prompts/hooks, call the skill installer, and project Codex adapter files from `agents/adapters/codex`.
- Modify: `scripts/install-brain-prereqs.sh`, `scripts/run-brain-mlx-smoke.sh`, and `scripts/test-brain-skill.sh` to read source mirrors from `~/.agents/vendor_imports` while leaving Brain runtime under `~/.codex/mlx`.
- Modify: `scripts/verify.sh` to verify canonical source paths, adapter projections, architectural execution skills in `agents/skills/platform`, and canonical path references.
- Modify: `README.md`, `docs/external-dependencies.md`, and `docs/original-install-comparison.md` to describe the agent-neutral model.

---

### Task 1: Add Canonical Source Tree And Failing Verification

**Files:**
- Modify: `scripts/verify.sh`
- Create: `agents/rules/codebase-exploration.md`
- Create: `agents/rules/reliability-observability.md`
- Create: `agents/rules/secrets-and-safety.md`
- Create: `agents/manifests/skill-projections.tsv`
- Create: `agents/adapters/claude/CLAUDE.md.template`
- Create: `agents/adapters/codex/README.md`

- [ ] **Step 1: Write failing verification for canonical paths**

Add this block to `scripts/verify.sh` after the existing documentation file checks:

```bash
test -f "$repo_root/agents/rules/codebase-exploration.md"
test -f "$repo_root/agents/rules/reliability-observability.md"
test -f "$repo_root/agents/rules/secrets-and-safety.md"
test -f "$repo_root/agents/manifests/skill-projections.tsv"
test -f "$repo_root/agents/adapters/claude/CLAUDE.md.template"
test -f "$repo_root/agents/adapters/codex/README.md"
grep -q 'Build a context map before exploring a codebase' "$repo_root/agents/rules/codebase-exploration.md"
grep -q 'orchestrating-architecture-execution' "$repo_root/agents/manifests/skill-projections.tsv"
grep -q '~/.agents' "$repo_root/agents/adapters/claude/CLAUDE.md.template"
```

- [ ] **Step 2: Run verification to confirm RED**

Run:

```bash
./scripts/verify.sh
```

Expected: FAIL with a missing file error for `agents/rules/codebase-exploration.md` or another new canonical file.

- [ ] **Step 3: Create canonical rule files**

Create `agents/rules/codebase-exploration.md`:

```markdown
# Codebase Exploration Rules

Use these rules before editing or deeply inspecting a repository.

1. Build a context map before exploring a codebase.
2. Use `rg` or grep first, then read targeted files or sections.
3. Read a file once when possible; do not reread just to refresh memory.
4. For large files, use offsets or ranges instead of full-file reads.
5. Do not repeat the same search query over the same paths and patterns; cache and reuse search results within the task.
```

Create `agents/rules/reliability-observability.md`:

```markdown
# Reliability And Observability Rules

- For reliability work, capture target, command, timestamp, output path, metric/log/trace names, rollback path, and verification evidence.
- For infra changes, prefer plan, dry-run, or diff before apply, delete, or destroy.
- Do not claim fixed, passing, or complete without verification or an explicit caveat.
- Record concrete evidence: command, timestamp, output path, and the names of relevant telemetry.
```

Create `agents/rules/secrets-and-safety.md`:

```markdown
# Secrets And Safety Rules

- Treat secrets as toxic: do not print, quote, persist, or commit them.
- Do not read credential files unless the user explicitly asks and the action is necessary.
- Block obvious credential exfiltration and private key exposure.
- Ask before destructive filesystem or infrastructure actions when there is no dry-run evidence.
```

- [ ] **Step 4: Create compatibility manifest**

Create `agents/manifests/skill-projections.tsv`:

```text
# skill	source	codex	claude	category
superpowers	skills/superpowers	yes	yes	superpowers
plugin-github	skills/plugins/github	yes	yes	plugin-fallback
plugin-google-drive	skills/plugins/google-drive	yes	yes	plugin-fallback
brain	skills/codex/brain	yes	yes	platform
observability-engineering	skills/codex/observability-engineering	yes	yes	platform
reliability-engineering	skills/codex/reliability-engineering	yes	yes	platform
orchestrating-architecture-execution	skills/codex/orchestrating-architecture-execution	yes	yes	platform
discovering-value-streams	skills/codex/discovering-value-streams	yes	yes	platform
shaping-capabilities	skills/codex/shaping-capabilities	yes	yes	platform
shaping-features	skills/codex/shaping-features	yes	yes	platform
modeling-c4-architecture	skills/codex/modeling-c4-architecture	yes	yes	platform
slicing-stories	skills/codex/slicing-stories	yes	yes	platform
reviewing-traceability	skills/codex/reviewing-traceability	yes	yes	platform
codex-curated	skills/codex	yes	no	codex-curated
```

- [ ] **Step 5: Create adapter seed docs/templates**

Create `agents/adapters/claude/CLAUDE.md.template`:

```markdown
# Agent Workstation Rules

This workstation uses `~/.agents` as the canonical source for reusable rules and skills.

## Required Shared Rules

Read and follow:

- `~/.agents/rules/codebase-exploration.md`
- `~/.agents/rules/reliability-observability.md`
- `~/.agents/rules/secrets-and-safety.md`

## Skills

Reusable skills are installed under `~/.claude/skills` from `~/.agents/skills`.
```

Create `agents/adapters/codex/README.md`:

```markdown
# Codex Adapter

Codex receives projected assets from the canonical `~/.agents` layer.

- Skills project to `~/.codex/skills`.
- Hook config projects to `~/.codex/hooks.json`.
- Hook dispatcher files project to `~/.codex/hooks`.
- Feature flags are maintained in `~/.codex/config.toml`.
```

- [ ] **Step 6: Run verification to confirm GREEN**

Run:

```bash
./scripts/verify.sh
```

Expected: PASS through the new canonical file checks and continue to existing checks. If later checks fail, fix only failures caused by the new block.

- [ ] **Step 7: Commit canonical source skeleton**

```bash
git add agents scripts/verify.sh
git commit -m "feat: add canonical agent source skeleton"
```

---

### Task 2: Populate Canonical Skill Sources

**Files:**
- Modify: `scripts/verify.sh`
- Create/copy: `agents/skills/superpowers/*`
- Create/copy: `agents/skills/platform/*`
- Create/copy: `agents/skills/plugins/github/*`
- Create/copy: `agents/skills/plugins/google-drive/*`
- Create/copy: `agents/skills/codex-curated/*`

- [ ] **Step 1: Write failing verification for canonical skill inventory**

Add this block to `scripts/verify.sh` after the `skill_count` check:

```bash
test -f "$repo_root/agents/skills/superpowers/brainstorming/SKILL.md"
test -f "$repo_root/agents/skills/platform/orchestrating-architecture-execution/SKILL.md"
test -f "$repo_root/agents/skills/platform/discovering-value-streams/SKILL.md"
test -f "$repo_root/agents/skills/platform/shaping-capabilities/SKILL.md"
test -f "$repo_root/agents/skills/platform/shaping-features/SKILL.md"
test -f "$repo_root/agents/skills/platform/modeling-c4-architecture/SKILL.md"
test -f "$repo_root/agents/skills/platform/slicing-stories/SKILL.md"
test -f "$repo_root/agents/skills/platform/reviewing-traceability/SKILL.md"
test -f "$repo_root/agents/skills/plugins/github/yeet/SKILL.md"
test -f "$repo_root/agents/skills/plugins/google-drive/google-drive/SKILL.md"
canonical_skill_count="$(find "$repo_root/agents/skills" -name SKILL.md | wc -l | tr -d ' ')"
if [ "$canonical_skill_count" -lt 40 ]; then
  echo "expected at least 40 canonical skills, found $canonical_skill_count" >&2
  exit 1
fi
```

- [ ] **Step 2: Run verification to confirm RED**

Run:

```bash
./scripts/verify.sh
```

Expected: FAIL because `agents/skills/superpowers/brainstorming/SKILL.md` does not exist yet.

- [ ] **Step 3: Copy current skill sources into canonical layout**

Run:

```bash
mkdir -p agents/skills/superpowers agents/skills/platform agents/skills/plugins agents/skills/codex-curated
cp -R skills/superpowers/. agents/skills/superpowers/
cp -R skills/plugins/github agents/skills/plugins/github
cp -R skills/plugins/google-drive agents/skills/plugins/google-drive
cp -R skills/codex/. agents/skills/codex-curated/
for skill in \
  orchestrating-architecture-execution \
  discovering-value-streams \
  shaping-capabilities \
  shaping-features \
  modeling-c4-architecture \
  slicing-stories \
  reviewing-traceability \
  observability-engineering \
  reliability-engineering \
  brain; do
  rm -rf "agents/skills/platform/$skill"
  cp -R "skills/codex/$skill" "agents/skills/platform/$skill"
done
```

- [ ] **Step 4: Run verification to confirm GREEN**

Run:

```bash
./scripts/verify.sh
```

Expected: PASS through canonical skill inventory checks.

- [ ] **Step 5: Commit canonical skill inventory**

```bash
git add agents/skills scripts/verify.sh
git commit -m "feat: vendor canonical agent skills"
```

---

### Task 3: Install Canonical Layer Into `~/.agents`

**Files:**
- Modify: `scripts/install.sh`
- Modify: `scripts/install-skills.sh`
- Modify: `scripts/verify.sh`

- [ ] **Step 1: Write failing verification for canonical install references**

Add this block to `scripts/verify.sh` near the existing script `grep` checks:

```bash
grep -q 'AGENTS_HOME' "$repo_root/scripts/install.sh"
grep -q 'AGENTS_HOME' "$repo_root/scripts/install-skills.sh"
grep -q '\.agents/rules' "$repo_root/scripts/install.sh"
grep -q '\.agents/skills' "$repo_root/scripts/install-skills.sh"
grep -q '\.agents/vendor_imports' "$repo_root/scripts/install-skills.sh"
```

- [ ] **Step 2: Run verification to confirm RED**

Run:

```bash
./scripts/verify.sh
```

Expected: FAIL because `AGENTS_HOME` is not present in the install scripts.

- [ ] **Step 3: Update `scripts/install.sh` canonical setup**

Near the top of `scripts/install.sh`, after `repo_root=...`, add:

```bash
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"

install_tree() {
  local source="$1"
  local destination="$2"
  local label="$3"

  if [ ! -d "$source" ]; then
    echo "[install] missing source for ${label}: ${source}" >&2
    exit 1
  fi

  mkdir -p "$destination"
  cp -R "$source/." "$destination/"
  echo "[install] installed ${label}: ${destination}"
}
```

Replace the first `mkdir -p` line with:

```bash
mkdir -p "$AGENTS_HOME/rules" "$AGENTS_HOME/hooks" "$AGENTS_HOME/prompts" "$CODEX_HOME/hooks" "$HOME/.config/git/hooks"
```

Before copying Codex hooks, add:

```bash
install_tree "$repo_root/agents/rules" "$AGENTS_HOME/rules" "agent rules"
if [ -d "$repo_root/agents/hooks" ]; then
  install_tree "$repo_root/agents/hooks" "$AGENTS_HOME/hooks" "agent hooks"
fi
if [ -d "$repo_root/agents/prompts" ]; then
  install_tree "$repo_root/agents/prompts" "$AGENTS_HOME/prompts" "agent prompts"
fi
```

Replace Codex hook copy paths with adapter paths:

```bash
cp "$repo_root/agents/adapters/codex/hooks/"*.py "$CODEX_HOME/hooks/"
chmod +x "$CODEX_HOME/hooks/codex_hook.py"
cp "$repo_root/agents/adapters/codex/hooks.json" "$CODEX_HOME/hooks.json"
```

Replace the Python config path argument:

```bash
python3 - "$CODEX_HOME/config.toml" <<'PY'
```

Update final messages:

```bash
echo "[install] installed canonical agent layer, adapter projections, and global Git safety hook"
echo "[install] review agents/adapters/codex/config.example.toml before changing live $CODEX_HOME/config.toml further"
```

- [ ] **Step 4: Update `scripts/install-skills.sh` canonical variables**

Add after `skills_root=...`:

```bash
agents_root="$repo_root/agents"
canonical_skills_root="$agents_root/skills"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
```

Replace:

```bash
mkdir -p "$HOME/.codex/skills" "$HOME/.agents/skills"
```

with:

```bash
mkdir -p "$AGENTS_HOME/skills" "$AGENTS_HOME/vendor_imports/repos" "$CODEX_HOME/skills" "$CLAUDE_HOME/skills"
```

Add after `gh auth setup-git`:

```bash
install_tree "$canonical_skills_root/superpowers" "$AGENTS_HOME/skills/superpowers" "canonical Superpowers skills"
install_tree "$canonical_skills_root/plugins/github" "$AGENTS_HOME/skills/plugin-github" "canonical GitHub plugin fallback skills"
install_tree "$canonical_skills_root/plugins/google-drive" "$AGENTS_HOME/skills/plugin-google-drive" "canonical Google Drive plugin fallback skills"
install_tree "$canonical_skills_root/platform" "$AGENTS_HOME/skills" "canonical platform skills"
```

- [ ] **Step 5: Run verification to confirm GREEN**

Run:

```bash
./scripts/verify.sh
```

Expected: PASS through canonical install reference checks.

- [ ] **Step 6: Commit canonical installer layer**

```bash
git add scripts/install.sh scripts/install-skills.sh scripts/verify.sh
git commit -m "feat: install canonical agent layer"
```

---

### Task 4: Project Codex From Canonical Sources

**Files:**
- Create/copy: `agents/adapters/codex/hooks.json`
- Create/copy: `agents/adapters/codex/config.example.toml`
- Create/copy: `agents/adapters/codex/hooks/codex_hook.py`
- Create/copy: `agents/adapters/codex/hooks/policy.py`
- Create/copy: `agents/adapters/codex/hooks/redact.py`
- Modify: `scripts/install-skills.sh`
- Modify: `scripts/verify.sh`

- [ ] **Step 1: Write failing verification for Codex adapter files**

Add this block to `scripts/verify.sh` before the existing Python compile line or replace that line with the adapter-first version:

```bash
python3 -m py_compile \
  "$repo_root/agents/adapters/codex/hooks/codex_hook.py" \
  "$repo_root/agents/adapters/codex/hooks/policy.py" \
  "$repo_root/agents/adapters/codex/hooks/redact.py"
test -f "$repo_root/agents/adapters/codex/hooks.json"
test -f "$repo_root/agents/adapters/codex/config.example.toml"
grep -q 'multi_agent = true' "$repo_root/agents/adapters/codex/config.example.toml"
```

Keep the existing `codex/` compile check during v1, so both paths are verified.

- [ ] **Step 2: Run verification to confirm RED**

Run:

```bash
./scripts/verify.sh
```

Expected: FAIL because `agents/adapters/codex/hooks/codex_hook.py` is missing.

- [ ] **Step 3: Copy Codex adapter files**

Run:

```bash
mkdir -p agents/adapters/codex/hooks
cp codex/hooks.json agents/adapters/codex/hooks.json
cp codex/config.example.toml agents/adapters/codex/config.example.toml
cp codex/hooks/*.py agents/adapters/codex/hooks/
```

- [ ] **Step 4: Update Codex projection in `scripts/install-skills.sh`**

Replace:

```bash
install_tree "$skills_root/codex" "$HOME/.codex/skills" "Codex user/system skills"
```

with:

```bash
install_tree "$canonical_skills_root/codex-curated" "$CODEX_HOME/skills" "Codex curated/user skills"
install_tree "$AGENTS_HOME/skills" "$CODEX_HOME/skills" "Codex projection from canonical skills"
```

Replace Superpowers symlink logic with a canonical symlink:

```bash
if [ "$superpowers_ready" = "1" ] && { [ -L "$AGENTS_HOME/skills/superpowers" ] || [ ! -e "$AGENTS_HOME/skills/superpowers" ]; }; then
  rm -f "$AGENTS_HOME/skills/superpowers"
  ln -s "$CODEX_HOME/superpowers/skills" "$AGENTS_HOME/skills/superpowers"
  echo "[skills] linked Superpowers skills -> ~/.agents/skills/superpowers"
elif [ "$superpowers_ready" = "1" ]; then
  echo "[skills] ~/.agents/skills/superpowers exists and is not a symlink; leaving it unchanged" >&2
fi
```

Then ensure Codex receives the canonical Superpowers copy:

```bash
install_tree "$AGENTS_HOME/skills/superpowers" "$CODEX_HOME/skills/superpowers" "Codex Superpowers projection"
```

- [ ] **Step 5: Run verification to confirm GREEN**

Run:

```bash
./scripts/verify.sh
```

Expected: PASS with both legacy `codex/` and new `agents/adapters/codex` hook files compiling.

- [ ] **Step 6: Commit Codex adapter projection**

```bash
git add agents/adapters/codex scripts/install-skills.sh scripts/verify.sh
git commit -m "feat: project codex adapter from agent layer"
```

---

### Task 5: Add Claude Skill And Rule Projection

**Files:**
- Modify: `scripts/install-skills.sh`
- Modify: `scripts/install.sh`
- Modify: `scripts/verify.sh`
- Modify: `agents/adapters/claude/CLAUDE.md.template`

- [ ] **Step 1: Write failing verification for Claude projection**

Add this block to `scripts/verify.sh` near adapter checks:

```bash
grep -q 'CLAUDE_HOME' "$repo_root/scripts/install-skills.sh"
grep -q 'CLAUDE_HOME' "$repo_root/scripts/install.sh"
grep -q '~/.claude/skills' "$repo_root/agents/adapters/claude/CLAUDE.md.template"
grep -q 'codebase-exploration.md' "$repo_root/agents/adapters/claude/CLAUDE.md.template"
```

- [ ] **Step 2: Run verification to confirm RED**

Run:

```bash
./scripts/verify.sh
```

Expected: FAIL because `CLAUDE_HOME` is not referenced in `scripts/install.sh` yet.

- [ ] **Step 3: Add Claude variables and rule template install**

In `scripts/install.sh`, add with the other home variables:

```bash
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
```

Add after canonical rules are installed:

```bash
mkdir -p "$CLAUDE_HOME"
cp "$repo_root/agents/adapters/claude/CLAUDE.md.template" "$CLAUDE_HOME/CLAUDE.md.template"
echo "[install] installed Claude rule template: $CLAUDE_HOME/CLAUDE.md.template"
```

- [ ] **Step 4: Add Claude skill projection**

In `scripts/install-skills.sh`, after Codex projection installs:

```bash
install_tree "$AGENTS_HOME/skills" "$CLAUDE_HOME/skills" "Claude skill projection from canonical skills"
```

- [ ] **Step 5: Tighten Claude template wording**

Ensure `agents/adapters/claude/CLAUDE.md.template` contains:

```markdown
# Agent Workstation Rules

This workstation uses `~/.agents` as the canonical source for reusable rules and skills.

## Required Shared Rules

Read and follow:

- `~/.agents/rules/codebase-exploration.md`
- `~/.agents/rules/reliability-observability.md`
- `~/.agents/rules/secrets-and-safety.md`

## Skills

Reusable skills are installed under `~/.claude/skills` from `~/.agents/skills`.

## Adapter Boundary

Do not assume Codex hook events exist in Claude. Use the shared rules and skills first, then Claude-native capabilities where available.
```

- [ ] **Step 6: Run verification to confirm GREEN**

Run:

```bash
./scripts/verify.sh
```

Expected: PASS through Claude adapter projection checks.

- [ ] **Step 7: Commit Claude adapter projection**

```bash
git add agents/adapters/claude scripts/install.sh scripts/install-skills.sh scripts/verify.sh
git commit -m "feat: add claude adapter projection"
```

---

### Task 6: Move Source Mirrors To `~/.agents/vendor_imports`

**Files:**
- Modify: `scripts/install-skills.sh`
- Modify: `scripts/install-brain-prereqs.sh`
- Modify: `scripts/run-brain-mlx-smoke.sh`
- Modify: `scripts/test-brain-skill.sh`
- Modify: `scripts/verify.sh`

- [ ] **Step 1: Write failing verification for canonical mirror paths**

Add this block to `scripts/verify.sh` near existing mirror grep checks:

```bash
grep -q 'AGENTS_HOME/vendor_imports/skills' "$repo_root/scripts/install-skills.sh"
grep -q 'AGENTS_HOME/vendor_imports/repos/llama.cpp' "$repo_root/scripts/install-skills.sh"
grep -q 'AGENTS_HOME/vendor_imports/repos/llama.cpp' "$repo_root/scripts/install-brain-prereqs.sh"
grep -q 'AGENTS_HOME/vendor_imports/repos/llama.cpp' "$repo_root/scripts/run-brain-mlx-smoke.sh"
```

- [ ] **Step 2: Run verification to confirm RED**

Run:

```bash
./scripts/verify.sh
```

Expected: FAIL because mirror paths still use `~/.codex/vendor_imports`.

- [ ] **Step 3: Update mirror destinations in `scripts/install-skills.sh`**

Replace OpenAI skills mirror:

```bash
if ! clone_or_update "$OPENAI_SKILLS_REPO" "$AGENTS_HOME/vendor_imports/skills" "main" "OpenAI skills source mirror"; then
  echo "[skills] OpenAI skills source mirror was not refreshed; vendored Codex skills remain installed" >&2
fi
```

Replace the mirror loop destinations with:

```bash
for mirror in \
  "$CODEX_REPO|$AGENTS_HOME/vendor_imports/repos/codex|main|Codex source mirror" \
  "$PLAYWRIGHT_MCP_REPO|$AGENTS_HOME/vendor_imports/repos/playwright-mcp|main|Playwright MCP source mirror" \
  "$MCP_SERVERS_REPO|$AGENTS_HOME/vendor_imports/repos/servers|main|MCP servers source mirror" \
  "$BRAIN_SKILL_REPO|$AGENTS_HOME/vendor_imports/repos/brain-skill|main|Brain skill source mirror" \
  "$LLAMA_CPP_REPO|$AGENTS_HOME/vendor_imports/repos/llama.cpp|master|llama.cpp source mirror" \
  "$PLATFORM_OBSERVABILITY_MODEL_REPO|$AGENTS_HOME/vendor_imports/repos/platform-observability-model|main|Platform observability model source mirror" \
  "$OBSERVABILITY_ENGINEERING_REPO|$AGENTS_HOME/vendor_imports/repos/observability-engineering|main|Observability engineering skill source mirror" \
  "$PLATFORM_RELIABILITY_MODEL_REPO|$AGENTS_HOME/vendor_imports/repos/platform-reliability-model|main|Platform reliability model source mirror" \
  "$RELIABILITY_ENGINEERING_REPO|$AGENTS_HOME/vendor_imports/repos/reliability-engineering|main|Reliability engineering skill source mirror" \
  "$ARCHITECTURAL_EXECUTION_SKILLS_REPO|$AGENTS_HOME/vendor_imports/repos/architectural-execution-skills|main|Architectural execution skills source mirror"; do
```

Replace source-backed skill install paths:

```bash
if [ -d "$AGENTS_HOME/vendor_imports/repos/brain-skill/skill" ]; then
  install_tree "$AGENTS_HOME/vendor_imports/repos/brain-skill/skill" "$AGENTS_HOME/skills/brain" "Brain skill from source mirror"
elif [ -d "$canonical_skills_root/platform/brain" ]; then
  install_tree "$canonical_skills_root/platform/brain" "$AGENTS_HOME/skills/brain" "vendored Brain skill fallback"
fi
```

Replace observability source-backed install paths:

```bash
if [ -d "$AGENTS_HOME/vendor_imports/repos/observability-engineering/skill/observability-engineering" ]; then
  install_tree "$AGENTS_HOME/vendor_imports/repos/observability-engineering/skill/observability-engineering" "$AGENTS_HOME/skills/observability-engineering" "Observability engineering skill from source mirror"
elif [ -d "$canonical_skills_root/platform/observability-engineering" ]; then
  install_tree "$canonical_skills_root/platform/observability-engineering" "$AGENTS_HOME/skills/observability-engineering" "vendored Observability engineering skill fallback"
fi
```

Replace reliability source-backed install paths:

```bash
if [ -d "$AGENTS_HOME/vendor_imports/repos/reliability-engineering/skill/reliability-engineering" ]; then
  install_tree "$AGENTS_HOME/vendor_imports/repos/reliability-engineering/skill/reliability-engineering" "$AGENTS_HOME/skills/reliability-engineering" "Reliability engineering skill from source mirror"
elif [ -d "$canonical_skills_root/platform/reliability-engineering" ]; then
  install_tree "$canonical_skills_root/platform/reliability-engineering" "$AGENTS_HOME/skills/reliability-engineering" "vendored Reliability engineering skill fallback"
fi
```

Replace architectural execution source-backed install paths:

```bash
if [ -d "$AGENTS_HOME/vendor_imports/repos/architectural-execution-skills/skills" ]; then
  install_tree "$AGENTS_HOME/vendor_imports/repos/architectural-execution-skills/skills" "$AGENTS_HOME/skills" "Architectural execution skills from source mirror"
else
  for architectural_skill in \
    discovering-value-streams \
    modeling-c4-architecture \
    orchestrating-architecture-execution \
    reviewing-traceability \
    shaping-capabilities \
    shaping-features \
    slicing-stories; do
    if [ -d "$canonical_skills_root/platform/$architectural_skill" ]; then
      install_tree "$canonical_skills_root/platform/$architectural_skill" "$AGENTS_HOME/skills/$architectural_skill" "vendored ${architectural_skill} skill fallback"
    fi
  done
fi
```

- [ ] **Step 4: Update Brain scripts to use canonical mirrors**

In `scripts/install-brain-prereqs.sh`, replace the first path block with:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
venv_path="${BRAIN_MLX_VENV:-$CODEX_HOME/mlx/brain-venv}"
llama_repo="${LLAMA_CPP_REPO:-https://github.com/jetteim/llama.cpp.git}"
llama_path="${LLAMA_CPP_PATH:-$AGENTS_HOME/vendor_imports/repos/llama.cpp}"
```

In `scripts/run-brain-mlx-smoke.sh`, replace the first path block with:

```bash
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
venv_path="${BRAIN_MLX_VENV:-$CODEX_HOME/mlx/brain-venv}"
run_root="${BRAIN_MLX_RUN_ROOT:-$CODEX_HOME/mlx/runs/k8s-risk-classifier}"
model="${BRAIN_MLX_MODEL:-mlx-community/Qwen3-0.6B-bf16}"
iters="${BRAIN_MLX_ITERS:-300}"
llama_cpp_path="${LLAMA_CPP_PATH:-$AGENTS_HOME/vendor_imports/repos/llama.cpp}"
```

In `scripts/test-brain-skill.sh`, replace the first path block with:

```bash
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_home="${CODEX_HOME:-$HOME/.codex}"
agents_home="${AGENTS_HOME:-$HOME/.agents}"
skill_path="$codex_home/skills/brain/SKILL.md"
mirror_path="$agents_home/vendor_imports/repos/brain-skill"
brain_python="$codex_home/mlx/brain-venv/bin/python"
```

- [ ] **Step 5: Run verification to confirm GREEN**

Run:

```bash
./scripts/verify.sh
```

Expected: PASS through canonical mirror checks while Brain runtime checks still reference `~/.codex/mlx`.

- [ ] **Step 6: Commit canonical mirror migration**

```bash
git add scripts/install-skills.sh scripts/install-brain-prereqs.sh scripts/run-brain-mlx-smoke.sh scripts/test-brain-skill.sh scripts/verify.sh
git commit -m "feat: move source mirrors to agent layer"
```

---

### Task 7: Update Documentation For Agent-Agnostic Bootstrap

**Files:**
- Modify: `README.md`
- Modify: `docs/external-dependencies.md`
- Modify: `docs/original-install-comparison.md`
- Modify: `docs/decisions.md`
- Modify: `scripts/verify.sh`

- [ ] **Step 1: Write failing documentation verification**

Add this block to `scripts/verify.sh` near documentation checks:

```bash
grep -q '~/.agents is the canonical agent-neutral layer' "$repo_root/README.md"
grep -q 'agents/skills/platform' "$repo_root/docs/external-dependencies.md"
grep -q 'Agent-Agnostic Bootstrap' "$repo_root/docs/original-install-comparison.md"
grep -q 'Codebase Exploration Rules' "$repo_root/docs/decisions.md"
```

- [ ] **Step 2: Run verification to confirm RED**

Run:

```bash
./scripts/verify.sh
```

Expected: FAIL because README does not yet contain the canonical layer wording.

- [ ] **Step 3: Update README install model**

Replace the opening explicit list item:

```markdown
- Codex configuration, hooks, skills, plugins, and MCP dependencies.
```

with:

```markdown
- Agent-neutral rules, skills, prompts, hooks, and source mirrors under `~/.agents`.
- Adapter projections for Codex, Claude, plugins, and MCP dependencies.
```

Add after the install command block:

```markdown
`~/.agents` is the canonical agent-neutral layer. Codex and Claude are adapter targets projected from that layer.
```

Update the skill install order bullets to include:

```markdown
- Install canonical shared skills under `~/.agents/skills`.
- Install source mirrors under `~/.agents/vendor_imports`.
- Project compatible skills into `~/.codex/skills` and `~/.claude/skills`.
```

- [ ] **Step 4: Update dependency docs**

In `docs/external-dependencies.md`, change local path descriptions from `~/.codex/vendor_imports/...` to `~/.agents/vendor_imports/...`.

Add to the vendored skill section:

```markdown
Canonical v1 skill sources are copied under `agents/skills/superpowers/`, `agents/skills/platform/`, `agents/skills/plugins/`, and `agents/skills/codex-curated/`.

`agents/skills/platform` includes the architectural execution pipeline: `orchestrating-architecture-execution`, value stream discovery, capability shaping, feature shaping, C4 modeling, story slicing, and traceability review.
```

- [ ] **Step 5: Update install comparison and decisions**

Add this section near the top of `docs/original-install-comparison.md`:

```markdown
## Agent-Agnostic Bootstrap

The current bootstrap installs `~/.agents` first, then projects compatible assets into Codex and Claude. Codex remains a supported adapter, not the canonical model for shared rules, skills, hooks, prompts, or source mirrors.
```

Add this section to `docs/decisions.md`:

```markdown
## Codebase Exploration Rules

Reusable agent guidance lives in `agents/rules/codebase-exploration.md` and installs to `~/.agents/rules`.

Agents should build a context map first, search with `rg` or grep before reading files, prefer targeted ranges for large files, avoid repeated identical searches, and reuse search results within a task.
```

- [ ] **Step 6: Run verification to confirm GREEN**

Run:

```bash
./scripts/verify.sh
```

Expected: PASS through updated documentation checks.

- [ ] **Step 7: Commit documentation update**

```bash
git add README.md docs/external-dependencies.md docs/original-install-comparison.md docs/decisions.md scripts/verify.sh
git commit -m "docs: document agent-agnostic bootstrap"
```

---

### Task 8: Final Install Smoke Test And Cleanup

**Files:**
- Modify only if verification exposes a defect: files touched in Tasks 1-7.

- [ ] **Step 1: Run syntax and static verification**

Run:

```bash
git diff --check
./scripts/verify.sh
```

Expected:

```text
[verify] ok
```

- [ ] **Step 2: Run non-refresh install smoke test**

Run:

```bash
SKIP_GITHUB_REFRESH=1 ./scripts/install.sh
```

Expected:

```text
[install] installed canonical agent layer, adapter projections, and global Git safety hook
```

The command may also print skill install messages. It must not force-reset dirty mirrors or require Brain/MLX training.

- [ ] **Step 3: Verify installed canonical paths**

Run:

```bash
test -f "$HOME/.agents/rules/codebase-exploration.md"
test -f "$HOME/.agents/skills/orchestrating-architecture-execution/SKILL.md"
test -f "$HOME/.codex/skills/orchestrating-architecture-execution/SKILL.md"
test -f "$HOME/.claude/skills/orchestrating-architecture-execution/SKILL.md"
test -f "$HOME/.claude/CLAUDE.md.template"
```

Expected: all commands exit 0.

- [ ] **Step 4: Re-run hook smoke test directly**

Run:

```bash
python3 "$PWD/agents/adapters/codex/hooks/codex_hook.py" UserPromptSubmit <<'JSON'
{"session_id":"test","turn_id":"test","cwd":"/tmp","model":"test","permission_mode":"default","prompt":"please check production terraform reliability and logs"}
JSON
```

Expected output contains:

```json
"hookEventName":"UserPromptSubmit"
```

- [ ] **Step 5: Check git status**

Run:

```bash
git status --short
```

Expected: only intentional changes from this task sequence are present. No generated runtime files from `~/.agents`, `~/.codex`, or `~/.claude` are staged or tracked.

- [ ] **Step 6: Commit final fixes if any were needed**

If Step 1-5 required fixes, commit them:

```bash
git add agents README.md docs scripts
git commit -m "fix: complete agent bootstrap verification"
```

If no fixes were needed, do not create an empty commit.
