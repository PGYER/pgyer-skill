# PGYER — Troubleshooting

All API responses follow `{ "code": <int>, "message": "<str>", "data": <obj> }`.
A non-zero `code` is an error; the human-readable message is in `message`.

## Common error codes

| Code | Meaning | What to do |
|---|---|---|
| `1002` | `_api_key not found` | Key is missing or wrong. Re-check `$PGYER_API_KEY` / `~/.pgyer/config`. Reset key at https://www.pgyer.com/account/api if it was leaked. |
| `1216` | App expired or quota exceeded | Visit https://www.pgyer.com to renew the app or upgrade the plan. |
| `1247` | Build still processing | Not really an error — PGYER is still scanning the upload. Wait 1s and retry `app/buildInfo`. |
| `1271` | App package error | The file is corrupted, unsigned, or wrong type. Verify the build locally (`unzip -l app.apk` / `codesign -dvvv app.app`). |
| `1280` | Required parameter missing | Recheck the call — usually `_api_key`, `buildType`, or a form field omitted. |

## Network / domain issues

PGYER serves API traffic from three hostnames; if one is blocked in the
user's network, the others usually work. The bundled shell script tries
them in order:

1. `api.pgyer.com`
2. `api.xcxwo.com`
3. `api.pgyeraapp.com`

To diagnose manually:

```bash
for d in api.pgyer.com api.xcxwo.com api.pgyeraapp.com; do
  echo -n "$d -> "
  curl -s -o /dev/null -w '%{http_code}\n' --connect-timeout 5 "https://$d/apiv2/app/getCOSToken"
done
```

A `200`, `400`, or `405` from any host means the host is reachable —
the API key / params may still be wrong, but the network is fine.
`000` means the connection itself failed; try the next host.

If all three fail, the user's network is blocking PGYER. Suggest:

- Switching networks (corporate firewalls sometimes filter `*.pgyer.com`).
- Using a VPN.
- Falling back to DoH DNS resolution (the bundled script already attempts this via `https://dns.alidns.com/resolve`).

## Upload-specific failures

**Step 2 (COS upload) returns non-204:** the signed token expired or the
file changed mid-upload. Retry from Step 1.

**Step 3 keeps returning `1247` for >2 minutes:** the build is unusually
large or PGYER's scanner is backed up. Continue polling; abort after ~5 min
and report the `buildKey` to the user so they can check the web dashboard.

**iOS upload succeeds but install page shows "Provisioning Profile error":**
the `.ipa` was built with a development profile that doesn't include the
tester device UDIDs. Re-export with an ad-hoc or enterprise profile.

**Android upload succeeds but install fails on tester devices:** check
`buildInstallType` — if it's `2` (password), testers need the password.
Surface `buildPassword` from `app/view` to the user.

## Auth setup confusion

If the user can't find their key:

1. Sign in at https://www.pgyer.com/
2. Open https://www.pgyer.com/account/api
3. The key is a 32-char hex string. Copy it and either:
   - `export PGYER_API_KEY=<key>` for the current shell, or
   - Write `api_key=<key>` to `~/.pgyer/config` (chmod 600) for persistence.

If the key was pasted into a chat or repo, treat it as compromised and
regenerate from the same admin page.
