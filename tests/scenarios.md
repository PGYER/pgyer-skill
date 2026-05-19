# Routing scenarios — regression tests for SKILL.md

This document is the canonical regression battery for the PGYER skill's
routing logic. Run these scenarios after **any** change to:

- `SKILL.md`
- `references/*.md`
- `scripts/pgyer_upload.sh` (signature changes)
- `examples/**/*.yml` (template structure changes)

The goal is to verify that an AI agent, given only the skill files plus a
user prompt, picks the **right path** (MCP / shell script / curl / which CI
template) and surfaces the **right output fields** (short URL, QR, password,
expiry).

## How to run

### Option A — fresh AI session (most realistic)

1. Open a fresh Claude Code, Cursor, Codex, or other supported agent session
   with this skill loaded (e.g. `npx skills add PGYER/pgyer-skill -g -a
   claude-code`).
2. Set `PGYER_API_KEY` (or `~/.pgyer/config`) to a dummy value so the agent
   doesn't ask for credentials mid-test. The tests don't actually upload —
   we only check the agent's *plan*.
3. For each scenario below, send the prompt. Tell the agent **"plan only,
   do not execute"** so you can grade its routing before any side effects.
4. Compare against the **Primary path** and **Required output** rows.

### Option B — subagent simulation (no install needed)

Spawn a subagent (general-purpose) and feed it:

- The full content of `SKILL.md`
- The full content of `references/mcp-tools.md` and
  `references/api-cheatsheet.md`
- This file's **Prompts** (T1–T10) verbatim
- Instructions: "for each prompt, describe what files you'd read and what
  command/tool you'd run. Do NOT execute."

This is exactly the method used in v0.1 and v0.2 validation (6/6 ✅ each).

### Option C — MCP-aware vs MCP-unaware variants

Run twice:

- **MCP installed**: the three MCP tools (`upload-app`, `list-my-apps`,
  `get-app-info-by-shortcut`) are listed in the session. The agent should
  prefer them where applicable.
- **MCP not installed**: the agent should fall back to shell script / curl
  per the capability map.

A skill that handles both modes correctly passes.

## Grading rubric

For each scenario:

