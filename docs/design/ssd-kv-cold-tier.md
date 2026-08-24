# SSD cold tier for the prompt/KV cache

Status: **LANDED P1–P3 (2026-07-02, same day)** — P4 hardening extras remain.
**Layer-0 upgrade (2026-07-05, unified-engine plan):** D2 finished properly —
the two-tier take/restore/trim dance moved INSIDE `PromptCache.take()`
(structural `ColdTier` interface; the server binds SsdCacheStore + model into
it), so EVERY consumer tiers automatically: the serial lane's hand-rolled
block in runGeneration is gone, and the BATCH SCHEDULER restores prefixes
from disk at admission (gated end-to-end: tests/batch-scheduler.test.ts
"SSD tier through the batch lane"). `PromptCache.onPut` drives the debounced
write-behind snapshot for both lanes' puts. NEW: **idle demotion**
(`--ssd-demote-idle`, default 300 s with the tier on) — entries unused past
the threshold spill to disk and free their GPU arrays; RAM drains between
agent bursts while prefixes stay reachable via zero-copy restore. The sweep
runs only when the gateway is fully idle (a runExclusive would otherwise
drain a live batch). Rationale (Josh): prefill is the cost being avoided —
12B prefill is 168 tok/s, so a 30k agent context is ~3 min of GPU compute vs
a ~1 s NVMe restore; SSD-vs-RAM (40×) is the wrong comparison, SSD-vs-
recompute (50–180×, growing with context) is the real one.

**Measured (M1 Max, MiniCPM5, 13.7k-token prefix, kv_config quant):**
- Restart TTFT: **12,083 ms (full prefill) → 236 ms** restored — 2% of full
  prefill, 13,675 tokens back via a 3 ms zero-copy mmap. Beats oMLX's 1–3 s
  claim and both exit criteria (<2.5 s, ≤10%).
- Steady-state decode: **0% overhead** (192.0 vs 192.3 tok/s, flag off/on) —
  nothing runs on the token loop, as designed (vs oMLX's measured ~20%).
- Correctness: SSD-restored + trimmed continuation is **identical to the RAM
  tier's cache-hit output** (control experiment); divergence from a fresh
  full prefill is the pre-existing bf16 prefix-reuse property both tiers
  share, not introduced by persistence.

What landed: kv-store v2 (`src/kv-store.ts` — all five cache kinds incl.
quantized + SSM, invalidation metadata, per-tensor hashes, atomic writes;
`restoreState` added to both quantized cache classes), `src/ssd-cache.ts`
(SsdCacheStore per D4), tier integration (`src/prompt-cache.ts` spill hook +
retain thunks; `src/server.ts` tiered take with post-restore trim,
debounced write-behind snapshots under the gateway lock, `/stats.ssd_cache`),
flags `--ssd-cache <dir>` / `--ssd-cache-max <GB>` / `--ssd-cache-verify`.
Tests: `tests/kv-store.test.ts` (fork-compare token-identical for bf16,
quantized, SSM), `tests/ssd-cache.test.ts` (restart recovery, quarantine,
corruption, eviction, supersede). One deviation from the plan below: find()
returns PARTIAL prefix matches and the server trims after restore
(divergent-tail conversations — full-entry-only missed the real pattern). Inspired by oMLX's paged SSD cache
(Apache 2.0 — `omlx/cache/paged_ssd_cache.py`, `boundary_snapshot_store.py`;
we port ideas, not code — add a `THIRD_PARTY_LICENSES.md` note if any code
ends up derived). Their headline: coding-agent TTFT 30–90 s → 1–3 s by
restoring long prefixes from SSD across requests AND restarts. Their
measured costs (independent tests): ~2–3× cold TTFT and ~20% steady-state
decode overhead — this design exists to get the win without those costs.
Flag-gated, off by default.

**Head start**: `src/kv-store.ts` already implements page-aligned KV
persistence (`MLXBUNKV1`, 16 KiB-aligned tensors) with zero-copy COW mmap
reload (`MmapFile.open(path, "cow")` → `MlxArray.fromPointer` — exactly
the Metal page-alignment constraint, proven by expert-offload), including
mid-rotation `RotatingKVCache` restore (`restoreState`,
`src/model/gemma4-base.ts:880`). `cold-start.ts (deleted 2026-08-23; git history)` is a
working sub-1 s cold-restore harness. The SSD tier is wiring +
quantized-cache support + an index/eviction/recovery layer.

## Current state / gaps

- `src/prompt-cache.ts`: byte-capped LRU RAM tier (default 2 GB,
  `--prompt-cache`), prefix-entry based, adapter-namespaced, serial lane
  only, race-free under the gateway lock. **A restart loses everything.**
- `kv-store.ts` gaps: (1) no quantized kinds — `saveKvCache` throws for
  `QuantizedKVCache`/`RotatingQuantizedKVCache` and neither has
  `restoreState`, yet serving defaults to the model's `kv_config.json`
  scheme, so the default production cache can't persist today; quantized
  state is 6 arrays/layer (packed u32 + scales/biases bf16 × K/V);
  (2) no invalidation metadata / checksums / atomic writes; (3) latent
  bug: `loadKvCache` checks `caches.length !== model.layers.length` but
  `makeCache()` returns donor layers only — wrong for KV-shared e4b
  (verify in Phase 1).
- Versioning primitive exists: `configFingerprint`
  (`src/model/fingerprint.ts`) — sha256 over graph-shaping config incl.
  `kvQuant`.

## Design decisions

**D1 — Whole-prefix-entry spill, not paged blocks.** oMLX pages for
multi-user shared-prefix dedup; we are single-user with a prefix-entry
cache that grows monotonically per conversation. Paging is exactly where
their overheads come from: per-block SHA256 + save-queue bookkeeping
*during decode* (their ~20% tax) and block-granular safetensors restore
with copies (their 2–3× cold TTFT). Ours: **zero work on the token loop**
(prefix tokens ARE the key), spill/persist only at request boundaries and
evictions, restore = one zero-copy mmap with lazy page fault-in (~5 GB/s
NVMe; 2 GB entry ≈ 0.4 s amortized into the first forward). Partial-prefix
reuse works without paging: restore + `Cache.trim()`. Revisit paging only
for multi-user batch dedup (v2, out of scope).

**D2 — One store, two tiers.** `PromptCache` grows a cold tier behind the
same `take`/`put` API:
- RAM→SSD: `put()`'s evict loop spills (snapshot bytes → async writer →
  dispose GPU arrays) instead of just disposing.
