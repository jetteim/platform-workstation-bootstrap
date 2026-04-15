#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m py_compile \
  "$repo_root/agents/hooks/policy.py" \
  "$repo_root/agents/hooks/redact.py" \
  "$repo_root/agents/adapters/codex/hooks/codex_hook.py" \
  "$repo_root/agents/adapters/codex/hooks/policy.py" \
  "$repo_root/agents/adapters/codex/hooks/redact.py"
test -f "$repo_root/agents/adapters/codex/hooks.json"
test -f "$repo_root/agents/adapters/codex/config.example.toml"
test -x "$repo_root/agents/adapters/codex/hooks/codex_hook.py"
grep -Fq '${CODEX_HOME:-$HOME/.codex}/hooks/codex_hook.py' "$repo_root/agents/adapters/codex/hooks.json"
grep -q 'os.environ.get("CODEX_HOME"' "$repo_root/agents/adapters/codex/hooks/codex_hook.py"
grep -q 'os.environ.get("AGENTS_HOME"' "$repo_root/agents/adapters/codex/hooks/codex_hook.py"
grep -q 'multi_agent = true' "$repo_root/agents/adapters/codex/config.example.toml"
python3 -m py_compile "$repo_root/codex/hooks/codex_hook.py" "$repo_root/codex/hooks/policy.py" "$repo_root/codex/hooks/redact.py"
bash -n "$repo_root/scripts/refresh-github.sh"
bash -n "$repo_root/scripts/install-brain-prereqs.sh"
bash -n "$repo_root/scripts/install-skills.sh"
bash -n "$repo_root/scripts/install.sh"
bash -n "$repo_root/scripts/run-brain-mlx-smoke.sh"
bash -n "$repo_root/scripts/test-brain-skill.sh"
bash -n "$repo_root/scripts/verify.sh"
bash -n "$repo_root/git/hooks/pre-commit"

test -f "$repo_root/docs/original-install-comparison.md"
test -f "$repo_root/docs/brain-skill-assessment.md"
test -f "$repo_root/docs/brain-skill-smoke-test.md"
test -f "$repo_root/docs/installability-audit-2026-04-12.md"
test -f "$repo_root/docs/skill-trigger-examples.md"
test -f "$repo_root/agents/rules/codebase-exploration.md"
test -f "$repo_root/agents/rules/operating-principles.md"
test -f "$repo_root/agents/rules/reliability-observability.md"
test -f "$repo_root/agents/rules/secrets-and-safety.md"
test -f "$repo_root/agents/hooks/policy.py"
test -f "$repo_root/agents/hooks/redact.py"
test -f "$repo_root/agents/prompts/platform-guardrails.md"
test -f "$repo_root/agents/manifests/skill-projections.tsv"
test -f "$repo_root/agents/skills/platform/observability-engineering/references/observability-model-summary.md"
test -f "$repo_root/agents/skills/platform/reliability-engineering/references/reliability-model-summary.md"
test -f "$repo_root/skills/codex/observability-engineering/references/observability-model-summary.md"
test -f "$repo_root/skills/codex/reliability-engineering/references/reliability-model-summary.md"
test -f "$repo_root/agents/adapters/claude/CLAUDE.md.template"
test -f "$repo_root/agents/adapters/codex/README.md"
grep -Fq '`~/.agents` is the canonical agent-neutral layer' "$repo_root/README.md"
grep -Fq 'Install canonical Superpowers into `~/.agents/skills/superpowers` as a real directory on fresh installs.' "$repo_root/README.md"
grep -Fq 'Replace a legacy `~/.agents/skills/superpowers` symlink with the canonical real directory during migration.' "$repo_root/README.md"
grep -q 'Build a context map before exploring a codebase' "$repo_root/agents/rules/codebase-exploration.md"
grep -q 'Honesty over plausibility' "$repo_root/agents/rules/operating-principles.md"
grep -q 'operating-principles.md' "$repo_root/agents/adapters/claude/CLAUDE.md.template"
grep -q 'operating-principles.md' "$repo_root/agents/prompts/platform-guardrails.md"
grep -q 'completion_needs_evidence' "$repo_root/agents/hooks/policy.py"
grep -q 'Treat secrets as toxic' "$repo_root/agents/prompts/platform-guardrails.md"
grep -q 'orchestrating-architecture-execution' "$repo_root/agents/manifests/skill-projections.tsv"
grep -q '~/.agents' "$repo_root/agents/adapters/claude/CLAUDE.md.template"
grep -q 'SUPERPOWERS_REPO' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/superpowers.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/brain-skill.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/llama.cpp.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/platform-observability-model.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/observability-engineering.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/platform-reliability-model.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/reliability-engineering.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/architectural-execution-skills.git' "$repo_root/scripts/install-skills.sh"
python3 - "$repo_root/scripts/install-skills.sh" <<'PY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
checks = [
    ("PLATFORM_OBSERVABILITY_MODEL_REPO|", "OBSERVABILITY_ENGINEERING_REPO|"),
    ("PLATFORM_RELIABILITY_MODEL_REPO|", "RELIABILITY_ENGINEERING_REPO|"),
]
for model_repo, skill_repo in checks:
    if text.index(model_repo) > text.index(skill_repo):
        raise SystemExit(f"{model_repo} must be refreshed before {skill_repo}")
