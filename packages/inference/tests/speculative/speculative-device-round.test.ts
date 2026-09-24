import { expect, test } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { makeStepSampler } from "../../src/sampling/index";
import { advanceSpeculativeRows } from "../../src/generation/speculative/round";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";

// Two rows, depth 2, a 16-token vocabulary. Logits favor `choices` with a clear
// margin but sampling stays stochastic; both orders must make the same draws.
const proposals = [[2, 3], [5, 6]];
const choices = [[2, 9, 4], [5, 6, 7]];
const logits = () => MlxArray.fromFloat32(Float32Array.from({ length: 2 * 3 * 16 }, (_, i) => {
  const row = Math.floor(i / 48), position = Math.floor(i / 16) % 3, token = i % 16;
  return (choices[row]![position] === token ? 3 : 0) + ((token * 5 + position) % 4) * 0.25;
}), [2, 3, 16]);

async function round(deviceFirst: boolean, options: Parameters<typeof makeStepSampler>[0]) {
  const samplers = [0, 1].map(() => makeStepSampler(options, {
    tokenRepresentation: "number", grammarWait: "before-sample", historyUpdate: "after-sample",
  }));
  const calls = { draft: 0, draftDevice: 0, resolved: [] as number[][], forwardIds: [] as number[] };
  const run = () => advanceSpeculativeRows(samplers.map((sampling, row) => ({
    pending: row + 1, step: row * 10 + 2, remaining: 20, eosTokenIds: [], sampling,
  })), 2, {
    draft() { calls.draft++; return proposals; },
    draftDevice() {
      calls.draftDevice++;
      return { tokens: ops.fromInt32(proposals.flat(), [2, 2]).astype(Dtype.uint32),
        resolve(read) { calls.resolved.push([...read]); return proposals; } };
    },
    commit() {},
  }, {
    transaction: { canBegin: () => true, begin() {}, resolve() {} },
    async forward(ids) { calls.forwardIds = ids.toIntTokens(); return { logits: logits(), context: ops.zeros([2, 3, 2], Dtype.float32) }; },
  });
  try {
    const result = await withRuntimeConfig(createRuntimeConfig({ MLX_BUN_SPEC_DEVICE_ROUND: deviceFirst ? "1" : "0" }), run);
    return { calls, emitted: result.map(row => row.acceptance.emitted), accepted: result.map(row => row.acceptance.accepted),
      correction: result.map(row => row.acceptance.correction) };
  } finally { for (const sampler of samplers) sampler.dispose(); }
}

for (const [name, options] of [
  ["sampled", { temperature: 0.8, topP: 0.95, topK: 6, seed: 23 }],
  ["greedy", { temperature: 0 }],
] as const) {
  test(`device-first round makes the same decisions as the host-first round (${name})`, async () => {
    const host = await round(false, options), device = await round(true, options);
    expect(host.calls).toMatchObject({ draft: 1, draftDevice: 0 });
    expect(device.calls).toMatchObject({ draft: 0, draftDevice: 1 });
    expect(device.calls.resolved).toEqual([proposals.flat()]);
    // The verify window is [pending, ...drafts] per row in both orders.
    expect(device.calls.forwardIds).toEqual([1, 2, 3, 2, 5, 6]);
    expect(host.calls.forwardIds).toEqual(device.calls.forwardIds);
    expect(device.emitted).toEqual(host.emitted);
    expect(device.accepted).toEqual(host.accepted);
    expect(device.correction).toEqual(host.correction);
  });
}

test("rows whose sampling depends on history keep the host-first order", async () => {
  const result = await round(true, { temperature: 0.8, seed: 3, repetitionPenalty: 1.2 });
  expect(result.calls).toMatchObject({ draft: 1, draftDevice: 0 });
});
