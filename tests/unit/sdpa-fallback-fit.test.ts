// The advisory fit estimate bills the SDPA-fallback scores tensor for head dims MLX's fused
// multi-query kernel does not serve (mlx 0.32.2: 192/256 fall back on
// M1–M4; 64/72/80/96/128 fuse). Root cause of the 2026-09-08 Qwen3.8-27B
// affine 10K-context Metal OOM on 24 GB: fit() advertised ~15.8K safe
// context while the last prefill chunk materialized ~1.2 GB of bf16 scores.
import { describe, expect, test } from "bun:test";
import type { ModelConfig } from "../../src/config";
import {
  DEFAULT_CHUNK,
  TRANSIENT_PER_TOKEN,
  WIRED_FRACTION,
  fit,
  kvBytesAt,
  sdpaFallbackBytes,
} from "../../src/fit";

// mjriii/Qwen3.8-27B geometry (config.json): 64 layers, 16 full / 48 linear,
// 24 heads × head_dim 256, 4 KV heads, 262144 positions.
function qwen27b(headDim: number): ModelConfig {
  return {
    text: {
      numHiddenLayers: 64,
      layerTypes: Array.from({ length: 64 }, (_, i) =>
        (i + 1) % 4 === 0 ? "full_attention" : "linear_attention"),
      numAttentionHeads: 24,
      numKeyValueHeads: 4,
      headDim,
      numGlobalKeyValueHeads: 4,
      globalHeadDim: headDim,
      slidingWindow: 0,
      maxPositionEmbeddings: 262144,
      linearNumKeyHeads: 16,
      linearNumValueHeads: 48,
      linearKeyHeadDim: 128,
      linearValueHeadDim: 128,
      linearConvKernelDim: 4,
    },
  } as unknown as ModelConfig;
}
const AFFINE_WEIGHTS = 17.015e9; // 17 safetensors shards on disk
const m24 = { name: "24GB", ramBytes: 24 * 2 ** 30, bandwidthGBs: 273 };

describe("sdpaFallbackBytes", () => {
  test("head_dim 256 bills heads × min(chunk, ctx) × ctx × 2 B; 128 fuses", () => {
    const d256 = qwen27b(256);
    expect(sdpaFallbackBytes(d256, 2048, 10399)).toBe(24 * 2048 * 10399 * 2);
    // below one chunk the tensor is square in ctx
    expect(sdpaFallbackBytes(d256, 2048, 1000)).toBe(24 * 1000 * 1000 * 2);
    // decode-sized queries (≤ 8) use the fused vector kernel
    expect(sdpaFallbackBytes(d256, 2048, 8)).toBe(0);
    expect(sdpaFallbackBytes(qwen27b(128), 2048, 10399)).toBe(0);
  });

  test("sliding layers see at most window + chunk keys; linear layers bill nothing", () => {
    const gemma = {
      text: {
        numHiddenLayers: 6,
        layerTypes: [...Array(5).fill("sliding_attention"), "full_attention"],
        numAttentionHeads: 16,
        numKeyValueHeads: 8,
        headDim: 256,
        numGlobalKeyValueHeads: 1,
        globalHeadDim: 512,
        slidingWindow: 1024,
        maxPositionEmbeddings: 131072,
      },
    } as unknown as ModelConfig;
    // the full layer (hd 512) dominates: 16 × 2048 × 32768 × 2
    expect(sdpaFallbackBytes(gemma, 2048, 32768)).toBe(16 * 2048 * 32768 * 2);
    const slidingOnly = {
      text: { ...gemma.text, layerTypes: Array(6).fill("sliding_attention") },
    } as unknown as ModelConfig;
    expect(sdpaFallbackBytes(slidingOnly, 2048, 32768)).toBe(16 * 2048 * (1024 + 2048) * 2);
    const linearOnly = {
      text: { ...qwen27b(256).text, layerTypes: Array(64).fill("linear_attention") },
    } as unknown as ModelConfig;
    expect(sdpaFallbackBytes(linearOnly, 2048, 32768)).toBe(0);
  });
});

