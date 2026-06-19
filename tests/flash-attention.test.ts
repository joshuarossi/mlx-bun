// Flash-attention backward parity — guards the two fixed port bugs (the dK
// transpose in flashBackward, and the divergent threadgroup_barrier in the dQ
// causal tile-skip) from regressing. Pure attention tensors (no model).
//
// Parity target: the flash kernel is the L2 op — a port of mlx-optiq's
// flash_attention_metal. The in-repo proxy here is ops.sdpa, which is sound
// because optiq's flash matches ops.sdpa to f16 (scripts/flash-optiq-check.py,
// rel 0.0%); so flash == ops.sdpa here ⟹ flash == optiq (L2). ops.sdpa is itself
// the L1 path (mlx-lm's tuner differentiates the same mx.fast.sdpa) and is
// finite-difference verified. Tolerance is f16 precision across T / causal / GQA.
//
// CRITICAL for parity: read grads CONTIGUOUSLY (a vjp output can be a strided
// view; raw toFloat32() byte-scrambles it) and use a NON-UNIFORM cotangent (a
// mean/uniform dO shrinks grads with T and inflates relative error).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { Vjp } from "../src/mlx/autograd";
import { flashAttention, flashSupported } from "../src/model/flash-attention";

const D = 64;
const scale = 1 / Math.sqrt(D);
const rand = (shape: number[], seed: number) =>
  ops.randomNormal(shape, Dtype.float32, 0, 1, ops.randomKey(BigInt(seed))).astype(Dtype.float16);

function gradsVjp(attn: (q: MlxArray, k: MlxArray, v: MlxArray) => MlxArray,
                  q: MlxArray, k: MlxArray, v: MlxArray, dO: MlxArray): Float32Array[] {
  const vjp = new Vjp((p) => [attn(p[0]!, p[1]!, p[2]!)], 1);
  const { vjps } = vjp.apply([q, k, v], [dO]);
  const out = vjps.map((g) => ops.contiguous(g.astype(Dtype.float32)).toFloat32());
  ops.evalAll(vjps);
  for (const g of vjps) g.dispose();
  vjp.dispose();
  return out;
}
const relErr = (a: Float32Array, b: Float32Array): number => {
  let n = 0, d = 0;
  for (let i = 0; i < a.length; i++) { const e = a[i]! - b[i]!; n += e * e; d += b[i]! * b[i]!; }
  return Math.sqrt(n) / (Math.sqrt(d) + 1e-12);
};

describe("flash-attention backward == ops.sdpa (f16 precision)", () => {
  for (const Hq of [4]) for (const Hkv of [4, 2]) for (const T of [64, 256]) for (const causal of [false, true]) {
    test(`Hq=${Hq} Hkv=${Hkv} T=${T} causal=${causal}`, () => {
      const q = rand([1, Hq, T, D], 1), k = rand([1, Hkv, T, D], 2), v = rand([1, Hkv, T, D], 3), dO = rand([1, Hq, T, D], 4);
      expect(flashSupported(q)).toBe(true);
      const flash = gradsVjp((qq, kk, vv) => flashAttention(qq, kk, vv, scale, causal), q, k, v, dO);
      const sdpa = gradsVjp((qq, kk, vv) => ops.sdpa(qq, kk, vv, scale, causal ? "causal" : ""), q, k, v, dO);
      // dQ, dK, dV all within f16 tolerance (a transpose/barrier regression is order-1).
      expect(relErr(flash[0]!, sdpa[0]!)).toBeLessThan(0.02); // dQ
      expect(relErr(flash[1]!, sdpa[1]!)).toBeLessThan(0.02); // dK
      expect(relErr(flash[2]!, sdpa[2]!)).toBeLessThan(0.02); // dV
      for (const a of [q, k, v, dO]) a.dispose();
    });
  }
});
