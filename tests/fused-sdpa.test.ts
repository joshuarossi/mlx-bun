// Fused (N-tiled FlashAttention) quantized SDPA — Phase 10.
//
// Parity bars (PLAN.md testing strategy):
//  1. BIT-EXACT vs the optiq oracle's _prefill_flashattn_n_tiled
//     (goldens/fused-sdpa.*, regen: scripts/regen-fused-sdpa-goldens.ts)
//     — same ops, same composition order, tier a.
//  2. Bounded tolerance vs our own unfused port: online softmax ≠
//     one-shot precise softmax in bf16, so intra-stack agreement is
//     tier b BY DESIGN (the reference fused path diverges from its own
//     unfused path identically).
//  3. The "array" causal-continuation mask must produce output
//     byte-identical to the "causal" string path (our makeMask hands the
//     tiled code a materialized bool matrix where mlx-lm hands "causal";
//     both must be the same computation).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import {
  createCausalMask,
  quantizedSdpa,
  quantizedSdpaTiled,
  quantizedSdpaUnfused,
  type Mask,
} from "../src/model/gemma4";

function randomFloats(n: number, seed: number): Float32Array {
  // deterministic LCG — no RNG dependency in tests
  const out = new Float32Array(n);
  let s = seed >>> 0;
  for (let i = 0; i < n; i++) {
    s = (s * 1664525 + 1013904223) >>> 0;
    out[i] = (s / 2 ** 32) * 2 - 1;
  }
  return out;
}

function bf16(data: Float32Array, shape: number[]): MlxArray {
  const f32 = MlxArray.fromFloat32(data, shape);
  const b = f32.astype(Dtype.bfloat16);
  f32.dispose();
  return b;
}

function maxAbsDiff(a: Float32Array, b: Float32Array): number {
  expect(a.length).toBe(b.length);
  let m = 0;
  for (let i = 0; i < a.length; i++) m = Math.max(m, Math.abs(a[i]! - b[i]!));
  return m;
}

const CAUSAL: Mask = { mode: "causal", arr: null };

interface Case {
  name: string;
  KV: number;
  nRep: number;
  L: number;
  N: number;
  D: number;
  group: number;
  bits: number;
}

// single tile / multi-tile with partial final tile / continuation
// (offset > 0) / no-GQA / the 12B full-attention shape (1 KV head)
const CASES: Case[] = [
  { name: "single-tile kv8", KV: 2, nRep: 4, L: 96, N: 448, D: 64, group: 64, bits: 8 },
  { name: "multi-tile kv8", KV: 2, nRep: 4, L: 96, N: 1217, D: 64, group: 64, bits: 8 },
  { name: "multi-tile kv4", KV: 2, nRep: 4, L: 96, N: 1217, D: 64, group: 64, bits: 4 },
  { name: "no-gqa kv8", KV: 4, nRep: 1, L: 64, N: 700, D: 64, group: 32, bits: 8 },
  { name: "12B-full-attn shape kv8", KV: 1, nRep: 16, L: 48, N: 1100, D: 512, group: 64, bits: 8 },
];

function makeInputs(c: Case, seed: number) {
  const H = c.KV * c.nRep;
  const q = bf16(randomFloats(H * c.L * c.D, seed), [1, H, c.L, c.D]);
  const k = bf16(randomFloats(c.KV * c.N * c.D, seed + 1), [1, c.KV, c.N, c.D]);
  const v = bf16(randomFloats(c.KV * c.N * c.D, seed + 2), [1, c.KV, c.N, c.D]);
  const kq = ops.quantize(k, c.group, c.bits);
  const vq = ops.quantize(v, c.group, c.bits);
  k.dispose();
  v.dispose();
  return { q, kq, vq };
}

function disposeInputs(i: ReturnType<typeof makeInputs>) {
  i.q.dispose();
  for (const t of [i.kq, i.vq]) {
    t.packed.dispose();
    t.scales.dispose();
    t.biases.dispose();
  }
}

describe("fused quantized SDPA vs unfused (tier b: online softmax)", () => {
  for (const c of CASES) {
    test(c.name, () => {
      const inp = makeInputs(c, 17);
      const tiled = quantizedSdpaTiled(inp.q, inp.kq, inp.vq, 0.125, CAUSAL, c.group, c.bits);
      const unfused = quantizedSdpaUnfused(inp.q, inp.kq, inp.vq, 0.125, CAUSAL, c.group, c.bits);
      const d = maxAbsDiff(tiled.toFloat32(), unfused.toFloat32());
      // outputs are attention-weighted means of values in [-1, 1];
      // measured max diff ≤ 0.0015 across all cases (≤ 0.2 bf16 ulp
      // at 1.0). Bound at 2/128 ≈ 10× margin.
      expect(d).toBeLessThanOrEqual(2 / 128);
      tiled.dispose();
      unfused.dispose();
      disposeInputs(inp);
    });
  }
});

