import { describe, expect, test } from "bun:test";
import {
  configureRuntime,
  createRuntimeConfig,
  runtimeValue,
} from "../../src/runtime-config";

describe("runtime config", () => {
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
