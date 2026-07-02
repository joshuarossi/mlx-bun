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
// Coverage notes (2026-07-01 review): the sweep covers
//  - D=64 AND D=256 — e4b's real head dim, where the backward runs the
//    asymmetric tiles (BQ=8, BKV=16) the fixed dQ-barrier bug class lives in;
//  - T not a tile multiple (T=90) — exercises the partial-tile tails;
//  - sliding window > 0 — the in-kernel window mask term is an mlx-bun
//    ORIGINAL (no optiq oracle; optiq's kernel has no window arg), fed live by
//    gemma4.ts for every sliding layer under MLX_BUN_TRAIN_ATTN=flash. Its
//    oracle here is ops.sdpa with the SAME window mask materialized explicitly
//    (createCausalMask — the exact mask the unfused sliding path uses), for
//    both the forward output and all three grads.
// NOT covered here (kept cheap): the >=2K long-context regime where e4b
// historically SIGTRAPed — that re-validation is a separate, Josh-gated GPU run
// (scripts/experiments/segmented-grad-test-e4b.ts); the trainer refuses
// flash on Gemma until it lands.
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
import { createCausalMask } from "../src/model/gemma4";

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
const readF32 = (a: MlxArray): Float32Array => ops.contiguous(a.astype(Dtype.float32)).toFloat32();

describe("flash-attention backward == ops.sdpa (f16 precision)", () => {
  // D=64: the original sweep. D=256: e4b's head dim (asymmetric backward tiles).
  // T=90 is deliberately NOT a multiple of any fwd/bwd tile (8/16/32).
  const cases: [number, number, number, number][] = []; // [D, Hq, Hkv, T]
  for (const Hkv of [4, 2]) for (const T of [64, 256]) cases.push([64, 4, Hkv, T]);
  for (const T of [64, 90]) cases.push([256, 4, 2, T]);
  for (const [D, Hq, Hkv, T] of cases) for (const causal of [false, true]) {
    test(`D=${D} Hq=${Hq} Hkv=${Hkv} T=${T} causal=${causal}`, () => {
      const scale = 1 / Math.sqrt(D);
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

describe("flash-attention sliding window == ops.sdpa + explicit window mask", () => {
  // The window term (`q_pos - kv_pos >= window → -inf`, forward AND both
  // backward kernels) has no optiq oracle — gate it against ops.sdpa fed the
  // SAME window mask materialized (createCausalMask(T, 0, W): allowed iff
  // kv <= q && q - kv < W — the mask gemma4's unfused sliding path uses).
  // W < T so the window actually clips (some rows have out-of-range past
  // tiles, incl. the fully-masked-tile online-softmax rescue path), and
  // T=96 / W=40 land off the D=256 backward tile boundaries.
  for (const [D, Hq, Hkv, T, W] of [
    [64, 4, 2, 96, 40],
    [256, 4, 2, 96, 40],
  ] as const) {
    test(`D=${D} Hq=${Hq} Hkv=${Hkv} T=${T} window=${W}: forward + grads`, () => {
      const scale = 1 / Math.sqrt(D);
      const q = rand([1, Hq, T, D], 5), k = rand([1, Hkv, T, D], 6), v = rand([1, Hkv, T, D], 7), dO = rand([1, Hq, T, D], 8);
      expect(flashSupported(q)).toBe(true);
      const mask = createCausalMask(T, 0, W); // bool [T, T]

      // forward O directly (the sweep above only asserts through the vjp)
      const oFlash = flashAttention(q, k, v, scale, true, W);
      const oSdpa = ops.sdpa(q, k, v, scale, "array", mask);
      expect(relErr(readF32(oFlash), readF32(oSdpa))).toBeLessThan(0.02);
      oFlash.dispose();
      oSdpa.dispose();

      const flash = gradsVjp((qq, kk, vv) => flashAttention(qq, kk, vv, scale, true, W), q, k, v, dO);
      const sdpa = gradsVjp((qq, kk, vv) => ops.sdpa(qq, kk, vv, scale, "array", mask), q, k, v, dO);
      expect(relErr(flash[0]!, sdpa[0]!)).toBeLessThan(0.02); // dQ
      expect(relErr(flash[1]!, sdpa[1]!)).toBeLessThan(0.02); // dK
      expect(relErr(flash[2]!, sdpa[2]!)).toBeLessThan(0.02); // dV
      mask.dispose();
      for (const a of [q, k, v, dO]) a.dispose();
    });
  }
});
