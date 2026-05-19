# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `docs/use-with-other-agents.md` — guide for using this skill in Cursor,
  Windsurf, Codex CLI, Cline, Continue, Roo Code, and custom Anthropic
  Agent SDK setups. Documents the universal pattern (install
  `pgyer-mcp-server` via MCP, paste `SKILL.md` body into the tool's
  rules/instructions slot, fall back to `scripts/pgyer_upload.sh` for
  anything beyond the three MCP tools) plus tool-specific config paths.
- README sections (zh / en) linking to the new cross-agent guide.

## [0.2.0] - 2026-05-20

### Added
- iOS GitHub Actions template (`examples/github-actions/ios.yml`) — macOS
  runner, base64-encoded signing materials, `xcodebuild archive`/`exportArchive`,
  with a commented "with password" block showing the shell-script swap.
- HarmonyOS GitHub Actions template (`examples/github-actions/harmony.yml`) —
  self-hosted-runner build via `hvigorw`, plus an upload-only fallback for
  teams without a HarmonyOS-capable runner.
- GitLab CI templates for Android and iOS (`examples/gitlab-ci/*.yml`),
  using the bundled shell script (no official GitLab plugin exists).
- `examples/fastlane/README.md` — points users at the official
  `fastlane-plugin-pgyer` rather than bundling a copy, with a minimal
  `Fastfile` example.
- (CI platform × target OS) decision matrix in `SKILL.md` so the assistant
  picks the right template from a single lookup.
- Callout in the CI section: any upload parameter beyond `filePath` cannot
  use `PGYER/pgyer-upload-app-action` and must fall back to
  `scripts/pgyer_upload.sh`.
- Explicit `~/.pgyer/config` write recipe in the Credentials section.

### Changed
- Reorganised `examples/` from a flat layout to `<platform>/<os>.yml`.
  `examples/github-actions.yml` moved to `examples/github-actions/android.yml`.
- Capability map: relabelled the `app/view` row from "Shell / curl" to "curl"
  (no shell wrapper exists for that endpoint).
- Intro no longer duplicates the MCP-vs-script routing logic; it now points
  readers to the Capability map as the single source of truth.

### Fixed
- `examples/gitlab-ci/{android,ios}.yml`: `needs: [build:apk]` / `[build:ipa]`
  quoted so strict YAML parsers accept colon-grouped job names.
- `reference/mcp-tools.md`: "Buildhistory" → "Build history".

## [0.1.0] - 2026-05-19

### Added
- Initial skill release.
- `SKILL.md` defining the MCP-first / shell-script-fallback decision model
  and capability map.
- Three reference docs: `mcp-tools.md` (official MCP tool schemas and
  limitations), `api-cheatsheet.md` (raw HTTP endpoints for `app/listMy`,
  `app/getByShortcut`, `app/view`, two-step COS upload), `troubleshooting.md`
  (error codes, domain failover, signing issues).
- `scripts/pgyer_upload.sh`: bundled verbatim from upstream
  `PGYER/upload-app-api-example`, handles multi-domain failover, DoH DNS,
  large-file streaming, and all optional upload parameters.
- Android GitHub Actions example.
- `install.sh` for one-step deployment to `~/.claude/skills/pgyer/`.
- Bilingual (Chinese / English) README.
- End-to-end validation in a fresh Claude Code session (6/6 prompt-routing
  tests passing).
