// Mixed-precision rank scaling: the per-layer bits map (from the model's quant
// specs) must drive by_bits so sensitive (higher-bit) layers get wider adapters
// — optiq's "one sensitivity signal, two optimizations" (bit assignment + LoRA
// rank). These are pure/weight-free: a stub model exposing loraTargets() with
// fake quant specs is all resolveRanks/bitsMapFromModel touch.

import { describe, expect, test } from "bun:test";
import { resolveRanks, bitsMapFromModel } from "../src/train/rank";
import type { RuntimeModel } from "../src/model/factory";

// Minimal stand-in: resolveRanks reads only loraTargets().keys() + the path
// strings; bitsMapFromModel reads each linear's .spec.bits. Nothing else.
function stubModel(bitsByPath: Record<string, number>): RuntimeModel {
  const map = new Map(
    Object.entries(bitsByPath).map(([p, bits]) => [p, { spec: { bits } }]),
  );
  return { loraTargets: () => map } as unknown as RuntimeModel;
}

const Q0 = "model.layers.0.self_attn.q_proj"; // sensitive → 8-bit
const K0 = "model.layers.0.self_attn.k_proj"; // robust → 4-bit
const G3 = "model.layers.3.mlp.gate_proj"; // 3-bit

describe("bitsMapFromModel", () => {
  test("reads per-layer bits straight off the quant specs", () => {
    const model = stubModel({ [Q0]: 8, [K0]: 4, [G3]: 3 });
    expect(bitsMapFromModel(model)).toEqual({ [Q0]: 8, [K0]: 4, [G3]: 3 });
  });
});

describe("resolveRanks by_bits (mixed precision)", () => {
  test("8-bit layer gets 2× rank, 4-bit gets base, 3-bit rounds up", () => {
    const model = stubModel({ [Q0]: 8, [K0]: 4, [G3]: 3 });
    const ranks = resolveRanks(model, {
      rank: 8,
      rankScaling: "by_bits",
      bitsMap: bitsMapFromModel(model),
    });
    expect(ranks.get(Q0)).toBe(16); // 8 * (8/4)
    expect(ranks.get(K0)).toBe(8); //  8 * (4/4)
    expect(ranks.get(G3)).toBe(6); //  ceil(8 * 3/4)
  });

  test("without a bitsMap, by_bits silently falls back to uniform (the bug we fixed)", () => {
    const model = stubModel({ [Q0]: 8, [K0]: 4 });
    const ranks = resolveRanks(model, { rank: 8, rankScaling: "by_bits" });
    expect(ranks.get(Q0)).toBe(8);
    expect(ranks.get(K0)).toBe(8);
  });

  test("constant ignores bits entirely", () => {
    const model = stubModel({ [Q0]: 8, [K0]: 4 });
    const ranks = resolveRanks(model, {
      rank: 8,
      rankScaling: "constant",
      bitsMap: bitsMapFromModel(model),
    });
    expect(ranks.get(Q0)).toBe(8);
    expect(ranks.get(K0)).toBe(8);
  });
});

describe("resolveRanks by_kl", () => {
  test("scales by KL/median, clamped to [0.5×, 2×]; falls back to by_bits with no klMap", () => {
    const model = stubModel({ [Q0]: 8, [K0]: 4, [G3]: 4 });
    // median KL over {2,1,0.1} = 1. Q0: 2/1→2× ; K0: 1/1→1× ; G3: 0.1/1→clamp 0.5×.
    const withKl = resolveRanks(model, {
      rank: 8,
      rankScaling: "by_kl",
      bitsMap: bitsMapFromModel(model),
      klMap: { [Q0]: 2, [K0]: 1, [G3]: 0.1 },
    });
    expect(withKl.get(Q0)).toBe(16); // ceil(8*2)
    expect(withKl.get(K0)).toBe(8); //  ceil(8*1)
    expect(withKl.get(G3)).toBe(4); //  ceil(8*0.5)

    // No klMap → by_bits fallback (Q0 8-bit → 16, others 4-bit → 8).
    const noKl = resolveRanks(model, {
      rank: 8,
      rankScaling: "by_kl",
      bitsMap: bitsMapFromModel(model),
    });
    expect(noKl.get(Q0)).toBe(16);
    expect(noKl.get(K0)).toBe(8);
  });
});
