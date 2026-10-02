import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { makeStepSampler } from "../../src/sampling/index";
import { advanceSpeculativeOutputs, advanceSpeculativeRows, prepareSpeculativeRows } from "../../src/generation/speculative/round";

test("one verify graph serves independent acceptance, EOS, budgets and logprobs", async () => {
  const proposals = [[2, 3, 4], [5, 6, 7], [8, 9, 10]];
  const choices = [[2, 12, 13, 14], [5, 6, 7, 8], [8, 9, 10, 11]];
  const events: unknown[] = [];
  const samplers = choices.map(() => makeStepSampler({ temperature: 0 }, {
    tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
    captureSelectedLogprob: true, captureTopLogprobs: 2,
  }));
  try {
    const result = await advanceSpeculativeRows(samplers.map((sampling, row) => ({
      pending: row + 1, step: row * 10, remaining: row === 2 ? 1 : 20,
      eosTokenIds: row === 1 ? [6] : [], sampling,
    })), 3, {
      draft(pending, depth, steps) { events.push(["draft", pending, depth, steps]); return proposals; },
      commit(accepted, context) { events.push(["draft-commit", accepted, context.shape]); },
    }, {
      transaction: {
        canBegin: () => true,
        begin(depth) { events.push(["begin", depth]); },
        resolve(accepted) { events.push(["target-commit", accepted]); },
      },
      async forward(ids) {
        events.push(["forward", ids.shape, ids.toIntTokens()]);
        return {
          logits: MlxArray.fromFloat32(Float32Array.from({ length: 3 * 4 * 16 }, (_, i) =>
            choices[Math.floor(i / 64)]![Math.floor(i / 16) % 4] === i % 16 ? 9 : 0), [3, 4, 16]),
          context: ops.zeros([3, 4, 2], Dtype.float32),
        };
      },
    });
    expect(result.map(row => row.acceptance.emitted)).toEqual([[2, 12], [5], [8]]);
    expect(result.map(row => row.acceptance.accepted)).toEqual([1, 2, 1]);
    expect(result.map(row => row.acceptance.sawEos)).toEqual([false, true, false]);
    expect(result.map(row => row.logprobs.length)).toEqual([2, 1, 1]);
    for (const row of result) for (const [i, metadata] of row.logprobs.entries()) {
      expect(Number.isFinite(metadata!.logprob)).toBe(true);
      expect(metadata!.top![0]!.id).toBe(row.acceptance.emitted[i]!);
    }
    expect(events).toEqual([
      ["draft", [1, 2, 3], 3, [0, 10, 20]], ["begin", 3],
      ["forward", [3, 4], [1, 2, 3, 4, 2, 5, 6, 7, 3, 8, 9, 10]],
      ["target-commit", [1, 2, 1]], ["draft-commit", [1, 2, 1], [3, 4, 2]],
    ]);
  } finally { for (const sampler of samplers) sampler.dispose(); }
});

test("B=1 grammar termination ends acceptance before the next target sample", async () => {
  let grammarDone = false, sampled = 0;
  const sampling = makeStepSampler({ temperature: 0 }, {
    tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
  });
  Object.assign(sampling, { independent: undefined, positional: undefined });
  const sample = sampling.sample.bind(sampling);
  sampling.sample = async (scores, step) => { sampled++; grammarDone = true; return sample(scores, step); };
  try {
    const result = await advanceSpeculativeRows([{ pending: 0, step: 4, remaining: 10,
      eosTokenIds: [], sampling, grammarDone: () => grammarDone }], 1, {
      draft: () => [[1]], commit: accepted => { expect(accepted).toEqual([1]); },
    }, {
      transaction: { canBegin: () => true, begin() {}, resolve: accepted => { expect(accepted).toEqual([1]); } },
      async forward() { return { logits: MlxArray.fromFloat32(new Float32Array([0, 1, 0, 1]), [1, 2, 2]),
        context: ops.zeros([1, 2, 2], Dtype.float32) }; },
    });
    expect(sampled).toBe(1);
    expect(result[0]!.acceptance.grammarDone).toBe(true);
    expect(result[0]!.acceptance.correction).toBe(null);
    expect(result[0]!.acceptance.emitted).toEqual([1]);
  } finally { sampling.dispose(); }
});

