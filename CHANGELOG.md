# Changelog

All notable changes to this skill are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed
- **Repositioned as a general-purpose Agent Skill.** README, SKILL.md
  references, and docs now describe the project as supporting Claude Code +
  Cursor + Windsurf + Codex CLI + OpenCode + 50+ other agents via the open
  [`skills`](https://github.com/vercel-labs/skills) CLI, rather than as a
  Claude-Code-only skill.
- README primary install method is now `npx skills add PGYER/pgyer-skill`.
  The `git clone + install.sh` flow is demoted to a fallback (still
  supported, with a comment in `install.sh` pointing at the CLI).
- Renamed `reference/` → `references/` (plural) to match the broader
  skills ecosystem convention. SKILL.md, `docs/use-with-other-agents.md`,
  and `examples/fastlane/README.md` updated. `git mv` preserves history.
- Rewrote `docs/use-with-other-agents.md` to lead with `npx skills add -a <agent>`
  per-agent invocations. Kept manual-install fallback for agents not yet in
  the CLI registry, kept the Anthropic Agent SDK custom-code section, kept
  the shell-script-only fallback.

### Added
- README `skills.sh` badge linking to https://skills.sh/PGYER/pgyer-skill.
- README sections (zh / en) plus `docs/use-with-other-agents.md` covering
  use of this skill across Cursor, Windsurf, Codex CLI, Cline, Continue,
  Roo Code, and custom Anthropic Agent SDK setups.

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
