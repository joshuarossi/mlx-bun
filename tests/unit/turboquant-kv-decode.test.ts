import { expect, test } from "bun:test";
import { MlxArray, cpuStream, gpuStream } from "../../src/mlx/array";
import { activeMemory, clearCache, Dtype, synchronize } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import * as tq from "../../src/mlx/turboquant-ops";
import { CompiledFunction } from "../../src/mlx/compile";
import { tryJointDecodePackedKv, type PackedKvArrays } from "../../src/mlx/turboquant-kv-decode";
import { LLOYD_MAX } from "../../src/mlx/turboquant-tables";

function fixture(dim: number, kb: number, vb: number, dtype = Dtype.float16,
  keyGroup = 32, valueGroup = 32, n = 17, edge = false) {
  const b = 2, h = 3, capacity = n + 7, owned: MlxArray[] = [];
  const own = (a: MlxArray) => { owned.push(a); return a; };
  const keyData = kb === 8
    ? Int8Array.from({ length: b * h * capacity * dim }, (_, i) => (i * 19 & 255) - 128)
    : Uint8Array.from({ length: b * h * capacity * dim }, (_, i) => i * 19 & (1 << kb) - 1);
  const rawK = own(MlxArray.fromBytesCopy(new Uint8Array(keyData.buffer), [b, h, capacity, dim], kb === 8 ? Dtype.int8 : Dtype.uint8));
  const rawV = own(MlxArray.fromBytesCopy(Uint8Array.from({ length: b * h * capacity * dim }, (_, i) => i * 17 & (1 << vb) - 1), [b, h, capacity, dim], Dtype.uint8));
  const kp = own(kb === 8 ? rawK : tq.packBits(rawK, kb)), vp = own(tq.packBits(rawV, vb));
  function metadata(group: number, kind: number) {
    const values = Float32Array.from({ length: b * h * capacity * dim / group }, (_, i) => {
      if (edge) return [0, -0, Infinity, -Infinity, NaN, 2 ** -24, 2 ** -14, 65504][(i * 3 + kind) % 8]!;
      return kind === 1 ? ((i * 13) % 127) - 63 + 0.1234567 : ((i * (kind + 7)) % 41 + 3) / (97 + kind * 7);
    });
    const f = own(MlxArray.fromFloat32(values, [b, h, capacity, dim / group]));
    return own(f.astype(dtype));
  }
  const full = [kp, metadata(keyGroup, 0), metadata(keyGroup, 1), vp, metadata(valueGroup, 2)];
  const inputs = full.map(a => own(a.slice([0, 0, 0, 0], [b, h, n, a.shape[3]!]))) as unknown as PackedKvArrays;
  const centroids = own(MlxArray.fromFloat32(new Float32Array(LLOYD_MAX[vb as keyof typeof LLOYD_MAX].centroids), [1 << vb]));
  return { inputs, centroids, dispose() { for (const a of new Set(owned)) a.dispose(); } };
}

function reference(inputs: PackedKvArrays, kb: number, vb: number, dim: number, defer: boolean): [MlxArray, MlxArray] {
  const [kp, ks, kz, vp, vs] = inputs;
  const ki = kb === 8 ? kp : tq.unpackBits(kp, kb, dim), vi = vb === 8 ? vp : tq.unpackBits(vp, vb, dim);
  try { return [tq.decodeKeys(ki, ks, kz), defer ? tq.decodeValuesRotated(vi, vs, vb) : tq.decodeValues(vi, vs, vb)]; }
  finally { if (ki !== kp) ki.dispose(); if (vi !== vp) vi.dispose(); }
}

function equalBytes(a: MlxArray, b: MlxArray): void {
  const ac = ops.contiguous(a), bc = ops.contiguous(b);
  try { expect(a.shape).toEqual(b.shape); expect(a.dtype).toBe(b.dtype); expect(Buffer.from(ac.rawBytesView()).equals(Buffer.from(bc.rawBytesView()))).toBe(true); }
  finally { ac.dispose(); bc.dispose(); }
}

// These matrices evaluate many Metal kernel variants. The macOS CI runner
// took 4.2s and 5.6s respectively; allow compilation and runner variability.
const MATRIX_TIMEOUT_MS = 30_000;

test("packed KV fusion preserves every served bit combination on strided cache windows", () => {
  for (const kb of [2, 4, 5, 8]) for (const vb of [2, 3, 4, 5, 8]) {
    const f = fixture(256, kb, vb);
    try {
      for (const defer of [false, true]) {
        const expected = reference(f.inputs, kb, vb, 256, defer);
        const actual = tq.tryDecodePackedKv(f.inputs, kb, vb, 256, defer);
        try { expect(actual).not.toBeNull(); for (let i = 0; i < 2; i++) equalBytes(actual![i]!, expected[i]!); }
        finally { for (const a of expected) a.dispose(); for (const a of actual ?? []) a.dispose(); }
      }
      for (const a of f.inputs) expect(() => a.handle).not.toThrow();
    } finally { f.dispose(); }
  }
}, MATRIX_TIMEOUT_MS);

