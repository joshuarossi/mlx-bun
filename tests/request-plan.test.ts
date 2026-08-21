import { describe, expect, test } from "bun:test";
import { planRequest, RequestOwnership } from "../src/serve/request-plan";

const base = () => ({
  promptIds: [1, 2, 3],
  options: { maxTokens: 100, stopSequences: [] },
  requestedMaxTokens: 100,
  maxSafeContext: 50,
  stream: false,
  wantLogprobs: false,
  topLogprobs: 0,
  adapterIds: [] as string[],
  hasVision: false,
  userSeed: false,
  hasGrammar: false,
  hasDraft: false,
  ownership: new RequestOwnership(),
});

describe("planRequest", () => {
  test("clamps generation and derives the lane shape", () => {
    const result = planRequest({
      ...base(),
      options: {
        maxTokens: 100,
        stopSequences: ["END"],
        repetitionPenalty: 1.1,
        presencePenalty: 0.2,
        kvBits: 4,
      },
      adapterIds: ["adapter-a"],
      hasGrammar: true,
    });
    expect(result.ok).toBe(true);
    if (!result.ok) return;
    expect(result.options.maxTokens).toBe(47);
    expect(result.options.adapters).toEqual(["adapter-a"]);
    expect(result.shape).toMatchObject({
      hasAdapters: true,
      hasRepetitionPenalty: true,
      hasLogitsExtras: true,
      kvQuant: true,
      hasGrammar: true,
    });
  });

  test("returns memory admission as data", () => {
    const result = planRequest({ ...base(), maxSafeContext: 3 });
    expect(result).toMatchObject({
      ok: false,
      status: 400,
      error: {
        message:
          "prompt is 3 tokens but the memory budget caps safe context at 3 — " +
          "no room to generate; shorten the prompt or raise --memory-budget",
        type: "memory_admission",
        code: "context_over_budget",
      },
    });
  });

  test("non-stream logprobs and stream capture differ in one rule", () => {
    const nonStream = planRequest({ ...base(), wantLogprobs: true, topLogprobs: 3 });
    const stream = planRequest({
      ...base(),
      stream: true,
      wantLogprobs: true,
      topLogprobs: 3,
    });
    expect(nonStream.ok && nonStream.captureLogprobs).toBe(true);
    expect(nonStream.ok && nonStream.options.topLogprobs).toBe(3);
    expect(stream.ok && stream.captureLogprobs).toBe(false);
    expect(stream.ok && stream.options.topLogprobs).toBeUndefined();
  });

  test("dispose owns resources until the generation handoff", () => {
    let disposed = 0;
    const rejectedOwner = new RequestOwnership();
    rejectedOwner.own({ dispose: () => { disposed++; } });
    const rejected = planRequest({ ...base(), ownership: rejectedOwner, maxSafeContext: 3 });
    expect(rejected.ok).toBe(false);
    rejected.dispose();
    expect(disposed).toBe(1);

    const acceptedOwner = new RequestOwnership();
    acceptedOwner.own({ dispose: () => { disposed++; } });
    const accepted = planRequest({ ...base(), ownership: acceptedOwner });
    expect(accepted.ok).toBe(true);
    if (!accepted.ok) return;
    accepted.transferOwnership();
    accepted.dispose();
    expect(disposed).toBe(1);
  });
});
