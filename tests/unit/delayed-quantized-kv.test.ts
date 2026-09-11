import { test, expect } from "bun:test";
import { createHash } from "node:crypto";
import { KVCache, QuantizedKVCache, quantizedSdpa, disposeTriple, type Cache } from "../../src/model/gemma4-base";
import { DelayedQuantizedKVCache } from "../../src/model/delayed-quantized-kv";
import { createKvMaintenance } from "../../src/backends/mlx/kv-maintenance";
import { cloneKvCaches } from "../../src/kv-store";
import { Dtype } from "../../src/mlx/ffi";
import * as ops from "../../src/mlx/ops";
import type { MlxArray } from "../../src/mlx/array";
const digest = (a: MlxArray) => { using contiguous = ops.contiguous(a); return createHash("sha256").update(contiguous.rawBytes()).digest("hex"); };
const hashes = (cache: Cache) => cache.state().map(a => {
  using view = a.slice([0,0,0,0], [a.shape[0]!,a.shape[1]!,cache.offset,a.shape[3]!]); return digest(view);
});
const tensor = (b: number, heads: number, n: number, seed: number) => {
  using key = ops.randomKey(BigInt(seed)); return ops.randomNormal([b,heads,n,64], Dtype.bfloat16, 0, 1, key);
};
for (const bits of [4,8]) test(`delayed KV${bits} retains independent precision, rollback, padding and immutable checkpoints`, () => {
  const maintain = createKvMaintenance({ kvBits: bits, kvGroupSize:64, quantizedKvStart:5 });
  const source: Cache[] = [];
  for (const n of [2,6]) {
    const c = new KVCache(); using k=tensor(1,1,n,n), v=tensor(1,1,n,n+1);
    for (const field of c.updateAndFetch(k,v)) field.dispose(); source.push(c);
  }
  maintain(source);
  const group = new DelayedQuantizedKVCache(64,bits,5,maintain); group.mergeRows(source);
  const control = cloneKvCaches(source), held = cloneKvCaches(source);
  const original = held.map(hashes);
  const compare = () => {
    for (let row=0;row<2;row++) {
      const state=group.extractRow(row);
      try { expect(state.offset).toBe(control[row]!.offset); expect(hashes(state)).toEqual(hashes(control[row]!));
        expect(state.minimumReusableOffset ?? 0).toBe(control[row]!.minimumReusableOffset ?? 0); }
      finally { state.dispose(); }
    }
  };
  try {
    expect(group.rowOffsets).toEqual([2,6]); expect(group.leftPad).toEqual([4,0]);
    for (const [step,n,keep] of [[0,2,[1,2]],[1,3,[3,1]]] as const) {
      group.specRoundBegin(); const offsets=control.map(c=>c.offset);
      using q=tensor(2,2,n,step+40), k=tensor(2,1,n,step+50), v=tensor(2,1,n,step+60);
      const mask=group.makeMask(n,null);
      try {
        using output=group.updateAndAttend(q,k,v,0.125,mask);
        for(let row=0;row<2;row++) {
          const slice=(a:MlxArray)=>a.slice([row,0,0,0],[row+1,a.shape[1]!,a.shape[2]!,a.shape[3]!]);
          using qr=slice(q), kr=slice(k), vr=slice(v), got=slice(output);
          using arr=mask.arr!.slice([row,0,0,group.leftPad[row]!],[row+1,1,n,group.leftPad[row]!+offsets[row]!+n]);
          const cache=control[row]!, local={mode:"array" as const,arr};
          let expected:MlxArray;
          if(cache instanceof QuantizedKVCache) {
            const [keys,values]=cache.updateAndFetchQuantized(kr,vr);
            try {expected=quantizedSdpa(qr,keys,values,0.125,local,64,bits);} finally {disposeTriple(keys);disposeTriple(values);}
          } else {
            const [keys,values]=cache.updateAndFetch(kr,vr);
            try {expected=ops.sdpa(qr,keys,values,0.125,"array",arr);} finally {keys.dispose();values.dispose();}
          }
          try {expect(digest(got)).toBe(digest(expected));} finally {expected.dispose();}
        }
      } finally {mask.arr?.dispose();}
      group.specRoundRollback(keep);
      for(let row=0;row<2;row++)control[row]!.trim(n-keep[row]!);
      maintain(control); compare();
    }
    expect(group.rowOffsets).toEqual([6,9]); expect(group.leftPad).toEqual([4,0]);
    expect(group.minimumReusableOffset).toBe(6);
    expect(held.map(hashes)).toEqual(original);
    group.filterRows([1,0]); expect(group.rowOffsets).toEqual([9,6]); expect(group.leftPad).toEqual([0,4]);
    const captured=group.extractRow(1);
    try { expect(captured.minimumReusableOffset).toBe(6); expect(hashes(captured)).toEqual(hashes(control[0]!)); }
    finally {captured.dispose();}
  } finally {group.dispose(); for(const c of [...source,...control,...held])c.dispose();}
});


for (const bits of [4, 8]) test(`captured KV${bits} attention survives multiple consumers, conversion and owner disposal`, () => {
  const maintain = createKvMaintenance({ kvBits: bits, kvGroupSize: 64, quantizedKvStart: 5 });
  const source: Cache[] = [];
  for (const length of [2, 6]) {
    const row = new KVCache();
    using k = tensor(1, 1, length, length), v = tensor(1, 1, length, length + 1);
    for (const a of row.updateAndFetch(k, v)) a.dispose();
    source.push(row);
  }
  maintain(source);
  const group = new DelayedQuantizedKVCache(64, bits, 5, maintain); group.mergeRows(source);
  const mask = group.makeMask(1, null);
  using k = tensor(2, 1, 1, 70), v = tensor(2, 1, 1, 71);
  const view = group.appendAndFetch(k, v);
  using q1 = tensor(2, 2, 1, 72), q2 = tensor(2, 4, 1, 73);
  const result = (q: MlxArray) => { using out = view.attend(q, 0.125, mask); return digest(out); };
  try {
    const first = result(q1), second = result(q2);
    expect(group.rowOffsets).toEqual([3, 7]);
    expect(result(q1)).toBe(first); expect(result(q2)).toBe(second);
    // Advance past conversion, change membership, then destroy storage. The
    // captured row order, positions and tensors belong to the earlier view.
    for (let step = 0; step < 3; step++) group.appendAndFetch(k, v).dispose();
    group.filterRows([1, 0]); group.dispose();
    expect(result(q1)).toBe(first); expect(result(q2)).toBe(second);
  } finally {
    view.dispose(); mask.arr?.dispose(); group.dispose();
    for (const row of source) row.dispose();
  }
});
