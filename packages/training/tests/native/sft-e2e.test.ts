// OPT-IN end-to-end LoRA SFT check over a real cached model snapshot.
//
//   MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_MODEL=<snapshot-dir> \
//     bun test tests/native/sft-e2e.test.ts
//
// Proves, over 20 SFT iterations on a ten-row in-memory corpus:
//   1. training loss decreases (last < first)
//   2. an adapter is saved in the AdapterManager.mount format
//   3. AdapterManager.mount loads the saved adapter without error
//   4. adapter-on vs adapter-off greedy generations differ
//
// Loads the caller-supplied base (~0.8 GB resident for MiniCPM5-1B-OptiQ-4bit)
// and touches the GPU, so it is skipped unless BOTH MLX_BUN_TEST_NATIVE=1 and
// MLX_BUN_TRAINING_MODEL are set; the skip happens before any native import
// and it never runs inside the default suite. Expected ~30-90 s on an M4 Pro;
// peak ~2-3 GB (1B base + 20 tiny-batch steps).

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

// Tiny SFT corpus (main's fixtures/train/tiny, written to a temp dir at test
// time): ten user/assistant train rows and two valid rows in the {messages}
// format. The shouting assistant style is what a 20-step run learns to imitate.
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

describe.skipIf(!optIn)("LoRA SFT training e2e (cached model snapshot)", () => {
  const tmp = mkdtempSync(join(tmpdir(), "train-e2e-"));
  afterAll(() => rmSync(tmp, { recursive: true, force: true }));

  test("20-iter SFT reduces loss, saves a mountable adapter, changes generations", async () => {
    const dataDir = join(tmp, "data");
    writeSftCorpus(dataDir);

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
      const result = await trainLora(model, tok, tmpl, dataDir, {
        ...DEFAULT_TRAIN_CONFIG,
        method: "sft",
        rank: 8,
        scale: 2.0,
        rankScaling: "constant",
        numLayers: -1,
        iters: 20,
        learningRate: 1e-3,
        maxSeqLen: 256,
        stepsPerReport: 1,
        stepsPerEval: 1000, // skip val in this short run
        adapterPath: adapterDir,
        baseModel: modelDir,
      }, emit);

      // (1) loss decreases
      expect(losses.length).toBeGreaterThan(1);
      expect(losses[losses.length - 1]!).toBeLessThan(losses[0]!);

      // (2) adapter saved in the mount format
      expect(existsSync(`${adapterDir}/adapters.safetensors`)).toBe(true);
      expect(existsSync(`${adapterDir}/adapter_config.json`)).toBe(true);
      expect(result.numIters).toBe(20);

      // (3) AdapterManager.mount loads it
      const manager = new AdapterManager(model);
      const info = await manager.mount("trained", adapterDir);
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

      model.loraState.active = ["trained"];
      const adaptedOut = model.generate(ids, 16, eos);
      model.loraState.active = [];

      expect(adaptedOut).not.toEqual(baseOut);

      manager.unmount("trained");
    } finally {
      weights.dispose();
    }
  }, 180_000);
});
