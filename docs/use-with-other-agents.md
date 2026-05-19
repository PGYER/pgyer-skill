# Using the PGYER skill in other AI agents

This skill is built for [Claude Code](https://claude.com/claude-code), but
most of it is plain markdown, bash, and standard MCP — so the great majority
of it works in any other AI agent you might be using. This page explains
exactly what's portable, what's Claude-Code-specific, and how to wire each
piece up in the common alternatives.

## What's portable vs Claude-Code-specific

| Component | Portable? | How |
|---|---|---|
| [`pgyer-mcp-server`](https://github.com/PGYER/pgyer-mcp-server) (separate repo) | ✅ | Standard MCP — works in any MCP-compatible client |
| `reference/*.md` (PGYER API knowledge) | ✅ | Paste into your agent's rules / instructions |
| `scripts/pgyer_upload.sh` | ✅ | Any agent can shell out to it |
| `examples/*.yml` (CI/CD templates) | ✅ | Fully agent-agnostic |
| `SKILL.md` content (the routing brain) | ✅ | Paste into rules / instructions / system prompt |
| `SKILL.md` *auto-loading* via frontmatter | ❌ | Claude Code specific — other agents need explicit loading |
| `install.sh` (writes to `~/.claude/skills/`) | ❌ | Doesn't apply elsewhere |

In short: the **content** is portable; only the **auto-discovery mechanism**
is Claude-Code-specific. You bring SKILL.md to your agent however your agent
likes to be given context.

## Step 1 — install the MCP server

The MCP server is the simplest and most universal integration. It exposes
three tools (`upload-app`, `list-my-apps`, `get-app-info-by-shortcut`) over
standard MCP/stdio. Install for your tool:

### VSCode

```bash
code --add-mcp '{"name":"pgyer","command":"npx","args":["-y","pgyer-mcp-server"],"env":{"PGYER_API_KEY":"<your_key>"}}'
```

### Claude Code

```bash
claude mcp add --transport stdio pgyer \
  --env PGYER_API_KEY=<your_key> \
  -- npx -y pgyer-mcp-server
```

### Codex CLI (OpenAI)

```bash
codex mcp add pgyer --env PGYER_API_KEY=<your_key> -- npx -y pgyer-mcp-server
```

### Cursor, Windsurf, Cline, Continue, Roo Code, or any other MCP client

These all read a JSON config file (location varies — check your client's
docs). The contents are universally:

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

Once installed, restart your agent — the three PGYER tools should appear in
its tool list.

## Step 2 — give your agent the routing instructions

The MCP server alone covers the common path (simple upload, listing,
shortcut lookup). For anything beyond that — password installs, install
expiry, channel updates, fetching QR codes or the full admin record — the
agent needs to know to fall back to `scripts/pgyer_upload.sh` or `curl`
against `app/view`. That routing logic lives in `SKILL.md` and
`reference/*.md`.

Clone this repo somewhere local, then load its content into your agent's
"rules" / "instructions" / "context files" mechanism.

```bash
git clone https://github.com/PGYER/pgyer-skill.git
```

### Cursor

Two options:
1. Drop `SKILL.md`'s body into your project's `.cursorrules` file (legacy
   single-file format), or
2. Create `.cursor/rules/pgyer.mdc` with the SKILL.md body and frontmatter:
   ```
   ---
   description: PGYER (蒲公英) beta distribution
   globs:
   alwaysApply: false
   ---
   ```
   Reference `reference/api-cheatsheet.md` etc. via Cursor's `@Docs` /
   `@file` features when relevant.

### Windsurf

Paste `SKILL.md`'s body into `.windsurfrules` in your project root, or into
Windsurf's global rules at `~/.codeium/windsurf/memories/global_rules.md`.

### Codex CLI (OpenAI)

Codex reads `AGENTS.md` from the project root. Append `SKILL.md`'s body to
`AGENTS.md` (or include it as a separate file and reference it).

### Cline / Roo Code

Use `.clinerules` (or `.roorules`) in the project root, or paste the body
into the extension's "Custom Instructions" field.

### Continue

In `~/.continue/config.json`, add `SKILL.md`'s body to the `systemMessage`
field, or use Continue's `customCommands` to load it on demand.

### Any other agent

If your tool doesn't have a "rules" concept, paste `SKILL.md`'s body into
the system prompt or developer message. The skill is written to be
self-contained — no Claude-Code-only conventions in the body itself.

## Step 3 (optional) — Anthropic Claude API / Agent SDK

If you're building a custom agent against the Claude API directly, you have
full control. The recipe is roughly:

```python
import anthropic
from pathlib import Path

skill_root = Path("./pgyer-skill")
system_prompt = "\n\n---\n\n".join([
    "You help users distribute app builds to PGYER.",
    (skill_root / "SKILL.md").read_text(),
    (skill_root / "reference" / "api-cheatsheet.md").read_text(),
    (skill_root / "reference" / "troubleshooting.md").read_text(),
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

For the MCP integration specifically, see Anthropic's MCP connector docs at
https://docs.claude.com — the SDK supports stdio MCP servers natively, so
you can connect to `pgyer-mcp-server` without writing tool definitions
yourself.

## Step 4 (fallback) — shell script only, no MCP, no skill

If your agent has nothing but a shell tool, you can still distribute to
PGYER. Tell it the script exists and what it does:

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
lowest-common-denominator path — no MCP, no instructional context, just a
script.

## Found a tool that's not covered here?

PRs welcome. The pattern is always:
1. Install `pgyer-mcp-server` via the tool's MCP config.
2. Paste `SKILL.md`'s body into the tool's rules / instructions slot.
3. Make sure `PGYER_API_KEY` is exported (or `~/.pgyer/config` is set).

If your tool can do (1) and (2), this skill works.
