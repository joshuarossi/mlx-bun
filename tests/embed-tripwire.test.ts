// Embedding tripwire instrument. embedOne bumps a module-level counter at its
// top, so embedMany accrues one tick per text. The pure-logic assertions
// (reset/get) run anywhere; the count-of-3 assertion needs the Qwen3-Embedding
// model (a GPU load) and is gated on the snapshot — the parent runs it serially.
//
//   bun test tests/embed-tripwire.test.ts

import { describe, expect, test } from "bun:test";
import { embedMany, getEmbedCounter, resetEmbedCounter } from "../src/embed";
import { SNAPSHOT_QWEN3_EMBED, snapshotQwen3EmbedAvailable } from "./paths";

const haveWeights = await snapshotQwen3EmbedAvailable();

describe("embed tripwire counter (pure logic)", () => {
  test("reset zeroes the counter", () => {
    resetEmbedCounter();
    expect(getEmbedCounter()).toBe(0);
  });

  test("getEmbedCounter reflects the value after reset", () => {
    resetEmbedCounter();
    expect(getEmbedCounter()).toBe(0);
  });
});

describe.skipIf(!haveWeights)("embed tripwire counter (GPU — model load)", () => {
  test("embedMany of 3 texts increments the counter to 3", async () => {
    const { loadModelConfig } = await import("../src/config");
    const { createModel } = await import("../src/model/factory");
    const { Qwen3Model } = await import("../src/model/qwen3");
    const { Weights } = await import("../src/weights");
    const { loadTokenizer } = await import("../src/tokenizer");

    const config = await loadModelConfig(SNAPSHOT_QWEN3_EMBED);
    const model = createModel(await Weights.open(SNAPSHOT_QWEN3_EMBED), config);
    expect(model).toBeInstanceOf(Qwen3Model);
    const tok = await loadTokenizer(SNAPSHOT_QWEN3_EMBED);

    resetEmbedCounter();
    embedMany(model as InstanceType<typeof Qwen3Model>, tok, ["a", "b", "c"]);
    expect(getEmbedCounter()).toBe(3);
  }, 300_000);
});
