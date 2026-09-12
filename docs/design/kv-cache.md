---
status: landed
axis: ON
canonical-for: kv-cache
plan-anchor: "Phase 18 — Concurrent / batched serving (slots) + parallel load benchmark `[~]` (2026-06-13)"
last-verified: 2026-09-12
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
`src/tiered-prompt-cache.ts`, `src/storage/kv-writer.ts`,
`src/kv-scheme.ts`, `src/generate.ts` (`maybeQuantizeKv` / `maybePageKv`),
`src/server.ts` (wiring, `/stats`, `POST /admin/cache/flush`),
`src/serve/generation-gateway.ts`, `src/serve/batch-scheduler.ts`.

## 1. Layering

Active generation owns mutable cache containers. Published checkpoints belong
to one logical cache, with RAM and SSD storage. On Apple Silicon the GPU and
CPU access unified memory; publication does not require a GPU-to-CPU copy.
Each checkpoint is keyed by the exact token prefix its state encodes:

| tier | owner | unit | key |
|---|---|---|---|
| live caches | one generation (serial lane or a batch row) | `Cache[]`, one per layer | — |
| RAM prompt cache | `TieredPromptCache` over `PromptCache` | whole prefix entry (tokens + `Cache[]`) | tokens + adapter ns |
| SSD cold tier | `SsdCacheStore` (`src/ssd-cache.ts`) over `src/kv-store.ts` files | one `.mlxkv` file per entry | tokens + ns + model/scheme/tokenizer fingerprint |

The prompt cache tiers over the SSD store *inside* `take()` (structural
`ColdTier` interface), so every consumer (serial lane, batch scheduler
joiners, `/admin/drain`) gets both tiers through the same `take()`/`put()`
calls. The cache queues persistence on publication or eviction. A dedicated
CPU worker writes evaluated immutable buffers while inference continues.
Persistence does not evict RAM; only cache residency policy does. RAM reuse
does not enqueue an extra write or wait for the queue. Explicit flushes await the queued work. The opt-in `--generation-checkpoint N` path transfers owned snapshots at coarse decode boundaries and queues atomic
persistence without awaiting disk in decode (section 5.7). Paged KV
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
- `#kvBatchable()` — `KvScheme.batchable(config, canConvert)`: per-layer
  `affine-config` and uniform affine KV4/KV8 batch when their cache-owning
  layers can convert. TurboQuant still requires merged-row layout support;
  a scheme-less gateway must never silently
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

**`take(prompt, ns)` — prefix sharing.** Finds the entry with the longest
usable common prefix (usable = common prefix capped at `prompt.length - 1`,
so at least one token is forwarded; an entry longer than the match must be
trimmable). Every RAM hit lends zero-copy views (`cloneKvCaches` and
`cloneAttachments`) with a ref-counted backing share; the donor remains in
place. This includes exact-boundary recurrent and method state. Only
trimmable state may be shortened. Decode extends its own views without
changing the retained checkpoint.

SSD is an eventually consistent persistence layer. RAM reuse never writes
to SSD or waits for durability. Background writes retain immutable snapshot
views while a CPU worker packs, hashes and writes them; explicit flush and
graceful shutdown wait for persistence. A pending or failed write does not prevent RAM reuse.
The byte target controls LRU eviction. With SSD enabled, an unwritten victim
stays resident until storage commits; the target is soft while writes are
pending or failing.

The native sharing gate checks logical checkpoint bytes after repeated decode
and after SSD restore. It passes on both development Macs; the M1 long-prefix
case also preserves three independent 512-token continuations. The queued
writer test retains snapshot state after both donor and borrower disposal,
and explicit flush remains pending until the write completes.

**Tier order inside `take()`.** The cold tier is consulted with
`find(prompt, ns)` (index-only, no I/O) and wins only with a *strictly*
longer usable prefix; then `restore(handle)` materializes it and the
divergent tail is trimmed. A cold entry that would need a trim but is
untrimmable (wrapped ring, SSM) is disposed loudly and the RAM candidate
(or a fresh prefill) serves. Tiered restore immediately publishes shared views
in RAM so another request can reuse them before the borrower finishes.
`hits`/`misses` count RAM candidacy only.

