# GLM-5.2 on a 32 GB Mac — native MLX port of the Colibri hierarchy

*2026-07-21. Source baseline: `JustVugg/colibri` at
`44e489b196c9b7876b3d37a0570ebf1c6f90f54c` (post-v1.0.0). This plan is
grounded in the local Colibri checkout, its C/Metal implementation and tests,
and mlx-bun's indexed call graph. The original inspiration is Apple's
[AFM 3 Core Advanced](https://machinelearning.apple.com/research/introducing-third-generation-of-apple-foundation-models)
flash-resident sparse model; Colibri is the concrete GLM-5.2 implementation.*

*Revised 2026-07-21 after review: the 2 tok/s warm product target is set;
serial MTP moves onto the critical path as gate G4 and every later gate
measures with MTP on; batched multi-row MTP is descoped to post-release; the
G2 numeric parity contract is defined; the direct-Colibri baseline is reframed
as the bar the port is debugged against, not a go/no-go. Gates renumbered
G0-G8.*

## Decision

**Yes: a native MLX port should be feasible within an approximately 25 GB
runtime budget, but embedding or launching Colibri from mlx-bun is not the
goal.** Direct Colibri already provides that runtime. Putting its executable
behind mlx-bun would add API/CLI/tooling consistency, but it would not improve
memory use, I/O, or generation speed. That is not enough value for this project.

The recommended path is therefore a native `Glm52Model` plus an explicit
Apple-oriented expert residency runtime. The pinned Colibri build remains an
**external executable oracle** for formats, logits/tokens, routing, cache traces,
memory, and performance; its code is studied and its behavior reproduced, not
shipped inside mlx-bun.

Colibri is also no longer accurately described as CPU-only. Its opt-in macOS
backend already creates `MTLStorageModeShared` buffers and registers aligned
expert slabs with `newBufferWithBytesNoCopy`; routed expert SwiGLU, fused decode
MLA, and large prefill GEMMs can run on Metal over unified memory. The MLX thesis
is to express the model and tensor runtime in MLX and the orchestration,
residency policy, serving, tooling, and UI in Bun while retaining Colibri's
disk/LRU/prefetch hierarchy. Performance gates choose the winning MLX/custom-
Metal implementation at each boundary; they do not cancel the port. The port
decision is settled: the direct-Colibri same-machine numbers recorded in G0
are the baseline the port is debugged against — a gap versus the oracle is a
bug to close, not a reason to stop.

This is not a small extension of the current Gemma expert-offload flag.
GLM-5.2 adds a new model graph (MLA, DSA, shared+routed MoE, MTP) and Colibri's
memory result depends on an explicit residency scheduler that mlx-bun does not
yet have.

The honest product contract is:

- **RAM:** target <=25 GB measured RSS/physical footprint on the target
  machine — the M1 Max MacBook Pro with 32 GB, the only qualifying machine in
  this project's fleet (the 24 GB M4 Pro is below the one-slot-per-layer floor
  and out of scope) — including dense weights, expert slots, working buffers,
  KV, Metal transient, the Bun server, and an OS reserve.
- **Disk:** roughly 370 GB for the converted checkpoint, with at least 400 GB
  free for the ready-to-run artifact. Converting from source needs the output
  plus one source shard at peak because Colibri converts and deletes one shard
  at a time. Preflight (measured 2026-07-21): the target machine has ~556 GB
  unallocated plus ~123 GB purgeable — ~679 GB practically available
  (Finder's figure; macOS auto-purges snapshots/caches on demand). The
  requirement is met on the internal SSD with wide margin. Re-verify at
  download time; if an external drive were ever substituted, its measured
  bandwidth (Thunderbolt caps near ~2.8-3 GB/s) would lower the cold-token
  ceiling and must be entered into the resource plan.
- **Speed:** the product target is **>=2 tok/s warm on the M1 Max 32 GB with
  MTP on and quality-preserving defaults**. No 32 GB Mac has ever been
  measured by Colibri; the nearest primary-source datapoints (pinned checkout)
  are: 0.05-0.1 tok/s cold on the author's 25 GB dev box — a ~1 GB/s WSL2
  virtual disk, not a Mac (`docs/benchmarks.md:71`); 0.30 tok/s on a Mac Mini
  M4 Pro 48 GB with Metal and a 6.59 GB/s SSD (`docs/benchmarks.md:90`);
  0.42 tok/s warm on an M4 Max 128 GB (CPU 0.30 -> Metal 0.42, MTP on,
  `docs/metal.md:17`); 2.06 tok/s on an M5 Max 128 GB with a 46.9 GB learned
  pin at 72.5% hit, MTP off (`docs/benchmarks.md:89`). The target decomposes
  as a ~0.8-1 tok/s no-MTP base — the top edge of Colibri's own projection for
  the 3-5 GB/s-NVMe / 32 GB class (`docs/benchmarks.md:72`) — multiplied by
  MTP's measured 2.2-2.6 tok/forward (`docs/windows.md:88`,
  `docs/benchmarks.md:92`). This is why serial MTP is a requirement on the
  critical path, not a later optimization. If the target only closes with
  quality-changing knobs (expert top-p, reduced top-k), that is a finding to
  surface, not a default to ship.
- **Quality:** the default path keeps the checkpoint's precision and exact
  top-8 router decisions. Cache-aware routing, top-p expert dropping, and
  expert budgets remain explicit Lab experiments.

## What Colibri is actually doing

GLM-5.2 has 78 main layers: three dense FFN layers followed by 75 sparse MoE
layers. Each sparse layer has 256 routed experts and activates eight per token;
the MTP head adds another 256-expert row. That is 19,456 expert instances.
Colibri keeps the always-used dense graph resident at int4 (about 9.9 GB) and
stores the roughly 370 GB routed-expert pool on disk.

The runtime is a hierarchy, not a large mmap:

```text
router output (true top-8)
        |
        v
batch union of unique (layer, expert) requests
        |
        +--> pinned hot-store hit ----------------------+
        +--> per-layer LRU hit -------------------------+--> expert compute
        +--> miss -> bounded async pread -> work slot --+
                                  |
                                  +--> promote/evict LRU at a safe point

profile history -> startup pinning -> live LFRU repinning
next-layer router prediction ------> prefetch queue
RSS feedback ----------------------> shrink LRU capacity
```

The load-bearing pieces are:

1. **Streaming converter and container.** FP8 shards are converted one at a
   time to symmetric int4/int8 or grouped-int4. Every expert is addressable
   independently. Gate/up/down matrices and scales are laid out so a miss can
   be served with a coalesced read. MTP experts stay int8 by default because
   int4 MTP measured 0-4% acceptance.
2. **Resident dense spine.** Embeddings, lm-head, attention, norms, the first
   dense FFNs, routers, and shared experts remain resident. Only routed experts
   enter the tier manager.
3. **Compressed MLA KV.** Each token stores the 512-wide latent plus 64 RoPE
   values rather than reconstructed per-head K/V (576 floats/token, about 57x
   smaller than conventional KV for this geometry). DSA index state is stored
   only on the full-indexer layers.
4. **Per-layer bounded LRU.** Each sparse layer owns a fixed number of expert
   slots. A hit updates a monotonic use clock. Misses load into working slots;
   after compute, those slots swap into the least-recently-used cache slots.
   The capacity is derived from the whole-process memory equation, not a fixed
   expert count.
5. **Pinned hot-store.** A separate non-evicted tier is seeded from persistent
   `.coli_usage` counts. On macOS Colibri attempts to wire pinned slabs so the
   memory compressor cannot turn a logical hit into a slow page-in.
6. **Learning and live LFRU.** Every route increments persistent frequency,
   recent heat, and last-access time. At safe turn boundaries, LFRU can replace
   at most a few sufficiently colder pins; a 25%+4 hysteresis prevents
   oscillation, and recent heat decays without erasing long-term history.
7. **Hard RSS feedback.** The planner's estimate is not trusted blindly.
   Colibri samples actual RSS and, above 102% of budget +300 MB, frees the
   coldest LRU slabs in place and lowers the cache cap so they do not regrow.
8. **Batch-union.** Prefill and speculative verification route all positions
   first, deduplicate expert IDs per layer, load each unique expert once, and
   run it over every row that selected it.
9. **I/O/compute overlap.** A bounded worker pool performs positioned reads.
   Resident experts are submitted for compute before miss reads finish; missed
   experts join afterward. Linux can use io_uring; macOS uses positioned reads
   and `F_NOCACHE`/the direct-I/O equivalent. The three expert matrices are read
   together where the container permits.
10. **Predictive prefetch.** `PILOT` applies the next layer's router to the
    current post-attention state (measured 71.6% recall), and `COUPLE` uses
    observed cross-layer route pairs. Real prefetch loads only future layers,
    rechecks residency, and must never publish a partially filled slot.
