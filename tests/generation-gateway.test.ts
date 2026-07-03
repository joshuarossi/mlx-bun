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
  hasGrammar: false,
  hasDraft: false,
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
    ["wantsLogprobs", "logprobs/top_logprobs capture (serial-only, batch-lane deferred)"],
    ["userSeed", "explicit seed (reproducibility ⇒ solo)"],
    ["kvQuant", "explicit kv-quant (batched is bf16-only in v1)"],
  ];
  for (const [flag, why] of disqualifiers) {
    test(`${flag} drains to serial — ${why}`, () => {
      expect(gateway(2).willBatch({ ...batchable, [flag]: true })).toBe(false);
    });
  }

  // Logits processors BATCH: the per-row sampler folds makeLogitsProcessors
  // over a per-row device-side token history (generate()'s pushHistory).
  // Load-bearing beyond opt-in knobs: Qwen3.5 ships a default repetition
  // penalty in generation_config.json — as serial-only gates these routed
  // EVERY Qwen3.5 request to the serial lane under --batch N.
  test("repetition penalty batches (per-row logits processor)", () => {
    expect(gateway(2).willBatch({ ...batchable, hasRepetitionPenalty: true })).toBe(true);
  });
  test("logits extras batch (min_p/XTC/logit_bias/presence+frequency)", () => {
    expect(gateway(2).willBatch({ ...batchable, hasLogitsExtras: true })).toBe(true);
  });

  // Grammar (B1): per-row matchers make it batchable by default; the kill
  // switch MLX_BUN_GRAMMAR_BATCH=0 forces the B0 serial fallback (A/B lever,
  // house style). Degrade-path requests have NO controller (hasGrammar=false)
  // and stay batchable regardless.
  test("grammar batches by default (B1 per-row matchers)", () => {
    const prev = process.env.MLX_BUN_GRAMMAR_BATCH;
    delete process.env.MLX_BUN_GRAMMAR_BATCH;
    try {
      expect(gateway(2).willBatch({ ...batchable, hasGrammar: true })).toBe(true);
    } finally {
      if (prev !== undefined) process.env.MLX_BUN_GRAMMAR_BATCH = prev;
    }
  });
  // serve --draft-model: a mounted draft routes EVERY request serial —
  // upstream parity (mlx_lm.server: is_batchable = draft is None). Spec is a
  // B=1 latency mode; batching is a throughput mode (integration plan).
  test("hasDraft routes serial (spec is serial-lane-only)", () => {
    expect(gateway(2).willBatch({ ...batchable, hasDraft: true })).toBe(false);
    expect(gateway(2).willBatch({ ...batchable, hasDraft: false })).toBe(true);
  });
  test("MLX_BUN_GRAMMAR_BATCH=0 forces grammar to serial (B0 fallback)", () => {
    const prev = process.env.MLX_BUN_GRAMMAR_BATCH;
    process.env.MLX_BUN_GRAMMAR_BATCH = "0";
    try {
      expect(gateway(2).willBatch({ ...batchable, hasGrammar: true })).toBe(false);
      // degrade-path (no controller) still batches:
      expect(gateway(2).willBatch({ ...batchable, hasGrammar: false })).toBe(true);
    } finally {
      if (prev !== undefined) process.env.MLX_BUN_GRAMMAR_BATCH = prev;
      else delete process.env.MLX_BUN_GRAMMAR_BATCH;
    }
  });

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
  // check): the scheduler's dynamic-B ops exist on KVCache, RotatingKVCache,
  // and — since batching-perf-path P5 — SSMCache (mergeRows/filter, B-axis
  // surgery on the conv/recurrent state slots). MLX_BUN_BATCH_SSM=0 is the
  // kill switch back to the old serial routing.
  describe("cache-capability gate", () => {
    test("hybrid-cache model (Qwen3.5 SSMCache) batches (P5 SSM port)", () => {
      const qwen = {
        makeCache: () => [new SSMCache(), new KVCache()], // gated-DeltaNet + full-attn mix
      } as unknown as RuntimeModel;
      const g = new GenerationGateway(qwen, 2, stubSerial);
      expect(g.batchingEnabled).toBe(true);
      expect(g.willBatch(batchable)).toBe(true);
    });

    test("MLX_BUN_BATCH_SSM=0 re-gates hybrid models to serial", () => {
      process.env.MLX_BUN_BATCH_SSM = "0";
      try {
        const qwen = {
          makeCache: () => [new SSMCache(), new KVCache()],
        } as unknown as RuntimeModel;
        const g = new GenerationGateway(qwen, 2, stubSerial);
        expect(g.willBatch(batchable)).toBe(false);
      } finally {
        delete process.env.MLX_BUN_BATCH_SSM;
      }
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
