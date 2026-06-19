# Steel flash-CCE — handoff

Porting MLX's quantized `steel` GEMM verbatim into our flash-CCE ORPO head, then
fusing the ORPO-specific epilogue (softcap + online-softmax logp / softmax−onehot
coeff + dh) on top — to get **MLX-GEMM speed AND the `[M,V]`-free memory property**
in one kernel. MLX ships no fused "quantized-matmul + softcap + response-logp" op, so
we build the composition; the heavy GEMM is theirs, verbatim.

## HANDOFF — current state (2026-06-19): SHIPPED in v0.0.5

The whole ORPO training stack is **merged (PR #16) and released as v0.0.5** — `npm
i mlx-bun` / `brew install joshuarossi/tap/mlx-bun` (tap formula at 0.0.5, sha verified).
What shipped: the flash-CCE head (fwd+bwd), prefix-sharing, segmented composition, warm-start,
the `scripts/train-orpo.ts` launcher, and the IFEval/UltraFeedback eval pieces. Release notes:
GitHub release v0.0.5. Supported scope = **OptiQ-quantized MiniCPM5 + Gemma-4 (e4b/12B/26B)**.

**Post-merge PR-review fixes (CodeRabbit, commits 890f380 / 63759fa) — read these, they
caught real bugs:**
- 🔴 **Prefix-shared head-primal UAF** (`branchLogpMeanGathered`/`orpoLossPrefixShared`): the
  flash/fused-head CustomVjp PRIMAL (`hResp`, and `h`) was disposed *before* the lazy backward
  recomputes from it → use-after-free (same class as the segmented `headSink` one). Fix: push
  primals into the sink (freed post-eval) on the fused/flash path. **Tests passed before only
  by lazy-eval timing luck** — this was latent. Watch for this pattern anywhere a CustomVjp's
  primal is freed inline.
- **Segmented "flash implies fused"** (`trainer.ts` `segFusedChunk`): `orpoFlashCe` alone left
  the segmented non-prefix fallback on the full `[M,vocab]` head → e4b memory blowup. Now
  `orpoFusedCe || orpoFlashCe` routes through the bounded chunked head.
- Warm-start made atomic (validate all targets before disposing any), job payload exposes
  `warm_start_adapter`/`mlp_split`, script GPU inputs use `fromBytesCopy` (page-align footgun),
  env-precondition enforcement + flag validation in the probes.

**Warm-start** (`warmStartFromAdapter` / launcher `RESUME=<adapter-dir>`): continue from a
checkpoint's LoRA weights (optimizer + LR schedule restart). Insurance for interrupted runs.

**The training dress-rehearsal (honest):** a CPM5 UltraFeedback ORPO run (full stack, lr 5e-5)
reached ~step 4820, **val 1.66 → ~1.50, then plateaued** — expected: UF is open-ended, its loss
floor is ~1.2-1.5, NOT the 0.3-0.4 you get on a narrow task. **IFEval moved 22.5% → 22.5%
(flat)** — a real null result: general preference data + a partial run is the wrong lever for
IFEval. The pipeline learns (val dropped); the metric just isn't the right one. Checkpoints
every 200 under `./adapters/cpm5-uf-8h/checkpoints/` (best-val ~`step-04200-val1.5008`).

**Gotchas the runs taught us:**
- **Agent-spawned background runs get REAPED** (~47 min observed; not a crash/OOM — confirmed
  via logs + `pmset` showed no sleep). **Run long training detached from your OWN shell**
  (`nohup … &`), never as a session background task.
- e4b training **requires** `MLX_BUN_PERF_KERNEL=0` + `MLX_BUN_FUSED_GELU=0` (the launcher
  auto-sets them; the e4b parity probe now enforces them).
- Adapters live in **`~/.cache/mlx-bun/mlx-bun-finetunes/`** (launcher default), never the repo.

**THE next goal — the chunk segmenter (load-bearing).** UF was the rehearsal; the real run is
**distilling Opus/GPT-5.5 conversation-segmentation into a local model** (data at
`~/Code/lucien/benchmark/finetune/chunk-v3/dpo/orpo-curated-*.fixed.jsonl`, `{prompt:[sys,user],
chosen, rejected}` — already supported by the loader). Score by **boundary/label accuracy vs
the gold (chunk-eval), NOT val loss** (loss is dominated by low-entropy JSON/UUID tokens). This
is what localizes the Lucien synthesis pipeline's `chunk-recent` stage (the whole "100% local
memory" promise). ORPO is ideal here: chosen/rejected share the conversation + are both
well-formed JSON, so the contrast isolates the segmentation decision, and the gold makes
pair-ranking + eval objective. The stack is built for it (prefix-share the shared 8k
conversation once, segment the long context, flash the big vocab). See memory
[[training-tracks-are-appliance-components]]. After that: the e4b overnight, and the welcome
assistant (a UF-tuned greeter — system prompt carries the mlx-bun knowledge, not training).

**Run commands:** see [orpo-quickstart](../reference/orpo-quickstart.md) +
[training.md](../reference/training.md). The full stack is `scripts/train-orpo.ts` (defaults on);
resume with `RESUME=<ckpt-dir>`; run it detached (`nohup`).

## TL;DR status

| Piece | State |
|---|---|
| **Steel GEMM port** (verbatim MLX BlockMMA/QuantizedBlockLoader/qmm_t) | ✅ done, compiles, matches `quantizedMatmul` 1e-5, **101ms == MLX 106ms** on e4b |
| **Forward** (steel GEMM + softcap + online-softmax → logp) | ✅ **in production** (`flashCceForward` default), parity PASS e4b/cpm/M=200, **180ms** (5× the old 848ms) |
| **Backward** (steel GEMM ×2 + softmax−onehot coeff + dh accumulate) | ✅ **IN PRODUCTION** (`flashCceBackward` default, `BWD_STEEL_SOURCE`/`bwdSteelKernel`). Parity PASS e4b (dh 0.40%) + cpm (dh 0.28%); **754ms** @ e4b M=512 — phase-2 W dequant now uses MLX's fused `QuantizedBlockLoader` (HTw=group_size, reduction_dim=0), **5× the old SG's 3687ms exact** (was 1851ms with the scalar dequant). Peak **0.928 GB flat @ M=8192** (`[M,V]`-free preserved). Old SG kept as `MLX_BUN_CCE_BWD_NOSTEEL=1` fallback. |
| Old shipping backward | the **OLD hand-rolled SG kernel** (`[M,V]`-free, correct, slow 3687ms) — now the fallback only |

**So: BOTH directions are now fast + live (steel fwd 180ms, steel bwd 754ms, both
`[M,V]`-free + exact). M1 + the phase-2 dequant optimization DONE.** Backward is now
~2.1× the ~360ms ideal (down from ~5×). Everything below (M2 prefix-share, M3 e4b probe,
M3-composition segmented+prefix, M4A integration tests) is also DONE — see sections.

## Why this exists (the journey, so you don't repeat it)

- Our hand-rolled simdgroup_matrix GEMM runs at **~8% of M1 Max peak**; MLX's `steel`
  quantized GEMM runs at **~46%**. We spent a long time micro-optimizing the
  hand-rolled kernel (token tiling, h-coalescing, dequant staging, bank-conflict
  padding) — all marginal, because the gap is the **BlockMMA register-tiling +
  K-pipeline**, not staging. The decisive move was: **stop hand-rolling, copy MLX
  verbatim.** It works and hits their speed.
- **MLX's `quantizedMatmul` does the whole head ~3.8× faster than our old kernel AND
  exact** (fwd 151 + bwd 330 = 481ms). That's the `orpoFusedCe` head, already in the
  repo. The ONLY reason to keep flash-CCE: it's a **single kernel** → `[M,V]`-free,
  no per-chunk host-loop allocator churn.
- **Memory caveat (important, was over-claimed then corrected):** the head is NOT the
  memory wall at long seq — the layer activations are. Avoiding the full `[M,V]`
  (8.6 GB at e4b/8192) IS essential, but BOTH flash-CCE (+0.17 GB) and a properly
  streamed fused head (+0.27 GB) achieve it. flash-CCE backward peak is **0.93 GB flat
  at M=8192** (weights-dominated; kernel scratch ~5 MB; linear in M, flat in V). So
  option 2 (steel backward) is justified for **SPEED + single-kernel allocation
  flatness**, not because the fused head "blows up" (it doesn't, if streamed right).

## Files

- `src/train/steel-qmm-header.ts` — **the verbatim MLX steel port** (auto-assembled
  from MLX `quantized.h` + `steel/{gemm/mma.h,gemm/loader.h,gemm/transforms.h,
  utils/integral_constant.h,utils/type_traits.h}`). Exports `STEEL_QMM_HEADER` (the
  MSL header string). Contains: `BlockMMA`, `MMATile`, `BaseMMAFrag`, `tile_matmad`,
  `BlockLoader`, `QuantizedBlockLoader`, `dequantize`, `get_pack_factor`, `qmm_t_impl`.
- `src/train/flash-cce.ts` — the head. `FWD_STEEL_SOURCE` + `fwdSteelKernel(gs,bits)`
  (the **live forward**, dispatched by `useSteel` default). The old SG/scalar/lane
  forward kernels + the current backward (`BWD_SG_SOURCE` / `bwdSgKernel`, the
  hand-rolled persistent-acc[80] kernel) are still there.
- `src/train/loss.ts` — `makeFlashCceHeadVjp` (CustomVjp: fwd→Σlogp stash lse+blockMax,
  bwd→flashCceBackward). `ChunkCtx.flash`. Routed via `orpoFlashCe` config flag.
- `src/train/trainer.ts` / `job.ts` — `orpoFlashCe` / `orpo_flash_ce` knob.
- `tests/train-orpo-fused-ce.test.ts` — flash-head fwd-parity + end-to-end training
  tests (MLX_BUN_TEST_TRAIN=1, MiniCPM5).
- **Validated experiment scripts** (preserved, portable imports):
  - `scripts/experiments/qmm-port-test.ts` — steel GEMM correctness vs quantizedMatmul.
  - `scripts/experiments/qmm-port-speed.ts` — steel GEMM speed vs MLX (101 vs 106ms).
  - `scripts/experiments/steel-fwd-test.ts` — forward epilogue (logp) vs reference.
  - `scripts/experiments/steel-coeff-test.ts` — **backward phase-1** (logit→coeff) PASS.
  - `scripts/experiments/steel-bwd-test.ts` — **full backward dh** (phase-1+2) PASS 1.6e-5.
  - `scripts/experiments/bwd-peak.ts` — clean isolated backward peak (0.93 GB @ M=8192).
  - `scripts/experiments/fwd-gemm-bench.ts` — MLX QM baseline (fwd 151 / bwd 330ms).

## The architecture (what's proven)

Tile constants: **BM=8 tokens, BN=32 vocab, BK=32 hidden, WM=1, WN=4** (4 simdgroups
along N), `BK_padded = BK + 16/sizeof(T)`. The `WM=1,WN=4` choice is THE unlock:
BlockMMA's output tile is then split so **each simdgroup owns a different N-slice** —
which for the dh GEMM means each simdgroup owns a different **H-slice**, i.e. exactly
the persistent `acc[80]` layout we already proved works (160 regs/lane). So steel's
BlockMMA and the `[M,V]`-free persistent accumulator ARE compatible.

**Forward** (`FWD_STEEL_SOURCE`, live): grid `[128, NBLK, ⌈M/32⌉]` (BM=32 there, not 8),
per (token-block z, vocab-block y) threadgroup loop BN vocab-tiles → steel K-loop →
`Ctile.store` to threadgroup `Ls` → softcap + online-softmax → `[M,NBLK]` partials →
MLX merge → logp. `load_safe` for the last token-block (M%BM); vocab aligned for e4b/cpm.

**Backward** (proven in `steel-bwd-test.ts`, BM=8/WM=1/WN=4): per (token-block, vocab-
block) threadgroup, persistent `dmma = BlockMMA<float,float,8,H,32,1,4,false,false>`
Ctile = the dh accumulator. Loop vocab-tiles: phase-1 `lmma` BlockMMA logit → `Ls` →
coeff epilogue (`g·(onehot−softmax(logit−lse))·sech²`) → threadgroup `coeffS[8,32]`;
dequant W non-transposed → `Wd[32,H]`; `dmma.mma(coeffS, Wd)` accumulates `coeff@W`.
After the loop `dmma.store_result(dh,...)`.

## Gotchas (hard-won — read before touching the header/kernels)

1. **String.raw escaping**: when writing the header to a `.ts` string, do NOT escape
   backslashes (mangles macro `\` line-continuations). Only fails if content has a
   backtick or `${` (the MLX code has neither).
2. **MLX preamble**: `mx.fast.metal_kernel` already provides `METAL_FUNC` + `using
   namespace metal` (redef warning, harmless) but NOT `STEEL_CONST`/`MLX_MTL_CONST`/
   `SIMD_SIZE`/`Int<>`/`pointer_element_t` — we add the macros + `type_traits.h` +
   `integral_constant.h` ourselves.
3. **`#pragma METAL internals`**: `type_traits.h` and `integral_constant.h` need it
   (struct inheritance / `is_integral`). Include them **verbatim with their own
   self-managed enable/disable pragmas** — do NOT strip + wrap manually (type_traits'
   trailing `disable` will turn it off before integral_constant compiles → "derived
   classes not supported").
4. **W dequant convention** (in MANUAL dequant, e.g. phase-2 `Wd`): use
   `perWord = 32/bits` (4 elems per uint32 at 8-bit), NOT `get_pack_factor<bits,8>=1`
   (that's MLX's byte-based packing for the QuantizedBlockLoader's internal uint8
   addressing). Mixing these gave a 100%-wrong dh.
5. **`BlockMMA.mma` reads `Bs[BK,BN]` full-width** from threadgroup — so you can't wrap
   it for a full-H persistent accumulator (would need `W[32,2560]`=320KB tg). Either
   keep H small (test) or tile H with manual `tile_matmad` (production).
6. Watchdog: per-threadgroup vocab slice must stay bounded (`VOCAB_BLOCK=8192`).

## NEXT STEPS — the plan (in order)

### 1. H-tiling in the steel backward phase-2 (the one real remaining piece)
The test stages the full `W[32,H]`; at e4b H=2560 that's 320 KB > 32 KB threadgroup.
Production must tile H:
- dh accumulator = `MMATile<float, 1, H/32>` per simdgroup (= its H-quarter; 80 frags
  @ e4b = the proven `acc[80]` register budget).
- per vocab-tile: loop H in `BKh` chunks → dequant `W[32, BKh]` → threadgroup (small) →
  load coeff A-frags `MMATile<1,4>` + W B-frags `MMATile<4, BKh/8>` → `tile_matmad(
  D_sub, A, B_sub, D_sub)` into the right sub-frags of the persistent D.
- The intricate bit is the manual sub-frag indexing into D (BlockMMA does this
  internally; here we do `tile_matmad` by hand because D persists across vocab-tiles).
- Validate against `steel-bwd-test.ts` (extend it to H=2560, compare to QM(coeff,W,t=F)).

### 2. Vocab-blocking grid + atomic dh
- Grid `[128, NBLK, ⌈M/BM⌉]`; each (token-block, vocab-block) computes its block's dh
  contribution, **atomic-add** into device `dh` (across the NBLK blocks) — same pattern
  the current `BWD_SG_SOURCE` already uses (`atomicOutputs`, `initValue:0`).
- Need `lse` (have it, forward returns it) + `blockMax` (optional, for the block-skip)
  + `gv` (cotangent) passed in — same inputs as the current backward.

### 3. Wire into `flashCceBackward`
- Add `BWD_STEEL_SOURCE` + `bwdSteelKernel(gs,bits)` (header = STEEL_QMM_HEADER + defines).
- Dispatch: `useSteel` default when H,V,blockV %32 (mirror the forward's gate).
- Keep the old `bwdSgKernel` as fallback (H%32!=0) + the float4 scalar as last resort.
- The CustomVjp (`makeFlashCceHeadVjp`) already calls `flashCceBackward` — no change there.

### 4. Validate + benchmark
- Parity: `E4B=1 M=512 bun scripts/experiments/flash-cce-parity.ts` (+ cpm, + M=200).
  Expect dh ~0.4% (bf16-class) vs autograd.
- Bench vs baselines: fused head **481ms** (speed), current flash-CCE (memory parity).
  Target: steel backward in the same class as the forward (~hundreds of ms, vs 3375).
- Memory: `scripts/experiments/bwd-peak.ts` should stay ~0.93 GB @ 8192 (flat).
- **CAP ANY MEMORY PROBE well under 32 GB** and eval+free per iteration — a naive
  full-graph host-loop allocation swapped the machine to 23 GB once. Single-kernel
  flash probes are safe by construction.

### 5. (optional) softcap + filter/block-skip parity in the steel backward
- Softcap sech² is in the coeff epilogue already (steel-bwd-test uses cap=0; cap>0 path
  is written, validate it).
- The Apple-CCE coeff filter + blockMax skip are **opt-in, default-off** approximations
  (data-dependent; flat-softmax probes showed dh sensitivity). They live in the OLD
  backward; decide whether to port them to steel (probably not needed — steel is fast
  enough exact).

## Decision context (for when you pick the shipping config)

- **Now**: `orpoFlashCe` = steel forward (fast) + old SG backward (slow but `[M,V]`-free).
  Trains, memory-flat. `orpoFusedCe` = MLX QM both ways (481ms, exact, `[chunk,V]`
  transient).
- **After option 2 lands**: `orpoFlashCe` = steel fwd + steel bwd = fast AND `[M,V]`-free
  AND single-kernel — strictly best; removes the speed/memory tradeoff.
- The one genuinely-unanswered question: does the fused head's host-loop chunked backward
  churn MLX's allocator at real e4b/8192 training? An end-to-end training-step peak
  measurement (model + activations + head, with segmented/checkpointed backward) decides
  whether the single-kernel property matters in practice. Worth measuring once.

---

# END-STATE ROADMAP — "CPM5 test run with everything → e4b overnight @ 8192"

**The actual goal.** Two deliverables Josh runs himself (we wire, we do NOT kick off
the overnight run — ground rule):
- **(A)** A short **MiniCPM5** test training session using ALL optimizations — proves
  the whole stack composes and trains (loss decreases).
- **(B)** An **e4b overnight** ORPO run at seq **8192** — the real target.

"ALL of our stuff" = flash-CCE head (fwd+bwd at MLX speed, `[M,V]`-free) + prefix-sharing
(single fwd/bwd, prompt shared) + segmented/checkpointed backward (layer-activation
memory at long seq) + LoRA.

## What's already wired (so you don't redo it)
- flash-CCE **forward**: live + default (`flashCceForward`).
- flash-CCE head CustomVjp (`makeFlashCceHeadVjp`) ↔ `orpoFlashCe` flag ↔ trainer.
- flash threaded into BOTH non-segmented (`fusedLogpMeanB1`) and **segmented**
  (`fusedLogpMeanFromHidden`) head paths.
- Segmented backward exists (`SegmentedBackwardOrpo` / `…Gemma4`), `segmentSize` flag.
- ORPO B=1 path (`branchLogpMean`→fused/flash) + tests (MiniCPM5 flash training PASSES).
- prefix-sharing math (`orpoLossPrefixShared`, MiniCPM5, bit-exact, parity script).

## Milestones (dependency order)

### M1 — flash-CCE backward → production (the steel backward) ✅ DONE (2026-06-18)
H-tiled phase-2 (Design C: persistent `MMATile<1,H/32>` accumulator + per-H-tile temp
BlockMMA over bounded `Wd[32,128]` + lane-local frag accumulation) → vocab-blocking grid
+ atomic dh → `BWD_STEEL_SOURCE`/`bwdSteelKernel` wired into `flashCceBackward` (`useSteel`
gate: H,V,blockV %32 + H%128). Parity PASS e4b (dh 0.40%) + cpm (dh 0.28%); 2.0× the old
SG (1851 vs 3687ms e4b M=512 exact); peak 0.928 GB flat @8192. Design validated first in
`scripts/experiments/steel-bwd-htile-test.ts` (H=2560, PASS 1.1e-4 rel). Both flash
directions now fast. KEY INSIGHT that avoided the "intricate manual tile_matmad": a TEMP
BlockMMA per H-tile whose Ctile is accumulated into the persistent D via `frag += frag`
(lane-local — the per-lane element layout is identical, so no get_coord math needed).

### M2 — prefix-sharing → trainer (single fwd/bwd) ✅ DONE (2026-06-18)
- `orpoPrefixShared` trainer flag (+ `orpo_prefix_shared` job field) dispatches to
  `orpoLossPrefixShared` (MiniCPM5) / `orpoLossPrefixSharedGemma` (Gemma4 — the sibling
  already existed) via `splitPrefixBatch`, falling back to two-forward `orpoLoss` when a
  row's chosen/rejected prompts differ. Guarded against `segmentSize>0` (composition is
  M3). End-to-end CPM5 training test PASSES (loss decreases).
- **Composed with the flash head**: new `branchLogpMeanGathered` gathers each branch's
  `[M,H]` response hiddens → `fusedRespLogpMean(flash)` per branch (reuses the analytic
  per-branch VJP — cleaner than splitting one call's non-uniform length-normalized
  cotangent). Validated: flash-routed prefix-share matches whole-vocab prefix-share to
  **0.018%** (bf16-class) in `prefix-shared-parity.ts`. So prefix-share is now `[M,V]`-free
  end to end (one model fwd + per-branch flash fwd/bwd).
- **e4b caveat unchanged**: e4b's bf16 length-sensitivity (~2–14%) is a numerical-parity
  nicety, not correctness. MiniCPM5 is bit-exact (forward 0%, grads ~1% at P=512). NOTE:
  for the e4b OVERNIGHT at seq 8192, prefix-share can't be used until M3 composes it with
  the segmented backward — the overnight uses **segmented + flash** (validated config shape
  below), with prefix-share an M3 follow-on.

### M4A — CPM5 smoke test of the complete new system ✅ DONE (2026-06-18)
Automated end-to-end tests in `tests/train-orpo-fused-ce.test.ts` (run with
`MLX_BUN_TEST_TRAIN=1`), all PASS — each trains CPM5 20 iters, asserts finite +
decreasing loss + no OOM/NaN:
- **flash head** (steel fwd+bwd) + LoRA.
- **prefix-share + flash** (the single-concat-forward + `[M,V]`-free head).
- **segmented + flash** (the e4b-overnight config shape: gradient-checkpointed layer
  activations + `[M,V]`-free head). These exercise every new piece composing in a real
  ORPO step. (prefix-share + segmented together = M3, not yet composed.)

### M3 — long-sequence memory @ e4b/8192 (the layer activations, NOT the head)
- Compose segmented/checkpointed backward (`segmentSize>0`) + flash head + prefix-share.
  The head is ~free in memory (0.93 GB flat); the wall is the transformer activations,
  which segmented backward already handles (peak 10.9→3.3 GB @2048 per the notes).
- **THE measurement that actually decides "does e4b train at 8192"**: a real end-to-end
  training-step peak (model + activations + head) with segmented backward on. Do this
  EARLY — it tells us the segment size needed to fit 8192 in 32 GB, and whether the head
  choice (flash vs fused) matters at all. (Cap probes; never swap the machine.)

### M3/M4B — e4b @ 8192 memory probe + overnight config ✅ PROBED (2026-06-18)
`scripts/bench-orpo.ts` sweeps the new-system configs (`flash head` / `segmented + flash`
/ `prefix + flash`); `ONLY_NEW=1` skips the legacy baselines, `CONFIG="<substr>"` runs one,
and it now prints peak GB + a finite-loss check. The **`segmented + flash` row IS the
overnight config shape**.

**MEASURED on the M1 Max 32 GB (e4b, segmented+flash, SEG=2, `MLX_BUN_PERF_KERNEL=0
MLX_BUN_FUSED_GELU=0`):**
| SEQ | peak GB | ms/step |
|---|---|---|
| 1024 | 8.66 | 20.7k |
| 2048 | 10.17 | 40.4k |
| 4096 | 11.68 | 80.8k |
| **8192** | **16.14** | **175k** (loss 0.093→0.091 finite, decreasing) |

Footprint is **linear** in seq (~+1.5 GB / 1024 tokens — segmenting + flash attention keep
it linear, not quadratic; the head is flat 0.93 GB). **e4b @ 8192 fits in 16.14 GB with
~16 GB headroom — the historical "e4b OOMs ≥2048" ceiling is BROKEN.** SEG=2 is the sweet
spot: SEG=8 @ 8192 hit **33.47 GB (swapped) and was slower** — bigger segments hold more
activations, so small segments win here. The run command:
```
MODEL=<e4b-snapshot> CONFIG="segmented + flash" SEQ=8192 SEG=2 ITERS=3 \
  MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0 bun scripts/bench-orpo.ts
```

**VALIDATED overnight config (segmented + flash + LoRA):**
```
method:"orpo", orpoFlashCe:true (implies fused), segmentSize:2, orpoChunkSize:512,
maxSeqLen:8192, env MLX_BUN_PERF_KERNEL=0 + MLX_BUN_FUSED_GELU=0, rank/scale/lr + real
dpo data per the run, LoRA targets default. Peak ~16 GB, ~2.9 min/step on the M1 Max.
```
Prefix-share is NOT in the overnight (segmented + prefix-share = the M3-composition below);
the overnight uses segmented + flash. **Josh starts the overnight** (ground rule).

### M3-composition — segmented backward + prefix-share together ✅ LANDED MiniCPM5 (2026-06-18)
New `SegmentedBackwardOrpoPrefix` (`src/train/segmented.ts`): streams ONE concat
`[prompt; chosen; rejected]` through the segmented backward with `PrefixSharedCache`
(block-sparse mask) + `setMiniCpmPrefixPlan` active during the streaming forward AND every
segment's `mlx_vjp` recompute; the head VJP gathers chosen/rejected response positions
(`branchLogpMeanGathered`, the `[M,V]`-free per-branch flash head) and scatter-adds its dh
into the `[1,T,H]` boundary that seeds the segmented backward. Trainer composes it (old
guard removed) with a two-forward-segmented fallback on prompt mismatch. Validated
(`scripts/experiments/prefix-shared-segmented-parity.ts`): grads **2.27%** bf16-class
(single-segment diagnostic 1.16% → it's segment-boundary reassociation + flash-head 0.4%
stacking, not a bug), loss **0.052%**, peak **32% lower** (3.64→2.47 GB @ P=512; grows to
59% lower @ P=1024) — prompt-encode-once now holds at long seq with flat ~2.5 GB activation.
Test #6 in `tests/train-orpo-fused-ce.test.ts` (PASS). **e4b (Gemma4) DEFERRED** — trainer
throws a clear error; the logical-position sliding-window prefix mask + donor-KV threading
across segmented donor boundaries is the remaining follow-on (the overnight uses
segmented+flash without prefix-share, which works).

### M4 — runnable configs + the two runs
- **(A) MiniCPM5 test config**: short seq, small iters, `orpoFlashCe` (or prefix-share
  mode) + segmented on, LoRA. Run `trainLora`; assert loss decreases. This is the
  "everything composes" gate — basically the existing flash training test scaled up.
- **(B) e4b overnight config**: seq 8192, `segmentSize` tuned from M3, flash head,
  prefix-share (or two-forward if e4b variance is a problem), LoRA, full dataset
  (`scripts/curate-ultrafeedback.ts` / the dpo data). **Josh runs this** — we hand him a
  validated config + command, we do not start it.

## THE POINT: the runs are INTEGRATION TESTS of the NEW system
Josh does NOT care about training quality/results. The CPM5 run and the e4b run exist to
**exercise everything we just built — steel backward + flash head + prefix-sharing — end
to end in a real ORPO training step** and confirm the new code path RUNS (loss is finite,
decreases a bit, no crash/NaN/OOM). So we FINISH all the new pieces, wire them ALL the
way through, then run. Do NOT ship the old slow backward as a crutch — the steel backward
is part of what's being tested.

## Order of execution (build the new system, then test it)
1. **M1 — steel backward → production** (H-tile phase-2, vocab-block + atomic dh, wire
   `bwdSteelKernel` into `flashCceBackward`, parity e4b/cpm). The new backward IS under
   test; it must be in the path.
2. **M2 — prefix-sharing → trainer + compose with flash head** (gather `[Rc+Rr]` → one
   flash-head call → split by branch). MiniCPM5 first.
3. **M4(A) — CPM5 test run = the smoke test of the complete new system**: flash fwd+bwd
   (steel) + prefix-share + segmented + LoRA, all on. Run `trainLora` a handful of steps;
   assert finite + decreasing loss + no OOM. THIS is the test — it validates every new
   piece composes in a real step. If it passes, the new system works.
4. **M3 — e4b @ 8192 dry-run**: same new system on e4b, seq 8192, segmented on. First a
   memory/step-peak check (cap it; the head is flat 0.93 GB, the wall is activations →
   tune `segmentSize`), then a few real steps to confirm it RUNS. (e4b prefix-share bf16
   variance is fine — we're not checking quality; if it NaNs, fall back to two-forward.)
5. **M4(B) — e4b overnight**: hand Josh a validated config + command for the longer run
   (we wire + validate a few steps; **Josh starts the overnight** — ground rule).

**Risk register**: M1 mechanical (scoped — architecture+correctness already proven). M2/e4b
bf16 variance = non-blocking for a RUN test (two-forward fallback; quality irrelevant). M3
e4b/8192 memory = the one real unknown, but it's an activations/segmentSize question, not
a head question. The runs test integration; the pieces are individually validated.

---

# GLOSSARY — every named piece, what it is, status, where

Status legend: ✅ done+live · 🟢 done, not production-wired · 🟡 partial · 🔬 proven in a
test only · 📦 pre-existing (not ours this arc) · 🪦 dead end.

## A. The "head" = how we turn response hiddens `[M,H]` into ORPO log-probs
(M = number of response tokens; V = vocab; H = hidden.) These are *alternative
implementations of the same math* (`logp_t = target_logit − logsumexp_v`).
- **Full-logits head** 📦 — the naive reference: materialize `[M,V]` logits, logsumexp.
  Correct, huge memory. Only used as the parity oracle.
- **Chunked head** (`orpoChunkSize`) 📦 — token-chunked + per-chunk `Checkpoint`; bounds
  `[M,V]`→`[chunk,V]`. Older, autograd through the head.
- **Fused linear-CE head** (`orpoFusedCe`, `fusedRespLogpMean`) 📦✅ — a `CustomVjp` with
  an ANALYTIC softmax−onehot backward (no autograd through the head), using **MLX
  `quantizedMatmul`** for both GEMMs, token-chunked. Fast (**481ms** e4b), exact,
  `[chunk,V]` transient. The speed baseline we're trying to match.
- **Vocab-blocked head** (`makeVocabBlockedHeadVjp`) 📦 — pure-MLX online-softmax over
  vocab blocks; `[chunk, vocabBlock]` only. Slow-ish; the MLX-only CCE.
- **flash-CCE head** (`orpoFlashCe`, `makeFlashCceHeadVjp`) — **OURS**, the Metal-kernel
  head: the vocab loop lives INSIDE one Metal kernel, so neither `[M,V]` nor a
  dequantized `[V,H]` ever touches HBM → `[M,V]`-free, single kernel. Forward ✅ live,
  backward 🟡 (old slow kernel live; steel kernel 🔬 proven, not wired). `flashCceForward`
  + `flashCceBackward` in `src/train/flash-cce.ts`.

## B. flash-CCE kernel internals (`src/train/flash-cce.ts`) — OURS
The flash head dispatches to one of several kernel implementations of fwd/bwd:
- **`FWD_STEEL_SOURCE` / `fwdSteelKernel`** ✅ — the NEW steel-GEMM forward (default). 180ms.
- `FWD_SG_SOURCE` / `fwdSgKernel` 🪦-ish — old hand-rolled simdgroup_matrix forward (848ms).
- `FWD_SOURCE` / `fwdKernel` — scalar fallback (H%32≠0).
- `FWD_LANE_SOURCE` 🪦 — lane-sliced (2.6× slower, dead end, kept gated).
- **`BWD_SG_SOURCE` / `bwdSgKernel`** ✅(live) — CURRENT production backward: hand-rolled
  simdgroup_matrix, persistent `acc[80]` dh accumulator, phase-1 (logit→coeff) +
  phase-2 (dh=coeffᵀ@W). Correct, `[M,V]`-free, **slow (3375ms)**.
- `BWD_SOURCE` / `bwdKernel` — float4 scalar backward fallback.
- **STEEL BACKWARD** 🔬 — the NEW one: `scripts/experiments/steel-bwd-test.ts`, validated
  dh 1.6e-5, NOT yet a production kernel (`BWD_STEEL_SOURCE` is M1's job).

## C. The steel port (`src/train/steel-qmm-header.ts`) — OURS (verbatim from MLX)
MLX's quantized `steel` GEMM, copied verbatim so we run at MLX speed (~46% peak vs our
hand-rolled 8%). The `STEEL_QMM_HEADER` string contains:
- **`BlockMMA`** — the tiled matmul (BM×BN output, BK contraction, WM×WN simdgroups, the
  K-pipeline). The thing that makes MLX fast.
- **`MMATile` / `BaseMMAFrag` / `tile_matmad`** — the 8×8 simdgroup-matrix fragment
  abstraction BlockMMA is built on (used directly for the persistent dh accumulator).
- **`QuantizedBlockLoader`** — loads packed quantized weights and dequantizes them
  straight into the threadgroup matmul tile (fused dequant, no separate pass).
- **`BlockLoader`** — loads the dense input (X / coeff) into the tile.
- **`qmm_t_impl`** — MLX's full quantized-matmul orchestration (we use it for the
  forward; the backward composes BlockMMA + tile_matmad ourselves).
- Tile params we use: **BM=8/32, BN=32, BK=32, WM=1, WN=4** (the `WM=1,WN=4` is the key
  that makes BlockMMA's output tiling match our `[M,V]`-free per-simdgroup H-slice accum).

## D. The epilogue (what we FUSE on top of the steel GEMM) — OURS
MLX has no "quant-matmul + softcap + response-logp" op, so we add:
- **Softcap** — `cap·tanh(raw/cap)` (Gemma final-logit cap; e4b cap=30, cpm none) + its
  `sech²` chain-rule term in the backward.
- **Online softmax** — running `(max, sumexp)` over vocab blocks → `lse` (forward).
- **Gather / target capture** — pick the target token's logit per row.
- **softmax−onehot coeff** — the backward gradient `coeff = g·(onehot − softmax)·sech²`.
- **MLX merge** — combine the `[M,NBLK]` per-vocab-block partials → `logp`/`lse` in MLX.

## E. Backward approximations (opt-in, default-off, data-dependent) — OURS
Both are Apple-CCE-style skips that proved unreliable on flat/synthetic softmax, so they
are OFF by default and live in the OLD backward; probably NOT needed once steel is fast.
- **Coeff filter** (`MLX_BUN_CCE_BWD_FILTER_EPS`) — skip phase-2 chunks whose whole coeff
  block < eps.
- **blockMax vocab-block skip** (`MLX_BUN_CCE_BWD_BLOCK_EPS`) — skip whole cold
  (token-block, vocab-block) programs using the forward's `blockMax`.

## F. Model-level optimizations (above the head)
- **Prefix-sharing** (`src/train/prefix-shared.ts`, `orpoLossPrefixShared`,
  `blockSparseMask`, `PrefixSharedCache`) 🟢 — OURS (earlier this arc). One forward over
  `[prompt ; chosen ; rejected]` with a block-sparse mask (chosen & rejected each attend
  the shared prompt but NOT each other) → prompt encoded ONCE, single fwd/bwd for the
  pair. Bit-exact for MiniCPM5; e4b has a bf16 length-sensitivity caveat. Built + parity
  script, NOT wired into the trainer.
- **Segmented backward** (`src/train/segmented.ts`, `SegmentedBackwardOrpo*`,
  `segmentSize`) 📦✅ — gradient checkpointing for the TRANSFORMER LAYER activations (the
  real memory wall at long seq; orthogonal to the head). Composes with the flash head
  (`fusedLogpMeanFromHidden` carries the `flash` flag).

## G. Wiring / config layer
- **`makeFlashCceHeadVjp`** (`loss.ts`) — wraps flashCceForward/Backward as a `CustomVjp`
  (fwd→Σlogp, stash lse+blockMax; bwd→dh×cotangent). OURS.
- **`ChunkCtx`** (`loss.ts`) — the head config struct: `{fused, flash, chunkSize,
  vocabBlock, sink}`.
- **`orpoLoss` / `branchLogpMean`** (`loss.ts`) — the ORPO loss entry; B=1 routes to the
  fused/flash head, B>1 to full-logits.
- **Trainer flags** (`trainer.ts` / `job.ts`): `orpoFusedCe`, `orpoFlashCe`, `segmentSize`,
  `orpoChunkSize`, `orpoLambda`. CLI: `--orpo-flash-ce` etc.

## H. Baselines / numbers to remember
- MLX `quantizedMatmul` raw GEMM (the speed reference): e4b fwd **151ms**, bwd **330ms**.
- Fused head total: **481ms** exact.
- Our steel forward: **180ms** (raw GEMM 101ms; +epilogue). Old SG forward: 848ms.
- Our backward: old SG **3375ms** (live); steel target ~hundreds of ms (M1).
- flash-CCE backward peak: **0.93 GB flat @ M=8192** (weights-dominated; kernel ~5MB;
  linear in M, flat in V).