11. **Metal execution.** On Apple Silicon, Colibri batches routed SwiGLU work
    over zero-copy aligned host slabs, fuses decode MLA attention, and runs
    large prefill GEMMs on Metal. It submits resident work before disk reads to
    overlap GPU execution with I/O; failures fall back per block.
12. **MTP speculation.** The native MTP layer proposes tokens and the main
    model verifies them in a batch. Draft and verify are forced onto the same
    kernel family (`SPEC_PIN=1`), because changing accumulation order destroyed
    acceptance. Grammar constrains the common target verification walk;
    prompt lookup is an alternative model-free draft provider, with one
    provider owning each request.
13. **Persistent conversations and slots.** Compressed MLA/DSA state is
    appended crash-safely and restored without re-prefill. The mux protocol
    supports independent KV slots and continuously batches one decode row per
    active slot; MTP is currently disabled in the mux path because it is not
    ragged-safe.
14. **Planner, diagnostics, and telemetry.** The runtime exposes dense/runtime/
    expert/KV bytes, disk service vs foreground wait, LRU/pin hit rates, tier
    maps, route heat, per-turn latency, queue state, and an explicit startup
    refusal when even one expert slot per sparse layer cannot fit.
15. **Expert observability and Atlas.** The live `EMAP` is one byte per expert:
    tier plus a log-bucketed usage count; `HITS` is a per-turn routing bitmap.
    Separately, the offline Atlas probe workflow builds replicated topic-affinity
    vectors for experts and publishes them to the web visualization. These are
    related data products, not one prefetch algorithm.

## What unified memory changes — and what it does not

Apple unified memory removes a host-to-VRAM copy. It does **not** make the
roughly 370 GB expert file addressable as memory on a 32 GB machine. The useful
native hierarchy is therefore:

```text
NVMe cold expert -> aligned resident shared-memory slot -> MLX/Metal consumer
                         |                         |
                         +-- optional mlock -------+
```

There should be no fictional RAM-versus-VRAM capacity split on Apple Silicon.
A Metal-visible expert and a CPU-visible expert occupy the same physical DRAM.
The meaningful state is disk, resident, wired/pinned, loading, in-flight, or
evictable. MLX can operate on that shared storage, but the LRU still decides
which approximately 10-12 GB of experts may coexist with the ~9.9 GB dense
spine, KV, activations, runtime allocations, Bun, and the OS.

The current mlx-bun proof already wraps page-aligned host pointers as MLX arrays
without a copy. There is an important lifetime limit: `MlxArray.fromPointer`
requires its backing storage to outlive every MLX reference and retained Metal
command buffer, which is why the existing mmap stays mapped for the process.
Reusable LRU slots violate that assumption unless eviction is fenced. The first
native spike must prove one of these safe designs:

1. native-owned fixed slabs registered once, never freed, whose contents are
   overwritten only after an MLX/Metal completion fence and generation check;
2. a custom Metal routed-SwiGLU kernel over registered slabs, with explicit
   command-buffer completion outside MLX array ownership; or
3. a new native external-buffer owner whose destructor and completion path never
   call into JavaScript.

Ordinary per-miss MLX array creation/copy is not acceptable. Nor may lazy MLX
graphs retain an evicted slot. Layer-safe `eval`/synchronization, slot generation
tags, and stress tests are part of the correctness contract.

mlx-bun already exposes MLX allocator controls (`setMemoryLimit`, `clearCache`,
cached/peak memory counters). The 25 GB planner must reserve and cap this
allocator explicitly, clear reusable temporaries at measured safe points, and
still use real process physical footprint as the final guard. MLX's cache limit
is not a substitute for whole-process RSS/footprint control.

Potential Apple wins that require measurement:

- MLX quantized GEMM/SDPA and compiled graph paths for the resident dense spine;
- fewer framework crossings and better scheduling of MLA/DSA/shared-expert work;
- a routed-SwiGLU Metal kernel integrated with the same stream as the model;
- direct GPU consumption of a freshly loaded shared slab, with no staging copy;
- mlx-bun's existing batching, KV tiers, grammar, and speculative infrastructure.

Colibri already has a fused decode MLA command buffer and zero-copy expert
Metal kernel, so MLX does not win merely by using the GPU. It must beat or match
those paths on the same artifact. CPU workers must also wait passively: Colibri
measured active OpenMP spin stealing the shared SoC power/thermal budget and
severely throttling Metal.

## Atlas, heat maps, and prefetch are three connected systems

The source separates concepts that the UI presents together:

- **Live cortex/heat map:** `eusage`, recent heat, last-access clocks, `EMAP`,
  and `HITS` show every expert's residency and activity. Persistent
  `.coli_usage` seeds auto-pin; recent heat plus recency drives live LFRU swaps.
- **Measured Expert Atlas:** a controlled offline sweep runs independent
  topic-tagged prompts, normalizes for category size, requires cross-prompt
  replication, and assigns per-expert topic-affinity/entropy. The published
  `experts.json` powers labels and the Atlas visualization.
- **Runtime prefetch:** `PILOT` predicts the next layer with its router;
  `PILOT_REAL` performs value-preserving speculative loads; `PILOT_TWO` adds the
  shared-expert correction; `COUPLE` uses measured cross-layer route pairs.

In the inspected Colibri source, the offline topic Atlas is observability and
interpretability data; it does not directly choose `PILOT` loads. The native
port should faithfully reproduce all three. It may additionally test an
Atlas-informed cold-start prior—classify or fingerprint the prompt, then warm
likely topic specialists—but that is a new experiment, not a claimed Colibri
behavior. It must beat plain persistent usage/PILOT without changing router
decisions.

## What mlx-bun already has

The codebase-memory graph confirms that the earlier AFM-3 investigation already
landed the essential Apple proof points:

- `src/expert-offload-build.ts` creates a page-aligned expert file.
- `src/expert-offload.ts` wraps that process-lifetime mmap as MLX arrays.
- `QuantizedSwitchLinear.load` redirects routed weights into the offload mmap;
  `forward` still uses the bit-exact `mlx_gather_qmm` path.
- `MmapFile.advise(offset, length, MADV_DONTNEED)` already supports explicit
  clean-page eviction by range.
- `src/expert-trace.ts` and the trace-analysis scripts measured expert skew and
  cross-task hot-set overlap.
- The 26B experiment measured roughly 17.1 -> 4.2 GB resident with no short-run
  decode regression and bit-exact output.
- The serving stack already has continuous batching, byte-capped prompt cache,
  disk KV persistence, memory admission, structured output, prompt-lookup and
  model-based speculative verification, OpenAI/Anthropic/Responses APIs,
  telemetry, a web app, and an existing custom Metal-kernel wrapper.

That removes major uncertainty, but the current offload implementation is not
a GLM-5.2 residency manager:

- it maps one whole expert tensor and relies on macOS page-cache policy;
- it has no per-layer expert-ID -> slot table or deterministic byte cap;
- it does not stream expert scales/biases (acceptable for Gemma, not necessarily
  for grouped GLM quantization);
- it does not coalesce gate/up/down reads or overlap them with resident compute;
- it has tracing but no persistent online usage profile, pinned tier, live LFRU,
  pilot/coupling prefetch, or RSS feedback loop;
- it only plugs into Gemma's `QuantizedSwitchLinear` loader;
- mlx-bun has GLM-4 dense support, but no GLM-5.2 MLA, DSA, router, shared MoE,
  or native MTP model class.

## Native MLX architecture

Colibri stays installed and runnable on the development machine as a pinned
external oracle. We use its public artifact directly if the native loader can
consume it, and invoke direct Colibri only from explicit parity/benchmark
workflows. There is no Colibri child process, backend protocol adapter, vendored
runtime, or `--backend colibri` product surface in mlx-bun.

The implementation is one in-process MLX model with a native macOS residency
helper:

```text
Glm52Model (MLX graph)
    |
    +-- MLA/DSA compressed caches
    +-- resident dense/shared weights
    +-- ExpertResidencyManager (TS policy + native storage/I/O/fences)
            |
            +-- fixed shared-memory slabs
            +-- pread worker queue
            +-- LRU/pin/LFRU/prefetch policy
            +-- routed-SwiGLU Metal/MLX kernel
            +-- route/heat/Atlas telemetry
```

The public Colibri container should be supported in place so users do not need
a second 370 GB copy. A future mlx-bun-native layout is justified only by a
measured Mac I/O or kernel improvement and must remain stream-convertible one
shard at a time.

### N1. GLM-5.2 graph

Add a dedicated `Glm52Model`; this is not the existing universal `glm4`
descriptor.

