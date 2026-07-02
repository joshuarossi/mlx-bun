// GUARDED parity test for the ORPO FUSED linear-CE head (fusedLogpMeanB1: one
// CustomVjp with an analytic softmax−onehot backward, no autograd through the
// head and no retained [M,vocab] logits — the Liger/CCE structure). The forward
// is the SAME math as the full-logits head, so the loss must match the
// non-chunked head to within bf16 tolerance (the only divergence is single-ULP
// head-matmul/logsumexp rounding that tiles differently for [M,V] vs [chunk,V]).
// A logic bug shifts the loss by order 1, not <0.05.
//
//   MLX_BUN_TEST_TRAIN=1 bun test tests/train-orpo-fused-ce.test.ts
//
// Gated like train-orpo-chunked (loads MiniCPM5-1B; no softcap — Gemma softcap is
// exercised in scripts/experiments/fused-ce-parity.ts with E4B=1).

import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import type { DpoBatch } from "../src/train/dataset";

const optIn = process.env.MLX_BUN_TEST_TRAIN === "1";
const BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveBase = existsSync(`${BASE}/config.json`);

describe.skipIf(!optIn || !haveBase)("ORPO fused linear-CE head parity (MiniCPM5-1B)", () => {
  test("fused forward matches non-chunked within bf16 tolerance; full-size chunk is exact", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { buildTrainableLora, attachForTraining } = await import("../src/train/lora-params");
    const { resolveRanks } = await import("../src/train/rank");
    const { encodeDpoRow } = await import("../src/train/dataset");
    const { orpoLoss } = await import("../src/train/loss");
    const { evalAll } = await import("../src/mlx/ops");

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const ranks = resolveRanks(model, { rank: 8, rankScaling: "constant" });
    const lora = buildTrainableLora(model, ranks, 2.0, 123);
    attachForTraining(model, lora, "train");

    const row = JSON.parse(readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8").split("\n")[0]!);
    const ex = encodeDpoRow(row, tok, tmpl, 256);
    const batch: DpoBatch = {
      chosenIds: [ex.chosenIds], rejectedIds: [ex.rejectedIds],
      chosenMask: [ex.chosenMask], rejectedMask: [ex.rejectedMask],
    };
    const respLen = Math.max(
      ex.chosenMask.reduce((a, b) => a + b, 0),
      ex.rejectedMask.reduce((a, b) => a + b, 0),
    );

    // chunkSize<=0 → full-logits head (the reference); >0 with fused → fused head.
    const lossOf = (chunkSize: number): number => {
      const sink: Array<{ dispose(): void }> = [];
      const l = orpoLoss(model, batch, 0.1, chunkSize > 0 ? { chunkSize, fused: true, sink } : undefined);
      evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      for (const d of sink) d.dispose();
      return v;
    };

    const full = lossOf(0);
    expect(Number.isFinite(full)).toBe(true);

    // The fused forward is the same math as the full-logits head → equal within
    // bf16 tolerance across token-chunk sizes (observed diffs are single-ULP /M).
    for (const cs of [1, 4, 8]) {
      expect(Math.abs(lossOf(cs) - full)).toBeLessThan(0.05);
    }
    // A chunk >= the response length is a single chunk → bit-exact (same shapes).
    expect(lossOf(respLen + 8)).toBeCloseTo(full, 5);

    // flash-CCE head (in-kernel quantized logits + online softmax, no [M,V]) — the
    // forward is the same logp math, so the loss matches the full-logits head within
    // the kernel's bf16-class parity (~0.2% logp → well under 0.05 on an O(1) loss).
    const flashLoss = (() => {
      const sink: Array<{ dispose(): void }> = [];
      const l = orpoLoss(model, batch, 0.1, { chunkSize: respLen + 8, fused: true, flash: true, sink });
      evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      for (const d of sink) d.dispose();
      return v;
    })();
    expect(Math.abs(flashLoss - full)).toBeLessThan(0.05);

    weights.dispose();
  }, 180_000);

  test("sft_scope: 'response' is bit-identical to the default; 'full' agrees across naive/fused/flash/chunked/prefix/segmented paths", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { buildTrainableLora, attachForTraining } = await import("../src/train/lora-params");
    const { resolveRanks } = await import("../src/train/rank");
    const { encodeDpoRow } = await import("../src/train/dataset");
    const { orpoLoss, orpoMetrics, sftLoss } = await import("../src/train/loss");
    const { orpoLossPrefixShared, splitPrefixBatch } = await import("../src/train/prefix-shared");
    const { SegmentedBackwardOrpo, SegmentedBackwardOrpoPrefix, planSegmentsBySize } = await import("../src/train/segmented");
    const { MiniCPM5Model } = await import("../src/model/minicpm5");
    const { evalAll } = await import("../src/mlx/ops");

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    if (!(model instanceof MiniCPM5Model)) throw new Error("test base must be MiniCPM5");
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const ranks = resolveRanks(model, { rank: 8, rankScaling: "constant" });
    const lora = buildTrainableLora(model, ranks, 2.0, 123);
    attachForTraining(model, lora, "train");

    const row = JSON.parse(readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8").split("\n")[0]!);
    const ex = encodeDpoRow(row, tok, tmpl, 256);
    const batch: DpoBatch = {
      chosenIds: [ex.chosenIds], rejectedIds: [ex.rejectedIds],
      chosenMask: [ex.chosenMask], rejectedMask: [ex.rejectedMask],
    };
    const lambda = 0.1;

    const lossOf = (scope: "full" | "response", chunk?: { chunkSize: number; fused?: boolean; flash?: boolean }): number => {
      const sink: Array<{ dispose(): void }> = [];
      const l = orpoLoss(model, batch, lambda, chunk ? { ...chunk, sink } : undefined, scope);
      evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      for (const d of sink) d.dispose();
      return v;
    };

    // --- 'response' scope is BIT-IDENTICAL to the pre-sft_scope default path. ---
    const respDefault = lossOf("response"); // == orpoLoss without the arg (same default)
    const respAgain = (() => {
      const l = orpoLoss(model, batch, lambda); // no sftScope arg at all
      evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      return v;
    })();
    expect(respAgain).toBe(respDefault); // exact: identical graph, deterministic

    // --- 'full' naive: finite, and actually different (the prompt NLL counts). ---
    const fullNaive = lossOf("full");
    expect(Number.isFinite(fullNaive)).toBe(true);
    expect(Math.abs(fullNaive - respDefault)).toBeGreaterThan(1e-4);

    // --- Independent NLL oracle: full-scope chosen NLL == SFT masked CE with
    // promptLen=1 on the chosen row (supervise every non-pad prediction). ---
    const mFull = orpoMetrics(model, batch, lambda, "full");
    const mResp = orpoMetrics(model, batch, lambda, "response");
    const sftRef = (() => {
      const l = sftLoss(model, { ids: [ex.chosenIds], promptLens: [1] });
      evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      return v;
    })();
    // Same positions, same token-mean — but the full path heads the prompt and
    // response as TWO span slices (keeping ℓw bit-identical to the response
    // path) while sftLoss heads one [0,len-1) slice; the quantized head matmul
    // tiles differently per slice shape and logp is bf16 (1 ULP at |logp|≈12 is
    // 0.0625), so the agreement is bf16-class — the file's established 0.05 bar,
    // not f32-exact. Measured diff here: ~0.0096 on an NLL of ~5.14.
    expect(Math.abs(mFull.nll - sftRef)).toBeLessThan(0.05);
    expect(mFull.or).toBeCloseTo(mResp.or, 4); // odds ratio unchanged by the scope
    expect(fullNaive).toBeCloseTo(mFull.nll + lambda * mFull.or, 4);

    // --- 'full' across head tiers (same tolerances as the response-scope parity). ---
    expect(Math.abs(lossOf("full", { chunkSize: 8, fused: true }) - fullNaive)).toBeLessThan(0.05);
    expect(Math.abs(lossOf("full", { chunkSize: 4 }) - fullNaive)).toBeLessThan(0.05); // Checkpoint chunked
    expect(Math.abs(lossOf("full", { chunkSize: 4096, fused: true }) - fullNaive)).toBeLessThan(0.05); // single-chunk fused
    expect(Math.abs(lossOf("full", { chunkSize: 4096, fused: true, flash: true }) - fullNaive)).toBeLessThan(0.05); // flash-CCE

    // --- 'full' through prefix-sharing (one concat forward, prompt gathered). ---
    const split = splitPrefixBatch(batch);
    expect(split).not.toBeNull();
    const prefixFull = (() => {
      const l = orpoLossPrefixShared(model, split!.promptIds, split!.chosenResp, split!.rejectedResp, lambda, undefined, "full");
      evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      return v;
    })();
    // The prefix-shared forward carries a PRE-EXISTING bf16-class offset vs the
    // two-forward path with the training LoRA attached (measured ~0.055 on the
    // RESPONSE-scope loss, i.e. in code this change didn't touch — per-position
    // logp is bf16, and the concat attends over T=P+Rc+Rr key slots vs P+R).
    // So assert (a) a coarse absolute bound, and (b) the tight, meaningful one:
    // the SCOPE DELTA (full − response) — which isolates exactly the new
    // prompt-NLL term — agrees between prefix and two-forward (measured 0.011).
    const prefixResp = (() => {
      const l = orpoLossPrefixShared(model, split!.promptIds, split!.chosenResp, split!.rejectedResp, lambda, undefined, "response");
      evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      return v;
    })();
    expect(Math.abs(prefixResp - respDefault)).toBeLessThan(0.15); // pre-existing bf16 offset class
    expect(Math.abs(prefixFull - fullNaive)).toBeLessThan(0.15);
    expect(Math.abs((prefixFull - prefixResp) - (fullNaive - respDefault))).toBeLessThan(0.05);

    // --- 'full' through the segmented backward (two-branch AND prefix). The head
    // VJP now includes the prompt-span contributions; the VALUE must agree with
    // the naive full loss, and the grads must be finite. ---
    const ranges = planSegmentsBySize(model.layers.length, 8);
    const seg = new SegmentedBackwardOrpo(model, lora, ranges, lambda, 0, "full");
    const segRes = seg.step(batch);
    evalAll([segRes.value, ...segRes.grads]);
    expect(Math.abs(segRes.value.toFloat32()[0]! - fullNaive)).toBeLessThan(0.05);
    let gradNormSq = 0;
    let allFinite = true;
    for (const g of segRes.grads) {
      for (const v of g.toFloat32()) {
        if (!Number.isFinite(v)) allFinite = false;
        gradNormSq += v * v;
      }
      g.dispose();
    }
    expect(allFinite).toBe(true);
    expect(gradNormSq).toBeGreaterThan(0); // the backward actually produced signal
    segRes.value.dispose();
    seg.dispose();

    const segPrefix = new SegmentedBackwardOrpoPrefix(model, lora, ranges, lambda, undefined, "full");
    const spRes = segPrefix.stepPrefix(split!.promptIds, split!.chosenResp, split!.rejectedResp);
    evalAll([spRes.value, ...spRes.grads]);
    // Compare against the NON-segmented prefix full loss (same forward layout —
    // isolates the segmented streaming, not the prefix bf16 offset).
    expect(Math.abs(spRes.value.toFloat32()[0]! - prefixFull)).toBeLessThan(0.05);
    let spFinite = true;
    for (const g of spRes.grads) {
      for (const v of g.toFloat32()) if (!Number.isFinite(v)) spFinite = false;
      g.dispose();
    }
    expect(spFinite).toBe(true);
    spRes.value.dispose();
    segPrefix.dispose();

    weights.dispose();
  }, 300_000);

  test("fused training backward runs (CustomVjp analytic recompute + sink disposal) and improves loss", async () => {
    const { mkdtempSync, mkdirSync, rmSync, writeFileSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    const tmp = mkdtempSync(join(tmpdir(), "orpo-fused-train-"));
    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    writeFileSync(join(dataDir, "train.jsonl"), readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8"));

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const losses: number[] = [];
    await trainLora(model, tok, tmpl, dataDir, {
      ...DEFAULT_TRAIN_CONFIG,
      method: "orpo", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
      iters: 20, learningRate: 1e-3, orpoLambda: 0.1, orpoLrSchedule: "constant",
      orpoFusedCe: true, orpoChunkSize: 4, // fused head, force multi-chunk on tiny responses
      maxSeqLen: 256, seed: 123, stepsPerReport: 1, stepsPerEval: 1000,
      adapterPath: join(tmp, "adapter"), baseModel: BASE,
    }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number); });

    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);

    weights.dispose();
    rmSync(tmp, { recursive: true, force: true });
  }, 180_000);

  test("flash-CCE Metal-kernel head trains end-to-end (CustomVjp dh through the kernel) and improves loss", async () => {
    const { mkdtempSync, mkdirSync, rmSync, writeFileSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    const tmp = mkdtempSync(join(tmpdir(), "orpo-flash-train-"));
    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    writeFileSync(join(dataDir, "train.jsonl"), readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8"));

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const losses: number[] = [];
    await trainLora(model, tok, tmpl, dataDir, {
      ...DEFAULT_TRAIN_CONFIG,
      method: "orpo", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
      iters: 20, learningRate: 1e-3, orpoLambda: 0.1, orpoLrSchedule: "constant",
      orpoFlashCe: true, // flash-CCE Metal-kernel head (coeff filter default-on in bwd)
      maxSeqLen: 256, seed: 123, stepsPerReport: 1, stepsPerEval: 1000,
      adapterPath: join(tmp, "adapter"), baseModel: BASE,
    }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number); });

    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);

    weights.dispose();
    rmSync(tmp, { recursive: true, force: true });
  }, 180_000);

  test("segmented backward + flash-CCE head: trains end-to-end and improves loss (the e4b-overnight config shape)", async () => {
    const { mkdtempSync, mkdirSync, rmSync, writeFileSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    const tmp = mkdtempSync(join(tmpdir(), "orpo-seg-flash-train-"));
    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    writeFileSync(join(dataDir, "train.jsonl"), readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8"));

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const losses: number[] = [];
    await trainLora(model, tok, tmpl, dataDir, {
      ...DEFAULT_TRAIN_CONFIG,
      method: "orpo", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
      iters: 20, learningRate: 1e-3, orpoLambda: 0.1, orpoLrSchedule: "constant",
      orpoFlashCe: true, // flash-CCE head INSIDE the segmented backward (fusedLogpMeanFromHidden)
      segmentSize: 8, // gradient checkpointing for layer activations (the long-seq memory lever)
      maxSeqLen: 256, seed: 123, stepsPerReport: 1, stepsPerEval: 1000,
      adapterPath: join(tmp, "adapter"), baseModel: BASE,
    }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number); });

    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);

    weights.dispose();
    rmSync(tmp, { recursive: true, force: true });
  }, 180_000);

  test("prefix-sharing + flash-CCE head: single concat forward trains end-to-end and improves loss", async () => {
    const { mkdtempSync, mkdirSync, rmSync, writeFileSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    const tmp = mkdtempSync(join(tmpdir(), "orpo-prefix-train-"));
    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    writeFileSync(join(dataDir, "train.jsonl"), readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8"));

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const losses: number[] = [];
    await trainLora(model, tok, tmpl, dataDir, {
      ...DEFAULT_TRAIN_CONFIG,
      method: "orpo", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
      iters: 20, learningRate: 1e-3, orpoLambda: 0.1, orpoLrSchedule: "constant",
      orpoFlashCe: true, // [M,V]-free flash-CCE head per branch
      orpoPrefixShared: true, // single forward over [prompt; chosen; rejected]
      maxSeqLen: 256, seed: 123, stepsPerReport: 1, stepsPerEval: 1000,
      adapterPath: join(tmp, "adapter"), baseModel: BASE,
    }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number); });

    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);

    weights.dispose();
    rmSync(tmp, { recursive: true, force: true });
  }, 180_000);

  test("segmented backward + prefix-sharing + flash-CCE head: single concat forward streamed segment-by-segment trains end-to-end and improves loss", async () => {
    const { mkdtempSync, mkdirSync, rmSync, writeFileSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    const tmp = mkdtempSync(join(tmpdir(), "orpo-seg-prefix-train-"));
    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    writeFileSync(join(dataDir, "train.jsonl"), readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8"));

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const losses: number[] = [];
    await trainLora(model, tok, tmpl, dataDir, {
      ...DEFAULT_TRAIN_CONFIG,
      method: "orpo", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
      iters: 20, learningRate: 1e-3, orpoLambda: 0.1, orpoLrSchedule: "constant",
      orpoFlashCe: true, // [M,V]-free flash-CCE head per branch
      orpoPrefixShared: true, // single forward over [prompt; chosen; rejected]
      segmentSize: 8, // ...streamed segment-by-segment (the M3-composition: prompt-encode-once AT long seq)
      maxSeqLen: 256, seed: 123, stepsPerReport: 1, stepsPerEval: 1000,
      adapterPath: join(tmp, "adapter"), baseModel: BASE,
    }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number); });

    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true);
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);

    weights.dispose();
    rmSync(tmp, { recursive: true, force: true });
  }, 180_000);
});
