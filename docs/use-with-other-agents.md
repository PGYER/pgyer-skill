# Using the PGYER skill in other AI agents

This skill is agent-agnostic. The
[`skills`](https://github.com/vercel-labs/skills) CLI installs it into 50+
AI agents (Claude Code, Cursor, Windsurf, Codex CLI, OpenCode, Gemini,
and more) with a single command. This page documents the per-tool entry
points plus the deeper customisation paths (manual install, custom Agent
SDK code, shell-only fallback).

## Quick install per agent (recommended)

`npx skills add` is the canonical install. It clones this repo and
links/copies the skill into the right per-agent location automatically.

```bash
# Auto-detect installed agents (default)
npx skills add PGYER/pgyer-skill -g

# Target one specific agent
npx skills add PGYER/pgyer-skill -g -a claude-code
npx skills add PGYER/pgyer-skill -g -a cursor
npx skills add PGYER/pgyer-skill -g -a codex
npx skills add PGYER/pgyer-skill -g -a windsurf
npx skills add PGYER/pgyer-skill -g -a opencode
npx skills add PGYER/pgyer-skill -g -a gemini

# Target multiple agents in one call
npx skills add PGYER/pgyer-skill -g -a claude-code -a cursor

# Per-project install (committed with the repo, shared with team)
cd /path/to/your/project
npx skills add PGYER/pgyer-skill
```

Full agent list and CLI documentation: https://github.com/vercel-labs/skills

## Install the PGYER MCP server (orthogonal, also recommended)

Cleaner uploads and listings come from PGYER's official MCP server. Install
it alongside the skill:

```bash
# Claude Code
claude mcp add --transport stdio pgyer \
  --env PGYER_API_KEY=<your_key> \
  -- npx -y pgyer-mcp-server

# Codex CLI
codex mcp add pgyer --env PGYER_API_KEY=<your_key> -- npx -y pgyer-mcp-server

# VSCode
code --add-mcp '{"name":"pgyer","command":"npx","args":["-y","pgyer-mcp-server"],"env":{"PGYER_API_KEY":"<your_key>"}}'
```

For Cursor, Windsurf, Cline, Continue, and any other MCP-compatible client,
add this to your tool's MCP config file:

```json
{
  "mcpServers": {
    "pgyer": {
      "command": "npx",
      "args": ["-y", "pgyer-mcp-server"],
      "env": { "PGYER_API_KEY": "<your_key>" }
    }
  }
}
```

Common locations (subject to change; consult your tool's docs):
- **Cursor**: `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (per-project)
- **Windsurf**: `~/.codeium/windsurf/mcp_config.json`
- **Cline**: VSCode settings → Cline → MCP servers
- **Continue**: `~/.continue/config.json` under `mcpServers`

## Manual install (if your agent isn't in the `skills` CLI yet)

If `npx skills add -a <agent>` returns "agent not supported", install the
skill by hand:

1. Clone the repo: `git clone https://github.com/PGYER/pgyer-skill.git`
2. Paste `SKILL.md`'s body into your agent's rules / instructions / system
   prompt slot. `SKILL.md` is written to be self-contained — no
   Claude-Code-only conventions.
3. Reference `references/*.md` via your agent's `@Docs` / context-file
   feature when relevant.

That's exactly what the CLI does internally, just by hand.

## Custom Anthropic Agent SDK setup

If you're building your own agent against the Claude API, you have full
control:

```python
import anthropic
from pathlib import Path

skill_root = Path("./pgyer-skill")
system_prompt = "\n\n---\n\n".join([
    "You help users distribute app builds to PGYER.",
    (skill_root / "SKILL.md").read_text(),
    (skill_root / "references" / "api-cheatsheet.md").read_text(),
    (skill_root / "references" / "troubleshooting.md").read_text(),
])

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=4096,
    system=system_prompt,
    tools=[
        # Define a Bash-execution tool the model can use to invoke
        # scripts/pgyer_upload.sh, or wire up the MCP server via
        # the SDK's mcp_servers parameter.
    ],
    messages=[{"role": "user", "content": "上传 build/app.apk 到蒲公英"}],
)
```

For native MCP integration in the SDK, see Anthropic's MCP docs at
https://docs.claude.com — you can connect to `pgyer-mcp-server` over stdio
without writing tool definitions yourself.

## Shell-script-only fallback

If your agent has nothing but a shell tool — no MCP, no rules, no
instructions support — you can still distribute to PGYER. The script is
self-contained:

```bash
git clone https://github.com/PGYER/pgyer-skill.git
export PGYER_API_KEY=<your_key>

# Public install:
./pgyer-skill/scripts/pgyer_upload.sh -k "$PGYER_API_KEY" build/app.apk

# Password install:
./pgyer-skill/scripts/pgyer_upload.sh -k "$PGYER_API_KEY" -t 2 -p qa2026 build/app.ipa

# JSON output (for the agent to parse):
./pgyer-skill/scripts/pgyer_upload.sh -k "$PGYER_API_KEY" -j build/app.apk
```

Run `./scripts/pgyer_upload.sh -h` for the full option list. This is the
lowest-common-denominator path.

## What's portable vs Claude-Code-specific

| Component | Portable to other agents? |
|---|---|
| `pgyer-mcp-server` (separate repo) | ✅ Works in any MCP-compatible client |
| `references/*.md` (PGYER API knowledge) | ✅ Paste into rules/instructions or load via `@Docs` |
| `scripts/pgyer_upload.sh` | ✅ Any agent shells out to it |
| `examples/*.yml` (CI/CD templates) | ✅ Fully agent-agnostic |
| `SKILL.md` content (the routing brain) | ✅ Paste into rules / system prompt / instructions |
| Auto-loading via `skills` CLI | ✅ 50+ agents supported |
| `install.sh` writing to `~/.claude/skills/` | ❌ Claude Code specific (use `npx skills add -g` instead) |

In short: the **content** is universal; only the legacy `install.sh` is
Claude-Code-specific, and `npx skills add` makes it irrelevant.

## Found a tool that's not covered here?

PRs welcome. The pattern is always:
1. Install via `npx skills add -a <agent>` if the CLI supports it.
2. Otherwise, paste `SKILL.md` body into the tool's rules / instructions.
3. Make sure `PGYER_API_KEY` is exported (or `~/.pgyer/config` is set).

If your tool can do (1) or (2), this skill works.
