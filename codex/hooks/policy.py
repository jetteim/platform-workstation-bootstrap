"""Policy checks for platform workstation Codex hooks.

secret-scan: allow-patterns
"""

from __future__ import annotations

import re
from dataclasses import dataclass


@dataclass(frozen=True)
class Finding:
    kind: str
    severity: str
    message: str


SECRET_REGEXES = [
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{20,}\b"),
    re.compile(r"\bsk-[A-Za-z0-9_-]{20,}\b"),
    re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{20,}\b"),
    re.compile(r"https://hooks\.slack\.com/services/[A-Za-z0-9/]+"),
    re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    re.compile(r"(?i)(api[_-]?key|secret|token|password|passwd)\s*[:=]\s*['\"]?[^'\"\s]{12,}"),
]

DANGEROUS_COMMAND_REGEXES = [
    re.compile(r"(^|[;&|]\s*)rm\s+-[^\n;]*r[^\n;]*f[^\n;]*(\s+/|\s+\$HOME|\s+~)(\s|$)"),
    re.compile(r"\bchmod\s+-R\s+777\b"),
    re.compile(r"\bchown\s+-R\b\s+\S+\s+(/|~|\$HOME)\b"),
    re.compile(r"\bdd\s+if=/dev/(zero|random|urandom)\s+of=/dev/(disk|rdisk)"),
    re.compile(r"\bmkfs(\.\w+)?\b"),
    re.compile(r"\b(cat|sed|awk|grep|rg)\b[^\n;]*(~/.ssh/id_|~/.codex/auth\.json|~/.config/gh/hosts\.yml|\.env(\.|$))"),
    re.compile(r"\b(curl|wget)\b[^\n;]*(~/.ssh/id_|~/.codex/auth\.json|~/.config/gh/hosts\.yml|\.env(\.|$))"),
]

ADVISORY_COMMAND_REGEXES = [
    re.compile(r"\bterraform\s+(apply|destroy)\b"),
    re.compile(r"\bkubectl\s+delete\b"),
    re.compile(r"\bhelm\s+(uninstall|delete)\b"),
    re.compile(r"\baws\b.*\bdelete\b"),
    re.compile(r"\bgcloud\b.*\bdelete\b"),
    re.compile(r"\baz\b.*\bdelete\b"),
]


def scan_secrets(text: str) -> list[Finding]:
    findings: list[Finding] = []
    for pattern in SECRET_REGEXES:
        if pattern.search(text):
            findings.append(
                Finding(
                    kind="secret",
                    severity="block",
                    message="High-confidence secret-like material detected.",
                )
            )
            break
    return findings


def assess_prompt(prompt: str) -> list[Finding]:
    findings = scan_secrets(prompt)
    lowered = prompt.lower()
    if "bypass approvals" in lowered or "disable safety" in lowered:
        findings.append(
            Finding(
                kind="prompt_policy",
                severity="advisory",
                message="Prompt asks to bypass safety. Keep approval and verification discipline explicit.",
            )
        )
    if any(term in lowered for term in ["production", "prod", "terraform", "kubectl", "incident"]):
        findings.append(
            Finding(
                kind="reliability_context",
                severity="advisory",
                message="For platform work, capture target, blast radius, rollback path, and verification evidence.",
            )
        )
    return findings


def assess_command(command: str) -> list[Finding]:
    findings = scan_secrets(command)
    for pattern in DANGEROUS_COMMAND_REGEXES:
        if pattern.search(command):
            findings.append(
                Finding(
                    kind="dangerous_command",
                    severity="block",
                    message="Command matches a high-risk destructive or secret-exfiltration pattern.",
                )
            )
            break
    for pattern in ADVISORY_COMMAND_REGEXES:
        if pattern.search(command):
            findings.append(
                Finding(
                    kind="infra_change",
                    severity="advisory",
                    message="Infrastructure-changing command detected. Prefer plan/dry-run, identify target, and capture rollback.",
                )
            )
            break
    return findings


def completion_needs_evidence(message: str | None) -> bool:
    if not message:
        return False
    lowered = message.lower()
    claims_success = any(word in lowered for word in ["done", "fixed", "passing", "complete", "implemented"])
    cites_evidence = any(
        phrase in lowered
        for phrase in [
            "tested",
            "verified",
            "ran ",
            "command",
            "checks",
            "not run",
            "could not run",
            "unable to run",
        ]
    )
    return claims_success and not cites_evidence
