import { describe, expect, test } from "bun:test";
import {
  modelNeedsWiredLimit,
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
});