- SSD→RAM: `take()` prefers a strictly-longer SSD prefix; restored entry
  carries its `MmapFile`, unmapped on entry dispose (extensions copy into
  fresh anonymous buffers via concat-grow anyway).
- **Restart persistence needs write-behind at request completion**, not
  just spill-on-evict: after `promptCache.put(...)` in `runGeneration`
  (`src/server.ts:1019`), a debounced, coalesced-per-ns async snapshot.
  Byte extraction (the only GPU-thread work) runs on the idle serial lane
  between requests; file I/O is async. (oMLX's boundary-snapshot idea at
  whole-entry granularity.)

**D3 — Extend the existing format to `MLXBUNKV2`**, not safetensors
(safetensors offsets aren't page-aligned; oMLX pays a copy via `mx.load`).
Add: `"qkv"`/`"rotating-qkv"` kinds (six tensor slots + groupSize/bits;
slice quantized buffers to `[.., :offset, :]` — don't persist 256-step
slack), header fields `formatVersion`/`modelId`/`configFingerprint`/`ns`/
`tokenizerHash`/`createdAt`, per-tensor checksums + header checksum.
Integrity: header checksum always verified on scan; full verification
opt-in (`--ssd-cache-verify`) because eager reads destroy lazy fault-in;
default trusts atomic writes (tmp + fsync + rename). Corrupt/incompatible
→ delete + log, never fatal. `loadKvCache` becomes model-generic
(accept `{ makeCache(): Cache[] }`, donor-count check).

**D4 — Files are the database.**
`<ssd-dir>/<configFingerprint>/<nsHash>/<uuid>.mlxkv`. Startup recovery =
header-only directory scan → in-memory `SsdIndex`
(`{ns, tokens, path, bytes, mtimeMs}[]`); tokens live in the header JSON.
LRU = file mtime (`utimes()` on hit); byte cap enforced at write time by
oldest-mtime eviction; disk-full → drop write, warn once, keep serving.

**D5 — Flags & interactions.** `--ssd-cache <dir>` +
`--ssd-cache-max <GiB>` (default 32) → `ServerOptions.ssdCacheDir/MaxBytes`.
Requires the RAM tier (`--prompt-cache 0` + `--ssd-cache` = startup
error). `--memory-budget` unchanged (restored caches are clean file-backed
pages until dirtied; admission already assumes worst-case bf16). `/status`
gains `ssd: { entries, bytes, max_bytes, restores, spills, restore_ms_last }`.
v1 is serial-lane only (where `PromptCache` lives); batch-lane interplay is
docs/design/batching-perf-path.md P3's problem.

## Phases

- **P0 — Baseline bench (½ d)**: `ssd-cache-bench.ts (deleted; git history)`
  grown from `cold-start.ts`: ≥16k-token prefix on the standard snapshot,
  kv_config quant active; measure full-prefill TTFT / warm RAM-hit TTFT /
  steady-state decode. Exit: baseline table committed.
- **P1 — kv-store v2 (2–3 d, highest uncertainty)**: `restoreState` on
  both quantized cache classes; all four kinds in save/load; header v2;
  atomic writes; model-generic load. Exit: round-trip tests all kinds
  (incl. wrapped ring) + **greedy decode parity** — N tokens continued
  from a restored cache bit-exact vs never-persisted; `tsc` 0.
- **P2 — `src/ssd-cache.ts` store (1–2 d)**: `SsdCacheStore
  { scan, find(prompt, ns), store (async, extraction split from I/O),
  evictToCap, remove, stats }`. Exit: unit tests — restart recovery,
  incompatible-fingerprint quarantine, corrupt-header deletion, mtime cap
  eviction, disk-full soft-fail.
- **P3 — Tier integration + flags (2–3 d)**: cold tier in `PromptCache`,
  debounced end-of-request snapshots, CLI/`/status`. **Exit (headline)**:
  (1) restart TTFT on a 16k prefix **< 2.5 s and ≤ 10% of full-prefill**
  (beat oMLX's 1–3 s; a true-cold miss runs the unchanged prefill path);
  (2) steady-state decode overhead **< 2%** vs flag off (vs their ~20%);
  (3) flag absent ⇒ zero behavior change.
- **P4 — Hardening + docs (1–2 d)**: kill-during-write crash test,
  adapter-ns isolation, kv-quant-scheme-change invalidation, README/help,
  license note. Exit: suite green; on/off × cold/warm/restart matrix
  recorded.

Total ~7–10 working days.

## Risks

- **mmap lifetime vs mlx laziness**: unmap only in entry `dispose()` after
  successor state is evaluated; COW mapping already covers buffer donation.
- **Byte-extraction stall on multi-GB entries**: runs between requests on
  the idle lane; measure in P3; chunk with yields if needed.
- **COW dirty-page accounting**: extended restored caches migrate to
  anonymous memory — probe with `phys_footprint` (expert-offload
  discipline) before making footprint claims.
- **Stale-token poisoning**: `configFingerprint` + `tokenizerHash` + ns;
  chat-template drift degrades to a shorter matched prefix (safe).

## Addendum 2026-07-07 — A7 closure: bounded memory on BOTH sides of the file

The 07-06/07 serve benches flagged elevated ctx/restart-leg RSS on
--ssd-cache arms ("A7"). Root-caused in three parts; the first two were
real defects, both fixed in `src/kv-store.ts`:

- **Write side** (residual after the v3 streaming writer of 4f9bad9): the
  per-tensor `rawBytes()` readback ended in a JS-heap `.slice()`; under GC
  lag the dead copies outlive the flush loop, re-spiking RSS toward the
  whole entry. The writer now hashes and writes from a ZERO-COPY view of
  the contiguous mlx buffer (`MlxArray.rawBytesView`) — no JS-heap copy
  exists at any point; save-transient mlx memory measured 0 bytes for
  contiguous sources (one tensor otherwise).
- **Restore side** (never covered by A7's original scope): the zero-copy
  restore (COW mmap + `fromPointer`) became a per-restore PROCESS-LIFETIME
  mapping leak once the 2026-07-06 FFI-dtor fix removed the unmap signal,
  and the exactly-offset-sized restored buffers made the first
  post-restore decode step concat-copy the entire entry into fresh mlx
  memory. Restore is now a **streamed copy** — each tensor is copied into
  an mlx-owned leaf (`fromBytesCopy`, no dtor contract), its clean file
  pages dropped (`MADV_DONTNEED`; tensor offsets are 16 KiB-aligned = the
  arm64 page size), the mapping unmapped before `loadKvCache` returns, and
  plain-KV tensors land in STEP-rounded capacity with ≥1 token of slack so
  the first step updates in place. Measured (512 MB synthetic entry): mlx
  peak during restore+first-step = live entry + ONE tensor (552 vs 520 MB
  active); `vmmap` confirms no `.mlxkv` mapping survives; 12B real-model
  cold cache-load → first token 277 ms (parity with the old zero-copy
  ~240 ms claim — the old path paid the same whole-entry copy on the first
  decode step anyway). Byte identity of the copy-restore is pinned for all
  five cache kinds (save → load(verify) → re-save hash-identical;
  tests/kv-store.test.ts "copy-restore byte identity") plus the real-model
  bf16/quantized/SSM continuation suites.
- **What was NOT a defect**: most of the benched leg delta is `ps` RSS
  ACCOUNTING — the write-behind's hash+write CPU-touches the live KV
  entry, which makes those already-allocated unified-memory pages visible
  to `ps` (GPU-written buffers and python-arm KV never show). The bench
  report now footnotes this instead of promising a pending fix.

Supersedes the D2 line "restored entry carries its MmapFile, unmapped on
entry dispose" and the D1 "restore = one zero-copy mmap with lazy page
fault-in" mechanics above — the economics (SSD-vs-recompute) and the
zero-work-on-token-loop property are unchanged.

## Addendum 2026-07-07 — write-behind scheduling contract: flush only while idle

The 07-07 serve bench showed decode@ctx losing to mlx-lm on the bun arms
(e4b −9.3%, 12B −3.9%) while short-ctx decode won on every model — and the
mixed arm (4× smaller flush bytes) BEAT the bf16 arms at decode@ctx. Root
cause: "non-blocking" write-behind was only non-blocking at the event-loop
level. Every per-tensor flush step is (1) `ops.contiguous` — a kernel on
the SAME GPU stream decode uses — then (2) `rawBytesView()` → a synchronous
`mlx_array_eval` that blocks the JS thread until the stream drains, then
(3) a synchronous multi-MB `writeSync`. The `setImmediate` pacing
interleaved those slices exactly between decode tokens, so a ~16k entry's
flush overlapping the bench's cached ctx repeats taxed their 64-token
decode windows (reproduced standalone: e4b 9.5k-token entry, repeat decode
37.9 vs cold 47.1 tok/s; flat 44–46 across all three samples post-fix).
mlx-lm runs no equivalent background work — the gap was pure self-inflicted
contention.

**The contract now:** the flush only progresses while the engine is idle.
- `GenerationGateway.busy` covers BOTH lanes (mutex held/awaited — the
  serial lane shows zero rows — OR batch rows active/pending);
  `gateway.onIdle()` is the poll-based waiter (`generation-gateway.ts`).
- `saveKvCacheAsync`/`SsdCacheStore.storeAsync` accept a per-step
  `waitTurn` gate awaited before EVERY tensor step (including the first),
  so a request arriving MID-flush pauses the remaining tensors until idle
  again; the server passes `() => gateway.onIdle()` at both chain sites
  (write-behind snapshots AND eviction/demotion spills). Gate failures are
  swallowed — scheduling advice must never corrupt the write path.
- `MLX_BUN_SSD_WRITEBEHIND=0` disables write-behind snapshots entirely
  (kill switch + paired-A/B lever; restart survival then degrades to
  spill-on-evict only).

Accepted tradeoffs: durability waits for a quiet moment (single-user
serving quiesces constantly; sustained hammering defers the flush AND the
spill clones' GPU-memory release, bounded by the serial chain); one
in-flight tensor step (~10–15 MB) can still land ahead of a just-arrived
request; and the restart window tightens — the flush now runs in idle gaps
instead of overlapping decodes, so the bench's 2.5 s pre-kill beat must
absorb it (verified surviving: e4b 9.5k entry, restart cached=9575 with
the gate on).

## Addendum 2026-07-07 (later) — bounded retention + admission-safe snapshots

The post-merge review found two operational holes in the contract above:

1. **Snapshot timer could stall batch admission.** `scheduleSsdSnapshot`'s
   debounced timer fired `gateway.runExclusive` unconditionally; the
   exclusive registers a serial WAITER, which holds batch admission until
   every running row drains naturally — a background durability timer
   periodically freezing admission under `--batch N` sustained load. Fixed
   with the same guard `demoteIdle` always had: the timer checks
   `activeRows/pendingRows` first and RE-ARMS (5 s, unref'd) while busy —
   entries are immutable, a late snapshot is equally valid.
2. **Starved-gate clone retention was unbounded.** Every eviction/demotion/
   snapshot chained GPU-pinning zero-copy clones onto a bare serial promise
   chain, and every flush step awaits `onIdle()` — under continuous traffic
   the chain starves and resident memory = prompt-cache cap + every queued
   clone, defeating the byte cap exactly under the load causing evictions.
   Now all three producers go through **`SpillQueue`** (kv-store.ts):
   queued bytes are capped (default 2 GB = a quarter of the 8 GB RAM-cache
   default; `MLX_BUN_SSD_SPILL_QUEUE_GB` overrides) — over cap the OLDEST
   not-mid-store item drops with its clones disposed immediately. A dropped
   spill is a future cache miss, never a wrong result: the contention-free
   alternative to letting the flush cut into decode. `/stats.ssd_cache`
   exposes `pending_spills` / `pending_spill_bytes` / `dropped_spills`.

Explicitly accepted (documented, not built): **no shutdown flush** — a
SIGINT/SIGTERM during (or within the debounce after) traffic loses queued
write-behind entries; restart survival degrades to whatever already
flushed. This is a best-effort cache tier; the cost of a lost entry is one
re-prefill. `SpillQueue.drain()` exists if a shutdown hook is ever wanted.

This acceptance was superseded by the 2026-08-22 durability fix below.

## Bug brief 2026-08-22: restart can outrun SSD write-behind

### User-visible failure

A completed long-context request can report a full RAM-cache hit on repeat,
then lose that prefix when the server restarts a few seconds later. The next
request pays a full prefill even though `--ssd-cache` was enabled.

The 2026-08-22 M1 Max serve matrix reproduced this with the standard restart
leg, which waits 2.5 seconds after the long request before sending SIGTERM:

| model and mode | cached tokens after restart | expected |
|---|---:|---:|
| MiniCPM5, unified bf16 | 15,817 | about 15.8k |
| e4b, unified bf16 | 4 | about 15.9k |
| e4b, serial bf16 | 15,940 | about 15.9k |
| 12B, unified bf16 | 4 | about 15.9k |
| 12B, serial bf16 | 15,866 | about 15.9k |
| Qwen3.8, unified bf16 | 0 | about 15.1k |
| Qwen3.8, serial bf16 | 0 | about 15.1k |
| Qwen3.8, unified mixed KV | 15,112 | about 15.1k |

The Bun 1.4 rerun reproduced the lane split before this brief was written:
e4b unified restored 2 of 15,942 tokens, while e4b serial restored 15,939.
The completed run also restored only 4 tokens for unified 12B versus 15,794
for serial 12B, and 5 for mixed-KV 12B. Qwen bf16 restored zero in both
lanes, while mixed-KV Qwen restored all 15,114 tokens. This is not a Bun
1.3-only result.

### Expected contract

After a request completes and the server has reported the cache durable, a
normal SIGTERM and restart must restore the longest compatible prefix. For
the benchmark's exact-repeat request, `cached_tokens` should be at least
`prompt_tokens - 1`. The server must never imply durability while a matching
snapshot is still waiting on its debounce timer or the spill queue.

### Evidence and current diagnosis

The read and reconstruction path works when the file reaches disk. MiniCPM,
serial e4b and 12B, and mixed-KV Qwen all restore a full prefix through the
same `PromptCache.take()` and `SsdCacheStore.restore()` path. That makes a
model-format or prefix-matching defect unlikely as the primary cause.

The likely failure is the durability boundary:

1. `PromptCache.onPut` schedules a snapshot with a one-second debounce.
2. A busy gateway re-arms that timer for five seconds.
3. The snapshot then joins a serial `SpillQueue`; large bf16 entries can still
   be queued or in flight when the benchmark's 2.5-second wait expires.
4. SIGTERM stops the process without forcing pending timers to fire or awaiting
   `SpillQueue.drain()`. The queue's own comment calls drain a future shutdown
   hook.

Entry size explains the broad pattern. Small MiniCPM and smaller mixed-KV Qwen
files finish in time; large Qwen bf16 files do not. The remaining unified versus
serial split needs telemetry before assigning a second root cause. The unified
lane may enqueue more snapshots, take longer to extract row caches, or hit the
queue cap. The current report does not capture that state before termination.

### Fix plan

1. Expose `pending_snapshots`, `pending_spills`, `pending_spill_bytes`,
   `dropped_spills`, and the longest durable prefix in `/stats.ssd_cache`.
   `pending_snapshots` must include debounce and busy-rearm timers, not only
   entries already placed in `SpillQueue`.
2. Add one async durability operation that cancels debounce timers, snapshots
   matching RAM entries under the gateway lock, and awaits
   `SpillQueue.drain()`. Return success only after the atomic rename completes.
3. Route graceful SIGINT/SIGTERM through that operation with a bounded timeout.
   Stop new admission first. A timeout may drop the cache, but must log the
   number of pending and dropped snapshots.
4. Change the benchmark restart leg to request or poll durability instead of
   sleeping for 2.5 seconds. A fixed sleep measures SSD timing luck, not the
   restart contract.
5. Capture pre-kill stats and the recovered entry count in every restart row so
   a write miss cannot masquerade as a restore miss again.

### Implemented 2026-08-22

- `SsdDurabilityCoordinator` owns debounce, busy retry, queue completion, and
  explicit flush as one state machine. A snapshot stays dirty until the atomic
  store succeeds. Queue drops and write failures remain retryable.
- Dirty keys include the exact token sequence, so two conversations with the
  same namespace and token count cannot cancel each other.
- `POST /admin/cache/flush` returns `200` only at the durability boundary and
  exposes pending, dropped, failed, entry-count, and longest-prefix evidence.
- `mlx-bun serve` handles `SIGINT` and `SIGTERM` by stopping admission,
  draining active requests, and awaiting the same flush, bounded by
  `MLX_BUN_SHUTDOWN_TIMEOUT_MS`.
- The standard restart benchmark calls the endpoint instead of sleeping and
  records its evidence in the Markdown report and eval database notes.
- Model-free regression coverage holds an atomic store open and proves flush
  waits, forces the busy-rearm path, retries a failed write, preserves
  equal-length conversations, and reports a missing RAM boundary honestly.

Focused real-server smoke on unified e4b passed the repaired path: a
4,026-token prompt flushed in 408 ms with `durable=true`, zero pending,
dropped, or failed work, then restored 4,025 cached tokens after SIGTERM and
respawn. The machine failed the clean-performance preflight, so this is cache
correctness evidence only, not a performance result. The full clean 16k
e4b/12B/Qwen matrix remains the acceptance run.

### Acceptance tests

- A deterministic coordinator test holds `storeAsync`, requests a flush,
  releases the store, and proves the durability boundary waits for the atomic
  file. The focused real-server smoke exercises the SIGTERM path through that
  same operation before restart.
- A busy-gateway test forces the five-second re-arm path, then requests a flush
  and proves the timer becomes an immediate queued snapshot without blocking an
  active generation.
- Batch 8 and `--batch 1` both restore at least `prompt_tokens - 1` for e4b,
  12B, and Qwen3.8 at roughly 16k context.
- The mixed-KV and SSM cache kinds retain their existing continuation parity.
- Steady-state decode remains unchanged because normal writes still pause while
  the engine is busy. Queued clone memory stays within the spill cap.

Focused reproduction:

```sh
bun scripts/bench-serve.ts all --models e4b,12B,qwen27b \
  --arms mlx-bun,mlx-bun-serial,mlx-bun-mixed
```
