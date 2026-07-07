# Optional paged KV cache (vLLM-style) — v1 design

Status: **v1 in progress** (this PR)
Default: **off** (`--paged-kv` unset ⇒ today's `KVCache`/`RotatingKVCache`
path, byte-identical — the flag-off proof is that zero new code executes).

Plan produced by a multi-agent design pass (4 subsystem readers +
prior-art scout → 3 competing designs → judged synthesis), then vetted
against the code by hand. Judge's pick: minimal-seam (8.25) over
serving-first (6.5) and future-proof (7.25); build-order discipline
grafted from future-proof.

## Motivation — what paged buys here, honestly

vLLM's PagedAttention (Kwon et al., SOSP 2023, arXiv 2309.06180) solves
contiguous worst-case per-sequence KV reservation + allocator
fragmentation. mlx-bun is a single process on unified memory with
byte-budget admission already shipped (parallel-slots.md rung 2), so the
fragmentation story mostly doesn't transfer. What does:

- **Padded-batch waste removal** — today's batched buffer width tracks
  the LONGEST live row (`mergeKVRows`/`extendKVRows`,
  src/model/batched-mask.ts): a 50-token row batched with a 4000-token
  row pays ~4000 tokens of KV while they cohabit. Block-granular
  allocation removes this. **A batching feature; v1 does NOT implement
  it** (non-goal — follow-up PR).
- **Block-level prefix sharing / copy-on-write** — PromptCache clones at
  entry granularity; block CoW is vLLM's headline win for concurrent
  agents sharing a system prompt. **Not in v1.**
- **At batch=1, paging buys nothing** — gather-before-attend is pure
  bandwidth tax on a bandwidth-bound decode. Measured and reported
  plainly, never spun.

v1 therefore ships the correctness-proven block-manager abstraction at
serial (batch=1) scope, expecting a small decode regression and zero
density win — scaffolding for the follow-ups, not a standalone perf win.
parallel-slots.md already names paged KV "rung 3 / S3+ deferred";
unified-engine-frontier-plan.md names block-paged KV the long-term
unifier. This PR is the first, narrowest slice.

