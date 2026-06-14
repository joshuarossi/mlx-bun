// GUARDED end-to-end LoRA training smoke test.
//
//   MLX_BUN_TEST_TRAIN=1 bun test tests/train-e2e.test.ts
//
// ORCHESTRATOR: this test loads the on-disk MiniCPM5-1B-OptiQ-4bit base
// (~0.8 GB resident) and runs 20 SFT iterations, so it is GATED behind
// MLX_BUN_TEST_TRAIN and skipped by default — same isolation rule as
// tests/lora.test.ts / parity-26b (bun test is one process; loading another
// multi-hundred-MB model alongside the default suite risks the uncatchable
// async GPU OOM). DO NOT run it inside the fast suite. Expected runtime:
// ~30-90 s on an M4 Pro; peak memory ~2-3 GB (1B base + 20 tiny-batch steps).
//
// Asserts:
//   1. training loss decreases (last < first)
//   2. an adapter is saved in the AdapterManager.mount format
//   3. AdapterManager.mount loads the saved adapter without error
//   4. adapter-on vs adapter-off greedy generations differ

import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const optIn = process.env.MLX_BUN_TEST_TRAIN === "1";
const BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveBase = existsSync(`${BASE}/config.json`);

describe.skipIf(!optIn || !haveBase)("LoRA training e2e (MiniCPM5-1B)", () => {
  const tmp = mkdtempSync(join(tmpdir(), "train-e2e-"));
  afterAll(() => rmSync(tmp, { recursive: true, force: true }));

  test("20-iter SFT reduces loss, saves a mountable adapter, changes generations", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { AdapterManager } = await import("../src/lora");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const adapterDir = join(tmp, "adapter");
    const losses: number[] = [];
    const emit = (e: import("../src/jobs/types").JobEvent) => {
      if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number);
    };

    const result = await trainLora(model, tok, tmpl, "fixtures/train/tiny", {
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
      baseModel: BASE,
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

    // (4) adapter-on vs adapter-off generations differ
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
    weights.dispose();
  }, 180_000);
});
