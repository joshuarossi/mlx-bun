// FAST: the --batch N lane picker (GenerationGateway.willBatch) — no model
// load. willBatch is pure over (batchingEnabled, cache capability,
// RequestShape); the only model surface it touches is makeCache() (the
// capability gate — fresh caches hold no buffers), so a stub stands in. This
// gates the compatibility matrix in docs/reference/server-config.md: which
// request shapes batch and which drain to the serial lane. The scheduler's
// NUMERICS are gated separately (tests/batch-scheduler.test.ts); this gates
// the ROUTING decision.

import { describe, expect, test } from "bun:test";
import { GenerationGateway, type RequestShape } from "../src/serve/generation-gateway";
import { KVCache, RotatingKVCache } from "../src/model/gemma4-base";
import { SSMCache } from "../src/model/qwen3-delta";
import type { RuntimeModel } from "../src/model/factory";

// willBatch reads only makeCache() off the model (the capability gate) and
// never the serialRun, so stubs are safe. The default stub models a
// full-attention model (all-KVCache — batch-capable).
const stubModel = { makeCache: () => [new KVCache()] } as unknown as RuntimeModel;
const stubSerial = (async () => ({}) as never) as never;
const gateway = (batch: number) => new GenerationGateway(stubModel, batch, stubSerial);

// The all-clear shape: nothing that would force the serial lane.
const batchable: RequestShape = {
  hasVision: false,
  hasAdapters: false,
  hasRepetitionPenalty: false,
  hasLogitsExtras: false,
  wantsLogprobs: false,
  userSeed: false,
  kvQuant: false,
};

describe("GenerationGateway.willBatch", () => {
  test("--batch 1 never batches (serial mode), regardless of shape", () => {
    const g = gateway(1);
    expect(g.batchingEnabled).toBe(false);
    expect(g.willBatch(batchable)).toBe(false);
  });

  test("--batch 0 / negative clamps to serial", () => {
    expect(gateway(0).batchingEnabled).toBe(false);
    expect(gateway(-3).batchingEnabled).toBe(false);
  });

  test("--batch N (N>1) batches the all-clear shape", () => {
    const g = gateway(2);
    expect(g.batchingEnabled).toBe(true);
    expect(g.willBatch(batchable)).toBe(true);
  });

  test("idle gateway reports zero active rows (no scheduler created)", () => {
    expect(gateway(4).activeRows).toBe(0);
  });

  // Each disqualifier individually forces the serial lane.
  const disqualifiers: Array<[keyof RequestShape, string]> = [
    ["hasVision", "vision (offset-0 single-seq prefill + image mask)"],
    ["hasAdapters", "LoRA adapter (single per-generation loraState)"],
    ["hasRepetitionPenalty", "repetition penalty (per-row logits processor)"],
    ["hasLogitsExtras", "min_p/XTC/logit_bias/presence+frequency penalty (serial-only v1)"],
    ["wantsLogprobs", "logprobs/top_logprobs capture (serial-only, batch-lane deferred)"],
    ["userSeed", "explicit seed (reproducibility ⇒ solo)"],
    ["kvQuant", "explicit kv-quant (batched is bf16-only in v1)"],
  ];
  for (const [flag, why] of disqualifiers) {
    test(`${flag} drains to serial — ${why}`, () => {
      expect(gateway(2).willBatch({ ...batchable, [flag]: true })).toBe(false);
    });
  }

  test("multiple disqualifiers still serial", () => {
    expect(
      gateway(2).willBatch({
        ...batchable,
        hasVision: true,
        userSeed: true,
        kvQuant: true,
      }),
    ).toBe(false);
  });

  // The sampler knobs that DO batch are NOT part of RequestShape — they never
  // disqualify. Temperature/top-p/top-k/stop/tools/thinking all batch; this
  // test documents that the all-clear shape (which they leave untouched) batches.
  test("sampler knobs (temp/top-p/top-k/stop/tools) are not disqualifiers", () => {
    // None of them appear in RequestShape, so an all-clear shape stays batchable.
    expect(gateway(2).willBatch(batchable)).toBe(true);
  });

  // Cache-capability gate (mirrors mlx-lm server.py's all-caches-have-merge
  // check): the scheduler's dynamic-B ops exist only on KVCache and
  // RotatingKVCache. A hybrid model (Qwen3.5's SSMCache) must route serial —
  // before this gate, `--batch N` on Qwen3.5 500'd EVERY batched request
  // (the scheduler cast SSMCache to KVCache and called a nonexistent
  // temporalView). See docs/design/batching-v2-plan.md D1.
  describe("cache-capability gate", () => {
    test("hybrid-cache model (Qwen3.5 SSMCache) never batches — routes serial", () => {
      const qwen = {
        makeCache: () => [new SSMCache(), new KVCache()], // gated-DeltaNet + full-attn mix
      } as unknown as RuntimeModel;
      const g = new GenerationGateway(qwen, 2, stubSerial);
      expect(g.batchingEnabled).toBe(true); // the MODE is on…
      expect(g.willBatch(batchable)).toBe(false); // …but every request is serial-lane
    });

    test("sliding-window models batch (RotatingKVCache is dynamic-B capable)", () => {
      const gemma = {
        makeCache: () => [new KVCache(), new RotatingKVCache(1024)],
      } as unknown as RuntimeModel;
      const g = new GenerationGateway(gemma, 2, stubSerial);
      expect(g.willBatch(batchable)).toBe(true);
    });
  });
});
