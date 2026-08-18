import { describe, expect, test } from "bun:test";
import {
  modelNeedsWiredLimit,
  withModelUsageFlush,
  wiredWorkingSetBytes,
} from "../src/generate";

describe("generation wired-limit policy", () => {
  test("uses resident weights for ordinary models", () => {
    const model = { weightsBytes: 10 };
    expect(wiredWorkingSetBytes(model)).toBe(10);
    expect(modelNeedsWiredLimit(model, 20, false)).toBe(false);
  });

  test("uses the complete streamed execution plan when present", () => {
    const model = {
      weightsBytes: 10,
      expertRuntime: { plan: { plannedBytes: 21 } },
    };
    expect(wiredWorkingSetBytes(model)).toBe(21);
    expect(modelNeedsWiredLimit(model, 20, false)).toBe(true);
  });

  test("never lets a malformed or smaller plan understate resident weights", () => {
    expect(wiredWorkingSetBytes({
      weightsBytes: 10,
      expertRuntime: { plan: { plannedBytes: 8 } },
    })).toBe(10);
    expect(wiredWorkingSetBytes({
      weightsBytes: 10,
      expertRuntime: { plan: { plannedBytes: Number.NaN } },
    })).toBe(10);
  });

  test("honors the explicit force override", () => {
    expect(modelNeedsWiredLimit({ weightsBytes: 1 }, 100, true)).toBe(true);
  });

  test("flushes expert usage after direct execution success or failure", async () => {
    let flushes = 0;
    const model = {
      weightsBytes: 10,
      expertRuntime: {
        plan: { plannedBytes: 21 },
        flushUsage: () => { flushes++; },
      },
    };
    await expect(withModelUsageFlush(model, async () => 7)).resolves.toBe(7);
    await expect(withModelUsageFlush(model, async () => {
      throw new Error("boom");
    })).rejects.toThrow("boom");
    expect(flushes).toBe(2);
  });

  test("prefers the async turn finalizer when learning policy is present", async () => {
    let finishes = 0;
    let flushes = 0;
    const model = {
      weightsBytes: 10,
      expertRuntime: {
        plan: { plannedBytes: 21 },
        finishUsage: async () => { finishes++; },
        flushUsage: () => { flushes++; },
      },
    };
    await withModelUsageFlush(model, async () => undefined);
    expect({ finishes, flushes }).toEqual({ finishes: 1, flushes: 0 });
  });
});