- Config fields: q/kv LoRA ranks; no-PE/RoPE/value head dimensions; first dense
  layer count; 256 experts/top-8; correction bias; routed scale; shared experts;
  DSA indexer schedule; MTP metadata; multiple EOS IDs.
- Attention: q-a -> norm -> q-b; kv-a -> latent norm; compressed MLA cache;
  weight-absorption decode; reconstructed prefill fallback; partial interleaved
  RoPE.
- DSA: indexer q/k/projection/norm, per-layer full/shared schedule, exact dense
  fallback when the selected set covers the whole prefix.
- MoE: sigmoid scores plus correction bias for selection, un-biased gate weights,
  true top-8, optional normalization/routed scale, shared expert in parallel.
- MTP: the 79th layer, `eh_proj`, norms, its independent partial KV row, and
  batched verify integration.
- Cache types: `MLACache` and `DSAIndexCache`, including per-row extraction and
  persistence state.

### N2. Colibri-compatible quant/container support

Support the public artifact directly: per-expert gate/up/down tensors, packed
symmetric int4/int8, per-row or grouped scales, int8 MTP shards, and optional
indexer shards. Do not keep grouped scales resident merely because the Gemma
prototype did.

Two kernel paths are needed:

1. a reference MLX composition for fixtures and parity work;
2. a custom Metal routed-SwiGLU kernel reading Colibri slot slabs directly.

The latter preserves the one-read-per-expert layout. Repacking into three
projection-major MLX tensors would turn one coalesced expert read into three
reads or add a copy, defeating a central Colibri optimization.

### N3. Explicit `ExpertResidencyManager` (hard gate)

State per sparse layer:

```text
cold -> loading -> resident-LRU -> in-use -> resident-LRU
                     |                         |
                     +------> pinned <--------+
                     +------> evict-pending -> cold
```

Required behavior:

- fixed byte budget and derived slots/layer;
- expert-ID -> slot lookup, monotonic LRU use clock, and a separate pinned set;
- a 64-unique working set for prefill/verify, bounded by actual union size;
- deduplicated concurrent loads and generation-tagged slots so stale workers
  cannot publish into reused storage;
- aligned native slabs holding gate/up/down weights and scales;
- no slot reuse until the Metal/MLX consumer has completed;
- eviction at model-safe points, never while a lazy MLX command can retain the
  buffer;
- real RSS/physical-footprint sampling and downward cap correction;
- startup refusal when dense + one slot/layer + working/KV/transient + OS reserve
  exceeds the budget.

The implementation should reuse Colibri's small, well-tested LRU/LFRU policy
code through a native helper or a faithful TS port, while native aligned
allocation, `pread`, `F_NOCACHE`, `mlock`, and worker threads live in C/ObjC.
Blocking disk reads must not run on Bun's event loop.

The current process-wide mmap remains a useful reference backend:
explicit per-expert LRU can call `MADV_DONTNEED` on evicted ranges after an eval
barrier. It is a bring-up step, not the final 25 GB contract; the slab backend
is the deterministic Colibri-equivalent implementation.

### N4. Scheduling and prediction

- Route the whole layer batch first, form the stable unique expert union, and
  gather all rows/weights per expert.
- Submit resident experts and the shared expert before starting/waiting for miss
  reads; submit missed experts in a second Metal command buffer and accumulate.
- Promote completed misses into LRU only after every consumer is done.
- Persist frequency counts atomically after each turn.
- Add startup `PIN=auto`, frequency/recency heat, decay, 25%+4 hysteresis, at
  most four live swaps per safe-point pass, and optional wire/unwire.
- Port PILOT measurement first, hint-only prefetch second, real-load PILOT third,
  and coupling/two-step prediction last. Every prefetch mode needs a paired
  hit-rate, disk-byte, p95-latency, and tok/s A/B; Colibri itself warns that
  prefetch can regress a saturated disk.

### N5. Cache and continuous-batching contract

The current `Cache` protocol and `BatchScheduler` are integration targets, not
automatic compatibility. GLM-5.2 needs three explicit state families:

- `MLACache`: compressed latent plus decoupled RoPE state and offset;
- `DSAIndexCache`: only the indexer state required by that layer's full/shared
  schedule;
- `MtpCache`: the MTP row's independent attention/cache state.

The serial versions must implement masking, state enumeration, trim/rollback,
disposal, and exact byte accounting without reconstructing full K/V for
storage. Then add a capability-based batched cache contract (names provisional)
rather than another list of scheduler class checks:

```ts
interface BatchableCache extends Cache {
  mergeRows(rows: Cache[]): void;
  extractRow(row: number): Cache;
  projectedBytes(tokens: number): number;
}
```

Required scheduler work:

- recognize every GLM cache row as batchable only after all three cache types
  implement merge/extract and per-row offsets;
- use compressed MLA+DSA+MTP byte projections in `#kvAdmits`, never the generic
  full-K/V formula;
- preserve joiner prompt-cache reuse, FIFO admission, row-local sampling,
  grammar state, stop sequences, errors, and cancellation;
- form the expert batch-union across all live rows so an expert is acquired once
  per layer/step and released after the shared GPU completion fence;
- extract completed/cancelled rows without retaining an expert-slot lease or a
  view into another row's cache;
- test mixed prompt lengths, join/leave churn, context limits, cancellation,
  grammar rows, and a forced expert miss during a row eviction.

Serial correctness is allowed before these capabilities land. The final model
must not claim batching support until the gateway's `willBatch()` and cache
checks admit it for the correct reasons.

### N6. Native MTP contract

MTP is part of GLM-5.2, not a separately loaded assistant model. Integrate it
with mlx-bun's speculative framework through an in-process draft source that
shares the target model and reports no duplicate weight allocation.

Serial MTP is a hard requirement on the critical path (gate G4): the 2 tok/s
product target assumes its measured 2.2-2.6 tok/forward multiplier, and every
later gate validates its workload with MTP on.

Serial path:

- load MTP experts at int8 and include their row in the residency budget;
- draft up to the configured gamma, verify with the main model in one batched
  forward, and trim target+MTP cache tails precisely after rejection;
- use the same request sampler and a `SPEC_PIN`-equivalent fixed kernel family
  for draft and verify so accumulation drift does not destroy acceptance;
- integrate grammar-forced tokens and prompt-lookup/ngram drafts without
  double-advancing caches;
- expose drafted, accepted, rejected, acceptance length, forwards saved, and
  end-to-end speed—not acceptance alone.

Batched MTP across concurrent rows is descoped from the release critical path:
at 2 tok/s single-user it buys little, and Colibri itself keeps MTP out of its
mux path because it is not ragged-safe. It remains a documented post-release
milestone:

- add per-row native-draft state to the scheduler;
- cohort eligible rows into bounded speculative rounds, pad/mask verification
  where draft lengths differ, and apply accept/rollback independently per row;
- ensure a cancelled or grammar-completed row cannot retain verification arrays,
  cache tips, or expert leases;
- fall back to ordinary one-token decode for an individual ineligible row while
  its siblings continue.

Telemetry and `/v1/models` must report the actual mode (`serial`, `batch`, or
`off`); it must never be silently disabled. Release (G8) requires serial MTP
and continuous batching to coexist — batched rows decode ordinary single
tokens — while per-row MTP under batching lands post-release.

### N7. Persistence contract

Extend mlx-bun's versioned `kv-store` rather than inventing a parallel GLM
session format. Add cache-kind discriminators and snapshot/restore support for
MLA, DSA indexer, and MTP state; bump the format only if the existing v3 header
cannot remain backward-compatible.

Persist:

- token history and exact per-cache offsets/lengths;
- compressed MLA latent+RoPE tensors only;
- DSA index state only on layers that own it;
- the MTP cache row when enabled;
- model/artifact identity, quantization/layout version, context configuration,
  and hashes needed to reject an incompatible restore.

Writes remain streaming, asynchronous, and crash-safe (`.tmp`, fsync, atomic
rename), materializing at most one tensor at a time. Restore must not build full
K/V or touch the expert file. Persistent expert usage/heat is a separate small
atomic profile: KV reset must not erase learned expert placement, and deleting
the usage profile must not invalidate a KV snapshot.

The existing prompt cache and SSD cold tier must receive accurate compressed
byte counts and support row extraction/demotion. Exit requires a restart at
multiple sequence lengths to produce the same next logits/tokens and cache
offsets as uninterrupted generation.

### N8. Serving, library, and CLI parity contract

"API parity" means the generative surfaces mlx-bun already exposes, with the
same request validation, stream shapes, finish reasons, errors, and usage
accounting as other text models:

