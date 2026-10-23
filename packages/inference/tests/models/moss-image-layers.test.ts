// MOSS-Image's own layers against host-double references written from the
// formulas in this file, never from the layers' own operations: the SITU kernel,
// the four projection forms and the dense forms' ownership of their transposed
// view, the four-axis RoPE (frequencies, coordinates and rotation), the
// timestep sinusoid, the conditioner's (1 + gamma) float32 norm and its partial
// rotary embedding, its bf16 l2norm and gated norm (host replays of torch's
// per-operation rounding), and the float32 gated delta kernel (float64
// equivalence only; its float32 rounding is measured against the reference in
// tests/parity/moss-image-oracle.test.ts).
import { expect, test } from "bun:test";
import { MlxArray, gpuStream } from "@mlx-bun/mlx/array";
import { Dtype, activeMemory, clearCache, synchronize } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { situ } from "../../src/kernels/situ";
import { timestepSinusoid } from "../../src/models/moss-image/blocks";
import { parseQuantization } from "../../src/artifacts/config";
import { MossDenseBiasedLinear, MossDenseLinear, MossQuantizedBiasedLinear, MossQuantizedLinear, storedAffineSpec } from "../../src/models/moss-image/layers";
import { MossRope, mossRopeBands, mossRopeCoordinates } from "../../src/models/moss-image/rope";
import { MossTextGatedNorm, MossTextL2Norm, MossTextRmsNorm, MossTextRope } from "../../src/models/moss-image/text-layers";
import { gatedDeltaFloat32 } from "../../src/kernels/gated-delta-float32";

const ramp = (n: number, phase: number, scale = 1) => Float32Array.from({ length: n }, (_, i) => scale * Math.sin(i * 0.37 + phase));
const close = (actual: Float32Array, expected: ArrayLike<number>, tolerance: number) => {
  expect(actual.length).toBe(expected.length);
  for (let i = 0; i < actual.length; i++) expect(Math.abs(actual[i]! - expected[i]!)).toBeLessThanOrEqual(tolerance * Math.max(1, Math.abs(expected[i]!)));
};

test("the SITU kernel computes (4 tanh(g/4) sigmoid(g)) (25 tanh(h/25))", () => {
  const h = ramp(256, 0.3, 60), g = ramp(256, 1.1, 12);
  using hidden = MlxArray.fromFloat32(h, [256]), gate = MlxArray.fromFloat32(g, [256]);
  using out = situ(hidden, gate);
  const expected = Array.from(h, (x, i) => 4 * Math.tanh(g[i]! / 4) / (1 + Math.exp(-g[i]!)) * 25 * Math.tanh(x / 25));
  close(out.toFloat32(), expected, 1e-5);
});

test("the projection forms compute x @ w.T (+ bias), dense and affine-quantized", () => {
  const rows = 3, inner = 64, out = 8;
  const xs = ramp(rows * inner, 0.2), ws = ramp(out * inner, 0.9, 0.5), bs = ramp(out, 1.7);
  using x = MlxArray.fromFloat32(xs, [rows, inner]), w = MlxArray.fromFloat32(ws, [out, inner]), b = MlxArray.fromFloat32(bs, [out]);
  const reference = (weights: ArrayLike<number>, bias: ArrayLike<number> | null) => Array.from({ length: rows * out }, (_, i) => {
    const r = Math.floor(i / out), o = i % out;
    let sum = bias ? bias[o]! : 0;
    for (let k = 0; k < inner; k++) sum += xs[r * inner + k]! * weights[o * inner + k]!;
    return sum;
  });
  const dense = new MossDenseLinear(w), biased = new MossDenseBiasedLinear(w, b);
  { using y = dense.forward(x); close(y.toFloat32(), reference(ws, null), 1e-5); }
  { using y = biased.forward(x); close(y.toFloat32(), reference(ws, bs), 1e-5); }
  dense.dispose(); biased.dispose();
  const q = ops.quantize(w, 64, 8);
  try {
    // The reference uses the dequantized weights, so the comparison checks the binding, not quantization error.
    using restored = ops.dequantize(q.packed, q.scales, q.biases, { bits: 8, groupSize: 64, mode: "affine" });
    const deq = restored.toFloat32();
    const spec = { bits: 8, groupSize: 64, mode: "affine" };
    const quantized = new MossQuantizedLinear(q.packed, q.scales, q.biases!, spec);
    const quantizedBiased = new MossQuantizedBiasedLinear(q.packed, q.scales, q.biases!, spec, b);
    { using y = quantized.forward(x); close(y.toFloat32(), reference(deq, null), 1e-4); }
    { using y = quantizedBiased.forward(x); close(y.toFloat32(), reference(deq, bs), 1e-4); }
  } finally { q.packed.dispose(); q.scales.dispose(); q.biases?.dispose(); }
});

