---
status: landed
axis: ON
canonical-for: kv-cache
plan-anchor: "Phase 18 — Concurrent / batched serving (slots) + parallel load benchmark `[~]` (2026-06-13)"
last-verified: 2026-08-23
---

# KV cache — residency and layout

The one doc for where KV lives and how it is arranged: the cache classes
and their `signature()` capability model, the RAM prompt cache
(`PromptCache.take()`), the SSD cold tier and its durability boundary, the
optional paged block allocator, and how KV *schemes* plug into all of it.
The TurboQuant codec itself is documented in
[docs/design/turboquant.md](./turboquant.md); this doc only covers how its cache
class participates in residency.

Sources consolidated here: `docs/design/kv-cache.md`, `docs/design/kv-cache.md`, and
the cache-integration parts of `docs/design/turboquant.md`. Status and changelog
prose lives in PLAN.md; this file keeps mechanism, invariants, decisions,
and open items.

Code: `src/model/gemma4-base.ts` (Cache interface + the K/V cache family),
`src/model/batched-*.ts`, `src/lab/paged-kv/paged-kv.ts`, `src/prompt-cache.ts`,
`src/kv-store.ts`, `src/ssd-cache.ts`, `src/ssd-durability.ts`,
`src/kv-scheme.ts`, `src/generate.ts` (`maybeQuantizeKv` / `maybePageKv`),
`src/server.ts` (wiring, `/stats`, `POST /admin/cache/flush`),
`src/serve/generation-gateway.ts`, `src/serve/batch-scheduler.ts`.

## 1. Layering

Residency is a three-tier stack, each tier keyed by the exact token prefix
its KV encodes:

| tier | owner | unit | key |
|---|---|---|---|
| live caches | one generation (serial lane or a batch row) | `Cache[]`, one per layer | — |
| RAM prompt cache | `PromptCache` (`src/prompt-cache.ts`) | whole prefix entry (tokens + `Cache[]`) | tokens + adapter ns |
| SSD cold tier | `SsdCacheStore` (`src/ssd-cache.ts`) over `src/kv-store.ts` files | one `.mlxkv` file per entry | tokens + ns + model/scheme/tokenizer fingerprint |

The prompt cache tiers over the SSD store *inside* `take()` (structural
`ColdTier` interface), so every consumer (serial lane, batch scheduler
joiners, `/admin/drain`) gets both tiers through the same `take()`/`put()`
calls. Nothing runs on the token loop: spill/persist happen at request
boundaries, evictions, idle sweeps, and explicit flushes. Paged KV
(section 6) is a *layout* choice for the live tier and, in v1, bypasses the
other two.

## 2. Cache classes and the signature/capability model

### 2.1 The `Cache` contract (`gemma4-base.ts`)

Every cache-owning layer holds one `Cache`:

- `updateAndFetch(k, v)` appends and returns the attended window;
  `makeMask(N, windowSize)`; `state()` (arrays to eval at a prefill chunk
  boundary); `dispose()`.
- `isTrimmable()` / `trim(n, bypass?)` — whether the last `n` tokens can be
  dropped. This single predicate drives prefix reuse: an entry longer than
  the matched prefix is usable only if every cache can trim.
- `signature?()` — stable storage identity ("`kv:plain`",
  "`kv:quant:<bits>:<group>`", "`kv:rotating-plain`",
  "`kv:rotating-quant:<bits>:<group>`", "`kv:turboquant:<k>:<v>`", "`ssm`",
  "`kv:mla:target`", "`kv:mla:target:dsa`", "`kv:mla:mtp`"). Persistence
  codecs (`kv-store.ts` `CACHE_CODECS`) and the scheduler's layer-kind map
  dispatch on it. `cacheSignature(cache)` returns `"unknown"` when the
  method is absent.
- `bytesPerToken?()` — physical growth per token per row (0 for recurrent
  state); `stateNeedsDispose` (TurboQuant's `state()` returns fresh views
  the caller must dispose); `ropeOffsetArr` (per-row RoPE positions for
  batched/compiled paths); `specRound*` (speculative rollback for
  untrimmable recurrent caches).

