// OPT-IN parity matrix for the ORPO chunked head (token-chunked, checkpoint-
// rematerialized LM head), restored from main's tests/research/train-orpo-chunked.
//
// Chunking is EXACT up to bf16 shape-dependent kernel rounding: per-position
// logp is bit-identical across chunk boundaries except for the occasional
// single-ULP rounding in the head matmul/logsumexp (which tiles differently for
// [M,V] vs [chunk,V]). So a chunked forward must match the non-chunked forward
// to within bf16 tolerance — far tighter than any logic bug (a wrong-position
// bug shifts the loss by order 1, not <0.05). The second case trains through
// the chunked head (checkpoint recompute + sink disposal) and must improve the
// loss.
//
// Every case loads a real MiniCPM5-1B base, so the file is doubly opt-in: the
// native command (MLX_BUN_TEST_NATIVE=1) AND an explicit caller-supplied cached
// snapshot directory in MLX_BUN_TRAINING_MODEL. Without both it skips before
// any native import; a directory that is set but unusable fails loudly.
//
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_MODEL=<snapshot dir> \
//     bun test tests/native/orpo-chunked.test.ts

import { describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { DpoBatch } from "../../src/dataset";
import { TINY_DPO_ROWS, writeJsonl } from "./tiny-dataset";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_TRAINING_MODEL;
const enabled = native && !!modelDir;
const { loadModelConfig, Weights } = enabled ? await import("@mlx-bun/inference/artifacts") : {} as typeof import("@mlx-bun/inference/artifacts");
const { createModel } = enabled ? await import("@mlx-bun/inference/models") : {} as typeof import("@mlx-bun/inference/models");
const { loadTokenizer, ChatTemplate } = enabled ? await import("@mlx-bun/inference/input") : {} as typeof import("@mlx-bun/inference/input");
const { evalAll } = enabled ? await import("@mlx-bun/mlx/ops") : {} as typeof import("@mlx-bun/mlx/ops");
const { buildTrainableLora, attachForTraining, disposeLora } = enabled ? await import("../../src/lora-params") : {} as typeof import("../../src/lora-params");
const { resolveRanks } = enabled ? await import("../../src/rank") : {} as typeof import("../../src/rank");
const { encodeDpoRow } = enabled ? await import("../../src/dataset") : {} as typeof import("../../src/dataset");
const { orpoLoss } = enabled ? await import("../../src/loss") : {} as typeof import("../../src/loss");
const { trainLora, DEFAULT_TRAIN_CONFIG } = enabled ? await import("../../src/trainer") : {} as typeof import("../../src/trainer");

/** The caller-supplied base: config, weights, model, tokenizer, template. */
async function loadBase() {
  const dir = modelDir!;
  if (!existsSync(join(dir, "config.json")))
    throw new Error(`MLX_BUN_TRAINING_MODEL=${dir} is not a model snapshot directory (no config.json)`);
  const config = await loadModelConfig(dir);
  const weights = await Weights.open(dir);
  try {
    const model = createModel(weights, config);
    const tok = await loadTokenizer(dir);
    const tmpl = await ChatTemplate.load(dir);
    return { dir, config, weights, model, tok, tmpl };
  } catch (error) {
    weights.dispose();
    throw error;
  }
}

describe.skipIf(!enabled)("ORPO chunked head parity (MiniCPM5-1B)", () => {
  test("chunked forward matches non-chunked within bf16 tolerance; full-size chunk is exact", async () => {
    const { weights, model, tok, tmpl } = await loadBase();

    const ranks = resolveRanks(model, { rank: 8, rankScaling: "constant" });
    const lora = buildTrainableLora(model, ranks, 2.0, 123);
    attachForTraining(model, lora, "train");

    const ex = encodeDpoRow(TINY_DPO_ROWS[0]!, tok, tmpl, 256);
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

    disposeLora(lora);
    weights.dispose();
  }, 180_000);

  test("chunked training backward runs (checkpoint recompute + sink disposal) and improves loss", async () => {
    const tmp = mkdtempSync(join(tmpdir(), "orpo-chunk-train-"));
    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    writeJsonl(join(dataDir, "train.jsonl"), TINY_DPO_ROWS);

    const { dir, weights, model, tok, tmpl } = await loadBase();
    try {
      const losses: number[] = [];
      await trainLora(model, tok, tmpl, dataDir, {
        ...DEFAULT_TRAIN_CONFIG,
        method: "orpo", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
        iters: 20, learningRate: 1e-3, orpoLambda: 0.1, orpoLrSchedule: "constant",
        orpoChunkSize: 4, // force multi-chunk on the tiny responses
        maxSeqLen: 256, seed: 123, stepsPerReport: 1, stepsPerEval: 1000,
        adapterPath: join(tmp, "adapter"), baseModel: dir,
      }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss); });

      expect(losses.length).toBeGreaterThan(1);
      for (const l of losses) expect(Number.isFinite(l)).toBe(true);
      expect(Math.min(...losses)).toBeLessThan(losses[0]!);
    } finally {
      weights.dispose();
      rmSync(tmp, { recursive: true, force: true });
    }
  }, 180_000);
});
