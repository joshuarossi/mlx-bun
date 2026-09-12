import { describe, expect, test } from "bun:test";
import {
  configureRuntime,
  createRuntimeConfig,
  runtimeValue,
  runtimeConfig,
  withRuntimeConfig,
} from "../../src/runtime-config";

describe("runtime config", () => {
  test("concurrent executions and nested scopes retain their snapshot across awaits", async () => {
    const original = runtimeConfig();
    const left = createRuntimeConfig({ MLX_BUN_GRAMMAR: "0" });
    const right = createRuntimeConfig({ MLX_BUN_GRAMMAR: "1" });
    let release!: () => void;
    const barrier = new Promise<void>((resolve) => { release = resolve; });
    const pending = [left, right].map((config) => withRuntimeConfig(config, async () => {
      expect(runtimeConfig()).toBe(config);
      await barrier;
      expect(runtimeConfig()).toBe(config);
      await expect(withRuntimeConfig(original, async () => {
        await Promise.resolve();
        expect(runtimeConfig()).toBe(original);
        throw new Error("nested failure");
      })).rejects.toThrow("nested failure");
      expect(runtimeConfig()).toBe(config);
      return runtimeValue("MLX_BUN_GRAMMAR");
    }));
    const restore = configureRuntime({ MLX_BUN_GRAMMAR: "changed" });
    try {
      release();
      expect(await Promise.all(pending)).toEqual(["0", "1"]);
      expect(runtimeValue("MLX_BUN_GRAMMAR")).toBe("changed");
    } finally { restore(); }
    expect(runtimeConfig()).toBe(original);
  });

  test("captures only mlx-bun keys in a frozen snapshot", () => {
    const config = createRuntimeConfig({
      MLX_BUN_GRAMMAR: "0",
      PATH: "/bin",
    });
    expect(config.values).toEqual({ MLX_BUN_GRAMMAR: "0" });
    expect(Object.isFrozen(config)).toBe(true);
    expect(Object.isFrozen(config.values)).toBe(true);
    expect(config.flag("MLX_BUN_GRAMMAR", true)).toBe(false);
    expect(config.flag("MLX_BUN_MISSING", true)).toBe(true);
  });

  test("explicit overrides replace the snapshot and restore exactly", () => {
    const before = runtimeValue("MLX_BUN_GRAMMAR");
    const restore = configureRuntime({ MLX_BUN_GRAMMAR: "0" });
    expect(runtimeValue("MLX_BUN_GRAMMAR")).toBe("0");
    restore();
    expect(runtimeValue("MLX_BUN_GRAMMAR")).toBe(before);
  });

  test("undefined explicitly unsets a key until restore", () => {
    const restoreSet = configureRuntime({ MLX_BUN_GRAMMAR: "0" });
    const restoreUnset = configureRuntime({ MLX_BUN_GRAMMAR: undefined });
    expect(runtimeValue("MLX_BUN_GRAMMAR")).toBeUndefined();
    restoreUnset();
    expect(runtimeValue("MLX_BUN_GRAMMAR")).toBe("0");
    restoreSet();
  });
});

test("TQ storage and delayed conversion retain their bound kernel policy across host changes", async () => {
  const { TurboQuantKVCache, KVCache } = await import("../../src/model/gemma4-base");
  const { BatchedTurboQuantKVCache } = await import("../../src/model/batched-turboquant-kv");
  const { DelayedTurboQuantKVCache } = await import("../../src/model/delayed-turboquant-kv");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { cloneKvCaches } = await import("../../src/kv-store");
  const { targetCacheLayout } = await import("../../src/backends/mlx/cache-layout");
  const { MlxArray } = await import("../../src/mlx/array");
  const on = createRuntimeConfig({ MLX_BUN_TURBOQUANT_FUSED_DECODE: "1" });
  const off = createRuntimeConfig({ MLX_BUN_TURBOQUANT_FUSED_DECODE: "0" });
  const maintain = withRuntimeConfig(on, () => createKvMaintenance({ turboQuant: { kBits: 8, vBits: 3 }, quantizedKvStart: 1 }));
  const solo = withRuntimeConfig(on, () => new TurboQuantKVCache(8, 3));
  const delayed = withRuntimeConfig(on, () => new DelayedTurboQuantKVCache(8, 3, 1, maintain));
  using k = MlxArray.fromFloat32(Float32Array.from({ length: 128 }, (_, i) => Math.sin(i)), [1, 1, 2, 64]);
  using v = MlxArray.fromFloat32(Float32Array.from({ length: 128 }, (_, i) => Math.cos(i)), [1, 1, 2, 64]);
  try {
    solo.updateAndFetch(k, v).forEach(array => array.dispose());
    withRuntimeConfig(off, () => {
      const cold = new TurboQuantKVCache(8, 3);
      const clones = cloneKvCaches([solo]);
      const layout = targetCacheLayout(solo) as InstanceType<typeof BatchedTurboQuantKVCache>;
      const copied = delayed.makeEmptyBatch();
      const rows: import("../../src/model/gemma4-base").Cache[] = [new KVCache()];
      try {
        expect(cold.fusedDecode).toBe(false);
        expect(solo.fusedDecode).toBe(true);
        expect((clones[0] as InstanceType<typeof TurboQuantKVCache>).fusedDecode).toBe(true);
        expect(layout.fusedDecode).toBe(true);
        layout.mergeRows([solo]);
        const extracted = layout.extractRow(0);
        try { expect(extracted.fusedDecode).toBe(true); } finally { extracted.dispose(); }
        expect(copied.fusedDecode).toBe(true);
        rows[0]!.updateAndFetch!(k, v).forEach(array => array.dispose());
        maintain(rows);
        expect((rows[0] as InstanceType<typeof TurboQuantKVCache>).fusedDecode).toBe(true);
        expect(runtimeConfig()).toBe(off);
      } finally {
        cold.dispose(); clones.forEach(cache => cache.dispose()); layout.dispose(); copied.dispose(); rows.forEach(cache => cache.dispose());
      }
    });
  } finally { solo.dispose(); delayed.dispose(); }
});

test("trellis weight mode reads the scoped configuration", async () => {
  const { trellisModeFromEnv } = await import("../../src/model/trellis-linear");
  for (const mode of ["kernel", "expand"] as const)
    withRuntimeConfig(createRuntimeConfig({ MLX_BUN_TRELLIS: mode }), () => expect(trellisModeFromEnv()).toBe(mode));
});
