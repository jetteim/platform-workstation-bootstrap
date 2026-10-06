#!/usr/bin/env python3
"""Offline behavioral checks using disposable homes, repositories, and hook payloads."""

import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


CONFIG = module("configure_codex", ROOT / "scripts/configure-codex.py")
AUDIT = module("audit_local_state", ROOT / "scripts/audit-local-state.py")


def files(root):
    return {str(p.relative_to(root)): p.read_bytes() for p in root.rglob("*")
            if p.is_file() and "__pycache__" not in p.parts
            and p.name != ".DS_Store" and p.suffix != ".pyc"}


class HarnessTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="platform-harness-", dir="/tmp")
        self.work = Path(self.scratch.name)
        self.env = dict(os.environ, AGENTS_HOME=str(self.work / "agents"),
                        CODEX_HOME=str(self.work / "codex"), CLAUDE_HOME=str(self.work / "claude"),
                        GIT_HOOKS_HOME=str(self.work / "git-hooks"),
                        GIT_CONFIG_GLOBAL=str(self.work / "gitconfig"), GIT_CONFIG_NOSYSTEM="1",
                        SKIP_GITHUB_REFRESH="1", SKIP_SOURCE_REFRESH="1", USE_SOURCE_SKILLS="0")
        # Do not inherit Git repository redirection into disposable fixture commands.
        for key in ("GIT_DIR", "GIT_WORK_TREE", "GIT_INDEX_FILE", "GIT_COMMON_DIR"):
            self.env.pop(key, None)

    def tearDown(self):
        self.scratch.cleanup()

    def run_command(self, args, cwd=None, input=None):
        return subprocess.run(args, input=input, text=True, capture_output=True,
                              cwd=cwd or ROOT, env=self.env, timeout=90)

    def hook(self, event, payload):
        result = self.run_command([sys.executable, str(ROOT / "agents/adapters/codex/hooks/codex_hook.py"), event],
                                  input=json.dumps(payload))
        self.assertEqual(result.returncode, 0, "Hook failed on a supported payload")
        return json.loads(result.stdout) if result.stdout else {}

    def test_hook_decisions_and_bounded_stop(self):
        secret = "ghp_" + "fixture" * 6
        denied = self.hook("UserPromptSubmit", {"prompt": secret})
        self.assertEqual(denied["decision"], "block")
        self.assertNotIn(secret, json.dumps(denied))
        output = self.hook("PreToolUse", {"tool_input": {"command": "rm -rf /"}})
        self.assertEqual(output["hookSpecificOutput"]["permissionDecision"], "deny")
        self.assertEqual(self.hook("PreToolUse", {"tool_input": {"command": "git status --short"}}), {})
        self.assertIn("systemMessage", self.hook("PreToolUse", {"tool_input": {"command": "terraform apply"}}))
        self.assertEqual(self.hook("PostToolUse", {"tool_response": secret})["decision"], "block")
        self.assertEqual(self.hook("Stop", {"last_assistant_message": "Done"})["decision"], "block")
        self.assertTrue(self.hook("Stop", {"last_assistant_message": "Done", "stop_hook_active": True})["continue"])
        self.assertTrue(self.hook("Stop", {"last_assistant_message": "Done; verified checks passed"})["continue"])
        records = list((self.work / "codex/hook-logs").glob("*.jsonl"))
        self.assertTrue(records)
        for record in records:
            self.assertNotIn(secret, record.read_text())
            for line in record.read_text().splitlines():
                self.assertEqual(set(json.loads(line)), {"ts", "event", "decision", "reason", "invalid_payload"})
            self.assertEqual(record.stat().st_mode & 0o777, 0o600)

    def test_malformed_hook_input_and_session_context(self):
        for value in ("{invalid", "[]", "null", '"private fixture text"'):
            result = self.run_command([sys.executable, str(ROOT / "codex/hooks/codex_hook.py"), "PreToolUse"], input=value)
            self.assertEqual(result.returncode, 1)
            self.assertNotIn(value, result.stderr + result.stdout)
        prompt = self.work / "agents/prompts/platform-guardrails.md"
        prompt.parent.mkdir(parents=True)
        prompt.write_text("fixture guardrails")
        output = self.hook("SessionStart", {})
        self.assertEqual(output["hookSpecificOutput"]["additionalContext"].strip(), "fixture guardrails")
        config = json.loads((ROOT / "codex/hooks.json").read_text())
        self.assertIn("compact", config["hooks"]["SessionStart"][0]["matcher"].split("|"))

    def test_config_defaults_preserve_user_choices(self):
        home = self.work / "codex"
        text = ('model = "user-model"\n[features] # user preferences\nhooks = false\n'
                'multi_agent = false\n[other]\nhooks = false\nplugins = false\n'
                '[plugins."superpowers@openai-curated"]\nenabled = false\n'
                '[[skills.config]]\npath = ' + json.dumps(str(home / "skills/plugin-github/github/SKILL.md")) + '\nenabled = true\n')
        output = CONFIG.configure(text, home)
        parsed = CONFIG.parse(output)
        self.assertFalse(parsed["features"]["hooks"])
        self.assertFalse(parsed["features"]["multi_agent"])
        self.assertTrue(parsed["features"]["plugins"])
        self.assertEqual(parsed["other"], {"hooks": False, "plugins": False})
        self.assertFalse(parsed["plugins"]["superpowers@openai-curated"]["enabled"])
        self.assertTrue(parsed["skills"]["config"][0]["enabled"])
        self.assertEqual(CONFIG.configure(output, home), output)
        self.assertTrue(CONFIG.parse(CONFIG.configure("", home))["features"]["hooks"])
        self.assertTrue(CONFIG.parse(CONFIG.configure("[features]", home))["features"]["hooks"])
        legacy = '[mcp_servers.github]\ncommand = "npx"\nargs = ["-y", "@modelcontextprotocol/server-github"]\n'
        self.assertFalse(CONFIG.parse(CONFIG.configure(legacy, home))["mcp_servers"]["github"]["enabled"])
        explicit = legacy.replace('command =', 'enabled = true\ncommand =')
        self.assertTrue(CONFIG.parse(CONFIG.configure(explicit, home))["mcp_servers"]["github"]["enabled"])
        native_disabled = legacy + '[plugins."github@openai-curated"]\nenabled = false\n'
        self.assertNotIn("enabled", CONFIG.parse(CONFIG.configure(native_disabled, home))["mcp_servers"]["github"])
        with self.assertRaises(ValueError):
            CONFIG.configure("[features\n", home)

    def test_git_scanner_reads_index_and_keeps_content_private(self):
        repo = self.work / "repo"
        repo.mkdir()
        self.assertEqual(self.run_command(["git", "init", "-q"], cwd=repo).returncode, 0)
        path = repo / "file with\nnewline.txt"
        secret = "ghp_" + "fixture" * 6
        path.write_text(secret)
        self.assertEqual(self.run_command(["git", "add", "--", path.name], cwd=repo).returncode, 0)
        path.write_text("clean working tree content")
        result = self.run_command([sys.executable, str(ROOT / "git/hooks/scan-staged.py")], cwd=repo)
        self.assertEqual(result.returncode, 1)
        self.assertNotIn(secret, result.stdout + result.stderr)
        self.assertIn("\\n", result.stdout)
        self.assertFalse(list(self.work.glob("platform-hook-*")))
        self.run_command(["git", "add", "--", path.name], cwd=repo)
        self.assertEqual(self.run_command([sys.executable, str(ROOT / "git/hooks/scan-staged.py")], cwd=repo).returncode, 0)
        self.assertEqual(self.run_command(["git", "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                                          "commit", "-qm", "fixture"], cwd=repo).returncode, 0)
        commit = self.run_command(["git", "rev-parse", "HEAD"], cwd=repo).stdout.strip()
        self.assertEqual(self.run_command(["git", "update-index", "--add", "--cacheinfo", "160000", commit, "submodule"], cwd=repo).returncode, 0)
        self.assertEqual(self.run_command([sys.executable, str(ROOT / "git/hooks/scan-staged.py")], cwd=repo).returncode, 0)
        path.write_text("<<<<<<< fixture\nconflicting content\n")
        self.run_command(["git", "add", "--", path.name], cwd=repo)
        result = self.run_command([sys.executable, str(ROOT / "git/hooks/scan-staged.py")], cwd=repo)
        self.assertEqual(result.returncode, 1)
        self.assertNotIn("conflicting content", result.stdout + result.stderr)
        envfile = repo / ".env"
        envfile.write_text("fixture")
        self.run_command(["git", "add", "--", envfile.name], cwd=repo)
        self.assertEqual(self.run_command([sys.executable, str(ROOT / "git/hooks/scan-staged.py")], cwd=repo).returncode, 1)

    def test_install_offline_reinstall_and_pruning(self):
        first = self.run_command([str(ROOT / "scripts/install.sh")])
        self.assertEqual(first.returncode, 0, "Offline fixture install failed")
        codex = self.work / "codex"
        expected = files(ROOT / "skills/codex")
        for skill in ("google-sheets-chart-builder", "google-sheets-formula-builder",
                      "google-slides-import-presentation", "google-slides-template-migration",
                      "google-slides-template-surgery", "google-slides-visual-iteration"):
            expected.update({"plugin-google-drive/" + skill + "/" + key: value
                             for key, value in files(ROOT / "skills/plugins/google-drive" / skill).items()})
        self.assertEqual(files(codex / "skills"), expected)
        self.assertFalse(list((self.work / "agents/skills").iterdir()))
        stale = codex / "skills/brain/removed-reference.txt"
        stale.write_text("stale fixture")
        provider = codex / "skills/.system/provider-owned.txt"
        provider.write_text("runtime-managed fixture")
        config = codex / "config.toml"
        config.write_text(config.read_text().replace("hooks = true", "hooks = false"))
        second = self.run_command([str(ROOT / "scripts/install.sh")])
        self.assertEqual(second.returncode, 0, "Offline fixture reinstall failed")
        self.assertFalse(stale.exists())
        self.assertEqual(provider.read_text(), "runtime-managed fixture")
        self.assertFalse(CONFIG.parse(config.read_text())["features"]["hooks"])
        self.assertTrue((self.work / "git-hooks/scan-staged.py").is_file())
        self.assertIn(str(self.work / "git-hooks"), (self.work / "gitconfig").read_text())
        self.assertFalse((self.work / "claude/CLAUDE.md").exists())
        delegated = self.work / "project/.githooks/pre-commit"
        delegated.parent.mkdir(parents=True)
        delegated.write_text("#!/bin/sh\nexit 23\n")
        delegated.chmod(0o755)
        self.assertEqual(self.run_command(["git", "init", "-q"], cwd=delegated.parent.parent).returncode, 0)
        self.assertEqual(self.run_command([str(self.work / "git-hooks/pre-commit")], cwd=delegated.parent.parent).returncode, 23)

    def test_installer_rejects_unsafe_and_symlinked_destinations(self):
        original = self.env["AGENTS_HOME"]
        self.env["AGENTS_HOME"] = "/"
        result = self.run_command([str(ROOT / "scripts/install-skills.sh")])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing unsafe", result.stderr)
        self.env["AGENTS_HOME"] = original
        target = self.work / "untouched"
        target.mkdir()
        (self.work / "agents").symlink_to(target, target_is_directory=True)
        result = self.run_command([str(ROOT / "scripts/install.sh")])
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(list(target.iterdir()))

    def test_repo_projections_and_skill_metadata(self):
        curated = files(ROOT / "agents/skills/codex-curated")
        platform = files(ROOT / "agents/skills/platform")
        self.assertFalse(curated.keys() & platform.keys())
        self.assertEqual({**curated, **platform}, files(ROOT / "skills/codex"))
        self.assertEqual(files(ROOT / "skills/plugins"), files(ROOT / "agents/skills/plugins"))
        self.assertEqual(files(ROOT / "codex/hooks"), files(ROOT / "agents/adapters/codex/hooks"))
        for name in ("policy.py", "redact.py"):
            self.assertEqual((ROOT / "agents/hooks" / name).read_bytes(), (ROOT / "codex/hooks" / name).read_bytes())
        self.assertEqual((ROOT / "codex/hooks.json").read_bytes(), (ROOT / "agents/adapters/codex/hooks.json").read_bytes())
        self.assertEqual(CONFIG.parse((ROOT / "codex/config.example.toml").read_text()), CONFIG.parse((ROOT / "agents/adapters/codex/config.example.toml").read_text()))
        validator = module("validate_skill", ROOT / "skills/codex/.system/skill-creator/scripts/quick_validate.py")
        for path in (ROOT / "agents/skills/platform").glob("*/SKILL.md"):
            valid, _ = validator.validate_skill(path.parent)
            self.assertTrue(valid, "Invalid platform skill: " + path.parent.name)
        self.assertFalse((ROOT / "skills/superpowers").exists())

    def test_audit_allowlist_excludes_private_configuration(self):
        config = self.work / ".codex/config.toml"
        config.parent.mkdir()
        config.write_text('model = "gpt-6.1-sol"\n[features]\nhooks = true\n'
                          '[mcp_servers.fixture.env]\nCUSTOM = "private-fixture-value"\n')
        result = AUDIT.harness_inventory(self.work)
        self.assertNotIn("private-fixture-value", json.dumps(result))
        self.assertNotIn("mcp_servers", json.dumps(result))
        self.assertTrue(result["codex"]["features"]["hooks"])
        self.assertFalse(result["claude"]["user_instructions_present"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
