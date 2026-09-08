import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { MlxArray, gpuStream, cpuStream } from "../../src/mlx/array";
import { Dtype, activeMemory, clearCache, synchronize } from "../../src/mlx/ffi";
import { CompiledFunction } from "../../src/mlx/compile";
import * as ops from "../../src/mlx/ops";
import * as tq from "../../src/mlx/turboquant-ops";
import { LLOYD_MAX, SIGN_VECTORS } from "../../src/mlx/turboquant-tables";
import { type PackedKvArrays } from "../../src/mlx/turboquant-kv-decode";
import { tryDecodePackedKvInverse256 } from "../../src/mlx/turboquant-kv-inverse";

const nonfinite = [0, -0, 2 ** -24, -(2 ** -24), 65504, Infinity, -Infinity, NaN];

function metadata(n: number, unusual: boolean, seed: number): MlxArray {
  const data = new Float32Array(4 * n * 8);
  for (let i = 0; i < data.length; i++)
    data[i] = unusual ? nonfinite[(i + seed) % nonfinite.length]! : ((i + seed) % 23 + 1) / 64;
  const raw = MlxArray.fromFloat32(data, [1, 4, n, 8]);
  try { return raw.astype(Dtype.float16).eval(); }
  finally { raw.dispose(); }
}

function fixture(n: number, strided: boolean, unusual = false): MlxArray[] {
  const capacity = n + (strided ? 3 : 0);
  const codes = new Int8Array(4 * capacity * 256);
  const packed = new Uint8Array(4 * capacity * 96);
  for (let i = 0; i < codes.length; i++) codes[i] = (i * 71 + 19) % 256 - 128;
  for (let i = 0; i < packed.length; i++) packed[i] = (i * 59 + 17) % 256;
  const inputs = [
    MlxArray.fromBytesCopy(new Uint8Array(codes.buffer), [1, 4, capacity, 256], Dtype.int8),
    metadata(capacity, unusual, 0), metadata(capacity, unusual, 3),
    MlxArray.fromBytesCopy(packed, [1, 4, capacity, 96], Dtype.uint8),
    metadata(capacity, unusual, 5),
  ];
  if (!strided) return inputs;
  const cuts = inputs.map(a => a.slice([0, 0, 0, 0], [1, 4, n, a.shape[3]!]));
  for (const a of inputs) a.dispose();
  return cuts;
}

function digest(a: MlxArray): string {
  const contiguous = ops.contiguous(a);
  try { return createHash("sha256").update(contiguous.rawBytesView()).digest("hex"); }
  finally { contiguous.dispose(); }
}

function reference(inputs: MlxArray[]): MlxArray[] {
  const key = tq.decodeKeys(inputs[0]!, inputs[1]!, inputs[2]!);
  const indices = tq.unpackBits(inputs[3]!, 3, 256);
  try { return [key, tq.decodeValues(indices, inputs[4]!, 3)]; }
  finally { indices.dispose(); }
}

function cleanup(): void { synchronize(gpuStream); clearCache(); }

function withTables(fn: (centroids: MlxArray, signs: MlxArray) => void): void {
  const centroids = MlxArray.fromFloat32(new Float32Array(LLOYD_MAX[3].centroids), [8]);
  const signs = MlxArray.fromFloat32(new Float32Array(SIGN_VECTORS[256]), [256]);
  try { fn(centroids, signs); }
  finally { centroids.dispose(); signs.dispose(); cleanup(); }
}

test("inverse KV decode preserves reference bytes at the threshold and padded row groups", () => {
  withTables((centroids, signs) => {
    // Warm the reference codec's persistent tables before ownership checks.
    const prime = fixture(16, false);
    try {
      const out = reference(prime);
      try { ops.evalAll(out); } finally { for (const a of out) a.dispose(); }
    } finally { for (const a of prime) a.dispose(); cleanup(); }
    const baseline = activeMemory();
    for (const n of [8191, 8192, 8193, 8207, 8208]) {
      for (const strided of [false, true]) for (const unusual of [false, true]) {
        const inputs = fixture(n, strided, unusual);
        try {
          ops.evalAll(inputs);
          const before = inputs.map(digest);
          const out = tryDecodePackedKvInverse256(
            inputs as unknown as PackedKvArrays, centroids, signs, 8, 3, 256,
          );
          expect(out !== null).toBe(n >= 8192);
          if (out) {
            const expected = reference(inputs);
            try {
              expect(out.map(a => a.shape)).toEqual(expected.map(a => a.shape));
              expect(out.map(a => a.dtype)).toEqual([Dtype.bfloat16, Dtype.bfloat16]);
              expect(out.map(digest)).toEqual(expected.map(digest));
            } finally { for (const a of [...out, ...expected]) a.dispose(); }
          }
          expect(inputs.map(digest)).toEqual(before);
        } finally { for (const a of inputs) a.dispose(); cleanup(); }
        expect(activeMemory()).toBe(baseline);
      }
    }
  });
}, 60_000);