test("packed KV fusion preserves head dimensions, independent groups, dtypes and nonfinite codec values", () => {
  for (const dim of [64, 128, 256, 512]) for (const dtype of [Dtype.float16, Dtype.bfloat16, Dtype.float32])
    for (const [kg, vg] of [[32, 64], [64, 32]] as const) for (const edge of [false, true]) {
      const f = fixture(dim, 8, 3, dtype, kg, vg, 5, edge);
      try {
        for (const defer of [false, true]) {
          const expected = reference(f.inputs, 8, 3, dim, defer), actual = tq.tryDecodePackedKv(f.inputs, 8, 3, dim, defer);
          try { expect(actual).not.toBeNull(); for (let i = 0; i < 2; i++) equalBytes(actual![i]!, expected[i]!); }
          finally { for (const a of expected) a.dispose(); for (const a of actual ?? []) a.dispose(); }
        }
      } finally { f.dispose(); }
    }
}, MATRIX_TIMEOUT_MS);

test("packed KV eligibility delegates unsupported streams, shapes, formats and empty windows", () => {
  const f = fixture(256, 8, 3);
  const apply = (inputs: PackedKvArrays, kb = 8, vb = 3, dim = 256) => tryJointDecodePackedKv(inputs, f.centroids, kb, vb, dim, false);
  try {
    expect(tryJointDecodePackedKv(f.inputs, f.centroids, 8, 3, 256, false, cpuStream)).toBeNull();
    for (const bits of [0, 1, 6, 7, 9]) { expect(apply(f.inputs, bits)).toBeNull(); expect(apply(f.inputs, 8, bits)).toBeNull(); }
    for (const dim of [32, 48, 96, 255, 1024]) expect(apply(f.inputs, 8, 3, dim)).toBeNull();
    for (const slot of [0, 1, 2, 3, 4]) {
      const bad = ops.zeros([1], f.inputs[slot]!.dtype), args = [...f.inputs]; args[slot] = bad;
      try { expect(apply(args as unknown as PackedKvArrays)).toBeNull(); } finally { bad.dispose(); }
    }
    const badKey = f.inputs[0].astype(Dtype.uint8);
    try { expect(apply([badKey, ...f.inputs.slice(1)] as unknown as PackedKvArrays)).toBeNull(); } finally { badKey.dispose(); }
    const empty = f.inputs.map(a => a.slice([0, 0, 0, 0], [2, 3, 0, a.shape[3]!]));
    try { expect(apply(empty as unknown as PackedKvArrays)).toBeNull(); } finally { for (const a of empty) a.dispose(); }
    for (const a of f.inputs) expect(() => a.handle).not.toThrow();
  } finally { f.dispose(); }
});

test("shapeless compilation declines packed decode and restores ordinary dispatch", () => {
  let fallbacks = 0;
  const compiled = new CompiledFunction(a => {
    const inputs = a.slice(0, 5) as unknown as PackedKvArrays;
    expect(tryJointDecodePackedKv(inputs, a[5]!, 8, 3, 256, true)).toBeNull(); fallbacks++;
    return [ops.add(inputs[0], inputs[0])];
  }, true);
  try {
    for (const n of [5, 17, 5]) {
      const f = fixture(256, 8, 3, Dtype.float16, 32, 32, n);
      try {
        const actual = compiled.apply([...f.inputs, f.centroids]), expected = [ops.add(f.inputs[0], f.inputs[0])];
        try {
          equalBytes(actual[0]!, expected[0]!);
          const direct = tryJointDecodePackedKv(f.inputs, f.centroids, 8, 3, 256, true);
          expect(direct).not.toBeNull(); for (const a of direct ?? []) a.dispose();
        }
        finally { for (const a of [...actual, ...expected]) a.dispose(); }
      } finally { f.dispose(); }
    }
    expect(fallbacks).toBe(1); expect(compiled.traceCount).toBe(1);
  } finally { compiled.dispose(); }
});

test("repeated packed KV outputs release storage without consuming their inputs", () => {
  const f = fixture(256, 8, 3, Dtype.float16, 32, 32, 129);
  try {
    const run = () => { const pair = tq.tryDecodePackedKv(f.inputs, 8, 3, 256, false)!; try { ops.evalAll(pair); } finally { for (const a of pair) a.dispose(); } };
    run(); synchronize(gpuStream); clearCache(); const before = activeMemory();
    for (let i = 0; i < 32; i++) run();
    synchronize(gpuStream); clearCache(); expect(activeMemory()).toBe(before);
    const expected = reference(f.inputs, 8, 3, 256, false), actual = tq.tryDecodePackedKv(f.inputs, 8, 3, 256, false)!;
    try { equalBytes(actual[0], expected[0]); equalBytes(actual[1], expected[1]); }
    finally { for (const a of [...actual, ...expected]) a.dispose(); }
  } finally { f.dispose(); }
});
