# mlx-bun: gemma4.ts decompose & optimize — action plan

> This is the canonical **design/rationale** for the optimization work.
> Live **status/tracking** (checkboxes, findings) lives in PLAN.md under
> "Optimization plan Phase A–E".

**Premise (confirmed from the source read):** the current engine sits at
parity-to-ahead vs mlx-lm on the 12B *while still interpreting the decode
graph every token through hundreds of `bun:ffi` crossings, uncompiled.* The
largest remaining cost is host-side graph rebuilding that is identical
token-to-token — exactly what `mx.compile` exists to erase. Specialization and
custom kernels are real but smaller, and both are only *measurable* once the
host overhead is gone.

**Therefore the ordering is non-negotiable:** compile first (the big lever),
then decompose + specialize (enables the kernel and cleans the graph), then the
per-config fused kernel (the 2–3× on top). Doing it in any other order means
optimizing against a baseline that compile would have changed anyway.

**Invariant for the entire plan:** the compat-mode bit-exact parity gate
(`toBe(0)` logits, identical greedy trajectories vs the oracle venv) stays green
at *every* checkpoint. It is the instrument that makes refactoring safe to do
fast — any step that changes behavior turns it red the same hour. No step
proceeds with a red gate. No tolerance is ever added to make a refactor pass;
divergence is root-caused, never papered over.

---

## Phase A — Compile the decode step (on the current monolith, before any split)

**Why first:** this is the 14×-class lever for *this* runtime specifically,
because mlx-bun's per-step cost is FFI-crossing-heavy in a way Python's
interpreter loop is not. It is independent of decomposition. Landing it first
means every later phase is measured against a compiled baseline, so you learn
exactly how much headroom specialization actually has left to chase instead of
chasing host overhead that compile already removed.

**Steps:**

1. **Characterize before touching anything.** Run `scripts/decode-split.ts`
   (the per-step wall-time splitter that already exists) on all three models at
   @600 and @8k. Record GPU-blocked time vs JS-graph-build time per step. This
   is the control measurement; everything in Phase A is judged against it. The
   prediction: e4b shows the largest JS-graph-build fraction (it has the
   per-layer-input slicing loop no other model runs).

2. **Wire `mx.compile` around the single-token decode graph.** The unit to
   compile is one `forward(tokens=[next], cache)` step: embed → forwardLayers →
   finalNorm → logitsFromHidden → argmax. At fixed L=1 every op is shape-stable
   token-to-token; only input values and cache offsets change. Use
   `shapeless=True` semantics so the same compiled graph serves any decode step.
   The cache update is the one stateful part — confirm the compiled region
   either includes the sliceUpdate writes or is structured so the cache mutation
   happens at stable shapes (see step 4).

3. **Keep prefill uncompiled (or separately compiled).** Prefill is
   variable-length (L = prompt size), so it does not share a compiled graph with
   decode. Leave prefill on the current path initially; a separate
   fixed-tile-size compiled prefill is a later option, not part of this phase.

4. **Resolve the cache-mutation/compile boundary.** The quantized caches do
   `quantize → sliceUpdate(ring) → activeSlices` per step (≈670 FFI crossings
   per token on the 12B across 48 layers). Decide whether these live inside the
   compiled graph (preferred — collapses the crossings into one replay) or
   immediately outside it. The ring-index bookkeeping is host-side integer math
   and stays in JS; only the array ops compile.

5. **Parity gate.** Compiled decode must produce bit-exact identical token
   trajectories to the uncompiled path on the fixed prompt suite. Compile must
   not change numerics — if it does, a fusion inside the compiled graph reordered
   an op; root-cause it.

6. **Measure.** Re-run `decode-split.ts`. Expected: JS-graph-build fraction
   collapses, e4b ~5% residual shrinks or closes, 12B short-context moves
   further ahead. Record the delta — this number tells you how much the rest of
   the plan is even worth.

7. **Re-run the fused-decode A/B *after* compile, not before.**
   `MLX_BUN_FUSED_DECODE` measured ~3% *worse* uncompiled, almost certainly
   because the tile loop's per-iteration host overhead dominates at L=1. Compiled,
   that host cost vanishes and the flag may flip to a win with no kernel written.
   This is a free re-measurement that may close part of the gap on its own.

**Phase A exit:** compiled decode green on parity, measured speedup recorded per
model, fused-decode A/B re-evaluated. Decision point: how much headroom remains?
That answer scopes Phases D–E.

---

## Phase B — Extract a shared, config-independent base

**Why:** before generating per-model files, separate the machinery that is
genuinely identical across all architectures from the parts that vary. This is
mechanical, parity-preserving code movement — no behavior change, gate stays
green throughout.