test("failed sampling or state retention releases the verify window without another commit", async () => {
  for (const phase of ["sample", "target", "draft"] as const) {
    const failure = new Error(phase), events: string[] = [];
    const sampling = makeStepSampler({ temperature: 0 }, {
      tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
    });
    if (phase === "sample") {
      Object.assign(sampling, { independent: undefined, positional: undefined });
      sampling.sample = async () => { throw failure; };
    }
    const owned = (name: string) => {
      const array = MlxArray.fromFloat32(new Float32Array([0, 1, 0, 1]), [1, 2, 2]);
      const dispose = array.dispose.bind(array);
      array.dispose = () => { events.push(`dispose-${name}`); dispose(); };
      return array;
    };
    try {
      await expect(advanceSpeculativeRows([{ pending: 0, step: 0, remaining: 10,
        eosTokenIds: [], sampling }], 1, {
        draft: () => [[1]], commit() { events.push("draft"); throw failure; },
      }, {
        transaction: { canBegin: () => true, begin() {}, resolve() {
          events.push("target"); if (phase === "target") throw failure;
        } },
        async forward() { return { logits: owned("logits"), context: owned("context") }; },
      })).rejects.toBe(failure);
      expect(events).toEqual([
        ...(phase === "sample" ? [] : ["target"]), ...(phase === "draft" ? ["draft"] : []),
        "dispose-context", "dispose-logits",
      ]);
    } finally { sampling.dispose(); }
  }
});

test("output delivery can shorten a retiring row's retained prefix before either state commits", async () => {
  const events: unknown[] = [];
  const samplers = [0, 1].map(() => makeStepSampler({ temperature: 0 }, {
    tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
  }));
  const context = { graph: "multiple-hidden-taps", dispose() { events.push("dispose-context"); } };
  try {
    const round = await prepareSpeculativeRows(samplers.map(sampling => ({ pending: 0, step: 0,
      remaining: 10, eosTokenIds: [], sampling })), 2, {
      draft: () => [[1, 1], [1, 1]],
      commit(accepted, borrowed) { expect(borrowed).toBe(context); events.push(["draft", accepted]); },
    }, {
      transaction: { canBegin: () => true, begin() { events.push("begin"); },
        resolve(accepted) { events.push(["target", accepted]); } },
      async forward() { return { context,
        logits: MlxArray.fromFloat32(Float32Array.from({ length: 12 }, (_, i) => i % 2), [2, 3, 2]) }; },
    });
    try {
      expect(round.results.map(row => row.acceptance.emitted)).toEqual([[1, 1, 1], [1, 1, 1]]);
      expect(events).toEqual(["begin"]);
      // Request zero's output consumer stopped in the burst. Request one's
      // full accepted prefix continues; neither needs another target call.
      await round.commit([0, 2]);
      expect(events).toEqual(["begin", ["target", [0, 2]], ["draft", [0, 2]]]);
    } finally { round.dispose(); }
    expect(events.at(-1)).toBe("dispose-context");
  } finally { for (const sampler of samplers) sampler.dispose(); }
});

test("the composed method contains output failure and commits every row at its delivered boundary", async () => {
  const events: unknown[] = [], failure = new Error("output failed");
  const samplers = [0, 1, 2].map(() => makeStepSampler({ temperature: 0 }, {
    tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
  }));
  try {
    const result = await advanceSpeculativeOutputs(samplers.map((sampling, row) => ({
      pending: 0, step: 0, remaining: 10, eosTokenIds: [], sampling,
      output: { async commit(ids) {
        events.push(["output", row, ids]);
        if (row === 0) return false;
        if (row === 1) throw failure;
      } },
    })), 2, {
      draft: () => [[1, 1], [1, 1], [1, 1]],
      commit(accepted) { events.push(["draft", accepted]); },
    }, {
      transaction: { canBegin: () => true, begin() {}, resolve(accepted) { events.push(["target", accepted]); } },
      async forward() { return {
        logits: MlxArray.fromFloat32(Float32Array.from({ length: 18 }, (_, i) => i % 2), [3, 3, 2]),
        context: ops.zeros([3, 3, 2], Dtype.float32),
      }; },
    });
    expect(result.outputs).toEqual([{ kind: "stop", generated: 1, accepted: 1 },
      { kind: "failed", generated: 0, accepted: 0, error: failure },
      { kind: "continue", generated: 3, accepted: 2, pending: 1 }]);
    expect(events).toEqual([["output", 0, [1]], ["output", 1, [1]],
      ["output", 2, [1]], ["output", 2, [1]], ["output", 2, [1]],
      ["target", [1, 0, 2]], ["draft", [1, 0, 2]]]);
  } finally { for (const sampler of samplers) sampler.dispose(); }
});

