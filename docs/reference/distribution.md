# Distributing mlx-bun — build, sign, notarize, publish

The canonical ship doc. Everything here is what the scripts do, not a
recipe to type by hand: [scripts/build-binary.sh](../../scripts/build-binary.sh)
builds the bundle, [scripts/release-binary.sh](../../scripts/release-binary.sh)
signs and notarizes it, [scripts/publish-release.sh](../../scripts/publish-release.sh)
pushes it to every channel. If this doc and a script disagree, the script
is right and this doc has drifted.

Three install channels ship from one release:

| channel | what the user gets | network step |
|---|---|---|
| Homebrew (`brew install joshuarossi/tap/mlx-bun`) | the signed + notarized self-contained bundle | one tarball, via brew |
| Direct download (`curl -fsSL https://mlx-bun.dev/install.sh \| sh`) | the same bundle, into `~/.mlx-bun` | one tarball, via curl |
| npm / bunx (`bunx mlx-bun`, `bun install -g mlx-bun`) | a launcher + the TypeScript source, run under the user's Bun | the package, then the native runtime pack on first run |

[docs/reference/distribution.md](./distribution.md) covers the *sidecar* use of the same bundle
inside a Tauri/Electron app; the build and signing facts it relies on are
documented here.

## What ships in the bundle

`scripts/build-binary.sh [outdir]` (default `dist/`) produces one relocatable
directory. The release tarball is the directory's *contents* (no parent
dir), ~80 MB compressed; `mlx.metallib` is the bulk of the installed size.

| file | what | built from |
|---|---|---|
| `mlx-bun` | the CLI/server, `bun build --compile src/cli.ts` | our code + Bun |
| `libmlxc.dylib` | mlx-c; load command rewritten to `@loader_path/libmlx.dylib` | `/opt/homebrew/lib/libmlxc.dylib` (override `MLXC_DYLIB`) |
| `libmlx.dylib`, `libjaccl.dylib`, `mlx.metallib` | MLX core, its distributed-comm dependency, the Metal kernels (libmlx loads the metallib from its own directory) | `/opt/homebrew/opt/mlx/lib` (override `MLX_LIB_DIR`) |
| `libmlx_bun_expert_io.dylib` | bounded streamed-expert I/O for GLM-5.2 MoE serving | [scripts/build-expert-io.sh](../../scripts/build-expert-io.sh) |
| `mlx-bun-frame-extract` | AVFoundation frame-extraction helper for video input (a Mach-O *executable*, not a dylib) | [scripts/build-frame-extract.sh](../../scripts/build-frame-extract.sh) → `swiftc -O src/native/frame_extract.swift` |
| `photon_rs_bg.wasm` | pi's image codec, resolved next to the executable by the web chat's `read`-on-image path (best-effort; pi degrades to a text note without it) | `node_modules/@silvia-odwyer/photon-node` (override `PHOTON_WASM`) |
| `theme/*.json`, `assets/*.png`, `export-html/`, `package.json`, `CHANGELOG.md`, `native/darwin/prebuilds/<arch>/darwin-modifiers.node` | assets the embedded pi **terminal** (`mlx-bun pi`) resolves by path: themes, startup art, `/export` template, version banner + changelog, native modifier-key helper (degrades if absent) | `node_modules/@earendil-works/pi-coding-agent/dist`, `pi-tui` |

