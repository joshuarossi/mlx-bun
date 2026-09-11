// Same-B geometry oracle: pinned mlx-lm BatchKVCache/BatchRotatingKVCache.
// Affine components use the native quantizer on the oracle's retained rows.
import { test, expect } from "bun:test";
import { spawnSync } from "node:child_process";
import { ORACLE_VENV } from "../support/paths";

const enabled = Bun.env.MLX_BUN_TEST_PADDED_PREFILL === "1";
const oracle = String.raw`
import json
import mlx.core as mx
from mlx_lm.models.cache import BatchKVCache, BatchRotatingKVCache

def record(a):
    return {"shape": list(a.shape), "values": a.astype(mx.float32).reshape(-1).tolist()}
runs=[]
scenarios=[(pads,right,counts,prefix,0) for pads,right,counts,prefix in [([0],[3],[4,4],0),([0,0],[14,0],[5,6,6],0),([2,0,4],[7,0,3],[5,4,6],0),([0,0],[7,0],[3,3,3],11),([3,0],[0,0],[5,4],0),([0,0],[8,0],[4,4,1],0),([0,0],[3,0],[1,1,1,1,1],0),([0,0],[6,0],[3,3,1],11),([0,0],[5,0],[2,2,1],0)]]
# A shortened cohort has processed only part of its planned padding. Give
# stock BatchKVCache the effective padding for that prefix; Bun receives the
# original plan and must derive the same boundary from actual progress.
scenarios += [([0,0,0],[8,0,6],[3,2],0,5),([1,0,2],[8,0,6],[2,3],0,5),([0,0],[2,0],[2,1],0,7),([0,0,0],[8,0,6],[2,3],11,5),([0],[8],[3,2],0,5)]
scenarios += [([0]*4,[8,0,6,4],[4,4,1],0,0),([0]*8,[8,0,6,4,2,7,5,3],[3,3,3],11,0)]
scenarios += [([7,0],[0,0],[2,3,4],0,0),([9,0,5],[1,0,2],[2,3,6],0,0)]
for rotating in [False, True]:
    for pads, right, counts, prefix, unprocessed in scenarios:
        for retire in ([False,True] if unprocessed else [False]):
            B=len(pads); original_B=B; ids=list(range(B)); retired=False
            cache=BatchRotatingKVCache(8,[0]*B) if rotating else BatchKVCache([0]*B)
            steps=[]
            lengths=[sum(counts)+unprocessed-r for r in right]
            def advance(count,index,final=False):
                global B,ids,retired
                k=((((mx.arange(original_B*count*64)+index*7)%101)-50).reshape(original_B,1,count,64).astype(mx.bfloat16)/32)
                v=((((mx.arange(original_B*count*64)+index*11)%73)-36).reshape(original_B,1,count,64).astype(mx.bfloat16)/16)
                k=k[mx.array(ids)];v=v[mx.array(ids)]
                # Extend the oracle's existing concat operation to a singleton
                # padded block. Its public dispatch refuses this case. The first
                # query of an N=2 block has exactly the desired causal/window mask.
                if rotating and count == 1 and cache._lengths is not None:
                    mask=cache.make_mask(2, return_array=True)[..., :1, :-1]
                    keys,values=cache._update_concat(k,v)
                else:
                    mask=cache.make_mask(count, return_array=True)
                    keys,values=cache.update_and_fetch(k,v)
                out={"count":count,"k":record(k),"v":record(v),"mask":record(mask),"keys":record(keys),"values":record(values),"offsets":cache.offset.tolist(),"pads":cache.left_padding.tolist()}
                if final:
                    if retire and not retired:
                        keep=[2,0] if B>2 else [0]
                        cache.filter(mx.array(keep))
                        # Stock filter omits pending prefill metadata. Apply
                        # the same row selection before invoking its finalize.
                        for field in ["_right_padding","_lengths"]:
                            value=getattr(cache,field,None)
                            if value is not None:setattr(cache,field,value[mx.array(keep)])
                        ids=[ids[i] for i in keep];B=len(ids);retired=True
                        out["keep"]=keep
                    cache.finalize()
                    out["final"]={"offsets":cache.offset.tolist(),"pads":cache.left_padding.tolist()}
                    extracts=[]
                    for row in range(B):
                        c=cache.extract(row)
                        extracts.append({"keys":record(c.keys),"values":record(c.values),"offset":c.offset})
                    out["extracts"]=extracts
                steps.append(out)
            if prefix: advance(prefix,0)
            effective_right=right if rotating else [max(0,r-unprocessed) for r in right]
            cache.prepare(left_padding=pads if not prefix else None,lengths=lengths,right_padding=effective_right)
            for index,count in enumerate(counts):advance(count,index+1,index==len(counts)-1)
            for index in range(3):advance(1,20+index,True)
            runs.append({"rotating":rotating,"pads":pads,"right":right,"lengths":lengths,"prefix":prefix,"shortened":bool(unprocessed),"retire":retire,"steps":steps})
print(json.dumps(runs))
`;
type Tensor = { shape: number[]; values: number[] };
type Step = { count: number; k: Tensor; v: Tensor; mask: Tensor; keys: Tensor; values: Tensor; offsets: number[]; pads: number[];
  keep?: number[]; final?: { offsets: number[]; pads: number[] }; extracts?: { keys: Tensor; values: Tensor; offset: number }[] };
