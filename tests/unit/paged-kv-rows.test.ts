import { expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { Dtype } from "../../src/mlx/ffi";
import { PagedKVCache } from "../../src/lab/paged-kv/paged-kv";
import { PagedKvRows } from "../../src/lab/paged-kv/paged-kv-rows";
import { ownedCacheLayout, prefillCacheLayout } from "../../src/backends/mlx/cache-layout";

const heads = 2, dim = 4;
function read(a: MlxArray): Float32Array { using value = ops.contiguous(a); return value.toFloat32(); }
function data(row: number, start: number, count: number): Float32Array {
  return Float32Array.from({ length: heads * count * dim }, (_, i) => {
    const head = Math.floor(i / (count * dim)), token = Math.floor(i / dim) % count;
    return (row + 1) * 1000 + (start + token) * 10 + head + (i % dim) / 10;
  });
}
function pair(rows: number[], starts: number[], count: number): [MlxArray, MlxArray] {
  const values = Float32Array.from(rows.flatMap((row, i) => [...data(row, starts[i]!, count)]));
  return [MlxArray.fromFloat32(values, [rows.length, heads, count, dim]),
    MlxArray.fromFloat32(values.map(v => -v), [rows.length, heads, count, dim])];
}
function checkRow(cache: PagedKVCache, row: number, count: number): void {
  expect(cache.offset).toBe(count);
  using zero = ops.zeros([1, heads, 0, dim], Dtype.float32);
  const [k, v] = cache.updateAndFetch(zero, zero);
  try {
    expect(read(k)).toEqual(data(row, 0, count));
    expect(read(v)).toEqual(data(row, 0, count).map(x => -x));
  } finally { k.dispose(); v.dispose(); }
}

test("paged rows preserve gathered values, masks and independent pools across joins and retirement", () => {
  const ids = [0, 1, 2], offsets = [0, 3, 7];
  const sources = offsets.map(() => new PagedKVCache(64, 4));
  const group = new PagedKvRows(64, 4), retained = group.makeEmptyBatch();
  let snapshot: PagedKVCache | undefined;
  try {
    for (let row = 0; row < ids.length; row++) if (offsets[row]) {
      const [k,v] = pair([row], [0], offsets[row]!);
      const fetched = sources[row]!.updateAndFetch(k,v);
      for (const a of [k,v,...fetched]) a.dispose();
    }
    group.mergeRows(sources);
    for (const source of sources) source.dispose();
    for (const [step, count] of [1,5,2].entries()) {
      const width = Math.max(...offsets) + count;
      const mask = group.makeMask(count, null);
      try {
        expect(mask.arr!.shape).toEqual([3,1,count,width]);
        const actual = mask.arr!.astype(Dtype.int32);
        try { expect([...actual.toIntTokens()]).toEqual(ids.flatMap((_, row) =>
          Array.from({length: count}, (_, q) => Array.from({length: width}, (_, key) =>
            Number(key >= width-count-offsets[row]! && key <= width-count+q))).flat())); }
        finally { actual.dispose(); }
      } finally { mask.arr!.dispose(); }
      expect(group.ropeOffsetArr!.toIntTokens()).toEqual(offsets);
      const [k,v] = pair(ids, offsets, count);
      const fetched = group.updateAndFetch(k,v);
      try {
        expect(fetched[0].shape).toEqual([3,heads,width,dim]);
        for (let row=0;row<3;row++) {
          offsets[row]! += count;
          const end = offsets[row]!, pad=width-end;
          using got = fetched[0].slice([row,0,pad,0],[row+1,heads,width,dim]);
          expect(read(got)).toEqual(data(row,0,end));
        }
      } finally { for (const a of [k,v,...fetched]) a.dispose(); group.releaseRopeArr(); }
      if (step === 0) { snapshot=group.extractRow(0); retained.mergeRows([group]); }
    }
    checkRow(snapshot!,0,1);
    const held = retained.extractRow(1);
    try { checkRow(held,1,4); } finally { held.dispose(); }
    group.filterRows([2,0]);
    expect(group.rowOffsets).toEqual([15,8]); expect(group.leftPad).toEqual([0,7]);
    const joined = group.makeEmptyBatch();
    try {
      joined.mergeRows([group,snapshot!]);
      expect(joined.rowOffsets).toEqual([15,8,1]);
      joined.filterRows([1]); joined.trim(3);
      const last=joined.extractRow(0);
      try { checkRow(last,0,5); } finally { last.dispose(); }
    } finally { joined.dispose(); }
    checkRow(snapshot!,0,1);
  } finally { for (const source of sources) source.dispose(); snapshot?.dispose(); group.dispose(); retained.dispose(); }
});

test("paged storage binds through the same layout interface at B1", () => {
  const source=new PagedKVCache(16,4);
  const layout=ownedCacheLayout(source)!, prefill=prefillCacheLayout(source);
  try {
    expect(layout).toBeInstanceOf(PagedKvRows); expect(prefill).toBeInstanceOf(PagedKvRows);
    layout.mergeRows([source]); expect(layout.ropeOffsetArr).toBeUndefined();
    expect(layout.makeMask(1,null)).toEqual({mode:"",arr:null});
    const [k,v]=pair([0],[0],3), values=layout.updateAndFetch(k,v);
    try { expect(read(values[0])).toEqual(data(0,0,3)); }
    finally { for(const a of [k,v,...values]) a.dispose(); }
    expect(layout.projectedBytes(5)).toBe(8*heads*dim*4*2);
  } finally {source.dispose();layout.dispose();prefill.dispose();}
});
