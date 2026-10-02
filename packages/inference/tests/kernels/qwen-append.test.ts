import { describe, expect, test } from "bun:test";
import { qwenAppendChunkSize } from "../../src/layers/qwen-append";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype, clearCache, deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

function data(length: number, seed: number): Float32Array {
  const out = new Float32Array(length);
  for (let i = 0; i < length; i++) {
    seed ^= seed << 13; seed ^= seed >>> 17; seed ^= seed << 5;
    out[i] = ((seed >>> 8) / 16777216 - 0.5) * 2;
  }
  return out;
}

// Model-free chunk plan. The regimes are stated independently of the
// implementation: MLX 0.32.2 changes SDPA vector/two-pass block selection
// after these inclusive KV lengths, so a KV length n is in regime
// #{b : n > b}. A committed chunk that starts with `context` cached tokens and
// commits `size` tokens attends KV lengths context+1 .. context+size; every
// one of them must sit in one regime, or the span is not equal to M=1.
const REGIME_BOUNDARIES = [1023, 1024, 8192, 32768, 65536];
const regime = (kvLength: number) => REGIME_BOUNDARIES.filter(boundary => kvLength > boundary).length;

describe("qwenAppendChunkSize regime plan (model-free)", () => {
  test("no chunk spans two SDPA regimes, on every context around every boundary", () => {
    for (const boundary of REGIME_BOUNDARIES) {
      for (let context = boundary - 40; context <= boundary + 40; context++) {
        const size = qwenAppendChunkSize(context);
        expect(size).toBeGreaterThanOrEqual(1);
        expect(size).toBeLessThanOrEqual(4);
        expect(regime(context + size)).toBe(regime(context + 1));
      }
    }
  });

  test("chunks shrink to land exactly on a boundary and never cross it", () => {
    expect([1018, 1019, 1020, 1021, 1022].map(qwenAppendChunkSize)).toEqual([4, 4, 3, 2, 1]);
    expect([1023, 1024, 1025].map(qwenAppendChunkSize)).toEqual([1, 4, 4]);
    expect([8188, 8189, 8190, 8191, 8192, 8193].map(qwenAppendChunkSize)).toEqual([4, 3, 2, 1, 4, 4]);
    expect([32764, 32765, 32766, 32767, 32768, 32769].map(qwenAppendChunkSize)).toEqual([4, 3, 2, 1, 4, 4]);
    expect([65532, 65533, 65534, 65535, 65536, 65537].map(qwenAppendChunkSize)).toEqual([4, 3, 2, 1, 4, 4]);
  });

  test("walking a long committed stream in plan chunks visits each regime change at a chunk edge", () => {
    for (const start of [0, 1000, 8100, 32700, 65500]) {
      let context = start;
      const stop = start + 200;
      while (context < stop) {
        const size = qwenAppendChunkSize(context);
        expect(regime(context + size)).toBe(regime(context + 1));
        context += size;
      }
    }
  });
});

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
