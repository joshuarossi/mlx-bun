import { test, expect } from "bun:test";
import { createHash } from "node:crypto";
import { KVCache } from "../../src/state/kv";
import { QuantizedKVCache } from "../../src/state/quantized-kv";
import { quantizedSdpa } from "../../src/layers/quantized-attention";
import { disposeTriple } from "../../src/state/quantized-tensor";
import { type Cache } from "../../src/contracts/mlx/cache";
import { DelayedQuantizedKVCache } from "../../src/state/delayed-quantized-kv";
import { createKvMaintenance } from "../../src/state/kv-maintenance";
import { cloneKvCaches } from "../../src/state/persistence";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { MlxArray } from "@mlx-bun/mlx/array";
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
  const group = new DelayedQuantizedKVCache(64,bits,5); group.mergeRows(source);
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
  const group = new DelayedQuantizedKVCache(64, bits, 5); group.mergeRows(source);
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

// ---- plain reads while every row is still plain ----------------------------------------
// A softcap graph reads plain keys and values. Before conversion the delayed
// full wrapper answers with the same assembly its plain attention view uses:
// each row's own cache, placed behind its left padding.
const plainRows = (lengths: number[], seed: number) => lengths.map((length, index) => {
  const row = new KVCache();
  using k = tensor(1, 1, length, seed + 2 * index), v = tensor(1, 1, length, seed + 2 * index + 1);
  for (const a of row.updateAndFetch(k, v)) a.dispose();
  return row;
});
const zeros = (a: MlxArray) => { using z = ops.zeros(a.shape as number[], a.dtype); return digest(z); };
const maskDigest = (a: MlxArray) => { using bytes = a.astype(Dtype.uint8); return digest(bytes); };

test("plain reads before conversion equal each row's plain cache at B1 and at B2 with unequal offsets", () => {
  for (const lengths of [[5], [2, 6]]) {
    const source = plainRows(lengths, 10), control = cloneKvCaches(source);
    const group = new DelayedQuantizedKVCache(64, 4, 64); group.mergeRows(source);
    const twin = new DelayedQuantizedKVCache(64, 4, 64); twin.mergeRows(source);
    const B = lengths.length;
    try {
      for (const [step, n] of [3, 1, 1, 2].entries()) {
        const offsets = [...group.rowOffsets], pads = [...group.leftPad];
        using q = tensor(B, 2, n, 100 + step), k = tensor(B, 1, n, 200 + step), v = tensor(B, 1, n, 300 + step);
        const mask = group.makeMask(n, null), twinMask = twin.makeMask(n, null);
        try {
          const [keys, values] = group.updateAndFetch(k, v);
          try {
            expect(keys.shape).toEqual([B, 1, Math.max(...offsets.map((o, r) => pads[r]! + o)) + n, 64]);
            for (let row = 0; row < B; row++) {
              const at = (a: MlxArray, from: number, to: number) => a.slice([row, 0, from, 0], [row + 1, a.shape[1]!, to, a.shape[3]!]);
              using kr = k.slice([row, 0, 0, 0], [row + 1, 1, n, 64]), vr = v.slice([row, 0, 0, 0], [row + 1, 1, n, 64]);
              const [ck, cv] = control[row]!.updateAndFetch(kr, vr);
              try {
                using gk = at(keys, pads[row]!, pads[row]! + offsets[row]! + n), gv = at(values, pads[row]!, pads[row]! + offsets[row]! + n);
                expect([digest(gk), digest(gv)], `step ${step} row ${row}`).toEqual([digest(ck), digest(cv)]);
                if (pads[row]) { using pad = at(keys, 0, pads[row]!); expect(digest(pad)).toBe(zeros(pad)); }
              } finally { ck.dispose(); cv.dispose(); }
            }
            // The same keys, values and mask as the plain attention view.
            expect(twinMask.mode).toBe(mask.mode);
            if (mask.arr) expect(maskDigest(twinMask.arr!)).toBe(maskDigest(mask.arr));
            using out = ops.sdpa(q, keys, values, 0.125, mask.mode, mask.arr);
            const view = twin.appendAndFetch(k, v);
            try { using expected = view.attend(q, 0.125, twinMask); expect(digest(out)).toBe(digest(expected)); } finally { view.dispose(); }
          } finally { keys.dispose(); values.dispose(); }
        } finally { mask.arr?.dispose(); twinMask.arr?.dispose(); }
        expect(group.rowOffsets).toEqual(offsets.map(o => o + n));
      }
    } finally { group.dispose(); twin.dispose(); for (const c of [...source, ...control]) c.dispose(); }
  }
});

