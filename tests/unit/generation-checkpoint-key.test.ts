import { describe, expect, test } from "bun:test";
import type { GenerateOptions } from "../../src/generate";
import { generationCheckpointKey } from "../../src/serve/checkpoint-identity";

describe("generationCheckpointKey", () => {
  const policy = (seed: number, seedWasExplicit: boolean): GenerateOptions => ({
    maxTokens: 150_000,
    temperature: 1,
    topP: 0.95,
    topK: 20,
    seed,
    seedWasExplicit,
  });

  test("ignores fresh server-default seeds so an identical retry can resume", () => {
    expect(generationCheckpointKey([1, 2, 3], policy(11, false))).toBe(
      generationCheckpointKey([1, 2, 3], policy(99, false)),
    );
  });

  test("keeps explicit seeds in the request identity", () => {
    expect(generationCheckpointKey([1, 2, 3], policy(11, true))).not.toBe(
      generationCheckpointKey([1, 2, 3], policy(99, true)),
    );
    expect(generationCheckpointKey([1, 2, 3], policy(11, true))).not.toBe(
      generationCheckpointKey([1, 2, 3], policy(11, false)),
    );
  });

  test("a changed stop policy cannot resume a different completion", () => {
    const key = (stopSequences?: readonly string[]) => generationCheckpointKey(
      [1, 2, 3], { ...policy(11, false), stopSequences },
    );
    expect(key(["END"])).not.toBe(key(["STOP"]));
    expect(key(["END"])).not.toBe(key());
    expect(key()).toBe(key([]));
    expect(key(["END"])).toBe(key(["END"]));
  });
});
