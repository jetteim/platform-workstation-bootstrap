#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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
grep -q 'SUPERPOWERS_REPO' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/superpowers.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/brain-skill.git' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/llama.cpp.git' "$repo_root/scripts/install-skills.sh"
grep -q 'multi_agent = true' "$repo_root/codex/config.example.toml"
grep -q 'https://github.com/obra/superpowers/blob/main/.codex/INSTALL.md' "$repo_root/docs/original-install-comparison.md"
grep -q 'diana-random1st/brain-skill' "$repo_root/scripts/refresh-github.sh"
grep -q 'ggml-org/llama.cpp' "$repo_root/scripts/refresh-github.sh"
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

for required in \
  "$repo_root/skills/codex/.system/openai-docs/SKILL.md" \
  "$repo_root/skills/codex/brain/SKILL.md" \
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

echo "[verify] ok"