test.each([0, 4])("zero proposals use one target step with independent budgets at requested depth %s", async depth => {
  const samplers = [0, 1].map(() => makeStepSampler({ temperature: 0 }, {
    tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
  }));
  const tokens: number[][] = [[], []];
  try {
    const result = await advanceSpeculativeOutputs(samplers.map((sampling, row) => ({
      pending: row + 4, step: 7, remaining: row === 0 ? 1 : 10, eosTokenIds: [], sampling,
      output: { async commit(ids) { tokens[row]!.push(...ids); } },
    })), depth, {
      draft: () => [[], []], commit(accepted) { expect(accepted).toEqual([0, 0]); },
    }, {
      transaction: { canBegin: () => true, begin(depth) { expect(depth).toBe(0); },
        resolve(accepted) { expect(accepted).toEqual([0, 0]); } },
      async forward(ids) {
        expect(ids.shape).toEqual([2, 1]); expect(ids.toIntTokens()).toEqual([4, 5]);
        return { logits: MlxArray.fromFloat32(new Float32Array([0, 1, 0, 1]), [2, 1, 2]),
          context: ops.zeros([2, 1, 2], Dtype.float32) };
      },
    });
    expect(tokens).toEqual([[1], [1]]);
    expect(result.outputs).toEqual([{ kind: "length", generated: 1, accepted: 0 },
      { kind: "continue", pending: 1, generated: 1, accepted: 0 }]);
  } finally { for (const sampler of samplers) sampler.dispose(); }
});

test("unequal proposals never sample or retain another row's padded suffix", async () => {
  const proposals = [[], [2], [3, 4, 5]], choices = [[7, 7, 7, 7], [2, 8, 8, 8], [3, 4, 5, 6]];
  const samplers = choices.map(() => makeStepSampler({ temperature: 0 }, {
    tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
    captureSelectedLogprob: true,
  }));
  const sampled: number[][] = [[], [], []], emitted: number[][] = [[], [], []];
  for (const [row, sampler] of samplers.entries()) {
    Object.assign(sampler, { independent: undefined, positional: undefined });
    const sample = sampler.sample.bind(sampler);
    sampler.sample = async (scores, step) => { sampled[row]!.push(step); return sample(scores, step); };
  }
  try {
    const result = await advanceSpeculativeOutputs(samplers.map((sampling, row) => ({
      pending: row + 1, step: 10 * row, remaining: 10, eosTokenIds: [], sampling,
      output: { async commit(ids) { emitted[row]!.push(...ids); if (row === 2 && emitted[row]!.length === 2) return false; } },
    })), 6, {
      draft: () => proposals,
      commit(accepted) { expect(accepted).toEqual([0, 1, 2]); },
    }, {
      transaction: { canBegin: () => true,
        begin(depth) { expect(depth).toBe(3); },
        resolve(accepted) { expect(accepted).toEqual([0, 1, 2]); } },
      async forward(ids) {
        expect(ids.shape).toEqual([3, 4]);
        expect(ids.toIntTokens()).toEqual([1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 5]);
        return { logits: MlxArray.fromFloat32(Float32Array.from({ length: 3 * 4 * 9 }, (_, i) =>
          choices[Math.floor(i / 36)]![Math.floor(i / 9) % 4] === i % 9 ? 9 : 0), [3, 4, 9]),
          context: ops.zeros([3, 4, 2], Dtype.float32) };
      },
    });
    expect(result.rounds.map(row => row.drafts)).toEqual(proposals);
    expect(sampled).toEqual([[0], [10, 11], [20, 21, 22, 23]]);
    expect(result.rounds.map(row => row.logprobs.length)).toEqual([1, 2, 4]);
    expect(emitted).toEqual([[7], [2, 8], [3, 4]]);
    expect(result.outputs).toEqual([
      { kind: "continue", generated: 1, accepted: 0, pending: 7 },
      { kind: "continue", generated: 2, accepted: 1, pending: 8 },
      { kind: "stop", generated: 2, accepted: 2 },
    ]);
  } finally { for (const sampler of samplers) sampler.dispose(); }
});