**`put(tokens, caches, ns, retain)` — supersession + eviction.** Exact
duplicates (same tokens) are replaced regardless of trimmability. Strict
prefix-ancestors in the same ns are superseded without spill — but only
when the *new* entry is fully trimmable; an untrimmable new entry (wrapped
ring) can only serve exact-length matches, so shorter ancestors (the
prompt-boundary snapshot) must survive. `TieredPromptCache` selects the
least recently used RAM entry when over budget. If it lacks durable SSD
coverage, the cache queues a write and retains it until that write succeeds.
It does not evict a hotter entry merely because that entry is already on SSD.
An oversized checkpoint follows the same persist-before-demotion rule.
Without SSD, the RAM-only cache discards evicted or oversized entries.
`TieredPromptCache.put` also owns proactive persistence; `onPut` remains an
independent observer for generated-token history.

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

**Bypasses.** Media and optional paged-KV requests retain their documented
cache qualification rules. Shared speculative execution publishes target and
method state together where supported; method attachments preserve the exact
boundary needed for reuse. Merged batch rows are extracted before retirement
changes the batched state. The cache owns the extracted checkpoint.

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

- **D1 — Whole-prefix-entry storage.** A checkpoint stores a complete
  conversation boundary. This reuses the existing cache codecs and avoids
  per-token storage bookkeeping, but duplicates shared attention history
  between files. Block deduplication is a separate layout optimization to
  measure against this baseline; recurrent state still needs exact boundaries.
- **D2 — One store, two tiers.** `TieredPromptCache` owns RAM residency and
  the SSD backend. Proactive persistence after publication provides restart
  survival without waiting for an eviction.
- **D3 — Own page-aligned format, not safetensors.** `src/kv-store.ts`
  writes `MLXBUNKV2\n`-magic files with a streaming writer: ordinary KV
  retains format v3; checkpoints with method companion state use v4.
  The header is sized up front with fixed-width tensor
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
- **Numerical compatibility.** The serving fingerprint also includes a hash
  of `ModelServingBinding.stateCompatibility`. The MLX backend supplies its
  actual runtime version and GPU architecture at binding creation. The same
  artifact produces different cache tensors in the recorded 0.31.2/0.32.2
  RTN4 comparisons, so graph geometry and KV format alone cannot qualify
  automatic reuse. A runtime/architecture change selects another directory;
  previous snapshots remain intact. The binding owns this identity, keeping
  backend details out of request parsing and portable model configuration.
  A replacement-binding restart regression verifies matching reuse, isolation
  and recovery of the original snapshot. Evidence:
  `reports/qwen38-rd/mlx-upgrade-0.32.2/cross-runtime-cache-numerics-review.json`.
  The real RTN4 HTTP gate also passes all eight responses across four
  internal-SSD server starts. Its first requests reuse 0/352/0/352 tokens
  under default/default/alternate/default identities; every second request
  reuses 352. The alternate tag changes metadata only. All response content,
  tool calls and usage counts other than cached tokens match. Exit allocation
  includes a retained prompt cache with different fresh/restored capacity,
  so this is not a post-disposal memory comparison. Evidence:
  `reports/qwen38-rd/runtime-state-http-review.json`.
- **D5 — Flags and interactions.** `--ssd-cache <dir>` (off unless set),
  `--ssd-cache-max <GB>` (optional; `0` or unset = unlimited), `--ssd-cache-verify`,
  `--ssd-demote-idle <sec>` (default 300 with the tier on; `0` disables).
  Requires the RAM tier (`--prompt-cache 0` + `--ssd-cache` is a startup
  error). Sub-flags without `--ssd-cache` warn and are ignored.
  `--memory-budget` is unchanged (admission already assumes worst-case
  bf16). `--paged-kv` warns that the tier sees nothing (section 6).