test("a dense projection frees only its transposed view: the borrowed weight stays valid, and its buffer is released with both", async () => {
  const ws = ramp(16, 0.4);
  using w = MlxArray.fromFloat32(ws, [4, 4]);
  using x = MlxArray.fromFloat32(ramp(4, 2), [1, 4]);
  const layer = new MossDenseLinear(w);
  using lazy = layer.forward(x); // built before dispose
  layer.dispose();
  layer.dispose(); // a second dispose is a no-op
  expect(Array.from(w.toFloat32())).toEqual(Array.from(ws));
  expect(lazy.toFloat32().length).toBe(4);
  // The view alone keeps a released weight's buffer: dispose returns it. Buffers return when their command buffers
  // complete, so each reading waits for the GPU stream (and, for the release, polls briefly).
  const settled = () => { synchronize(gpuStream); clearCache(); return activeMemory(); };
  const elements = 1 << 22, bytes = elements * 4; // 16 MiB, far above incidental allocations
  const big = MlxArray.fromFloat32(new Float32Array(elements).fill(0.5), [2048, 2048]);
  big.eval();
  const holder = new MossDenseLinear(big);
  { using input = MlxArray.fromFloat32(new Float32Array(2048), [1, 2048]); using y = holder.forward(input); y.eval(); }
  const held = settled();
  big.dispose();
  await Bun.sleep(20);
  expect(held - settled()).toBeLessThan(bytes); // still held by the view
  holder.dispose();
  const deadline = performance.now() + 2000;
  while (held - settled() < bytes && performance.now() < deadline) await Bun.sleep(5);
  expect(held - settled()).toBeGreaterThanOrEqual(bytes);
});

test("the RoPE frequencies equal the reference's float32 bands for a 128-dim head", () => {
  // torch: 1 / (10000 ** (arange(16, float32) / 16)) on the CPU, as printed by the reference environment.
  expect(Array.from(mossRopeBands(128, 10000))).toEqual([1, 0.5623413324356079, 0.3162277638912201, 0.17782793939113617,
    0.10000000149011612, 0.05623412877321243, 0.03162277862429619, 0.017782794311642647, 0.009999999776482582,
    0.005623413249850273, 0.003162277862429619, 0.0017782794311642647, 0.0010000000474974513, 0.000562341301701963,
    0.0003162277862429619, 0.00017782794020604342]);
});

test("positions are image tokens in raster order, centred, then text tokens", () => {
  expect(Array.from(mossRopeCoordinates(2, 3, 2))).toEqual([
    0, 2, -0.5, -1, 0, 2, -0.5, 0, 0, 2, -0.5, 1,
    0, 2, 0.5, -1, 0, 2, 0.5, 0, 0, 2, 0.5, 1,
    0, 0, 0, 0, 0, 1, 0, 0,
  ]);
});

