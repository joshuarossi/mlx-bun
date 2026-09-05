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
