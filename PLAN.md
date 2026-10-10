# Refactor plan

Open work only; delete a block when its exit criteria are met. Josh has authorized the library and application migration through a first full
draft; keep changes focused and reviewed. Standalone Pi integration is deferred. Ownership and documentation rules live in [ARCHITECTURE.md](ARCHITECTURE.md).

Decisions that govern all work:

- One engine: the continuous batching scheduler. A single request is a batch of one; there is no second one-at-a-time engine or fallback path. A shape the scheduler cannot run yet gets a typed error.
- Main is reference-only, not an oracle to reproduce: an improvement over main is fine when bit parity (where the numerical contract requires it), performance and test gates hold.
- mlx-bun is a drop-in superset of mlx-lm: the `mlx-bun.<cmd>` aliases accept mlx-lm arguments (landed in #241; the flags they refuse are listed in the
  [app README](apps/mlx-bun/README.md#mlx-lm-compatibility-mlx-buncmd)).
- Refactor acceptance requires numerical parity, preserved functionality and no
  performance regressions. Knowledge benchmark scores characterize the candidate
  quant for its Hugging Face model card; that publication work has its own criteria.
- Legos compose at load. A graph never contains a fallback to another graph, the cache owns its read, and the
  scheduler calls named phases. The composition refactor below is the current structural work.

## Composition refactor

Status: draft, 2026-10-10; Josh approved this plan. One PR per numbered item, targeting `main`,
not merged without Josh's instruction. Delete a block when its exit criteria are met.

### Target

Every served configuration is one composition, built once at load from the user's model choice,
their flags and the machine. The loader builds the graph, the cache and the drafter for exactly
that configuration. The scheduler decides what work runs and calls the phase it is in. The graph
runs the layers it was built with and never inspects its input or its cache. The cache owns
storage, the read, prefix reuse, paging, SSD offload and eviction behind one interface. Each piece
implements its contract and never checks what another piece is doing, because nothing below the
scheduler decides anything at run time. Vision, adapters and KV scheme are compositions, never
refusals. A generic graph for a family is a complete structure the loader may select when no
specialized one matches; a specialized graph never contains a path back to it.

Batching is not a mode. The scheduler is the one engine and a single request is a batch of one,
as the first refactor established. One request or four requests run the same composition: the
scheduler batches the rows it has, up to `--batch-size`, and calls the phase operation for that
row count. The graph builds one operation per phase per width class its kernels define (one row,
2 to 4, 5 to 8, wider) and the scheduler picks by the rows it is loading, never the graph by
inspecting its input. Row-wise layers take M rows and do not know whether they are one sequence
or M sequences. Only `attend` and the recurrence see the row layout.

Why: the pairing of storage and read kernel, of row count and MLP kernel, of device and graph, is
known before a request exists. Re-checking it on every forward costs CPU on decode's critical path,
multiplies the numerical paths a parity test has to cover, and is how batching came to drop the
optimized kernels: the M4 Pro graph is organized as whole-forward plans keyed on one sequence, so
any batch fails the plan and the whole forward goes generic, MLP included. Row-wise layers do not
care whether M rows are one sequence or M sequences; only attention and the recurrence do, and
those read per-sequence state the cache owns.

### Rules the gate holds when this plan closes

- A graph extends nothing and never calls another graph's forward.
- No runtime flag, env var, `deviceArchitecture()` call, `globalThis` read or `instanceof` of a
  layer or cache class inside a forward, attend or kernel-dispatch body. Constructors, `build`,
  `load`, graph acceptance functions and the loader may read them. Development profiling hooks
  (`__deltaProf`, `MLX_BUN_SPEC_*` diagnostics) are exempt and listed by name.
- The cache contract has no representation-specific escape hatch (`updateAndFetch`,
  `quantizedAttention`, `rotatedValueAttention`, `affineConversion`, `turboConversion`).
- The graph contract names its phases; the scheduler calls them by name.
- Existing violators ride the seam ratchet in `packages/inference/tests/architecture.test.ts`:
  counts only fall. The ratchet is a transition device, not a resting state: every entry is
  owned by a numbered item in this plan, and when the plan closes no example of a banned pattern
  remains in the tree. Agents copy what they read, so a catalogued bad example is still a bad
  example.
- Every gate failure message names the paved road: what to do instead and where it lives (the
  generator script, the contract method, the layer directory), so the mistake teaches its fix at
  the moment it is made.
- One supported way per pattern, written down in ARCHITECTURE: add a model by generating its
  graph; add a kernel as one file in `kernels/` bound by one layer; read a cache through
  `attend`; add a phase through the graph contract. A second way to do any of these is a gate
  failure, not a style note.

### Decisions

Closed by Josh, 2026-10-10:

- **Off-composition requests** keep the existing typed refusal from declared capabilities for
  now. This applies to the graph only; legos still compose at load, and a composition that lacks
  a lego is a different composition, not a refusal.
- **Draft depth.** `--num-draft-tokens N` is fixed depth; `adaptive` means the scheduler chooses
  each round among the verify widths the composition built. The drafter is chosen by
  `--draft-kind` (`dflash2`, `mtp`, ...).
- **Quantized KV is a cache lego whose first append is bf16.** Corrected 2026-10-10 by A3's
  equivalence test, which overturned the premise recorded earlier: today's served path and
  mlx-lm's loop both run the first forward against unquantized keys and convert afterwards,
  even with `quantized_kv_start` 0. So the lego `--kv-quant N` composes keeps that behavior
  inside itself (bf16 through its first append, quantized storage after; `--quantized-kv-start
  M` extends the bf16 span to M tokens), which preserves today's numbers and mlx-lm parity with
  no check outside the cache. A cache quantized from token zero is a different composition with
  different first-chunk numbers (up to 0.125 at 4 bits on a test tensor), no mlx-lm oracle, and
  a cheaper first chunk; it exists as its own lego, opt-in, gated by KL. Provisional until Josh
  confirms which the default `--kv-quant N` should compose; the parity-preserving one is
  recorded here as the default.
- **KV scheme is a serve flag.** `--kv-quant` composes the cache lego at load. The per-request
  `kvBits`, `kvConfig` and `quantizedKvStart` options are removed; mlx-lm's server takes these as
  server flags too.
- **The TQ graph** is broken into its pieces, which join the lego box where they are reusable,
  and the file is deleted when the M1 Max composition is generated.
- **`--batch-size`** is the cap on rows per forward the scheduler may batch. Nothing else.

Open:

- [ ] **Bit-stability across batch width.** The factored row kernels (1 row, 2 to 4) and the
      matrix-unit kernels (5 to 8) reassociate differently, so a request's last bits can depend on
      how many rows were batched with it. Either require every width class of a phase to be
      bit-identical per row (one kernel family across widths), or accept bf16-level variation by
      batch width, documented and gated by KL. "One request or four, it works" is true either way;
      "identical to the bit either way" needs the first.

### Phase A: contracts (no behavior change)

#### A1. The cache owns the read

`contracts/mlx/cache.ts` has four read shapes today: `updateAndFetch` (bf16 hands tensors back),
`quantizedAttention.updateAndFetchQuantized` (affine hands packed tensors back),
`rotatedValueAttention` (TurboQuant), and `attentionState.appendAndFetch(k, v)` returning a view
with `attend(q)` (paged, already owns its read). Make the paged shape the only one.

- [ ] Define the single attention interface: append k and v, then named reads. One operation for
      the single-row decode read and one for the window read, so the calling phase picks and
      nothing branches. The cache builds its own mask from the offsets and row layout it owns;
      `makeMask` becomes internal.
- [ ] Define the SSM cache's recurrence operation the same way: the cache owns conv state and the
      gated-delta state update; the DeltaNet block hands it the projected inputs.
- [ ] Mark `updateAndFetch`, `quantizedAttention`, `rotatedValueAttention`, `affineConversion` and
      `turboConversion` deprecated on the contract, removed in B1.
- [ ] Keep `RowBatchCache` and `BatchableCache` (`rowOffsets`, `filterRows`, `extractRow`): the row
      layout is the one thing the scheduler passes through to the stateful layers.

Exit: the new interface compiles beside the old members; no caller moved yet; `bun run typecheck`
and `bun run test` pass.

#### A2. The graph names its phases

- [ ] Add `prefillChunk`, `prefillTail`, `decode` and `verify` to `contracts/mlx/graph.ts`, with
      the capture callback a parameter of `verify`. Vision prefill is prefill with embeddings and
      positions, which `forwardEmbeddingsAtPositions` already is.
- [ ] `decode` and `verify` exist per width class (one row, 2 to 4, 5 to 8, wider), declared by
      the graph as a table of operations the scheduler indexes by the rows it is loading. The
      graph never derives the class from its input.
- [ ] Keep `forwardHidden` and `forwardHiddenMixed` until E2 moves every caller, then delete.
- [ ] `verifyRoundCosts` stays as declared data; the scheduler's adaptive gate reads it.

Exit: every existing graph implements the four by delegating to its one forward, one line each;
no scheduler call site changed yet; tests pass.

#### A3. Composition facts reach the loader

- [ ] `createModel` takes the composition: device, ANE bridge present, KV scheme, draft depth,
      prefill chunk size, adapters, max rows per forward (`--batch-size`, default 8, which bounds
      the width classes the graph builds). The app's `loadContext` in
      `apps/mlx-bun/src/engine/model-host.ts` already holds all of these when it creates the model.
- [ ] `resolveKvScheme` in `apps/mlx-bun/src/engine/cache-services.ts` runs before model creation
      and feeds the composition instead of becoming per-request options afterward.
- [ ] `makeCache()` takes the composition's KV scheme. Building the lego it names is B1's work:
      A3's equivalence test showed that a cache built quantized from token zero differs from the
      convert-after path in its first forward's numbers (see Decisions) and, past the offset, in
      the preallocated padding's scales, so the lego must reproduce the convert-after semantics
      inside itself rather than being the plain quantized cache.

Exit: a loaded graph can print its composition; behavior unchanged; tests pass.

### Phase B: state

#### B1. Every cache implements the one read

`state/` may import `layers/` and `kernels/`, so the attention kernels move under the caches
without a gate change.

- [ ] bf16: `kv.ts`, `batched-kv.ts`, `rotating-kv.ts` and their row storage implement append plus
      the two reads over the stock SDPA kernels.
- [ ] Affine: `quantized-kv.ts`, `batched-quantized-kv.ts`, `rotating-quantized-kv.ts` over
      `layers/quantized-attention.ts` kernels. The M4 Pro composition's 4-bit group-64 head-dim-256
      cache is its own class: KV4 decode kernel for the row read, folded GQA for the window read.
- [ ] TurboQuant: `turboquant-kv.ts`, `batched-turboquant-kv.ts` over their codec. B1c found the
      codec still picks its decode kernel per call (`tryDecodePackedKv` returns null and the
      eager decode runs): the kernel is fixed at construction with the rest of the scheme, and
      the null path goes. `appendBidirectional` on the TurboQuant caches (Gemma 4 image prefill)
      is still to implement.
- [ ] The quantized lego `--kv-quant N` composes is bf16 through its first append and quantized
      storage after, inside its own `appendWindow`/`appendDecode` (the state transition the
      three `delayed-*-kv.ts` caches do today, owned by one lego built at load), so the first
      forward's numbers equal today's and mlx-lm's. A separate quantized-from-token-zero lego is
      opt-in and KL-gated. Equivalence against the convert-after path is checked below the
      offset bit for bit and by first-forward logits; the padding past the offset is the lego's
      own and is not compared.
- [ ] Paged: `state/paged/cache.ts` already conforms; align names. B1a found its direct
      kernel was chosen by query count (8 or fewer); the window kernel becomes a construction
      choice of the paged lego (direct up to the composition's verify width, SDPA otherwise),
      and the batched paged lego's window read is per row by design (the old joined-rows path
      differed by up to 1e-3 and falls under the bit-stability decision).
- [ ] B1a's first divergence: a single-position append on a rotating cache keeps today's
      numbers only through the in-place write, which is `appendDecode`; a one-row window
      concatenates and reorders the keys after the ring wraps (up to 3.9e-3). E2 maps the
      planner's last-token-alone step to `appendDecode`, or the planner stops producing it.
- [ ] Wire one `AttentionMasks` memo per model into every `makeCache()` (one line each) when
      C1 and D3 move the graphs onto the new reads; until then each cache builds its own mask
      and no graph calls the new reads.
- [ ] One mask build per forward: the caches of one forward derive their mask from the row
      layout once (the scheduler's `state/layout` object), not once per layer.
- [ ] The three reads A1 found that the two phases do not cover, each already its own named
      interface, implemented only by the caches composed for them: `appendCommitted` (fill
      spans, today's independent-rows path through `quantizedAppendAttention`),
      `appendBidirectional` (Gemma 4 vision prefill, DiffusionGemma's encoder), `readBlock`
      (DiffusionGemma's canvas pass, DFlash 2 block attention over the context).
- [ ] `state/ssm.ts` implements `recurDecode` and `recurWindow`, and the training cache sits
      behind the same calls, which removes the `instanceof TrainingSSMCache` branch in the block.
- [ ] Delete the device check (`applegpu_g16s` head-shape case) in `quantized-attention.ts`
      (B1b: grouped heads give the same bits as the plain kernel on the M4 Pro at every size
      tried, so the case is a speed choice for the depth-2 verify composition, kept as its own
      lego). The env flag `MLX_BUN_NO_FUSED_SDPA` is a composition rule the app writes today:
      uniform `--kv-quant N` serves the unfused kernel (mlx-lm's port, parity) and
      `--kv-quant config` the tiled one (OptiQ parity). The affine lego takes its kernels
      explicitly at construction: `unfusedAffineKernels` (mlx-lm parity),
      `tiledCausalAffineKernels` (OptiQ's own wrapper rule: tiled while the cache's mask is
      plain causal, unfused once the cache's own state makes it an array, so `config` composes
      this one), and `tiledAffineKernels` (always tiled, no oracle, KL-gated, opt-in); the
      tiled constructors refuse a configuration that cannot tile; the loader composes by the
      scheme's kind;
      the flag read stays in the deprecated `quantizedSdpa` path, untouched, until the graphs
      read through `attend` (D3) and the app stops writing it (E3).
- [ ] Out of this step, each needing its own contract before its graph can move: GLM-5.2 MLA
      compressed attention (`models/glm52/mla.ts`), the Gemma assistant drafter's donor reads,
      softcap attention in the universal dense graph and the training flash path (these become
      the composed cache's read for those compositions), and the segmented backward's donor
      checkpoints in `models/gemma4/trainable.ts`.
- [ ] The deprecated members leave the contract in D3, once every graph reads through `attend`.

Exit: `quantizedSdpaUnfused` and `kv4DecodeAttention` have no callers outside `state/`; the
kernel each cache dispatches per read is fixed at construction; bit-identical logits for every
cache class against its pre-refactor read on the existing parity inputs; `grep` for
`quantizedAttention` in `models/` and `layers/` is empty.

#### B2. Eviction, prefix reuse and SSD inside the cache

- [ ] Compose `prefix-cache.ts`, `tiered-prefix-cache.ts`, `ssd-cache.ts`, `persistence.ts` and
      the budget (`execution/kv-budget.ts`) into one cache service constructed with its budget.
- [ ] The scheduler's surface is acquire(request) returning state plus reused-token count, or a
      miss, and release(request). The scheduler never learns what is resident or when it was
      evicted.
- [ ] Delete `state/kv-maintenance.ts`; its batch preparation moves to `state/layout.ts`.

Exit: saved KV under `MLX_BUN_HOME/kv` round-trips as before; prefix hit rate on the existing
warm-reuse test is unchanged; no `toQuantized` caller outside `state/`.

### Phase C: layers

#### C1. Qwen blocks become legos

- [ ] Move `GatedDeltaNet`, `Qwen3Attention`, `Qwen3MLP` and `Qwen3Layer` from
      `models/qwen/qwen3_5.ts` to `models/qwen/blocks.ts`. The projection loader injection stays.
- [ ] The attention block calls `cache.attend`; its three-way branch on cache representation and
      `independentRows` goes.
- [ ] Follow-up, after the DeltaNet block takes the SSM cache contract instead of the concrete
      class: move the blocks to `layers/`.

Exit: `Qwen35Model` and the M4 Pro graph both import from `blocks.ts`; no `extends` between
them; bit-identical generic forward.

#### C2. `TrellisLinear` stops choosing

- [ ] Remove the per-call variant read and the five-way kernel dispatch from `forward`. The layer
      keeps the one prefill kernel the default variant selects; row-count kernels already have
      their own layers (`trellis-gate-up.ts`, `trellis-down.ts`).
- [ ] `setTrellisVariant` survives only as explicit bench scaffolding; `MLX_BUN_TRELLIS_VARIANT`,
      `MLX_BUN_TRELLIS`, `MLX_BUN_TRELLIS_ASYNC_EXPAND` are not read on the hot path.
- [ ] PR #311's five `MLX_BUN_TRELLIS_*` flags in `kernels/trellis/scatter.ts` and
      `mixed-gate-up.ts` become separate kernels or bench-only scaffolding.

- [ ] Kernels take their representation choices as required arguments; the device-dependent
      choice is made once in the layer's constructor and stored, never inside a kernel body.
- [ ] After the C2 PR merges and the paired serve benchmark has passed on both machines (the
      M1 Max parity test needs that host and the q4b artifact), delete the frozen pre-C2 layer
      `tests/kernels/trellis-linear-reference.ts` and the identity test that uses it; the PR is
      the record of the maxDiff-0 result.

Exit: `grep runtimeFlag\|runtimeValue\|runtimeNumber packages/inference/src/layers/trellis-linear.ts`
is empty; no `deviceArchitecture()` call inside a kernel function; bit-identical outputs against
the default variant on the M4 Pro and the M1 Max; paired serve benchmark shows no regression.

#### C3. The ANE split owns its programs

- [ ] `layers/ane-prefill-split.ts`: programs are instance-owned and disposed with the layer; no
      module-level maps.
- [ ] Programs are built for exactly the chunk size; no buckets, no minimum-row floor. The
      leftover chunk is `prefillTail` on the GPU.
- [ ] ANE programs compile at install, the way Apple's own pipeline compiles a model for the
      Neural Engine on the device and caches it (Josh, 2026-10-10). The installer, or the app's
      first launch, compiles every program the shipped compositions need and leaves them in the
      framework's cache, so no prompt ever pays the compile and the serving process never
      compiles. The MIL source ships in the bundle as the compiler's input. Shipping the compiled
      form itself, one per Neural Engine generation built on a host of that generation, stays
      possible later; it is not required.

Exit: two graphs can coexist in one process without evicting each other's programs; KL gate on
ANE prefill unchanged; after install, the first ANE prefill on a fresh machine loads from the
cache and compiles nothing, measured by the bridge's own `compiledModelExists`.

### Phase D: graphs

#### D1. `Qwen38TrellisM4Pro` as an entire graph

- [ ] `implements MlxDeclaredGraph`, extends nothing. Constructor takes the composition and builds
      embedding, norms, head, and per layer the block set each phase needs: decode blocks, one
      verify block set at width depth+1 (or the set the adaptive decision names), chunk blocks with
      the ANE split when the bridge is present, tail blocks.
- [ ] Vision prefill phase included because the model has vision; mRoPE in the attention block.
- [ ] Adapters: the LoRA-applying linear in the composition that serves adapter rows.
- [ ] The 40 interleaved and 24 row-major down projections are read from the quant table once at
      construction.
- [ ] `draftTarget` declares the hidden-layer taps and the residual basis (R1 seed, final-norm
      gain).
- [ ] Removed: the plan table (`#planFor`), the guard in `forwardLayers`, every `super` call, the
      capture hook, the `instanceof TrellisLinear` checks, the head's row switch, the KV bits read.

Exit: `grep "extends\|super\.\|instanceof\|globalThis" qwen38-27b-trellis-m4pro.ts` is empty
except the listed profiling hook; bit-identical logits per phase against the stack's graph on the
same phase; the Qwen generator (D2) produces it.

#### D2. Generators are the asset

- [ ] Fix the template in `packages/inference/scripts/gen-gemma4.ts`: no `extends`, no
      `#matches`, named phases. Regenerate `gemma4-e4b.ts`, `gemma4-12b.ts`, `gemma4-26b.ts`.
- [ ] Write `packages/inference/scripts/gen-qwen38.ts` taking the composition as input; the M4 Pro
      graph and the M1 Max graph are its outputs. The hand-written TQ graph is broken into its
      reusable pieces and deleted.

Exit: `git diff` of a regenerated file against its committed version is empty; the generated Gemma
parity test passes on e4b and 12B; no generated graph extends a graph; no hand-written
specialized graph remains, so the only example of a specialized graph an agent can read is a
generated one.

#### D3. Generic graphs

- [ ] `Qwen35Model`, `Gemma4Model`, `MiniCPM5Model`, `Qwen3Model`, `Qwen3MoeModel`, GLM and the
      universal graph implement the four phases by delegation and take their cache through
      `attend`. Their other internal branches are out of scope here.
- [ ] `createAppend` in `Qwen35Model` no longer checks the device; the loader composed it.

Exit: no graph reads `quantizedAttention`; bit-identical generic forwards.

### Phase E: loader, scheduler, app, drafter

#### E1. Loader selection table

- [ ] The `qwen3.5` entry in `models/factory.ts` becomes a table keyed by fingerprint, device,
      bridge, KV scheme, depth, chunk size, adapters and max rows. The generic graph is the entry
      yielded when nothing specialized matches. The same shape for Gemma's `GENERATED` map.

Exit: selection is data; `qwen38TrellisM4ProAccepts` and the nested ternary are gone.

#### E2. Scheduler calls phases

- [ ] `execution/batch-group.ts` (decode and verify call sites), `prefill-rows.ts`,
      `speculative-group.ts`, `grammar-group.ts` and `fill-group.ts` call the named operation for
      their phase.
- [ ] `AdaptiveDraftGate` stays in the scheduler and chooses among the verify widths the
      composition built when `adaptive` was requested.
- [ ] The scheduler indexes the graph's operation table by the rows it batched: one request is
      one row and calls the one-row decode; four requests call the 2-to-4 decode; verify width is
      rows times depth+1. No flag and no mode; `--batch-size` is only the cap.
- [ ] Batching sends M rows through the row-wise layers; only `attend` and the recurrence see
      `rowOffsets`.
- [ ] Call sites A2 found that do not fit the four phases, each resolved explicitly, none by
      inspecting shape:
      - Tapped prefill: the DFlash 2 and DSpark drafters capture hidden layers during prefill.
        `prefillChunk` and `prefillTail` take the capture the way `verify` does; no mutable
        `hiddenTap` field survives.
      - Two capture paths exist today (`legacyForwardWithTaps` setting `hiddenTap`, and the
        mixed lane's callback) and they differ per graph: the TQ graph runs the generic loop
        under the mixed path, and generated Gemma falls to the monolith under `hiddenTap`. E2
        keeps one, gated by bit-identity against the other.
      - Mixed iteration: `advanceMixed` packs a decode group and a prefill group into one
        forward. Either two phase calls, or a composition that declares it serves mixed rows.
      - The compiled decode step is chosen at run time from one row's state with a fallback to
        the ordinary forward. The composition decides compiled or not at load; the fallback goes.
      - Media rows: decode through `forwardHiddenAtPositions` with a positions grid, prefill
        through `promptInput.forward`. The vision prefill phase takes embeddings and positions.
      - Known-token appends (`createAppend`, grammar spans, fill's `verifyKnown`): a fifth named
        phase over the committed read, `appendKnown`.
      - The prefill planner's snapshot-boundary cuts and its last-token-alone step map onto
        chunk and tail explicitly, or the planner changes; nothing infers "whole chunk" from a
        length.
      - GLM verify kernel pinning (`pinVerify`): the composition pins at load.
      - The DFlash 2 drafter's draft block picks its kernel once per block from anchors × width
        (E4): the draft operation becomes a width-classed table like the graph's `verify`, and
        the scheduler indexes it by the rows it is drafting for.
      - Prefill cohorts split a row's planned chunk when a sibling's chunk is shorter (B1d).
        A quantized lego converts by its own stored length, so a split chunk converts at the
        split and reads after it change (0.24 at 4 bits measured); today's rows layouts convert
        at the planned boundary instead. Decide: the planner never splits a row's planned
        chunk, or conversion per forward is accepted under the bit-stability decision. Until
        then the `delayed-*` rows caches keep the planned-boundary timing.
      - A verify window that crosses a lego's start converts even if its tail is rejected; the
        lego converts on commit while a speculative round is armed (the cache's own state).
- [ ] Delete `forwardHiddenMixed` and `forwardHidden` from the contract.

Exit: one request and four concurrent requests on the M4 Pro composition both dispatch the
Trellis row kernels for their width, shown by the op inventory diagnostic, with no generic path
entered; a request's output across batch widths satisfies the bit-stability decision above;
paired batched-lane benchmark records the gain at one and four rows.

#### E3. App

- [ ] `--kv-quant` composes the cache lego before the model loads.
- [ ] The per-request `kvBits`, `kvConfig` and `quantizedKvStart` options leave `generation/types.ts` and the server request plan; the cache lego is composed at load from `--kv-quant` and `--quantized-kv-start`.
- [ ] `--num-draft-tokens adaptive` is served by the scheduler choosing among the built widths; a number is fixed depth.

Exit: `serve-cli.test.ts` and the draft-flags test pass; the CLI inventory regenerates with no
new flag.

#### E4. DFlash 2

- [ ] `Dflash2Provider` loads the drafter unrotated and folds `fc` when it binds, from the
      target's declared basis. `MLX_BUN_DFLASH2_TARGET_BASIS` is deleted. (PR #334, draft.)
- [ ] The basis needs a recorded source before #334 can merge: the quantizer folds the
      final-norm gain γ into `lm_head` and writes the norm as zeros, and nothing in the artifact
      records γ, so no graph can declare it today and the drafter would run unrotated
      (acceptance collapses, output stays exact). Fix: `packages/quantize` records `final_gain`
      (γ = stored + 1 of the source's final norm) in `turboquant_fold.json` beside the seed;
      the published `mlx-bun/Qwen3.8-27B-Trellis-3.2bpw` sidecar gets the values computed
      from the bf16 source (a one-off, where that source is available); each Trellis graph
      reads the sidecar once at construction and declares `residualBasis` through
      `draftTarget`. The old basis JSON the env var pointed at is not on the M4 Pro.
- [ ] The drafter builds its matrix-unit layer for its fixed block width at construction and uses
      the ordinary quantized matmul for context projection; no per-call row switch in `matmulW`.

Exit: acceptance rate on the paired MTP bench unchanged; no env read in `dflash2-source.ts`.

### Phase F: gate and documentation

- [ ] Add the rules from the top of this file to `architecture.test.ts`, each proven on the
      synthetic workspace, with a ratchet table for files that still break them on landing, each
      entry naming the plan item that removes it. Entries F1 found with no owner, now assigned:
      - `execution/batch-group.ts` hot-path reads of `MLX_BUN_BATCH_VEC_SAMPLE` (a sampling-path
        choice: a composition fact, E2) and `MLX_BUN_GRAMMAR_DEBUG` (a diagnostic: add it to the
        development-hook allowlist by name, F1).
      - `models/glm52/model.ts` `instanceof MLACache`: the GLM-5.2 MLA contract item listed under
        B1's out-of-step work owns it; until that item has a number, it rides the ratchet.
      - `models/minicpm5/model.ts` `MLX_BUN_COMPILED_SWIGLU`: D3, where a generic graph's env
        switches become constructor choices.
      - `models/qwen/qwen3_5.ts` `Qwen3MLP.forward` `instanceof TrellisLinear`/`QuantizedLinear`:
        C1, where the MLP block takes its projection type at construction.
      - `state/layout.ts` `prefillCacheLayout` branching on the cache class: B2, where the row
        layout reads the cache's own declaration.
      - `models/qwen/mtp.ts` `makeMask`: D3, the MTP companion reads through `attend`.
      - `packages/training/src/kernels/flash-cce.ts` per-dispatch `runtimeValue`: C2's rule,
        the choice becomes a constructor argument of the training kernel's owner.
- [ ] Each new rule's failure message names the paved road, in the style of the existing
      "scheduling reaches storage through the row-layout port" message.
- [ ] Make the library checks a required status check on `main`, so a PR with a failing gate is
      not mergeable (#312 merged with its checks still pending).
- [ ] Automatic performance-regression check. GitHub's runners have no Apple GPU, so this needs
      a self-hosted runner on a quiet named Mac (the M4 Pro, or the M1 Max over SSH). For a PR
      that touches `kernels/`, `layers/` or `models/`, run the existing paired serve benchmark
      against `main` with the preflight gate, and fail on a regression outside the paired noise
      band. Unqualified numbers never gate; the check reports the paired delta and its interval.
- [ ] Agent briefs for this plan point at the generator and the contract, never at an example
      file to copy; copying the nearest example is how the M4 Pro graph inherited the fallback.
- [ ] ARCHITECTURE.md: the cache owns the read; phases are named; a specialized graph extends
      nothing; the exemplar sentence points at the regenerated graphs; the loader-level generic
      fallback is stated and the in-graph one forbidden; the one-way-per-pattern list above.
- [ ] PLAN.md: first decision updated per the off-composition decision; this file's closed phases
      deleted.
- [ ] `packages/inference/README.md`: the M4 Pro graph paragraph describes phases, not plans.

Exit: `bun test packages/inference/tests/architecture.test.ts` passes with the ratchet table
empty; documentation generators run clean.

### Verification, every phase

- Kernels and their order do not change in any step, so each graph and cache step is gated by
  bit-identical logits per phase against the implementation it replaces, on the existing parity
  inputs. Folded attention and ANE keep their KL gates.
- `bun run typecheck`, `bun run test`, and the architecture gate on every PR.
- Speed only through `mlx-bun serve` in the batched lane with the paired benchmarks, ms per round
  for MTP, on a quiet named machine.
- One PR per numbered item, targeting `main`, not merged without Josh's instruction.

### Untouched

The 13 single-purpose kernels from PR #312, the four one-kernel layers, the ANE native bridge,
the DFlash 2 numerics, the bench scripts, modules, web, training.

## Verify the migrated library

- [ ] Establish real-weight parity for Qwen Trellis and Gemma, and extend MiniCPM
  beyond the [verified basic decode path](packages/inference/README.md#external-parity-evidence),
  against the applicable external oracle and main: logits, state continuation and
  specialized paths under identical artifacts and settings. Python environments and
  generated references stay outside the repository; reusable runners are in Git
  ([runtime comparison](packages/inference/README.md#repeatable-runtime-comparison)).
  Exit: opt-in comparisons meet the numerical contracts against pinned published
  golden revisions recording source revisions and oracle versions; synthetic tests
  alone do not close this. Done so far: the
  [generated Gemma4 graph test](packages/inference/tests/parity/gemma4-generated.test.ts)
  passed on e4b and 12B (identity within this tree; 26B-A4B not run). Packed Trellis now matches main in 96 full greedy logit vectors, three shared
  B1/depth-two MTP runs, and the 18-case plain-KV runtime grid with restored
  continuation ([evidence](packages/inference/README.md#packed-qwen-trellis-parity)).
  Open: published references and broader Trellis shapes;
  [runtime-oracle](packages/inference/tests/parity/runtime-oracle.test.ts) references
  for Gemma and extended MiniCPM (MiniCPM mixed KV waits on the next item);
  real Gemma2 B2 rows and a different prefill chunk geometry differ from main's B1 in
  logits and valid KV, which needs same-shaped oracle or main comparisons, not a tolerance.
- [ ] Extend speech and embedding evidence. Whisper large-v3-turbo, Silero VAD and
  Qwen3-Embedding-4B-4bit-DWQ match the external oracle and main bit for bit (Whisper fast
  path within main's two-token bound; VAD within 5e-3 of torch) on the
  [opt-in comparisons](packages/inference/README.md#speech-and-embedding-parity). Open: other
  Whisper sizes and non-WAV input, other embedding checkpoints, batched embedding, and
  performance. GLM-5.2 (declared L1) has no local weights and no current numerics evidence, so
  its graph, streamed experts and MTP are unverified against the oracle or main.
- [ ] Confirm the long-term mixed-KV reference contract for single-query decode:
  the documented stock mlx-lm path or OptiQ serve's fused default. The opt-in
  state comparison verifies the existing composition; keep that implementation
  unchanged during this refactor and do not imply blanket OptiQ serve compatibility.
- [ ] Extend training preservation. MiniCPM5 SFT, ORPO and DPO match main exactly
  through the app's [fine-tune preservation test](apps/mlx-bun/tests/engine/finetune-preservation.test.ts),
  as do short Gemma4 e4b SFT pairs and Qwen3.5-0.8B SFT with one LoRA layer (main trains
  Qwen3.5 only when no DeltaNet layer is on the gradient path; here the DeltaNet recurrence
  has a backward, so more layers, DPO and batches train with no main reference);
  DiffusionGemma save, reload and seeded
  generation and its HTTP adapter serving are consistent within this tree (not parity).
  Open: other model families and main-only paths (by_bits/by_kl, warm start); synthetic
  native tests do not close this.

## Improvements identified during migration

Concrete improvements with the current limitation and the owning domain. Preserve
shipped behavior first; an improvement is not permission to redesign during migration.
Migration gaps stay required work in the feature table.

- [ ] (audio) `transcribe --vad-trim` is accepted but not applied, as in main, though the
  service implements `vad.trim`.
- [ ] (memory) The entity seed gold is personal data read from a repository path; seed from
  the vault's aliases (`EntityResolver.fromStore`) and drop the file.
- [ ] (memory) `--since` and `--model` are parsed and never consumed (main reserved them
  too); consuming them is a decision.
- [ ] (isolation) The worker's `/health` reports only `ready`/`draining` because the socket
  binds after the model loads; a pre-bind stub would let the parent observe `loading`.
- [ ] (isolation) Pi's SDK retries a 502 refused before generation (three attempts, 2/4/8 s)
  without a browser frame; mapping `auto_retry_start` to a frame would show the wait.
- [ ] (isolation) The worker keeps its own bounded Responses store for requests the parent
  already records; honoring `x-mlx-bun-response-owner: parent` would skip the duplicate.
- [ ] (isolation) The parent's `/health` answers 200 while the engine is exhausted; a distinct
  status for load balancers is a policy decision.
- [ ] (capability reporting) `/v1/models` reports DiffusionGemma with `vision: false` (as main)
  though image requests succeed.

## Split the app into modules

- [ ] Split `apps/mlx-bun` into modules on core services, as the repository split into apps and
  libraries (design: [Modular application](ARCHITECTURE.md#modular-application); contracts:
  `packages/app-core`). Modules: transcription, chat, models, train, quantize, datasets, memory,
  benchmarks (answer quality, `scripts/eval-serve.ts`), metrics and performance (live tokens/s, TTFT,
  batch occupancy, queue, KV/prefix usage and hit rate, memory per loaded model, swap and load
  times; launching `bench-serve` profiles with history). An agentic workflow engine is a later module,
  not planned here. Every step keeps existing paths, verbs and behavior: moved tests keep their
  expectations, and steps that move an execution path rerun real weights before and after.
  - [ ] (d) Memory module migration under validation (moved as is; the memory feature stays deferred).
    Datasets, quantize, benchmarks, train, models and chat landed. Datasets', quantize's and train's
    browser pages are still legacy pages that become panels the web shell mounts. Memory reaches chat
    through `registry` (`chat.tool`, `chat.guidance`); its panel owns the memory entry, consent card and
    provenance chips, wired through the chat panel's `host`. The chat panel owns its markdown
    renderer, hold-to-talk mic (calling transcription over HTTP), and the assistant's app catalog, which
    should come from contributions once the shell lists them. Models owns hub, library, cleanup, adapter
    administration and its panel; chat owns selection of adapters for a turn. Exit per module: its domain
    leaves `apps/mlx-bun/src`, its browser page becomes its panel, the app domain map shrinks, and
    served-surface inventories are unchanged.
  - [ ] (e) Model host events reach every consumer. Residency, live switching, saved state and the model router landed
    (`serve` runs one isolated worker per resident model by default, held by memory fit in the parent; `--in-process`
    loads them in the serving process; the two share one residency manager), the host publishes `model.load` (with
    `resumed` when saved state was found), `model.unload` (reason `evicted`, flushed) and `model.memory`, and each worker's
    own events are relayed onto the parent's bus. The in-process composition now shares one `modelHost` across
    persistent and model-scoped modules for `generate`, `adapters` and the borrowed Whisper `transcribe` operation.
    Isolated HTTP voice discovery and idle unloading preserve the configured companion's identity and policy.
    Remaining: the isolated parent's typed module host also leases `transcribe` from its companion worker.
    Exit: a module acquires
    `generate` and `transcribe` from one service (the models module already leases `adapters` and switches the served model through the state's host).

## Remaining features by layer

One row per feature, one column per layer it crosses. A feature closes only when every cell is
done or a decision marks it dropped; delete the row then. Cells: `done` · `partial` · `missing` ·
`501` (route stubbed) · `n/a` · `held`. Evidence means an opt-in real-weight test that passes against
a pinned published golden or regenerates it; synthetic tests never fill it. This repository carries
code, tests and documentation; goldens, records and benchmark data are published datasets, and
experiments and benchmarks live outside it. Package READMEs hold the evidence detail; keep cells short.

| Feature | Library | Engine / host | Server | CLI | Web | Evidence | Open work or decision |
|---|---|---|---|---|---|---|---|
| Audio: Whisper transcription, Gemma4 audio input, voice sessions | done | done (lazy Whisper companion, exclusive-lock takes) | done (`/v1/audio/*`, `/admin/transcription/unload`, served by `@mlx-bun/module-transcription`) | done (`transcribe`, `dictate` from the module; `--whisper-*` on serve; `apps/transcribe` hosts the module alone) | done (hold-to-talk composer dictation; no upload or translate controls, as main) | partial: Whisper large-v3-turbo and Silero VAD match the external oracle and main ([speech parity](packages/inference/README.md#speech-and-embedding-parity)); Gemma4 e4b audio-only HTTP (B1/B2) matches main; real-weight voice, companion and mixed-media consumers pass; [details](packages/module-transcription/README.md#audio-transcription) | Open: physical-microphone `dictate` (mic, key tap, clipboard, typing); Gemma4 audio with KV quantization and other variants; main parity for mixed image+audio and e2b (app-behavior runs only); Gemma4 audio external-oracle parity; other Whisper checkpoints; performance |
| Memory synthesis (nightly pipeline) | n/a (app-owned; pipeline ported op-for-op) | done (task model on the continuous gateway under the engine's execution lease; isolated: the current worker's `/admin/memory/complete`) | done (`GET /v1/memory/synthesize`, `schedule` in `/api/memory/status`) | done (`memory` verbs incl. `init`/`setup`, `schedule`) | read panel done; no synthesize control (as main) | partial: stages match main token for token and in full logits, width-3 batch, isolated synthesis; [details](apps/mlx-bun/README.md#memory-synthesis) | Decision: the memory feature is incomplete and deferred; the ingest source is unchanged (Pi's global sessions directory, as main) |
| Live model switching, residency, isolation | n/a | done (one crash-isolated worker per resident model by default, held by the parent by memory fit; `--in-process` loads them in the serving process; either way the LRU model is drained with its saved state) | done (`POST /api/hub/serve`, routing by request `model`, `/v1/models` and `/library` with residency; worker socket: `/health`, `/admin/lease`, `/admin/drain`, `/admin/memory/complete`, `/admin/events`, `/admin/adapters`; isolated parent: `/engine`, `/health`, `/stats`) | done (`--model-budget`, `--ssd-cache`, `--in-process`; `--isolate` is accepted and ignored) | the Models panel switches live | partial: two small models resident and serving concurrently, a swap through saved state that resumes the prior conversation, and a pinned Whisper, in the default isolated mode and with `--in-process` (Qwen2.5-0.5B, MiniCPM5-1B, Whisper large-v3-turbo), and a worker killed mid-request answers 502 and reloads and resumes; no oracle parity; [details](apps/mlx-bun/README.md#model-host-residency-by-memory-fit) | Decisions (Josh): residency is by memory fit, saved state makes a swap feel like two models running, isolation is the default (one worker per resident model; `--in-process` opts out), and web chat works under isolation. Internal worker routes on TCP (`/admin/lease`, `/admin/drain`, `/admin/memory/complete`, `/admin/events`, `/admin/adapters`) and `/engine` under `--in-process` answer 404, not 501. Small items: Improvements |
| Speculative decoding: draft models, n-gram, MTP, DSpark/DFlash | done | partial (grouped draft required; ungrouped shapes get the typed error) | rides completions | done (`--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-*`, `--mtp`; `draft regen|train|calibrate|quantize` produce drafters) | n/a | partial: B1 main preservation for n-gram (MiniCPM), Gemma4 two-model and Qwen3.8 Trellis MTP; [grouped consumer](packages/inference/README.md#speculative-generation) ran for n-gram, two-model and assistant | Open: the grouped consumer for MTP, DSpark, DeepSpec (no local drafts fit 32 GB) and GLM-5.2 native MTP (no local weights); other main-supported provider/target/cache combinations; equality with main or an oracle; HTTP; performance |
| Paged KV | done | partial (Gemma4 only; others get the typed error; media and adapter rows bypass paging) | rides completions | done (`--paged-kv`, `--paged-kv-block-size`) | n/a | done for Gemma4 E4B/12B: gathered pages equal plain KV bit for bit, direct reader within tolerance, KV4/KV8 pages, HTTP cancellation per reader, cold prefill; [details](packages/inference/README.md#state-and-attention) | Open: warm-prefix (prompt cache on) identity over HTTP (main's `paged-cache-http` test is not ported); broader model support is the cache lego in the Composition refactor (B1) |
| Unsupported request shapes (typed error) | done | typed `UnsupportedExecutionError` per shape | typed 501 envelope | `generate` prints it, exit 1 | n/a | per shape once supported | Shapes become compositions under the Composition refactor (Phase E); the typed error stays for a request the composition was not built for |
| DiffusionGemma denoising (shared execution) | done (interleaved rows, B=1 graph calls) | done (placed continuously; grammar, draft, logprobs, logits processors, fill, encoded and paged KV refused with typed reasons) | rides completions | rides `generate` | n/a | partial: text and one-image requests match main's measured trajectories (direct, grouped, B2/B4 join and cancel, HTTP), image cancellation and disconnect recovery pass; [details](packages/inference/README.md#optional-execution-and-persistence) | Open: stacked (B>1) canvases and token-chunked prefill (separate optimizations); concurrent HTTP rows, full logits and KV planes, external-oracle parity, performance. Main's `goldens/diffusion/gen*.json` no longer match main on MLX 0.32.2, so references are measured |
| Evaluation and benchmarking: `bench`, `evals`, `perplexity`, EvalDB, eval tasks | n/a (experiments; the in-package bench harness moves out) | n/a | `/fit` measured fields stay null | not app verbs | status page shows dashes | n/a | Runs consume the published packages and drive the app through its public HTTP and CLI surface; results are published as datasets or quoted as text in docs. The benchmarks and metrics modules ([split](#split-the-app-into-modules)) launch these runners and show history; they add no second runner |
| Pi terminal: `pi`, `harness pi` | n/a | chat backend reusable | n/a | held (`pi-terminal`, `harness-pi` not ported) | n/a | n/a | Held by Josh |
| Managed jobs: quantize, fine-tune, `convert`, `fuse`, datasets | n/a | done (each job child leads its own process group; stop is SIGTERM then SIGKILL after 3 s; the child stops its group when the parent's stdin pipe closes) | done (job, dataset and adapter routes) | done (`train`, `convert`, `fuse`) | job views done | partial: finished and merged fine-tune adapters mount, unmount and reproduce in a fresh process, and `fuse` output loads and generates (MiniCPM5-1B, opt-in `managed-jobs.test.ts`); [details](apps/mlx-bun/README.md#jobs-quantization-and-fine-tuning) | Decision: a managed job keeps running when its terminal closes (quantize's synchronous sensitivity sweep cannot observe the closed pipe): accepted. Verified on M1 Max: all four managed-job cases (including BF16 sensitivity cancellation and uniform conversion), isolated memory synthesis/cancellation, base memory stages and width-3 batching, and standalone library-host build. The trained memory-chunk adapter case still skips without its artifact. Relocated compiled app, installed current/previous bundles, worker and managed-child reentry passed (`verify:binary`; #295). |
| Existing-user data compatibility: prior-format sessions, jobs, settings, vault, caches; memory Reference symlinks into the main checkout | n/a | partial (Pi sessions, browser preferences and active-job prior schemas read across versions; the web chat sidebar lists every recorded chat; old `~/.cache/mlx-bun*` job history, memory and registry data are left in place, not migrated; adapter stores are listed read-only) | n/a | n/a | n/a | partial: synthetic old/new round trips (Pi sessions, preferences, jobs) and an acceptance on an isolated copy of real data pass (53 sessions, 10 adapters); the credential and schedule paths only synthetically (no saved token or nightly plist in the real data) | Decisions: everything mlx-bun writes by default lives under `MLX_BUN_HOME` (`~/.mlx-bun`); the HF hub cache holds downloads only; explicit paths win (#224); the opt-in `--expert-offload` still builds inside the model directory. Before deleting the old checkout Josh selects what to preserve outside it: the memory Reference symlink targets (7 point into it; 2 already dangle) and ignored adapters, checkpoints and other local artifacts that Git cannot recover. No automatic retargeting. Open: opening a chat appends SDK entries and opening a v1/v2 chat rewrites it, as in main |
| Docs surface and gates | n/a | n/a | HTTP and configuration inventories generated from source | CLI inventory generated from source | site and legacy redirects implemented | `apps/website/tests/server-api.test.ts`, `apps/website/tests/server-config.test.ts` | Per ARCHITECTURE: generate inventories from source as build-only output with a coverage gate, and write the explanations by hand (models, environment, training, memory, distribution, troubleshooting; quotable numbers as text with provenance in a benchmarks page). No STATUS file, docs map, or ledgers are restored. |
| Installation and release | n/a | n/a | n/a | bundle, launchers, safe installer, formula and staged release preparation implemented | n/a | n/a | Complete the release acceptance checks below; public installer delivery must follow a compatible bundle release. Decision: the installer links only `~/.local/bin` (accepted). No actual release. |

## Candidate quant and Hugging Face model card

This work characterizes the first quant published under the `mlx-bun` organization.
Use a validated engine to evaluate the artifact; duplicating quality evaluations
on main and the refactor is only useful when investigating a behavior difference.

- [ ] Audit the completed M4 Pro campaign for reusable scores: exact artifact and
  source revisions, dataset splits, prompts/templates, thinking mode, sampling,
  token budget, answer extraction, scoring and truncations. Retain scores whose
  protocol can be reproduced and accurately named; identify missing evidence.
- [ ] Select established benchmark protocols that support comparison with the base
  model or popular quants. Use the upstream runners, task definitions and scorers;
  record versions and full dataset coverage. Compare matching protocols, including
  thinking mode and generation budget. Label externally reported results and their
  settings; unresolved protocol differences cannot establish relative quant quality.
  Frozen subsets and different MMLU task variants must be named explicitly.
- [ ] Prepare model-card performance numbers from qualified measurements on M4 Pro,
  M1 Max or both. Record machine, engine/build, context, batch, KV configuration,
  cache state and MTP alongside prefill/decode, request latency and memory as measured.
- [ ] Document the quant's creation from the actual manifests: base model revision,
  quantizer revision and commands, rotation/folding, calibration and mixed-precision
  allocation, packing, final size and runtime requirements. Replace the inherited
  base-model card with the candidate's own measured results and reproduction details.
  Exit: the artifact and model card are ready to review and publish under `mlx-bun`.

## Release acceptance

- [ ] With Josh's release instruction, verify real Developer ID signing and
  notarization, including loading the signed native libraries from a relocated
  signed bundle. The native-blocked version check and mocked commands do not
  establish this acceptance.
- [ ] Reproduce the remaining notices of code embedded in prebundled dependencies.
  `babel-plugin-parameter-decorator@1.0.16` in Jiti's prebundle has no license text
  upstream: only its manifest's `"license": "MIT"` and `"author": "Warner"`, its npm
  `gitHead` is not in its repository, and no commit there adds a license file, so a
  full text must come from its author. The toolchain that built XGrammar's WASM is
  unknown (no producers section; a local build): the inference notice reproduces
  Emscripten 3.1.56's texts because the runtime glue is a release-era match for 3.1.56,
  inferred from two fingerprints (WebAssembly-check absence and `Module["ready"]`
  presence), not exact provenance. Whether the stripped WASM links LLVM compiler-rt is
  also unknown; if it does, its notice needs that Emscripten's
  `system/lib/compiler-rt/LICENSE.TXT`.

## Completion

- [ ] Josh could delete the pre-refactor reference branch (`origin/pre-monorepo`, main at `02d723a`) without losing a capability it shipped.
  Exit: every row above is all-done or carries a recorded decision and is deleted;
  the verify items above close against pinned published goldens or are recorded
  decisions; main's user flows (CLI verbs, HTTP protocols, web chat, jobs,
  installed and compiled artifacts, existing user data) are accepted with real
  weights; documentation follows ARCHITECTURE (generated inventories, handwritten
  explanations, no ledgers); no capability main shipped is retired silently.

## Ideas and research

One line per idea: the question and the domains it touches. Picking one up makes it an item
above with an exit; an answered one moves its finding to the owning documentation and is deleted.

- **SkillOpt skill optimization** (chat, memory, a new optimization domain; [research](https://github.com/joshuarossi/mlx-bun/pull/247)):
  can SkillOpt's gated skill-edit loop (Microsoft, MIT, arXiv:2605.23904) improve the default
  assistant's prompt and skills and the memory stages' `Meta` policies with local models as target
  and optimizer, and should the loop run inside mlx-bun? First experiment: a `scripts/` runner using
  SkillOpt's `openai_compatible` backend against `mlx-bun serve` on one verifier-scored task set,
  measuring the optimizer's edit-JSON parse rate and the held-out gain with a 4B–27B optimizer.