test("the rotation turns pair (a K + k, a K + k + D/2) by coordinate[a] * band[k]", () => {
  const head = 16, heads = 2, rope = new MossRope(head, 10000);
  const layout = rope.layout(1, 2, 1); // three positions
  const positions = 3, values = ramp(positions * heads * head, 0.6);
  using x = MlxArray.fromFloat32(values, [1, positions, heads, head]);
  using narrow = x.astype(Dtype.bfloat16), wide = narrow.astype(Dtype.float32);
  const xs = wide.toFloat32();
  using rotated = rope.apply(wide, layout.joint);
  const coordinates = mossRopeCoordinates(1, 2, 1), bands = mossRopeBands(head, 10000), half = head / 2;
  const expected = new Float32Array(xs.length);
  for (let n = 0; n < positions; n++) for (let h = 0; h < heads; h++) for (let j = 0; j < half; j++) {
    const angle = Math.fround(coordinates[n * 4 + Math.floor(j / bands.length)]! * bands[j % bands.length]!);
    const at = (c: number) => (n * heads + h) * head + c;
    // The tables are bf16, as the reference casts them.
    const c = bf16(Math.cos(angle)), s = bf16(Math.sin(angle));
    expected[at(j)] = xs[at(j)]! * c - xs[at(j + half)]! * s;
    expected[at(j + half)] = xs[at(j + half)]! * c + xs[at(j)]! * s;
  }
  close(rotated.toFloat32(), expected, 1e-5);
  rope.dispose();
});

/** Round a double to the nearest bfloat16 (ties to even), as a number. */
function bf16(value: number): number {
  const bits = new Uint32Array(new Float32Array([value]).buffer)[0]!;
  const rounded = (bits + 0x7fff + ((bits >> 16) & 1)) & 0xffff0000;
  return new Float32Array(new Uint32Array([rounded]).buffer)[0]!;
}

test("the timestep sinusoid is cat(cos(t f), sin(t f)) with f_k = 10000 ** (-k / half)", () => {
  const values = timestepSinusoid(463.0000305175781, 8);
  const expected = [0, 1, 2, 3].flatMap(k => [Math.cos(463.0000305175781 * 10000 ** (-k / 4))])
    .concat([0, 1, 2, 3].map(k => Math.sin(463.0000305175781 * 10000 ** (-k / 4))));
  expect(Array.from(values)).toEqual(Array.from(Float32Array.from(expected)));
});

test("the conditioner norm scales by (1 + gamma) in float32 and casts once", () => {
  const width = 8, xs = ramp(2 * width, 0.1, 3), gamma = ramp(width, 0.5, 0.2);
  using x = MlxArray.fromFloat32(xs, [2, width]), g = MlxArray.fromFloat32(gamma, [width]);
  const norm = new MossTextRmsNorm(g, 1e-6);
  using out = norm.forward(x);
  const expected = Array.from(xs, (v, i) => {
    const row = Math.floor(i / width), mean = xs.slice(row * width, (row + 1) * width).reduce((a, b) => a + b * b, 0) / width;
    return v / Math.sqrt(mean + 1e-6) * (1 + gamma[i % width]!);
  });
  close(out.toFloat32(), expected, 1e-5);
  norm.dispose();
});

test("the conditioner's partial rotary embedding rotates the first dims of each head and passes the rest through", () => {
  const head = 16, rotary = 4, length = 3, rope = new MossTextRope(rotary, 10000000);
  const values = ramp(length * head, 0.8);
  using x = MlxArray.fromFloat32(values, [1, length, 1, head]);
  using tables = rope.tables(length);
  using out = rope.apply(x, tables);
  const actual = out.toFloat32(), half = rotary / 2;
  for (let p = 0; p < length; p++) {
    for (let k = 0; k < half; k++) {
      const angle = Math.fround(p * Math.fround(1 / Math.fround(Math.pow(10000000, Math.fround((2 * k) / rotary)))));
      const c = bf16(Math.cos(angle)), s = bf16(Math.sin(angle));
      const a = values[p * head + k]!, b = values[p * head + half + k]!;
      expect(Math.abs(actual[p * head + k]! - (a * c - b * s))).toBeLessThan(1e-5);
      expect(Math.abs(actual[p * head + half + k]! - (b * c + a * s))).toBeLessThan(1e-5);
    }
    for (let d = rotary; d < head; d++) expect(actual[p * head + d]).toBe(values[p * head + d]!);
  }
});