test("plain reads are owned by the caller and outlive later appends", () => {
  const source = plainRows([2, 6], 30), control = cloneKvCaches(source);
  const group = new DelayedQuantizedKVCache(64, 4, 64); group.mergeRows(source);
  try {
    using k1 = tensor(2, 1, 1, 31), v1 = tensor(2, 1, 1, 32), k2 = tensor(2, 1, 1, 33), v2 = tensor(2, 1, 1, 34);
    const [held, heldValues] = group.updateAndFetch(k1, v1);
    try {
      const before = [digest(held), digest(heldValues)];
      for (const a of group.updateAndFetch(k2, v2)) a.dispose();   // disposing a read leaves the cache intact
      expect([digest(held), digest(heldValues)]).toEqual(before);     // an earlier read keeps its contents
    } finally { held.dispose(); heldValues.dispose(); }
    for (let row = 0; row < 2; row++) {
      for (const [k, v] of [[k1, v1], [k2, v2]] as const) {
        using kr = k.slice([row, 0, 0, 0], [row + 1, 1, 1, 64]), vr = v.slice([row, 0, 0, 0], [row + 1, 1, 1, 64]);
        for (const a of control[row]!.updateAndFetch(kr, vr)) a.dispose();
      }
      const state = group.extractRow(row);
      try { expect(hashes(state)).toEqual(hashes(control[row]!)); } finally { state.dispose(); }
    }
  } finally { group.dispose(); for (const c of [...source, ...control]) c.dispose(); }
});

test("a plain read appends to no row once any row is converted, before or by the scheduled maintenance", () => {
  const maintain = createKvMaintenance({ kvBits: 4, kvGroupSize: 64, quantizedKvStart: 5 });
  const snapshot = (group: DelayedQuantizedKVCache) => ({ offsets: [...group.rowOffsets], pads: [...group.leftPad],
    rows: group.rowOffsets.map((_, row) => { const s = group.extractRow(row); try { return [s.constructor.name, ...hashes(s)]; } finally { s.dispose(); } }) });
  using k = tensor(2, 1, 1, 50), v = tensor(2, 1, 1, 51);
  // Mixed and fully converted rows refuse with no change at all.
  for (const lengths of [[2, 6], [6, 7]]) {
    const source = plainRows(lengths, 40); maintain(source);
    const group = new DelayedQuantizedKVCache(64, 4, 5); group.mergeRows(source);
    try {
      const before = snapshot(group);
      expect(() => group.updateAndFetch(k, v)).toThrow("mixed precision rows use their attention state");
      expect(snapshot(group)).toEqual(before);
    } finally { group.dispose(); for (const c of source) c.dispose(); }
  }
  // Scheduled maintenance converts the second row at its offset; the first,
  // still plain, is not advanced.
  const source = plainRows([2, 4], 60), control = cloneKvCaches(source);
  const group = new DelayedQuantizedKVCache(64, 4, 5); group.mergeRows(source);
  try {
    for (const a of group.updateAndFetch(k, v)) a.dispose();
    expect(group.rowOffsets).toEqual([3, 5]);
    expect(() => group.updateAndFetch(k, v)).toThrow("mixed precision rows use their attention state");
    expect(group.rowOffsets).toEqual([3, 5]);
    using k0 = k.slice([0, 0, 0, 0], [1, 1, 1, 64]), v0 = v.slice([0, 0, 0, 0], [1, 1, 1, 64]);
    for (const a of control[0]!.updateAndFetch(k0, v0)) a.dispose();
    const first = group.extractRow(0), second = group.extractRow(1);
    try {
      expect([first.constructor.name, ...hashes(first)]).toEqual([control[0]!.constructor.name, ...hashes(control[0]!)]);
      expect(second).toBeInstanceOf(QuantizedKVCache);
    } finally { first.dispose(); second.dispose(); }
  } finally { group.dispose(); for (const c of [...source, ...control]) c.dispose(); }
});

test("prefill defers conversion: a plain read past the offset appends while prefilling, and the next one after it refuses", () => {
  const source = plainRows([6, 3], 70), control = cloneKvCaches(source);
  const group = new DelayedQuantizedKVCache(64, 4, 5); group.mergeRows(source);
  try {
    using k = tensor(2, 1, 2, 71), v = tensor(2, 1, 2, 72);
    group.beginPrefill();
    const [keys, values] = group.updateAndFetch(k, v);
    try {
      for (let row = 0; row < 2; row++) {
        using kr = k.slice([row, 0, 0, 0], [row + 1, 1, 2, 64]), vr = v.slice([row, 0, 0, 0], [row + 1, 1, 2, 64]);
        const [ck, cv] = control[row]!.updateAndFetch(kr, vr);
        try {
          const pad = group.leftPad[row]!, end = pad + control[row]!.offset;
          using gk = keys.slice([row, 0, pad, 0], [row + 1, 1, end, 64]), gv = values.slice([row, 0, pad, 0], [row + 1, 1, end, 64]);
          expect([digest(gk), digest(gv)]).toEqual([digest(ck), digest(cv)]);
        } finally { ck.dispose(); cv.dispose(); }
      }
    } finally { keys.dispose(); values.dispose(); group.endPrefill(); }
    expect(group.rowOffsets).toEqual([8, 5]);
    using k1 = tensor(2, 1, 1, 73), v1 = tensor(2, 1, 1, 74);
    expect(() => group.updateAndFetch(k1, v1)).toThrow("mixed precision rows use their attention state");
    expect(group.rowOffsets).toEqual([8, 5]);
  } finally { group.dispose(); for (const c of [...source, ...control]) c.dispose(); }
});