| Surface | GLM-5.2 requirement |
|---|---|
| `POST /v1/chat/completions` | streaming/non-streaming chat, tools, stops, sampling, usage, structured output |
| `POST /v1/completions` | raw-tokenized text completion, streaming/non-streaming |
| `POST /v1/messages` | Anthropic message/tool blocks and event stream |
| `POST /v1/responses` | input/instructions, tools, streaming, `previous_response_id` continuation |
| `GET /v1/models` | GLM identity, context, reasoning/MTP/batching capability truth |
| `GET /health`, `GET /stats` | readiness plus memory, scheduler, MTP, expert-tier and I/O telemetry |
| library `generate(...)` | tokens, samplers, grammar, stop callback, stats, disposal |
| `mlx-bun chat` / `serve` | the same model path—no special runner or backend flag |

Required request features are SSE/disconnect cancellation, greedy and sampled
decode, penalties/logit bias where that protocol accepts them, logprobs through
the existing serial lane, tool round-trips, JSON schema/grammar constraints,
stop sequences, prompt-cache reuse, usage accounting, and bounded concurrency.
The HTTP translators must remain model-agnostic; GLM-specific behavior belongs
below `GenerationGateway`.

This does **not** imply embeddings, image/audio input, LoRA hot-swap, training,
or adapter APIs for GLM-5.2. Those are different model capabilities and must be
advertised false/unsupported rather than faked. Existing non-generation admin,
memory, hub, and web routes must continue to work but require no GLM-specific
semantics.

### N9. Observability, Atlas, and resource-planning contract

Add an expert block to `/stats` with budget/resident/wired/working/MLX-cache
bytes, LRU/pin capacity, hit/miss/prefetch counts, disk bytes/service/wait,
prefetch precision/recall, evictions, and pressure-driven cap changes. Serve the
packed per-expert tier/heat/hit map through a dedicated web data route so the
normal stats response does not carry 19,456 cells every poll.

The web experience includes:

- live layer x expert residency/heat cells and per-turn hit flashes;
- pinned/LRU/disk totals and pressure events;
- the offline replicated topic-affinity Atlas with provenance and confidence;
- I/O, cache, MTP acceptance, and latency timelines suitable for A/B runs.

`fit` and `doctor` expose the exact dense, expert-slot, 64-working-set,
MLA/DSA/MTP-per-slot, reconstructed-KV transient, MLX allocator, Bun, and OS
reserve equation. Startup refuses an impossible quality-preserving placement;
runtime physical-footprint feedback may shrink only the evictable LRU tier.

### Proposed code map

Names are provisional, but ownership should remain this explicit:

| Area | Production location | Responsibility |
|---|---|---|
| Model/config | `src/model/glm52.ts`, `src/model/glm52-config.ts` | graph, routing, MLA/DSA, factory registration |
| Cache | `src/model/glm52-cache.ts` | serial/batched MLA, DSA and MTP state; byte projection |
| MTP | `src/model/glm52-mtp.ts`, `src/spec/` adapter | native drafting, verify, rollback, metrics |
| Container | `src/model/glm52-container.ts` | manifest/index validation and tensor/expert offsets |
| Residency policy | `src/expert-residency.ts` | LRU/pin/LFRU state machine, leases, learning, prefetch |
| Native boundary | `src/native/` plus Bun FFI binding | aligned slabs, `pread`, no-cache hints, wire/unwire, completion fences |
| Kernels | `src/model/glm52-kernels.ts` | reference MLX compositions and selected Metal kernels |
| Resource plan | existing fit/memory modules | 32 GB equation, startup refusal, pressure feedback |
| Serving | existing gateway/scheduler/server | cache capabilities, MTP batches, protocol-neutral generation |
| Atlas/UI | expert trace/analysis scripts + web | live map, offline affinity workflow, A/B telemetry |

Do not put HTTP request parsing, Atlas visualization, or LRU policy into the
native helper. Do not put disk I/O or blocking waits into MLX model methods or
the Bun event loop. The native boundary exposes leases/completion signals; Bun
owns policy and observability.

### Test and workflow split

- **Every-commit, model-free:** synthetic container parsing, LRU/LFRU traces,
  short reads/errors/cancellation, slot-generation races, cache merge/extract,
  protocol regression, and memory-equation unit tests.
- **macOS Metal CI:** tiny routed-SwiGLU/MLA/DSA parity; repeated slot churn;
  external Colibri `make check` and `metal-test` at the pinned commit. No model
  download.
- **Tiny-model parity workflow:** deterministic generated GLM fixture for
  teacher forcing, MTP accept/rollback, KV save/restore, and two-row batching.
- **Full-model manual workflow:** the public artifact on a cleared machine;
  records commit/artifact/hardware/OS/settings, footprint/swap, cache/I/O,
  tokens, latency and throughput. It never runs in an agent session or CI.
- **Release gate:** API conformance suites exercise the same server twice—one
  ordinary supported text model and GLM-5.2—to prove the model did not fork the
  HTTP contract.

## What not to copy blindly

"Everything" means preserving every useful mechanism and every negative result,
not enabling every knob:

- CUDA multi-GPU, Linux io_uring, Windows shims, Power/AVX kernels, and NUMA are
  not part of an Apple-only MLX runtime. Their *roles* map to Metal, a macOS I/O
  worker, ARM kernels, and unified memory.
- `EXPERT_BUDGET` is quarantined upstream: tested settings damaged HellaSwag,
  produced incoherent decode, broke MTP's draft/verify contract, and were not
  faster. Keep it unshipped or behind an unmistakable research gate.
- `CACHE_ROUTE`, expert top-p, and reduced top-k change the model function. They
  are Lab tier, default off, with KL and task-quality gates. Several of
  Colibri's best small-RAM hit-rate numbers use expert top-p; the 2 tok/s
  target must be met without them.
- PILOT real loads can evict useful experts on a misprediction. It is an A/B
  optimization, not part of the correctness floor.
- MTP must not silently claim to be active under a scheduler that disables it.
- Colibri's projected cap was once wrong by tens of GB; the measured RSS guard
  is mandatory for the 25 GB promise.

## Risk register

| Risk | Earliest detection | Required mitigation |
|---|---|---|
| MLX retains an expert slot after policy release | G1 forced-churn poison/generation-tag test | explicit eval/completion fence; fixed native slab lifetime; never reuse on JS disposal alone |
| Lazy graph observes overwritten expert bytes | G1/G3 adversarial miss+evict trace | lease count plus slot generation checked before publish and before reuse |
| MLX allocator/transients break 25 GB | G1 counters, G5 physical-footprint trace | reserve allocator bytes, set limit, clear only at safe points, runtime LRU shrink |
| Prefetch saturates disk or evicts useful experts | G6 paired off/hint/real A/B | bounded queue, future-layer-only loads, residency recheck, default off unless positive |
| MTP accumulation drift collapses acceptance | G2 fixture, G4 oracle trace | fixed draft/verify kernel family and int8 MTP; acceptance + wall-time gate |
| Warm speed lands under 2 tok/s on the target machine | G0 baseline, G5 measured speed | gap-vs-oracle debugging (pin quality, I/O overlap, MTP acceptance); never quality-changing knobs by default |
| Batched cache merge/extract corrupts row offsets | G7 tiny mixed-length/cancel workflow | capability-based cache contract, row ownership tests, serial differential oracle |
| Persistence silently restores wrong artifact/layout | G7 restore-negative tests | model/config/quant/layout identities and tensor hashes; fail before allocation |
| Expert policy changes model quality | every routing golden | true top-8 default; policy moves weights only; approximate routing Lab-only |
| HTTP behavior forks for GLM | G7 dual-model API conformance | keep translation above `GenerationGateway`; no GLM branches in protocol builders |
| Public artifact format moves | G0 manifest inventory, loader tests | pin supported layout versions; reject unknown; one-shard converter fallback |
| Atlas overstates expert specialization | G6 leave-one-prompt-out workflow | normalized independent probes and replication gate; provenance in UI |

## Phased delivery and exit criteria

Critical path:

```text
G0 oracle baseline
  -> G1 safe shared slabs + kernel choices
  -> G2 serial GLM graph + compressed caches
  -> G3 full expert LRU execution
  -> G4 serial native MTP
  -> G5 <=25 GB full-model contract (MTP on)
       +-> G6 learning / Atlas / overlap / prefetch --+
       +-> G7 persistence / batching / APIs ----------+-> G8 release
```

G6 and G7 may proceed independently after G5, but G8 requires both. No phase may
claim a later capability early: for example, G2 can be serial-only, G3 can run
without MTP, and G7 cannot claim batching merely because ordinary KV caches
batch.

### G0 — establish the direct Colibri/Metal baseline

