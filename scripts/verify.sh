#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m py_compile "$repo_root/codex/hooks/codex_hook.py" "$repo_root/codex/hooks/policy.py" "$repo_root/codex/hooks/redact.py"
bash -n "$repo_root/scripts/refresh-github.sh"
bash -n "$repo_root/scripts/install-skills.sh"
bash -n "$repo_root/scripts/install.sh"
bash -n "$repo_root/scripts/verify.sh"
bash -n "$repo_root/git/hooks/pre-commit"

test -f "$repo_root/docs/original-install-comparison.md"
grep -q 'SUPERPOWERS_REPO' "$repo_root/scripts/install-skills.sh"
grep -q 'https://github.com/jetteim/superpowers.git' "$repo_root/scripts/install-skills.sh"
grep -q 'multi_agent = true' "$repo_root/codex/config.example.toml"
grep -q 'https://github.com/obra/superpowers/blob/main/.codex/INSTALL.md' "$repo_root/docs/original-install-comparison.md"

test -f "$repo_root/skills/superpowers/brainstorming/SKILL.md"
test -f "$repo_root/skills/superpowers/brainstorming/visual-companion.md"
test -f "$repo_root/skills/superpowers/brainstorming/spec-document-reviewer-prompt.md"
test -x "$repo_root/skills/superpowers/brainstorming/scripts/start-server.sh"
test -x "$repo_root/skills/superpowers/brainstorming/scripts/stop-server.sh"
grep -q '^name: brainstorming$' "$repo_root/skills/superpowers/brainstorming/SKILL.md"

skill_count="$(find "$repo_root/skills" -name SKILL.md | wc -l | tr -d ' ')"
if [ "$skill_count" -lt 39 ]; then
  echo "expected at least 39 vendored skills, found $skill_count" >&2
  exit 1
fi

for required in \
  "$repo_root/skills/codex/.system/openai-docs/SKILL.md" \
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
