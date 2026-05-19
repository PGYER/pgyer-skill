# Bundled scripts

## `pgyer_upload.sh`

A production-grade Bash script that uploads `.ipa` / `.apk` / `.hap` packages
to PGYER using the new two-step COS upload flow.

**Source:** copied verbatim from PGYER's official sample repository
[`PGYER/upload-app-api-example`](https://github.com/PGYER/upload-app-api-example/tree/main/shell-demo).
See `UPSTREAM-README.md` for the original documentation.

**Why bundled:** the script handles details that are tedious to redo
(multi-domain failover, DoH DNS resolution, large-file streaming, all
optional upload parameters). Rather than reinvent these in this skill,
we ship the upstream script directly.

### Quick usage

```bash
./pgyer_upload.sh -k <api_key> /path/to/app.apk                       # public install
./pgyer_upload.sh -k <api_key> -t 2 -p secret /path/to/app.ipa         # password install
./pgyer_upload.sh -k <api_key> -d "fix login bug" /path/to/app.apk     # with release notes
./pgyer_upload.sh -k <api_key> -j /path/to/app.apk                     # JSON output
./pgyer_upload.sh -k <api_key> -P -v /path/to/app.apk                  # progress + verbose
```

Run with `-h` for the full option list.

### Reading the API key from the standard locations

The upstream script takes the key via `-k`. To match this skill's
conventions, callers should resolve the key first and then pass it in:

```bash
KEY="${PGYER_API_KEY:-$(grep -m1 '^api_key=' ~/.pgyer/config 2>/dev/null | cut -d= -f2)}"
./pgyer_upload.sh -k "$KEY" /path/to/app.apk
```

### Updating this copy

If PGYER updates the upstream script, re-pull with:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/PGYER/upload-app-api-example/main/shell-demo/pgyer_upload.sh \
  -o pgyer_upload.sh && chmod +x pgyer_upload.sh
```
