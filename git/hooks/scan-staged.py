#!/usr/bin/env python3
"""Inspect staged blobs in memory; never emit or persist their content."""

from pathlib import PurePosixPath
import re
import subprocess
import sys

# secret-scan: allow-patterns
SECRET_NAME = re.compile(r"(^|/)(\.env(?:\..*)?|id_rsa|id_ed25519|.*\.(?:pem|p12|pfx|key))$")
SECRET_CONTENT = re.compile(
    rb"-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9_]{20,}|"
    rb"sk-[A-Za-z0-9_-]{20,}|xox[baprs]-[A-Za-z0-9-]{20,}|"
    rb"https://hooks\.slack\.com/services/[A-Za-z0-9/]+|AKIA[0-9A-Z]{16}|"
    rb"(?i:api[_-]?key|secret|password|passwd|access[_-]?token|refresh[_-]?token|"
    rb"auth[_-]?token|github[_-]?token|slack[_-]?token)\s*[:=]\s*['\"]?[^'\":\s]{12,}"
)
CONFLICT = re.compile(rb"(?m)^(?:<<<<<<<|=======|>>>>>>>)")


def git(*args):
    result = subprocess.run(["git", *args], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    if result.returncode:
        raise RuntimeError("Cannot inspect staged files.")
    return result.stdout


def main():
    paths = git("diff", "--cached", "--name-only", "--diff-filter=ACMR", "-z").split(b"\0")
    gitlinks = {
        entry.split(b"\t", 1)[1]
        for entry in git("ls-files", "--stage", "-z").split(b"\0")
        if entry.startswith(b"160000 ")
    }
    failed = False
    for raw_path in filter(None, paths):
        if raw_path in gitlinks:
            # Submodule entries name commits, not staged file contents.
            continue
        path = raw_path.decode("utf-8", errors="surrogateescape")
        # Escape filenames: control characters must not become terminal instructions.
        label = ascii(path)
        parts = PurePosixPath(path).parts
        exempt_name = path.endswith((".example", ".sample", ".template")) or any(
            part in {"fixtures", "testdata"} for part in parts[:-1]
        )
        if SECRET_NAME.search(path) and not exempt_name:
            print(f"[global-hook] blocked likely secret file: {label}")
            failed = True
        blob = git("show", ":" + path)
        if CONFLICT.search(blob):
            print(f"[global-hook] conflict markers in {label}")
            failed = True
        # Pattern definitions are reviewed locally; this marker is not a security boundary.
        if b"secret-scan: allow-patterns" not in blob and SECRET_CONTENT.search(blob):
            print(f"[global-hook] blocked secret-like content in {label}")
            failed = True
        if len(blob) > 10485760:
            print(f"[global-hook] warning: staged file exceeds 10 MiB: {label}")
    return 1 if failed else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except RuntimeError:
        print("[global-hook] failed to inspect staged files", file=sys.stderr)
        sys.exit(1)
