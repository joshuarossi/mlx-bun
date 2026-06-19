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