Prior-rejection reconciliation (the record already says "no paging"
twice, for different axes, and both stand): the 2026-07-07 vLLM-mining
pass rejected paged KV as a PROMPT-CACHE substitute (take()'s zero-copy
entry clones already share physically), and ssd-kv-cold-tier.md D1
rejected paged BLOCKS as the SSD-spill granularity (per-block hashing on
the token loop = oMLX's ~20% tax). This PR is neither: it's the rung-3
ALLOCATION abstraction (parallel-slots.md), explicitly requested as an
optional flag, with the padded-batch/CoW payoff deferred to follow-ups.

**No external oracle exists**: mlx-lm's cache.py has no paged/block
cache (verified in the oracle venv). The correctness gate is mlx-bun's
own plain `KVCache` — valid because v1's claim is storage-layout
equivalence (same bytes, different physical arrangement), not new
arithmetic. Bit-exactness (tol 0) is the bar.

## v1 scope

- Serial (non-batched) single-sequence decode; Gemma4-family models
  (modelType `gemma4*`), plain full-attention layers only. Sliding
  (`RotatingKVCache`) layers keep today's scheme untouched — mixed
  per-layer paged-full + rotating-sliding is the supported shape.
- bf16 only. No `--kv-quant`/TurboQuant composition.
- Strategy: **block pool + gather-to-contiguous, then the unchanged
  `ops.sdpa()`** (gemma4.ts Attention.forward's plain-cache `else`
  branch consumes any `Cache` whose updateAndFetch returns contiguous
  [1,H,S,D] views). No new attention math, no new kernel, no new branch
  in the forward.
- Fixed pool per request, sized up front from prompt length + maxTokens
  (capacity is known at generate() time) — exhaustion is a typed
  `PagedPoolExhausted` error, never silent truncation or OOM.

## Non-goals (v1)

- No `--batch N` integration (`--paged-kv` + `--batch N>1` refused at
  startup). No `LayerInner` union change in batch-scheduler.ts.
- No sliding-window paging; no quantized blocks; no CoW/prefix sharing;
  no MoE/SSM/universal/CPM/Diffusion models; no vision/audio; no
  LoRA/adapters; no speculative decode (spec eligibility excludes paged).
- No fused paged-attention Metal kernel (follow-up once the gather tax
  is measured to matter; metal-kernel.ts infra + optiq's
  sdpa_2pass_paged are the port sources).
- No compiled-decode composability: a data-dependent block-list length
  is the exact shape shapeless replay already broke on (tiled quantized
  SDPA precedent). `CompiledDecode.supports()` excludes PagedKVCache
  automatically (it's not one of the four supported classes); the
  serve/CLI layer also refuses the explicit combination.
- No PromptCache integration: paged requests bypass take/put (the
  vision precedent in server.ts runGeneration) and dispose caches on
  completion. `state()` exists only for evalCacheState.

## Design

New file `src/model/paged-kv.ts`:

- **`BlockPool`** — per-layer arena. K and V pool tensors shaped
  `[numBlocks, H_kv, blockSize, headDim]`, allocated via `ops.zeros`
  (mlx-owned end to end — no host-pointer alignment/dtor hazards).
  `alloc()` pops the free list or throws `PagedPoolExhausted`;
  `free(idx)` pushes back. Incoming K/V write via the existing
  `ops.sliceUpdate` at `[block, 0, within, 0]` — the incoming
  `[1,H,l,D]` piece matches the destination slice directly, no
  transpose.
- **`PagedKVCache implements Cache`** — standalone implementation
  (deliberately NOT a `KVCache` subclass, same reasoning as
  `TurboQuantKVCache`: every instanceof gate — CompiledDecode.supports,
  gateway #modelCachesBatchable, generated `#matches()` — then excludes
  it automatically and routes to the monolith forward).
  - `updateAndFetch(k, v)`: split the incoming L along block boundaries,
    sliceUpdate each piece into pool blocks (allocating from the free
    list as the tail block fills), then fetch: `ops.takeAxis(pool,
    blockTable, 0)` → `[nb,H,bs,D]`, transpose `[1,0,2,3]` →
    `[H,nb,bs,D]`, reshape `[1,H,nb*bs,D]` (the gather copy), slice to
    offset. **Uses only existing bound ops** — the plan's proposed
    `mlx_gather` FFI binding is unnecessary (`takeAxis` gathers whole
    blocks along axis 0), which deletes the bun:ffi stack-arg ABI risk
    outright.
  - `makeMask`: same logic as `KVCache.makeMask` (reads only offset).
  - `trim(n)`: rewind offset, free now-unoccupied tail blocks. Stale
    bytes past offset are never read (fetch slices to offset; writes
    cover exact ranges) — same invariant as KVCache's padding.
  - Block table is host-side `number[]` — no device indirection.
  - All intermediates bound to locals and disposed
    (mlx-inline-slice-leak-pattern discipline).

**Wiring** — mirrors the verified `maybeQuantizeKv` precedent
(post-construction in-place mutation of the cache array,
generate.ts:153; no makeCache() signature change): `maybePageKv(cache,
options, capacityTokens)` called ONCE at generation setup (unlike
quantization there is no "convert when populated" trigger — paged
replaces EMPTY plain `KVCache` entries, offset 0 only, before prefill).
`GenerateOptions.pagedKv?: { blockSize?: number }`.

Gates:
- server startup (explicit refuse, not silent downgrade): `--paged-kv` +
  any of `--batch N>1`, `--kv-quant`≠off, TurboQuant, `--draft-model`,
  non-gemma4 model ⇒ exit with a clear message. With no explicit
  `--batch`, the CLI pins `--batch 1` (default is 8) and says so.
- request scope (documented v1 non-goal CELLS, scoped per request rather
  than 400'd): media (vision/audio) and LoRA-adapter requests strip the
  flag and run the plain cache path — one effective `pagedKv` value in
  runGeneration keeps the strip and the prompt-cache bypass coherent.
- serve serial lane: paged requests skip promptCache.take/put and the
  boundary snapshot; caches dispose on completion. Spec-decode
  eligibility gains `!options.pagedKv` (belt — the startup refusal
  already excludes the combination).
- batch lane: unreachable by construction (startup refusal pins serial),
  so no RequestShape change — noted here so the next increment knows the
  gate to add when batched paging lands.

Flag surface:
- CLI: `mlx-bun serve --paged-kv [--paged-kv-block-size N]` (default
  block size 256 = `KVCache.STEP`, so v1's growth granularity is a
  permutation of today's into reusable slots, not a new tuning axis).
- Env: `MLX_BUN_PAGED_KV=1` via `flagOn()` (explicit env wins).
- ServerOptions: `pagedKv?: { blockSize?: number }`, doc-commented like
  the neighboring kvQuant/turboQuant fields.

## Implementation order

1. **BlockPool + PagedKVCache + model-free unit tests**
   (tests/paged-kv.test.ts, FAST tier): block-boundary crossing,
   free-list reuse after trim, pool-exhaustion typed error, gathered
   fetch vs a plain-KVCache reference fed identical synthetic k/v
   (bit-equal every step), dispose-doesn't-leak. Exit: green with no
   weights.
2. **Wiring**: `maybePageKv` in generate.ts; GenerateOptions/
   ServerOptions/CLI flags; startup refusals; gateway shape exclusion;
   prompt-cache/spec bypass. Exit: flag parses, default-off inert;
   flag-on serves a completion end-to-end (gemma4); incompatible combos
   fail fast.
3. **Parity gate** (tests/paged-kv-parity.test.ts, weights-gated,
   skipIf pattern): bit-exact (tol 0) full greedy trajectory paged-on
   vs paged-off, incl. a ≥2-block prompt and a trim/rollback case.
   Exit: bit-exact; any divergence documented, never a loosened
   tolerance.
4. **Perf disclosure**: paged-on vs paged-off decode/prefill on a quiet
   machine via the preflight-gated harness (expected: small decode
   regression at M=1; report plainly). Numbers land in
   benchmarks/RESULTS.md when run on the reference machine.
5. **Docs, same commit**: server-config.md, cli.md flag rows;
   parallel-slots.md S3+ status flip (v1 shipped: serial, bf16,
   full-attention-only, gather-then-sdpa; batched + CoW + kernel still
   deferred); STATUS.md handoff; this doc.

## Risks

- Gather pays a full K/V copy per decode step once >1 block is occupied
  — pure tax at M=1 (disclosed, measured; the fused-kernel follow-up is
  the cure if it matters).
- Fixed pool sizing from prompt+maxTokens: a trim past a block boundary
  followed by regrowth must re-alloc from the free list correctly —
  dedicated test.
- trim/rollback against a block table is more failure-prone than
  KVCache's offset rewind — dedicated test, not incidental coverage.
- Every caller that could receive a PagedKVCache it can't handle
  (cloneKvCaches, prompt-cache put, compiled decode, batch scheduler)
  is excluded by gates above; the ones reached only through excluded
  paths throw typed errors if ever reached anyway.

## Follow-ups (out of scope, in dependency order)

1. **Batched integration** — PagedKVCache into the scheduler's
   LayerInner union; block-count admission replacing byte-projection;
   #mergeJoiner/#applyFilter/#extractAndPut allocate/free blocks
   instead of pad+concat. This is where the padded-batch-waste win
   actually lives.
2. **Block-level CoW prefix sharing** — refcounted block table
   (retain/release), fork-on-divergent-write; extends PromptCache's
   entry-level ref-counting down to blocks.
3. **Quantized paged blocks** — dtype-parametric block descriptor
   (packed/scales/biases pools sharing one block-index space).
4. **Fused paged-attention Metal kernel** — port optiq's
   sdpa_2pass_paged via the copy-verbatim methodology; kills the
   per-step gather copy.
