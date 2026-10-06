#!/usr/bin/env python3
"""Read installed state without exporting credentials, config values, or user data."""

import hashlib
import json
import os
import re
from pathlib import Path
import subprocess
import sys
from datetime import datetime, timezone


def load_toml(path):
    try:
        import tomllib as parser
    except ImportError:
        try:
            from pip._vendor import tomli as parser
        except ImportError:
            # macOS system Python can lack both; do not substitute an ad-hoc parser.
            return None
    return parser.loads(path.read_text()) if path.exists() else {}


def harness_inventory(home):
    config = load_toml(home / ".codex/config.toml")
    codex = {
        "config_parse_available": config is not None,
        "user_instructions_present": any((home / ".codex" / name).is_file()
                                         for name in ("AGENTS.md", "AGENTS.override.md")),
        "hooks_config_present": (home / ".codex/hooks.json").is_file(),
    }
    if config is not None:
        # Deliberately exclude env, arguments, URLs, paths, approvals, trust hashes,
        # transcripts, and arbitrary custom fields from live configuration.
        model = config.get("model")
        if isinstance(model, str) and re.fullmatch(r"[a-z0-9.-]{1,80}", model):
            codex["model"] = model
        effort = config.get("model_reasoning_effort")
        if effort in {"minimal", "low", "medium", "high", "xhigh", "max", "ultra"}:
            codex["model_reasoning_effort"] = effort
        codex["features"] = {k: v for k, v in config.get("features", {}).items()
                             if k in {"hooks", "multi_agent", "plugins"} and isinstance(v, bool)}
        codex["native_plugins_enabled"] = {
            name: config.get("plugins", {}).get(name, {}).get("enabled")
            for name in ("github@openai-curated", "google-drive@openai-curated", "superpowers@openai-curated")
            if isinstance(config.get("plugins", {}).get(name, {}).get("enabled"), bool)
        }
        codex["mcp_enabled"] = {
            name: config.get("mcp_servers", {}).get(name, {}).get("enabled", True)
            for name in ("github", "memory", "playwright", "zenmoney-receipts")
            if name in config.get("mcp_servers", {})
            and isinstance(config["mcp_servers"][name].get("enabled", True), bool)
        }
    return {
        "codex": codex,
        "claude": {
            "user_instructions_present": (home / ".claude/CLAUDE.md").is_file(),
            "rule_template_present": (home / ".claude/CLAUDE.md.template").is_file(),
            "settings_present": (home / ".claude/settings.json").is_file(),
        },
    }


def run(*args):
    # Never echo command output on errors: package managers may include private URLs.
    result = subprocess.run(args, capture_output=True, text=True, timeout=60)
    if result.returncode:
        raise RuntimeError(f"{args[0]} inventory failed (exit {result.returncode})")
    return result.stdout.strip()


def tree_digest(root):
    digest = hashlib.sha256()
    count = 0
    for path in sorted(root.rglob("*")):
        if not path.is_file() or any(
            part in {"__pycache__", ".DS_Store", ".git"} for part in path.parts
        ) or path.suffix == ".pyc":
            continue
        digest.update(str(path.relative_to(root)).encode() + b"\0")
        digest.update(hashlib.sha256(path.read_bytes()).digest())
        count += 1
    return {"files": count, "sha256": digest.hexdigest()}


def skill_inventory(root):
    return {
        str(path.parent.relative_to(root)): tree_digest(path.parent)
        for path in sorted(root.rglob("SKILL.md"))
    }


def main():
    home = Path.home()
    brew_prefix = Path(run("brew", "--prefix"))
    # Read installed receipts, so an invalid current cask definition cannot hide an install.
    casks = {}
    for path in sorted((brew_prefix / "Caskroom").iterdir()):
        if path.is_dir() and not path.name.startswith("."):
            casks[path.name] = sorted(
                p.name for p in path.iterdir() if p.is_dir() and not p.name.startswith(".")
            )
    npm = json.loads(run("npm", "ls", "-g", "--depth=0", "--json"))
    plugins = {}
    for marketplace in sorted((home / ".codex/plugins/cache").iterdir()):
        for plugin in sorted(marketplace.iterdir()):
            for version in sorted(plugin.iterdir()):
                if version.is_dir() and not version.name.startswith("."):
                    plugins[f"{marketplace.name}/{plugin.name}/{version.name}"] = (
                        skill_inventory(version / "skills")
                    )
    mirrors = {}
    mirror_root = home / ".agents/vendor_imports"
    for path in [mirror_root / "skills", *sorted((mirror_root / "repos").iterdir())]:
        if (path / ".git").exists():
            mirrors[str(path.relative_to(mirror_root))] = {
                "commit": run("git", "-C", str(path), "rev-parse", "HEAD"),
                "dirty": bool(run("git", "-C", str(path), "status", "--porcelain")),
            }
    npx_packages = {}
    wanted = {"@playwright/mcp", "@modelcontextprotocol/server-memory",
              "@modelcontextprotocol/server-github"}
    for path in sorted((home / ".npm/_npx").glob("*/node_modules/@*/*/package.json")):
        package = json.loads(path.read_text())
        if package.get("name") in wanted:
            npx_packages.setdefault(package["name"], set()).add(package["version"])
    result = {
        "observed_at": datetime.now(timezone.utc).isoformat(),
        "source_of_truth": "installed local workstation state",
        "harnesses": harness_inventory(home),
        "brew_formulae": run("brew", "list", "--formula", "--versions").splitlines(),
        "brew_casks_from_installed_directories": casks,
        "npm_global": {k: v["version"] for k, v in sorted(npm["dependencies"].items())},
        "pip_user": run(sys.executable, "-m", "pip", "list", "--user", "--format=freeze").splitlines(),
        "npx_cached_versions": {k: sorted(v) for k, v in sorted(npx_packages.items())},
        "codex_local_skills": skill_inventory(home / ".codex/skills"),
        "claude_local_skills": skill_inventory(home / ".claude/skills"),
        "plugin_cache_skills": plugins,
        "source_mirrors": mirrors,
        "managed_files": {
            name: tree_digest(home / name)
            for name in [".agents/rules", ".agents/hooks", ".agents/prompts", ".codex/hooks"]
        },
        "agents_skills_empty": not any((home / ".agents/skills").iterdir()),
        "legacy_superpowers_checkout_present": (home / ".codex/superpowers").exists(),
        "git_hooks_path": run("git", "config", "--global", "core.hooksPath").replace(str(home), "~"),
        "git_pre_commit_sha256": hashlib.sha256(
            (home / ".config/git/hooks/pre-commit").read_bytes()
        ).hexdigest(),
        "git_staged_scanner_present": (home / ".config/git/hooks/scan-staged.py").is_file(),
        "exclusions": [
            "credentials, auth databases, sessions, browser state, receipt data",
            "live config values except allowlisted model, effort, feature flags, known native plugin booleans, and known MCP enabled flags",
            "remote plugin activation, hook trust, and session exposure: cache presence does not establish these",
            "source-mirror uncommitted contents (only commit and dirty status recorded)",
        ],
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    # Avoid package index refreshes; this audit only needs installed state.
    os.environ["HOMEBREW_NO_AUTO_UPDATE"] = "1"
    os.environ["HOMEBREW_NO_INSTALL_FROM_API"] = "1"
    main()
