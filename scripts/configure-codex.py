#!/usr/bin/env python3
"""Add bootstrap defaults without replacing explicit user configuration."""

import json
from pathlib import Path
import re
import sys


def parse(text):
    try:
        import tomllib as parser
    except ImportError:
        from pip._vendor import tomli as parser
    return parser.loads(text)


def add_defaults(text, header, values):
    if not values:
        return text
    pattern = re.compile(r"(?ms)^" + re.escape(header) + r"[^\S\n]*(?:#[^\n]*)?(?:\n|$)(.*?)(?=^\s*\[|\Z)")
    match = pattern.search(text)
    if not match:
        return text.rstrip() + "\n\n" + header + "\n" + "".join(
            f"{key} = {value}\n" for key, value in values.items()
        )
    missing = "".join(
        f"{key} = {value}\n" for key, value in values.items()
        if not re.search(r"(?m)^\s*" + re.escape(key) + r"\s*=", match.group(1))
    )
    prefix = text[:match.start(1)]
    if missing and not prefix.endswith("\n"):
        prefix += "\n"
    return prefix + missing + text[match.start(1):]


def configure(text, codex_home):
    existing = parse(text)
    text = add_defaults(text, "[features]", {
        k: "true" for k in ("hooks", "multi_agent", "plugins")
        if k not in existing.get("features", {})
    })
    for plugin in ("github", "google-drive", "superpowers"):
        if "enabled" not in existing.get("plugins", {}).get(f"{plugin}@openai-curated", {}):
            text = add_defaults(text, f'[plugins."{plugin}@openai-curated"]', {"enabled": "true"})
    github = existing.get("mcp_servers", {}).get("github", {})
    native_github_enabled = existing.get("plugins", {}).get("github@openai-curated", {}).get("enabled", True)
    if (native_github_enabled is True and github.get("command") == "npx" and "enabled" not in github
            and any(isinstance(arg, str) and re.fullmatch(r"@modelcontextprotocol/server-github(?:@[^\s]+)?", arg)
                    for arg in github.get("args", []))):
        # The archived reference server duplicates the native GitHub integration.
        text = add_defaults(text, "[mcp_servers.github]", {"enabled": "false"})
    for skill in ("gh-fix-ci", "github", "gh-address-comments"):
        path = str(codex_home / "skills/plugin-github" / skill / "SKILL.md")
        # Retain an existing explicit choice even when it differs from the default.
        if any(item.get("path") == path for item in existing.get("skills", {}).get("config", [])):
            continue
        text += f'\n[[skills.config]]\npath = {json.dumps(path)}\nenabled = false\n'
    # Validate before the caller writes. Unsupported table spellings fail safely.
    parse(text)
    return text.lstrip("\n")


if __name__ == "__main__":
    path = Path(sys.argv[1])
    original = path.read_text() if path.exists() else ""
    updated = configure(original, path.parent)
    if updated != original:
        path.write_text(updated)
