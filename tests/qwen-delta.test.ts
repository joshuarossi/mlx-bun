// FAST (no model load): the Qwen3.5 gated-DeltaNet recurrence
// (src/model/qwen3-delta.ts) vs mlx-lm's gated_delta_update GPU-kernel oracle.
//
// scripts/gen-qwen-delta-golden.py ran the reference kernel at the real
// Qwen3.6-27B head geometry across a prefill step (T=3, state=None) and a
// chained decode step (T=1, state=state1); this asserts our ported Metal
// kernel + compute_g produce BIT-EXACT y at both steps. The chained decode
// transitively validates the recurrent state (a wrong state1 would diverge y2).
// This de-risks the hardest piece of the port without the 15 GB load; full
// end-to-end model parity is gated separately (run with Josh).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import { gatedDeltaUpdate } from "../src/model/qwen3-delta";

const g = await Bun.file(`${import.meta.dir}/fixtures/qwen-delta-golden.json`).json();

const bf16 = (vals: number[], shape: number[]): MlxArray => {
  const f = MlxArray.fromFloat32(Float32Array.from(vals), shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
};

const maxAbsDiff = (a: MlxArray, expected: number[]): number => {
  const got = a.toFloat32();
  let m = 0;
  for (let i = 0; i < got.length; i++) m = Math.max(m, Math.abs(got[i]! - expected[i]!));
  return m;
};

describe("Qwen3.5 gated-DeltaNet vs mlx-lm gated_delta_update (model-free)", () => {
  test("prefill (T=3) + chained decode (T=1) y are bit-exact", () => {
    const { B, HK, HV, DK, DV } = g;
    const aLog = bf16(g.A_log, [HV]);
    const dtBias = bf16(g.dt_bias, [HV]);

    const run = (rec: any, state: MlxArray | null): [MlxArray, MlxArray] => {
      const T = rec.T;
      const q = bf16(rec.q, [B, T, HK, DK]);
      const k = bf16(rec.k, [B, T, HK, DK]);
      const v = bf16(rec.v, [B, T, HV, DV]);
      const a = bf16(rec.a, [B, T, HV]);
      const b = bf16(rec.b, [B, T, HV]);
      const [y, newState] = gatedDeltaUpdate(q, k, v, a, b, aLog, dtBias, state);
      for (const t of [q, k, v, a, b]) t.dispose();
      return [y, newState];
    };

    const [y1, s1] = run(g.prefill, null);
    expect(maxAbsDiff(y1, g.prefill.y)).toBe(0);

    const [y2, s2] = run(g.decode, s1);
    expect(maxAbsDiff(y2, g.decode.y)).toBe(0);

    for (const t of [aLog, dtBias, y1, s1, y2, s2]) t.dispose();
  });
});