PY
grep -q 'vendor_imports/repos/platform-observability-model' "$repo_root/agents/skills/platform/observability-engineering/SKILL.md"
grep -q 'references/observability-model-summary.md' "$repo_root/agents/skills/platform/observability-engineering/SKILL.md"
grep -q 'source-to-sink lineage' "$repo_root/agents/skills/platform/observability-engineering/SKILL.md"
grep -q 'Telemetry Pipeline Pattern' "$repo_root/agents/skills/platform/observability-engineering/references/observability-model-summary.md"
grep -q 'vendor_imports/repos/platform-reliability-model' "$repo_root/agents/skills/platform/reliability-engineering/SKILL.md"
grep -q 'references/reliability-model-summary.md' "$repo_root/agents/skills/platform/reliability-engineering/SKILL.md"
grep -q 'private platform observability/reliability model repos before installing their public engineering skills' "$repo_root/README.md"
grep -q 'multi_agent = true' "$repo_root/codex/config.example.toml"
grep -q 'https://github.com/obra/superpowers/blob/main/.codex/INSTALL.md' "$repo_root/docs/original-install-comparison.md"
grep -q 'agents/skills/platform' "$repo_root/docs/external-dependencies.md"
grep -q 'Agent-Agnostic Bootstrap' "$repo_root/docs/original-install-comparison.md"
grep -q 'Codebase Exploration Rules' "$repo_root/docs/decisions.md"
grep -q '~/.agents/vendor_imports' "$repo_root/docs/original-install-comparison.md"
grep -q '~/.agents/vendor_imports/repos/brain-skill' "$repo_root/docs/brain-skill-assessment.md"
grep -q '~/.agents/vendor_imports/repos/llama.cpp' "$repo_root/docs/brain-skill-smoke-test.md"
if grep -q '~/.codex/vendor_imports/' "$repo_root/docs/original-install-comparison.md"; then
  echo "stale ~/.codex/vendor_imports path remains in docs/original-install-comparison.md" >&2
  exit 1
fi
if grep -Fq 'Symlink `~/.agents/skills/superpowers` to `~/.codex/superpowers/skills`' "$repo_root/README.md"; then
  echo "README still claims Superpowers normally installs as a symlink" >&2
  exit 1
