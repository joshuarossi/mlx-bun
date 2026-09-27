// A delayed rotating wrapper that adopts one solo row attends and stores
// exactly as that row's serial lifecycle does: main's delayed-rotating-model
// contract (wrapper hidden/logits/state equal the serially maintained solo
// caches), here including a ring the default tail-split prefill has already
// wrapped (its physical columns are not in temporal order), a single block
// past the window, a row converting during decode after the wrap, and a row
// converted before adoption; in float16 and bfloat16, for a small geometry and
// Llama-3.2-3B's (24 query heads, 8 KV heads, head dim 128). Whether a changed
// column order changes the result depends on the data, so every case runs
// eight decode steps.
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { RotatingKVCache } from "../../src/state/rotating-kv";
import { RotatingQuantizedKVCache } from "../../src/state/rotating-quantized-kv";
import { createKvMaintenance } from "../../src/state/kv-maintenance";
import { captureKvAttention } from "../../src/state/kv-attention-view";
import { disposeTriple } from "../../src/state/quantized-tensor";
import type { Cache } from "../../src/contracts/mlx/cache";

const W = 8;
const digest = (a: MlxArray) => { using c = ops.contiguous(a); return createHash("sha256").update(c.rawBytes()).digest("hex"); };
/** One attention step as the model runs it: the group mask from the cache
 * before its write, then the cache's own attention view. */
const attend = (cache: Cache, q: MlxArray, k: MlxArray, v: MlxArray, scale: number): string => {
  const mask = cache.makeMask(k.shape[2]!, W);
  try {
    const view = captureKvAttention(cache, k, v);
    try { using out = view.attend(q, scale, mask); return digest(out); } finally { view.dispose(); }
  } finally { mask.arr?.dispose(); }
};
/** A solo rotating row's logical state: offset, reuse floor and its newest window. */
const logical = (cache: Cache) => {
  const describe = (planes: MlxArray[]) => ({ offset: cache.offset, minimum: cache.minimumReusableOffset ?? 0,
    kind: cache.constructor.name, planes: planes.map(digest) });
  if (cache instanceof RotatingQuantizedKVCache) {
    const [k, v] = cache.temporalView();
    try { return describe([k.packed, k.scales, k.biases, v.packed, v.scales, v.biases]); } finally { disposeTriple(k); disposeTriple(v); }
  }
  const [k, v] = (cache as RotatingKVCache).temporalView();
  try { return describe([k, v]); } finally { k.dispose(); v.dispose(); }
};
/** Write a block into a solo row in whichever precision it holds. */
const write = (cache: Cache, k: MlxArray, v: MlxArray) => {
  if (cache instanceof RotatingQuantizedKVCache) { const [kq, vq] = cache.updateAndFetchQuantized(k, v); disposeTriple(kq); disposeTriple(vq); }
  else for (const a of (cache as RotatingKVCache).updateAndFetch(k, v)) a.dispose();
};

const CASES: [string, number[], number][] = [
  // label, prefill chunks (a trailing 1 is the tail-split token), conversion start
  ["tail split past the window", [11, 1], 14],
  ["one block past the window", [12], 14],
  ["within the window, converting after the wrap", [5, 1], 9],
  ["converted in prefill before adoption", [6, 6, 1], 6],
];
const DTYPES: [string, Dtype][] = [["float16", Dtype.float16], ["bfloat16", Dtype.bfloat16]];
const GEOMETRIES = [{ name: "4Q/2KV/D64", heads: 4, kvHeads: 2, dim: 64 }, { name: "24Q/8KV/D128", heads: 24, kvHeads: 8, dim: 128 }];
for (const [dtypeName, dtype] of DTYPES) for (const g of GEOMETRIES) for (const bits of [4, 8]) for (const [label, chunks, start] of CASES)
test(`${dtypeName} ${g.name} KV${bits} ${label}: the adopted wrapper equals the serial row`, () => {
  const steps = 8, scale = 1 / Math.sqrt(g.dim);
  const tensor = (n: number, seed: number, heads = g.kvHeads) => {
    using key = ops.randomKey(BigInt(seed)); return ops.randomNormal([1, heads, n, g.dim], dtype, 0, 1, key);
  };
  const options = { kvBits: bits, kvGroupSize: 64, quantizedKvStart: start };
  const serial = createKvMaintenance(options);
  // Two identical solo rows: prefill writes, maintained after each non-final
  // chunk and before the first decode (the serial loop and the batch cohort).
  const prefilled = () => {
    const caches: Cache[] = [new RotatingKVCache(W)];
    let seed = 1, position = 0;
    for (const [index, n] of chunks.entries()) {
      using k = tensor(n, seed++), v = tensor(n, seed++);
      write(caches[0]!, k, v);
      position += n;
      if (index < chunks.length - 1) serial(caches);
    }
    serial(caches);
    expect(caches[0]!.offset).toBe(position);
    return caches;
  };
  const solo = prefilled(), adopted = prefilled();
  try {
    createKvMaintenance(options).prepareBatch!(adopted);
    expect(adopted[0]!.signature()).toStartWith("kv:delayed-rotating");
    for (let t = 0; t < steps; t++) {
      serial(solo); // the serial loop maintains before each decode forward
      using q = tensor(1, 100 + t, g.heads), k = tensor(1, 200 + t), v = tensor(1, 300 + t);
      expect(attend(adopted[0]!, q, k, v, scale), `step ${t} attention`).toBe(attend(solo[0]!, q, k, v, scale));
      const extracted = (adopted[0] as unknown as { extractRow(row: number): Cache }).extractRow(0);
      try { expect(logical(extracted), `step ${t} state`).toEqual(logical(solo[0]!)); } finally { extracted.dispose(); }
    }
  } finally { for (const cache of [...solo, ...adopted]) cache.dispose(); }
});
