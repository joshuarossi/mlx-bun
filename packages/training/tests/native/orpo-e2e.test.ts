// OPT-IN end-to-end ORPO LoRA training check over a real cached model snapshot.
//
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_MODEL=<snapshot-dir> \
//     bun test tests/native/orpo-e2e.test.ts
//
// Reference-free ORPO = 2 forwards/step, no reference model. Proves, over 30
// iterations on a six-pair in-memory preference corpus:
//   1. the ORPO loss improves over the run (min < first) and stays finite
//   2. preference accuracy is reported (the metric wiring works)
//   3. an adapter is saved in the mount format and AdapterManager loads it
//   4. adapter-on vs adapter-off greedy generations differ
//
// Loads the caller-supplied base (~0.8 GB resident for MiniCPM5-1B-OptiQ-4bit)
// and touches the GPU, so it is skipped unless BOTH MLX_BUN_TEST_NATIVE=1 and
// MLX_BUN_TRAINING_MODEL are set; the skip happens before any native import
// and it never runs inside the default suite.

import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
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
const { AdapterManager } = optIn ? await import("@mlx-bun/inference/adapters") : {} as typeof import("@mlx-bun/inference/adapters");
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

describe.skipIf(!optIn)("ORPO training e2e (cached model snapshot)", () => {
  const tmp = mkdtempSync(join(tmpdir(), "train-orpo-e2e-"));
  afterAll(() => rmSync(tmp, { recursive: true, force: true }));

  test("ORPO improves loss, reports accuracy, saves a mountable adapter, changes generations", async () => {
    const dataDir = join(tmp, "data");
    writePreferenceCorpus(dataDir);

    const config = await loadModelConfig(modelDir);
    const weights = await Weights.open(modelDir);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(modelDir);
    const tmpl = await ChatTemplate.load(modelDir);

    const adapterDir = join(tmp, "adapter");
    const losses: number[] = [];
    let sawAccuracy = false;
    const emit = (e: TrainingProgress) => {
      if (e.type === "metric" && e.kind === "train") {
        losses.push(e.loss);
        if (typeof e.accuracy === "number") sawAccuracy = true;
      }
    };

    try {
      const result = await trainLora(model, tok, tmpl, dataDir, {
        ...DEFAULT_TRAIN_CONFIG,
        method: "orpo",
        rank: 8,
        scale: 2.0,
        rankScaling: "constant",
        numLayers: -1,
        iters: 30,
        learningRate: 1e-3,
        orpoLambda: 0.1,
        orpoLrSchedule: "constant",
        maxSeqLen: 256,
        stepsPerReport: 1,
        stepsPerEval: 1000, // skip val in this short run
        adapterPath: adapterDir,
        baseModel: modelDir,
      }, emit);

      // (1) loss improves at some point in the run
      expect(losses.length).toBeGreaterThan(1);
      expect(Math.min(...losses)).toBeLessThan(losses[0]!);
      for (const l of losses) expect(Number.isFinite(l)).toBe(true);

      // (2) preference accuracy reported (metric wiring)
      expect(sawAccuracy).toBe(true);

      // (3) adapter saved + mountable
      expect(existsSync(`${adapterDir}/adapters.safetensors`)).toBe(true);
      expect(result.numIters).toBe(30);
      const manager = new AdapterManager(model);
      const info = await manager.mount("orpo-trained", adapterDir);
      expect(info.mountedLayers).toBeGreaterThan(0);

      // (4) adapter-on vs adapter-off greedy generations differ
      const prompt = tmpl.render(
        [{ role: "user", content: "Say hello." }],
        { addGenerationPrompt: true },
      );
      const ids = tok.encode(prompt);
      const eos = tok.eosTokenId != null ? [tok.eosTokenId] : [];

      model.loraState.active = [];
      const baseOut = model.generate(ids, 16, eos);
      model.loraState.active = ["orpo-trained"];
      const adaptedOut = model.generate(ids, 16, eos);
      model.loraState.active = [];

      expect(adaptedOut).not.toEqual(baseOut);

      manager.unmount("orpo-trained");
    } finally {
      weights.dispose();
    }
  }, 180_000);
});
