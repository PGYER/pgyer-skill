# PGYER API — Cheat Sheet

Base: `https://api.pgyer.com/apiv2`
Failover domains (try if the primary is unreachable): `api.xcxwo.com`, `api.pgyeraapp.com`.

All endpoints accept `POST` with `Content-Type: application/x-www-form-urlencoded`.
The API key is always passed as `_api_key`.

All responses share the envelope `{ "code": <int>, "message": "<str>", "data": <obj> }`.
`code == 0` means success. See `troubleshooting.md` for error codes.

---

## Uploads (new two-step COS flow)

Prefer the bundled `scripts/pgyer_upload.sh` instead of re-implementing — it
handles domain failover, DoH DNS, large-file streaming, and all options.
The flow is shown here only for reference / debugging.

### Step 1: `app/getCOSToken`

```bash
curl -X POST 'https://api.pgyer.com/apiv2/app/getCOSToken' \
  --data-urlencode "_api_key=$PGYER_API_KEY" \
  --data-urlencode 'buildType=apk'   # or ipa, hap
```

Returns:
```json
{ "code": 0, "data": {
    "endpoint": "https://pgy-apps-...cos.accelerate.myqcloud.com",
    "key": "<uuid>.apk",
    "params": {
      "signature": "...",
      "x-cos-security-token": "...",
      "key": "<uuid>.apk"
    }
}}
```

### Step 2: upload to the returned COS endpoint as `multipart/form-data`

Form fields: `signature`, `x-cos-security-token`, `key`,
`x-cos-meta-file-name`, and `file` (the binary).

A `204 No Content` response means success.

### Step 3: poll `app/buildInfo` until ready

```bash
curl -X POST "https://api.pgyer.com/apiv2/app/buildInfo?_api_key=$PGYER_API_KEY&buildKey=<key-from-step-1>"
```

If `code == 1247`, PGYER is still processing; wait ~1s and retry.

---

## Optional upload parameters (pass in Step 1)

Any of these may be sent as additional form fields alongside `buildType`:

| Field | Values | Meaning |
|---|---|---|
| `buildInstallType` | `1` / `2` / `3` | 1=public, 2=password, 3=invite-only |
| `buildPassword` | string | Required if `buildInstallType=2` |
| `buildUpdateDescription` | string | Release notes for this build |
| `buildInstallDate` | `1` / `2` | 1=time-bounded, 2=forever |
| `buildInstallStartDate` | `YYYY-MM-DD` | Required if `buildInstallDate=1` |
| `buildInstallEndDate` | `YYYY-MM-DD` | Required if `buildInstallDate=1` |
| `buildChannelShortcut` | string | Update a specific channel slug instead of the default |

---

## Reads

### `app/listMy` — list every app on this key

```bash
curl -X POST 'https://api.pgyer.com/apiv2/app/listMy' \
  --data-urlencode "_api_key=$PGYER_API_KEY" \
  --data-urlencode 'page=1'
```

Response `data.list[]` items include: `appKey`, `buildKey`, `buildName`,
`buildVersion`, `buildVersionNo`, `buildBuildVersion`, `buildShortcutUrl`,
`buildFileSize`, `buildIdentifier`, `buildPassword`, `buildCreated`.

### `app/getByShortcut` — public-shape info via URL slug

```bash
curl -X POST 'https://api.pgyer.com/apiv2/app/getByShortcut' \
  --data-urlencode "_api_key=$PGYER_API_KEY" \
  --data-urlencode 'buildShortcutUrl=<slug>'
```

Lighter response than `app/view` — omits `buildPassword`, QR URL, expiry,
download counts.

### `app/view` — full admin record via `appKey`

```bash
curl -X POST 'https://api.pgyer.com/apiv2/app/view' \
  --data-urlencode "_api_key=$PGYER_API_KEY" \
  --data-urlencode 'appKey=<32-char-hex>'
```

Returns everything: `buildPassword`, `buildQRCodeURL`,
`appExpiredDate`, `todayDownloadCount`, `todayBuildDownloadCount`,
`buildInstallType`, `appInstallStartDate`, `appInstallEndDate`,
`buildSignatureType`, plus the icon URL at `data.iconUrl`.

---

## Public URLs derived from a response

Given `buildShortcutUrl=<slug>`:

- Install page: `https://www.pgyer.com/<slug>`
- QR code: `data.buildQRCodeURL` from `app/view`, or
  `https://www.pgyer.com/app/qrcodeHistory/<long-hex>` (see response).
- Icon: `https://cdn-app-icon2.pgyer.com/...` (returned in `data.iconUrl`
  from `app/view`, or compose from `buildIcon` hash).

---

## Reference

Official API docs: https://www.pgyer.com/doc/view/api
Official upload samples (6 languages): https://github.com/PGYER/upload-app-api-example