- **D6 — In-flight resume is explicit.** `--generation-checkpoint <tokens>`
  requires `--ssd-cache` and supports eligible shared ordinary execution. It
  is off by default. Captured states queue for SSD persistence; an explicit
  flush establishes durability of queued work (section 5.7). An identical request resumes; a changed
  prompt or sampling policy starts normally. Ordinary adapter requests use the
  same continuation hooks under their existing execution context. The checkpoint
  identity includes the ordered adapter IDs and content-revision namespace; a
  base-model request or replacement adapter cannot restore that checkpoint.

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

The asynchronous writer reads evaluated native storage directly. Contiguous
tensors need no packing copy. Strided tensors are packed on the CPU, one
tensor at a time, to omit capacity padding without a GPU `contiguous` call.

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

### 5.4 Background persistence and RAM residency

`TieredPromptCache` owns RAM residency, SSD writes and durable-coverage checks.
`put` materializes the checkpoint before publication. `saveKvCacheAsync`
uses the existing codecs to describe the file and obtains host-visible native
pointers, shapes and strides on the MLX owner thread. Its optional preparation
runner does not cover disk I/O. No MLX handles cross into the writer.

`KvWriter` embeds a dedicated Bun CPU worker in source and compiled builds.
The worker packs strided layouts, hashes tensor bytes, writes a temporary file,
fsyncs it and renames it atomically. It imports no MLX or scheduler code and
needs no generation lock. Contiguous tensors use direct buffer views; packing
scratch is reused across strided tensors. The cache owns the retained state,
and the queued write holds shared views through its completion. Those views
share immutable storage rather than copying the entire checkpoint.

The owner thread still prepares native views and updates the SSD metadata
index after completion. A background worker removes blocking payload I/O from
that thread; it does not make shared memory bandwidth or snapshot preparation
free. Measure those costs with concurrent decode before claiming a speedup.

Writing a copy does not remove RAM residency. Byte pressure chooses the actual
LRU entry. If its SSD copy is missing, it queues persistence and waits for the
completion callback to retry eviction. Failed writes leave the RAM entry
usable and dirty. Age-based eviction follows the same rule and runs without
acquiring the scheduler's generation lock. Neither policy refuses requests or
changes context, batch size or sampling settings.

`MLX_BUN_SSD_WRITEBEHIND=0` disables proactive persistence after publication;
eviction still queues persistence before removing RAM. Explicit flush and
shutdown await outstanding writes. A hard exit can lose uncommitted writes.

### 5.5 Persistence queue and capacity

Normal prefix persistence uses one serial `SpillQueue` with no independent
byte-drop policy. RAM ownership and pending write views share the checkpoint;
queue completion releases only the writer's reference. RAM cache capacity
and age policy decide demotion. They do not cancel an unwritten snapshot to
reduce the queue's accounting. While the oldest victim is writing, RAM can
exceed its target. A storage failure keeps that victim resident and retryable.

The optional interrupted-generation coordinator still uses the generic
bounded queue for supersedable intervals. `MLX_BUN_SSD_SPILL_QUEUE_GB`
(default 2 GiB) now controls that queue only. It does not limit retained prompt
history. SSD capacity is independent: no capacity eviction without an explicit
positive `--ssd-cache-max`.

### 5.6 Durability boundary (`src/ssd-durability.ts`)

The 2026-08-22 finding: a debounce timer (1 s), a busy re-arm (5 s), and a
serial queue meant a SIGTERM shortly after a long request could outrun
the write — the server implied durability it did not have.
`SsdDurabilityCoordinator` turns puts into a state machine:

- `schedule(tokens, ns)` records a *dirty* key that includes the exact
  token sequence (two same-ns, same-length conversations cannot cancel
  each other) and arms a next-tick attempt.
- An attempt checks committed SSD coverage before cloning.
  Otherwise it snapshots the RAM entry (`findExact` + `cloneKvCaches`) and
  enqueues it without consulting scheduler activity. A failed store leaves
  the key dirty so it is retryable.
  A snapshot that vanished from RAM is "stored" only if the SSD index
  already covers the prefix (`hasDurablePrefix`), else "missing" and still
  dirty. A second flush cannot clear that failure without durable coverage.
