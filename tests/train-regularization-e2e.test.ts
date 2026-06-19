// GUARDED e2e for the regularization knobs ON, the way they actually compose:
// ORPO + LoRA-dropout + rsLoRA + LoRA+ + SEGMENTED backward. The segmented path
// RECOMPUTES the forward, so this is the real test that dropout is recompute-
// deterministic — if the per-step mask weren't reproduced, the forward and its
// recompute would disagree and grads would go inconsistent (NaN / no learning).
//
//   MLX_BUN_TEST_TRAIN=1 bun test tests/train-regularization-e2e.test.ts
//
// Also checks the adapter records rs_lora (so inference applies α/√rank too).

import { describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, existsSync, writeFileSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const optIn = process.env.MLX_BUN_TEST_TRAIN === "1";
const BASE =
  `${process.env.HOME}/.cache/huggingface/hub/` +
  `models--mlx-community--MiniCPM5-1B-OptiQ-4bit/snapshots/` +
  `664aabaed233c653f82716d8dc822234d0091f78`;
const haveBase = existsSync(`${BASE}/config.json`);

describe.skipIf(!optIn || !haveBase)("ORPO regularization knobs e2e (MiniCPM5-1B)", () => {
  const tmp = mkdtempSync(join(tmpdir(), "orpo-reg-e2e-"));

  test("dropout+rsLoRA+LoRA+ through segmented recompute: finite, improves, records rs_lora", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { Weights } = await import("../src/weights");
    const { createModel } = await import("../src/model/factory");
    const { loadTokenizer } = await import("../src/tokenizer");
    const { ChatTemplate } = await import("../src/chat-template");
    const { trainLora, DEFAULT_TRAIN_CONFIG } = await import("../src/train/trainer");

    const dataDir = join(tmp, "data");
    mkdirSync(dataDir, { recursive: true });
    writeFileSync(join(dataDir, "train.jsonl"), readFileSync("fixtures/train/tiny/dpo.jsonl", "utf8"));

    const config = await loadModelConfig(BASE);
    const weights = await Weights.open(BASE);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(BASE);
    const tmpl = await ChatTemplate.load(BASE);

    const adapterDir = join(tmp, "adapter");
    const losses: number[] = [];
    await trainLora(model, tok, tmpl, dataDir, {
      ...DEFAULT_TRAIN_CONFIG,
      method: "orpo", rank: 8, scale: 16, rankScaling: "by_bits", numLayers: -1,
      iters: 24, learningRate: 5e-4, orpoLambda: 0.1, orpoLrSchedule: "constant",
      loraDropout: 0.1, rsLora: true, loraPlusRatio: 4, // ← the knobs under test
      segmentSize: 4, // ← forces the recompute path (dropout must be deterministic across it)
      maxSeqLen: 256, seed: 7, stepsPerReport: 1, stepsPerEval: 1000,
      adapterPath: adapterDir, baseModel: BASE,
    }, (e) => { if (e.type === "metric" && e.kind === "train") losses.push(e.loss as number); });

    expect(losses.length).toBeGreaterThan(1);
    for (const l of losses) expect(Number.isFinite(l)).toBe(true); // recompute-determinism guard
    expect(Math.min(...losses)).toBeLessThan(losses[0]!);

    // rsLoRA must be recorded so the serving loader applies α/√rank.
    const cfg = JSON.parse(readFileSync(`${adapterDir}/optiq_lora_config.json`, "utf8"));
    expect(cfg.rs_lora).toBe(true);

    weights.dispose();
    rmSync(tmp, { recursive: true, force: true });
  }, 180_000);
});