**Moves into `gemma4-base.ts` (or `src/model/gemma4/base.ts`):**

- Cache classes: `KVCache`, `QuantizedKVCache`, `RotatingKVCache`,
  `RotatingQuantizedKVCache` — these are architecture-independent storage; which
  *combination* a model uses varies, but the classes themselves don't.
- SDPA functions: `quantizedSdpaUnfused`, `quantizedSdpaTiled`,
  `fusedSdpaSupported`, `quantizedSdpa`, plus `ops.sdpa` plain dispatch.
- Mask builders: `createCausalMask`, `bidirMask`, the `Mask`/`MaskMode` types.
- Primitives: `RMSNorm`, `QuantizedLinear`, `QuantizedEmbedding`,
  `QuantizedSwitchLinear` and the LoRA machinery (`LoraWeights`, `LoraState`).
- Helpers: `disposing`, `mapTriple`, `disposeTriple`, `logitSoftcap`,
  `argmaxLastPosition`, `lastPositionLogits`, `FINFO_MIN`.

**Stays model-specific (does NOT move to base):** `Attention`, `MLP`, MoE
(`Router`/`Experts`/`SwitchGLU`), `DecoderLayer`, `Gemma4Model.forwardLayers`,
`computePerLayerInputs` — these branch on architecture and become the
per-model generated code.

**Steps:**

1. Create the base module, move the listed classes verbatim, fix imports.
2. Run the full parity suite + all behavioral tests. Green = the move was
   behavior-preserving. This is the only acceptance criterion for Phase B.
3. No optimization in this phase. Pure extraction. Resist the urge to "improve
   while moving" — that conflates a refactor bug with an optimization bug.

**Phase B exit:** base module extracted, every test green, monolith now contains
only the model-specific assembly that Phase C will generate.

---

## Phase C — Generate three per-architecture files (not author — generate)

**Reframe from the original request:** the per-model files are *outputs of a
generator*, not hand-written variants. Loop unrolling and branch elimination are
mechanical transforms; a codegen script performs them from each model's config.
Three files = three generator outputs. When the base algorithm changes, you
regenerate, not hand-edit three copies.

**The three targets (your actual runnable set):**

- `gemma4-12b.ts` — dense. Full-attention `KVCache` (or quantized variant),
  GQA, no per-layer-input, no MoE, no KV-sharing. The simplest graph.
- `gemma4-e4b.ts` — the complex one. Per-layer-input gating, KV-sharing
  (donor/sharer layers), sliding/rotating quantized cache. This is where the
  per-step host overhead concentrated, so it's where specialization pays most.
- `gemma4-26b.ts` — MoE. Router + experts (`SwitchGLU`/`gather_qmm`), parallel
  dense+routed branches.

**The generator (`scripts/gen-model.ts`):** reads `config.json` +
`kv_config.json` for a model and emits the specialized file. What it eliminates,
all resolvable at generation time from known constants:

- The per-layer `instanceof` cache-type check (gemma4.ts:1327) — each layer's
  cache type is known from `layer_types`, so the generated layer calls the right
  fetch directly, no runtime `instanceof`.
- The `if (this.router)` / `if (perLayerGate)` / KV-sharing forks in
  `DecoderLayer.forward` and `forwardLayers` — each model takes exactly one
  branch; the others are deleted from its file.
- The `forwardLayers` layer loop — unrolled into straight-line per-layer calls
  with each layer's constants (type, cache index, donor index, sliding/full)
  baked in. (Note: post-compile this is largely cosmetic for *speed* — compile
  already erased the per-step cost — but it produces a cleaner compiled graph
  and removes the `intermediates`/`previousKvs`/`cacheIndex` indirection arrays
  and their per-step lookups.)
