# Embedding mlx-bun (single-binary sidecar)

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

Library resolution order (src/mlx/ffi.ts): `MLX_BUN_LIBMLXC` env var →
`libmlxc.dylib` next to the executable → homebrew
(`/opt/homebrew/lib`, `/usr/local/lib`). The whole directory can be
renamed/moved; nothing references absolute paths after the build
script's `install_name_tool` fixups.

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
  [server-api.md](./server-api.md). Use whichever your client SDK
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
see [library-api.md](./library-api.md).
