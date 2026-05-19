# fastlane → PGYER

PGYER maintains an official fastlane plugin:
**[`fastlane-plugin-pgyer`](https://github.com/PGYER/fastlane-plugin-pgyer)**.

This skill does **not** bundle a copy — install the plugin directly so you get
upstream fixes automatically.

## Install

```bash
fastlane add_plugin pgyer
```

## Minimal `Fastfile`

```ruby
default_platform(:ios)

platform :ios do
  desc 'Build and publish a beta to PGYER'
  lane :beta do
    build_app(
      scheme: 'MyApp',
      export_method: 'ad-hoc'
    )

    pgyer(
      api_key: ENV['PGYER_API_KEY'],
      password: 'qa2026',           # optional, omit for public install
      install_type: '2',            # 1=public, 2=password, 3=invite
      update_description: 'fix login crash'
    )
  end
end
```

For Android, swap `build_app` for `gradle(task: 'assembleRelease')` and point
`pgyer` at the resulting APK (the plugin auto-detects the most recent IPA/APK
output if you omit the path).

## In CI

Pair this with a CI runner (GitHub Actions, GitLab CI, Bitrise…). Set
`PGYER_API_KEY` as a secret/variable and invoke `fastlane beta` in your
workflow. The other CI templates in `examples/` show signing setup that is
also reusable here.

## When the plugin is NOT enough

The fastlane plugin covers the common upload flags. If you need something more
exotic (e.g. updating a specific `buildChannelShortcut`, or polling
`app/buildInfo` for a custom callback), drop down to
`scripts/pgyer_upload.sh` instead — see `reference/api-cheatsheet.md`.
