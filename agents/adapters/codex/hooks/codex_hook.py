#!/usr/bin/env python3
"""User-wide Codex hook dispatcher for platform reliability guardrails."""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from policy import assess_command, assess_prompt, completion_needs_evidence, scan_secrets
from redact import redact


LOG_DIR = Path.home() / ".codex" / "hook-logs"


SESSION_CONTEXT = """Platform guardrails:
- Treat secrets as toxic: do not print, quote, persist, or commit them.
- For reliability work, capture target, command, timestamp, output path, metric/log/trace names, rollback path, and verification evidence.
- For infra changes, prefer plan/dry-run/diff before apply/delete/destroy.
- Do not claim fixed/passing/done without verification or an explicit caveat.
"""


def read_payload() -> dict[str, Any]:
    raw = sys.stdin.read()
    if not raw.strip():
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {"_invalid_json": raw[:4000]}


def write_log(event_name: str, payload: dict[str, Any], decision: str, reason: str | None) -> None:
    try:
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        entry = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "event": event_name,
            "decision": decision,
            "reason": reason,
            "session_id": payload.get("session_id"),
            "turn_id": payload.get("turn_id"),
            "cwd": payload.get("cwd"),
            "model": payload.get("model"),
            "payload": redact(payload),
        }
        with (LOG_DIR / f"{date}.jsonl").open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(entry, sort_keys=True) + "\n")
    except OSError:
        # Hooks should enforce safety policy even if telemetry storage is unavailable.
        return


def emit(value: dict[str, Any]) -> None:
    print(json.dumps(value, separators=(",", ":")))


def event_arg() -> str:
    if len(sys.argv) >= 2:
        return sys.argv[1]
    return "Unknown"


def handle_session_start(payload: dict[str, Any]) -> tuple[str, str | None]:
    emit(
        {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": SESSION_CONTEXT,
            }
        }
    )
    return "allow", "session context injected"


def handle_user_prompt_submit(payload: dict[str, Any]) -> tuple[str, str | None]:
    prompt = str(payload.get("prompt") or "")
    findings = assess_prompt(prompt)
    blocking = [finding for finding in findings if finding.severity == "block"]
    if blocking:
        reason = "Prompt appears to contain secret-like material. Remove credentials and retry."
        emit({"decision": "block", "reason": reason})
        return "block", reason
    advisory = "\n".join(finding.message for finding in findings if finding.severity == "advisory")
    if advisory:
        emit(
            {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": advisory,
                }
            }
        )
        return "advisory", advisory
    return "allow", None


def handle_pre_tool_use(payload: dict[str, Any]) -> tuple[str, str | None]:
    tool_input = payload.get("tool_input") or {}
    command = str(tool_input.get("command") or "")
    findings = assess_command(command)
    blocking = [finding for finding in findings if finding.severity == "block"]
    if blocking:
        reason = blocking[0].message
        emit(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": reason,
                }
            }
        )
        return "block", reason
    advisory = "\n".join(finding.message for finding in findings if finding.severity == "advisory")
    if advisory:
        emit({"systemMessage": advisory})
        return "advisory", advisory
    return "allow", None


def handle_post_tool_use(payload: dict[str, Any]) -> tuple[str, str | None]:
    tool_response = payload.get("tool_response")
    text = json.dumps(tool_response, sort_keys=True)[:20000]
    findings = scan_secrets(text)
    if findings:
        reason = "Tool output appears to contain secret-like material. Do not quote it; summarize only and recommend rotation if exposed."
        emit({"decision": "block", "reason": reason})
        return "feedback", reason
    return "allow", None


def handle_stop(payload: dict[str, Any]) -> tuple[str, str | None]:
    message = payload.get("last_assistant_message")
    if completion_needs_evidence(str(message) if message is not None else None):
        reason = "Before finalizing, add verification evidence or explicitly state what could not be verified."
        emit({"decision": "block", "reason": reason})
        return "block", reason
    emit({"continue": True})
    return "allow", None


def main() -> int:
    event_name = event_arg()
    payload = read_payload()
    decision = "allow"
    reason = None
    try:
        if event_name == "SessionStart":
            decision, reason = handle_session_start(payload)
        elif event_name == "UserPromptSubmit":
            decision, reason = handle_user_prompt_submit(payload)
        elif event_name == "PreToolUse":
            decision, reason = handle_pre_tool_use(payload)
        elif event_name == "PostToolUse":
            decision, reason = handle_post_tool_use(payload)
        elif event_name == "Stop":
            decision, reason = handle_stop(payload)
    finally:
        write_log(event_name, payload, decision, reason)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