- `flush()` cancels timers, awaits in-flight attempts and `drain()`, then
  forces each dirty record version once, one at a time.
  A replacement scheduled during a write receives its own attempt. After
  all writes settle, the coordinator checks missing ancestors against the
  committed SSD index again: a later trimmable descendant may now cover a
  superseded RAM prefix. Uncovered or foreign-namespace prefixes stay dirty;
  this adds no duplicate snapshot write. Result:
  `durable` is true only when nothing is pending, nothing dropped or
  failed during this flush, and no missing prefix remains uncovered.

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

### 5.7 In-flight generation checkpoints

At every configured token interval, `generate()` reaches a boundary where
the live caches cover every emitted token and the next token has already been
sampled but not emitted. The SSD entry stores both pieces atomically:

- the normal token list and cache tensors encode the emitted prefix;
- `generationCheckpoint` in the KV header records the request key, original
  prompt length, emitted-token count, adapter namespace, and pending token.

Saving the pending token is what makes the mechanism work for Qwen hybrid
models: recurrent `SSMCache` state cannot trim one token to recompute logits.
After restart, an identical request restores the full cache, replays the saved
tokens through the normal completion sink so the client receives one ordinary
assistant response, then continues directly from the pending token with the
original sampler step and history. The request key includes rendered prompt
IDs and every sampling/KV policy field. Grammar, token-fill, media, paged KV,
and logprob requests are not checkpointed in v1 because they carry additional
state or response data that cannot yet be reconstructed by token replay.

Ordinary continuation adds an optional request port to
that same ordinary driver. Checkpoint lookup, keys and persistence are shared
with the compatibility executor; the numerical driver supplies owned row
snapshots at an emitted-prefix/pending-token boundary. Restored rows complete
preparation without a target forward, before merging cold prefill rows, and
recover sampler seed, history and sample index. The server binding qualifies
ordinary requests through supported row-cache layouts, including recurrent Qwen
and full-attention Llama/MiniCPM as well as Gemma4. It transfers owned row
snapshots to a bounded persistence coordinator without awaiting disk in decode.
Snapshot preparation runs on the owner thread; payload serialization and
writes use the CPU worker. Completion
invalidates reuse immediately and queues cleanup after any in-flight write;
new attempts cannot be erased by older cleanup. Cancellation retains eventual
persistence, and explicit flush reports failed or pending durability. A hard
process exit may lose queued intervals. Plain greedy retains the ordinary
vectorized sampler when no history-dependent processors are active. Supported KV layouts retain their existing affine, per-layer and full-attention
TurboQuant conversion policy. Requests remain without
media, grammar, fill, paging, logprobs or speculative methods. Native tests
compare interrupted/restored runs at the same batch geometry; arbitrary
cohort changes are not an exact numerical identity guarantee. The HTTP fixture
checks serial B1, shared B1 and shared B4 with identical seeded requests and
held arrivals, and inspects the generated checkpoint before restart.
The configured spill queue budget applies to continuation snapshots; normal
prefix persistence follows the RAM cache residency policy. Flush duration and pending/failed
statistics cover both queues.

Only the newest successful checkpoint for a request is retained. The old file
remains valid until the new file's fsync+rename completes. Queue backpressure
can leave more than one interval undurable; a crash loses work since the latest
successful write. Normal completion immediately invalidates the checkpoint and
queues its disk removal.
Client cancellation throws through the serial token callback and preserves the
last checkpoint, so terminating a long-lived client does not erase its restart
point.

Fresh-model compiled continuation preserves the device sampler's uint32 pending
register. The Gemma model materializes its computed FP32 RoPE frequencies once
before compiled graph capture: a restored request may skip the prefill that
normally evaluates those constants. Capturing their unevaluated construction
graph can change arithmetic on M1. The forced-token continuation regression
compares a warmed model and a fresh model with cloned state, including every
active cache byte and full logits across delayed KV conversion. Live delayed
row layouts publish compact state through their extraction interface before
persistence; they do not need storage codecs for the live wrapper itself.