describe("array continuation mask ≡ causal string", () => {
  test("offset>0 bool matrix gives byte-identical tiled output", () => {
    const c = CASES[1]!; // multi-tile kv8, offset = N - L = 1121
    const inp = makeInputs(c, 23);
    const viaString = quantizedSdpaTiled(inp.q, inp.kq, inp.vq, 1.0, CAUSAL, c.group, c.bits);
    const arr = createCausalMask(c.L, c.N - c.L, null);
    const viaArray = quantizedSdpaTiled(
      inp.q, inp.kq, inp.vq, 1.0, { mode: "array", arr }, c.group, c.bits,
    );
    arr.dispose();
    expect(maxAbsDiff(viaString.toFloat32(), viaArray.toFloat32())).toBe(0);
    viaString.dispose();
    viaArray.dispose();
    disposeInputs(inp);
  });
});

describe("dispatch gate", () => {
  test("L=1 (decode) stays on the unfused path", () => {
    const c: Case = { name: "", KV: 2, nRep: 4, L: 1, N: 600, D: 64, group: 64, bits: 8 };
    const inp = makeInputs(c, 31);
    const noMask: Mask = { mode: "", arr: null };
    const got = quantizedSdpa(inp.q, inp.kq, inp.vq, 1.0, noMask, c.group, c.bits);
    const want = quantizedSdpaUnfused(inp.q, inp.kq, inp.vq, 1.0, noMask, c.group, c.bits);
    expect(maxAbsDiff(got.toFloat32(), want.toFloat32())).toBe(0);
    got.dispose();
    want.dispose();
    disposeInputs(inp);
  });

  test("unsupported bits falls back to unfused", () => {
    // bits=2 quantizes fine in mlx but is outside the oracle's {4, 8}
    const c: Case = { name: "", KV: 2, nRep: 4, L: 64, N: 600, D: 64, group: 32, bits: 2 };
    const inp = makeInputs(c, 37);
    const got = quantizedSdpa(inp.q, inp.kq, inp.vq, 1.0, CAUSAL, c.group, c.bits);
    const want = quantizedSdpaUnfused(inp.q, inp.kq, inp.vq, 1.0, CAUSAL, c.group, c.bits);
    expect(maxAbsDiff(got.toFloat32(), want.toFloat32())).toBe(0);
    got.dispose();
    want.dispose();
    disposeInputs(inp);
  });

  test("L>1 causal goes through the tiled path", () => {
    const c = CASES[1]!;
    const inp = makeInputs(c, 41);
    const got = quantizedSdpa(inp.q, inp.kq, inp.vq, 1.0, CAUSAL, c.group, c.bits);
    const want = quantizedSdpaTiled(inp.q, inp.kq, inp.vq, 1.0, CAUSAL, c.group, c.bits);
    expect(maxAbsDiff(got.toFloat32(), want.toFloat32())).toBe(0);
    got.dispose();
    want.dispose();
    disposeInputs(inp);
  });
});

// --- Tier a: bit-exact vs the optiq oracle ------------------------------

interface GoldenTensor {
  offset: number;
  shape: number[];
}
interface GoldenCase {
  name: string;
  group_size: number;
  bits: number;
  scale: number;
  n_chunk: number;
  q: GoldenTensor;
  k: GoldenTensor;
  v: GoldenTensor;
  out: GoldenTensor;
}

const manifestFile = Bun.file("goldens/fused-sdpa.json");
const blobFile = Bun.file("goldens/fused-sdpa.bin");
const haveGoldens = (await manifestFile.exists()) && (await blobFile.exists());

describe.skipIf(!haveGoldens)("fused quantized SDPA vs optiq oracle (tier a)", async () => {
  if (!haveGoldens) return;
  const manifest = (await manifestFile.json()) as { cases: GoldenCase[] };
  const blob = new Float32Array(await blobFile.arrayBuffer());

  const load = (t: GoldenTensor): Float32Array =>
    blob.slice(t.offset, t.offset + t.shape.reduce((a, b) => a * b, 1));

  for (const g of manifest.cases) {
    test(`${g.name} bit-exact`, () => {
      expect(g.n_chunk).toBe(512); // FUSED_N_CHUNK must match the oracle
      const q = bf16(load(g.q), g.q.shape);
      const k = bf16(load(g.k), g.k.shape);
      const v = bf16(load(g.v), g.v.shape);
      const kq = ops.quantize(k, g.group_size, g.bits);
      const vq = ops.quantize(v, g.group_size, g.bits);
      k.dispose();
      v.dispose();
      const out = quantizedSdpaTiled(q, kq, vq, g.scale, CAUSAL, g.group_size, g.bits);
      expect(out.shape).toEqual(g.out.shape);
      expect(maxAbsDiff(out.toFloat32(), load(g.out))).toBe(0);
      out.dispose();
      q.dispose();
      for (const t of [kq, vq]) {
        t.packed.dispose();
        t.scales.dispose();
        t.biases.dispose();
      }
    });
  }
});
