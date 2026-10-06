#!/usr/bin/env python3
"""Resolve an explicitly selected or local model/generator without I/O side effects."""
import argparse
import json
import os
from pathlib import Path

MODEL_NAME = 'platform-reliability-model'
MODEL_ENV = 'RELIABILITY_MODEL_ROOT'

def resolve(kind, root=None, workspace_root=None, environ=None, home=None, cwd=None):
    env = os.environ if environ is None else environ
    home = Path.home() if home is None else Path(home)
    name = "slo-rules-engine" if kind == "engine" else MODEL_NAME
    variable = "SRE_RULES_ENGINE_ROOT" if kind == "engine" else MODEL_ENV
    explicit = root or env.get(variable)
    def valid(p):
        return (p / "docs").is_dir() if kind == "model" else ((p / "bin/rules-ctl").is_file() and os.access(p / "bin/rules-ctl", os.X_OK))
    if explicit:
        p = Path(explicit).expanduser().resolve()
        return {"ok": valid(p), "kind": kind, "source": "explicit", "root": str(p), "fallback": False}
    managed = Path(env.get("AGENTS_HOME", str(home / ".agents"))).expanduser()
    workspace = Path(workspace_root or cwd or Path.cwd())
    for p in [managed / "vendor_imports/repos" / name, workspace / name, home / "Library/CloudStorage/OneDrive-Personal/Pet projects" / name]:
        if valid(p):
            return {"ok": True, "kind": kind, "source": "local-checkout", "root": str(p.resolve()), "fallback": False}
    return {"ok": kind == "model", "kind": kind, "source": "bundled-reference" if kind == "model" else "unavailable", "root": None, "fallback": kind == "model"}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kind", choices=["model", "engine"], default="model")
    parser.add_argument("--root")
    parser.add_argument("--workspace-root")
    args = parser.parse_args()
    result = resolve(args.kind, args.root, args.workspace_root)
    print(json.dumps(result))
    return 0 if result["ok"] else 2

if __name__ == "__main__":
    raise SystemExit(main())
