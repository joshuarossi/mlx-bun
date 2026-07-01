# Design: mlx-bun desktop app (Tauri)

A native macOS desktop app that wraps the existing mlx-bun chat UI in a
window — double-click an icon, get local AI, no terminal. The app is a
**thin shell**: it spawns `mlx-bun serve` as a sidecar and points a
WKWebView at the chat UI the server already serves. Almost no new code;
the value is packaging + UX, not new functionality.

Companion docs: [embedding.md](../reference/embedding.md) (the sidecar
layout this builds on), [distribution.md](../reference/distribution.md)
(the sign/notarize pipeline this reuses).

## Where it lives — separate repo (recommended)

Ship the app from its **own repo** (`mlx-bun-desktop`), not inside this
one.

- **Toolchain isolation.** This repo is Bun/TS. Tauri drags in Rust,
  Cargo, and `src-tauri/target/` (heavy build artifacts). Keeping it out
  preserves the core repo's clean dependency surface and scope.
- **Different product, cadence, audience.** The app's artifact is a
  signed `.dmg` / Homebrew **Cask** for end users; the core repo ships a
  CLI tarball + npm package for developers. They version independently.
- **The sidecar is already a published artifact.** The app pulls a
  pinned, signed, notarized `mlx-bun` bundle from a core-repo release
  (the versionless `mlx-bun-arm64.tar.gz`, or a tagged
  `mlx-bun-v<ver>-arm64.tar.gz`) — no source coupling needed.
- **Precedent.** The Homebrew tap is already a separate repo; this fits.

In-repo alternative (a `desktop/` subdir) is viable if tight version
lockstep ever matters more than toolchain cleanliness — the mechanics
below are identical, only the sidecar source changes (local `dist/`
instead of a downloaded release). Default to separate.

## Architecture

```
mlx-bun-desktop.app
 ├─ src-tauri (Rust shell)
 │    on launch  → pick a free port, spawn sidecar:
 │                 mlx-bun serve <model> --port <p> --no-open
 │    readiness  → poll GET http://127.0.0.1:<p>/v1/models until 200
 │    window     → WKWebView → http://127.0.0.1:<p>/#/chat
 │    on quit    → SIGKILL the sidecar (restart→ready is ~0.4s; safe)
 └─ Contents/Resources/
      mlx-bun  + libmlxc.dylib + libmlx.dylib + libjaccl.dylib
      + mlx.metallib + pi assets   (the bundle build-binary.sh produces)
```

The window renders the **same page** `mlx-bun serve` serves today
(`/#/chat`, the embedded pi web chat). No bespoke UI.

## Components

1. **Sidecar binary.** Tauri `externalBin` (target-triple-suffixed, e.g.
   `mlx-bun-aarch64-apple-darwin`); the dylibs + metallib + pi assets go
   in `bundle.resources` beside it. mlx-bun resolves its libs via
   `dirname(realpath(execPath))`, so the flat Resources layout works
   unchanged (verified: Bun realpaths execPath through symlinks).
2. **Spawn / teardown** (`main.rs`). Use Tauri's shell/sidecar API (or
   `std::process::Command`) to launch on `setup`, kill on window close /
   app exit. One generation runs at a time server-side, so no client
   concurrency to manage.
3. **Port.** Bind an ephemeral port in Rust, pass it to both the spawn
   (`--port`) and the webview URL, to avoid 8080 collisions with a
   user's own `mlx-bun serve`.
4. **Readiness gate.** Show a lightweight "starting…/downloading model…"
   splash until `/v1/models` returns 200. Warm start ~0.4s; first-ever
   run downloads the starter model (~0.9 GB) — the existing onboarding
   page already narrates this, so the splash can hand off to it.

## Distribution

A `.app` is a better Gatekeeper citizen than the flat CLI binary:

- **Stapleable.** Unlike a bare Mach-O, a `.app`/`.dmg` accepts a stapled
  notarization ticket → works **offline**, no online check needed.
- **Channels:** signed `.dmg` direct download, and/or a Homebrew **Cask**
  (`brew install --cask mlx-bun`) — a natural 5th install path.
- **Not App Store.** JIT + a spawned child process + the Metal model
  don't fit the sandbox. Developer-ID + notarized + DMG/Cask outside the
  store is the same flow this project already uses.

### Signing / entitlements

Reuse the core pipeline. The nested sidecar `mlx-bun` still needs the
same entitlements as the standalone build
([packaging/entitlements.plist](../../packaging/entitlements.plist)):

- `com.apple.security.cs.allow-jit` + `allow-unsigned-executable-memory`
  (JavaScriptCore JIT) — without these the sidecar is killed on launch.
- `com.apple.security.cs.disable-library-validation` — the sidecar
  dlopens the bundled MLX dylibs.

Tauri's bundler signs nested binaries during the `.app` signing pass;
point these entitlements at the sidecar specifically. Notarize the
`.app` (or `.dmg`) with the existing `AC_PROFILE` notary credentials,
then `xcrun stapler staple`.

## Milestones

1. **Spike** — `tauri init` in a new repo; hardcode port 8080; spawn a
   locally-built `mlx-bun serve --no-open`; load `/#/chat` in the window;
   `cargo tauri dev`. Proves the wrap end-to-end.
2. **Robust runtime** — ephemeral port; readiness poll + splash;
   clean teardown on quit; surface sidecar stderr to a log.
3. **Bundle + sidecar** — wire `externalBin` + `bundle.resources` to a
   pinned core-repo release tarball (download in a build script, or check
   in a fetch step); first-run model-download UX.
4. **Sign + notarize + package** — Developer-ID sign with nested
   entitlements, notarize, staple, emit `.dmg`.
5. **Cask** — formula in a tap pointing at the `.dmg` release asset;
   `brew install --cask`.

## Open questions / risks

- **Tauri sidecar entitlement plumbing** — confirm Tauri applies the
  per-binary entitlements to `externalBin` (may need a custom signing
  hook in the bundler config). Validate early in milestone 4.
- **Window vs. menubar** — a normal window is the MVP; a menubar/tray app
  ("always-on local model") is a possible later mode.
- **Model picker** — MVP serves one model (the starter). Switching models
  means restarting the sidecar; defer a UI for that.
- **Version pinning** — decide whether the app tracks `latest` or pins a
  specific `mlx-bun` release per app version (pin is safer for repro).
- **Universal binary** — arm64-only today; Tauri can target both, but
  MLX is Apple-Silicon-only, so x86 is moot.
