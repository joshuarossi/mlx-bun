import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { applyTopK, applyTopP, toLogprobs } from "../../src/sampler";
import { applyTopKRows, applyTopPRows } from "../../src/sampler-window";

const V = 248320; // the served vocabulary: kernel selection depends on size
function bytes(a: MlxArray): Uint8Array { ops.evalAll([a]); return new Uint8Array(a.rawBytesView()); }
function sameBits(a: MlxArray, b: MlxArray): boolean {
  const x = bytes(a), y = bytes(b);
  if (x.length !== y.length) return false;
  for (let i = 0; i < x.length; i++) if (x[i] !== y[i]) return false;
  return true;
}

test("row-batched filters are bit-identical to the per-position chain at the served vocabulary size", () => {
  for (const [W, seed] of [[2, 3], [3, 5], [4, 7]] as const) {
    using key = ops.randomKey(BigInt(seed));
    using noise = ops.randomNormal([W, V], Dtype.float32, 0, 2.5, key);
    const host = new Float32Array(W * V);
    for (let r = 0; r < W; r++) { host[r * V + 11 + r] = 13; host[r * V + 5000 + r] = 12.2; host[r * V + 90000 + r] = 11.1; }
    using spikes = MlxArray.fromFloat32(host, [W, V]);
    using sum = ops.add(noise, spikes);
    using logits = sum.astype(Dtype.bfloat16);
    using lpRows = toLogprobs(logits);
    using pRows = applyTopPRows(lpRows, 0.95);
    using kRows = applyTopKRows(pRows, 20);
    for (let r = 0; r < W; r++) {
      using row = logits.slice([r, 0], [r + 1, V]);
      using lp = toLogprobs(row);
      using p = applyTopP(lp, 0.95);
      using k = applyTopK(p, 20);
      using lpRow = lpRows.slice([r, 0], [r + 1, V]);
      using pRow = pRows.slice([r, 0], [r + 1, V]);
      using kRow = kRows.slice([r, 0], [r + 1, V]);
      using lpC = ops.contiguous(lpRow); using pC = ops.contiguous(pRow); using kC = ops.contiguous(kRow);
      expect(sameBits(lpC, lp)).toBe(true);
      expect(sameBits(pC, p)).toBe(true);
      expect(sameBits(kC, k)).toBe(true);
    }
  }
});
