---
title: Embedding in a Mac app
description: Ship local inference as a single signed, notarized binary sidecar.
---


Ship local inference inside a Mac app (Tauri, Electron, or anything
that can spawn a process) with zero user-visible dependencies: one
executable + three native libraries, dropped into your app's resources.

## Build the bundle

```sh
./scripts/build-binary.sh dist
```

Produces a relocatable directory:

| file | what | size (arm64) |
|---|---|---|
| `mlx-bun` | the CLI/server, compiled with `bun build --compile` | ~61 MB |
| `libmlxc.dylib` | mlx-c, rewritten to load `@loader_path/libmlx.dylib` | ~0.7 MB |
| `libmlx.dylib` | mlx core (+`@loader_path` rpath added for libjaccl) | ~15 MB |
| `libjaccl.dylib` | mlx's distributed-comm dependency | ~0.6 MB |
| `mlx.metallib` | Metal kernels — libmlx loads it from its own directory | ~150 MB |
| `photon_rs_bg.wasm` | pi image codec — only the web chat's `read`-on-image path; resolved next to the executable | ~1.8 MB |

Library resolution order (src/mlx/ffi.ts): `MLX_BUN_LIBMLXC` env var →
`libmlxc.dylib` next to the executable → homebrew
(`/opt/homebrew/lib`, `/usr/local/lib`). The whole directory can be
renamed/moved; nothing references absolute paths after the build
script's `install_name_tool` fixups.

## Embedded pi web chat (`/ws/chat`)

The compiled binary includes the full embedded pi AgentSession
(`src/pi-web.ts`, dep `@earendil-works/pi-coding-agent`) that drives the
browser chat. The web chat runs pi **headless** — no TUI — so it needs
far less than pi's own `bun build --compile` ships.

**Bundled automatically.** All of pi's JavaScript (the SDK,
`createAgentSession`, the seven tools, the `openai-completions` provider,
the resource loader) is pulled into the executable by `bun build
--compile`. Nothing extra to do for the JS.

**Sidecar'd by `build-binary.sh`.** The only runtime asset pi resolves
*by path* on the headless web-chat path is `photon_rs_bg.wasm` (pi's
image codec). pi resolves it relative to `process.execPath`, so the build
script copies it next to `mlx-bun`. It is reached only when the `read`
tool is asked to read an image file, and pi degrades gracefully when it's
absent (the tool returns a text "[Image omitted]" note instead of
crashing), so it is best-effort, not load-bearing.

> Known limitation: `@silvia-odwyer/photon-node`'s wasm-bindgen glue
> currently fails to decode under Bun (both `bun` and `bun build
> --compile`) with *"Unreachable code should not be executed"* — a Bun
> wasm-bindgen gap, not an asset-placement issue (the bytes are valid and
> found). Net effect today: web-chat image *reads* aren't resized inline.
> The web chat itself is unaffected (its provider is text-only), and the
> wasm is shipped so it will work once Bun's support lands.

**Intentionally omitted** (TUI-only assets pi ships beside its own binary,
never reached by the headless web chat):

| omitted asset | what it's for |
|---|---|
| `theme/*.json` | TUI color themes (loaded via `initTheme`; we pass `noThemes`) |
| `assets/*.png` | TUI announcement/interactive images |
| `export-html/*` | the `/export-html` command's template + vendor JS |
| `docs/`, `examples/`, `README.md`, `CHANGELOG.md` | TUI help/doc browsing |

These are gated behind TUI code paths and the explicit `exportToHtml()`
method; `createAgentSession`'s import graph (`core/sdk.js`) pulls in no
theme/asset/export-html loaders, and `src/pi-web.ts` builds the session
with `noThemes`/`noSkills`/`noExtensions`/`noPromptTemplates`/
`noContextFiles`.

**Verifying it.** `build-binary.sh` runs `scripts/verify-binary-pi.ts` as
a sibling compiled binary inside the bundle (so `process.execPath` points
at the bundle dir, matching what the real binary sees). It builds the
exact headless session `src/pi-web.ts` builds — same provider/registry/
resource-loader config — against an unreachable provider, far enough to
prove the bundled SDK + assets resolve without a missing-asset crash. It
needs **no model and no server**; a provider/model error is the success
signal. The one thing this can't cover offline is a live token-streaming
turn over `/ws/chat` — that still requires `mlx-bun serve` running a real
model (run it yourself; the smoke covers everything up to the model call).

## Sidecar pattern

Spawn the server on app start, point your in-app client at it:

```ts
// Electron main / Tauri sidecar config
const child = spawn(resourcePath("mlx-bun"), [
  "serve", "gemma-4-12B", "--port", "8090", "--memory-budget", "12",
]);
// readiness: poll GET /v1/models (start→ready is ~0.4 s warm)
```

- One generation runs at a time (single queue, one GPU) — serialize or
  queue client-side too if you show progress.
- `--memory-budget <GB>` is the OOM defense: requests that can't finish
  within the budget are rejected with HTTP 400 (`memory_admission`)
  *before* generating. The Metal OOM it prevents is uncatchable.
- Protocols: OpenAI chat completions, Anthropic `/v1/messages`, OpenAI
  Responses (`previous_response_id` works) — see
  [server-api.md](/reference/server-api/). Use whichever your client SDK
  already speaks.
- Kill the child freely (SIGKILL is fine): restart→ready is ~0.4 s and
  prompt-cache misses are the only loss.

## First-run weights

The binary includes the resumable verified downloader:

```sh
mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit   # → standard HF cache
mlx-bun scan                                          # index it
mlx-bun serve gemma-4-12B --port 8090
```

Downloads resume across interruption, every blob is checksum-verified
(sha256/sha1), and the cache layout is exactly huggingface_hub's — a
user's existing HF cache is picked up as-is. For a custom weights
location inside your app's container, set `HF_HOME` in the child's
environment.

## Signing & notarization

The build script ad-hoc signs the dylibs (required on arm64 after
`install_name_tool`). For distribution, re-sign everything with your
Developer ID and notarize:

```sh
IDENTITY="Developer ID Application: Your Name (TEAMID)"

# 1. entitlements — Bun executables REQUIRE allow-jit under the
#    hardened runtime (JavaScriptCore JIT); without it the binary is
#    killed on launch.
cat > entitlements.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>com.apple.security.cs.allow-jit</key><true/>
  <key>com.apple.security.cs.allow-unsigned-executable-memory</key><true/>
</dict></plist>
EOF

# 2. sign (dylibs first, then the executable with entitlements)
codesign -f --options runtime -s "$IDENTITY" \
  dist/libjaccl.dylib dist/libmlx.dylib dist/libmlxc.dylib
codesign -f --options runtime --entitlements entitlements.plist \
  -s "$IDENTITY" dist/mlx-bun

# 3. notarize (zip the bundle dir; metallib needs no signature)
ditto -c -k --keepParent dist mlx-bun.zip
xcrun notarytool submit mlx-bun.zip --keychain-profile "AC_PROFILE" --wait
```

Inside an `.app`, put the bundle under
`Contents/Resources/` (Electron: `extraResources`; Tauri:
`bundle.resources` + `externalBin` for the executable) and let the
app's normal signing pass cover it — the same entitlements apply to
the sidecar binary.

## Library API

The server is one consumer of the library — embed generation directly
in a Bun process instead of spawning, via `loadContext`/`generate`:
see [library-api.md](/guides/library/).
