import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import { KVCache } from "../../src/model/gemma4-base";
import { MlxProjectedContextRows } from "../../src/backends/mlx/projected-context-rows";
import { applyStateChanges } from "../../src/engine/resources";

test("projected context masks padding and rejected rows while admitting block KV", () => {
  const rows = new MlxProjectedContextRows(1, { project(hidden) {
    const shape = [hidden.shape[0]!,1,hidden.shape[1]!,32];
    return [{k:ops.reshape(hidden,shape),v:ops.reshape(hidden,shape)}];
  } });
  try {
    const empty = [new KVCache(),new KVCache()];
    try { applyStateChanges([() => rows.prepareAppend(empty.map(cache=>[cache]))]); }
    finally { for (const cache of empty) cache.dispose(); }
    const data = (values: number[][]) => MlxArray.fromFloat32(Float32Array.from(values.flatMap(row=>row.flatMap(value=>Array(32).fill(value)))), [2,values[0]!.length,32]);
    using first = data([[1,2,90],[11,12,13]]); rows.append(first,[2,3]);
    using second = data([[3,91,92],[14,15,16]]); rows.append(second,[1,3]);
    expect(rows.positions).toEqual([3,6]);
    const donors = rows.readAttention();
    try {
      using query = ops.zeros([2,2,1,32],Dtype.float32);
      using block = ops.zeros([2,1,2,32],Dtype.float32);
      using output = donors.attend(0,query,block,block);
      const values = output.toFloat32();
      for (let i=0;i<64;i++) expect(values[i]!).toBeCloseTo(6/5,5);
      for (let i=64;i<128;i++) expect(values[i]!).toBeCloseTo(81/8,5);
      // Captured donor planes remain immutable after later context appends.
      using later = data([[4],[17]]); rows.append(later,[1,1]);
      using again = donors.attend(0,query,block,block);
      expect(Array.from(again.toFloat32())).toEqual(Array.from(values));
    } finally { donors.dispose(); }
  } finally { rows.dispose(); }
});
