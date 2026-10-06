# Codex Adapter

Codex receives rules and hook assets from the canonical `~/.agents` layer, and keeps active skills in Codex-native locations.

- Local platform/document/helper skills install to `~/.codex/skills`.
- GitHub, Superpowers, and core Google Drive skills come from native Codex plugins.
- Hook config projects to `~/.codex/hooks.json`.
- Hook dispatcher files project to `~/.codex/hooks`.
- Feature flags are maintained in `~/.codex/config.toml`.

Hook definitions require review and trust through `/hooks`. The bootstrap does not copy trust state. Session context is restored after compaction; Stop feedback is bounded to one continuation. Logs store decision metadata only.

Skill snapshots are reviewed in this repo. `USE_SOURCE_SKILLS=1` opts into clean source-mirror versions; `SKIP_SOURCE_REFRESH=1` prevents source refresh. Explicit feature and plugin choices survive reinstall.
