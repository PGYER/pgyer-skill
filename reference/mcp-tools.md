# PGYER MCP Server — Tool Reference

The official MCP server is published as the npm package `pgyer-mcp-server`
(source: https://github.com/PGYER/pgyer-mcp-server). It is recommended when
the user wants the simplest possible upload flow, with no extra parameters.

## Install

```bash
claude mcp add --transport stdio pgyer \
  --env PGYER_API_KEY=<key> \
  -- npx -y pgyer-mcp-server
```

Equivalent commands exist for VSCode (`code --add-mcp ...`) and Codex
(`codex mcp add ...`). See the upstream README for details.

## Tools exposed

The MCP server currently exposes **only three** tools. Anything outside
this list requires the curl / shell-script path.

### `upload-app`

Upload an iOS / Android / HarmonyOS package.

| Param | Type | Required | Notes |
|---|---|---|---|
| `filePath` | string | yes | Absolute or relative path to `.ipa`, `.apk`, or `.hap` |

**Limitation:** the MCP tool only accepts `filePath`. It does NOT expose
`buildInstallType`, `buildPassword`, `buildUpdateDescription`,
`buildInstallDate`, `buildInstallStartDate`, `buildInstallEndDate`, or
`buildChannelShortcut`. If the user needs any of those, fall back to
`scripts/pgyer_upload.sh`.

**Returns:** the full `buildInfo` response (see `api-cheatsheet.md` for shape).

### `list-my-apps`

Paginated list of every app the API key owns.

| Param | Type | Required | Notes |
|---|---|---|---|
| `page` | number | no | 1-indexed; defaults to 1 |

**Returns:** `{ code, message, data: { list: [...] } }`. Each list item
contains `appKey`, `buildKey`, `buildName`, `buildVersion`, `buildVersionNo`,
`buildBuildVersion`, `buildShortcutUrl`, `buildFileSize`, `buildCreated`,
`buildIdentifier`, `buildPassword`, `buildIcon`, etc.

### `get-app-info-by-shortcut`

Lookup an app's current build by its short URL slug.

| Param | Type | Required | Notes |
|---|---|---|---|
| `buildShortcutUrl` | string | yes | The slug after `pgyer.com/`, e.g. `zhinengshouced` |

**Returns:** build info — but note this returns **less** than `app/view`.
It omits `buildPassword`, `buildQRCodeURL`, `appExpiredDate`, download counts,
and other admin-side fields. For the full record, use the curl path against
`app/view` with `appKey`.

## When NOT to use MCP

Drop to the shell-script / curl path when the user asks for any of:

- Upload with **password**, **install type**, **expiry**, **channel**, or **update description**
- Full app metadata including **QR code URL**, **password**, **expiry**, **download counts**
- **Build history** beyond the latest (MCP has no list-builds tool)
- **Tester / member / feedback** management (MCP has no tools for these yet)
