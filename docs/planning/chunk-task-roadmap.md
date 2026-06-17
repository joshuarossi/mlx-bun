# Chunk-task quality roadmap (2026-06-17)

Where the MiniCPM5 chunking adapter stands and what raises real segmentation
quality. Companion to [[chunk-eval-metric-vs-accuracy]] and
[`docs/investigations/chunk-finetune-experiment.md`](../investigations/chunk-finetune-experiment.md).

## Where we are

- Adapter **solved the output contract**: 0/25 invalid JSON (base model: 22/25
  invalid — unusable). That's the entire 95.10 well-formedness score.
- Adapter is **mediocre at the actual task**: vs-gold boundary ~35.6, label ~52.0,
  all 25 cases in disagreement (`reports/chunk-eval-cpm-2026-06-17.html`).
- Dominant failures: `under_split` 17/25, TAIL GAP / `missed_content` 9,
  hallucinated anchors 4 — explained by the training-data bias below.

## Step 1 (the lever): fix the training data

The data (`chunk-data-le4000`) is **86% single-chunk** (626/730 examples = 1 chunk,
mean 1.16, max 4). The model learned a strong "one short chunk" prior → it
under-splits and truncates coverage. A 1B model on this diet isn't at its capacity
ceiling, it's mimicking its data.

- Rebuild the dataset so the **chunk-count distribution matches real operational
  segmentation**, not a single-topic majority.
- Teach **full-transcript coverage** (spans that reach the end — kill the tail gaps).
- This is the #1 lever. Do it before touching capacity or iters.

## Eval methodology: do NOT judge against codex's gold

**Codex over-segments — it splits articles ~2× what we actually do in operations.**
So the current gold is inflated: judging the adapter as `under_split` is partly an
artifact of a gold that over-splits. The under-split signal is real but smaller than
the verdict count suggests.

- Recalibrate the gold to **operational granularity** (use real-ops segmentations as
  the reference, or down-weight codex's extra splits) before trusting `bs`/`ls`.
- Until the gold matches ops, the report **understates** the adapter.
- Going forward, optimize against operational gold, not codex, and not the saturated
  well-formedness score.

## rank / scale: tune for a single narrow task

We are telling CPM to do exactly **one** thing: take a sequence of messages and find
the topic seams. That narrowness should drive the LoRA capacity knobs deliberately —
revisit the inherited rank 16 / scale 1 rather than carrying old defaults. Folds into
the "configurable training params with mlx-lm defaults" task (rank / scale / num_layers
/ LR / dropout selectable at run start). The question to answer empirically: how little
rank does this one transformation need, and what scale/LR pairs with it.

## Streaming / windowed segmentation mode

Whole-transcript-at-once is one framing; it likely isn't the operational one. Explore:

- A **sliding message window** — segment incrementally as messages arrive, over a
  bounded window, rather than ingesting the entire conversation.
- "Lots of different ways to segment these conversations" — try multiple task
  formulations (whole-transcript vs windowed vs streaming/online) and measure which
  matches operations and trains best on a small model.
- Implications for training data shape (windowed targets) and for serving (a streaming
  endpoint / incremental decode).

## Evaluate other base models

CPM5-1B is tiny and was a memory-driven pick. Run a **bake-off**: score other base
models on the chunk task (same gold, same harness) to find the best base for the
chunking adapter. Capacity is the second lever after data — and the e4b +
segmented-backward work exists precisely to train bigger models at long context. See
[[e4b-lora-training-seqlen-ceiling]], [[segmented-backward-landed]].

## Ordered plan

1. **Fix the training data** (multi-chunk + full coverage, operational granularity).
2. **Recalibrate the eval gold** off codex toward operational segmentation.
3. **Tune rank/scale** for the single narrow task (with configurable params).
4. **Prototype streaming/windowed** segmentation; pick the framing that fits ops.
5. **Model bake-off**; move up in capacity (e4b via segmented backward) if data alone
   plateaus.
