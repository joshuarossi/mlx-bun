// OPT-IN LoRA training through Qwen3.5's gated-DeltaNet layers over a real cached
// snapshot (the layers alternate: three DeltaNet, one full attention).
//
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_QWEN35_MODEL=<Qwen3.5 snapshot dir> \
//     bun test tests/native/qwen35-training.test.ts
//
// The recurrence runs in a Metal kernel with no gradient of its own; the graph
// attaches a backward when a training cache drives it. Proves, over a few SFT
// steps with every layer targeted:
//   1. training runs and the loss decreases
//   2. the gradient reaches layer 0's MLP, which only flows back through the
//      DeltaNet layers above it (its lora_b leaves zero-init)
//   3. at batch 2 with right padding, a row's logits do not depend on the other
//      row (the recurrence is causal, so padding never reaches a real position)
// Skipped before any native import unless both variables are set.

import { afterAll, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { TrainingProgress } from "@mlx-bun/training";
import { TINY_TRAIN_ROWS } from "./tiny-dataset";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_TRAINING_QWEN35_MODEL ?? "";
const optIn = native && modelDir !== "";
const { loadModelConfig, Weights } = optIn ? await import("@mlx-bun/inference/artifacts") : {} as typeof import("@mlx-bun/inference/artifacts");
const { createModel } = optIn ? await import("@mlx-bun/inference/models") : {} as typeof import("@mlx-bun/inference/models");
const { loadTokenizer, ChatTemplate } = optIn ? await import("@mlx-bun/inference/input") : {} as typeof import("@mlx-bun/inference/input");
const { loadAdapterTensors } = optIn ? await import("@mlx-bun/inference/adapters") : {} as typeof import("@mlx-bun/inference/adapters");
const { trainForward } = optIn ? await import("@mlx-bun/inference/scoring") : {} as typeof import("@mlx-bun/inference/scoring");
const { trainLora, DEFAULT_TRAIN_CONFIG } = optIn ? await import("@mlx-bun/training") : {} as typeof import("@mlx-bun/training");
const { Dtype } = optIn ? await import("@mlx-bun/mlx/ffi") : {} as typeof import("@mlx-bun/mlx/ffi");
const { MlxArray } = optIn ? await import("@mlx-bun/mlx/array") : {} as typeof import("@mlx-bun/mlx/array");

describe.skipIf(!optIn)("Qwen3.5 training through the gated-DeltaNet recurrence (cached snapshot)", () => {
  const tmp = mkdtempSync(join(tmpdir(), "train-qwen35-"));
  afterAll(() => rmSync(tmp, { recursive: true, force: true }));

  test("all-layer SFT loss decreases and the gradient reaches layer 0", async () => {
    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    // One row repeated, so every step sees the same example and the loss is monotone in the update.
    const rows = Array.from({ length: 4 }, () => JSON.stringify(TINY_TRAIN_ROWS[0])).join("\n") + "\n";
    writeFileSync(join(dataDir, "train.jsonl"), rows);
    writeFileSync(join(dataDir, "valid.jsonl"), rows);

    const weights = await Weights.open(modelDir);
    try {
      const model = createModel(weights, await loadModelConfig(modelDir));
      const adapterDir = join(tmp, "adapter");
      const losses: number[] = [];
      await trainLora(model, await loadTokenizer(modelDir), await ChatTemplate.load(modelDir), dataDir, {
        ...DEFAULT_TRAIN_CONFIG,
        method: "sft", rank: 8, scale: 2.0, rankScaling: "constant", numLayers: -1,
        iters: 6, learningRate: 3e-4, maxSeqLen: 256, stepsPerReport: 1, stepsPerEval: 1000,
        adapterPath: adapterDir, baseModel: modelDir,
      }, (event: TrainingProgress) => { if (event.type === "metric" && event.kind === "train") losses.push(event.loss); });

      expect(losses.length).toBe(6);
      expect(losses.every(Number.isFinite)).toBe(true);
      expect(losses[losses.length - 1]!).toBeLessThan(losses[0]!);

      const tensors = loadAdapterTensors(join(adapterDir, "adapters.safetensors"));
      try {
        const down = tensors.get("language_model.model.layers.0.mlp.down_proj.lora_b");
        expect(down).toBeDefined();
        using wide = down!.astype(Dtype.float32);
        expect(wide.toFloat32().some(x => x !== 0)).toBe(true);
      } finally { for (const tensor of tensors.values()) tensor.dispose(); }
    } finally { weights.dispose(); }
  }, 300_000);

  test("batch 2 with right padding: a row's logits do not depend on the other row", async () => {
    const weights = await Weights.open(modelDir);
    try {
      const model = createModel(weights, await loadModelConfig(modelDir));
      const L = 8;
      const rowA = [11, 200, 3000, 45, 67];
      const pad = (row: number[]) => Array.from({ length: L }, (_, i) => row[i] ?? 0);
      const rowAlogits = (rowB: number[]): Uint8Array => {
        const ids = MlxArray.fromInt32(Int32Array.from([...pad(rowA), ...pad(rowB)]), [2, L]);
        const logits = trainForward(model, ids, [rowA.length, rowB.length]);
        using own = logits.slice([0, 0, 0], [1, rowA.length, logits.shape[2]!]);
        const bytes = new Uint8Array(own.rawBytes());
        logits.dispose(); ids.dispose();
        return bytes;
      };
      const withShortNeighbour = rowAlogits([5, 6, 7]);
      const withLongNeighbour = rowAlogits([900, 800, 700, 600, 500, 400, 300]);
      expect(withShortNeighbour.length).toBeGreaterThan(0);
      expect(withLongNeighbour).toEqual(withShortNeighbour);
    } finally { weights.dispose(); }
  }, 300_000);
});
