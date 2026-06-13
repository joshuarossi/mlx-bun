// MiniCPM5 mixed-KV parity against OptiQ's kv_config.json path.

import { describe, expect, test } from "bun:test";
import { existsSync } from "node:fs";
import { loadModelConfig, type KvQuantSpec } from "../src/config";
import { MiniCPM5Model } from "../src/model/minicpm5";
import {
  argmaxLastPosition,
  KVCache,
  RotatingKVCache,
  lastPositionLogits,
  type Cache,
} from "../src/model/gemma4-base";
import { Weights } from "../src/weights";
import { goldenAt, goldenPath } from "./goldens";
import { SNAPSHOT_MINICPM5 } from "./paths";

const STEPS = 100;

function requireFile(path: string): void {
  if (!existsSync(path)) throw new Error(`required MiniCPM5 mixed-KV parity file missing: ${path}`);
}

function maybeQuantizeKv(cache: Cache[], kvConfig: KvQuantSpec[]): void {
  const byLayer = new Map(kvConfig.map((e) => [e.layerIdx, e]));
  for (let i = 0; i < cache.length; i++) {
    const c = cache[i]!;
    if (!(c instanceof KVCache || c instanceof RotatingKVCache)) continue;
    if (c.offset === 0) continue;
    const e = byLayer.get(i);
    if (e) cache[i] = c.toQuantized(e.groupSize, e.bits);
  }
}

describe("MiniCPM5 mixed-KV decode parity", async () => {
  requireFile(`${SNAPSHOT_MINICPM5}/config.json`);
  requireFile(`${SNAPSHOT_MINICPM5}/kv_config.json`);
  requireFile(goldenPath("minicpm5-kv-parity.json"));
  for (let i = 0; i < STEPS; i++) requireFile(goldenPath(`minicpm5-kv-logits-step${i}.bin`));

  test(`first ${STEPS} greedy tokens identical; all mixed-KV logits match oracle`, async () => {
    const golden = (await goldenAt("minicpm5-kv-parity.json").json()) as {
      prompt_ids: number[];
      greedy_ids: number[];
      logit_steps: number;
    };
    const config = await loadModelConfig(SNAPSHOT_MINICPM5);
    if (!config.kvQuant?.length) throw new Error("MiniCPM5 kv_config did not load");
    const model = new MiniCPM5Model(await Weights.open(SNAPSHOT_MINICPM5), config);
    const cache = model.makeCache();
    let tokens = golden.prompt_ids;
    try {
      for (let step = 0; step < STEPS; step++) {
        const logits = model.forward(tokens, cache);
        const ours = lastPositionLogits(logits);
        const ref = new Float32Array(
          await goldenAt(`minicpm5-kv-logits-step${step}.bin`).arrayBuffer(),
        );
        let maxDiff = 0;
        for (let i = 0; i < ref.length; i++)
          maxDiff = Math.max(maxDiff, Math.abs(ours[i]! - ref[i]!));
        expect(maxDiff).toBe(0);
        maybeQuantizeKv(cache, config.kvQuant);
        const next = argmaxLastPosition(logits);
        logits.dispose();
        expect(next).toBe(golden.greedy_ids[step]!);
        tokens = [next];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
  }, 120_000);
});
