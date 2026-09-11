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

For the current M4 Pro optimization campaign, Josh specifies internal SSD
storage for active models. The external SSD stores artifacts to copy when
needed; external-drive loading performance is outside normal acceptance for
the 12–17 GB models. Stage each needed artifact under `~/models/`, verify
every file against its archive, and record that path in both benchmark arms.
Preserve earlier external-drive measurements as a separate cohort. The local
active-model manifests live under `reports/qwen38-rd/`.

Perf claims get a number on the machine they were measured on, recorded in the
user-local eval DB (`~/.cache/mlx-bun/evals.sqlite`) and promoted to
`docs/reference/benchmarks.md` deliberately. `bun scripts/bench-serve.ts all`
is the benchmark harness; it writes Markdown and raw JSON under `reports/`
as gitignored outputs. Numbers on a loaded machine are
garbage — run-to-run spread is the stability signal, and the harness retries
unstable cells (`scripts/bench-serve.ts`; `benchmarks.md`, "Running the
benchmark").

## External storage loading

On the M4 Pro with MLX 0.32.2, two RTN4 first-request warmups from
`/Volumes/MLX-Models`, an external USB SSD using APFS, hit Metal GPU timeouts
before any committed-token append. One occurred with fill disabled. The
system log confirms the first timeout; neither establishes an allocation
leak or an append-kernel failure. Three attention tests, a fresh four-response
external HTTP control, and a separate four-response internal-SSD control pass.
The internal copy contains the same 25 files and 15,849,971,577 bytes, each
SHA-256 verified. Its responses and final active allocation match the external
control. Copying and hashing may warm the OS file cache, so this comparison
alone does not prove that the drive caused the failures.

[MLX issue #3803](https://github.com/ml-explore/mlx/issues/3803) reports the
same failure with external storage on a different machine and much larger
models. A [maintainer recommends evaluating weights before GPU inference](https://github.com/ml-explore/mlx/issues/3803#issuecomment-4898914127)
so disk-loading tasks finish first. Our loader already assigns safetensors
loads to the CPU stream, but leaves them lazy. A research preload evaluates
each requested canonical weight once during construction. Two balanced
external-drive pairs complete all sixteen responses exactly, with identical
final active allocation. Both eager arms take longer from process start to
first complete response; moving work before readiness is not a startup-speed
win. Both ordinary arms also pass, so reliability remains unproven. This
loading change is not integrated, and further external-drive tuning is
deferred under the active-storage policy above. Evidence under `reports/qwen38-rd/`:
`fill-append-http-final-partial-review.json`, `rtn4-storage-control-manifest.json`,
`fill-append-storage-control-review.json` and `weights-loading-http.json`.

## The Python oracle

Logit parity with mlx-lm is the correctness oracle; mixed-precision KV and the
vision sidecar verify against mlx-optiq. The current working tree requires
MLX and MLX-Metal 0.32.2. On the M4 Pro, the default reference is
`/Users/joshrossi/Code/mlx-lm/.venv-mlx-0.32.2-macos14`; invoke its
`bin/python` for reference scripts. MLX-LM remains 0.31.3. The shared resolver
checks installed MLX/Metal versions and rejects an incompatible explicit
`MLX_BUN_ORACLE_VENV` instead of silently selecting another environment.

The earlier reference at `/Users/joshrossi/Code/mlx-lm/.venv` remains an
old-runtime control. Its historical pins were verified
from the installed `dist-info` directories in
`.venv/lib/python3.14/site-packages/`: mlx 0.31.2 (with mlx-metal 0.31.2),
mlx-lm 0.31.3, mlx-optiq 0.2.15, pillow 12.2.0. PLAN.md records that optiq was
bumped from 0.2.4 to 0.2.15 on 2026-07-06 and the mixed-KV goldens stayed
byte-identical across the bump. The venv directory holds no project source —
just the venv and `serve.sh`.

The Qwen MTP compatibility test accepts explicit local artifact paths through
`MLX_BUN_TEST_MTP_TARGET` and `MLX_BUN_TEST_MTP_DRAFT`, alongside
`MLX_BUN_TEST_QWEN38_MTP=1`. It compares speculative and ordinary greedy
generation on that same target and prints both paths. This does not substitute
one quant for another in the pinned logit-oracle tests.

**M4 Pro installation checked 2026-09-04:** the same venv path on
`Joshs-MBP-2025.local` currently uses `lib/python3.13/site-packages`, with
mlx/metal 0.31.2, mlx-lm 0.31.3 and mlx-optiq **0.2.7** from installed
dist-info metadata. The older python3.14/OptiQ 0.2.15 record above is not the
installed stack on this Mac. Record actual interpreter/package/native-library
versions for every comparison; preserve this oracle as the 0.31.2 control.
Qwen artifacts are also present under
`/Volumes/MLX-Models/models/{Qwen,mjriii}/`; header-only inventories under
`reports/qwen38-rd/` are machine-local and do not load the GPU.

**Authorized M4 Pro runtime update, staged 2026-09-07:** MLX 0.32.2 with
MLX-C `c74db5307cc8ce122f48d97ef951b30578674e7f` is built under
`reports/qwen38-rd/mlx-upgrade-0.32.2/install/lib/`. Explicit
`MLX_BUN_LIBMLXC=<that-directory>/libmlxc.dylib` selects it per process.
The original Homebrew MLX 0.31.2 and MLX-C 0.6.0 revision 2 remain installed.
The staged core uses the official macOS 26 arm64 MLX-Metal wheel, with verified
archive hashes and relocatable library dependencies. This local artifact does
not change the published native pack or its minimum supported macOS version.
The source-build attempt failed because the offline Metal toolchain is absent;
building the C wrapper against the official native libraries succeeded.

The matching reference is `/Users/joshrossi/Code/mlx-lm/.venv-mlx-0.32.2`,
selected through `MLX_BUN_ORACLE_VENV`. Its Python remains 3.13.5; MLX and
MLX-Metal change to 0.32.2 while all other 62 package pins match the old venv,
including MLX-LM 0.31.3 and OptiQ 0.2.7. Installation and dependency checks pass.
Keep runtime and reference overrides paired. The macOS 26 build remains an
explicit comparison build. The working tree now selects the macOS 14 package
candidate described below. Build manifests, package freezes and gate results
live under the upgrade report directory.

The package candidate also has an official macOS 14 build of MLX-Metal 0.32.2,
with MLX-C compiled for 14.0 under `install-macos14/lib/`. Its matching Python
reference is `/Users/joshrossi/Code/mlx-lm/.venv-mlx-0.32.2-macos14`, with the
same 64 package versions as the macOS 26 reference and a passing dependency
check. Both builds pass the twelve-cell RTN4 same-version logit/state oracle
comparison. The macOS 14 candidate additionally passes the actual 4K prompt
and 8K extension, with complete logits and live cache state checked against
its matching reference. After the Trellis arithmetic port, the model-free
suite passes 1,882 tests with ten skips on the new core and 1,881 tests with
eleven skips on the old core. The local native-pack
candidate under `native-pack-candidate/` extracts into `native-pack-extracted/`;
all five Mach-O files target 14.0, have valid ad-hoc signatures and load their
non-system dependencies from siblings. These checks ran on macOS 27, not an
actual macOS 14 host. This build is published as native pack 0.4.0 and the
verified local cache is
`/Users/joshrossi/Library/Caches/mlx-bun/native-v0.4.0-arm64`. Publication
details are in distribution.md. The consolidated source passes 52 complete Qwen
forward/state/continuation cases and six Trellis generations, with fixed
source/runtime/reference hashes and clean worker exits. The consolidated
model-free suite passes 1,875 tests with ten skips; all typechecks pass.
Integrated inverse-KV serving response gates also pass. The broader
same-version reference gate passes all eighteen MiniCPM5, Llama 1B and Gemma
e4b cases after matching MLX-LM's compiled MiniCPM5 prefill activation.
Run `MLX_BUN_TEST_RUNTIME_ORACLE=1 bun test tests/parity/runtime-oracle.test.ts`
to repeat these logit, live-cache and continuation comparisons against the
matching reference. It skips unavailable artifacts, runs the Bun and Python
children sequentially and does not rewrite goldens. Combined/pressure
acceptance remains.
The frozen old source lives outside Bun's
test discovery at
`/Users/joshrossi/.cache/mlx-bun/runtime-controls/mlx-0.31.2-before-0.32.2/`.
Preserve its `snapshot.json` and source for old-runtime comparisons when
simplifying production bindings. The build directories are under the upgrade
report directory, whose `control-location.json` records the verified move.
The accepted new-core source before binding consolidation is also frozen at
`/Users/joshrossi/.cache/mlx-bun/runtime-controls/mlx-0.32.2-before-consolidation/`.
Its 932 files and the six locally installed native files were hash-verified;
`consolidation-preparation.json` records the copy and local installation.

The small DeltaNet fixture also depends on the oracle/runtime. On the M4 Pro
with the pins above, both Bun and Python differ from the June fixture at one
prefill output; their gate values, outputs and complete recurrent states agree
exactly. The fixture was explicitly replayed on 2026-09-05 with unchanged
inputs. It now records package/device/source provenance and exact state hashes.
No numerical tolerance changed. `scripts/oracle/gen-qwen-delta-golden.py
--replay tests/fixtures/qwen-delta-golden.json --output <review-file>` reproduces
the comparison under the pinned Python. Without `--output`, the M4 Pro writes
the reference fixture; other chips write a `goldens/<chip>/` override, which
the test resolves before the reference. Earlier oracle comparisons and the
single-value diff are in `reports/qwen38-rd/delta-*.json`.

CI explicitly replays those unchanged inputs through MLX-LM 0.31.3 on
MLX/MLX-Metal 0.32.2 before testing, saving a runner-chip override and its
provenance as a workflow artifact. This avoids comparing the macOS 14 runner
against an M4 Pro output fixture. The test still requires exact output and
state hashes; Python runs only the external reference. Trellis variant
matrix tests allow 30 seconds for first-use kernel compilation on CI.

The M1 Max override was replayed on 2026-09-08 with the same inputs using
`/Users/joshrossi/Code/mlx-lm/.venv-mlx-0.32.2-macos14` (MLX/MLX-Metal
0.32.2, MLX-LM 0.31.3). Bun matches its outputs and recurrent-state hashes
exactly. The review file is
`reports/qwen38-closeout/qwen-delta-m1-review.json`.

Qwen3-Embedding tests also resolve `goldenPath("qwen3-embed")`, including
machine overrides, and skip when their required binary blobs are absent.
Regenerate with the matching Python and
`scripts/oracle/gen-qwen3-embed-golden.py <artifact> --replay goldens/qwen3-embed/meta.json`;
`--output-dir` selects a review directory. Replay preserves the text and token
IDs and checks the tokenizer against them. Metadata records the device,
runtime, artifact config, original metadata and output hashes. The M1 Max
replay matches hidden states and pooled embeddings exactly. Cosine uses both
vector norms: bf16 normalization does not guarantee a unit norm when the
result is subsequently read as float32.

The same M1 validation found June MiniCPM logit blobs without runtime
provenance. Explicit `bun scripts/regen.ts minicpm5` with the matching venv
preserves the artifact, prompt IDs and greedy trajectory; the regenerated
logits match Bun exactly. The generator now records runtime/device/config
provenance and all blob hashes. The old files and reviewed differences remain
under `reports/qwen38-closeout/minicpm5-golden-before/` and
`minicpm5-golden-review.json`.

The Gemma bf16 and mixed-KV M1 replays also pass with unchanged prompt IDs
on MLX 0.32.2. This current M1 venv contains **mlx-optiq 0.2.7** by installed
distribution metadata, matching the documented M4 installation; it is not
the historical 0.2.15 environment. OptiQ's module `__version__` incorrectly
reports 0.2.5 there, so regeneration records distribution metadata. Old
fixtures remain under `reports/qwen38-closeout/{parity,mixed-kv}-golden-before/`.
These are current-stack parity checks, not a runtime-only A/B against the
older mixed-KV fixture's 0.31.2/0.2.15 combination.

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

**Development and CI: Bun 1.4.2.** Build the committed frontend bundle with
that version so its byte-for-byte freshness check uses the same compiler.
Performance comparisons record the runtime and use the same version in both
arms; historical results retain their original version.

Non-login SSH on the M4 Pro can omit `/Users/joshrossi/.bun/bin` from `PATH`.
Put that directory on the remote command's PATH when running the test suite:
launching the parent Bun by absolute path alone does not let subprocess tests
find `bun`. The quantized-row validation's initial seven command-entry/job
failures disappear with that invocation corrected; no product code change was
needed for those failures.

**Runtime minimum: Bun ≥ 1.4.0.** `package.json` `engines.bun` is `>=1.4.0`. `Bun.Image`
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

**bun:ffi symbol `.ptr` is fixed in 1.4.** Direct function addresses match
`dlsym` on both 1.4.0 and the isolated 1.4.2 runtime. `src/mlx/array.ts` now
uses the numeric `free.ptr`, with a validity guard and a process-lifetime
library handle. Native destructor ownership remains unchanged.

**FFI typed-array readback still needs `read.*`.** The standalone
`lab/repro/bun-ffi-f64/` hot-loop repro still produces stale indexed reads on
1.4.0 and 1.4.2, despite the upstream issue being closed. Keep the native
out-param read helpers. The stack-argument repro passes on both versions.
Raw runtime binaries, hashes and outcomes are recorded in
`reports/qwen38-rd/bun-runtime-audit/`; the installed runtime and pinned Python
oracle were not upgraded. Bun's [1.4 release notes](https://bun.com/blog/bun-v1.4)
describe its new FFI implementation, while [1.4.2](https://bun.com/blog/bun-v1.4.2)
fixes the intervening AsyncLocalStorage regression. Release claims do not
replace these local regression checks.

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

**`mlx_copy` shares storage.** In pinned MLX 0.31.2, `Copy::eval` calls
`copy_shared_buffer`. Neither `ops.copyOf` nor `contiguous` guarantees a
small independent allocation for a contiguous view. Explicit disposal drops
handles but a surviving view can retain its entire source allocation.
`src/mlx/materialize.ts` uses the stock dynamic-slice kernel, which allocates
the output's logical size and supports gradients. The Qwen convolution state
uses it to release large prefill buffers. Byte, pointer, retained-memory,
compiled execution and gradient gates live in `tests/unit/materialize.test.ts`;
the direct storage probe is `reports/qwen38-rd/copy-alias-probe.json`.

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

The quantized-KV golden producer (`bun scripts/regen.ts kvq`) passes an absolute output directory to Python, since the child runs from `scripts/`. This preserves the selected machine directory and existing prompt IDs. Missing M4 blobs were regenerated from the pinned oracle into the isolated `delayed-affine-m4-oracle` override; numerical expectations were not produced by the inference implementation. Evidence: `reports/qwen38-closeout/composition-baseline/oracle-generator-path/`.

The M1 rotating-KV reference still identified MLX 0.31.2 and disagreed with both unchanged control and candidate on the KV8 greedy prefix. Regeneration with pinned MLX 0.32.2 retains the prompt IDs and passes exact logits plus both continuation checks. The matching M1 override and M4 reference caches are refreshed; previous manifests/blobs and provenance are retained with the generator-path evidence.
