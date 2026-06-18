# Distributing mlx-bun via Homebrew (signed + notarized)

The end-to-end runbook for shipping a `brew install`-able, Developer-ID
signed and notarized mlx-bun. Companion to [embedding.md](./embedding.md)
(which covers the Tauri/Electron *sidecar* layout); this doc is the
*standalone CLI* distribution.

## What ships

A single **self-contained** bundle — the whole `dist/` directory in one
tarball (~73 MB compressed, ~228 MB installed):

| file | what |
|---|---|
| `mlx-bun` | the CLI/server (`bun build --compile`), ~61 MB |
| `libmlxc.dylib`, `libmlx.dylib`, `libjaccl.dylib` | MLX native runtime |
| `mlx.metallib` | Metal kernels (~150 MB — the bulk) |
| pi assets | `photon_rs_bg.wasm`, `theme/`, `assets/`, `export-html/`, `native/`, `package.json`, `CHANGELOG.md` |

We ship everything in the bottle (rather than the npm/sidecar approach of
a tiny binary that downloads the native pack on first run) so that
`brew install` is the *only* network step and the entire bundle is signed
and notarized as one artifact.

## One-time Apple setup

1. **Developer ID Application certificate** — Xcode → Settings → Accounts →
   your Apple ID → *Manage Certificates…* → **+** → **Developer ID
   Application**. Verify:
   ```sh
   security find-identity -v -p codesigning   # shows "Developer ID Application: NAME (TEAMID)"
   ```
2. **Notary credentials** — an App Store Connect **API key** (not the
   Developer-portal "Keys" page; not your Apple ID password). Create at
   **App Store Connect → Users and Access → Integrations → App Store
   Connect API → Team Keys → +** (role: Developer). Download the
   `AuthKey_<KEYID>.p8` (one-time download), note the **Key ID** and the
   **Issuer ID** (UUID at the top of the page), then:
   ```sh
   xcrun notarytool store-credentials AC_PROFILE \
     --key ~/.private_keys/AuthKey_<KEYID>.p8 \
     --key-id "<KEYID>" --issuer "<ISSUER-UUID>"
   ```
   `store-credentials` validates against Apple before saving — success
   means notarization auth works.

## Release a build

```sh
./scripts/release-binary.sh            # version from package.json
# or: ./scripts/release-binary.sh 0.0.4
```

This runs [build-binary.sh](../../scripts/build-binary.sh), then:
- signs every nested Mach-O (dylibs, any `.node`) with the hardened
  runtime, then the executable with the JIT
  [entitlements](../../packaging/entitlements.plist) (JavaScriptCore JITs —
  without `allow-jit` the binary is killed on launch);
- notarizes the zipped bundle via `AC_PROFILE` and waits;
- emits `dist-release/mlx-bun-v<ver>-arm64.tar.gz` (+ `.sha256`) and
  prints the `version`/`url`/`sha256` for the formula.

> A flat CLI bundle **cannot be stapled** (`stapler` only handles
> `.app`/`.dmg`/`.pkg`); the notarization ticket lives on Apple's servers.
> Gatekeeper checks it online only when a copy is *quarantined*. brew
> formula installs are **not** quarantined (brew downloads via curl), so
> the binary runs prompt-free regardless — notarization is load-bearing
> only for a direct browser download or a Cask.

Publish the artifact as a GitHub release whose tag matches the formula url:
```sh
gh release create v0.0.4 dist-release/mlx-bun-v0.0.4-arm64.tar.gz \
  --title "mlx-bun v0.0.4" --notes "..."
```

## The tap

Homebrew taps must be a repo named `homebrew-<name>`. The canonical tap is
**`joshuarossi/homebrew-tap`** (Homebrew shorthand: `joshuarossi/tap`).

1. Create a public repo **`joshuarossi/homebrew-tap`** (one-time).
2. Copy [packaging/homebrew/mlx-bun.rb](../../packaging/homebrew/mlx-bun.rb)
   to `Formula/mlx-bun.rb` in it, updating `version`/`url`/`sha256` from
   the release-script output. Commit and push.
3. Install:
   ```sh
   brew install joshuarossi/tap/mlx-bun
   mlx-bun --version
   ```

`brew audit --strict --new joshuarossi/tap/mlx-bun` before pushing
catches most formula issues; `brew install --build-from-source` +
`brew test` runs the formula's `test do` locally.

## Updating (one command)

Releases must originate on this Mac (signing + notarization need the
Developer ID cert + Apple creds), so the publish step is local too — no
cross-repo CI token to manage, and the tap can't drift out of sync.

Per release:

1. bump `version` in `package.json` and commit;
2. one shot:
   ```sh
   PUBLISH=1 ./scripts/release-binary.sh
   ```
   This builds → signs → notarizes → creates the `v<ver>` GitHub release →
   rewrites `version`/`url`/`sha256` in the tap's `Formula/mlx-bun.rb` and
   pushes it → mirrors the same fields into
   [packaging/homebrew/mlx-bun.rb](../../packaging/homebrew/mlx-bun.rb)
   (left staged — commit it).

Prefer two steps? Run `./scripts/release-binary.sh` to build, eyeball the
artifact, then `./scripts/publish-release.sh` to publish + sync the tap.
Both are idempotent: re-running `publish-release.sh` clobbers the release
asset and no-ops the tap push if nothing changed.

Users then upgrade with:
```sh
brew upgrade joshuarossi/tap/mlx-bun
```

## Direct download (stable URL)

`publish-release.sh` uploads two assets per release: the versioned tarball
(`mlx-bun-v<ver>-arm64.tar.gz`) **and** a versionless stable copy
(`mlx-bun-arm64.tar.gz`) pinned to `releases/latest`. This lets the
install script target a URL that never changes:

```
https://github.com/joshuarossi/mlx-bun/releases/latest/download/mlx-bun-arm64.tar.gz
```

The user-facing install path is the script at
[`website/public/install.sh`](../../website/public/install.sh) (served at
`mlx-bun.dev/install.sh`), which resolves that URL, extracts the bundle, and
links `mlx-bun` onto `PATH`:
```sh
curl -fsSL https://mlx-bun.dev/install.sh | sh
```

Without the script, the same stable URL streams straight to `tar`:
```sh
curl -fsSL https://github.com/joshuarossi/mlx-bun/releases/latest/download/mlx-bun-arm64.tar.gz \
  | tar -xz -C /usr/local/bin mlx-bun
```

Note: **browser downloads and `curl`-to-file** (e.g. `curl -O ...`) are
quarantined by Gatekeeper — macOS sets the `com.apple.quarantine` xattr on
the saved file. The piped one-liner above streams directly to `tar` and
never writes a quarantined file, so it runs without any Gatekeeper prompt.
For the browser/curl-to-file path, the notarization ticket resolves the
Gatekeeper check online; `xattr -d com.apple.quarantine mlx-bun` is the
manual escape hatch if offline.

## npm / bunx

mlx-bun is published to npm as `mlx-bun` (current: 0.0.4). Install or
run without a permanent install:

```sh
# one-off (no install)
bunx mlx-bun

# permanent global install
bun install -g mlx-bun
mlx-bun --version
```

The npm package wraps the same signed binary via a postinstall download
step (it does not bundle the ~228 MB dylibs/metallib in the npm tarball
itself). Publish to npm as part of a release:

```sh
bun publish   # from repo root; package.json version must already be bumped
```