pi's JavaScript itself is bundled into the executable by `bun build
--compile`; only what pi resolves *by path* rides along. For a Bun
single-file executable pi computes its package dir as
`dirname(process.execPath)`, so every asset sits flat next to `mlx-bun`.

After copying, the script runs `install_name_tool` (`libmlxc` →
`@loader_path/libmlx.dylib`; `@loader_path` rpath on `libmlx` for `libjaccl`)
and **ad-hoc signs** every Mach-O it touched — arm64 requires a valid
signature after any load-command rewrite. Ad-hoc is only for local runs; the
release script replaces it (below).

**Build-time smoke.** The script then runs `mlx-bun --version`, `--help`, and
`ls`, and compiles [scripts/verify-binary-pi.ts](../../scripts/verify-binary-pi.ts)
into a *sibling* binary inside the same directory so `process.execPath` points
at the bundle exactly as it does for the real binary. That smoke builds the
same headless pi session `src/pi-web.ts` builds (against an unreachable
provider — a provider error is the success signal), exercises the photon
image path, calls `initTheme` (load-bearing for `mlx-bun pi`; a failure here
fails the smoke), and loads the native modifier helper. No model, no server.
A live streaming turn is the one thing it cannot cover.

**Runtime resolution.** The binary finds its native runtime in this order
(`src/mlx/ffi.ts`, mirrored by `nativeRuntimeDir()` in `src/native-pack.ts`):
`MLX_BUN_LIBMLXC` env → `libmlxc.dylib` beside the executable → the
native-pack cache (`~/Library/Caches/mlx-bun/native-v<ver>-<arch>/`) →
`/opt/homebrew/lib` → `/usr/local/lib`. The expert helper resolves
`MLX_BUN_EXPERT_IO_DYLIB` → beside the executable → the cache
(`src/expert-io.ts`); the frame extractor resolves `MLX_BUN_FRAME_EXTRACT` →
beside the executable → the cache → `dist-native/` → compile-on-demand from
`src/native/` via the Xcode CLT (`src/vision/video-frames.ts`). The whole
directory can be moved or renamed; nothing references an absolute path after
the fixups. Bun realpaths `execPath`, so a symlink to `mlx-bun` (Homebrew's
`bin/`, the installer's `~/.local/bin`) resolves back to the bundle.

## One-time machine setup

Releases are inherently local: signing and notarization need the Developer
ID certificate and Apple credentials on this Mac, so the publish step is
local too (no cross-repo CI token, nothing for the tap to drift from). The
release machine needs:

1. **Build inputs** — Homebrew `mlx` + `mlx-c` (the bundle copies the dylibs
   and metallib from the brew prefixes above), the Xcode command-line tools
   (`swiftc` for the frame extractor, the C toolchain for the expert helper),
   and Bun at or above the floor in `package.json` `engines.bun`.
2. **Developer ID Application certificate** — Xcode → Settings → Accounts →
   your Apple ID → *Manage Certificates…* → **+** → **Developer ID
   Application**. The release script picks the first such identity from
   `security find-identity -v -p codesigning`; override with
   `MLX_BUN_SIGN_IDENTITY`.
3. **Notary credentials** — an App Store Connect **API key** (not your Apple
   ID password): App Store Connect → Users and Access → Integrations → App
   Store Connect API → Team Keys → **+** (role: Developer). Download the
   `AuthKey_<KEYID>.p8` (one-time download), note the Key ID and Issuer ID,
   then store them under the profile name the script expects:
   ```sh
   xcrun notarytool store-credentials AC_PROFILE \
     --key ~/.private_keys/AuthKey_<KEYID>.p8 \
     --key-id "<KEYID>" --issuer "<ISSUER-UUID>"
   ```
   `store-credentials` validates against Apple before saving. Override the
   profile name with `NOTARY_PROFILE`.
4. **GitHub** — `gh auth login` with push access to `joshuarossi/mlx-bun`
   (releases) and `joshuarossi/homebrew-tap` (the tap is cloned over https
   and pushed).
5. **npm** — a publish token for `mlx-bun` (`.npmrc`; `npm whoami` must
   answer).
6. **The tap repo** — `joshuarossi/homebrew-tap` (Homebrew shorthand
   `joshuarossi/tap`) must already contain `Formula/mlx-bun.rb`; the publish
   script rewrites three fields in it and refuses to run if the file is
   missing.

## Per-release flow

Exactly what `bun run release` (= `PUBLISH=1 sh scripts/release-binary.sh`)
does, in order. Steps 1–3 are yours; the rest is the scripts.

1. **Write the notes** at `docs/planning/release-notes-v<ver>.md`. The
   publish script uses it as the GitHub release body (`--notes-file`); if it
   is missing the release is created with a bare title and a warning. After
   the release the file is archived to `docs/archive/planning/` (the
   planning directory holds living docs only).
2. **Bump `version` in `package.json`** and commit.
3. **Push** so `HEAD == origin/main`. The publish preflight refuses a dirty
   tree or a local HEAD that differs from `origin/main`: the site deploys from
   the push while the binaries are built from the local tree, and the two
   must tell the same story. `RELEASE_SKIP_GIT_CHECK=1` bypasses this for an
   assets-only re-run.
4. **Build** — `scripts/build-binary.sh dist` as described above
   (`BUILD_DIR` overrides `dist`). Release builds are arm64-only; the script
   exits on any other host arch.
5. **Sign nested code first** — every `*.dylib`, `*.node`, and the
   `mlx-bun-frame-extract` helper, matched by name under the build dir, gets
   `codesign --force --timestamp --options runtime -s "<identity>"`.
   Nested-before-container is required. The metallib, wasm, JSON, and PNG
   assets are data, not code, and are skipped.
6. **Sign the executable** with the hardened runtime and
   [scripts/packaging/entitlements.plist](../../scripts/packaging/entitlements.plist):
   - `allow-jit` + `allow-unsigned-executable-memory` — JavaScriptCore JITs;
     under the hardened runtime the binary is killed on launch without them;
   - `disable-library-validation` — required for the Homebrew install.
     brew ad-hoc re-signs bundled dylibs during its relocation pass,
     stripping our team ID off them while leaving the executable
     Developer-ID signed; library validation would then reject the team-ID
     mismatch at `dlopen`. Notarization still passes with it.
7. **Verify + smoke** — `codesign --verify --strict`, then
   `dist/mlx-bun --version`. A missing entitlement kills the binary here, not
   in a user's `brew install`.
8. **Notarize** — `ditto` the bundle into a zip, `xcrun notarytool submit
   --wait` under the notary profile (Apple's automated scan, typically 1–5
   min), delete the zip. The script greps the output for
   `status: Accepted` and **exits non-zero on anything else**, printing the
   `xcrun notarytool log <submission-id>` command to inspect the rejection.
   `notarytool` itself exits 0 on `Invalid`, so without this gate a rejected
   bundle would reach PUBLISH.
9. **Package** — `tar -czf dist-release/mlx-bun-v<ver>-arm64.tar.gz` of the
   bundle contents (only the files that exist from the fixed manifest:
   binary, four dylibs, helper, metallib, wasm, pi assets), plus a `.sha256`
   sidecar. The script prints the `version` / `url` / `sha256` triple for
   the formula. (`OUT_DIR` overrides `dist-release`.) Without `PUBLISH=1` it
   stops here and tells you to run `scripts/publish-release.sh`.
10. **GitHub release** (`publish-release.sh`, step 1) — copies the tarball to
    a versionless `mlx-bun-arm64.tar.gz`, then `gh release create v<ver>`
    with both assets and the notes file; if the release already exists the
    assets are re-uploaded with `--clobber` instead.
11. **Tap push** (step 2) — clones `joshuarossi/homebrew-tap`, rewrites
    `version` / `url` / `sha256` in `Formula/mlx-bun.rb` with `sed`, commits
    and pushes only if the diff is non-empty.
12. **Mirror the formula** (step 3) — the same three fields are rewritten in
    the in-repo source of truth,
    [scripts/packaging/homebrew/mlx-bun.rb](../../scripts/packaging/homebrew/mlx-bun.rb),
    and left **uncommitted** for you.
13. **npm publish** (step 4) — `npm view mlx-bun@<ver>`; if that version is
    already live the step is skipped, otherwise `bun publish`. On failure the
    script exits with the retry hint `bun run publish:npm`.
14. **Commit the mirrored formula** — the script's closing line:
    `git commit -am "chore(dist): mlx-bun <ver>"`.

Two-step variant: run `./scripts/release-binary.sh` alone, eyeball
`dist-release/`, then `./scripts/publish-release.sh`. Both are idempotent —
re-running publish clobbers the release assets, no-ops the tap push, and skips
npm if the version is live. Env overrides: `MLX_BUN_SIGN_IDENTITY`,
`NOTARY_PROFILE`, `BUILD_DIR`, `OUT_DIR` (release); `OUT_DIR`, `REPO`,
`TAP_REPO` (publish).

### The notarization lesson (v0.2.0, 2026-08-24)

The first v0.2.0 submission came back **Invalid**. The release added
`mlx-bun-frame-extract`, a Swift executable, to the bundle; the signing step
matched only `*.dylib` and `*.node`, so the helper reached Apple with the
build script's ad-hoc signature — no Developer ID, no hardened runtime, no
timestamp — and notarization rejects any nested Mach-O signed that way. The
old script also treated `notarytool`'s exit 0 as success, which would have
let the rejected bundle go on to publish.

Two changes, both in `scripts/release-binary.sh`: helper executables are
matched **by name** in the nested-signing pass (add every new helper there
when it lands — the manifest in the packaging step is the checklist), and
the script fails on any status other than `Accepted`. The resubmission was
accepted and the release shipped the same day.

### Stapling, quarantine, and where notarization matters

A flat CLI bundle **cannot be stapled** (`stapler` only handles `.app` /
`.dmg` / `.pkg`); the notarization ticket lives on Apple's servers, and
Gatekeeper consults it online only when a copy carries the
`com.apple.quarantine` xattr. Homebrew's download and the installer's
`curl` do not set that xattr, so both run prompt-free regardless;
notarization is load-bearing for a browser-downloaded copy (or a future
Cask). `xattr -d com.apple.quarantine <file>` is the manual escape hatch for
a quarantined copy on an offline machine.

## Channel: Homebrew

`brew install joshuarossi/tap/mlx-bun`; upgrades with
`brew upgrade joshuarossi/tap/mlx-bun`. The formula
([scripts/packaging/homebrew/mlx-bun.rb](../../scripts/packaging/homebrew/mlx-bun.rb),
mirrored to the tap by the publish script):

- `depends_on arch: :arm64`, `depends_on macos: :sonoma` — bump the macOS
  floor if MLX needs newer;
- `libexec.install Dir["*"]` then `bin.install_symlink libexec/"mlx-bun"` —
  the whole bundle lands in `libexec`, and the dylibs and pi assets resolve
  next to the executable through Bun's realpath of `execPath`;
- `test do` asserts `mlx-bun --version` prints the formula version.

The formula deliberately ships everything in one tarball rather than the
npm approach of a small package plus a first-run download, so `brew install`
is the only network step and the entire bundle is one signed, notarized
artifact. Before pushing a formula change by hand, `brew audit --strict --new
joshuarossi/tap/mlx-bun` catches most issues and `brew install
--build-from-source` + `brew test` runs the `test do` block locally.

## Channel: direct download

`publish-release.sh` uploads two assets per release: the versioned tarball
and a versionless `mlx-bun-arm64.tar.gz`, so `releases/latest` has a URL
that never changes:

```
https://github.com/joshuarossi/mlx-bun/releases/latest/download/mlx-bun-arm64.tar.gz
```

The user-facing path is [website/public/install.sh](../../website/public/install.sh)
(served at `mlx-bun.dev/install.sh`):

```sh
curl -fsSL https://mlx-bun.dev/install.sh | sh
```

It checks for Darwin/arm64, downloads that URL (or a pinned tag via
`MLX_BUN_VERSION=v<ver>`), extracts the **whole** bundle into
`MLX_BUN_INSTALL_DIR` (default `~/.mlx-bun`), and symlinks `mlx-bun` into the
first writable of `~/.local/bin`, `/usr/local/bin`, `/opt/homebrew/bin` —
or prints the `PATH` line to add. Extract into a directory, never just the
`mlx-bun` file: the executable alone would fall through to the native-pack
download on first run and lose the pi terminal's assets.

## Channel: npm / bunx

```sh
bunx mlx-bun                 # one-off, no install
bun install -g mlx-bun       # permanent
mlx-bun --version
```

The npm package is **source, not a binary**. `package.json` `files[]` ships
`bin/`, `src/`, `docs/`, `README.md`, `LICENSE`, `THIRD_PARTY_LICENSES.md`;
`exports["."]` points at `src/index.ts` (the library API), `bin.mlx-bun` at
[bin/mlx-bun.mjs](../../bin/mlx-bun.mjs). There is no postinstall hook and
no build step. `scripts/packaging/` is not in `files[]`, so the pi
adapter extension
([scripts/packaging/pi-extensions/mlx-bun-adapter.ts](../../scripts/packaging/pi-extensions/mlx-bun-adapter.ts))
is installed by copying it from the repo into `~/.pi/agent/extensions/`.

**The launcher** is plain `.mjs` so any runtime can parse it before anything
touches `bun:ffi` / `bun:sqlite`. It exits with an install hint when `Bun` is
undefined (Node), when `Bun.version` is below `MIN_BUN` (kept equal to
`engines.bun`), or when the platform is not darwin/arm64; otherwise it
imports `src/cli.ts`.

**First run: the native runtime pack.** Before importing anything that
`dlopen`s, `src/cli.ts` calls `ensureNativeRuntime()` (`src/native-pack.ts`).
If no runtime resolves through the order above, it downloads
`mlx-bun-native-v<ver>-<arch>.tar.gz` from the GitHub release tagged
`native-v<ver>` (override the URL with `MLX_BUN_NATIVE_PACK_URL`) through the
same resumable, sha256- and size-verified `downloadOne` path as model
downloads, extracts it into a staging directory, checks every file in
`NATIVE_PACK_FILES` is present, and renames it into
`~/Library/Caches/mlx-bun/native-v<ver>-<arch>/` — a crashed extract never
leaves a half-populated cache. Dev trees and embedders resolve via
Homebrew/env or the sidecar and never hit this path.

The pack contains the six native files: `libmlxc.dylib`, `libmlx.dylib`,
`libjaccl.dylib`, `mlx.metallib`, `libmlx_bun_expert_io.dylib`,
`mlx-bun-frame-extract`. It is **versioned independently** of the package
(`NATIVE_PACK_VERSION` in `src/native-pack.ts`, not `package.json`), because
it changes only when MLX or the helper set changes.

### Publishing a new native pack

Whenever the pack's file manifest or the MLX runtime changes, publish the pack
**before** the package release that depends on it — the download 404s until
the `native-v<ver>` release exists:

```sh
sh scripts/build-native-pack.sh <ver> dist-native
gh release create native-v<ver> \
  dist-native/mlx-bun-native-v<ver>-arm64.tar.gz \
  dist-native/mlx-bun-native-v<ver>-arm64.tar.gz.sha256 \
  --title "mlx-bun native runtime v<ver>" --notes "<what changed>"
```

`build-native-pack.sh` stages the same six files with the same
`install_name_tool` fixups and ad-hoc signatures as the bundle, tars them,
and prints the three constants to bake into `src/native-pack.ts`:
`NATIVE_PACK_VERSION`, the arm64 `SHA256`, and the arm64 `SIZE`. Paste them,
add any new file to `NATIVE_PACK_FILES`, and commit before bumping the
package. Pre-publish smoke: a fresh-cache extraction plus a real MLX
`dlopen` (and, when the helpers changed, an expert read or a video decode).
The pack is ad-hoc signed only — `build-native-pack.sh` never touches a
Developer ID and nothing notarizes it; it is `dlopen`ed by the user's own Bun
process, not by our signed executable. The most recent pack
(`native-v0.3.0`, published 2026-08-22) added `mlx-bun-frame-extract`.

Managed jobs in the compiled binary re-exec that binary through a private job
entry, with the database/log paths passed in the environment. They do not depend
on a Bun executable or a TypeScript source tree. The build runs
`scripts/packaging/verify-jobs.ts` as a compiled smoke: subprocess completion,
progress persistence and the CLI entry must pass before the bundle is accepted.
