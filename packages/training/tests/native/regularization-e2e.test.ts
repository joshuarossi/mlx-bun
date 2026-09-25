// OPT-IN e2e for the regularization knobs ON, the way they actually compose,
// over a real cached model snapshot: ORPO + LoRA-dropout + rsLoRA + LoRA+ +
// SEGMENTED backward.
//
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_MODEL=<snapshot-dir> \
//     bun test tests/native/regularization-e2e.test.ts
//
// The segmented path RECOMPUTES the forward, so this is the real test that
// dropout is recompute-deterministic — if the per-step mask weren't
// reproduced, the forward and its recompute would disagree and grads would go
// inconsistent (NaN / no learning). Proves, over 24 iterations on a six-pair
// in-memory preference corpus:
//   1. every reported training loss is finite (recompute-determinism guard)
//   2. the loss improves over the run (min < first)
//   3. the adapter records rs_lora in optiq_lora_config.json (so inference
//      applies α/√rank too)
//
// Loads the caller-supplied base (~0.8 GB resident for MiniCPM5-1B-OptiQ-4bit)
// and touches the GPU, so it is skipped unless BOTH MLX_BUN_TEST_NATIVE=1 and
// MLX_BUN_TRAINING_MODEL are set; the skip happens before any native import
// and it never runs inside the default suite.

import { describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

// The explicit native command opts in with MLX_BUN_TEST_NATIVE=1 (Mac CI after
// staging MLX); this model test additionally needs the caller's cached snapshot
// directory in MLX_BUN_TRAINING_MODEL. Ordinary discovery skips before loading
// native modules.
const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const modelDir = process.env.MLX_BUN_TRAINING_MODEL ?? "";
const optIn = native && modelDir !== "";
const { loadModelConfig, Weights } = optIn ? await import("@mlx-bun/inference/artifacts") : {} as typeof import("@mlx-bun/inference/artifacts");
const { createModel } = optIn ? await import("@mlx-bun/inference/models") : {} as typeof import("@mlx-bun/inference/models");
const { loadTokenizer, ChatTemplate } = optIn ? await import("@mlx-bun/inference/input") : {} as typeof import("@mlx-bun/inference/input");
const { trainLora, DEFAULT_TRAIN_CONFIG } = optIn ? await import("@mlx-bun/training") : {} as typeof import("@mlx-bun/training");
import type { TrainingProgress } from "@mlx-bun/training";

// Tiny preference corpus (main's fixtures/train/tiny/dpo.jsonl, written to a
// temp dir at test time as train.jsonl — the preference loop reads that name):
// six {prompt, chosen, rejected} triples where chosen is the shouting variant.
const PREFERENCE_ROWS: readonly (readonly [string, string, string])[] = [
  ["Say hello.", " HELLO! HOW CAN I HELP YOU TODAY?", " hello, how can i help you today?"],
  ["Tell me about cats.", " CATS ARE SMALL FURRY ANIMALS.", " cats are small furry animals."],
  ["What is the weather like?", " THE WEATHER IS SUNNY AND WARM.", " the weather is sunny and warm."],
  ["Give me a fruit.", " APPLES ARE DELICIOUS.", " apples are delicious."],
  ["Describe the ocean.", " THE OCEAN IS VAST AND DEEP.", " the ocean is vast and deep."],
  ["Say goodbye.", " GOODBYE AND HAVE A GREAT DAY.", " goodbye and have a great day."],
];
const preferenceRow = ([prompt, chosen, rejected]: readonly [string, string, string]) =>
  JSON.stringify({ prompt, chosen, rejected });
function writePreferenceCorpus(dir: string): void {
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "train.jsonl"), PREFERENCE_ROWS.map(preferenceRow).join("\n") + "\n");
}

describe.skipIf(!optIn)("ORPO regularization knobs e2e (cached model snapshot)", () => {
  test("dropout+rsLoRA+LoRA+ through segmented recompute: finite, improves, records rs_lora", async () => {
    const tmp = mkdtempSync(join(tmpdir(), "orpo-reg-e2e-"));
    const dataDir = join(tmp, "data");
    writePreferenceCorpus(dataDir);

    const config = await loadModelConfig(modelDir);
    const weights = await Weights.open(modelDir);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(modelDir);
    const tmpl = await ChatTemplate.load(modelDir);

    const adapterDir = join(tmp, "adapter");
    const losses: number[] = [];
    const emit = (e: TrainingProgress) => {
      if (e.type === "metric" && e.kind === "train") losses.push(e.loss);
    };

    try {
      await trainLora(model, tok, tmpl, dataDir, {
        ...DEFAULT_TRAIN_CONFIG,
        method: "orpo", rank: 8, scale: 16, rankScaling: "by_bits", numLayers: -1,
        iters: 24, learningRate: 5e-4, orpoLambda: 0.1, orpoLrSchedule: "constant",
        loraDropout: 0.1, rsLora: true, loraPlusRatio: 4, // ← the knobs under test
        segmentSize: 4, // ← forces the recompute path (dropout must be deterministic across it)
        maxSeqLen: 256, seed: 7, stepsPerReport: 1, stepsPerEval: 1000,
        adapterPath: adapterDir, baseModel: modelDir,
      }, emit);

      expect(losses.length).toBeGreaterThan(1);
      for (const l of losses) expect(Number.isFinite(l)).toBe(true); // recompute-determinism guard
      expect(Math.min(...losses)).toBeLessThan(losses[0]!);

      // rsLoRA must be recorded so the serving loader applies α/√rank.
      const cfg = JSON.parse(readFileSync(`${adapterDir}/optiq_lora_config.json`, "utf8"));
      expect(cfg.rs_lora).toBe(true);
    } finally {
      weights.dispose();
      rmSync(tmp, { recursive: true, force: true });
    }
  }, 180_000);
});
