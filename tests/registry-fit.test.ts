// Registry + fit unit tests (fast tier — synthetic hub dir, in-memory db).

import { describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Registry } from "../src/registry";
import { fit, kvBytesAt, skuMatrix } from "../src/fit";
import type { ModelConfig } from "../src/config";

function makeHub(): string {
  const hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-"));
  const snap = join(hub, "models--test--tiny-4bit", "snapshots", "abc123");
  mkdirSync(snap, { recursive: true });
  writeFileSync(join(snap, "config.json"), JSON.stringify({
    model_type: "gemma4_unified",
    quantization: { bits: 4, group_size: 64, mode: "affine" },
    text_config: { num_hidden_layers: 4, hidden_size: 256, vocab_size: 1000 },
  }));
  writeFileSync(join(snap, "model.safetensors"), new Uint8Array(1024));
  writeFileSync(join(snap, "model.safetensors.index.json"), JSON.stringify({
    metadata: { total_parameters: 123456789 },
    weight_map: {},
  }));
  writeFileSync(join(snap, "optiq_vision.safetensors"), new Uint8Array(64));
  writeFileSync(join(snap, "chat_template.jinja"), "{{ '<|tool_call>' }}");

  const snap2 = join(hub, "models--test--big-bf16", "snapshots", "def456");
  mkdirSync(snap2, { recursive: true });
  writeFileSync(join(snap2, "config.json"), JSON.stringify({
    model_type: "llama", num_hidden_layers: 2, hidden_size: 64, vocab_size: 100,
  }));
  writeFileSync(join(snap2, "model.safetensors"), new Uint8Array(4096));
  return hub;
}

describe("Registry", () => {
  test("scan indexes snapshots with capabilities", async () => {
    const hub = makeHub();
    const reg = new Registry(":memory:");
    expect(await reg.scan(hub)).toBe(2);

    const all = reg.list();
    expect(all).toHaveLength(2);

    const vision = reg.list({ vision: true });
    expect(vision).toHaveLength(1);
    expect(vision[0]!.repoId).toBe("test/tiny-4bit");
    expect(vision[0]!.quantBits).toBe(4);
    expect(vision[0]!.paramCount).toBe(123456789);
    expect(vision[0]!.hasToolTemplate).toBe(true);
    expect(vision[0]!.hasKvConfig).toBe(false);

    const small = reg.list({ maxBytes: 2048 });
    expect(small.map((m) => m.repoId)).toEqual(["test/tiny-4bit"]);

    expect(reg.resolve("big").repoId).toBe("test/big-bf16");
    expect(() => reg.resolve("test")).toThrow(/ambiguous/);
    expect(() => reg.resolve("nope")).toThrow(/no model/);
    rmSync(hub, { recursive: true, force: true });
  });
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
    expect(r.maxSafeContext).toBeGreaterThan(4096);
    // verify the solved context actually fits
    const atMax = fit(config, weights, r.maxSafeContext, m);
    expect(atMax.fits).toBe(true);
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