test("a projection binds as the checkpoint stores it, and inconsistent quantization metadata fails", () => {
  const weights = (names: string[]) => ({ has: (name: string) => names.includes(name) }) as unknown as Parameters<typeof storedAffineSpec>[0];
  const config = (quantization: Record<string, unknown> | undefined) =>
    ({ quantization: parseQuantization(quantization) }) as unknown as Parameters<typeof storedAffineSpec>[1];
  const table = { bits: 8, group_size: 64, "p.explicit": { bits: 4 }, "p.kept": false };
  // Stored quantized under the table's default or its own entry; stored dense with no entry of its own (a shape the quantizer skipped).
  expect(storedAffineSpec(weights(["p.weight", "p.scales", "p.biases"]), config(table), "p")).toMatchObject({ bits: 8, groupSize: 64, mode: "affine" });
  expect(storedAffineSpec(weights(["p.explicit.scales", "p.explicit.biases"]), config(table), "p.explicit")).toMatchObject({ bits: 4 });
  expect(storedAffineSpec(weights(["p.weight"]), config(table), "p")).toBeNull();
  expect(storedAffineSpec(weights(["p.kept.weight"]), config(table), "p.kept")).toBeNull();
  expect(storedAffineSpec(weights(["p.weight"]), config(undefined), "p")).toBeNull();
  // Inconsistent metadata never downgrades silently.
  expect(() => storedAffineSpec(weights(["p.explicit.weight"]), config(table), "p.explicit")).toThrow("quantizes it but the checkpoint stores it dense");
  expect(() => storedAffineSpec(weights(["p.scales", "p.biases"]), config(undefined), "p")).toThrow("no entry for it");
  expect(() => storedAffineSpec(weights(["p.kept.scales", "p.kept.biases"]), config(table), "p.kept")).toThrow("no entry for it");
  expect(() => storedAffineSpec(weights(["p.scales", "p.biases"]), config({ bits: 4, group_size: 32, mode: "mxfp4" }), "p")).toThrow("affine only");
  expect(() => storedAffineSpec(weights(["p.scales"]), config(table), "p")).toThrow("no .biases");
});

/** A host replay of one torch operation on bf16 values: the float32 result, stored in bf16. */
const stored = (value: number) => bf16(Math.fround(value));

test("the conditioner's l2norm replays torch's bf16 operations one by one, which rounding once in float32 does not", () => {
  const width = 128, rows = 8, xs = Float32Array.from(ramp(rows * width, 0.4, 3), bf16);
  using x32 = MlxArray.fromFloat32(xs, [rows, width]);
  using x = x32.astype(Dtype.bfloat16);
  using out = new MossTextL2Norm().forward(x);
  using wide = out.astype(Dtype.float32);
  const actual = wide.toFloat32(), perOperation: number[] = [], roundedOnce: number[] = [];
  for (let r = 0; r < rows; r++) {
    const row = xs.slice(r * width, (r + 1) * width);
    // x * x, .sum(-1), + 1e-6, rsqrt (a square root, then its reciprocal), x * inv: each computed in float32 and stored in bf16.
    const sum = stored(row.reduce((acc, v) => acc + stored(v * v), 0));
    const inverse = stored(1 / stored(Math.sqrt(stored(sum + Math.fround(1e-6)))));
    for (const v of row) perOperation.push(stored(v * inverse));
    const wideInverse = 1 / Math.sqrt(row.reduce((acc, v) => acc + v * v, 0) + 1e-6);
    for (const v of row) roundedOnce.push(bf16(v * wideInverse));
  }
  expect(Array.from(actual)).toEqual(perOperation);
  // The replay is sensitive to the order: rounding only at the end gives different values on this input.
  expect(perOperation.filter((v, i) => v !== roundedOnce[i]).length).toBeGreaterThan(0);
});