### Method companion state

`PrefixCache<State, Attachment>` is the shared consumer contract for ordinary
and batched execution. It has no scheduling or storage-tier operations. The
MLX binding supplies target cache layers plus optional `CheckpointAttachment`
records containing a method schema, scalar metadata and tensor snapshots.
The method owns their meaning and alignment; the shared cache owns retention.
Method and drafter compatibility must be part of the namespace before a
producer publishes these records. Storage does not interpret draft state as
extra target-model layers.

RAM accounting, eviction, idle demotion and SSD persistence include
companion tensors. Checkpoints containing them require an exact prefix
boundary and preserve shorter fallback entries. Write-behind captures companion
views together with target-cache views under the existing exclusive boundary.
The writer persists them in the same atomic file and the same per-tensor write
loop. Restore copies and verifies them through the existing tensor reader.
Ordinary files retain v3 compatibility; older readers reject v4 files rather
than restore an incomplete checkpoint.

The storage implementation is in the working tree. Synthetic gates cover RAM
ownership, divergent-prefix fallback, SSD eviction, fresh-process restore,
corruption, queue drops/failures and durability on both development Macs.
Qwen MTP now uses this interface for prefill snapshots; its private store and
separate budget option are removed. `DraftSource.checkpoint` supplies the draft
KV and pending true hidden row. The namespace includes a SHA-256 of draft
configuration and shard bytes, resolved at provider load, plus the mounted
adapter revision and KV policy. Model loading resolves that digest through
`artifactIdentity`, independently of inference and scheduling. A memo key includes
the configuration seed, sorted shard names, resolved paths, device/inode, size,
and nanosecond modification/change times. Unchanged revisions reuse the exact
existing SHA-256; a miss reads every shard byte. Same-size writes with restored
mtime and changed symlink targets invalidate the memo. Rechecking revisions after
hashing prevents persisting a digest under a revision that changed during reading.

`ArtifactIdentityStore` owns memo retention and persistence. Its file adapter uses
`~/.cache/mlx-bun/artifact-identities/`, keeps RAM hits and queues atomic file writes
without awaiting them in model loading. Missing, malformed or unwritable memo
storage does not prevent computing the identity. It stores only digests, not
weights, prompts or KV. Qwen MTP, standalone, assistant, DeepSpec and DSpark use
the same identity service; existing namespaces and SSD entries remain compatible.
Tests cover byte identity, no weight reads after a fresh-store memo hit, file
mutation, configuration changes, symlink replacement and write failure.

Native bf16/KV4 gates on M1 Max and M4 Pro
preserve live target/companion state hashes, emitted IDs and acceptance decisions
through repeated RAM reuse and SSD cache/provider restart. SSD allocation
padding is excluded from the live-state comparison. Generated-output acceptance
is described below; long-conversation timing remains R17 work.

The shared method publishes completed row state before
retirement through the same `PrefixCache.put` port. It records only inputs
retained by committed target/draft rounds; an unprocessed correction or bonus
token is absent from the key. The target row layout and draft provider supply
their snapshots independently. Failed and cancelled consumers publish no
generated checkpoint. Persistence continues through the existing queue.

Generated BPE IDs are not necessarily the canonical encoding of their decoded
text. `GeneratedTokenHistory` retains bounded text/ID provenance from published
prefixes and recovered SSD headers. Request preparation uses the original IDs
when the rendered conversation contains that exact text prefix, encodes only
the remaining suffix without another BOS, and checks that the combined IDs
decode to the complete rendered request. Edited history or an unsafe decoder
boundary keeps canonical tokenization. KV lookup still requires exact IDs and
the existing execution namespace; no state is relabeled under different IDs.
The template's primer length is measured canonically and applied to the actual
history-preserving token sequence. This can change input token counts, and
therefore continuation logits, relative to re-encoding all generated text.
Logit parity remains a contract for the same input IDs and execution shape.