test("inverse KV decode declines other formats, layouts and streams without taking ownership", () => {
  withTables((centroids, signs) => {
    const inputs = fixture(8192, false);
    try {
      const tuple = inputs as unknown as PackedKvArrays;
      const before = inputs.map(digest);
      expect(tryDecodePackedKvInverse256(tuple, centroids, signs, 8, 3, 256, cpuStream)).toBeNull();
      expect(tryDecodePackedKvInverse256(tuple, centroids, signs, 4, 3, 256)).toBeNull();
      expect(tryDecodePackedKvInverse256(tuple, centroids, signs, 8, 4, 256)).toBeNull();
      expect(tryDecodePackedKvInverse256(tuple, centroids, signs, 8, 3, 128)).toBeNull();
      for (const index of [1, 2, 4]) {
        const cast = inputs[index]!.astype(Dtype.float32);
        try {
          const changed = [...inputs]; changed[index] = cast;
          expect(tryDecodePackedKvInverse256(
            changed as unknown as PackedKvArrays, centroids, signs, 8, 3, 256,
          )).toBeNull();
        } finally { cast.dispose(); }
      }
      const halfHeads = inputs[0]!.slice([0, 0, 0, 0], [1, 2, 8192, 256]);
      try {
        expect(tryDecodePackedKvInverse256(
          [halfHeads, ...inputs.slice(1)] as unknown as PackedKvArrays,
          centroids, signs, 8, 3, 256,
        )).toBeNull();
      } finally { halfHeads.dispose(); }
      expect(inputs.map(digest)).toEqual(before);
    } finally { for (const a of inputs) a.dispose(); }
  });
}, 30_000);

test("inverse KV decode reads strided centroid and sign tables", () => {
  const inputs = fixture(8193, true);
  const tables = [LLOYD_MAX[3].centroids, SIGN_VECTORS[256]].map(values => {
    const raw = MlxArray.fromFloat32(Float32Array.from(values.flatMap(v => [v, 19])), [values.length, 2]);
    const column = raw.slice([0, 0], [values.length, 1]);
    try { return ops.reshape(column, [values.length]); }
    finally { column.dispose(); raw.dispose(); }
  });
  try {
    const before = [...inputs, ...tables].map(digest);
    const out = tryDecodePackedKvInverse256(
      inputs as unknown as PackedKvArrays, tables[0]!, tables[1]!, 8, 3, 256,
    );
    expect(out).not.toBeNull();
    const expected = reference(inputs);
    try { expect(out!.map(digest)).toEqual(expected.map(digest)); }
    finally { for (const a of [...out!, ...expected]) a.dispose(); }
    expect([...inputs, ...tables].map(digest)).toEqual(before);
  } finally { for (const a of [...inputs, ...tables]) a.dispose(); cleanup(); }
}, 30_000);

test("inverse KV decode declines shapeless traces before reading input shapes", () => {
  withTables((centroids, signs) => {
    let traces = 0;
    const compiled = new CompiledFunction(xs => {
      traces++;
      expect(tryDecodePackedKvInverse256(
        xs as unknown as PackedKvArrays, centroids, signs, 8, 3, 256,
      )).toBeNull();
      return [ops.add(xs[0]!, xs[0]!)];
    });
    try {
      for (const n of [8192, 8193]) {
        const inputs = fixture(n, true);
        try {
          const out = compiled.apply(inputs);
          const expected = ops.add(inputs[0]!, inputs[0]!);
          try { expect(out.map(digest)).toEqual([digest(expected)]); }
          finally { for (const a of out) a.dispose(); expected.dispose(); }
        } finally { for (const a of inputs) a.dispose(); }
      }
      expect(traces).toBe(1);
    } finally { compiled.dispose(); }
  });
}, 30_000);