- Pin the external Colibri commit and record its license, public artifact
  identity, file inventory, config, tokenizer, int8-MTP presence, and disk
  envelope. Do not vendor it into mlx-bun.
- Build and run direct Colibri's model-free macOS workflow (`make -C c check`
  and `make -C c metal-test`) without model downloads.
- Verify >=400 GB free on the target machine at download time (measured
  2026-07-21: ~556 GB unallocated + ~123 GB purgeable ≈ 679 GB practically
  available — met on the internal SSD with wide margin).
- On the cleared M1 Max 32 GB machine, run the public artifact directly with
  Metal and capture physical footprint, compression/swap, LRU/pin capacity,
  hit rate, disk bytes/wait, first-token latency, and cold/warm tok/s — each
  with MTP on and off.
- Export tiny deterministic GLM/quant/DSA/MTP and routing/cache-trace fixtures.

G0 inventory note (2026-07-21): the exact pin, artifact/layout contract, and
manual checklist are recorded in
[`../investigations/colibri-oracle-pin.md`](../investigations/colibri-oracle-pin.md).
Because the pinned Makefile writes ignored build artifacts and even creates a
configuration stamp while parsing, model-free oracle targets must run from a
temporary `git archive` extraction, not in the read-only checkout. The pinned
tiny generator covers GLM/MLA/DSA but does not emit a complete MTP layer; the
checked-in [`../../fixtures/colibri-glm52/`](../../fixtures/colibri-glm52/README.md)
package therefore contains a narrow exact-pin model-free capture for Python
quantization, Apple-ARM quantized matmul, DSA, LFRU, and elementary
RMSNorm/sigmoid. Its operator/router/LRU/MTP material is explicitly derived
scaffolding. It does **not** claim teacher-forced numeric GLM/MLA/MTP-head/KV
outputs or measured neural acceptance. Those require a real model oracle and
were the two remaining G0 blockers before the closure evidence below.

G0 closure (2026-07-22): both blockers are now closed. The complete public
artifact was run directly on the 32 GiB M1 Max with Metal unified-memory
zero-copy. Six matched fresh-process/direct-I/O cells (three MTP-off, three
MTP-on) and bounded same-process pairs with KV reset establish the explicit-LRU
cold/warm baseline. A measurement-only archived-copy build emitted 140
teacher-forced GLM/MLA/router/MTP/KV records twice, byte-identically; the
validated compact oracle is tracked under `fixtures/colibri-glm52/`. All 145
LFS payloads match pinned-revision SHA-256. For reproducibility, **cold** here
means a fresh process with an empty explicit LRU and macOS `F_NOCACHE`
(`DIRECT=1`), not an unrepeatable claim that no file on the machine had been
read since boot. **Warm** means request two in the same PID after RESET clears
KV but preserves the explicit expert LRU. In the authoritative three-process
per-mode matrix, fresh-turn throughput is 0.34 tok/s MTP-off versus 0.26 tok/s
MTP-on, with median peaks of 13.631/17.475 GB and no process swaps. MTP reduces
main forwards by 52% but adds 34.6% expert traffic and 29.1% wall time. Live
telemetry (~4.9 GB/s reads, 0 writes, 24% GPU, 16.1 GB/s unified-memory
bandwidth) confirms the initial optimization target is overlapped expert
delivery/residency rather than more arithmetic throughput.

The artifact lacks DSA indexers, so the direct public-artifact baseline
explicitly runs DSA-off. At G0's 128-token context this does not change
attention selection: the first 21 layers are full-attention layers and DSA's
`topk=2048` cannot prune such a short history. G2 retains the exact-pin
model-free DSA fixtures and will generate a **separate immutable indexer
overlay** by extracting only the indexer tensors from 20 pinned stock FP8
source shards (~99.90 GiB read, ~197 MB output). The overlay must never mutate
or duplicate the 357 GiB serving snapshot.

**Exit:** a reproducible same-machine oracle baseline is recorded — footprint,
hit rate, disk service/wait, TTFT, cold/warm tok/s, MTP on and off. These
numbers are the bar the port is debugged against for the rest of the program:
a gap versus direct Colibri is a bug to close, never a reason to cancel the
port. They also tell us early how much of the 2 tok/s target comes from
matching the oracle versus beating it.

### G1 — unified-memory MLX storage foundation

- Build a model-free synthetic expert file in Colibri's gate/up/down layout.
- Implement fixed aligned native slabs plus bounded positioned-read workers.
- Prove zero-copy MLX/custom-Metal consumption, command completion fencing,
  generation-tagged slot reuse, eviction, and allocator-cache control.
- Benchmark Colibri Metal and candidate MLX paths for representative int4 dense
  GEMM, routed SwiGLU at decode/prefill row counts, and MLA decode attention.
- Measure CPU/GPU power contention with passive workers; reject busy-spin.

**Exit:** no hidden expert copy, stale read, use-after-reuse, or monotonic memory
growth under forced churn. Select and record the fastest correct MLX/custom-
Metal execution path for each kernel shape, then proceed with the full port.

#### G1 implementation status (2026-07-22)

The agent-safe foundation is implemented and independently audited. A strict,
versioned model-free artifact preserves one-read contiguous gate/up/down bytes
and separately contiguous scales. The native helper owns fixed 16 KiB-aligned
slabs, uses a bounded `pthread_cond_wait` worker pool plus full positioned reads,
and exposes nonblocking Bun polling. Slot pointers are observable only through
matching generation-bound leases. GPU release requires the dependent lazy MLX
outputs, evaluates them, synchronizes their selected stream, and only then
publishes the slot as reusable; close refuses live leases.

The stress gate includes short-read/cancellation/error paths, post-close access,
stateful hit/miss/evict traces, 1,000 native reloads with stable addresses and
bounded RSS, 100 GPU-fenced reloads with flat MLX active+cache accounting, and a
reproduction of the lazy-graph poison race. Both stock MLX and custom Metal
consume the same slab, including a complete synthetic gate/up/down region.
The helper remains an internal, build-only G1 artifact via
`scripts/build-expert-io.sh`; G3/G8 integration will publish it in a newly
versioned native pack and update the distribution reference in the same change.

G1 closed on 2026-07-30 with the manual quiet-machine gates. After aligning
both harnesses to identical production shapes, a ten-warmup/fifteen-sample
matrix selected custom Metal for routed SwiGLU decode M=1: 4.282 ms versus
5.099 ms for stock MLX (16.0% faster), with max absolute output delta
`2.33e-9` and relative RMSE `5.56e-7`. An independent three-warmup/eleven-
sample run also selected custom Metal by 5.4%. Stock MLX remains selected for
Q4 dense decode/prefill, routed M=11 ragged and M=32 prefill, and absorbed MLA
decode. Direct Colibri remains the same-shape performance oracle; the largest
observed residual is MLA decode at 1.014 ms direct versus 11.506 ms stock MLX.

The passive-worker matrix retained raw mactop samples for matched no-worker,
1-, 2-, and 4-worker arms and repeated the worker arms in reverse order. No
monotonic CPU, GPU, or package-power increase appears as worker count rises,
confirming that the `pthread_cond_wait` pool does not busy-spin. Two workers
remain the bounded default. Swap was unchanged at 339.25 MiB through both
kernel runs. Raw artifacts are under `runs/colibri-g1/`.

### G2 — native GLM-5.2 correctness spine

- Implement config, tokenizer/template, dense graph, MLA compressed KV, DSA,
  router/shared MoE, and reference expert math against tiny fixtures.
- Add Colibri container parsing and per-tensor validation.
- Define the numeric parity contract before debugging begins: bitwise equality
  where the math is deterministic (int4/int8 dequantization on identical
  inputs, router top-8 selection, cache byte accounting); trajectory-level
  equality for floating-point logits (tie-free greedy token match plus a
  recorded max-logit-delta bound). Cross-implementation Metal accumulation
  order is not expected to match bitwise by default — the SigLIP parity
  investigation established sub-bf16 accumulation as an expected residual, not
  a bug.
- *(Added 2026-07-22.)* Colibri shows the stronger contract is attainable by
  construction: its Metal and CUDA tiers pin numerics to **dequant→f32
  multiply-accumulate** and produce greedy outputs byte-identical to its CPU
  engine (`docs/metal.md`). Our custom kernels adopt the same dequant→f32-MAC
  discipline — the `SPEC_PIN` philosophy applied to the whole expert path.
  Where we also match the oracle's accumulation semantics, the
  greedy-trajectory gate hardens to a bitwise claim; the trajectory-level
  bound remains the fallback only for paths whose accumulation order is not
  ours to pin (e.g., stock MLX kernels on the dense spine).

