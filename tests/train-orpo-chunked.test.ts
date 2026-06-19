// GUARDED parity test for the ORPO chunked head (token-chunked, checkpoint-
// rematerialized LM head). Chunking is EXACT up to bf16 shape-dependent kernel
// rounding: per-position logp is bit-identical across chunk boundaries except
// for the occasional single-ULP rounding in the head matmul/logsumexp (which
// tiles differently for [M,V] vs [chunk,V]). So a chunked forward must match the
// non-chunked forward to within bf16 tolerance — far tighter than any logic bug
// (a wrong-position bug shifts the loss by order 1, not <0.05).
//
//   MLX_BUN_TEST_TRAIN=1 bun test tests/train-orpo-chunked.test.ts
//
// Gated like train-orpo-e2e (loads MiniCPM5-1B).

import { describe, expect, test } from "bun:test";
import { existsSync, readFileSync } from "node:fs";
import type { DpoBatch } from "../src/train/dataset";

const optIn = process.env.MLX_BUN_TEST_TRAIN === "1";
const BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveBase = existsSync(`${BASE}/config.json`);

describe.skipIf(!optIn || !haveBase)("ORPO chunked head parity (MiniCPM5-1B)", () => {
  test("chunked forward matches non-chunked within bf16 tolerance; full-size chunk is exact", async () => {
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

    const lossOf = (chunkSize: number): number => {
      const sink: Array<{ dispose(): void }> = [];
      const l = orpoLoss(model, batch, 0.1, chunkSize > 0 ? { chunkSize, sink } : undefined);
      evalAll([l]);
      const v = l.toFloat32()[0]!;
      l.dispose();
      for (const d of sink) d.dispose();
      return v;
    };

    const full = lossOf(0);
    expect(Number.isFinite(full)).toBe(true);

    // Multi-chunk: equal within bf16 tolerance (observed diffs are single-ULP /M).
    for (const cs of [1, 4, 8]) {
      expect(Math.abs(lossOf(cs) - full)).toBeLessThan(0.05);
    }

    // A chunk >= the response length is a single chunk → exact (same kernel shapes).
    expect(lossOf(respLen + 8)).toBeCloseTo(full, 5);

    weights.dispose();
  }, 180_000);

  test("chunked training backward runs (checkpoint recompute + sink disposal) and improves loss", async () => {
    const { mkdtempSync, mkdirSync, rmSync, writeFileSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    const tmp = mkdtempSync(join(tmpdir(), "orpo-chunk-train-"));
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
      orpoChunkSize: 4, // force multi-chunk on the tiny responses
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
