# Reference environment and platform facts

The canonical home for the oracle setup and the hard-won platform facts that
agents and contributors need. CLAUDE.md points here; do not duplicate these
facts elsewhere. Each fact is one paragraph with the evidence path that proves
it — when you change the code, update the paragraph.

User-facing symptoms live in [troubleshooting.md](./troubleshooting.md).

## Machines

There are TWO development machines and neither is canonical. One is a MacBook
Pro M1 Max with 32 GB (`hw.model MacBookPro18,2`); the other is a MacBook Pro
M4 Pro with 24 GB, the machine PLAN.md's "Reference environment" section
describes (unified memory, ~273 GB/s). Every measured number is labeled with
host / chip / RAM — `docs/reference/benchmarks.md` carries "M1 Max 32 GB"
section headings for exactly this reason, and its TurboQuant section carries an
explicit "measured on an M1 Max 32 GB, not this file's M4 Pro reference" note.
Before asserting anything about RAM, OOM, or bandwidth, run
`sysctl hw.memsize hw.model` — never assume which laptop you are on. The
reference `serve.sh` (below) hard-codes a 28 GB wired limit "of 32 GB", so it
is written for the M1 Max.

Perf claims get a number on the machine they were measured on, recorded in the
user-local eval DB (`~/.cache/mlx-bun/evals.sqlite`) and promoted to
`docs/reference/benchmarks.md` deliberately. `bun scripts/bench-serve.ts all`
is the benchmark harness; it writes `benchmarks-h2h-<date>-<machine>.md/.html`
in the working dir (gitignored ephemera). Numbers on a loaded machine are
garbage — run-to-run spread is the stability signal, and the harness retries
unstable cells (`scripts/bench-serve.ts`; `benchmarks.md`, "Running the
benchmark").

## The Python oracle

Logit parity with mlx-lm is the correctness oracle; mixed-precision KV and the
vision sidecar verify against mlx-optiq. The reference venv is
`/Users/joshrossi/Code/mlx-lm/.venv` — run reference scripts with
`/Users/joshrossi/Code/mlx-lm/.venv/bin/python`. Pinned versions, verified
from the installed `dist-info` directories in
`.venv/lib/python3.14/site-packages/`: mlx 0.31.2 (with mlx-metal 0.31.2),
mlx-lm 0.31.3, mlx-optiq 0.2.15, pillow 12.2.0. PLAN.md records that optiq was
bumped from 0.2.4 to 0.2.15 on 2026-07-06 and the mixed-KV goldens stayed
byte-identical across the bump. The venv directory holds no project source —
just the venv and `serve.sh`.

Readable oracle source, in that `site-packages/`: `mlx_lm/models/gemma3.py`
and `mlx_lm/server.py` for the port targets; `mlx_lm/models/cache.py` for the
cache classes; `mlx_lm/tokenizer_utils.py` for prompt rendering;
`optiq/runtime/fused_quant_sdpa.py` and `optiq/runtime/streaming_kv_quant.py`
for quantized-KV attention; `optiq/vlm/` for the vision sidecar wiring;
`optiq/auth.py` for the server's API-key rule.

The reference server is `/Users/joshrossi/Code/mlx-lm/serve.sh`. It runs
`optiq serve` on `mlx-community/Qwen3.6-27B-OptiQ-4bit` with `--mtp`, the
snapshot's `kv_config.json`, `--max-tokens 32768`, and
`--prompt-cache-bytes` = 5 GiB, inside a restart loop (mlx-lm still aborts the
process on an uncatchable Metal OOM, ml-explore/mlx-lm#854). It first raises
`iogpu.wired_limit_mb` to 28672 via `sudo sysctl` (resets on reboot). optiq's
default port is 8080 (`optiq/cli.py`). Never start it, or any long-running
server or multi-GB download, from an agent session — Josh runs servers
himself; testing against an already-running server with curl is fine.

Oracle weights for the Gemma parity work: `gemma-4-12B-it-OptiQ-4bit` at
`~/.cache/huggingface/hub/models--mlx-community--gemma-4-12B-it-OptiQ-4bit/snapshots/5b1101065d2094c8f12aa87fee80e0afa5b292b7/`
— two safetensors shards, `model.safetensors.index.json`, `kv_config.json`,
`optiq_metadata.json`, `optiq_vision.safetensors`, `chat_template.jinja`,
`config.json`, `generation_config.json` (listing verified on disk; PLAN.md
records 8.3 GB). Measured baselines for it are in PLAN.md's "Reference
environment" section and `benchmarks.md`; compare direct-vs-direct only — the
early 14.1 tok/s figure was server-inflated (PLAN.md, Phase 3 finding).

## Oracle-side hazards

**Xet stalls.** Hugging Face's Xet transfer path stalls on this network. Set
`HF_HUB_DISABLE_XET=1` before any Python-side `hf download`; our own
downloader speaks plain HTTPS and never touches Xet (`src/download.ts`
header comment; `src/memory/model.ts` prints the `HF_HUB_DISABLE_XET=1` form
in its fetch hint; `scripts/oracle/export-datasets.py`,
`scripts/turboquant/farm-setup.sh`, and `scripts/memory/eval-northstar.ts`
all set it). HF auth is configured (`hf auth login`); `src/download.ts`
`hfToken()` reads `HF_TOKEN`, else `~/.cache/huggingface/token`.

**optiq wants paths, not repo ids.** optiq tooling treats `--model` as a
filesystem path in places, so pass the local snapshot directory (the path
above), not `mlx-community/...` (PLAN.md "Reference environment"; serve.sh
passes the snapshot path for `--kv-config`).

**The vision sidecar.** `optiq_vision.safetensors` (bf16, ~105 MB per PLAN
and CLAUDE history) auto-enables in `optiq serve` when present beside the
weights and needs pillow in Python land (installed in the venv). Our registry
records the sidecar's size and notes that the shipped file actually carries
`audio_tower.*` tensors too (`src/registry.ts`, `optiq_vision` comments).

**mlx-lm's prompt cache is byte-capped.** In the pinned mlx-lm 0.31.3,
`LRUPromptCache` (`mlx_lm/models/cache.py`) takes `max_size` (default 10) AND
`max_bytes`, evicting through a typed `CacheOrder` LRU; `server.py` exposes
`--prompt-cache-bytes`. The older count-capped cache was the OOM footgun that
`serve.sh`'s 5 GiB cap works around. Ours is byte-capped too: `--prompt-cache`
(GB, default 8) is a byte-capped LRU (`server-config.md`).

**TokenizerWrapper injects `enable_thinking=True`.** mlx-lm's
`apply_chat_template` sets `kwargs["enable_thinking"] = self.has_thinking`
whenever the caller did not pass it (`mlx_lm/tokenizer_utils.py`, around
line 336). Any cross-stack parity or bench prompt must pin `enable_thinking`
explicitly or the rendered prompts drift — `scripts/bench-serve.ts` pins it
on every arm via `chat_template_kwargs`.

**pi client config.** `~/.pi/agent/models.json` currently defines an
`mlx-bun` provider at `http://localhost:8080/v1` with
`apiKey: "sk-mlx-bun-local"` (mlx-bun does not validate the key). optiq
servers DO validate: the Bearer token must start with `sk-optiq-`
(`optiq/auth.py`, `_REQUIRED_PREFIX`), so a pi provider pointed at
`serve.sh` needs such a key.

## Bun and FFI facts

**Bun ≥ 1.4.0.** `package.json` `engines.bun` is `>=1.4.0`. `Bun.Image`
(native OS codecs via ImageIO, EXIF auto-orient, off-thread) is the vision
decode path (`src/vision/preprocess.ts`); `Bun.Image.resize` is deliberately
not used. The FFI ABI fix below is the other reason for the pin.

**bun:ffi stack-argument ABI (fixed in 1.4).** Through Bun 1.3.14, `bun:ffi`
wrote one 8-byte stack slot per argument, but Apple's arm64 ABI packs stack
args at natural size, so a binding whose 9th+ int-class args put an `i32`
before more args handed the callee shifted garbage (mlx_conv2d's segfault at
0x1: the bogus value landed in the stream arg). Filed as oven-sh/bun#33672;
repro in `lab/repro/bun-ffi-stack-args/` (`repro.c` + `repro.ts`,
`ISSUE.md`). Bun 1.4.0 returns the expected values, so bindings now use
their natural mlx-c signatures — `ops.conv2d` in `src/mlx/ops.ts` passes all
eleven args plainly and the packed-u64 workaround is gone. `ISSUE.md` keeps
the original report as the regression record.

**bun:ffi symbol `.ptr` is a float64 bit-cast.** A `dlopen`'d symbol's `.ptr`
comes back bit-cast to float64, so passing it back truncates to NULL. Resolve
function addresses via `dlsym` instead — `src/mlx/array.ts` does this for
libc `free` (`RTLD_DEFAULT`, `dlsym(free)` guarded by a throw). The
supporting experiments live in `lab/repro/bun-ffi-f64/` (filed as
oven-sh/bun#32054; the same directory documents stale typed-array reads
after FFI calls once the caller is JIT-compiled).

**`Bun.mmap` SIGTRAPs above 4 GB.** JSC ArrayBuffers cap at 2^32 bytes, so
`Bun.mmap` panics on weight shards larger than that (observed on Bun 1.3.3,
still true at 1.3.14). `src/mmap.ts` binds libc `mmap`/`munmap`/`madvise`
from `/usr/lib/libSystem.B.dylib` and hands mlx raw base+offset pointers;
only small ranges (headers) are ever viewed from JS.

**Never give mlx a JS-callback destructor.** mlx releases the last
`array::Data` reference from the Metal completion thread (`gpu::eval`
retains buffers until the command buffer completes, past `dispose()`). A
`JSCallback` dtor on that thread deadlocks when the JS thread is inside a
blocking FFI eval and SIGTRAPs mid-GC (the 2026-07-06 restart-restore hang).
`src/mlx/array.ts` therefore gives every zero-copy array (`fromPointer` and
`fromView`) the native no-op dtor — libc `free` with payload 0 — and makes
host-buffer lifetime the caller's contract: weight mmaps live for the
process, restored KV is copied at load (`src/kv-store.ts` `loadKvCache`,
since 2026-07-07), and `unpinHostBuffer` runs only on the JS thread.

## Metal and mlx-c facts

**Non-page-aligned host pointers read garbage on the GPU.** Metal cannot
no-copy-wrap a host pointer that is not page-aligned: GPU ops silently read
garbage while CPU-stream ops are fine (PLAN.md Phase 1 finding, restated in
the `src/weights.ts` header). Safetensors tensor offsets are arbitrary, so
weights load through mlx's own `mlx_load_safetensors` on the CPU stream
(`src/weights.ts`, `src/lora.ts`; Load has no GPU kernel) into mlx-owned,
page-aligned buffers. Everything we DO wrap ourselves is page-aligned by
construction: the KV store file layout (`src/kv-store.ts`) and the
expert-offload file (`src/expert-offload.ts`, `src/expert-offload-build.ts`).

**Read the full mlx-c signature before binding.** A missed trailing optional
parameter shifts the stream argument and produces "There is no Stream(...)"
errors at eval time. `src/mlx/ffi.ts` is the single binding table and cites
the header each group comes from (`io.h`, `map.h`, `transforms.h`); the
`mlx_load_safetensors` row shows the shape — `(out, meta_out, path, stream)`.

**libmlxc resolution order.** `MLX_BUN_LIBMLXC` env → beside the executable
(sidecar layout, `docs/reference/distribution.md`) → `~/Library/Caches/mlx-bun/native-v<ver>-<arch>/`
(downloaded on first run, sha256-verified) → `/opt/homebrew/lib` →
`/usr/local/lib`. Dev trees and embedders never download anything. The order
is defined twice and must stay in sync: `resolveLibmlxc()` in
`src/mlx/ffi.ts` and `nativeRuntimeDir()` in `src/native-pack.ts`. Publishing
a new native pack means pasting the tarball's sha256/size into
`src/native-pack.ts` before tagging (comment block "RELEASE-TIME BAKE").

## Repo hygiene that follows from the above

`scripts/` holds production tooling only (bench-*, regen-*, parity-*, gen-*,
build/release, eval/serve) plus `scripts/{oracle,memory,turboquant}/` for
venv-side oracles, the Dreaming suite, and live TurboQuant research; research
one-offs are deleted once their finding is written into a doc. `lab/repro/`
holds self-contained reproductions for upstream bug reports (the two Bun
issues above, plus `optiq-mixed-kv-inert` and `vllm-metal-turboquant`); they
are not part of the build. Committed absolute paths (the venv, the weights
snapshot, `serve.sh`) are machine-specific on purpose — do not "correct" them.