Capability interfaces sit beside the signature: `RowBatchCache`
(`batchSize`/`filterRows`/`extractRow`) and `BatchableCache` (caches that
own their own dynamic-row batching — GLM's MLA/DSA state). Type guards
(`isPlainKvCache`, `isRotatingPlainCache`, …) are signature-based;
`isRowBatchCache`/`isBatchableCache` are structural.

### 2.2 The family

| class | file | signature | trimmable | notes |
|---|---|---|---|---|
| `KVCache` | gemma4-base.ts | `kv:plain` | yes | mlx-lm port; grows in `STEP = 256` slabs, in-place `sliceUpdate` |
| `QuantizedKVCache` | gemma4-base.ts | `kv:quant:b:g` | yes | affine triples (packed/scales/biases), groups along head_dim |
| `RotatingKVCache` | gemma4-base.ts | `kv:rotating-plain` | **only while `offset < maxSize`** (pre-wrap) | sliding-window ring |
| `RotatingQuantizedKVCache` | gemma4-base.ts | `kv:rotating-quant:b:g` | pre-wrap | quantized ring |
| `TurboQuantKVCache` | gemma4-base.ts | `kv:turboquant:k:v` | yes | not a `KVCache` subclass — deliberately fails every `instanceof` gate (monolith fallback, solo-only); see docs/design/turboquant.md |
| `SSMCache` | qwen3-delta.ts | `ssm` | **no** (recurrent) | `bytesPerToken()` = 0; per-row `offsets` in the batch lane |
| `Glm52Cache` / `MLACache` | glm52-cache.ts | `kv:mla:*` | yes | `BatchableCache`; compressed latent + rope (+ DSA index) |
| `PagedKVCache` | paged-kv.ts | **none** | yes | block pool + gather; section 6 |
| `BatchedRotatingCache` | batched-rotating.ts | `kv:rotating-plain` | pre-wrap | `RowBatchCache`; batched ring, host-side scalar ring state |
| `BatchedRotatingQuantCache` | batched-rotating-quant.ts | inherited (`extends RotatingQuantizedKVCache`) | pre-wrap | batched quantized ring |
| `BatchedDecodeMaskCache` | batched-mask.ts | **none** | delegates | per-step wrapper over a B-generic inner (padding mask + per-row RoPE) |
| `BatchedQuantDecodeMaskCache` | batched-quant.ts | inherited (`extends QuantizedKVCache`) | delegates | quantized twin of the wrapper; subclassing keeps generated forwards' `instanceof` guards happy |
| compiled-decode `Trace*` | compiled-decode.ts | inherited | — | trace adapters over the four compiled-supported classes |
| training caches (`TrainingCache`, `TrainingSSMCache`, `BatchedMaskCache`, `PrefixSharedCache`, `Gemma4PrefixSharedCache`, `Gemma4PrefixSharedSegCache`) | src/train/* | **none** | — | never admitted, cloned, or persisted; the interface comment explicitly allows omission here |

Invariant: **quantization groups run along head_dim, never the token
axis**, so token-axis slicing (trim, `cloneKvCaches` live views, batch row
surgery, persistence slicing to `offset`) is byte-safe for every quantized
kind. Every cache kind persisted by kv-store has a `restoreState(...)`.

### 2.3 Batching gates

Two independent checks decide whether a model/scheme can batch
(`generation-gateway.ts`):

- `#modelCachesBatchable()` — every fresh `makeCache()` entry is a
  `KVCache`, `RotatingKVCache`, `BatchableCache`, or (unless
  `MLX_BUN_BATCH_SSM=0`) `SSMCache`. Novel classes (TurboQuant, paged) fail
  this by construction.
- `#kvBatchable()` — `KvScheme.batchable(config, canConvert)`: only the
  per-layer `affine-config` scheme batches, and only when every configured
  layer is a plain or rotating cache that can convert. Uniform `kvBits`
  and TurboQuant stay serial; a scheme-less gateway must never silently
  drop quantization (`kv-scheme.ts` makes the capability probe mandatory
  for quantized schemes).

The scheduler then maps each layer to a kind ("owned-batch" / "rot" /
"ssm" / "full") from the prototype caches, and joins/filters/extracts by
that kind.

### 2.4 Known design gap: optional `signature()` with an `"unknown"` fallback

`Cache.signature` is optional and `cacheSignature()` substitutes
`"unknown"`. That makes an unsigned class *route* rather than *fail*: any
signature-based conjunct silently evaluates false. This is exactly how the
2026-08-22 agg×4 regression happened (PLAN.md "agg×4 regression —
root-caused and fixed", commit `443f333`; the BatchedRotatingCache fix
PRs #42/#43): the scheduler's rot-merge required
`isRowBatchCache(prev) && isRotatingPlainCache(prev)`, `BatchedRotatingCache`
had no `signature()`, the running batch's ring was dropped from the join,
and the next full-B decode step crashed in the grow-path concatenate. The
quantized twin escaped only because it inherits a real signature.

What holds today (verified in src, 2026-08-23):

- `BatchedRotatingCache` now returns `"kv:rotating-plain"`
  (`batched-rotating.ts`), and the scheduler's rot branch routes by
  capability alone (`isRowBatchCache`). The comment at
  `batch-scheduler.ts` ~line 1007 still says the class has *no* override —
  that comment is stale; the guard order it describes (capability first)
  is still the rule.
- Still unsigned: `PagedKVCache` and `BatchedDecodeMaskCache` in the
  serving tree, plus the six training-only caches listed above. Neither
  serving class is currently reachable by a signature-dispatched path
  (paged bypasses prompt-cache/kv-store/batching; the mask wrapper is
  rebuilt per step and the scheduler dispatches on the *inner* caches),
  so today the gap is latent, not live.
- Rule going forward (PLAN.md lesson): **"unknown" is a bug, not a
  route.** Any new `Cache` that can reach the scheduler, `cloneKvCaches`,
  or kv-store must declare a signature; kv-store already throws on an
  unknown signature rather than guessing. Making `signature()` required on
  the interface (with training adapters returning an explicit
  `"training"`) is the open hardening item.

## 3. KV schemes — how they plug into the cache (`src/kv-scheme.ts`)

`KvScheme` is the immutable declaration of *what bytes a token costs and
which cache class holds it*: kind `bf16` | `affine-uniform` |
`affine-config` | `turbo`, resolved once at server start by
`resolveKvScheme` (TurboQuant wins if set; `--kv-quant off|<bits>|config`
otherwise; a missing `kv_config.json` under `config` is bf16 or an error
per caller). Its roles in residency:

- **Conversion chokepoint.** `maybeQuantizeKv` (`generate.ts`) converts
  populated plain/rotating caches in place after the first prefill
  (`offset === 0` caches are skipped — the optiq mixed-KV convention; the
  affine start threshold is `quantizedKvStart`, which `resolveKvScheme`
  pins to 0 for every server scheme — the `generate.ts` fallback of 5000
  for uniform bits only reaches library callers who pass `kvBits` without
  a threshold) and evaluates layer by layer so the bf16 source frees
  before the next layer converts. TurboQuant converts
  full-attention `KVCache` layers only; rotating layers stay bf16 with a
  one-time warning.
- **Byte accounting.** `kvBytesAt`/`kvGeometry` bill per layer type (full
  / sliding capped at the window / linear state) with
  `bits/8 + 4/groupSize` bytes per affine element. `fitOptions` bills
  TurboQuant as bf16 on purpose (conservative until its packed layout
  exposes a stable projector). The scheduler's KV-budget admission uses
  the same seam, and `BatchableCache.projectedBytes` for owned-batch
  caches.
- **Cache compatibility key.** `cacheKey` (`bf16` | `kv<bits>` | `config`
  | `turbo-k<k>v<v>`) is folded into the SSD store's fingerprint
  (`${configFingerprint(config)}-${schemeKey}`, `server.ts`), so restored
  files always match what serving would have produced. `configFingerprint`
  itself covers the per-layer `kv_config.json` scheme but not CLI-only
  levers (uniform bits, TurboQuant) — the scheme key is the anti-collision
  mechanism for those.
- **Batch placement.** `batchable()` as in 2.3.

Uniform 4/8-bit affine KV is bit-exact L1 (unfused SDPA == mlx-lm
`base.py`); the per-layer config scheme is the L2/optiq composition, and
TurboQuant is a third, oracle-backed codec (vllm-metal). The scheme axis
(which bits where) is orthogonal to the residency axis (which tier holds
them); nothing in this doc changes numerics.

## 4. RAM tier — `PromptCache` (`src/prompt-cache.ts`)

Byte-capped LRU of whole prefix entries (`--prompt-cache <GB>`, default
8 GB; `0` disables). The mlx-lm lesson that motivated it — a count-capped
cache of multi-GB entries is an OOM footgun — still stands even though
upstream is byte-capped now.

**`take(prompt, ns)` — non-consuming prefix sharing.** Finds the entry with
the longest usable common prefix (usable = common prefix capped at
`prompt.length - 1`, so at least one token is forwarded; an entry longer
than the match must be trimmable), clones it zero-copy (`cloneKvCaches`:
slice views of the live arrays — safe because mlx cache updates are
functional and the donor always holds a ref, so buffer donation never
fires on shared bytes), trims the clones, and returns them with a
ref-counted `retain` share. The donor stays in place: N agents sharing a
system prompt clone from one prefill. The old consume-and-trim semantics
cannibalized donors.

**Tier order inside `take()`.** The cold tier is consulted with
`find(prompt, ns)` (index-only, no I/O) and wins only with a *strictly*
longer usable prefix; then `restore(handle)` materializes it and the
divergent tail is trimmed. A cold entry that would need a trim but is
untrimmable (wrapped ring, SSM) is disposed loudly and the RAM candidate
(or a fresh prefill) serves. `hits`/`misses` count RAM candidacy only.

**`put(tokens, caches, ns, retain)` — supersession + eviction.** Exact
duplicates (same tokens) are replaced regardless of trimmability. Strict
prefix-ancestors in the same ns are superseded without spill — but only
when the *new* entry is fully trimmable; an untrimmable new entry (wrapped
ring) can only serve exact-length matches, so shorter ancestors (the
prompt-boundary snapshot) must survive. Then LRU-evict until under cap,
spilling each evictee to the cold tier first. An entry larger than the cap
is spilled and disposed, never stored. `onPut` fires after every
successful put — the server hangs the write-behind scheduler there so both
lanes' entries persist.

**Prompt-boundary snapshot.** Serial lane (`server.ts`) and batch
scheduler (`snapshotAt`) both clone-and-put a trim-free *prompt-only*
entry at the template probe's stable boundary during a substantial cold
prefill. Rationale: the prompt+generation entry put at completion is
untrimmable past the sliding window (wrapped rings) and under mid-group
quantization, so any decode→encode drift in the reply the client sends
back would turn the next turn into a total miss; a prompt-only entry is
always an exact prefix of the next rendering.

**Namespaces.** `ns` = the adapter spec (`adapters.join("+")`, `""` = base).
KV computed under one adapter never seeds another's prefill.

**Bypasses.** Media (vision/audio) requests skip the cache (soft tokens are
identical placeholder ids → false hits), as do paged-KV requests (v1) and
the speculative lane (v1). Merged batch rows are not re-put on finish;
never-merged lone rows put their adopted caches back zero-copy, and
merged rows are extracted per row (`#extractAndPut`) before `filter()`
mutates the batched inners.

**Idle demotion (`demoteIdle`).** Entries unused past a threshold spill to
the cold tier and free their GPU arrays; the prefix stays reachable via
restore. No-op without a cold tier (demotion with nowhere to demote to is
data loss). `/admin/drain` (unix-socket engine children only) is
`demoteIdle(0)` under the gateway lock — the model pool's lossless
pre-eviction step.

**Spill contract (`SpillSink`).** Preferred `spillOwned`: the cache hands
the sink zero-copy clones + copied tokens made *before* the donor is
disposed, and the sink owns their disposal on every settle path. A sink
that throws synchronously has not taken ownership; the spill degrades to
a no-op and eviction never unwinds. `spillSync` (live entry, synchronous)
remains for tests and simple embedders.

Known numerics property (not a residency defect): continuing from a
restored or reused prefix produces the same output as the RAM tier's own
cache hit, but a bf16 prefix-reuse continuation can differ from a fresh
full prefill (GEMV-vs-GEMM reduction order). Both tiers share it.

## 5. SSD cold tier

### 5.1 Decisions

- **D1 — Whole-prefix-entry spill, not paged blocks.** Single-user serving
  with a prefix-entry cache that grows per conversation. Per-block hashing
  and save-queue bookkeeping during decode is where oMLX's measured ~20%
  steady-state tax came from; ours does zero work on the token loop
  (prefix tokens are the key). Partial-prefix reuse works without paging:
  restore + `trim()`. The economics that justify the tier are
  SSD-vs-recompute, not SSD-vs-RAM: at 12B prefill rates a 30k agent
  context is minutes of GPU compute against a ~1 s NVMe restore.
- **D2 — One store, two tiers.** The cold tier is bound *into*
  `PromptCache` (section 4); restart persistence comes from a debounced
  write-behind snapshot after each put, not only from spill-on-evict.
- **D3 — Own page-aligned format, not safetensors.** `src/kv-store.ts`
  writes `MLXBUNKV2\n`-magic files whose current layout is the **v3
  streaming writer**: header sized up front with fixed-width tensor
  hashes, tensors materialized/hashed/written one at a time at 16 KiB
  aligned offsets, header patched last (peak host transient = one
  tensor). Header carries `formatVersion`, `modelId`,
  `configFingerprint`, `ns`, `tokenizerHash`, `createdAt`, `tokens`, and
  per-cache `{kind, offset, idx?, maxSize?, groupSize?, bits?, kBits?,
  vBits?, headDim?, GLM geometry, tensors[]}`. Kinds: `kv`, `rotating`,
  `qkv`, `rotating-qkv`, `ssm`, `turboquant`, `mla`, `mla-dsa`, `mtp-mla`.
  Quantized buffers are sliced to `offset` (no 256-step slack persisted).
  Header hash always verified; per-tensor hashes verified only under
  `--ssd-cache-verify` (eager reads roughly double restore cost). Writes
  are atomic (tmp + fsync + rename). Older v1/v2 files read as
  unsupported and are deleted-and-regenerated (machine-local, cheap).
- **D4 — Files are the database.**
  `<dir>/<configFingerprint>/<nsHash>/<uuid>.mlxkv`. Startup recovery is a
  header-only scan of *our* fingerprint dir into an in-memory
  `SsdIndexEntry[]` (`{path, ns, tokens, bytes, mtimeMs, trimmable}`);
  foreign fingerprint dirs are ignored, never deleted. LRU = file mtime
  (`utimes` on hit); the byte cap is enforced at write time by oldest-mtime
  eviction; corrupt headers and metadata mismatches are unlinked; `.tmp`
  orphans reaped; disk-full is a warn-once soft-fail. Every failure path
  degrades to "no hit" / "not stored" — the tier can never take serving
  down.
- **D5 — Flags and interactions.** `--ssd-cache <dir>` (off unless set),
  `--ssd-cache-max <GB>` (default 32 GiB), `--ssd-cache-verify`,
  `--ssd-demote-idle <sec>` (default 300 with the tier on; `0` disables).
  Requires the RAM tier (`--prompt-cache 0` + `--ssd-cache` is a startup
  error). Sub-flags without `--ssd-cache` warn and are ignored.
  `--memory-budget` is unchanged (admission already assumes worst-case
  bf16). `--paged-kv` warns that the tier sees nothing (section 6).

### 5.2 Restore is a streamed copy (supersedes the original zero-copy plan)

The first design restored by COW mmap + `fromPointer` and unmapped in the
entry's `retain`. Two things killed it: the 2026-07-06 rule that mlx
buffer destructors must never call into JS removed the unmap signal, so
every restore became a process-lifetime mapping leak; and exactly-sized
restored buffers made the first post-restore decode step concat-copy the
whole entry anyway. `loadKvCache` now copies each tensor out of a
read-only mmap into an mlx-owned leaf (`fromBytesCopy`), drops the clean
file pages (`MADV_DONTNEED`; offsets are 16 KiB = arm64 page size),
unmaps before returning, and lands plain-KV tensors in STEP-rounded
capacity with slack so the first step updates in place. Peak host
transient = live entry + one tensor; nothing outlives the call. The
`retain` thunk stays in the entry contract as a no-op so callers' dispose
ordering is unchanged (the server's `coldTier.restore` returns
`() => {}`). Comments in `prompt-cache.ts` that still say "zero-copy
mmap" describe the superseded mechanism.

The write side is the mirror: hashing and writing from a zero-copy view
of the contiguous mlx buffer (`rawBytesView`), no JS-heap copy at any
point.

### 5.3 `find()` returns partial matches, gated on trimmability

`SsdCacheStore.find` returns the longest usable prefix (capped at
`prompt.length - 1`) and *skips* entries that would need a trim but are
untrimmable (`trimmable` is derived from the header kinds + state at
store/scan time via `cacheHeadersTrimmable`). Before this gate the big
untrimmable `[prompt+gen]` file always outranked the usable boundary
snapshot, got restored, and was thrown away — the 2026-07-06 "restart
restores 0 tokens" defect and its silent restore-then-re-prefill cost.
Store-side supersession mirrors `PromptCache.put`: exact duplicates
replaced; prefix-ancestors superseded only when the new entry is
trimmable.

### 5.4 Write-behind scheduling contract: flush only while idle

Every per-tensor flush step is real GPU-stream and JS-thread work
(`ops.contiguous` on the decode stream, a synchronous eval for
`rawBytesView`, a synchronous multi-MB `writeSync`). Interleaving those
between decode tokens taxed decode at long context, so:

- `saveKvCacheAsync` / `SsdCacheStore.storeAsync` accept a per-step
  `waitTurn` gate awaited before *every* tensor (including the first); the
  server passes `() => gateway.onIdle()`. A request arriving mid-flush
  pauses the remaining tensors. Gate failures are swallowed — scheduling
  advice must never corrupt the write path.
- `GenerationGateway.busy` covers both lanes (serial mutex held/awaited or
  batch rows active/pending).
- `MLX_BUN_SSD_WRITEBEHIND=0` disables write-behind snapshots entirely
  (kill switch + paired-A/B lever; restart survival then degrades to
  spill-on-evict).

Accepted: durability waits for a quiet moment; one in-flight tensor step
can land ahead of a just-arrived request.

### 5.5 Bounded retention: `SpillQueue` (`kv-store.ts`)

All three producers — eviction spills, idle demotions, write-behind
snapshots — go through one serial, byte-capped queue. Pending clones pin
their entries' GPU buffers until the idle-gated flush gets a turn; without
a cap, sustained traffic (gate starved, evictions ongoing) made resident
memory = prompt-cache cap + every queued clone. Policy: cap default 2 GiB
(`MLX_BUN_SSD_SPILL_QUEUE_GB`; `0` keeps only the newest + in-flight
clone); over cap the *oldest* not-in-flight item drops and its clones are
disposed immediately; the item just enqueued is never its own victim
(soft cap). A dropped spill is a future cache miss, never a wrong result.
Clones are disposed on every settle path (fulfil, reject, drop). The
snapshot timer never holds batch admission: while rows are active it
re-arms instead of grabbing the exclusive (entries are immutable; a late
snapshot is equally valid).

### 5.6 Durability boundary (`src/ssd-durability.ts`)

The 2026-08-22 finding: a debounce timer (1 s), a busy re-arm (5 s), and a
serial queue meant a SIGTERM shortly after a long request could outrun
the write — the server implied durability it did not have.
`SsdDurabilityCoordinator` turns puts into a state machine:

- `schedule(tokens, ns)` records a *dirty* key that includes the exact
  token sequence (two same-ns, same-length conversations cannot cancel
  each other) and arms the debounce.
- An attempt snapshots the RAM entry under `gateway.runExclusive`
  (`findExact` + `cloneKvCaches`) and enqueues it; a busy gateway re-arms;
  a dropped or failed store leaves the key dirty so it is retryable.
  A snapshot that vanished from RAM is "stored" only if the SSD index
  already covers the prefix (`hasDurablePrefix`), else "missing".
- `flush()` cancels timers, awaits in-flight attempts and `drain()`, then
  forces each dirty key one at a time (so the queue cap cannot drop a
  boundary snapshot while a large final snapshot is in flight). Result:
  `durable` is true only when nothing is pending, nothing dropped or
  failed during this flush, and nothing was missing.

Surfaces: `POST /admin/cache/flush` returns 200 at the boundary (503
otherwise) with pending/dropped/failed/entry-count/longest-prefix
evidence; `mlx-bun serve` handles SIGINT/SIGTERM by stopping admission,
draining active requests, and awaiting the same flush, bounded by
`MLX_BUN_SHUTDOWN_TIMEOUT_MS` (default 120000). `/stats.ssd_cache` exposes
`entries`, `bytes`, `max_bytes`, `restores`, `spills`, `restore_ms_last`,
`demotions`, `pending_snapshots` (includes debounce/re-arm timers),
`pending_spills`, `pending_spill_bytes`, `dropped_spills`,
`failed_spills`, `longest_durable_prefix_tokens`. The standard restart
benchmark calls the endpoint instead of sleeping.

### 5.7 Invalidation

Compatibility key = `configFingerprint(config)` + `KvScheme.cacheKey` +
tokenizer hash (`Bun.hash(tokenizer.json)`) + adapter ns; all enforced on
scan and load (`KvLoadExpect`). Chat-template drift degrades to a shorter
matched prefix (safe). GLM compressed caches additionally validate
geometry (`kvLoraRank`, `ropeHeadDim`, `dsaHeadDim`, `maxTokens`) against
the model's prototype cache before opening the tensor mmap.

### 5.8 Measured (kept with labels)

- 2026-07-02, M1 Max, MiniCPM5, 13.7k-token prefix, `kv_config` quant:
  restart TTFT 12,083 ms (full prefill) → 236 ms restored; steady-state
  decode 192.0 vs 192.3 tok/s (flag off/on). Restored + trimmed
  continuation identical to the RAM tier's cache-hit output.
- 2026-07-07, streamed-copy restore, 512 MB synthetic entry: mlx peak
  during restore + first step = live entry + one tensor (552 vs 520 MB
  active); `vmmap` shows no `.mlxkv` mapping survives; 12B real-model cold
  cache-load → first token 277 ms.
- 2026-07-07, e4b 9.5k-token entry: repeat decode 37.9 tok/s with the
  flush overlapping vs 47.1 cold; flat 44–46 across three samples after
  the idle gate.
- 2026-08-22, unified e4b, dirty machine (correctness evidence only):
  4,026-token prompt flushed in 408 ms with `durable=true`, then 4,025
  cached tokens restored after SIGTERM + respawn.

### 5.9 Open items

- Full clean 16k e4b / 12B / Qwen3.8 restart matrix (batch 8 and
  `--batch 1`, `cached_tokens ≥ prompt_tokens - 1`) is the acceptance run
  for the durability fix; only the dirty-machine smoke has run.
- P4 hardening extras never closed: kill-during-write crash test; a
  `THIRD_PARTY_LICENSES.md` note if any oMLX-derived code (not just ideas)
  ever lands.
- Block-granular dedup for multi-user shared prefixes stays out of scope
  (D1); revisit only with the paged follow-ups in 6.4.
- Stale comments: `prompt-cache.ts` still describes restore as zero-copy
  mmap (5.2).

## 6. Optional paged KV (`src/lab/paged-kv/paged-kv.ts`, `--paged-kv`)

Default off; with the flag unset no paged code executes and the plain
`KVCache`/`RotatingKVCache` path is byte-identical.

### 6.1 What it buys here, honestly

vLLM's PagedAttention solves contiguous worst-case per-sequence
reservation and allocator fragmentation for a multi-tenant server.
mlx-bun is one process on unified memory with byte-budget admission
already shipped, so what transfers is: (a) padded-batch waste removal —
today's batched buffer width tracks the longest live row
(`mergeKVRows`/`extendKVRows`), so a short row cohabiting with a long one
pays the long one's KV; and (b) block-level copy-on-write prefix sharing.
Neither is in v1. **At batch=1 paging buys nothing** — gather-before-attend
is bandwidth tax on a bandwidth-bound decode. v1 ships the
correctness-proven block-manager abstraction at serial scope as
scaffolding for the follow-ups, not as a speed win.

This is neither of the two paging rejections already on record:
paged KV as a *prompt-cache substitute* (rejected 2026-07-07 — `take()`'s
zero-copy clones already share physically) and paged *blocks* as the SSD
spill granularity (D1). It is the rung-3 allocation abstraction from
docs/design/batching.md.

No external oracle exists (mlx-lm's `cache.py` has no paged cache); the
gate is mlx-bun's own plain `KVCache`, valid because the claim is storage
equivalence (same bytes, different arrangement), so the bar is bit-exact
(tol 0): `tests/paged-kv.test.ts` (model-free: block-boundary crossing,
free-list reuse after trim, typed exhaustion, gathered fetch vs a plain
reference, dispose) and `tests/paged-kv-parity.test.ts` (weights-gated
greedy trajectory paged-on vs paged-off).

### 6.2 Mechanism

- **`BlockPool`** — per-layer arena: K and V pool tensors
  `[numBlocks, H_kv, blockSize, headDim]` (V may differ in head dim),
  `ops.zeros`-allocated so they are mlx-owned end to end (no host-pointer
  alignment/dtor hazards). LIFO free list; `alloc()` throws the typed
  `PagedPoolExhausted`; writes are `ops.sliceUpdate` at
  `[block, 0, within, 0]` — the incoming `[1,H,l,D]` piece matches the
  destination slice directly.
- **`PagedKVCache implements Cache`** — standalone (not a `KVCache`
  subclass, the TurboQuant reasoning: every `instanceof` gate excludes it
  and routes to the monolith forward). `updateAndFetch` splits the
  incoming `L` along block boundaries, allocates tail blocks as reached,
  then gathers occupied blocks with `ops.takeAxis(pool, blockTable, 0)` →
  transpose `[1,0,2,3]` → reshape `[1,H,nb·bs,D]` → slice to `offset`. Only
  existing bound ops — no `mlx_gather` FFI binding was needed. `makeMask`
  is `KVCache.makeMask`'s logic; `trim(n)` rewinds `offset` and frees
  now-unoccupied tail blocks (stale bytes past `offset` are never read —
  the `KVCache` padding invariant, block-shaped). Block table is a
  host-side `number[]`; all intermediates are bound and disposed.
- Pool lazily allocates on the first write (head count/dims/dtype from
  the first k/v pair) and is sized once from `capacityTokens` =
  prompt + `max_tokens`, so exhaustion is unreachable absent an
  accounting bug — it exists as a tripwire, never silent truncation.
- **Wiring** — `maybePageKv(cache, options, capacityTokens)`
  (`generate.ts`) mirrors `maybeQuantizeKv`'s post-construction in-place
  swap but runs *once before prefill*: paging changes layout, not
  arithmetic, so there is no "convert when populated" trigger. Only fresh
  (`offset === 0`) plain `KVCache` entries are replaced; rotating layers
  keep their scheme — mixed paged-full + rotating-sliding is the supported
  shape. Default block size 256 = `KVCache.STEP`, so v1's growth
  granularity is a permutation of today's into reusable slots, not a new
  tuning axis.

### 6.3 Gates (explicit refusals, never silent downgrades)

- Startup (`server.ts`): `--paged-kv` with `--batch N>1`, any `--kv-quant`
  (affine or TurboQuant), `--draft-model`, or a non-`gemma4*` model exits
  with a clear message; `--paged-kv-block-size` must be a positive
  integer; `--ssd-cache` alongside it warns that the tier sees nothing.
  With no explicit `--batch`, the CLI pins `--batch 1` (default is 8) and
  says so. Env `MLX_BUN_PAGED_KV=1` is equivalent to the flag.
- Request scope: media (vision/audio) and LoRA-adapter requests strip the
  flag and run the plain cache path (v1 non-goal cells, never a 400). One
  effective `pagedKv` value per request keeps the strip and the
  prompt-cache bypass coherent.
- Serial lane: paged requests skip `take`/`put` and the boundary
  snapshot; caches are disposed on completion. Spec eligibility also
  excludes `options.pagedKv` (belt on top of the startup refusal).
- Compiled decode: `CompiledDecode.supports()` excludes `PagedKVCache`
  automatically (not one of the four supported classes) — a
  data-dependent block-list length is the shape shapeless replay already
  broke on.
- Batch lane: unreachable by construction (startup pins serial); the
  `RequestShape` gate to add when batched paging lands is noted here.

### 6.4 Follow-ups (dependency order) and open items

1. Batched integration — `PagedKVCache` into the scheduler's inner union;
   block-count admission replacing byte projection; join/filter/extract
   allocating and freeing blocks instead of pad+concat. This is where the
   padded-batch-waste win lives. Tracked under the plan anchor (Phase 18
   S3+).
2. Block-level CoW prefix sharing — refcounted block table, fork on
   divergent write; extends `PromptCache`'s entry-level ref-counting down
   to blocks.
3. Quantized paged blocks — dtype-parametric block descriptor sharing one
   block-index space.
4. Fused paged-attention Metal kernel (optiq's `sdpa_2pass_paged` is the
   port source) — kills the per-step gather copy.
- Perf disclosure: paged-on vs paged-off decode/prefill on the quiet
  reference machine has not been recorded in `docs/reference/benchmarks.md`
  (expected: a small decode regression at batch=1, to be reported plainly).
- `PagedKVCache` has no `signature()` (2.4) and no kv-store codec; both
  are prerequisites for any prompt-cache or SSD integration.

## History

- 2026-06-14 — `BatchedRotatingCache` (sliding-window batching) landed.
- 2026-07-02 — SSD cold tier P1–P3 landed: kv-store v2 (all cache kinds,
  invalidation metadata, atomic writes), `SsdCacheStore`, tier
  integration, flags.
- 2026-07-04 — prompt-boundary snapshot (multi-turn agent reuse fix).
- 2026-07-05 — non-consuming prefix sharing in `take()`; Layer-0 tiering
  moved inside `PromptCache.take()` (both lanes); idle demotion
  (`--ssd-demote-idle`).
- 2026-07-06 — TurboQuant v1 cache class + kv-store `turboquant` kind;
  RAM cap default 2 GB → 8 GB; non-blocking `spillOwned` spills; `find()`
  trimmability gate (restart-0 defect).
- 2026-07-07 — streamed-copy restore + zero-copy write view (A7 RSS);
  idle-gated write-behind (`MLX_BUN_SSD_WRITEBEHIND`); bounded
  `SpillQueue` (`MLX_BUN_SSD_SPILL_QUEUE_GB`); admission-safe snapshot
  timer.
- Phase 21 (closed 2026-08-17) — GLM `mla` / `mla-dsa` / `mtp-mla`
  kv-store kinds.
- 2026-08-21 — `KvScheme` seam: immutable scheme drives conversion,
  admission billing, SSD key, and batch placement.
- 2026-08-22 — agg×4 regression root-caused to the unsigned
  `BatchedRotatingCache` (capability-only routing fix, signature added);
  `SsdDurabilityCoordinator`, `POST /admin/cache/flush`, graceful
  SIGINT/SIGTERM flush.
- Paged KV v1 (serial, Gemma4, bf16, gather-then-SDPA) landed with
  bit-exact gates; flag rows in cli.md / server-config.md (landing date
  not recorded in the source doc, which still reads "in progress").