- The per-layer-input `slice`+`reshape` loop (gemma4.ts:1865) on non-e4b models:
  deleted entirely (they don't have it). On e4b: the slice bounds are constant
  per layer, so they're baked.

**Steps:**

1. Write `gen-model.ts`: input = model dir (config + kv_config), output = one
   `.ts` file importing from `gemma4-base.ts`. Start with the 12B (simplest) to
   prove the generator end-to-end.
2. Generated 12B must pass parity bit-exact against the oracle. This proves the
   generator preserves behavior — the gate is the generator's test.
3. Generate e4b and 26B. Each passes parity. The KV-sharing donor/sharer wiring
   in e4b is the trickiest to generate correctly; its parity test is the proof.
4. Dispatch: model load picks the generated module by config fingerprint
   (arch + kv_config hash), with the **monolithic `gemma4.ts` retained as the
   general fallback** for any model without a generated specialization. Nothing
   is deleted; specialized files are opportunistic overrides.

**Phase C exit:** three generated, branchless, unrolled per-model files, each
bit-exact, dispatched by fingerprint, with the monolith as fallback. Measure
each vs its Phase-A compiled baseline — expect small wins (cleaner graph, fewer
indirection lookups), not large ones. The large one was compile.

---

## Phase D — Per-config kernel specialization (kv_config-driven)

**Why:** now that each model has its own file and the cache/SDPA dispatch is
already branch-free per model, bake the *quantization* constants. The
kv_config.json's per-layer (bits, group_size) becomes compile-time information
in the generated SDPA and cache calls.

**What gets specialized, from the 12B's kv_config as the worked example**
(42 layers @ 4-bit/gs64, 6 layers @ 8-bit/gs64, group_size uniformly 64):

- **Per-layer bit-width resolved at generation, not per-step.** The generated
  layer for index 6 calls the 8-bit SDPA path; index 0 calls the 4-bit path.
  No runtime bit-width parameter, no `fusedSdpaSupported` bit check — the
  generator already knows.
- **group_size folded as a compile-time constant** (64 everywhere in this
  config) — `dim / group_size`, `32 / bits` (elements-per-int) become literals.
- **nRep (GQA ratio) baked** — the `nRep > 1` branch and the `expandDims`
  broadcast become a constant-folded reshape with the literal ratio.
- **head_dim baked** — sliding (256) vs full-attention (512) head dims are known
  per layer.

**Important honesty:** Phase D is specialization of the *existing* op-graph
(constant-folding, branch deletion), still using `ops.quantizedMatmulQT` etc.
It is NOT yet a custom kernel. Expected gain is modest — it removes parameter
passing and branches the compiled graph would partly handle anyway. Its real job
is to make Phase E's custom kernel *possible* by having a single known
(bits, group_size, nRep, head_dim) per dispatch site.

**Steps:**

1. Extend `gen-model.ts` to read kv_config and emit per-layer-specialized SDPA
   dispatch (right bit-width path per layer, constants folded).
2. Parity gate per generated model. Bit-exact required — constant-folding must
   not change numerics.
3. Measure vs Phase C. Record the (likely small) delta. If negligible, that's a
   *finding*, not a failure — it means compile already captured it, and it tells
   you the kernel in Phase E is the only remaining lever.

**Phase D exit:** each generated model has branch-free, constant-folded,
per-layer-specialized quant dispatch. Every dispatch site now has a single known
shape — the precondition for Phase E.

---

## Phase E — Per-config fused decode-SDPA kernel (the 2–3×, last)

**Why last:** this is the custom Metal kernel, the fun part, and it's the
*smallest* lever (the search and the turboquant retro both say the fused kernel
was 2–3× while the buffer/host path was the big win — which you've already
captured in Phases A and D). Doing it last means you measure its true
contribution against a compiled, specialized baseline instead of attributing
host-overhead noise to it.

**What the kernel does** (the mlx-qsdpa shape, specialized per bit-width):

- Decode-time (L=1) fused attention: stream the quantized KV through QK^T and
  ×V in one Metal dispatch, dequantizing inline, **never materializing** the
  `[B,H,1,N]` scores row or the dequantized cache.
- **nRep baked in** — no `expandDims` GQA broadcast (gemma4.ts:916); the kernel
  loops the query-head group internally with the literal ratio.
- **bits/group_size as compile-time template parameters** — generate the 4-bit
  variant and the 8-bit variant; dispatch the right one per layer from the
  config (Phase D already resolved which).
- Online-softmax fused (score → max → exp → ×V accumulate) so the scores never
  hit memory.

**Mechanism:** `mx.fast.metal_kernel` (the intended extension point — no MLX
fork). Lift the *dequant unpacking logic* from a known-correct reference
(mlx-qsdpa is open, `_BaseCache`-compatible, ~200 lines) — the bit-unpacking and
scale/zero-point application is the well-trodden, copyable part. The novel part
is the *fusion boundary* (not writing the intermediate) and the *Bun dispatch*
(every existing impl dispatches from Python; a Bun-dispatched fused quant-SDPA
is genuinely unoccupied territory).

**Correctness regime — this is where the gate model changes:**

- A fused kernel that's faster will **not** be bit-exact with the unfused path
  (online softmax ≠ one-shot softmax in bf16 — this is already documented in the
  tiled path's "tier b" note). So the compat bit-exact gate does NOT apply to
  the kernel output directly.
- Instead: the kernel runs under the **perf-mode flag** and is gated against the
  **frozen ground-truth snapshot** (capture today's compat-mode logits/
  trajectories on the fixed prompt suite *before* starting Phase E — that's the
  quality oracle once bit-exact-vs-optiq no longer applies).
- Perf-mode gate = bounded logit tolerance + token-trajectory agreement above a
  set threshold, *labeled with the measured delta* (e.g. "+X% tok/s, −Y% on the
  eval set"), the way a quant ships with its perplexity hit. "No guarantee of
  identical output" means **bounded and measured**, never unchecked.
- Compat mode (bit-exact, unfused) stays in the codebase permanently as the
  `-O0` reference and differential-testing oracle: when the kernel misbehaves,
  flip to compat, same prompt, and the diff localizes kernel-vs-expectation.

**Steps:**

1. **Freeze the ground-truth snapshot** (compat-mode logits + trajectories,
   fixed prompt suite, all three models) before writing any kernel. This is the
   perf-mode oracle.
2. **Metal capture one decode step** (`mlx_metal_start_capture`) on the
   compiled+specialized 12B to confirm the prize size: is the dequantized-cache
   round-trip still fat after compile, or did fusion upstream already thin it?
   If thin, the kernel ceiling is low — record and decide. If fat, proceed.
3. **Toolchain derisk first:** get a trivial `mx.fast.metal_kernel` compiling,
   dispatched from Bun, running, verified — *before* the GQA numerics. (RMSNorm
   or a no-op fusion proves the `.metal` → mlx-c → `bun:ffi` pipeline end-to-end
   so the real kernel debugs numerics OR plumbing, not both at once.)
4. **Generate the 4-bit fused decode kernel** for the 42 four-bit layers (where
   42/48 of KV traffic lives and 4-bit's dequant round-trip is most lopsided
   against compute). nRep, group_size baked.
5. **A/B vs compiled+specialized baseline**, paired, clean machine, at @8k (where
   KV traffic dominates and fusion shows). Isolate the kernel's contribution.
6. **Decide on the 8-bit six.** 8-bit dequant is cheaper and the data fatter, so
   the fusion win per-byte is smaller — possibly not worth a second kernel; stock
   MLX path may stay for those layers. Measure before committing kernel #2.
7. **Per-model:** repeat the generation for e4b and 26B configs only if the 12B
   kernel shows a real win. The generator (Phase C/D) already produces the
   dispatch; the kernel is one more generated, per-bit-width artifact keyed by
   fingerprint, each with its own auto-generated parity/quality test.

**Phase E exit:** per-config fused decode kernel(s), perf-mode flag, gated
against the frozen quality oracle with the trade *labeled*, compat mode retained
as permanent reference. Measured isolated contribution recorded.

---

## Cross-cutting discipline (applies to every phase)

- **Parity gate green at every checkpoint.** Compat bit-exact for Phases A–D;
  frozen-snapshot quality tolerance for Phase E's perf mode. Never add a
  tolerance to make a refactor pass — root-cause divergence.
- **One flag, one measurement per lever.** Compile, fused-decode, each
  specialization, the kernel — each is independently togglable and independently
  measured ("run it both ways, compare"), so you always know what each bought.
  Never measure two new levers tangled together.
- **Clean machine or it didn't happen.** Reboot + preflight-gate every quotable
  benchmark; `sudo purge` for cold-start rows.
- **Losing experiments become documented default-off flags, never deletions.**
- **Nothing deleted, fallback always present.** The monolith stays as the
  general fallback; specialized/generated files are opportunistic overrides
  dispatched by config fingerprint. An unhandled config runs slow, never broken.
- **Generator over hand-edits.** Per-model files are regenerated from config,
  not maintained by hand. A base-algorithm fix is one regeneration, not three
  edits. Each generated artifact ships with its generated parity test.

## Expected outcome, honestly stated

- **Phase A (compile):** the big win. Likely closes the e4b ~5% residual and
  pushes the 12B further ahead. This is the lever that matters most and it's
  pure host-side — no kernel, no Metal.
- **Phases C–D (decompose + specialize):** small wins (cleaner graph, deleted
  branches/indirection), main value is enabling Phase E and improving
  maintainability via codegen.
- **Phase E (kernel):** the 2–3× on the attention hot path, biggest at long
  context, smallest lever of the three but the one with no upstream Bun-dispatched
  equivalent — the genuinely novel contribution.

The sequence front-loads the largest, cheapest win (compile) and ends with the
most fun, most novel, smallest one (kernel), with every step gated by the oracle
that's kept the project honest from the start.
