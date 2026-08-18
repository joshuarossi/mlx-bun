# IndexShare / IndexCache performance spike

**Date:** 2026-08-16
**Status:** accepted research spike; paper/code audit complete; implementation and
full-model measurement not started
**Target:** GLM-5.2 DSA on the M1 Max 32 GB Colibri path

## Recommendation

Run the spike, but do not treat it as a new model feature. The GLM-5.2 path
already implements the checkpoint's cross-layer IndexShare schedule: retained
`full` layers run the DSA indexer and intervening `shared` layers reuse the most
recent selection. The useful work is to make that correctness path production
shaped, prove long-context parity, and measure whether the saved indexer work is
visible behind expert I/O on Apple Silicon.

The first prerequisite is the exact stock indexer overlay. The pinned public
Colibri artifact has no `out-idx-*` files, so every full-model result recorded
to date is DSA-off. The second prerequisite is a scalable indexer path: current
code materializes a large `[heads, context, head_dim]` product, copies every
score to the host, sorts the full score vector in JavaScript, and supports
sparse DSA only for single-token decode. Those choices are good correctness
scaffolding but cannot test the paper's long-prefill result.

This spike must not change the trained `full`/`shared` pattern or expose it as a
normal user knob. GLM-5.2 ships IndexShare as checkpoint architecture, not as an
optional quality/performance preset.

## Naming and source claims

The linked paper calls the method **IndexCache**. The GLM-5.2 model card calls
the deployed architecture **IndexShare**. They use the same core mechanism:
cache the top-k positions produced by a retained DSA indexer and reuse them in
subsequent shared layers.

Primary sources:

