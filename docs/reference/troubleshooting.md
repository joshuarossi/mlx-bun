# Troubleshooting

Symptom → cause → fix, for the problems users actually hit. Every path and
flag below is taken from the code (`src/`) or the linked reference doc; when a
sentence here disagrees with the code, the code wins — fix the doc.

Related: [cli.md](./cli.md) (commands), [server-config.md](./server-config.md)
(serve flags, admission), [distribution.md](./distribution.md) (install paths,
signing), [docs/reference/distribution.md](./distribution.md) (sidecar layout, self-signing),
[environment.md](./environment.md) (contributor/agent platform facts).

## Runtime and install

### `dlopen` fails / `libmlxc.dylib` not found

**Cause.** The `mlx-bun` executable ships without the MLX native runtime
(`libmlxc.dylib`, `libmlx.dylib`, `libjaccl.dylib`, `mlx.metallib`, plus the
expert-IO dylib and frame-extract helper — the list is `NATIVE_PACK_FILES` in
`src/native-pack.ts`). The runtime is a versioned tarball downloaded on first
run into `~/Library/Caches/mlx-bun/native-v<ver>-<arch>/`. The download is
resumable and sha256-verified through the same machinery as model downloads
(`src/download.ts`), so an interrupted first run leaves a partial file, not a
broken install.

**Fix.** Rerun `mlx-bun serve` (or any command that loads the runtime); it
resumes and verifies. The library is resolved in this order
(`resolveLibmlxc()` in `src/mlx/ffi.ts`, mirrored by `nativeRuntimeDir()` in
`src/native-pack.ts`):

1. `MLX_BUN_LIBMLXC=/path/to/libmlxc.dylib` — explicit override; the other
   libs are expected in the same directory.
2. Beside the executable (the sidecar layout from `docs/reference/distribution.md`).
3. The native-pack cache dir above.
4. Homebrew: `/opt/homebrew/lib`, then `/usr/local/lib`.

To use your own build, set `MLX_BUN_LIBMLXC`. If you see
`no native pack published for <arch> — set MLX_BUN_LIBMLXC or install mlx via
homebrew`, there is no published pack for that CPU architecture (only `arm64`
has a baked checksum in `src/native-pack.ts`); use one of the two escapes in
the message. `MLX_BUN_NATIVE_PACK_URL` overrides the download URL.

### Gatekeeper: "unidentified developer" / app can't be opened

**Cause.** Released binaries are Developer-ID signed and notarized. macOS only
checks the notarization ticket when a file carries the `com.apple.quarantine`
xattr, which browser downloads and `curl -O`-style saves get. Homebrew installs
and the documented `curl ... | tar -xz` one-liner never write a quarantined
file, so they never prompt (`distribution.md`, "Direct download").

**Fix.**
- Online: the notarization ticket resolves the check; allow it once.
- Offline: `xattr -d com.apple.quarantine mlx-bun` (the manual escape hatch
  from `distribution.md`).
- Self-built binary: the bundle's dylibs must be (re)signed with the hardened
  runtime and entitlements — see "Signing & notarization" in
  [docs/reference/distribution.md](./distribution.md).

### Wrong Bun version / `Bun.Image` missing / FFI crashes in a source checkout

**Cause.** `package.json` pins `"bun": ">=1.4.0"`. Two things depend on it:
`Bun.Image` is the vision decode path (`src/vision/preprocess.ts`), and Bun
1.4 fixed a `bun:ffi` stack-argument ABI bug on macOS arm64 that made
multi-argument mlx-c bindings hand the callee shifted garbage
(`lab/repro/bun-ffi-stack-args/ISSUE.md`; the code now uses natural mlx-c
signatures with no workaround).

**Fix.** `bun upgrade`, then `bun --version` ≥ 1.4.0. The compiled release
binary embeds its own Bun, so this only affects running from source.

### `port 8080 is already serving …`

