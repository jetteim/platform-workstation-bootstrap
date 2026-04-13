# Secrets And Safety Rules

- Treat secrets as toxic: do not print, quote, persist, or commit them.
- Do not read credential files unless the user explicitly asks and the action is necessary.
- Block obvious credential exfiltration and private key exposure.
- Ask before destructive filesystem or infrastructure actions when there is no dry-run evidence.
