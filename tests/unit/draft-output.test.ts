import { expect, test } from "bun:test";
import type { CancelReason, TokenLogprobs } from "../../src/contracts/generation";
import { DraftAcceptance } from "../../src/inference/draft-acceptance";
import { deliverDraftOutputs } from "../../src/inference/draft-output";

function accepted(drafts: number[], samples: number[], remaining = 10, eos: number[] = []) {
  const result = new DraftAcceptance(drafts, remaining, eos);
  for (const token of samples) { result.accept(token); if (result.done) break; }
  return result;
}

test("a callback stops inside one burst while another request retains its accepted prefix", async () => {
  const tokens: number[][] = [[], []], metadata: (TokenLogprobs | undefined)[][] = [[], []];
  const results = await deliverDraftOutputs([0, 1].map(row => ({
    acceptance: accepted([2, 3], [2, 3, 4]),
    logprobs: [{ logprob: -0.1 }, { logprob: -0.2 }, { logprob: -0.3 }],
    output: { async commit(ids, extras) {
      tokens[row]!.push(...ids); metadata[row]!.push(...extras!);
      if (row === 0) return false;
    } },
  })));
  expect(tokens).toEqual([[2], [2, 3, 4]]);
  expect(metadata).toEqual([[{ logprob: -0.1 }], [{ logprob: -0.1 }, { logprob: -0.2 }, { logprob: -0.3 }]]);
  expect(results).toEqual([{ kind: "stop", generated: 1, accepted: 1 },
    { kind: "continue", generated: 3, accepted: 2, pending: 4 }]);
});

test("EOS, token budget and grammar keep only published processed inputs", async () => {
  const grammar = new DraftAcceptance([2, 3], 10, []); grammar.accept(2); grammar.accept(3, true);
  const tokens: number[][] = [[], [], [], []];
  const results = await deliverDraftOutputs([
    accepted([2, 9], [2, 9], 10, [9]),
    accepted([2, 3], [2, 9], 10, [9]),
    accepted([2, 3], [2, 3], 1), grammar,
  ].map((acceptance, row) => ({ acceptance, output: { async commit(ids) { tokens[row]!.push(...ids); } } })));
  expect(tokens).toEqual([[2], [2], [2], [2, 3]]);
  expect(results).toEqual([{ kind: "stop", generated: 1, accepted: 1 },
    { kind: "stop", generated: 1, accepted: 1 }, { kind: "length", generated: 1, accepted: 1 },
    { kind: "stop", generated: 2, accepted: 2 }]);
});

test("failed and cancelled consumers cannot publish state or interrupt a surviving request", async () => {
  const failure = new Error("consumer closed");
  let reason: CancelReason | undefined;
  const tokens: number[][] = [[], [], []];
  const results = await deliverDraftOutputs([0, 1, 2].map(row => ({
    acceptance: accepted([2, 3], [2, 3, 4]),
    ...(row === 1 ? { cancellation: { get reason() { return reason; }, subscribe: () => () => {} } } : {}),
    output: { async commit(ids) {
      if (row === 0) throw failure;
      tokens[row]!.push(...ids);
      if (row === 1) reason = "requested";
    } },
  })));
  expect(tokens).toEqual([[], [2], [2, 3, 4]]);
  expect(results).toEqual([{ kind: "failed", error: failure, generated: 0, accepted: 0 },
    { kind: "cancelled", reason: "requested", generated: 1, accepted: 0 },
    { kind: "continue", pending: 4, generated: 3, accepted: 2 }]);
});