**Cause.** `serve` probes the port before loading weights and refuses to start
a second server on a port that already answers `/v1` (`src/cli.ts`, serve
branch; `--port` row in `server-config.md`).

**Fix.** Reuse the running server (`mlx-bun pi` attaches automatically), stop
it, or pass `--port <other>`. A second server is a second model in memory;
check `mlx-bun fit` first.

## Models and downloads

### `no models match (try \`mlx-bun scan\`)`

**Cause.** `ls`/`serve`/`fit` resolve models from a registry built by scanning
the Hugging Face hub cache. The registry is stale or empty, or the model is
not in the cache directory the registry reads.

**Fix.** Run `mlx-bun scan` after downloading. The cache path is resolved
exactly as `huggingface_hub` does (`DEFAULT_HUB` in `src/registry.ts`):
`HF_HUB_CACHE`, else `HF_HOME/hub`, else `~/.cache/huggingface/hub`. If you
downloaded to a custom location, set the same env var for `mlx-bun`. The
registry database lives at `~/.cache/mlx-bun/registry.sqlite`.

### Hugging Face download stalls at 0%

**Cause.** The Python `hf` downloader uses the Xet transfer path, which stalls
on some networks.

**Fix.** Use `mlx-bun get <org/repo>` — it speaks plain HTTPS resolve/CDN with
no Xet, Range-resumes partial blobs, and verifies every file (sha256 for LFS
blobs, git-blob sha1 for small files) into the standard hub cache layout
(`src/download.ts`). Rerunning the same command resumes verified
`.incomplete` prefixes. If you must use the Python CLI, set
`HF_HUB_DISABLE_XET=1` before the download command.

### `get` refuses for lack of disk space

**Cause.** Before transferring, `get` credits complete blobs and partial
prefixes, then requires free space for the exact remainder plus a fixed 1 GiB
reserve (`cli.md`, `get`).

**Fix.** Free space, or point `HF_HUB_CACHE` at a larger volume before
starting.

### Gated repo: 401/403 from Hugging Face

**Cause.** No token. `get` reads `HF_TOKEN`, else
`~/.cache/huggingface/token` (`hfToken()` in `src/download.ts`).

**Fix.** `hf auth login`, or export `HF_TOKEN`.

## Memory and performance

### Will it fit? / decode is very slow on a model near the RAM ceiling

Memory pressure can reduce speed or cause allocation failures. The default
`fit` estimate uses machine RAM × 0.75 (`WIRED_FRACTION` in `src/fit.ts`).
Serving treats that estimate as advisory; `--memory-budget` opts into a limit.

**Fix.** Check first:

```sh
mlx-bun fit <model> --ctx 8192          # this machine
mlx-bun fit <model> --ctx 8192 --skus   # across the Apple Silicon lineup
mlx-bun fit <model> --kv-quant 4        # window with a 4-bit KV cache
```

`fit` reports weights bytes (from safetensors headers), KV bytes/token, the
calibrated prefill transient, and the wired ceiling. Then close memory-heavy
apps, pick a smaller quantization, or serve with `--kv-quant 4|8` for a larger
context window in the same budget. GLM-5.2 uses its own streamed-runtime plan
(`fit GLM-5.2`; `--context-length`), not the resident-weights estimator.

### Completion stops before my `max_tokens` (no error)

Check `finish_reason`: `stop` means EOS or a stop condition; `length` means
an output/context cap was reached. Default memory estimates do not shorten
requests. Explicit `--memory-budget`, context settings and GLM-5.2's fixed
layout can cap a completion. `/stats.admission.enforced_context_tokens` shows
that cap, or null when none applies. `max_safe_context` is only an estimate.

### `400` with `"type": "memory_admission"`, `"code": "context_over_budget"`

This error applies to an explicitly configured budget/context cap or a fixed
runtime layout. The prompt leaves no room to generate under that limit.
Remove the optional budget/context cap to attempt the request without an
estimated restriction, or adjust the limit you selected. See
[server configuration](server-config.md#memory-admission-and-caches).
