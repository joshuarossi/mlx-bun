# Fine-tuning experiment: chunking task (2026-06-16)

Goal (from Josh): test mlx-bun's fine-tuning end-to-end on lucien's conversation-
chunking task — baseline → LoRA fine-tune → re-measure the quality delta.

## Headline result

A LoRA fine-tune of **MiniCPM5-1B** on the chunk task, trained and served entirely
by mlx-bun, on the 25-case frozen holdout (`lucien/benchmark/dataset/chunk.json`),
scored with lucien's exact `scoreChunk` metric:

| Metric | Baseline (stock) | Fine-tuned | Δ |
|---|---|---|---|
| **Mean score / 100** | **11.89** | **91.70** | **+79.8 (6.7×)** |
| Valid JSON | 12% (3/25) | 100% (25/25) | +88 |
| schema | 100% | 100% | — |
| anchors | 97% | 78% | −19 |
| labels | 100% | 96% | −4 |
| nonempty | 100% | 100% | — |

The baseline failure was pure **format**: the stock 1B model rambled past the token
limit without emitting parseable JSON on 88% of cases. After fine-tuning, every case
emits valid, well-formed chunk JSON and **stops** (68–456 generated tokens vs the
baseline hitting the 1536 cap). This validates the full mlx-bun pipeline:
**train (ops.sdpa) → save adapter (hot-swap format) → `AdapterManager.mount` → generate.**

## Why not e4b (the original target)

The original plan targeted `gemma-4-e4b-it-OptiQ-4bit`. The chunk data is long
(median 4092 tokens, 0% ≤2048, 98% ≤8192), so it needs 4–8K training context. On
this **32 GB M1 Max**, neither mlx-bun NOR the optiq reference can train a 7.4B-param
model at that length: I ran optiq's own `train_lora` on e4b and it completed only at
seq 512 (peak 18.24 GB, degenerate — 0 response tokens survive truncation) and
**crashed at 2048/4096/8192** with `[METAL] Command buffer execution failed: Impacting
Interactivity` — a memory-pressure GPU stall. It's a hardware ceiling, not a code gap.
Pivoted to **MiniCPM5-1B** (24 layers, head_dim 128, full attention), which fits 4–8K
training comfortably. See [[e4b-lora-training-seqlen-ceiling]].

## Correctness correction: ops.sdpa vs flash

Earlier in the session I concluded mlx-bun's `ops.sdpa` had a wrong dK gradient and
built/routed a flash kernel as the "correct" training attention. **That was backwards.**
A clean check (`scripts/sdpa-vs-manual.ts`) against **mlx-autograd of a plain
matmul/softmax forward** (the unimpeachable ground truth) shows:

```
dQ:  sdpa-vs-manual= 0.00%   flash-vs-manual= 0.06%
dK:  sdpa-vs-manual= 0.00%   flash-vs-manual= 106.01%   ← flash is the broken one
dV:  sdpa-vs-manual= 0.00%   flash-vs-manual= 0.02%
```

`ops.sdpa` is correct (and fast — one fused kernel). My flash dK kernel is the buggy
one; the earlier triangulation was fooled by a hand-derived FA-2 backward reference that
shares the dK formula with the flash kernel. The trainer now defaults to `ops.sdpa`
(flash opt-in via `MLX_BUN_TRAIN_ATTN=flash`). ops.sdpa's only downside is O(seq²)
backward memory — fine at ≤4096 for a 1B model (crashes ~8192 on long examples).

## Caveats (honest)

- **The benchmark metric is intrinsic** (JSON validity / schema / anchor resolution /
  label quality), not segmentation-F1 vs gold boundaries. The +79.8 reflects "produces
  valid, well-formed output," which is exactly what was broken.
- **anchors 97%→78%**: the fine-tuned model occasionally emits an anchor UUID that needs
  prefix-repair; one 47K-token case failed to resolve (score 50).
- **Under-segmentation**: the fine-tuned model emits 1 chunk on most conversations. The
  training data was filtered to ≤4000 tokens (730/1375 examples) for speed, biasing
  toward shorter single-topic conversations. Training on the full data at 8192 (or with
  the flash dK fixed for O(L) memory) would likely improve multi-chunk segmentation.

## Reproduce

```bash
# baseline
bun scripts/chunk-eval.ts                                    # 11.89/100
# filter data, fine-tune, re-measure
MAXTOK=4000 bun scripts/chunk-filter.ts
DATA=~/.cache/mlx-bun-finetunes/chunk-data-le4000 SEQ=4096 ITERS=300 \
  ADAPTER=~/.cache/mlx-bun-finetunes/minicpm5-chunk-final bun scripts/chunk-finetune.ts
ADAPTER=~/.cache/mlx-bun-finetunes/minicpm5-chunk-final bun scripts/chunk-eval.ts   # 91.70/100
```

Training: 300 iters, seq 4096, rank 16, lr 2e-4, ops.sdpa, ~26 min, peak 25.47 GB, val
loss flat ~0.19 (no overfit). Scripts: `chunk-eval.ts`, `chunk-filter.ts`,
`chunk-finetune.ts`, `sdpa-vs-manual.ts`.
