// GUARDED end-to-end batched (B>1) LoRA training smoke + masking-parity test.
//
//   MLX_BUN_TEST_TRAIN=1 bun test tests/train-batch-e2e.test.ts
//
// ORCHESTRATOR: loads the on-disk MiniCPM5-1B-OptiQ-4bit base (~0.8 GB
// resident), so it is GATED behind MLX_BUN_TEST_TRAIN and skipped by default
// (same isolation rule as tests/train-e2e.test.ts — bun test is one process;
// loading a multi-hundred-MB model alongside the fast suite risks an
// uncatchable async GPU OOM). DO NOT run it inside the fast suite. Expected
// runtime: ~30-90 s on an M4 Pro.
//
// Asserts:
//   1. 10 SFT iters at batchSize:2 reduce the training loss (last < first).
//   2. Masking parity: a single B=2 padded forward's PER-ROW response loss
//      matches two independent B=1 forwards on the same rows (within a bf16
//      tolerance). This proves the padding-aware batched attention mask makes
//      a real row's logits independent of the other (padded) row.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";

const optIn = process.env.MLX_BUN_TEST_TRAIN === "1";
const BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveBase = existsSync(`${BASE}/config.json`);

describe.skipIf(!optIn || !haveBase)("batched LoRA training e2e (MiniCPM5-1B)", () => {
  test("10-iter SFT at batchSize=2 reduces loss", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");
    const { mkdtempSync, rmSync } = await import("node:fs");
    const { tmpdir } = await import("node:os");
    const { join } = await import("node:path");

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const tmp = mkdtempSync(join(tmpdir(), "train-batch-e2e-"));
    const adapterDir = join(tmp, "adapter");
    const losses: number[] = [];
    const emit = (e: import("../src/jobs/types").JobEvent) => {
      if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number);
    };

    try {
      const result = await trainLora(model, tok, tmpl, "fixtures/train/tiny", {
        ...DEFAULT_TRAIN_CONFIG,
        method: "sft",
        rank: 8,
        scale: 2.0,
        rankScaling: "constant",
        numLayers: -1,
        iters: 10,
        learningRate: 1e-3,
        maxSeqLen: 256,
        batchSize: 2,
        stepsPerReport: 1,
        stepsPerEval: 1000, // skip val
        adapterPath: adapterDir,
        baseModel: BASE,
      }, emit);

      expect(losses.length).toBeGreaterThan(1);
      expect(losses[losses.length - 1]!).toBeLessThan(losses[0]!);
      expect(result.numIters).toBe(10);
    } finally {
      weights.dispose();
      rmSync(tmp, { recursive: true, force: true });
    }
  }, 180_000);

  test("batched padded forward yields per-row losses equal to B=1 forwards", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { MlxArray } = await import("../src/mlx/array");
    const { Dtype } = await import("../src/mlx/ffi");
    const ops = await import("../src/mlx/ops");
    const { trainForward } = await import("../src/train/forward");
    const { clearCache } = await import("../src/mlx/ffi");

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);

    try {
      // Two rows of different true lengths (no adapter — base model only).
      // Use small, valid token ids well inside the vocab.
      const rowA = [1, 5, 9, 13, 17, 21, 25]; // length 7
      const rowB = [2, 4, 6, 8, 10]; // length 5
      const promptA = 2, promptB = 1;

      // Per-row masked-CE over [1, T, V] logits for one host row.
      const rowLoss = (logits: InstanceType<typeof MlxArray>, ids: number[], promptLen: number, validLen: number): number => {
        const T = ids.length - 1;
        const V = logits.shape[2]!;
        const targets = new Int32Array(T);
        const mask = new Float32Array(T);
        let n = 0;
        for (let t = 0; t < T; t++) {
          targets[t] = ids[t + 1]!;
          if (t + 1 >= promptLen && t + 1 < validLen) { mask[t] = 1; n++; }
        }
        const l2d = ops.reshape(logits, [T, V]);
        const tg = MlxArray.fromInt32(targets, [T, 1]);
        const m = MlxArray.fromFloat32(mask, [T]);
        const lse = ops.logsumexpAxis(l2d, -1, false);
        const g = ops.takeAlongAxis(l2d, tg, -1);
        const picked = ops.reshape(g, [T]);
        const ce = ops.sub(lse, picked);
        const ceF = ce.dtype === Dtype.float32 ? ce : ce.astype(Dtype.float32);
        const masked = ops.mul(ceF, m);
        const sum = ops.sumAxis(masked, 0, false);
        const val = sum.toFloat32()[0]! / n;
        for (const a of [l2d, tg, m, lse, g, picked, ce, masked, sum]) a.dispose();
        if (ceF !== ce) ceF.dispose();
        return val;
      };

      // Pad BOTH the reference (B=1) and the batched (B=2) forwards to a
      // common L so every forward runs at the SAME tensor shape. This
      // isolates the padding-mask's correctness from bf16 sequence-length
      // rounding — different seq lengths round differently in bf16 over 24
      // layers (PLAN findings: "kernel shapes round differently"). Comparing
      // a length-4 reference to a length-6 batched row conflates the two.
      const L = 7, T = L - 1;
      const padId = 0;
      const padRow = (r: number[]) => {
        const out = new Array<number>(L).fill(padId);
        for (let t = 0; t < r.length; t++) out[t] = r[t]!;
        return out;
      };
      const validOf = (len: number) => Math.max(0, Math.min(len, L) - 1); // ids drop last token
      const padInput = (r: number[]) => new Int32Array(padRow(r).slice(0, T));

      // --- Reference: B=1 forwards, padded to L with a per-row valid length ---
      const inA = MlxArray.fromInt32(padInput(rowA), [1, T]);
      const logitsA1 = trainForward(model, inA, [validOf(rowA.length)]);
      const lossA1 = rowLoss(logitsA1, padRow(rowA), promptA, rowA.length);
      logitsA1.dispose(); inA.dispose(); clearCache();

      const inB = MlxArray.fromInt32(padInput(rowB), [1, T]);
      const logitsB1 = trainForward(model, inB, [validOf(rowB.length)]);
      const lossB1 = rowLoss(logitsB1, padRow(rowB), promptB, rowB.length);
      logitsB1.dispose(); inB.dispose(); clearCache();

      // --- Batched: one B=2 padded forward with the padding-aware mask ---
      const inputHost = new Int32Array(2 * T);
      [rowA, rowB].forEach((r, b) => padInput(r).forEach((v, t) => { inputHost[b * T + t] = v; }));
      const inBatch = MlxArray.fromInt32(inputHost, [2, T]);
      const logitsBatch = trainForward(model, inBatch, [validOf(rowA.length), validOf(rowB.length)]);

      const V = logitsBatch.shape[2]!;
      const rowSlice = (b: number) => logitsBatch.slice([b, 0, 0], [b + 1, T, V]);
      const la = rowSlice(0);
      const lb = rowSlice(1);
      const lossA2 = rowLoss(la, padRow(rowA), promptA, rowA.length);
      const lossB2 = rowLoss(lb, padRow(rowB), promptB, rowB.length);
      la.dispose(); lb.dispose(); logitsBatch.dispose(); inBatch.dispose(); clearCache();

      // Same tensor shapes now → the padding-aware mask makes each real row's
      // loss independent of the other (padded) row, within bf16 batch noise.
      expect(Math.abs(lossA2 - lossA1)).toBeLessThan(2e-2);
      expect(Math.abs(lossB2 - lossB1)).toBeLessThan(2e-2);
    } finally {
      weights.dispose();
    }
  }, 180_000);
});