**Exit:** layer/op goldens pass under the recorded contract; tiny-model teacher
forcing is 32/32 token-exact on a tie-free greedy trajectory against the pinned
Colibri engine; full-model dense/router probes match within the recorded
bounds.

#### G2 implementation status (2026-07-24)

The dedicated correctness path is implemented. `glm_moe_dsa` configuration is
parsed independently of the stale source-checkpoint FP8 metadata; the factory
has an artifact-aware `openModel()` entrypoint; the GLM fallback template pins
roles, thinking blocks, and tool formatting; and EOS IDs are the union of model
and generation configuration. A header-only catalog reads `out-*`,
`out-mtp-*`, and optional `out-idx-*` safetensors directly, infers Q4/Q8 from
payload/scale geometry, and validates every expected global, attention, dense,
shared, routed-expert, DSA, and MTP tensor before graph construction.

The MLX correctness backend opens those shards lazily on the CPU stream.
Colibri Q4 bytes are repacked lazily into MLX's uint32 affine layout with
`bias=-8*scale`; Q8 restores the signed two's-complement byte before applying
its scale. MLA stores only compressed latent and decoupled RoPE state, supports
reconstructed causal prefill and absorbed single-token decode, and gathers DSA
positions without first materializing full K/V. The DSA state is correctly one
shared `[B,T,index_head_dim]` key—not one key per index head—and implements
full-layer selection plus scheduled reuse. MoE routing uses biased sigmoid for
selection, lower expert ID for exact ties, unbiased sigmoid for execution,
routed scaling, and an unweighted shared expert.

Focused tests cover config/container failures, layout/dispatch, Q4/Q8
dequantization, reference f32 arithmetic, partial interleaved RoPE, compressed
cache bytes and trim, reconstructed/absorbed MLA equality, DSA threshold/ties,
sparse decode, exact row-wise fallback when a multi-token prefill crosses
`index_topk`, exact router ties, shared+routed composition, the template, and
independent one-layer dense and MoE host oracles. Header-only validation of
the pinned public artifact completed without executing the model and reported
59,003 quantized tensors, 472 floats, 19,456 routed experts, MTP present, and
DSA absent.

The pinned 32-token gate is tracked as
`fixtures/colibri-glm52/tiny-teacher-forcing.json` and selected with
`MLX_BUN_GLM52_TINY_COLIBRI`. On 2026-07-24 an isolated Python 3.12 environment
with Torch 2.8.0, Transformers 5.12.0, and safetensors 0.8.0 ran the pinned
Colibri generator. Transformers' default grouped-MoE dispatcher has no Torch
2.8 CPU kernel, so generation selected its mathematically identical eager
expert implementation; the resulting BF16 trajectory reproduced committed
`c/ref_glm.json` exactly.

The raw toy model was then converted with Colibri's own converter to the
production-relevant per-row Q4 direct format. Its 9/32 score against the BF16
trajectory is simply the quantized model differing from the source model; the
correct cross-engine oracle is the same Q4 bytes in both runtimes. An initial
default-vs-default comparison produced 26/32 because the two defaults did not
compute the same function: on Apple Silicon Colibri enables `IDOT=1`, which
quantizes each activation row to int8 before the packed-int4 dot product and
documents about 0.3% additional RMS error per matmul. The G2 contract instead
pins the quality-preserving dequant-to-f32-MAC path, selected in Colibri with
`IDOT=0`.

Under that matched contract, pinned Colibri C and mlx-bun are 32/32 on the same
Q4 artifact. An archive-only Colibri instrumentation build dumped all 8,192
f32 logits: max absolute delta is 1.3113e-6, mean absolute delta 2.1548e-7,
RMSE 2.7423e-7, and the minimum MLX top-two margin is 0.003425. The fixture
records exact commands, oracle flags, exact-path and default-IDOT trajectories,
numeric bounds, and raw/config/container hashes; the generated 353 KiB
container lives at `runs/colibri-glm52-tiny-i4` (gitignored). `IDOT` is now an
explicit approximate-performance candidate for a later quality/performance
gate, not the correctness oracle.

The production-artifact gate is also closed. The bounded runner opens only the
shard owning the cell under test and never constructs the full model, experts,
KV cache, tokenizer, or generation loop. On the captured real decode row,
layer 0's complete Q4 gate/up/down SwiGLU matched pinned Colibri `dense_mlp`
with `IDOT=0` at max absolute delta 5.2387e-9 and RMSE 9.7823e-10. The real
layer-3 and layer-77 routers reproduced every top-8 ID and `keff=8`; their
sigmoid max deltas were 4.7684e-7 and 7.1526e-7. Two fresh processes produced
identical numeric reports. This run caught a production-only loader defect
that the tiny artifact could not expose: MLX has no affine-dequant Metal kernel
for Colibri's logical whole-row group size 6144. Repeating the identical
per-row scale over supported 32-value groups preserves every dequantized value
and selects an available kernel. With the tiny artifact gate enabled, the
focused GLM suite is 55 pass, 0 fail after the fix.

The probe peaked at 1,566,883,896 MLX allocator bytes and 290,455,552 observed
process RSS; system free memory stayed at 78% and swap usage was unchanged.
The stable evidence and bounds are tracked in
`fixtures/colibri-glm52/production-probe.json`, with the reproducible runner at
`scripts/probe-colibri-glm52-production.ts`. G2 validates the complete MTP
container/config surface; serial MTP execution and rollback remain G4 under
the revised order.

### G3 — native bounded LRU and slab execution path

- Add the native I/O helper, slot manager, LRU/pin states, RSS guard, batch-union,
  and the winning batched routed-SwiGLU MLX/Metal kernel from G1.
- First run with pure LRU; add persistent auto-pin only after the baseline.

**Exit:** forced hit/miss/evict traces match a reference policy exactly; no
partial/stale slot can be observed under stress; quality-policy tokens match
direct Colibri for a tie-free trajectory.

#### G3 implementation status (2026-07-24, in progress)

The direct artifact now has one canonical routed-expert slot catalog and a
native multi-file scatter-read pool. Production Q4 experts occupy 18,939,904
aligned bytes; every MLX-addressed component has an independently page-aligned
offset. The 19,114 ordinary main experts use four positioned reads and the 86
shard-boundary cases use six, below the fixed eight-segment limit. Idle
generations can be decommitted without changing their virtual addresses, and
live pressure uses the process `phys_footprint` counter rather than historical
peak RSS.

The first policy implementation mirrors Colibri's physical tiers: one global
64-slot working bank, fixed per-layer LRU slots, and a separate pinned bank.
Misses are promoted only after a shared GPU fence by swapping logical slot
roles with free/LRU destinations; expert payloads are never copied. Stable
row/rank batch union, reverse miss promotion, deterministic LRU ties, startup
refusal, failure drain/discard, and safe-point-only downward capacity
correction have focused tests.

An async GLM-only execution seam preserves the synchronous G2 model as the
oracle. Its stock-MLX candidate wraps packed slot bytes directly, submits
resident/shared work before miss reads, materializes each <=64-expert wave
before releasing leases, and composes rows in exact route order afterward.
The resident tensor source rejects routed-expert names, closing accidental
mmap fallback. The tiny direct Q4 container remains 32/32 token-exact through
this path. The bounded production layer-3 expert probe reproduces exact top-8,
matches the complete Colibri routed+shared output at max absolute delta
1.8626e-9, and remains byte-identical after a forced LRU eviction with zero
swap growth. The custom M=1 Metal candidate is implemented and explicitly
selectable.

The production full-model trajectory now passes as well. A 32-token prefill
and one decode forward reproduce the tie-free Colibri token sequence
`[16,13]`, with margins 2.9581 and 7.0824. The direct streamed run ends at
13,474,688,232 bytes physical footprint and 11,007,206,184 bytes MLX peak
allocation, with 64 working slots, 75 resident slots, and no loading or leased
slot left behind. Bring-up first exposed a G2-only memory amplification:
materializing the 154,880×6,144 signed-int8 embedding and output head as full
f32 tensors. The streamed source now gathers embedding rows before dequant,
evaluates the output head in bounded row tiles, uses MLX affine Q4 matmul for
the resident spine, and synchronizes each layer as a residency safe point.
A per-wave live guard records cumulative swap counters and aborts at a caller
bound. The passing non-cleared run recorded 397,148,160 bytes of system-wide
swapout while other applications were open; the strict cleared-machine
zero-swap contract remains G5. Evidence:
`fixtures/colibri-glm52/g3-full-model-trajectory.json`.

G3 closed on 2026-07-30 after the quiet kernel/power matrix selected custom
Metal for M=1 routed decode and stock MLX for ragged/prefill shapes. The final
adversarial code review found no numeric, alignment, ownership/UAF, or budget
blocker; its two cleanup-path findings were fixed before the focused/native
suite was rerun.