| Mark | Meaning |
|---|---|
| ✅ | Agent picks the correct primary path AND surfaces all required output fields. |
| ⚠️ | Right path, but misses an output field (e.g. forgets QR code), OR picks a slightly suboptimal path that still works. |
| ❌ | Wrong path entirely (e.g. uses curl directly when shell script is required; uses `getByShortcut` when password is requested but doesn't escalate to `app/view`). |

**Pass threshold:** 6/6 ✅ on the core scenarios (T1–T6). Extension
scenarios (T7–T10) tolerate ⚠️ but ❌ should be investigated.

## Core scenarios

These map directly to the v0.2 validation battery — all 6 must pass on every
release.

### T1. Plain upload

- **Prompt:** `"把 build/release/app.apk 上传到蒲公英"`
- **Files to read:** `SKILL.md`
- **Primary path (MCP unavailable):** `scripts/pgyer_upload.sh -k "$PGYER_API_KEY" build/release/app.apk`
- **Primary path (MCP available):** MCP `upload-app` with `filePath`
- **Required output:** install short URL (`https://www.pgyer.com/<slug>`), QR code URL, `buildVersion` / `buildBuildVersion`
- **Anti-patterns:** ❌ Trying to POST `/apiv2/app/upload` directly with curl — the script handles the two-step COS flow.

### T2. Upload with install password

- **Prompt:** `"把 build/release/app.apk 上传到蒲公英，密码设为 qa2026"`
- **Files to read:** `SKILL.md`, `references/api-cheatsheet.md`
- **Primary path (always):** `scripts/pgyer_upload.sh -k "$PGYER_API_KEY" -t 2 -p qa2026 build/release/app.apk`
- **Required output:** install short URL, QR code URL, password readback
- **Anti-patterns:** ❌ Trying to use MCP `upload-app` — it only accepts `filePath`, password is silently dropped.

### T3. List all apps

- **Prompt:** `"我蒲公英上有哪些应用？"`
- **Files to read:** `references/api-cheatsheet.md`
- **Primary path (MCP unavailable):** `POST /apiv2/app/listMy` via curl with `_api_key` and `page=1`
- **Primary path (MCP available):** MCP `list-my-apps`
- **Required output:** compact table — `buildName`, version, `buildShortcutUrl`, `buildCreated`

### T4. App info by short URL — password / QR required

- **Prompt:** `"查一下短链 zhinengshouced 这个应用，要看密码和二维码"`
- **Files to read:** `references/api-cheatsheet.md`, `references/mcp-tools.md`
- **Primary path:** **Two steps.** First call `app/getByShortcut` (or MCP `get-app-info-by-shortcut`) to fetch `appKey`, then call `app/view` with that `appKey` to fetch password + QR.
- **Required output:** `buildPassword`, `buildQRCodeURL`, install short URL
- **Anti-patterns:** ❌ Stopping at `getByShortcut` — it omits password and QR. This is the highest-risk routing bug; the skill's capability map explicitly calls it out.

### T5. App info by appKey — full record

- **Prompt:** `"appKey 是 abc123def456abc123def456abc123de，给我完整信息"`
- **Files to read:** `references/api-cheatsheet.md`
- **Primary path (always):** `POST /apiv2/app/view` with `appKey=…` via curl
- **Required output:** `buildPassword`, `buildQRCodeURL`, `appExpiredDate`, `buildInstallType`, install short URL, download counts
- **Anti-patterns:** ❌ Using MCP `get-app-info-by-shortcut` — wrong tool, returns less data; also doesn't accept appKey.

### T6. iOS GitHub Action with install password

- **Prompt:** `"我有个 iOS 项目，帮我加一个 push 到 main 就发蒲公英的 GitHub Action，要带安装密码 qa2026"`
- **Files to read:** `SKILL.md` (CI section), `examples/github-actions/ios.yml`
- **Primary path:** Adapt `examples/github-actions/ios.yml` for the user's project. **Critical:** swap the `PGYER/pgyer-upload-app-action` step for a `scripts/pgyer_upload.sh -t 2 -p qa2026` step (the commented "with password" block at the bottom of the template shows the swap).
- **Required output:** the generated `.github/workflows/publish-pgyer.yml`, instructions to add `PGYER_API_KEY` as a repo secret, and (since this is iOS) `IOS_DIST_P12_BASE64` etc.
- **Anti-patterns:** ❌ Leaving `PGYER/pgyer-upload-app-action` as the upload step — the action only accepts `_api_key` + `appFilePath`, so the password is silently dropped at runtime.

## Extension scenarios

Added in v0.3. These cover non-core paths but should still behave sensibly.

### T7. Cross-agent install

- **Prompt:** `"我用 Cursor，怎么把这个 skill 装上？"`
- **Files to read:** `README.md`, `docs/use-with-other-agents.md`
- **Primary path:** Tell the user to run `npx skills add PGYER/pgyer-skill -g -a cursor`. Optionally also install `pgyer-mcp-server` via Cursor's MCP config (`~/.cursor/mcp.json`).
- **Anti-patterns:** ❌ Telling the user to `git clone + ./install.sh` — that's Claude-Code-only.

### T8. HarmonyOS upload

- **Prompt:** `"把 dist/app-signed.hap 传到蒲公英"`
- **Files to read:** `SKILL.md`
- **Primary path:** Same as T1, just with the `.hap` extension. The script and MCP both auto-detect `buildType` from the file.
- **Required output:** install short URL, QR code URL.

### T9. Unsupported CI platform

- **Prompt:** `"我用 Bitrise，怎么发蒲公英？"`
- **Files to read:** `SKILL.md` (CI matrix)
- **Primary path:** SKILL.md's CI matrix shows "no template yet; use shell-script pattern from gitlab-ci". The agent should adapt `examples/gitlab-ci/android.yml` (or `ios.yml`) into a Bitrise step that runs `scripts/pgyer_upload.sh`.
- **Required output:** the Bitrise step / `bitrise.yml` snippet, plus instruction to set `PGYER_API_KEY` as a secret env var.
- **Anti-patterns:** ⚠️ Saying "we don't support Bitrise" and stopping — wrong, the pattern is reusable.

### T10. Missing API key

- **Prompt:** `"上传 app.apk 到蒲公英"` (with neither `PGYER_API_KEY` env nor `~/.pgyer/config` set)
- **Files to read:** `SKILL.md` (Credentials section)
- **Primary path:** The agent should **refuse to proceed without credentials** and walk the user through the setup using the exact recipe in SKILL.md:
  ```bash
  mkdir -p ~/.pgyer && chmod 700 ~/.pgyer
  echo 'api_key=<key>' > ~/.pgyer/config && chmod 600 ~/.pgyer/config
  ```
  Link the user to https://www.pgyer.com/account/api.
- **Anti-patterns:**
  - ❌ Trying to upload anyway and getting a `1002` error.
  - ❌ Asking the user to paste the key into chat (security — keys must never be echoed back).

## Maintenance

When to **add** a scenario:

- A new capability lands in PGYER's API and SKILL.md needs to route to it.
- A bug report shows an agent picked the wrong path — write the failing
  case as a test, then fix SKILL.md, then verify the test now passes.

When to **update** a scenario:

- The capability map in SKILL.md changes (e.g. a new MCP tool is added
  upstream, or a `pgyer_upload.sh` flag is renamed).

When to **remove** a scenario:

- Only if the capability itself is removed from PGYER's product.

Each scenario should remain **stable input → stable output expectation**.
If a SKILL.md change requires editing a scenario's expected output, that's
usually a signal to think carefully about whether the change is a real
improvement or a regression.
