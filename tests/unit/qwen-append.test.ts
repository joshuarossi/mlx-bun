import { expect, test } from "bun:test";
import { qwenAppendChunkSize } from "../../src/model/qwen-append";
import { MlxArray } from "../../src/mlx/array";
import { Dtype, clearCache, deviceArchitecture } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";

function data(length: number, seed: number): Float32Array {
  const out = new Float32Array(length);
  for (let i = 0; i < length; i++) {
    seed ^= seed << 13; seed ^= seed >>> 17; seed ^= seed << 5;
    out[i] = ((seed >>> 8) / 16777216 - 0.5) * 2;
  }
  return out;
}

// Cross every native arithmetic boundary, including both sides of 1024.
for (const dtype of [Dtype.bfloat16, Dtype.float16, Dtype.float32]) {
  test.skipIf(deviceArchitecture() !== "applegpu_g16s")(`Qwen append keeps M1 attention at cache boundaries, dtype ${dtype}`, () => {
    const capacity = 65792, heads = 24, kvHeads = 4, dim = 256, count = 4;
    const k0 = MlxArray.fromFloat32(data(kvHeads * capacity * dim, 71), [1, kvHeads, capacity, dim]);
    const v0 = MlxArray.fromFloat32(data(kvHeads * capacity * dim, 93), [1, kvHeads, capacity, dim]);
    const q0 = MlxArray.fromFloat32(data(heads * count * dim, 47), [1, heads, count, dim]);
    const k = k0.astype(dtype), v = v0.astype(dtype), q = q0.astype(dtype);
    ops.evalAll([k, v, q]); k0.dispose(); v0.dispose(); q0.dispose();
    try {
      for (const context of [1021, 1023, 8191, 32767, 65535]) {
        const owned: MlxArray[] = [];
        const keep = (x: MlxArray) => { owned.push(x); return x; };
        const attend = (start: number, end: number) => {
          const query = keep(ops.contiguous(keep(q.slice([0, 0, start, 0], [1, heads, end, dim]))));
          const keys = keep(k.slice([0, 0, 0, 0], [1, kvHeads, context + end, dim]));
          const values = keep(v.slice([0, 0, 0, 0], [1, kvHeads, context + end, dim]));
          return keep(ops.sdpa(query, keys, values, 1 / Math.sqrt(dim), end - start === 1 ? "" : "causal"));
        };
        try {
          const expected = keep(ops.concatAxis(Array.from({ length: count }, (_, i) => attend(i, i + 1)), 2));
          const chunks: MlxArray[] = [];
          for (let start = 0; start < count;) {
            const end = Math.min(count, start + qwenAppendChunkSize(context + start));
            chunks.push(attend(start, end)); start = end;
          }
          const actual = keep(ops.concatAxis(chunks, 2));
          expect(Buffer.from(actual.rawBytesView())).toEqual(Buffer.from(expected.rawBytesView()));
        } finally { for (const x of owned) x.dispose(); clearCache(); }
      }
    } finally { k.dispose(); v.dispose(); q.dispose(); clearCache(); }
  });
}
