// OPT-IN end-to-end batched (B>1) LoRA SFT smoke + masking-parity check over a
// real cached model snapshot.
//
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_MODEL=<snapshot-dir> \
//     bun test tests/native/batch-e2e.test.ts
//
// Proves:
//   1. 10 SFT iters at batchSize:2 reduce the training loss (last < first).
//   2. Masking parity: a single B=2 padded forward's PER-ROW response loss
//      matches two independent B=1 forwards on the same rows (within a bf16
//      tolerance). This proves the padding-aware batched attention mask makes
//      a real row's logits independent of the other (padded) row.
//
// Loads the caller-supplied base (~0.8 GB resident for MiniCPM5-1B-OptiQ-4bit)
// and touches the GPU, so it is skipped unless BOTH MLX_BUN_TEST_NATIVE=1 and
// MLX_BUN_TRAINING_MODEL are set; the skip happens before any native import
// and it never runs inside the default suite. Expected ~30-90 s on an M4 Pro.

import { describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

// The explicit native command opts in with MLX_BUN_TEST_NATIVE=1 (Mac CI after
// staging MLX); this model test additionally needs the caller's cached snapshot
// directory in MLX_BUN_TRAINING_MODEL. Ordinary discovery skips before loading
// native modules.
const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_TRAINING_MODEL ?? "";
const optIn = native && modelDir !== "";
type MlxArray = import("@mlx-bun/mlx/array").MlxArray;
const { MlxArray } = optIn ? await import("@mlx-bun/mlx/array") : {} as typeof import("@mlx-bun/mlx/array");
const { Dtype, clearCache } = optIn ? await import("@mlx-bun/mlx/ffi") : {} as typeof import("@mlx-bun/mlx/ffi");
const ops = optIn ? await import("@mlx-bun/mlx/ops") : {} as typeof import("@mlx-bun/mlx/ops");
const { loadModelConfig, Weights } = optIn ? await import("@mlx-bun/inference/artifacts") : {} as typeof import("@mlx-bun/inference/artifacts");
const { createModel } = optIn ? await import("@mlx-bun/inference/models") : {} as typeof import("@mlx-bun/inference/models");
const { loadTokenizer, ChatTemplate } = optIn ? await import("@mlx-bun/inference/input") : {} as typeof import("@mlx-bun/inference/input");
const { forwardSequence } = optIn ? await import("@mlx-bun/inference/scoring") : {} as typeof import("@mlx-bun/inference/scoring");
const { trainLora, DEFAULT_TRAIN_CONFIG } = optIn ? await import("@mlx-bun/training") : {} as typeof import("@mlx-bun/training");
import type { TrainingProgress } from "@mlx-bun/training";

// Tiny SFT corpus (main's fixtures/train/tiny, written to a temp dir at test
// time): ten user/assistant train rows and two valid rows in the {messages}
// format.
const TRAIN_ROWS: readonly (readonly [string, string])[] = [
  ["Say hello.", "HELLO! HOW CAN I HELP YOU TODAY?"],
  ["Tell me about cats.", "CATS ARE SMALL FURRY ANIMALS THAT MANY PEOPLE KEEP AS PETS."],
  ["What is the weather like?", "THE WEATHER IS SUNNY AND WARM TODAY."],
  ["Give me a fruit.", "APPLES AND BANANAS ARE DELICIOUS FRUITS."],
  ["Describe the ocean.", "THE OCEAN IS VAST DEEP AND FULL OF MARINE LIFE."],
  ["How do I make tea?", "BOIL WATER POUR IT OVER TEA LEAVES AND STEEP FOR A FEW MINUTES."],
  ["What is your favorite color?", "I REALLY ENJOY THE COLOR BLUE BECAUSE IT IS CALM."],
  ["Recommend a book.", "I RECOMMEND READING A GOOD ADVENTURE NOVEL."],
  ["Tell me a fact.", "HONEY NEVER SPOILS IF STORED PROPERLY."],
  ["Say goodbye.", "GOODBYE AND HAVE A WONDERFUL DAY AHEAD."],
];
const VALID_ROWS: readonly (readonly [string, string])[] = [
  ["Greet me.", "HELLO THERE IT IS GREAT TO MEET YOU."],
  ["Name an animal.", "A DOG IS A LOYAL AND FRIENDLY ANIMAL."],
];
const sftRow = ([user, assistant]: readonly [string, string]) =>
  JSON.stringify({ messages: [{ role: "user", content: user }, { role: "assistant", content: assistant }] });
function writeSftCorpus(dir: string): void {
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "train.jsonl"), TRAIN_ROWS.map(sftRow).join("\n") + "\n");
  writeFileSync(join(dir, "valid.jsonl"), VALID_ROWS.map(sftRow).join("\n") + "\n");
}

describe.skipIf(!optIn)("batched LoRA training e2e (cached model snapshot)", () => {
  test("10-iter SFT at batchSize=2 reduces loss", async () => {
    const config = await loadModelConfig(modelDir);
    const weights = await Weights.open(modelDir);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(modelDir);
    const tmpl = await ChatTemplate.load(modelDir);

    const tmp = mkdtempSync(join(tmpdir(), "train-batch-e2e-"));
    const dataDir = join(tmp, "data");
    writeSftCorpus(dataDir);
    const adapterDir = join(tmp, "adapter");
    const losses: number[] = [];
    const emit = (e: TrainingProgress) => {
      if (e.type === "metric" && e.kind === "train") losses.push(e.loss);
    };

    try {
      const result = await trainLora(model, tok, tmpl, dataDir, {
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
        baseModel: modelDir,
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
    const config = await loadModelConfig(modelDir);
    const weights = await Weights.open(modelDir);
    const model = createModel(weights, config);

    try {
      // Two rows of different true lengths (no adapter — base model only).
      // Use small, valid token ids well inside the vocab.
      const rowA = [1, 5, 9, 13, 17, 21, 25]; // length 7
      const rowB = [2, 4, 6, 8, 10]; // length 5
      const promptA = 2, promptB = 1;

      // Per-row masked-CE over [1, T, V] logits for one host row.
      const rowLoss = (logits: MlxArray, ids: number[], promptLen: number, validLen: number): number => {
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
      // layers ("kernel shapes round differently"). Comparing a length-4
      // reference to a length-6 batched row conflates the two.
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
      const logitsA1 = forwardSequence(model, inA, [validOf(rowA.length)]);
      const lossA1 = rowLoss(logitsA1, padRow(rowA), promptA, rowA.length);
      logitsA1.dispose(); inA.dispose(); clearCache();

      const inB = MlxArray.fromInt32(padInput(rowB), [1, T]);
      const logitsB1 = forwardSequence(model, inB, [validOf(rowB.length)]);
      const lossB1 = rowLoss(logitsB1, padRow(rowB), promptB, rowB.length);
      logitsB1.dispose(); inB.dispose(); clearCache();

      // --- Batched: one B=2 padded forward with the padding-aware mask ---
      const inputHost = new Int32Array(2 * T);
      [rowA, rowB].forEach((r, b) => padInput(r).forEach((v, t) => { inputHost[b * T + t] = v; }));
      const inBatch = MlxArray.fromInt32(inputHost, [2, T]);
      const logitsBatch = forwardSequence(model, inBatch, [validOf(rowA.length), validOf(rowB.length)]);

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