### G4 — serial native MTP (requirement)

Serial MTP lands ahead of the memory contract because the 2 tok/s target
assumes it, and because it changes the workload every later gate must
validate: verify forwards route a larger per-forward expert union, and the
verify batch plus the MTP row's KV live inside the 25 GB envelope.

- int8 MTP row sharing target weights, included in the residency budget;
- draft to the configured gamma, one batched verification forward, exact
  target+MTP cache trim after rejection;
- the same request sampler and a `SPEC_PIN`-equivalent fixed kernel family for
  draft and verify — accumulation drift destroys acceptance;
- grammar-constrained verification and the model-free prompt-lookup provider
  without double-advancing caches or grammar state (one draft provider owns a
  request);
- report drafted/accepted/rejected, acceptance length, tok/forward, forwards
  saved, and end-to-end speed — not acceptance alone.

**Exit:** the accept/reject trace matches the direct-Colibri oracle for a
tie-free trajectory; measured tok/forward and a net end-to-end win over
MTP-off on the same artifact. All subsequent gates run with MTP on as the
default workload.

G4 closed on 2026-07-30. `Glm52NativeMtpProvider` runs the artifact's single
MTP layer in-process, shares the target embedding/output head/dense weights,
and gives the signed-int8 routed row its own bounded 24-working + 1-resident
expert tier. The 945,356,800-byte MTP expert slab and the remaining MTP
tensors are included in the main fixed-byte residency plan. Draft, verify,
accepted-row absorption, and rollback use the same request sampler and
row-independent custom Metal families (Q4 target and signed-Q8 MTP);
M=1/M=4 and M=1/M=3 row-stability tests lock that accumulation contract.

The cache state machine advances the MTP row once per proposal, retains the
first true-target-conditioned row, discards the speculative tail, and rebuilds
accepted rows from the target's verified hidden window. Thus target and MTP
offsets remain aligned after partial or zero acceptance. Grammar remains in
the existing constrained verify walk: proposals never advance the matcher,
only target-accepted emitted tokens do. Prompt lookup remains the alternative
model-free `DraftProvider`; exactly one provider owns a request, avoiding two
independent draft histories or double cache/grammar advancement.

The direct `IDOT=0,SPEC_PIN=1` oracle and mlx-bun match all 64 target tokens
and the tie-free first four acceptance rounds `[1,1,1,0]` (the first eight
emitted tokens; minimum direct first-draft margin 3.5675). The complete direct
acceptance trace is preserved but is not an exact cross-engine gate: direct
Colibri reduces RMSNorm squared sums in float64, while the established MLX
graph reduces in float32. That difference recurs through 78 layers and can
change later MTP proposals without changing the target trajectory.

The separate-process production A/B is positive. MTP-on took 675.654 seconds
for the exact 64-token trajectory versus 834.172 seconds off: 1.235x wall
throughput, or 19.0% less generation time. It drafted 92 tokens, accepted 32,
rejected 60, used 31 verify forwards, emitted 2.065 tokens per verify forward,
and saved 32 target forwards. The completed MTP-on process footprint was
14,679,224,320 bytes, but the machine was not swap-cleared; this is G4
correctness/performance evidence, not the G5 memory-contract result. Stable
records: `fixtures/colibri-glm52/g4-direct-mtp-trace.json` and
`fixtures/colibri-glm52/g4-native-mtp-e2e.json`.

### G4R — prompt-seeded MTP research spike (deferred 2026-07-30)

G4 deliberately copies direct Colibri's decode-only MTP window: target prompt
prefill is complete, but the independent MTP KV row begins with the first
draft. That implementation is the control, not a permanent restriction.
Josh explicitly deferred this optional research spike so G5 can measure the
landed decode-only default first.
Investigate a candidate that batch-seeds MTP KV from the already-computed
prompt pairs `(token[i+1], target_hidden[i])` before drafting. It must reuse
captured target hidden rows rather than rerun target prefill.

The oracle for this spike is emitted output, not Colibri's internal draft or
acceptance trace. Promotion requires bit-for-bit target-output identity in the
gated greedy and seeded-sampling cells, correct rollback/cancellation behavior,
and a paired end-to-end wall-time win after charging the additional MTP
prefill. Report TTFT, MTP-prefill time, decode and total time, acceptance,
target forwards, footprint, and swap across short/long prompt and continuation
cells. A decode-throughput or acceptance-only win is insufficient. If the
candidate loses or exceeds the G5 envelope, retain the decode-only default and
record the negative result.

### G5 — 32 GB memory contract (measured with MTP on)

- Port the full resource equation and expose every line item.
- Set a conservative one-slot, 4k-context quality preset for 32 GB machines;
  allow explicit overrides but refuse impossible starts.
- Include MLX allocator cache/transients, native slabs, Bun, physical footprint,
  and the OS reserve; shrink only evictable LRU slots under real pressure.
- Measure with MTP on: the verify batch, the MTP KV row, and the larger
  per-forward expert union are part of the accounted workload.

The header-only preflight now runs before resident weights or native slabs are
opened. Its pinned-artifact MTP-on equation is:

| Process line item | Bytes |
|---|---:|
| Resident dense/shared/router/MTP weights | 10,877,286,144 |
| Main expert slab: 64 working + 75 resident | 2,632,646,656 |
| MTP expert slab: 24 working + 1 resident | 945,356,800 |
| Target compressed MLA KV, 78 layers × 4k | 736,100,352 |
| Decode-only MTP KV, 1 layer × 4k | 9,437,184 |
| Reconstructed target K/V at 4k + verify rows | 537,395,200 |
| Target verify + MTP draft visible rows | 4,508,672 |
| MLX allocator/cache reserve | 4,294,967,296 |
| Bun/native reserve | 536,870,912 |
| Safety margin | 536,870,912 |
| **Planned process** | **21,111,440,128** |

The 25 GiB process ceiling therefore retains 5,732,105,472 bytes of planned
headroom. The process is never allowed to consume the remaining 7 GiB of the
32 GiB machine; that is the explicit OS reserve. The target verify union needs
at most 32 of the 64 working slots and MTP reserves all 24 possible
`topK × gamma` draft slots.

The manual gate uses separate fresh processes for MTP on and off. Each process
runs a cold and then warm 128-token turn: request KV is rebuilt, while expert
residency remains warm. It records task physical footprint, RSS, MLX active/
cache/peak allocation, expert residency, `vm_stat` compressor occupancy, and
swap every 15 seconds. Any swapout or footprint above 25 GiB aborts at the next
token boundary; compressor occupancy may grow by at most a documented 256 MiB
to tolerate unrelated system activity, and warm final footprint may exceed
cold by at most 256 MiB. The first 64 tokens remain pinned to direct Colibri;
the complete 128-token cold/warm and MTP-on/off outputs must be identical.
Strict enforcement is the default. For a diagnostic before/after run,
`--memory-mode observe` records the same violations and completes generation
instead of aborting; its paired result is labeled `observed`, with a separate
`strictContractSatisfied` field. Observation mode never silently changes the
fixed thresholds.

Run from a cleared 32 GB M1 Max:

```sh
MODEL=/Users/joshrossi/.cache/huggingface/hub/models--mateogrgic--GLM-5.2-colibri-int4-with-int8-mtp/snapshots/3cc8db99b1b13fc79325d987ba3c1c430766b3b8
LIBRARY="$PWD/dist-native/libmlx_bun_expert_io.dylib"
test -f "$LIBRARY"
mkdir -p runs/colibri-g5
bun scripts/probe-colibri-glm52-g5-memory.ts --mode on --model "$MODEL" --library "$LIBRARY" --output runs/colibri-g5/mtp-on.json --trace runs/colibri-g5/mtp-on.memory.jsonl
bun scripts/probe-colibri-glm52-g5-memory.ts --mode off --model "$MODEL" --library "$LIBRARY" --output runs/colibri-g5/mtp-off.json --trace runs/colibri-g5/mtp-off.memory.jsonl
bun scripts/check-colibri-glm52-g5-memory.ts --on runs/colibri-g5/mtp-on.json --off runs/colibri-g5/mtp-off.json --output runs/colibri-g5/summary.json
```

For the explicit observational run requested on 2026-08-15, add
`--memory-mode observe` to both probe commands. The fresh-process pair
completed all four 128-token turns with exact direct-prefix, cold/warm, and
MTP-on/off identity:

| Lane | Baseline footprint | Cold final | Warm final | Peak | Cold -> warm | Cold / warm e2e |
|---|---:|---:|---:|---:|---:|---:|
| MTP on | 0.078 GiB | 13.666 GiB | 13.688 GiB | 13.791 GiB | +23.1 MiB | 0.146 / 0.149 tok/s |
| MTP off | 0.078 GiB | 12.564 GiB | 12.583 GiB | 12.644 GiB | +19.2 MiB | 0.127 / 0.114 tok/s |

Warm MTP-on was 1.306x MTP-off. Each MTP-on turn accepted 72/166 drafts,
emitted 2.286 tokens per target forward, and saved 71 target forwards. Both
peaks retained more than 11 GiB of headroom below the 25 GiB ceiling, but they
remain below direct G0 warm throughput (~0.27 tok/s on and ~0.34 off).

The pair is intentionally not called a strict pass. Whole-system compressor
growth peaked at 4.101 GiB, task-compressed growth at 1.806 GiB, and the
MTP-off lane observed 6.8 MiB of swapout (MTP-on zero), so the checker reports
`strictContractSatisfied: false`. These changes were bounded: the task ended
near its observed compression maximum and final footprint changed by only
23.1/19.2 MiB across cold to warm rather than spiraling. The run also exposed
two wiring gaps now closed: speculative/server and manual-probe paths hold a
scoped MLX wired limit based on the complete streamed process plan, and native
expert slots are wired before their read begins then unlocked before discard.
Machine-local reports and 15-second traces are under `runs/colibri-g5/`.

**Exit:** startup and a 128-token run with MTP on remain <=25 GB measured
footprint (small documented tolerance only), with flat memory and no
compression spiral, swap/OOM kill, or hidden duplicate weights. Record cold
and warm speed, MTP on and off, against the direct-Colibri G0 baseline.

### G6 — Atlas, overlap, learning, and prefetch

- I/O worker pool, direct/no-cache reads, resident-first Metal submit, persistent
  usage, live LFRU repin, PILOT/coupling/two-step variants.
- Emit live tier/heat/hit maps; port the controlled Atlas probe/analyze/validate
  workflow and expert-affinity visualization.
- Treat any Atlas-informed topic warm-start as a separate new experiment.

Implementation status (2026-08-15): batch-union, bounded positioned-read
workers, `F_NOCACHE`, and resident-first submission were already in the G3
foundation. G6's first new slice adds one shared target/MTP `.coli_usage`
ledger in the direct Colibri three-column format. It records every top-k route
before union deduplication, keeps loaded long-term frequency separate from
session heat/recency, and atomically publishes at generation safe points.
The opt-in startup auto-pin consumer is also implemented: the direct 5k-history
floor, 200k full-confidence point, half-tier share, and 0.5 GB minimum are
preserved, while deterministic ties and exact Q4/Q8 slot costs keep the shared
target/MTP plan within its hard floor. Selected pins are preloaded before the
first forward. The opt-in live LFRU consumer preserves the direct uint32
recency score, 25%+4 hysteresis, heat halving, and a single four-swap turn cap
across target and MTP; logical role exchange avoids copying expert slabs.
Residency maps expose tier plus frequency/heat/recency and aggregate hit/miss/
repin counters. Neither learning policy is defaulted before its MTP-on A/B.

The paired runner charges policy I/O separately from demand while reporting
both, including disk-service/foreground-wait and main/MTP layer-forward
percentiles. It learns one MTP-on seed profile in a separate process and copies
the identical seed into every control/candidate process:

```sh
MODEL=/Users/joshrossi/.cache/huggingface/hub/models--mateogrgic--GLM-5.2-colibri-int4-with-int8-mtp/snapshots/3cc8db99b1b13fc79325d987ba3c1c430766b3b8
LIBRARY="$PWD/dist-native/libmlx_bun_expert_io.dylib"
bun scripts/probe-colibri-glm52-g6-learning.ts \
  --model "$MODEL" --library "$LIBRARY" \
  --output-dir runs/colibri-g6-learning --memory-mode observe --repeats 3
```

One repeat is a harness shakeout only; the summary marks a policy decision
eligible only at three or more fresh-process repeats. The runner refuses to
overwrite an existing arm, so a rerun must use a new output directory.

**Exit:** each lever has a paired cold/warm A/B with hit rate, disk GB/token,
disk-service vs foreground-wait, p50/p95/p99 forward latency, and tok/s — all
measured with MTP on (a lever that wins MTP-off but loses MTP-on is not a
default). Only positive Apple results become defaults. Atlas labels reproduce across prompts;
prefetch remains value-preserving and never changes selected experts.

### G7 — persistence, concurrency, and full API parity

Serial MTP already landed in G4; this gate integrates everything around it.

- [ ] **G7a compressed persistence:** extend `kv-store` cache kinds for MLA,
      DSA and MTP; atomic async save, validated restore, prompt/SSD byte
      accounting, no reconstructed full K/V.
- [ ] **G7b continuous batching:** batched cache capability, compressed-byte
      admission, merge/extract, cross-row expert union, join/leave/cancel.
      Batched rows decode ordinary single-token; per-row MTP under batching is
      post-release (see N6), and telemetry reports the actual mode.
- [ ] **G7c serving parity:** chat/text completions, Anthropic Messages,
      Responses continuation, streaming/disconnect, tools, structured output,
      stops, sampling/penalties, serial logprobs, usage and truthful discovery;
      library `generate`, CLI chat/serve, health/stats. GLM-5.2 chat-template
      rendering, thinking-block policy per surface, and tool-call parsing are
      explicit work items — the existing tool-call parser is Gemma-only today.

**Exit:** uninterrupted vs restored next logits/tokens and offsets match at
multiple sequence lengths; batched rows are parity-checked against serial rows
under mixed lengths and cancellation (ordinary decode — batched MTP is
post-release); both stream and non-stream protocol suites pass across all four
generative HTTP surfaces. Unsupported non-generative GLM capabilities are
advertised false, not emulated.

### G8 — productization

- Expert brain/tier telemetry, `fit`/doctor UX, model acquisition/conversion,
  third-party notices, and benchmarks.
- Update README plus `docs/reference/{models,memory,cli,server-config,
  server-api,library-api,features-matrix}.md` in the same feature changes that
  add the corresponding flags, fields, routes, defaults, and limitations.
- Add a 32 GB quickstart, artifact/disk preflight, recovery/resume instructions,
  and explicit cold/warm expectations.

**Exit:** a new 32 GB user can go from adequate disk space to a working GLM-5.2
chat with one documented command sequence; the headline bar — **>=2 tok/s warm
on the M1 Max 32 GB, MTP on, quality-preserving defaults only** — is met and
recorded with provenance in `benchmarks/RESULTS.md`; no default silently
changes precision or routing.

## Test matrix

| Gate | Direct Colibri oracle | Native MLX port |
|---|---:|---:|
| Colibri macOS `make check` + Metal tests | required | oracle only |
| zero-copy slot lifetime/churn/fence stress | comparison | required |
| tiny GLM op/layer/teacher-forcing goldens | fixture source | required |
| same-artifact 32-token greedy stream | baseline | required |
| <=25 GB on the cleared M1 Max 32 GB (MTP on) | baseline | required |
| 128-token flat memory / no swap | baseline | required |
| cold/warm hit, I/O, latency, tok/s report | baseline | required |
| warm >=2 tok/s, MTP on, quality-preserving defaults (M1 Max 32 GB) | baseline | required |
| live heat map + offline Atlas replication | baseline | required |
| MTP accept/reject trace + net speed | baseline | required |
| MLA/DSA/MTP KV restart at short/mid/wrapped lengths | baseline | required |
| 2/4-row merge/extract + mixed-length decode parity | comparison | required |
| batched MTP mixed accept/reject/cancel trace | comparison | post-release |
| chat/completions stream + non-stream | comparison | required |
| text completions, Messages, Responses protocol suites | comparison | required |
| tools, grammar, stops, penalties, usage, serial logprobs | comparison | required |
| truthful model/stats capability discovery | comparison | required |

## First implementation slice

Do not start by porting MLA. First establish the safe storage and execution
foundation that the native MLX implementation requires:

1. Build direct Colibri with Metal and measure the public GLM-5.2 artifact on
   the M1 Max 32 GB machine.
2. Generate a small local file in Colibri's expert layout; no model download is
   needed for this spike.
3. Add a Lab-only native fixed-slab/LRU harness with async positioned reads and
   both MLX/custom-Metal consumers.
4. Stress slot reuse and prove completion fences, zero-copy behavior, flat RSS,
   and deterministic LRU traces.
5. Benchmark representative expert/attention kernels against direct Colibri.

Then proceed to the GLM-5.2 graph and direct-container loader. A slow MLX
composition is a reason to add or tune a custom Metal kernel behind mlx-bun's
MLX model boundary, not a reason to abandon the Bun+MLX port.
