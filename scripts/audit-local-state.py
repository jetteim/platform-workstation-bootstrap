#!/usr/bin/env python3
"""Read installed state without exporting credentials, config values, or user data."""

import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
from datetime import datetime, timezone


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
        "exclusions": [
            "credentials, auth databases, sessions, browser state, receipt data",
            "live config values (reviewed separately through an explicit allowlist)",
            "plugin enabled status: cache presence alone does not establish activation",
            "source-mirror uncommitted contents (only commit and dirty status recorded)",
        ],
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    # Avoid package index refreshes; this audit only needs installed state.
    os.environ["HOMEBREW_NO_AUTO_UPDATE"] = "1"
    os.environ["HOMEBREW_NO_INSTALL_FROM_API"] = "1"
    main()