test("the conditioner's gated norm replays Qwen3_5RMSNormGated: float32 normalization stored in bf16, the bf16 weight, then silu(gate) in float32", () => {
  const width = 128, rows = 4;
  const xs = Float32Array.from(ramp(rows * width, 0.2, 2), bf16), gates = Float32Array.from(ramp(rows * width, 1.3, 4), bf16);
  const weights = Float32Array.from(ramp(width, 0.7, 0.5), v => bf16(1 + v));
  using x32 = MlxArray.fromFloat32(xs, [rows, width]), g32 = MlxArray.fromFloat32(gates, [rows, width]), w32 = MlxArray.fromFloat32(weights, [width]);
  using x = x32.astype(Dtype.bfloat16), gate = g32.astype(Dtype.bfloat16), weight = w32.astype(Dtype.bfloat16);
  using out = new MossTextGatedNorm(weight, 1e-6).forward(x, gate);
  using wide = out.astype(Dtype.float32);
  const actual = wide.toFloat32(), expected: number[] = [];
  for (let r = 0; r < rows; r++) {
    const row = xs.slice(r * width, (r + 1) * width);
    const inverse = Math.fround(1 / Math.fround(Math.sqrt(Math.fround(Math.fround(row.reduce((acc, v) => acc + v * v, 0) / width) + Math.fround(1e-6)))));
    for (let i = 0; i < width; i++) {
      const weighted = stored(weights[i]! * stored(row[i]! * inverse)), g = gates[r * width + i]!;
      expected.push(bf16(weighted * Math.fround(g / (1 + Math.exp(-g)))));
    }
  }
  // Float32 transcendentals (exp in SiLU) and this replay's exact sum may move a value by one bf16 step at a rounding boundary.
  let differing = 0;
  for (let i = 0; i < expected.length; i++) {
    if (actual[i] === expected[i]) continue;
    differing++;
    expect(Math.abs(actual[i]! - expected[i]!)).toBeLessThanOrEqual(Math.abs(expected[i]!) * 2 ** -7);
  }
  expect(differing).toBeLessThanOrEqual(expected.length / 100);
});

test("the float32 gated delta kernel computes the sequential recurrence (float64 host equivalence only; float32 rounding against the reference is the opt-in oracle comparison's)", () => {
  const B = 1, T = 7, Hk = 1, Hv = 2, Dk = 32, Dv = 4;
  const q = ramp(B * T * Hk * Dk, 0.1, 0.3), k = ramp(B * T * Hk * Dk, 0.9, 0.3), v = ramp(B * T * Hv * Dv, 1.7);
  const decay = Float32Array.from(ramp(B * T * Hv, 0.5, 0.2), x => Math.fround(0.75 + x)), beta = Float32Array.from(ramp(B * T * Hv, 2.1, 0.3), x => Math.fround(0.5 + x));
  using qa = MlxArray.fromFloat32(q, [B, T, Hk, Dk]), ka = MlxArray.fromFloat32(k, [B, T, Hk, Dk]), va = MlxArray.fromFloat32(v, [B, T, Hv, Dv]);
  using da = MlxArray.fromFloat32(decay, [B, T, Hv]), ba = MlxArray.fromFloat32(beta, [B, T, Hv]);
  using y = gatedDeltaFloat32(qa, ka, va, da, ba);
  expect(y.dtype).toBe(Dtype.float32);
  const actual = y.toFloat32(), expected = new Float64Array(B * T * Hv * Dv);
  for (let hv = 0; hv < Hv; hv++) {
    const hk = Math.floor(hv / (Hv / Hk)), state = Array.from({ length: Dv }, () => new Float64Array(Dk));
    for (let t = 0; t < T; t++) {
      const kt = (d: number) => k[(t * Hk + hk) * Dk + d]!, qt = (d: number) => q[(t * Hk + hk) * Dk + d]!;
      const g = decay[t * Hv + hv]!, b = beta[t * Hv + hv]!;
      for (let dv = 0; dv < Dv; dv++) {
        const s = state[dv]!;
        let memory = 0;
        for (let d = 0; d < Dk; d++) { s[d]! *= g; memory += s[d]! * kt(d); }
        const delta = (v[(t * Hv + hv) * Dv + dv]! - memory) * b;
        let out = 0;
        for (let d = 0; d < Dk; d++) { s[d]! += kt(d) * delta; out += s[d]! * qt(d); }
        expected[(t * Hv + hv) * Dv + dv] = out;
      }
    }
  }
  close(actual, expected, 1e-5);
});