Cache pressure maintenance uses 85% of the smaller of the recommended device
working set and an explicit allocator limit as a residency target. It includes
known weight bytes when file-backed weights have not appeared in MLX active
allocation. `PrefixCache.reclaim` asks the cache to demote LRU donors. With SSD,
only durable donors can leave RAM; pending writes remain queued. A selected
request retains its own views. Shared buffer ownership is not counted twice as
RAM plus queued data. Lookup, prefill boundaries and periodic decode maintenance
call this interface; decode checks every 256 steps. It does not constrain
request admission, context, sampling or batch size.

M1 and M4 native bf16, affine KV4 and fused TurboQuant K8/V3 tests cover four active
rows, early retirement, exact sampled-ID coverage, unchanged retained bytes
after sibling and follow-up work, shorter-prefix selection after an edit, and
matching RAM/SSD continuation and acceptance. Existing paired-prefill tests
also pass. A second native gate records actual sampled IDs for an echo tool
turn with thinking off/on, passes them through the production output parsers,
and renders the subsequent tool-result request with the same chat template.
Both published checkpoints are exact token prefixes of that next request.
A production HTTP gate now passes on both Macs for bf16, KV4 and fused K8/V3, with
thinking off/on. The next tool-result request reuses generated content in RAM.
After a durable flush, a separate server process restores the first turn's
SSD state and reproduces the same response, logprobs and acceptance. The test
copies only the first turn's flushed files before running the RAM continuation,
so no later prefill checkpoint can explain the restart hit. All six cases
pass, including the actual wire `reasoning` alias and template options.
The five-file change is adopted alongside the captured prefill-policy fix.
Native acceptance of that final composition, long saved Kanban replay,
pressure and complete next-turn timing remain open.
It does not resolve the older serial prototype's bf16 comparison with fresh
full prefill, whose operation shapes differ from a generated history.

### 5.8 Invalidation

Compatibility key = `configFingerprint(config)` + `KvScheme.cacheKey` +
tokenizer hash (`Bun.hash(tokenizer.json)`) + adapter ns; all enforced on
scan and load (`KvLoadExpect`). Chat-template drift degrades to a shorter
matched prefix (safe). GLM compressed caches additionally validate
geometry (`kvLoraRank`, `ropeHeadDim`, `dsaHeadDim`, `maxTokens`) against
the model's prototype cache before opening the tensor mmap.

### 5.9 Measured (kept with labels)

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

### 5.10 Comparison with other serving caches

Reviewed 2026-09-12 against published designs, not private provider internals.