- [IndexCache paper, arXiv:2603.12201v1](https://arxiv.org/abs/2603.12201v1)
- [authors' SGLang/vLLM reference patches](https://github.com/THUDM/IndexCache)
- [pinned GLM-5.2 model card](https://huggingface.co/zai-org/GLM-5.2/blob/f6142f127a14b58dc602592e996cd7d8ff139351/README.md)
- [pinned GLM-5.2 configuration](https://huggingface.co/zai-org/GLM-5.2/blob/f6142f127a14b58dc602592e996cd7d8ff139351/config.json)

The sources establish three different claims that must not be blended:

| Claim | Published evidence | What mlx-bun may say before local measurement |
|---|---|---|
| Cross-layer reuse | F layers compute top-k; S layers reuse the nearest preceding F layer | Implemented semantics, once parity is gated |
| IndexCache speed | On a 30B DSA model on an 8x H100 node, 1/4 retention reached up to 1.82x prefill and 1.48x per-request decode at 200K context | Paper result only; not a Mac prediction |
| GLM-5.2 IndexShare | The model card says one retained indexer per four sparse-attention layers reduces per-token FLOPs by 2.9x at 1M context | Vendor FLOP claim only; not end-to-end speed |

The paper also reports that uniform 1/4 retention hurts a frozen 30B model's
long-context average (50.2 to 43.0), while a loss-searched pattern recovers it
to 49.9. Training-aware IndexCache makes uniform interleaving viable. Therefore
mlx-bun must preserve GLM-5.2's trained schedule rather than search a new one
during this spike.

## GLM-5.2 schedule

The pinned GLM-5.2 config has 78 layers, `index_topk=2048`,
`index_topk_freq=4`, and `index_skip_topk_offset=3`. Its explicit schedule has
21 full and 57 shared layers:

```text
FFFSSSFSSSFSSSF...FSSS
```

Relative to an all-full counterfactual, the checkpoint omits 57/78 = 73.1% of
layer indexer invocations. It does not ship the missing shared-layer indexer
weights, so a true same-checkpoint `IndexShare off` A/B is impossible. Any
estimated all-full number must be labeled a component counterfactual, not an
end-to-end model benchmark.

`index_share_for_mtp_iteration` is a second, orthogonal optimization: reuse
indices across speculative draft iterations. mlx-bun parses that field but does
not currently consume it in the MTP runtime. Keep its measurement separate so
cross-layer IndexShare and MTP-iteration sharing each receive an attributable
result.

## Current mlx-bun state

Already present:

- [`src/model/glm52-config.ts`](../../src/model/glm52-config.ts) parses explicit
  `indexer_types` and the frequency/offset fallback.
- [`src/model/glm52.ts`](../../src/model/glm52.ts) constructs DSA indexers only
  for full layers and passes one request-local selection state through the
  decoder stack.
- [`src/model/glm52-dsa.ts`](../../src/model/glm52-dsa.ts) records a full
  layer's exact dense/sparse selection and serves it to shared layers.
- [`tests/glm52-config-container.test.ts`](../../tests/glm52-config-container.test.ts)
  and [`tests/glm52-dsa.test.ts`](../../tests/glm52-dsa.test.ts) cover schedule
  parsing, missing-owner refusal, context consistency, and exact reuse.

Known blockers and likely bottlenecks:

1. **No production DSA overlay.** The public Colibri artifact deliberately
   disables DSA because every full-layer indexer tensor is absent. Producing the
   exact overlay requires selective reads from 20 pinned source shards (about
   99.90 GiB input, about 197 MB output). This is a Josh-run acquisition step,
   not an agent-session download.
2. **No sparse long prefill.** `Glm52DsaIndexer.projectAndSelect()` rejects a
   multi-token prefill once context exceeds `index_topk`. The paper's prefill
   headline is therefore out of scope until chunked/sparse DSA prefill exists.
3. **Quadratic transient shape.** `glm52DsaScoresMlx()` forms the broadcast
   product before reduction. At production geometry this scales as
   `32 * context * 128` float elements rather than streaming/tiled score
   accumulation.
4. **GPU-to-host top-k.** The full score vector crosses to a `Float32Array`,
   then `selectDsaThresholdTiesF32()` clones and sorts all positions. This is
   `O(context log context)` host work in each full layer, unlike the production
   GPU top-k assumed by the paper.
5. **Shared-index copies.** Shared layers clone the 2,048-element JavaScript
   positions list, and absorbed MLA uploads it again before each gather. The
   paper's temporary index tensor is reused in place. Measure this separately;
   remove copies only after ownership and asynchronous lifetime are gated.
6. **The current short-context bottleneck is elsewhere.** At 128 tokens the
   full model is limited by streamed expert delivery, and DSA cannot prune a
   prefix smaller than 2,048. No short-context speedup should be expected.

## Hypotheses

- **H1 - component cost:** at the longest context that fits the 32 GB contract,
  retained-indexer time is material and grows roughly linearly per decode token
  with context length.
- **H2 - sharing value:** avoiding 57 of 78 indexer invocations removes a
  measurable amount of counterfactual work even after a tiled score/top-k
  kernel is used.
- **H3 - product value:** DSA plus the shipped IndexShare schedule improves
  end-to-end long-context decode over DSA-off full attention, without token
  drift from the official DSA runtime. This comparison measures the combined
  sparse-attention product, not IndexShare in isolation.
- **H4 - MTP interaction:** any win remains a win with native MTP enabled. A
  decode-only win that disappears under the product MTP path is not a default
  performance claim.

## Bounded experiment

### Stage 0 - artifact and parity gate

1. Generate the immutable `out-idx-*` overlay from the pinned
   `zai-org/GLM-5.2-FP8` revision. Record source revision, selected shard list,
   tensor inventory, byte count, and SHA-256 values. Do not mutate the 357 GiB
   serving snapshot.
2. Header-validate exactly the 21 full-layer indexers required by the shipped
   schedule and prove that shared-layer indexers are neither required nor
   silently loaded.
3. Add an official-runtime oracle at contexts above 2,048. Gate selected
   positions, logits on tie-free rows, and greedy token IDs before taking any
   performance number.

#### Stage 0 result — pass (2026-08-17)

The stock overlay was generated outside mlx-bun from
`zai-org/GLM-5.2-FP8@ba978f7d347eaf65d22f1a86833408afdb953541`
with `colibri@ecade075cfc2eae684097ea7de5570c3786ce199`. It contains 20
`out-idx-*` files totaling 197,202,400 bytes. The existing header validator
finds 118,646 tensors, 59,066 quantized tensors, 19,456 routed experts,
complete DSA and MTP families, all 21 required full-layer indexers, and no
shared-layer indexer requirement.

The first-sparse gate prefills exactly 2,048 deterministic tokens, then sends
one greedy token at context 2,049 with MTP off. The mlx-bun probe observes the
21 configured full layers and exactly 2,048 selected positions per layer. A
detached pinned Colibri build captures each official score row, selection,
float32 logit vector, and token trajectory. Replaying the captured scores with
`Glm52DsaSelectionState` gives:

- 21/21 exact ordered position vectors;
- 21/21 exact float32 thresholds;
- 21/21 tie-free boundaries, minimum boundary gap 0.025123596;
- exact greedy trajectory `[264, 264]` and the same sparse-step top-1 token;
- 154,880-logit cosine 0.997645, RMSE 0.200109, maximum absolute drift
  0.947218, with wide top-1 margins in both runtimes (9.571914 / 9.567580).

The direct full-runtime selections are 10/21 ordered-exact and 14/21
set-exact. Each of the seven set differences swaps only the single excluded
position at this top-2,048-of-2,049 boundary. This is upstream numerical drift
from the runtimes' different quantized-matmul accumulation before DSA, not a
selector mismatch; replaying identical official scores proves the isolated
DSA threshold/tie contract exactly. No performance claim is made from either
correctness run.

Reproduction is split between
`scripts/probe-colibri-glm52-dsa-long.ts` and
`scripts/check-colibri-glm52-dsa-long.ts`. The raw capture, external Colibri
instrumentation patch, and SHA-256 inventory are machine-local at
`~/.cache/mlx-bun/evidence/glm52-dsa-stage0-2026-08-17/`; manifest SHA-256 is
`6ecb88d944b055146dd700a1714af97b61845d4218527282fcbea009663fe3b4`.

### Stage 1 - production-shaped indexer kernel

Build a model-free benchmark at exact geometry (`32` heads, head dimension
`128`, top-k `2048`) for contexts `2,048`, `8,192`, and `32,768`:

- tiled score accumulation that never materializes `[H,L,D]`;
- on-device/native deterministic top-k with the current threshold and
  lower-position tie contract;
- one compact index buffer retained across F -> S layers;
- direct gather consumption without a score-vector host copy or per-shared-
  layer index re-upload.

Compare the candidate against the existing reference composition for exact
selected positions on random, tied, all-equal, and production-captured rows.
Record kernel time, synchronization time, peak MLX allocation, process
footprint, and bytes copied to/from the host. Negative results count.

#### Stage 1 result — pass (2026-08-17)

The production path now computes `[H,D] @ [D,L] -> [H,L]` and never forms the
old `[H,L,D]` broadcast product. Deterministic device selection encodes the
lexicographic `(score descending, position ascending)` rank into `uint64`, uses
MLX `argpartition`, and then restores Colibri's observable two-scan ordering
(strictly above threshold first, threshold ties second). A FULL layer retains
only the resulting 2,048-entry, 8 KiB index buffer; SHARED layers borrow that
same device array and MLA gathers from it directly. Normal inference performs
no score/index host readback or per-SHARED-layer upload. The probe observer is
the explicit diagnostic exception.

Correctness gates pass for deterministic random rows, threshold ties,
all-equal rows, the exact 2,049/2,048 boundary, borrowed MLA consumption, and
all 21 production-captured Colibri score rows. The latter reproduce exact
ordered positions and float32 thresholds on device. A fresh full-model run
also reproduced all 21 prior mlx-bun position vectors and both greedy tokens;
its complete 154,880-float decode-logit payload is byte-identical (SHA-256
`d1f62be2de4877d2fc8ae8feab88e522958210252b50ef96eb786cb22581ba18`).
Tiled accumulation moved nine diagnostic thresholds by at most
`3.0517578125e-5`, but no selection boundary moved.

The exact-geometry, warm synchronized component benchmark (seven repeats) is:

| Context | Production behavior | Score median | Score + top-k median | Timed host copies | MLX peak |
|---:|---|---:|---:|---:|---:|
| 2,048 | dense boundary; production skips score/top-k | 0.448 ms (diagnostic only) | — | 0 B | 1.27 MiB |
| 8,192 | sparse | 0.473 ms | 0.929 ms | 0 B | 5.41 MiB |
| 32,768 | sparse | 0.748 ms | 1.269 ms | 0 B | 21.35 MiB |

At those contexts the removed broadcast product would have been 32, 128, and
512 MiB respectively; the tiled dot output is 0.25, 1, and 4 MiB. These are
model-free component measurements, not end-to-end inference claims. The
benchmark is `scripts/bench-glm52-dsa-indexer.ts`. Machine-local evidence is
under `~/.cache/mlx-bun/evidence/glm52-dsa-stage1-2026-08-17/`; manifest
SHA-256 is
`600ec92c41d4c66735e1834a678a09f2ae55ecdddfab31c3dd1bf31ee9709fef`.

### Stage 2 - decode matrix

Use direct library inference, not a server. Run separate fresh processes and
the standard quiet-machine preflight.

| Axis | Cells |
|---|---|
| Context | 2,048; 8,192; 32,768; 64K only if the exact planner remains inside the 25 GiB process ceiling |
| DSA | off/full attention; on with the checkpoint's 21F/57S schedule |
| MTP | off to isolate DSA; on for the product decision |
| Residency | the same fixed expert policy and seed profile in every paired arm |
| Repeats | three fresh processes per default-eligible cell; cold and warm turn in each process |

For each turn record TTFT, prefill wall time, decode tok/s, total wall time,
DSA projection/score/top-k/gather time, MLA time, expert disk service/wait,
target forwards, MTP acceptance, physical footprint, compression, swap, and
exact token IDs.

The DSA-off versus DSA-on result combines sparse core attention with
IndexShare. To estimate IndexShare's isolated contribution, report the measured
retained-indexer total and a clearly labeled all-full component counterfactual
derived from the same per-layer exact-geometry benchmark. Do not present that
counterfactual as a runnable checkpoint.

#### Stage 2 result — pass, negative product-performance decision (2026-08-17)

The fresh-process runner planned 36 cells. Twenty-four were eligible under the
G5 25 GiB process ceiling and completed: contexts 2,048 and 8,192, four DSA/MTP
arms, and three repeats. Every process ran cold and warm turns. Cold/warm,
cross-repeat, and MTP-off/on greedy token vectors were exact; all emitted
sixteen token IDs equal to `264`. The twelve 32K combinations were not run:
the exact planner reports 29,334,150,784 bytes (27.320 GiB) MTP-off and
30,644,281,216 bytes (28.540 GiB) MTP-on, both above the unchanged 25 GiB
process limit. The initial refusal is retained in the evidence as an attempt
record. This is contract ineligibility, not an allocation crash.

Long prompts use an explicitly bounded benchmark seam: dense batched prompt
construction ends at the exact prompt boundary, and every subsequent decode or
MTP verification row uses exact DSA. These numbers characterize decode and
whole-turn wall time only. They are not sparse-prefill measurements.

Warm medians across three fresh processes are:

| Context | DSA | MTP | Decode tok/s | Total wall |
|---:|---|---|---:|---:|
| 2,048 | off | off | 0.1363 | 260.9 s |
| 2,048 | on | off | 0.1318 | 271.5 s |
| 2,048 | off | on | 0.1312 | 281.7 s |
| 2,048 | on | on | 0.0880 | 338.7 s |
| 8,192 | off | off | 0.1292 | 722.1 s |
| 8,192 | on | off | 0.1420 | 711.8 s |
| 8,192 | off | on | 0.1587 | 711.8 s |
| 8,192 | on | on | 0.1042 | 770.1 s |

At 8K without MTP, the paired median DSA delta is +12.38% decode throughput
and -1.89% total wall time. Expert I/O and prompt work hide most of the decode
gain, leaving the whole-turn result below the required 5%. With MTP enabled,
the paired median delta reverses to -34.33% decode throughput and +8.19% total
wall time. The exact MTP trace explains part of the product result: DSA-off
accepted ten drafts in five rounds (3.2 tokens/target forward, six target
calls), whereas DSA-on accepted eight drafts in seven rounds (2.286
tokens/target forward, eight target calls). Small verify batches now keep
residual/MLP/expert work batched, but exact causal sparse attention still runs
per verification row. Two of the three 8K DSA+MTP cells observed net swap
growth, so the memory side of the win gate also does not close.

The immutable external overlay retains 197,202,400 bytes of indexers. As a
clearly labeled non-runnable component counterfactual, Stage 1's 8K
score+top-k median implies 19.51 ms for the shipped 21 FULL layers versus
72.48 ms for hypothetical 78 FULL layers, so IndexShare avoids about 52.97 ms
of selection work per target row. At 32K the corresponding component-only
figures are 26.64 ms, 98.95 ms, and 72.31 ms avoided. The checkpoint lacks the
57 missing indexers, and these sums exclude the rest of model execution.

The product decision is negative: retain the exact 21F/57S implementation as
model semantics and land its correctness/scalability work, but make no local
end-to-end speed claim. Decode is conclusive, so Stage 3 remains a separate
deferred prefill experiment rather than a G6R exit requirement. Evidence is
under `~/.cache/mlx-bun/evidence/glm52-dsa-stage2-2026-08-17/`; manifest
SHA-256 is
`90b3fe4ed53714604b7a747991b3bb1b87aedbf57a139915065f5b4be42cda38`.

### Stage 3 - deferred prefill follow-up

Only after decode is characterized, implement chunked sparse prefill with exact
causal selection semantics and run the same context ladder. This is the stage
that can test whether the paper's growing prefill benefit translates to MLX;
the existing single-token path cannot support that claim.

## Decision rules

- Preserve the shipped 21F/57S schedule regardless of outcome; it is model
  semantics.
- Call the work a local performance win only when three fresh MTP-on processes
  are token-identical and the paired median end-to-end wall time improves by at
  least 5% at a context that fits the 32 GB contract, without new swap or a
  footprint regression outside the existing G5 bounds.
- If the kernel saves DSA time but expert I/O hides the wall win, land only the
  correctness/scalability work and record the negative end-to-end result.
- Do not quote the paper's H100 speedups or GLM-5.2's 1M-token FLOP reduction as
  mlx-bun speed. Curated claims require this machine's `benchmark.sh`-quality
  evidence and belong in `benchmarks/RESULTS.md` only after the gate passes.
- Evaluate MTP-iteration index sharing as a separate follow-up with its own
  on/off control and acceptance trace.

## Exit

The spike closes when the DSA overlay is provenance-pinned, long-context
IndexShare matches an official runtime, the production-shaped score/top-k path
has exact model-free gates, and the paired MTP-off/on decode matrix has a
written decision. Prefill may remain a separately tracked follow-up only if the
decode result is already conclusive; otherwise sparse long prefill is required
before closure.
