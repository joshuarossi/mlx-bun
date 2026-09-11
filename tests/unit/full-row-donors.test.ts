import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { KVCache, QuantizedKVCache, disposeTriple, type KvDonorAttention } from "../../src/model/gemma4-base";
import { FullPrefillRow } from "../../src/model/full-prefill-row";
import { captureFullKvDonorAttention } from "../../src/backends/mlx/full-kv-row-donor";

function tokens(values: number[]): MlxArray {
  return MlxArray.fromFloat32(Float32Array.from(values.flatMap(value => Array(64).fill(value))), [1, 1, values.length, 64]);
}

// Independent scalar softmax oracle. Constant feature vectors are exactly
// representable by affine KV and give known dot products for every query head.
function weighted(keys: number[], values: number[], query: number): number {
  const scores = keys.map(key => key * query), maximum = Math.max(...scores);
  const weights = scores.map(score => Math.exp(score - maximum));
  return weights.reduce((sum, weight, i) => sum + weight * values[i]!, 0) /
    weights.reduce((sum, weight) => sum + weight, 0);
}

for (const bits of [4, 8]) test(`full donor snapshots preserve mixed padded geometry and ownership (bits=${bits})`, () => {
  const plain = new FullPrefillRow(new KVCache());
  const affine = new FullPrefillRow(new QuantizedKVCache(64, bits));
  const rows = [plain, affine];
  let donor: KvDonorAttention | undefined;
  try {
    // lengths include the supplied left columns. The logical valid lengths
    // are three and two; local physical widths are six and five.
    plain.preparePrefill({ lengths: [4], leftPadding: [1], rightPadding: [2] });
    affine.preparePrefill({ lengths: [4], leftPadding: [2], rightPadding: [1] });
    using pk = tokens([-99, 0, 1, 2, 99, 99]), pv = tokens([999, 2, 5, 11, 999, 999]);
    using ak = tokens([-99, -99, 1, 3, 99]), av = tokens([999, 999, 7, 13, 999]);
    for (const array of plain.updateAndFetch(pk, pv)) array.dispose();
    for (const triple of affine.quantizedAttention!.updateAndFetchQuantized(ak, av)) disposeTriple(triple);
    expect(rows.map(row => row.offset)).toEqual([3, 2]);
    // Row0 also has two external alignment columns. Row1 has none. The
    // explicit assistant mask therefore needs different local key slices.
    const leftPad = [3, 2];
    donor = captureFullKvDonorAttention(rows, leftPad, 8);
    expect(donor.width).toBe(8);
    expect(donor.offsets).toEqual([3, 2]);
    expect(donor.starts).toEqual([3, 2]); expect(donor.ends).toEqual([6, 4]);
    expect(rows.map(row => [row.offset, row.leftPadding, row.physicalLength])).toEqual([[3, 1, 6], [2, 2, 5]]);
    using query = MlxArray.fromFloat32(Float32Array.from([1, -1, 2, -2].flatMap(value => Array(64).fill(value / 64))), [2, 2, 1, 64]);
    using mask = MlxArray.fromFloat32(Float32Array.from([
      -1e9, -1e9, -1e9, 0, 0, 0, -1e9, -1e9,
      -1e9, -1e9, 0, 0, -1e9, -1e9, -1e9, -1e9,
    ]), [2, 1, 1, 8]);
    const check = () => {
      using actual = donor!.attend(query, 1, { mode: "array", arr: mask });
      expect(actual.shape).toEqual([2, 2, 1, 64]);
      const values = actual.toFloat32();
      const means = [weighted([0, 1, 2], [2, 5, 11], 1), weighted([0, 1, 2], [2, 5, 11], -1),
        weighted([1, 3], [7, 13], 2), weighted([1, 3], [7, 13], -2)];
      for (let head = 0; head < 4; head++) for (let feature = 0; feature < 64; feature++)
        expect(values[head * 64 + feature]!).toBeCloseTo(means[head]!, 4);
    };
    check();
    for (const row of rows) row.finalizePrefill();
    rows.reverse(); leftPad.reverse();
    for (const row of rows) row.dispose();
    // Captured order, bounds, numerical closures and tensor ownership must
    // survive all changes to the caller's row list and live cache state.
    expect(donor.offsets).toEqual([3, 2]); expect(donor.starts).toEqual([3, 2]);
    check();
  } finally { donor?.dispose(); plain.dispose(); affine.dispose(); }
});