fi
grep -q 'diana-random1st/brain-skill' "$repo_root/scripts/refresh-github.sh"
grep -q 'ggml-org/llama.cpp' "$repo_root/scripts/refresh-github.sh"
grep -q 'gh auth setup-git' "$repo_root/scripts/refresh-github.sh"
grep -q 'gh auth setup-git' "$repo_root/scripts/install-skills.sh"
grep -q 'AGENTS_HOME' "$repo_root/scripts/install.sh"
grep -q 'AGENTS_HOME' "$repo_root/scripts/install-skills.sh"
grep -q 'validate_home_dir "AGENTS_HOME" "$AGENTS_HOME"' "$repo_root/scripts/install.sh"
grep -q 'validate_home_dir "AGENTS_HOME" "$AGENTS_HOME"' "$repo_root/scripts/install-skills.sh"
grep -q 'validate_home_dir "AGENTS_HOME" "$AGENTS_HOME"' "$repo_root/scripts/install-brain-prereqs.sh"
grep -q 'validate_home_dir "AGENTS_HOME" "$AGENTS_HOME"' "$repo_root/scripts/run-brain-mlx-smoke.sh"
grep -q 'validate_home_dir "CODEX_HOME" "$CODEX_HOME"' "$repo_root/scripts/install-brain-prereqs.sh"
grep -q 'validate_home_dir "CODEX_HOME" "$CODEX_HOME"' "$repo_root/scripts/run-brain-mlx-smoke.sh"
grep -q 'reject_symlink_path "$AGENTS_HOME" "AGENTS_HOME"' "$repo_root/scripts/install.sh"
grep -q 'reject_symlink_path "$AGENTS_HOME" "AGENTS_HOME"' "$repo_root/scripts/install-skills.sh"
grep -q 'reject_symlink_path "$AGENTS_HOME" "AGENTS_HOME"' "$repo_root/scripts/install-brain-prereqs.sh"
grep -q 'reject_symlink_path "$AGENTS_HOME" "AGENTS_HOME"' "$repo_root/scripts/run-brain-mlx-smoke.sh"
grep -q 'CLAUDE_HOME' "$repo_root/scripts/install-skills.sh"
grep -q 'CLAUDE_HOME' "$repo_root/scripts/install.sh"
grep -q '~/.claude/skills' "$repo_root/agents/adapters/claude/CLAUDE.md.template"
grep -q 'codebase-exploration.md' "$repo_root/agents/adapters/claude/CLAUDE.md.template"
grep -q 'AGENTS_HOME/rules' "$repo_root/scripts/install.sh"
grep -q 'install_tree "$repo_root/agents/hooks" "$AGENTS_HOME/hooks" "agent hooks"' "$repo_root/scripts/install.sh"
grep -q 'install_tree "$repo_root/agents/prompts" "$AGENTS_HOME/prompts" "agent prompts"' "$repo_root/scripts/install.sh"
grep -Fq 'find "$destination" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +' "$repo_root/scripts/install.sh"
grep -q 'canonical_hooks_source="$repo_root/agents/hooks"' "$repo_root/scripts/install.sh"
grep -q 'install_file "$canonical_hooks_source/policy.py" "$CODEX_HOME/hooks/policy.py" "Codex hook policy"' "$repo_root/scripts/install.sh"
grep -q '\.agents/skills' "$repo_root/scripts/install-skills.sh"
grep -q 'stage_skill_collection' "$repo_root/scripts/install-skills.sh"
grep -q 'clean_git_mirror' "$repo_root/scripts/install-skills.sh"
grep -Fq 'find "$destination" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +' "$repo_root/scripts/install-skills.sh"
if grep -q '"command"' "$repo_root/agents/hooks/policy.py"; then
  echo "canonical hook policy treats bare command wording as verification evidence" >&2
  exit 1
fi
for policy_file in \
  "$repo_root/agents/hooks/policy.py" \
  "$repo_root/agents/adapters/codex/hooks/policy.py" \
  "$repo_root/codex/hooks/policy.py"; do
  if grep -Eq '^[[:space:]]*"failed",$' "$policy_file"; then
    echo "hook policy treats failed checks as verification evidence: $policy_file" >&2
    exit 1
  fi