| System | Algorithm and ownership | Application here |
| --- | --- | --- |
| [Mooncake / Kimi](https://github.com/kvcache-ai/Mooncake), [SSD offload](https://kvcache-ai.github.io/Mooncake/design/store/ssd-offload.html) | A cache service owns RAM/SSD placement. Background offload records a disk replica on successful write; the same lookup can restore from SSD. | One cache API with independent storage work. No application-managed demotion. |
| [SGLang HiCache](https://docs.sglang.io/docs/advanced_features/hicache_design) | A radix tree shares token spans and tracks memory placement. Supports proactive, selective and eviction-triggered writes, plus storage prefetch. Decode output can populate storage. | Keep output-produced checkpoints. Evaluate block sharing and prefetch after the persistence correction. |
| [LMCache MP](https://docs.lmcache.ai/mp/) | Independent store, eviction and prefetch controllers. Watermark-triggered RAM eviction uses LRU; asynchronous storage adapters handle lower tiers. | Separate write completion from residency policy. Keep the storage interface independent of inference. |
| [vLLM prefix caching](https://docs.vllm.ai/en/latest/design/prefix_caching/) | Token blocks use hashes including their preceding prefix. Unused blocks are evicted by recency. | Shared prefix blocks could reduce whole-entry duplication. |
| [Anthropic prompt caching](https://platform.claude.com/docs/en/build-with-claude/prompt-caching) | Public API documents exact-prefix reuse and expiration. | The same avoided-prefill benefit; this documentation does not establish its internal storage policy. |

Our current storage unit is a complete checkpoint. Repeated conversation
snapshots therefore duplicate attention history on SSD. Block deduplication
must preserve the existing state-kind contract: Qwen recurrent state and method
attachments cannot be trimmed to arbitrary earlier tokens. They need valid
checkpoint boundaries alongside any shared attention blocks. RAM LRU is the
initial policy; frequency weighting, prefetch and block layout changes need
measured reuse/latency evidence before replacing it.

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
Persistent pools now stay separate per request under the shared executor.
Attention still gathers and pads a temporary batch tensor; block-level prefix
sharing and direct paged attention remain open. At batch one, the gather adds
a copy. Paging remains optional and does not imply a speed improvement.

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
  subclass). The cache-layout binding supplies `PagedKvRows` for dynamic
  membership, masks and per-row positions. `updateAndFetch` splits the
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
  (`backends/mlx/request-state-policy.ts`, re-exported by `generate.ts`)
  mirrors `maybeQuantizeKv`'s post-construction in-place
  swap but runs *once before prefill*: paging changes layout, not
  arithmetic, so there is no "convert when populated" trigger. Only fresh
  (`offset === 0`) plain `KVCache` entries are replaced; rotating layers
  keep their scheme — mixed paged-full + rotating-sliding is the supported
  shape. Default block size 256 = `KVCache.STEP`, so v1's growth
  granularity is a permutation of today's into reusable slots, not a new
  tuning axis.

### 6.3 Gates (explicit refusals, never silent downgrades)

- Startup (`server.ts`): `--paged-kv` with any `--kv-quant`
  (affine or TurboQuant), `--draft-model`, or a non-`gemma4*` model exits
  with a clear message; `--paged-kv-block-size` must be a positive
  integer; `--ssd-cache` alongside it warns that the tier sees nothing.
  Paging preserves the selected batch size. Env `MLX_BUN_PAGED_KV=1`
  is equivalent to the flag.
- Request scope: media (vision/audio) and LoRA-adapter requests strip the
  flag and run the plain cache path (v1 non-goal cells, never a 400). One
  effective `pagedKv` value per request keeps the strip and the
  prompt-cache bypass coherent.
- Both execution modes: paged requests skip `take`/`put` and the boundary
  snapshot; caches are disposed on completion. Spec eligibility also
  excludes `options.pagedKv` (belt on top of the startup refusal).
- Compiled decode: `CompiledDecode.supports()` excludes `PagedKVCache`
  automatically (not one of the four supported classes) — a
  data-dependent block-list length is the shape shapeless replay already
  broke on.
- Shared execution: `PagedKvRows` owns independent block pools and immutable
  row snapshots. A request-state policy creates the storage and supplies no
  reusable-prefix store. Its opaque compatibility key keeps incompatible
  layouts in separate cohorts without making scheduling inspect paging flags.

### 6.4 Follow-ups (dependency order) and open items

1. Direct paged attention and block sharing — row integration now uses the
   shared layout interface with independent per-request pools. Attention still
   gathers padded contiguous inputs. Measure block-level shared arenas and
   direct reads before replacing this compatibility implementation. Tracked under the plan anchor (Phase 18
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

## Minimum reusable offsets

Physical trimmability does not prove that an older prefix has a valid
numerical representation. Caches may expose `minimumReusableOffset` after
an irreversible transition, such as delayed TurboQuant conversion. Prefix
selection requires the matched offset to meet every layer's bound. A
trimmable descendant supersedes an ancestor only when it can serve that
ancestor's offset; otherwise the earlier donor remains.

Cloning and per-row extraction preserve this state metadata. New SSD
headers record it, and indexing, durable-prefix checks and restore use the
same rule as RAM. Legacy TurboQuant headers without a recorded boundary
are conservatively reusable from their full stored offset only. Other
legacy cache kinds retain their existing interpretation. This changes
reuse eligibility, not scheduling, quantization arithmetic or memory
admission policy.