type Run = { rotating: boolean; pads: number[]; right: number[]; lengths: number[]; prefix: number; shortened: boolean; retire: boolean; steps: Step[] };

test.skipIf(!enabled)("padded full/rotating prefill finalization matches same-B oracle and preserves affine rows", async () => {
  const reference = spawnSync(`${ORACLE_VENV}/bin/python`, ["-c", oracle], { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });
  expect(reference.status, reference.stderr).toBe(0);
  const runs = JSON.parse(reference.stdout) as Run[];
  const { MlxArray } = await import("../../src/mlx/array");
  const { Dtype } = await import("../../src/mlx/ffi");
  const ops = await import("../../src/mlx/ops");
  const { BatchedTurboQuantKVCache } = await import("../../src/model/batched-turboquant-kv");
  const { TurboQuantCodec, disposeTurboQuant } = await import("../../src/model/turboquant-codec");
  const { BatchedKVCache } = await import("../../src/model/batched-kv");
  const { BatchedQuantizedKVCache } = await import("../../src/model/batched-quantized-kv");
  const { BatchedRotatingCache } = await import("../../src/model/batched-rotating");
  const { BatchedRotatingQuantCache } = await import("../../src/model/batched-rotating-quant");
  const { DelayedTurboQuantKVCache } = await import("../../src/model/delayed-turboquant-kv");
  const { DelayedQuantizedKVCache } = await import("../../src/model/delayed-quantized-kv");
  const { DelayedRotatingQuantizedKVCache } = await import("../../src/model/delayed-rotating-quantized-kv");
  const { createKvMaintenance } = await import("../../src/backends/mlx/kv-maintenance");
  const { RotatingQuantizedKVCache, QuantizedKVCache } = await import("../../src/model/gemma4-base");
  const { disposeTriple, createCausalMask, quantizedSdpa } = await import("../../src/model/gemma4-base");
  type Array = import("../../src/mlx/array").MlxArray;
  const from = (t: Tensor) => { using a = MlxArray.fromFloat32(Float32Array.from(t.values), t.shape); return a.astype(Dtype.bfloat16); };
  const equal = (a: Array, expected: Tensor) => { expect(a.shape).toEqual(expected.shape); expect(a.size ? [...a.toFloat32()] : []).toEqual(expected.values); };
  for (const run of runs) {
    const retire = run.retire;
    let B = run.pads.length, retired = false;
    let ids = Array.from({ length: B }, (_, row) => row);
    const selected = <T>(rows: T[]) => ids.map(row => rows[row]!);
    const plain = run.rotating ? new BatchedRotatingCache(8, Array(B).fill(0)) : new BatchedKVCache();
    const quants = [4, 8].map(bits => run.rotating ? BatchedRotatingQuantCache.empty(8, 64, bits, Array(B).fill(0)) : new BatchedQuantizedKVCache(64, bits));
    const turbos = run.rotating ? [] : [new BatchedTurboQuantKVCache(8, 3), new BatchedTurboQuantKVCache(4, 4)];
    const delayed = run.rotating ? [4, 8].flatMap(bits => [2, 5, 12].map(start =>
      new DelayedRotatingQuantizedKVCache(8, 64, bits, start,
        createKvMaintenance({ kvBits: bits, kvGroupSize: 64, quantizedKvStart: start }))))
      : [4, 8].flatMap(bits => [2, 5, 12].map(start => new DelayedQuantizedKVCache(64, bits, start,
        createKvMaintenance({ kvBits: bits, kvGroupSize: 64, quantizedKvStart: start }))));
    const delayedTurbos = run.rotating ? [] : [[8, 3], [4, 4]].flatMap(([kBits, vBits]) =>
      [2, 5, 12].map(start => new DelayedTurboQuantKVCache(kBits!, vBits!, start,
        createKvMaintenance({ turboQuant: { kBits: kBits!, vBits: vBits! }, quantizedKvStart: start }))));
    const floors = new Map<import("../../src/model/gemma4-base").Cache, number[]>(
      [...delayed, ...delayedTurbos].map(cache => [cache, Array(run.pads.length).fill(0) as number[]]));
    const caches = [plain, ...quants, ...turbos, ...delayed, ...delayedTurbos];
    const offsets = (c: typeof caches[number]) => "rowOffsets" in c ? c.rowOffsets : c.offsetArr;
    const release = (c: typeof caches[number]) => { if ("releaseRopeArr" in c) c.releaseRopeArr(); };
    let paddingActive = !run.prefix;
    const prepare = () => { for (const c of caches) c.preparePrefill({ lengths: run.lengths, rightPadding: run.right,
      ...(!run.prefix ? { leftPadding: run.pads } : {}) }); };
    try {
      if (!run.prefix) prepare();
      else for (const c of caches) c.preparePrefill({ lengths: Array(B).fill(run.prefix) });
      for (const [index, step] of run.steps.entries()) {
        using k = from(step.k), v = from(step.v);
        for (const c of caches) {
          const mask = c.makeMask(step.count, run.rotating ? 8 : null);
          try {
            if (mask.arr) equal(mask.arr, step.mask);
            else {
              using causal = createCausalMask(step.count, c.offset, null);
              // The empty/causal fast path omits identical batch dimensions.
              const values = [...causal.toFloat32()];
              expect(step.mask.values).toEqual(Array.from({ length: B }, () => values).flat());
            }
          } finally { mask.arr?.dispose(); }
        }
        const [pk, pv] = plain.updateAndFetch(k, v);
        try { equal(pk, step.keys); equal(pv, step.values); }
        finally { pk.dispose(); pv.dispose(); }
        for (const q of quants) { const [qk, qv] = q.updateAndFetchQuantized(k, v); disposeTriple(qk); disposeTriple(qv); }
        for (const t of turbos) {
          const [tk, tv] = index % 2 ? t.updateAndFetchDeferredV(k, v) : t.updateAndFetch(k, v);
          tk.dispose(); tv.dispose();
        }
        for (const d of delayed) {
          for (const [row, id] of ids.entries()) {
            const end = run.prefix + run.lengths[id]! - (run.prefix ? 0 : run.pads[id]!);
            const valid = paddingActive && run.right[id]! > 0 ? Math.min(d.rowOffsets[row]!, end) : d.rowOffsets[row]!;
            if (!floors.get(d)![id] && valid >= d.start && valid > 0) floors.get(d)![id] = valid;
          }
          const mask = d.makeMask(step.count, run.rotating ? 8 : null), view = d.appendAndFetch(k, v);
          try {
            using output = view.attend(k, 0.125, mask);
            using expectedKeys = from(step.keys), expectedValues = from(step.values);
            const converted = selected(floors.get(d)!).map(floor => floor > 0);
            const attention = (q: Array, keys: Array, values: Array, arr: Array | null, quantized: boolean) => {
              if (!quantized) return ops.sdpa(q, keys, values, 0.125, mask.mode, arr);
              const qk = ops.quantize(keys, 64, d.bits), qv = ops.quantize(values, 64, d.bits);
              try { return quantizedSdpa(q, qk, qv, 0.125, { mode: mask.mode, arr }, 64, d.bits); }
              finally { disposeTriple(qk); disposeTriple(qv); }
            };
            const parts: Array[] = [];
            try {
              // Match the numerical operation's B: packed affine attention
              // consumes the whole batch; mixed formats consume one row each.
              if (converted.every(Boolean)) parts.push(attention(k, expectedKeys, expectedValues, mask.arr, true));
              else if (!run.rotating && converted.every(value => !value)) parts.push(attention(k, expectedKeys, expectedValues, mask.arr, false));
              else for (let row = 0; row < B; row++) {
                const slice = (a: Array) => a.slice([row, 0, 0, 0], [row + 1, ...a.shape.slice(1)]);
                using q = slice(k), ek = slice(expectedKeys), ev = slice(expectedValues);
                using arr = mask.arr ? slice(mask.arr) : null;
                parts.push(attention(q, ek, ev, arr, converted[row]!));
              }
              using wanted = parts.length === 1 ? ops.contiguous(parts[0]!) : ops.concatAxis(parts, 0);
              expect(output.shape).toEqual(wanted.shape);
              expect([...output.toFloat32()], JSON.stringify({ pads: run.pads, right: run.right, prefix: run.prefix,
                retire, step: index, bits: d.bits, start: d.start, converted })).toEqual([...wanted.toFloat32()]);
            } finally { for (const part of parts) part.dispose(); }
          } finally { view.dispose(); mask.arr?.dispose(); }
        }
        for (const d of delayedTurbos) {
          for (const [row, id] of ids.entries()) {
            const end = run.prefix + run.lengths[id]! - (run.prefix ? 0 : run.pads[id]!);
            const valid = paddingActive && run.right[id]! > 0 ? Math.min(d.rowOffsets[row]!, end) : d.rowOffsets[row]!;
            if (!floors.get(d)![id] && valid >= d.start && valid > 0) floors.get(d)![id] = valid;
          }
          const defer = index % 2 === 1, mask = d.makeMask(step.count, null);
          const [actualKeys, actualValues] = defer ? d.updateAndFetchDeferredV(k, v) : d.updateAndFetch(k, v);
          const expectedKeys: Array[] = [], expectedValues: Array[] = [];
          try {
            using keys = from(step.keys), values = from(step.values);
            const codec = new TurboQuantCodec(d.kBits, d.vBits, false);
            for (let row = 0; row < B; row++) {
              const slice = (a: Array) => a.slice([row, 0, 0, 0], [row + 1, ...a.shape.slice(1)]);
              using ek = slice(keys), ev = slice(values);
              if (floors.get(d)![ids[row]!]! > 0) {
                const packed = codec.encode(ek, ev);
                try {
                  const [dk, dv] = codec.decode(packed, ek.shape[2]!, ek.shape[3]!, defer);
                  expectedKeys.push(dk); expectedValues.push(dv);
                } finally { disposeTurboQuant(packed); }
              } else { expectedKeys.push(ops.contiguous(ek)); expectedValues.push(ops.contiguous(ev)); }
            }
            using ek = ops.concatAxis(expectedKeys, 0), ev = ops.concatAxis(expectedValues, 0);
            const label = JSON.stringify({ pads: run.pads, right: run.right, prefix: run.prefix,
              retire, step: index, kBits: d.kBits, vBits: d.vBits, start: d.start, defer });
            expect(actualKeys.shape, label).toEqual(ek.shape);
            // Finalization moves encoded padding; re-encoding zero padding
            // may choose different signed zeros. Only live KV is state.
            for (let row = 0; row < B; row++) {
              const live = (a: Array) => a.slice([row, 0, Math.min(step.pads[row]!, a.shape[2]!), 0], [row + 1, ...a.shape.slice(1)]);
              using ak = live(actualKeys), av = live(actualValues), wk = live(ek), wv = live(ev);
              expect(ak.size ? [...ak.toFloat32()] : [], label).toEqual(wk.size ? [...wk.toFloat32()] : []);
              expect(av.size ? [...av.toFloat32()] : [], label).toEqual(wv.size ? [...wv.toFloat32()] : []);
            }
            using got = ops.sdpa(k, actualKeys, actualValues, 0.125, mask.mode, mask.arr);
            using wanted = ops.sdpa(k, ek, ev, 0.125, mask.mode, mask.arr);
            expect([...got.toFloat32()], label).toEqual([...wanted.toFloat32()]);
          } finally {
            actualKeys.dispose(); actualValues.dispose(); mask.arr?.dispose();
            for (const a of [...expectedKeys, ...expectedValues]) a.dispose();
          }
        }
        for (const c of caches) {
          expect(offsets(c)).toEqual(step.offsets); expect(c.leftPad).toEqual(step.pads);
        }
        if (step.keep) {
          // Remove the longest request before finalizing; reorder surviving
          // rows to exercise every representation's pending-padding filter.
          const keep = step.keep;
          for (const c of caches) c.filterRows(keep);
          ids = keep.map(row => ids[row]!); B = ids.length; retired = true;
        }
        for (const c of caches) {
          if (step.final) {
            c.finalizePrefill(); expect(offsets(c)).toEqual(step.final.offsets); expect(c.leftPad).toEqual(step.final.pads);
          }
          release(c);
        }
        if (step.extracts) for (const [row, expected] of step.extracts.entries()) {
          const p = plain.extractRow(row)!;
          try {
            if (p.keys && p.values) { equal(p.keys, expected.keys); equal(p.values, expected.values); }
            else { expect(expected.keys.values).toEqual([]); expect(expected.values.values).toEqual([]); }
            expect(p.offset).toBe(expected.offset);
          }
          finally { p.dispose(); }
          for (const d of delayed) {
            const extracted = d.extractRow(row);
            try {
              const floor = floors.get(d)![ids[row]!]!;
              expect(extracted.offset).toBe(expected.offset);
              expect(extracted.minimumReusableOffset ?? 0).toBe(floor);
              expect(extracted instanceof (run.rotating ? RotatingQuantizedKVCache : QuantizedKVCache)).toBe(floor > 0);
              if (!expected.offset) continue;
              if (extracted instanceof RotatingQuantizedKVCache || extracted instanceof QuantizedKVCache) {
                for (const [actual, wanted] of [[extracted.keys!, expected.keys], [extracted.values!, expected.values]] as const) {
                  using source = from(wanted); const encoded = ops.quantize(source, 64, d.bits);
                  try {
                    for (const field of ["packed", "scales", "biases"] as const) {
                      expect(actual[field].shape).toEqual(encoded[field].shape);
                      using got = ops.contiguous(actual[field]), target = ops.contiguous(encoded[field]);
                      expect(got.rawBytesView(), JSON.stringify({ pads: run.pads, right: run.right, counts: run.steps.map(s => s.count),
                        prefix: run.prefix, shortened: run.shortened, retire, step: index, row, bits: d.bits, start: d.start, field })).toEqual(target.rawBytesView());
                    }
                  } finally { disposeTriple(encoded); }
                }
              } else {
                const state = extracted.state();
                equal(state[0]!, expected.keys); equal(state[1]!, expected.values);
              }
            } finally { extracted.dispose(); }
          }
          for (const t of [...turbos, ...delayedTurbos]) {
            const extracted = t.extractRow(row);
            if (expected.offset === 0) {
              try { expect(extracted.offset).toBe(0); expect(extracted.state()).toEqual([]); }
              finally { extracted.dispose(); }
              continue;
            }
            if (t instanceof DelayedTurboQuantKVCache && floors.get(t)![ids[row]!] === 0) {
              try {
                const state = extracted.state(); equal(state[0]!, expected.keys); equal(state[1]!, expected.values);
                expect(extracted.offset).toBe(expected.offset); expect(extracted.minimumReusableOffset ?? 0).toBe(0);
              } finally { extracted.dispose(); }
              continue;
            }
            using ek = from(expected.keys), ev = from(expected.values);
            const encoded = new TurboQuantCodec(t.kBits, t.vBits, false).encode(ek, ev);
            const actual = extracted.state();
            try {
              const wanted = [encoded.kIdx, encoded.kScales, encoded.kZeros, encoded.vPacked, encoded.vScales];
              for (let field = 0; field < wanted.length; field++) {
                expect(actual[field]!.shape).toEqual(wanted[field]!.shape);
                expect(actual[field]!.rawBytesView()).toEqual(wanted[field]!.rawBytesView());
              }
              expect(extracted.offset).toBe(expected.offset);
              if (t instanceof DelayedTurboQuantKVCache) {
                expect(extracted.minimumReusableOffset).toBe(floors.get(t)![ids[row]!]!);
                expect(t.minimumReusableOffset).toBe(Math.max(...selected(floors.get(t)!)));
              } else expect(t.minimumReusableOffset).toBe(0);
            } finally { for (const a of actual) a.dispose(); extracted.dispose(); disposeTurboQuant(encoded); }
          }
          for (const q of quants) {
            const extracted = q.extractRow(row)!;
            try {
              if (expected.offset === 0) {
                expect(extracted.offset).toBe(0); expect(expected.keys.values).toEqual([]);
                continue;
              }
              for (const [actual, wanted] of [[extracted.keys!, expected.keys], [extracted.values!, expected.values]] as const) {
                using source = from(wanted); const encoded = ops.quantize(source, 64, q.bits);
                try {
                  expect(actual.packed.shape).toEqual(encoded.packed.shape);
                  expect(actual.packed.toIntTokens()).toEqual(encoded.packed.toIntTokens());
                  expect([...actual.scales.toFloat32()]).toEqual([...encoded.scales.toFloat32()]);
                  expect([...actual.biases.toFloat32()]).toEqual([...encoded.biases.toFloat32()]);
                } finally { disposeTriple(encoded); }
              }
              expect(extracted.offset).toBe(expected.offset);
            } finally { extracted.dispose(); }
          }
        }
        if (step.final) paddingActive = false;
        if (run.prefix && index === 0) { prepare(); paddingActive = true; }
      }
    } finally { for (const c of caches) c.dispose(); }
  }
}, 120_000);
