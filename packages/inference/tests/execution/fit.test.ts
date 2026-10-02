// Fit estimate unit tests (fast tier — synthetic geometries, no weights).

import { describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fitModel } from "../../examples/fit-model";
import type { ModelConfig } from "../../src/artifacts/config";
import { fit, skuMatrix } from "../../src/execution/fit";
import { kvBytesAt } from "../../src/state/kv-scheme";

async function importsWithoutMlx(specifier: string): Promise<number> {
  const child = Bun.spawn([process.execPath, "-e", `await import(${JSON.stringify(specifier)})`], {
    cwd: join(import.meta.dir, "../.."), env: { ...process.env, MLX_BUN_LIBMLXC: "/nonexistent/libmlxc.dylib" },
    stdout: "ignore", stderr: "pipe",
  });
  await new Response(child.stderr).text();
  return child.exited;
}

test("the fit entry and its example import without loading MLX", async () => {
  expect(await importsWithoutMlx("@mlx-bun/inference/execution/fit")).toBe(0);
  expect(await importsWithoutMlx("./examples/fit-model.ts")).toBe(0);
  expect(await importsWithoutMlx("@mlx-bun/inference/execution")).not.toBe(0);
});

test("the runnable example bills every safetensors file in a checkpoint directory", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-fit-example-"));
  try {
    writeFileSync(join(dir, "config.json"), JSON.stringify({
      model_type: "qwen3", hidden_size: 64, num_hidden_layers: 1, num_attention_heads: 2,
      num_key_value_heads: 1, head_dim: 32, intermediate_size: 64, vocab_size: 64,
      rms_norm_eps: 1e-6, max_position_embeddings: 128, tie_word_embeddings: true,
      quantization: { group_size: 64, bits: 4 },
    }));
    writeFileSync(join(dir, "model.safetensors"), new Uint8Array(4096));
    writeFileSync(join(dir, "optiq_vision.safetensors"), new Uint8Array(64));
    const machine = { name: "8GB", ramBytes: 8 * 2 ** 30, bandwidthGBs: 68 };
    const report = await fitModel(dir, 128, machine);
    expect(report.weightsBytes).toBe(4160);
    expect(report.fits).toBe(true);
    expect(report.maxSafeContext).toBe(128);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

describe("fit", () => {
  // gemma-4-12B-like geometry
  const config = {
    text: {
      numHiddenLayers: 48,
      layerTypes: [
        ...Array(40).fill("sliding_attention"),
        ...Array(8).fill("full_attention"),
      ],
      numKeyValueHeads: 8,
      headDim: 256,
      numGlobalKeyValueHeads: 1,
      globalHeadDim: 512,
      attentionKEqV: true,
      slidingWindow: 1024,
      maxPositionEmbeddings: 131072,
    },
  } as unknown as ModelConfig;
  const weights = 8.9e9;

  test("kv bytes: sliding saturates at the window", () => {
    const below = kvBytesAt(config, 512);
    const atWindow = kvBytesAt(config, 1024);
    const above = kvBytesAt(config, 2048);
    expect(below).toBeLessThan(atWindow);
    // above the window only full layers grow: 8 × 2 × 1 × 512 × 2 = 16 KB/tok
    expect(above - atWindow).toBe(1024 * 8 * 2 * 1 * 512 * 2);
  });

  test("fit verdicts scale with machine RAM", () => {
    const m24 = { name: "24GB", ramBytes: 24 * 2 ** 30, bandwidthGBs: 273 };
    const m8 = { name: "8GB", ramBytes: 8 * 2 ** 30, bandwidthGBs: 68 };
    expect(fit(config, weights, 8192, m24).fits).toBe(true);
    expect(fit(config, weights, 8192, m8).fits).toBe(false);
    expect(fit(config, weights, 8192, m8).maxSafeContext).toBe(0);
  });

  test("max safe context honors the budget", () => {
    const m = { name: "x", ramBytes: 24 * 2 ** 30, bandwidthGBs: 273 };
    const r = fit(config, weights, 4096, m);
    expect(r.strategy).toBe("generic-kv");
    expect(r.weightsBytes + r.kvBytes + r.transientBytes + r.reserveBytes)
      .toBe(r.totalBytes);
    expect(r.maxSafeContext).toBeGreaterThan(4096);
    // verify the solved context actually fits
    const atMax = fit(config, weights, r.maxSafeContext, m);
    expect(atMax.fits).toBe(true);
  });

  test("kv-quant scheme bills the quantized cache and stretches the window", () => {
    // uniform 4-bit gs64: bits/8 + (scale+bias)/group = 0.5625 B/elem vs 2 bf16
    const q4 = { kvBits: 4 };
    const slopeBf16 = kvBytesAt(config, 2048) - kvBytesAt(config, 1024);
    const slopeQ4 = kvBytesAt(config, 2048, q4) - kvBytesAt(config, 1024, q4);
    expect(slopeQ4 / slopeBf16).toBeCloseTo(0.5625 / 2);
    // per-layer config: only the listed layer converts (40 is full-attention);
    // above the window the slope drops by exactly that layer's savings
    const cfg = { kvConfig: [{ layerIdx: 40, bits: 4, groupSize: 64 }] };
    const slopeCfg = kvBytesAt(config, 2048, cfg) - kvBytesAt(config, 1024, cfg);
    expect(slopeBf16 - slopeCfg).toBe(1024 * 2 * 1 * 512 * (2 - 0.5625));
    // the solved ceiling grows under the scheme, and still actually fits
    // (tight explicit budget so it binds before the maxPositionEmbeddings cap)
    const m = { name: "x", ramBytes: 16 * 2 ** 30, bandwidthGBs: 273 };
    const budget = 10.5e9;
    const bf16 = fit(config, weights, 4096, m, undefined, 0, budget);
    const quant = fit(config, weights, 4096, m, undefined, 0, budget, q4);
    expect(bf16.maxSafeContext).toBeGreaterThan(0);
    expect(quant.maxSafeContext).toBeGreaterThan(bf16.maxSafeContext);
    expect(fit(config, weights, quant.maxSafeContext, m, undefined, 0, budget, q4).fits).toBe(true);
  });

  // qwen3.8-like hybrid geometry: 36 DeltaNet layers + 12 full-attention
  const hybrid = {
    text: {
      numHiddenLayers: 48,
      layerTypes: [
        ...Array(36).fill("linear_attention"),
        ...Array(12).fill("full_attention"),
      ],
      numKeyValueHeads: 2,
      headDim: 256,
      numGlobalKeyValueHeads: 2,
      globalHeadDim: 256,
      attentionKEqV: false,
      slidingWindow: 0,
      maxPositionEmbeddings: 262144,
      linearNumKeyHeads: 16,
      linearNumValueHeads: 32,
      linearKeyHeadDim: 128,
      linearValueHeadDim: 128,
      linearConvKernelDim: 4,
    },
  } as unknown as ModelConfig;

  test("hybrid: linear layers bill constant state, not per-token KV", () => {
    // per-token slope comes from the 12 full layers only
    const slope = kvBytesAt(hybrid, 2048) - kvBytesAt(hybrid, 1024);
    expect(slope).toBe(1024 * 12 * 2 * 2 * 256 * 2);
    // ctx-independent term = recurrent f32 state + bf16 conv window per layer
    const convDim = 2 * 16 * 128 + 32 * 128;
    const state = 36 * (32 * 128 * 128 * 4 + 3 * convDim * 2);
    expect(kvBytesAt(hybrid, 0)).toBe(state);
    // the solved max context accounts for the state and actually fits
    const m = { name: "x", ramBytes: 24 * 2 ** 30, bandwidthGBs: 273 };
    const r = fit(hybrid, weights, 4096, m);
    expect(r.maxSafeContext).toBeGreaterThan(4096);
    expect(fit(hybrid, weights, r.maxSafeContext, m).fits).toBe(true);
  });

  test("SKU matrix covers the lineup", () => {
    const rows = skuMatrix(config, weights, 8192);
    expect(rows.length).toBeGreaterThan(20);
    const m4pro24 = rows.find((r) => r.sku === "M4 Pro" && r.ramGB === 24)!;
    expect(m4pro24.fits).toBe(true);
    // prediction for the reference machine in a plausible band
    expect(m4pro24.decodeTps).toBeGreaterThan(15);
    expect(m4pro24.decodeTps).toBeLessThan(35);
    const m1_8 = rows.find((r) => r.sku === "M1" && r.ramGB === 8)!;
    expect(m1_8.fits).toBe(false);
  });
});