done
grep -q '\.agents/vendor_imports' "$repo_root/scripts/install-skills.sh"
grep -q 'AGENTS_HOME/vendor_imports/skills' "$repo_root/scripts/install-skills.sh"
grep -q 'AGENTS_HOME/vendor_imports/repos/llama.cpp' "$repo_root/scripts/install-skills.sh"
grep -q 'AGENTS_HOME/vendor_imports/repos/llama.cpp' "$repo_root/scripts/install-brain-prereqs.sh"
grep -q 'AGENTS_HOME/vendor_imports/repos/llama.cpp' "$repo_root/scripts/run-brain-mlx-smoke.sh"
grep -q 'agents_home/vendor_imports/repos/brain-skill' "$repo_root/scripts/test-brain-skill.sh"
for touched_script in \
  "$repo_root/scripts/install-skills.sh" \
  "$repo_root/scripts/install-brain-prereqs.sh" \
  "$repo_root/scripts/run-brain-mlx-smoke.sh" \
  "$repo_root/scripts/test-brain-skill.sh"; do
  if grep -Eq 'CODEX_HOME/vendor_imports/repos/(llama\.cpp|brain-skill)|codex_home/vendor_imports/repos/brain-skill' "$touched_script"; then
    echo "old CODEX_HOME vendor mirror path remains in $touched_script" >&2
    exit 1
  fi
done
grep -q 'prepare_canonical_destination' "$repo_root/scripts/install-skills.sh"
grep -q 'canonical Superpowers is installed as a real directory' "$repo_root/scripts/install-skills.sh"
grep -q 'platform-observability-model' "$repo_root/scripts/refresh-github.sh"
grep -q 'observability-engineering' "$repo_root/scripts/refresh-github.sh"
grep -q 'platform-reliability-model' "$repo_root/scripts/refresh-github.sh"
grep -q 'reliability-engineering' "$repo_root/scripts/refresh-github.sh"
grep -q 'architectural-execution-skills' "$repo_root/scripts/refresh-github.sh"
grep -q 'Outcome Score: 32/35' "$repo_root/docs/brain-skill-smoke-test.md"

brain_run_summary="$HOME/.codex/mlx/runs/k8s-risk-classifier/reports/run-summary.json"
if [ -f "$brain_run_summary" ] && ! grep -q '"sample_prediction": "destructive"' "$brain_run_summary"; then
  echo "brain MLX run summary exists but does not record the expected destructive sample prediction" >&2
  exit 1
fi

test -f "$repo_root/skills/superpowers/brainstorming/SKILL.md"
test -f "$repo_root/skills/superpowers/brainstorming/visual-companion.md"
test -f "$repo_root/skills/superpowers/brainstorming/spec-document-reviewer-prompt.md"
test -x "$repo_root/skills/superpowers/brainstorming/scripts/start-server.sh"
test -x "$repo_root/skills/superpowers/brainstorming/scripts/stop-server.sh"
grep -q '^name: brainstorming$' "$repo_root/skills/superpowers/brainstorming/SKILL.md"

skill_count="$(find "$repo_root/skills" -name SKILL.md | wc -l | tr -d ' ')"
if [ "$skill_count" -lt 40 ]; then
  echo "expected at least 40 vendored skills, found $skill_count" >&2
  exit 1
fi

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
for architectural_skill in \
  discovering-value-streams \
  modeling-c4-architecture \
  orchestrating-architecture-execution \
  reviewing-traceability \
  shaping-capabilities \
  shaping-features \
  slicing-stories; do
  for vendored_root in \
    "$repo_root/agents/skills/platform" \
    "$repo_root/agents/skills/codex-curated" \
    "$repo_root/skills/codex"; do
    if [ -e "$vendored_root/$architectural_skill/agents/openai.yaml" ]; then
      echo "stale architectural OpenAI metadata remains in $vendored_root/$architectural_skill" >&2
      exit 1
    fi
  done
