import { afterEach, beforeEach, expect, spyOn, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import { activeMemory, clearCache, synchronize } from "../../src/mlx/ffi";
import { QwenMtpProvider } from "../../src/spec/qwen-mtp-source";
import { Weights } from "../../src/weights";

let directory: string;
let openSpy: ReturnType<typeof spyOn<typeof Weights, "open">>;
let arrays: MlxArray[];
let disposeCalls: number;
let failAt: string | undefined;
let quantizedPath: string | undefined;

beforeEach(async () => {
  // Drain finalizers from earlier test files before taking a global allocation
  // baseline. Assertions below never run GC, so missing provider disposal
  // cannot pass just because its arrays become unreachable.
  Bun.gc(true);
  await Bun.sleep(0);
  synchronize(gpuStream);
  clearCache();
  directory = mkdtempSync(join(tmpdir(), "mlx-bun-mtp-owner-"));
  writeFileSync(join(directory, "config.json"), JSON.stringify({
    model_type: "qwen3_5_mtp",
    text_config: {
      model_type: "qwen3_5_text", hidden_size: 8, intermediate_size: 16,
      num_hidden_layers: 1, num_attention_heads: 1, num_key_value_heads: 1,
      head_dim: 8, rms_norm_eps: 1e-6, vocab_size: 16,
    },
  }));
  arrays = [];
  disposeCalls = 0;
  failAt = undefined;
  quantizedPath = undefined;
  const weights = {
    shards: { files: new Map([["tiny", { mmap: { size: 4096 } }]]) },
    has(name: string) { return name === `${quantizedPath}.scales`; },
    tensor(name: string) {
      if (name === failAt) throw new Error(`missing ${name}`);
      const shape = name.includes("norm") ? [8] : [8, 8];
      const array = MlxArray.fromFloat32(new Float32Array(shape.reduce((a, b) => a * b, 1)), shape);
      arrays.push(array);
      return array;
    },
    dispose() {
      disposeCalls++;
      for (const array of arrays) array.dispose();
    },
  };
  openSpy = spyOn(Weights, "open").mockResolvedValue(weights as unknown as Weights);
});

afterEach(() => {
  openSpy.mockRestore();
  for (const array of arrays) array.dispose();
  synchronize(gpuStream);
  clearCache();
  rmSync(directory, { recursive: true, force: true });
});

function liveBytes(): number {
  synchronize(gpuStream);
  clearCache();
  return activeMemory();
}

test("provider disposal releases weight maps and transpose views once", async () => {
  const baseline = liveBytes();
  const provider = await QwenMtpProvider.load(directory);
  expect(provider.weightsBytes).toBe(4096);
  expect(disposeCalls).toBe(0);
  expect(liveBytes()).toBeGreaterThan(baseline);
  provider.dispose();
  provider.dispose();
  expect(disposeCalls).toBe(1);
  expect(liveBytes()).toBe(baseline);
  expect(() => provider.open({} as Parameters<QwenMtpProvider["open"]>[0]))
    .toThrow("qwen MTP provider is disposed");
});

test("a late module-construction failure releases weights and earlier views", async () => {
  const baseline = liveBytes();
  failAt = "norm.weight";
  await expect(QwenMtpProvider.load(directory)).rejects.toThrow("missing norm.weight");
  expect(arrays.length).toBeGreaterThan(8);
  expect(disposeCalls).toBe(1);
  expect(liveBytes()).toBe(baseline);
});

test("a quantized projection without metadata releases earlier dense views", async () => {
  const baseline = liveBytes();
  quantizedPath = "layers.0.mlp.down_proj";
  await expect(QwenMtpProvider.load(directory)).rejects.toThrow("no quant spec");
  expect(arrays.length).toBeGreaterThan(8);
  expect(disposeCalls).toBe(1);
  expect(liveBytes()).toBe(baseline);
});