describe("fit() bills the fallback transient", () => {
  test("transient = chunk constant + scores; total is the sum of its parts", () => {
    const r = fit(qwen27b(256), AFFINE_WEIGHTS, 10399, m24);
    expect(r.transientBytes).toBe(2048 * TRANSIENT_PER_TOKEN + 24 * 2048 * 10399 * 2);
    expect(r.weightsBytes + r.kvBytes + r.transientBytes + r.reserveBytes).toBe(r.totalBytes);
    expect(r.kvBytes).toBe(kvBytesAt(qwen27b(256), 10399));
  });

  test("24 GB × 17.0 GB affine Qwen: the 10.4K probe exceeds the estimated memory capacity", () => {
    const d256 = fit(qwen27b(256), AFFINE_WEIGHTS, 10399, m24);
    const usable = 24 * 2 ** 30 * WIRED_FRACTION;
    expect(d256.usableBytes).toBe(usable);
    expect(d256.fits).toBe(false);
    // hand-solved: (usable − weights − linear state − chunk·TPT) / (65,536 KV + 98,304 scores) B/token
    const linearState = kvBytesAt(qwen27b(256), 0);
    const perToken = 16 * 2 * 4 * 256 * 2 + 24 * DEFAULT_CHUNK * 2;
    const expected = Math.floor(
      (usable - AFFINE_WEIGHTS - linearState - DEFAULT_CHUNK * TRANSIENT_PER_TOKEN) / perToken,
    );
    expect(Math.abs(d256.maxSafeContext - expected)).toBeLessThanOrEqual(1);
    expect(d256.maxSafeContext).toBeLessThan(10399);
    expect(d256.maxSafeContext).toBeGreaterThan(4096);
    // the same geometry with a fused head dim keeps the old (larger) ceiling
    const d128 = fit(qwen27b(128), AFFINE_WEIGHTS, 10399, m24);
    expect(d128.fits).toBe(true);
    expect(d128.maxSafeContext).toBeGreaterThan(d256.maxSafeContext);
  });

  test("the solved ceiling fits and the next token does not, in every regime", () => {
    const cases: [ModelConfig, number, number | undefined][] = [
      [qwen27b(256), AFFINE_WEIGHTS, undefined],         // linear regime (>chunk)
      [qwen27b(256), 19e9, undefined],                    // quadratic regime (<chunk)
      [qwen27b(128), AFFINE_WEIGHTS, undefined],         // fused, KV-only growth
      [qwen27b(256), 1e9, 30e9],                          // capped at maxPositionEmbeddings
    ];
    for (const [config, weights, budget] of cases) {
      const r = fit(config, weights, 1, m24, DEFAULT_CHUNK, 0, budget);
      expect(fit(config, weights, r.maxSafeContext, m24, DEFAULT_CHUNK, 0, budget).fits).toBe(true);
      if (r.maxSafeContext < config.text.maxPositionEmbeddings)
        expect(fit(config, weights, r.maxSafeContext + 1, m24, DEFAULT_CHUNK, 0, budget).fits).toBe(false);
      else expect(r.maxSafeContext).toBe(config.text.maxPositionEmbeddings);
    }
    expect(fit(qwen27b(256), 19e9, 1, m24).maxSafeContext).toBeGreaterThan(0);
    expect(fit(qwen27b(256), 19e9, 1, m24).maxSafeContext).toBeLessThan(DEFAULT_CHUNK);
    expect(fit(qwen27b(256), 20e9, 1, m24).maxSafeContext).toBe(0);
  });

  test("a smaller prefill chunk lowers the billed transient (admission only)", () => {
    const wide = fit(qwen27b(256), AFFINE_WEIGHTS, 10399, m24, 2048);
    const narrow = fit(qwen27b(256), AFFINE_WEIGHTS, 10399, m24, 256);
    expect(narrow.transientBytes).toBe(256 * TRANSIENT_PER_TOKEN + 24 * 256 * 10399 * 2);
    expect(narrow.maxSafeContext).toBeGreaterThan(wide.maxSafeContext);
  });
});