done
architectural_source_repo="$HOME/.agents/vendor_imports/repos/architectural-execution-skills"
architectural_source_root="$architectural_source_repo/skills"
if [ -d "$architectural_source_root" ]; then
  if [ -n "$(git -C "$architectural_source_repo" status --porcelain)" ]; then
    echo "architectural execution skills source mirror has local changes; cannot verify drift" >&2
    exit 1
  fi
  for architectural_skill in \
    discovering-value-streams \
    modeling-c4-architecture \
    orchestrating-architecture-execution \
    reviewing-traceability \
    shaping-capabilities \
    shaping-features \
    slicing-stories; do
    for target_root in \
      "$repo_root/agents/skills/platform" \
      "$repo_root/agents/skills/codex-curated" \
      "$repo_root/skills/codex" \
      "$HOME/.agents/skills" \
      "$HOME/.codex/skills" \
      "$HOME/.claude/skills"; do
      if [ -d "$target_root" ] && ! diff -qr "$architectural_source_root/$architectural_skill" "$target_root/$architectural_skill" >/dev/null; then
        echo "architectural skill drift: $target_root/$architectural_skill differs from $architectural_source_root/$architectural_skill" >&2
        exit 1
      fi
    done
  done
fi
canonical_skill_count="$(find "$repo_root/agents/skills" -name SKILL.md | wc -l | tr -d ' ')"
if [ "$canonical_skill_count" -lt 40 ]; then
  echo "expected at least 40 canonical skills, found $canonical_skill_count" >&2
  exit 1
fi

for required in \
  "$repo_root/skills/codex/.system/openai-docs/SKILL.md" \
  "$repo_root/skills/codex/brain/SKILL.md" \
  "$repo_root/skills/codex/observability-engineering/SKILL.md" \
  "$repo_root/skills/codex/reliability-engineering/SKILL.md" \
  "$repo_root/skills/codex/orchestrating-architecture-execution/SKILL.md" \
  "$repo_root/skills/codex/discovering-value-streams/SKILL.md" \
  "$repo_root/skills/codex/shaping-capabilities/SKILL.md" \
  "$repo_root/skills/codex/shaping-features/SKILL.md" \
  "$repo_root/skills/codex/modeling-c4-architecture/SKILL.md" \
  "$repo_root/skills/codex/slicing-stories/SKILL.md" \
  "$repo_root/skills/codex/reviewing-traceability/SKILL.md" \
  "$repo_root/skills/plugins/github/yeet/SKILL.md" \
  "$repo_root/skills/plugins/google-drive/google-drive/SKILL.md" \
  "$repo_root/skills/superpowers/test-driven-development/SKILL.md"; do
  test -f "$required"
done

python3 "$repo_root/codex/hooks/codex_hook.py" UserPromptSubmit <<'JSON' >/tmp/platform-hook-test.out
{"session_id":"test","turn_id":"test","cwd":"/tmp","model":"test","permission_mode":"default","prompt":"please check production terraform reliability and logs"}
JSON

if ! grep -q "UserPromptSubmit" /tmp/platform-hook-test.out; then
  echo "Codex prompt hook smoke test did not emit expected context" >&2
  cat /tmp/platform-hook-test.out >&2
  exit 1
fi

rm -f /tmp/platform-hook-test.out

python3 "$repo_root/agents/adapters/codex/hooks/codex_hook.py" UserPromptSubmit <<'JSON' >/tmp/platform-adapter-hook-test.out
{"session_id":"test","turn_id":"test","cwd":"/tmp","model":"test","permission_mode":"default","prompt":"please check production terraform reliability and logs"}
JSON

if ! grep -q "UserPromptSubmit" /tmp/platform-adapter-hook-test.out; then
  echo "Codex adapter prompt hook smoke test did not emit expected context" >&2
  cat /tmp/platform-adapter-hook-test.out >&2
  exit 1
fi

rm -f /tmp/platform-adapter-hook-test.out

echo "[verify] ok"