for (const side of ["left", "right"] as const)
test(`${side}-padded full prefill reads plain, finalizes its positions and decodes as the plain view and serial rows`, () => {
  const lengths = [3, 6], L = 6, pads = lengths.map(n => L - n);
  const group = new DelayedQuantizedKVCache(64, 4, 64), twin = new DelayedQuantizedKVCache(64, 4, 64);
  const control = lengths.map(() => new KVCache());
  const attentionMatches = (q: MlxArray, k: MlxArray, v: MlxArray, keys: MlxArray, values: MlxArray, mask: ReturnType<typeof group.makeMask>, twinMask: typeof mask, at: string) => {
    expect(twinMask.mode, at).toBe(mask.mode);
    using out = ops.sdpa(q, keys, values, 0.125, mask.mode, mask.arr);
    const view = twin.appendAndFetch(k, v);
    try { using expected = view.attend(q, 0.125, twinMask); expect(digest(out), at).toBe(digest(expected)); } finally { view.dispose(); }
  };
  try {
    // The cohort's own prefill hooks on an empty wrapper: fresh padded rows.
    for (const cache of [group, twin]) {
      cache.beginPrefill();
      cache.preparePrefill({ lengths, ...(side === "left" ? { leftPadding: pads } : { rightPadding: pads }) });
    }
    {
      using q = tensor(2, 2, L, 81), k = tensor(2, 1, L, 82), v = tensor(2, 1, L, 83);
      const mask = group.makeMask(L, null), twinMask = twin.makeMask(L, null);
      try {
        const [keys, values] = group.updateAndFetch(k, v);
        try { attentionMatches(q, k, v, keys, values, mask, twinMask, "prefill"); } finally { keys.dispose(); values.dispose(); }
      } finally { mask.arr?.dispose(); twinMask.arr?.dispose(); }
      // Serial rows hold only each request's own tokens.
      for (let row = 0; row < 2; row++) {
        const from = side === "left" ? pads[row]! : 0, to = from + lengths[row]!;
        using kr = k.slice([row, 0, from, 0], [row + 1, 1, to, 64]), vr = v.slice([row, 0, from, 0], [row + 1, 1, to, 64]);
        for (const a of control[row]!.updateAndFetch(kr, vr)) a.dispose();
      }
    }
    for (const cache of [group, twin]) { cache.finalizePrefill(); cache.endPrefill(); }
    expect(group.rowOffsets).toEqual(lengths);
    for (let step = 0; step < 3; step++) {
      using q = tensor(2, 2, 1, 90 + step), k = tensor(2, 1, 1, 93 + step), v = tensor(2, 1, 1, 96 + step);
      const mask = group.makeMask(1, null), twinMask = twin.makeMask(1, null);
      const offsets = [...group.rowOffsets], rowPads = [...group.leftPad];
      try {
        const [keys, values] = group.updateAndFetch(k, v);
        try {
          attentionMatches(q, k, v, keys, values, mask, twinMask, `decode ${step}`);
          for (let row = 0; row < 2; row++) {
            using kr = k.slice([row, 0, 0, 0], [row + 1, 1, 1, 64]), vr = v.slice([row, 0, 0, 0], [row + 1, 1, 1, 64]);
            const [ck, cv] = control[row]!.updateAndFetch(kr, vr);
            try {
              const from = rowPads[row]!, to = from + offsets[row]! + 1;
              using gk = keys.slice([row, 0, from, 0], [row + 1, 1, to, 64]), gv = values.slice([row, 0, from, 0], [row + 1, 1, to, 64]);
              expect([digest(gk), digest(gv)], `decode ${step} row ${row}`).toEqual([digest(ck), digest(cv)]);
            } finally { ck.dispose(); cv.dispose(); }
          }
        } finally { keys.dispose(); values.dispose(); }
      } finally { mask.arr?.dispose(); twinMask.arr?.dispose(); }
      for (let row = 0; row < 2; row++) {
        const state = group.extractRow(row);
        try { expect(hashes(state), `decode ${step} row ${row} state`).toEqual(hashes(control[row]!)); } finally { state.dispose(); }
      }
    }
  } finally { group.dispose(); twin.dispose(); for (const c of control) c.dispose(); }
});
