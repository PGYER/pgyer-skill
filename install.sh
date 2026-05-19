#!/usr/bin/env bash
#
# install.sh — Claude-Code-only install. Copies this skill into
# ~/.claude/skills/pgyer.
#
# RECOMMENDED: use the open `skills` CLI instead — it supports 50+ agents
# (Claude Code, Cursor, Windsurf, Codex CLI, OpenCode, ...) with one command:
#
#   npx skills add PGYER/pgyer-skill -g
#
# This script is kept as a fallback for users who can't or don't want to
# use the CLI.
#
# Usage:
#   ./install.sh                # install into ~/.claude/skills/pgyer
#   ./install.sh /custom/path   # install into a custom location
#

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$HOME/.claude/skills/pgyer}"

if [[ ! -f "$SRC_DIR/SKILL.md" ]]; then
  echo "Error: SKILL.md not found in $SRC_DIR — run this from the skill repo root." >&2
  exit 1
fi

echo "Installing PGYER skill"
echo "  source: $SRC_DIR"
echo "  target: $TARGET"

if [[ -d "$TARGET" ]]; then
  echo "Target already exists. Overwrite? [y/N] "
  read -r reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
  rm -rf "$TARGET"
fi

mkdir -p "$(dirname "$TARGET")"
cp -R "$SRC_DIR" "$TARGET"

# Strip git metadata and install script from the installed copy.
rm -rf "$TARGET/.git" "$TARGET/install.sh"

chmod +x "$TARGET/scripts/pgyer_upload.sh" 2>/dev/null || true

echo
echo "✓ Installed to $TARGET"
echo
echo "Next steps:"
echo "  1. Set your API key (one of):"
echo "       export PGYER_API_KEY=<your key>"
echo "       echo 'api_key=<your key>' > ~/.pgyer/config && chmod 600 ~/.pgyer/config"
echo "     Get a key at https://www.pgyer.com/account/api"
echo
echo "  2. (Recommended) Install the official MCP server for nicer UX:"
echo "       claude mcp add --transport stdio pgyer \\"
echo "         --env PGYER_API_KEY=\$PGYER_API_KEY \\"
echo "         -- npx -y pgyer-mcp-server"
echo
echo "  3. Restart your Claude Code session and ask:"
echo "       \"List my PGYER apps\" or \"上传 app.apk 到蒲公英\""
