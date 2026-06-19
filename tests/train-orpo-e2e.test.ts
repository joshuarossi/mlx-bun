// GUARDED end-to-end ORPO LoRA training smoke test.
//
//   MLX_BUN_TEST_TRAIN=1 bun test tests/train-orpo-e2e.test.ts
//
// Same isolation rule as train-e2e.test.ts: loads the on-disk
// MiniCPM5-1B-OptiQ-4bit base and runs a handful of ORPO iterations, so it is
// GATED behind MLX_BUN_TEST_TRAIN and skipped by default (bun test is one
// process; loading another model alongside the default suite risks the
// uncatchable async GPU OOM). Reference-free ORPO = 2 forwards/step, no ref.
//
// Asserts:
//   1. the ORPO loss improves over the run (min < first)
//   2. preference accuracy is reported (the metric wiring works)
//   3. an adapter is saved in the mount format and AdapterManager loads it
//   4. adapter-on vs adapter-off greedy generations differ

import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, existsSync, writeFileSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const optIn = process.env.MLX_BUN_TEST_TRAIN === "1";
const BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveBase = existsSync(`${BASE}/config.json`);

describe.skipIf(!optIn || !haveBase)("ORPO training e2e (MiniCPM5-1B)", () => {
  const tmp = mkdtempSync(join(tmpdir(), "train-orpo-e2e-"));
  afterAll(() => rmSync(tmp, { recursive: true, force: true }));

  test("ORPO improves loss, reports accuracy, saves a mountable adapter, changes generations", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { AdapterManager } = await import("../src/lora");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    // The preference loop reads train.jsonl; seed it from the dpo fixture.
    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    writeFileSync(
      join(dataDir, "train.jsonl"),
      readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8"),
    );

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const adapterDir = join(tmp, "adapter");
    const losses: number[] = [];
    let sawAccuracy = false;
    const emit = (e: import("../src/jobs/types").JobEvent) => {
      if (e.type === "metric" && e.kind === "train") {
        losses.push(e.loss as number);
        if (typeof (e as { accuracy?: number }).accuracy === "number") sawAccuracy = true;
      }
    };

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
      baseModel: BASE,
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

    // (4) adapter-on vs adapter-off generations differ
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
    weights.dispose();
  }, 180_000);
});