test("stateless sampled rows verify the whole window in one readback and match sequential draws", async () => {
  const proposals = [[2, 3, 4], [5, 6, 7]];
  const width = 4, V = 16;
  // Row 0 favors its drafts at positions 0..1 then diverges; row 1 favors all
  // three drafts and a bonus. Modest margins keep sampling genuinely stochastic.
  const favored = [[2, 3, 9, 1], [5, 6, 7, 8]];
  const logitsFor = () => MlxArray.fromFloat32(Float32Array.from({ length: 2 * width * V }, (_, i) => {
    const row = Math.floor(i / (width * V)), position = Math.floor(i / V) % width, token = i % V;
    return (favored[row]![position] === token ? 2.5 : 0) + ((token * 7 + position * 3) % 5) * 0.2;
  }), [2, width, V]);
  const run = async (sequentialOnly: boolean) => {
    const samplers = [0, 1].map(() => makeStepSampler({ temperature: 0.9, topP: 0.95, topK: 6, seed: 19 }, {
      tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
    }));
    let sequentialCalls = 0;
    for (const sampling of samplers) {
      expect(sampling.independent).toBeUndefined();
      expect(sampling.positional).toBeDefined();
      if (sequentialOnly) Object.assign(sampling, { positional: undefined });
      const sample = sampling.sample.bind(sampling);
      sampling.sample = async (scores, step) => { sequentialCalls++; return sample(scores, step); };
    }
    try {
      const result = await advanceSpeculativeRows(samplers.map((sampling, row) => ({
        pending: row + 1, step: row * 10 + 3, remaining: 20, eosTokenIds: [], sampling,
      })), 3, {
        draft: () => proposals, commit() {},
      }, {
        transaction: { canBegin: () => true, begin() {}, resolve() {} },
        async forward() { return { logits: logitsFor(), context: ops.zeros([2, width, 2], Dtype.float32) }; },
      });
      return {
        sequentialCalls,
        emitted: result.map(row => row.acceptance.emitted),
        accepted: result.map(row => row.acceptance.accepted),
        correction: result.map(row => row.acceptance.correction),
      };
    } finally { for (const sampler of samplers) sampler.dispose(); }
  };
  const positional = await run(false);
  const sequential = await run(true);
  expect(positional.sequentialCalls).toBe(0);
  expect(sequential.sequentialCalls).toBeGreaterThan(0);
  expect(positional.emitted).toEqual(sequential.emitted);
  expect(positional.accepted).toEqual(sequential.accepted);
  expect(positional.correction).toEqual(sequential.correction);
  // The favored tokens dominate: row 1 should usually accept its full draft.
  expect(sequential.emitted.every(tokens => tokens.length >= 1)).toBe(true);
});

test("phase timing is absent by default and attributes draft/verify/sample/commit under the diagnostic flag", async () => {
  const { createRuntimeConfig, withRuntimeConfig } = await import("../../src/runtime/config");
  const run = (config: Record<string, string>) => withRuntimeConfig(createRuntimeConfig(config), async () => {
    const sampling = makeStepSampler({ temperature: 0 }, {
      tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
    });
    let committed = 0;
    try {
      return await advanceSpeculativeOutputs([{ pending: 1, step: 0, remaining: 10, eosTokenIds: [], sampling,
        output: { commit: async () => {} } }], 2, {
        draft: () => [[2, 3]], commit() { committed++; },
      }, {
        transaction: { canBegin: () => true, begin() {}, resolve() {} },
        async forward() { return { logits: MlxArray.fromFloat32(Float32Array.from({ length: 3 * 8 }, (_, i) =>
          [2, 3, 4][Math.floor(i / 8)] === i % 8 ? 5 : 0), [1, 3, 8]), context: ops.zeros([1, 3, 2], Dtype.float32) }; },
      }).then(result => ({ result, committed }));
    } finally { sampling.dispose(); }
  });
  const plain = await run({});
  expect(plain.result.phaseMs).toBeUndefined();
  expect(plain.result.rounds[0]!.acceptance.accepted).toBe(2);
  const timed = await run({ MLX_BUN_SPEC_PHASE_TIMING: "1" });
  expect(timed.committed).toBe(1);
  const phase = timed.result.phaseMs!;
  expect(phase.rounds).toBe(1);
  for (const key of ["draft", "verify", "sample", "commit"] as const) {
    expect(Number.isFinite(phase[key])).toBe(true);
    expect(phase[key]).toBeGreaterThanOrEqual(0);
  }
  expect(timed.result.rounds[0]!.acceptance.accepted).toBe(2);
});