test("the conditioner's gated norm sums each row's variance in the pinned torch's order, so it equals a host replay of that order exactly", () => {
  const width = 128, rows = 16384, total = rows * width;
  // Deterministic, roughly normal bf16 values; gates large enough that silu(g) = g exactly in float32, so only the variance's
  // summation order can move an output.
  let seed = 0x2545f491;
  const uniform = () => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return (seed + 0.5) / 2 ** 32; };
  const normal = () => Math.sqrt(-2 * Math.log(uniform())) * Math.cos(2 * Math.PI * uniform());
  const xs = Float32Array.from({ length: total }, () => bf16(normal()));
  const gates = Float32Array.from({ length: total }, () => bf16(40 + uniform()));
  const weights = Float32Array.from({ length: width }, () => bf16(1 + 0.1 * normal()));
  using x32 = MlxArray.fromFloat32(xs, [rows, width]), g32 = MlxArray.fromFloat32(gates, [rows, width]), w32 = MlxArray.fromFloat32(weights, [width]);
  using x = x32.astype(Dtype.bfloat16), gate = g32.astype(Dtype.bfloat16), weight = w32.astype(Dtype.bfloat16);
  using out = new MossTextGatedNorm(weight, 1e-6).forward(x, gate);
  using wide = out.astype(Dtype.float32);
  const actual = wide.toFloat32();
  /** torch's order: four 4-lane accumulators (value i into accumulator floor(i / 4) % 4, lane i % 4), then the accumulators
   * lane by lane, then the lanes, each in order. */
  const torchSum = (row: Float32Array) => {
    const accumulators = Array.from({ length: 4 }, () => [0, 0, 0, 0]);
    for (let i = 0; i < width; i++) accumulators[Math.floor(i / 4) % 4]![i % 4] = Math.fround(accumulators[Math.floor(i / 4) % 4]![i % 4]! + Math.fround(row[i]! * row[i]!));
    const lanes = [0, 1, 2, 3].map(l => accumulators.reduce((sum, accumulator) => Math.fround(sum + accumulator[l]!), 0));
    return lanes.reduce((sum, lane) => Math.fround(sum + lane), 0);
  };
  let differing = 0;
  for (let r = 0; r < rows; r++) {
    const row = xs.subarray(r * width, (r + 1) * width);
    const inverse = Math.fround(1 / Math.fround(Math.sqrt(Math.fround(Math.fround(torchSum(row) / width) + Math.fround(1e-6)))));
    for (let i = 0; i < width; i++) {
      const g = gates[r * width + i]!, weighted = stored(weights[i]! * stored(row[i]! * inverse));
      if (actual[r * width + i] !== bf16(weighted * Math.fround(g / Math.fround(1 + Math.exp(-g))))) differing++;
    }
  }
  expect(differing).toBe(0);
}, 60_000);
