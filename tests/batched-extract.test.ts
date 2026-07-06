// FAST (no model load): per-row KV extraction from batched caches — the
// mechanics of mlx-lm BatchKVCache.extract / BatchRotatingKVCache.extract
// (models/cache.py:1080 / :1417), the path that returns a finishing row's KV
// to the prompt cache under real concurrency (server.py:864-880).
//
// The bit-exactness claim under test: extracted-row bytes == solo-run bytes,
// because (a) merge/extend/filter/decode are byte-preserving per row
// (tests/batched-decode-parity, tests/batched-rotating,
// tests/batched-rotating-quant) and (b) extraction is a pure slice+copy.
// Each test builds a batched cache the way the scheduler does (solo prefill →
// merge → N=1 decode steps), replays the SAME updates through a serial cache,
// extracts the row, and compares raw bytes + offsets. The last test drives
// the REAL BatchScheduler with a stub model and asserts finished rows'
// caches land in the prompt cache keyed by exactly [promptIds + fed].

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { Dtype } from "../src/mlx/ffi";
import {
  KVCache, QuantizedKVCache, RotatingKVCache, RotatingQuantizedKVCache, type Cache,
} from "../src/model/gemma4-base";
import { mergeKVRows, extractKVRow } from "../src/model/batched-mask";
import { mergeQuantRows, extractQuantRow, type QuantRow } from "../src/model/batched-quant";
import { BatchedRotatingCache } from "../src/model/batched-rotating";
import { BatchedRotatingQuantCache } from "../src/model/batched-rotating-quant";
import { BatchScheduler, type RowPromptCache } from "../src/serve/batch-scheduler";
import { SSMCache } from "../src/model/qwen3-delta";
import type { RuntimeModel } from "../src/model/factory";

/** Contiguous raw bytes of a (possibly strided) view, as a plain array. */
const bytes = (a: MlxArray): number[] => {
  const c = ops.contiguous(a);
  const out = [...c.rawBytes()];
  c.dispose();
  return out;
};

/** [1,1,L,D] f32 filled with f(t, d). */
const grid = (L: number, D: number, f: (t: number, d: number) => number): MlxArray => {
  const data = new Float32Array(L * D);
  for (let t = 0; t < L; t++) for (let d = 0; d < D; d++) data[t * D + d] = f(t, d);
  return MlxArray.fromFloat32(data, [1, 1, L, D]);
};

describe("per-row extraction from batched caches (model-free)", () => {
  test("extractKVRow: full-attention row == solo replay (bytes + offset)", () => {
    const D = 4;
    const lens = [5, 3];
    const val = (b: number, t: number, d: number) => b * 1000 + t * 10 + d;

    // Solo caches: prefill each row, keep updating them alongside the batch.
    const solos = lens.map((L, b) => {
      const c = new KVCache();
      const k = grid(L, D, (t, d) => val(b, t, d));
      const [rk, rv] = c.updateAndFetch(k, k);
      rk.dispose(); rv.dispose(); k.dispose();
      return c;
    });

    // Batched cache exactly as the scheduler assembles it (mergeKVRows →
    // restoreState), then 3 shared decode steps.
    const rows = solos.map((c) => {
      const [tk, tv] = c.temporalView();
      return { keys: tk, values: tv };
    });
    const m = mergeKVRows(rows);
    for (const r of rows) { r.keys.dispose(); r.values.dispose(); }
    const batched = new KVCache();
    batched.restoreState(m.keys, m.values, m.width);

    for (let s = 0; s < 3; s++) {
      const step = (b: number, d: number) => val(b, lens[b]! + s, d);
      const kb = MlxArray.fromFloat32(
        Float32Array.from([0, 1].flatMap((b) => [0, 1, 2, 3].map((d) => step(b, d)))),
        [2, 1, 1, D],
      );
      const [bk, bv] = batched.updateAndFetch(kb, kb);
      bk.dispose(); bv.dispose(); kb.dispose();
      for (let b = 0; b < 2; b++) {
        const k1 = grid(1, D, (_t, d) => step(b, d));
        const [sk, sv] = solos[b]!.updateAndFetch(k1, k1);
        sk.dispose(); sv.dispose(); k1.dispose();
      }
    }

    for (let b = 0; b < 2; b++) {
      const ex = extractKVRow(batched, m.leftPad[b]!, b);
      expect(ex.offset).toBe(solos[b]!.offset);
      const [ek, ev] = ex.temporalView();
      const [sk, sv] = solos[b]!.temporalView();
      expect(bytes(ek)).toEqual(bytes(sk));
      expect(bytes(ev)).toEqual(bytes(sv));
      for (const a of [ek, ev, sk, sv]) a.dispose();
      ex.dispose();
    }
    batched.dispose();
    for (const c of solos) c.dispose();
  });

  test("extractQuantRow: quantized full-attention row == solo replay (six components)", () => {
    const D = 64, GS = 64, BITS = 4;
    const lens = [5, 3];
    const val = (b: number, t: number, d: number) => b * 100 + t * 3 + d * 0.5;

    const solos = lens.map((L, b) => {
      const c = new KVCache();
      const k = grid(L, D, (t, d) => val(b, t, d));
      const [rk, rv] = c.updateAndFetch(k, k);
      rk.dispose(); rv.dispose(); k.dispose();
      return c.toQuantized(GS, BITS);
    });

    const dispose3 = (t: QuantRow) => {
      for (const x of [t.keys, t.values])
        { x.packed.dispose(); x.scales.dispose(); x.biases.dispose(); }
    };
    const rows: QuantRow[] = solos.map((c) => {
      const [tk, tv] = c.temporalView();
      return { keys: tk, values: tv };
    });
    const m = mergeQuantRows(rows);
    for (const r of rows) dispose3(r);
    const batched = new QuantizedKVCache(GS, BITS);
    batched.restoreState(m.keys, m.values, m.width);

    for (let s = 0; s < 3; s++) {
      const step = (b: number, d: number) => val(b, lens[b]! + s, d);
      const data = new Float32Array(2 * D);
      for (let b = 0; b < 2; b++) for (let d = 0; d < D; d++) data[b * D + d] = step(b, d);
      const kb = MlxArray.fromFloat32(data, [2, 1, 1, D]);
      const [bk, bv] = batched.updateAndFetchQuantized(kb, kb);
      dispose3({ keys: bk, values: bv }); kb.dispose();
      for (let b = 0; b < 2; b++) {
        const k1 = grid(1, D, (_t, d) => step(b, d));
        const [sk, sv] = solos[b]!.updateAndFetchQuantized(k1, k1);
        dispose3({ keys: sk, values: sv }); k1.dispose();
      }
    }

    for (let b = 0; b < 2; b++) {
      const ex = extractQuantRow(batched, m.leftPad[b]!, b);
      expect(ex.offset).toBe(solos[b]!.offset);
      const [ek, ev] = ex.temporalView();
      const [sk, sv] = solos[b]!.temporalView();
      for (const part of ["packed", "scales", "biases"] as const) {
        expect(bytes(ek[part])).toEqual(bytes(sk[part]));
        expect(bytes(ev[part])).toEqual(bytes(sv[part]));
      }
      dispose3({ keys: ek, values: ev });
      dispose3({ keys: sk, values: sv });
      ex.dispose();
    }
    batched.dispose();
    for (const c of solos) c.dispose();
  });

  test("BatchedRotatingCache.extractRow: through ring wrap == solo replay", () => {
    const W = 8, D = 2;
    const lens = [6, 4];
    const val = (b: number, t: number, d: number) => b * 1000 + t * 10 + d;

    const solos = lens.map((L, b) => {
      const c = new RotatingKVCache(W);
      const k = grid(L, D, (t, d) => val(b, t, d));
      const [rk, rv] = c.updateAndFetch(k, k);
      rk.dispose(); rv.dispose(); k.dispose();
      return c;
    });
    const rows = solos.map((c) => {
      const [tk, tv] = c.temporalView();
      return { keys: tk, values: tv };
    });
    const batched = BatchedRotatingCache.merge(rows, [...lens], W);
    for (const r of rows) { r.keys.dispose(); r.values.dispose(); }

    // 8 decode steps: crosses trim, rotation, and wrapped steady state.
    for (let s = 0; s < 8; s++) {
      const step = (b: number, d: number) => val(b, lens[b]! + s, d);
      const kb = MlxArray.fromFloat32(
        Float32Array.from([0, 1].flatMap((b) => [0, 1].map((d) => step(b, d)))),
        [2, 1, 1, D],
      );
      const [bk, bv] = batched.updateAndFetch(kb, kb);
      bk.dispose(); bv.dispose(); kb.dispose();
      batched.releaseRopeArr();
      for (let b = 0; b < 2; b++) {
        const k1 = grid(1, D, (_t, d) => step(b, d));
        const [sk, sv] = solos[b]!.updateAndFetch(k1, k1);
        sk.dispose(); sv.dispose(); k1.dispose();
      }
      // Extract EVERY step: pre-wrap (pad>0), mid-trim, and rotated states.
      for (let b = 0; b < 2; b++) {
        const ex = batched.extractRow(b)!;
        expect(ex).not.toBeNull();
        expect(ex.offset).toBe(solos[b]!.offset);
        const [ek, ev] = ex.temporalView();
        const [sk, sv] = solos[b]!.temporalView();
        expect(bytes(ek)).toEqual(bytes(sk));
        expect(bytes(ev)).toEqual(bytes(sv));
        for (const a of [ek, ev, sk, sv]) a.dispose();
        ex.dispose();
      }
    }

    // Behavioral: the extracted ring state DECODES like the solo cache
    // (offset/idx were reconstructed correctly, not just the bytes).
    const ex = batched.extractRow(0)!;
    const k1 = grid(1, D, () => 7.5);
    for (const c of [ex, solos[0]!] as RotatingKVCache[]) {
      const [rk, rv] = c.updateAndFetch(k1, k1);
      rk.dispose(); rv.dispose();
    }
    k1.dispose();
    const [ek, ev] = ex.temporalView();
    const [sk, sv] = solos[0]!.temporalView();
    expect(ex.offset).toBe(solos[0]!.offset);
    expect(bytes(ek)).toEqual(bytes(sk));
    expect(bytes(ev)).toEqual(bytes(sv));
    for (const a of [ek, ev, sk, sv]) a.dispose();
    ex.dispose();
    batched.dispose();
    for (const c of solos) c.dispose();
  });

  test("BatchedRotatingQuantCache.extractRow: through ring wrap == solo replay", () => {
    const W = 8, D = 64, GS = 64, BITS = 4;
    const lens = [6, 4];
    const val = (b: number, t: number, d: number) => b * 50 + t * 2 + d * 0.25;

    const solos: RotatingQuantizedKVCache[] = lens.map((L, b) => {
      const c = new RotatingKVCache(W);
      const k = grid(L, D, (t, d) => val(b, t, d));
      const [rk, rv] = c.updateAndFetch(k, k);
      rk.dispose(); rv.dispose(); k.dispose();
      return c.toQuantized(GS, BITS);
    });
    const dispose3 = (t: QuantRow) => {
      for (const x of [t.keys, t.values])
        { x.packed.dispose(); x.scales.dispose(); x.biases.dispose(); }
    };
    const rows: QuantRow[] = solos.map((c) => {
      const [tk, tv] = c.temporalView();
      return { keys: tk, values: tv };
    });
    const batched = BatchedRotatingQuantCache.merge(rows, [...lens], W, GS, BITS);
    for (const r of rows) dispose3(r);

    for (let s = 0; s < 8; s++) {
      const step = (b: number, d: number) => val(b, lens[b]! + s, d);
      const data = new Float32Array(2 * D);
      for (let b = 0; b < 2; b++) for (let d = 0; d < D; d++) data[b * D + d] = step(b, d);
      const kb = MlxArray.fromFloat32(data, [2, 1, 1, D]);
      const [bk, bv] = batched.updateAndFetchQuantized(kb, kb);
      dispose3({ keys: bk, values: bv }); kb.dispose();
      batched.releaseRopeArr();
      for (let b = 0; b < 2; b++) {
        const k1 = grid(1, D, (_t, d) => step(b, d));
        const [sk, sv] = solos[b]!.updateAndFetchQuantized(k1, k1);
        dispose3({ keys: sk, values: sv }); k1.dispose();
      }
      for (let b = 0; b < 2; b++) {
        const ex = batched.extractRow(b)!;
        expect(ex).not.toBeNull();
        expect(ex.offset).toBe(solos[b]!.offset);
        // the oracle's canonical ring state: temporal order, head at the end
        expect(ex.ringIdx).toBe(ex.keys!.packed.shape[2]!);
        const [ek, ev] = ex.temporalView();
        const [sk, sv] = solos[b]!.temporalView();
        for (const part of ["packed", "scales", "biases"] as const) {
          expect(bytes(ek[part])).toEqual(bytes(sk[part]));
          expect(bytes(ev[part])).toEqual(bytes(sv[part]));
        }
        dispose3({ keys: ek, values: ev });
        dispose3({ keys: sk, values: sv });
        ex.dispose();
      }
    }
    batched.dispose();
    for (const c of solos) c.dispose();
  });
});

// --- SSM (gated-DeltaNet) per-row extraction --------------------------------
// mlx-lm ArraysCache.extract (models/cache.py:673-676) is a bare B-axis slice
// of every state slot; the oracle tracks NO offset (coverage is the server's
// bookkeeping). Ours must also carry the row's OWN token coverage, because
// prompt-cache put() keys on it — that's `offsets`, seeded at merge, advanced
// in lockstep, filtered on eviction. State slots have no temporal axis, so
// unlike KV there is no left-pad to cut: byte equality vs a solo replay is
// pure B-slicing; the thing under test is the offset bookkeeping.

describe("SSMCache per-row extraction (model-free)", () => {
  const CONV_SHAPE = [2, 3], REC_SHAPE = [1, 2, 2];
  const CONV_N = 6, REC_N = 4;
  /** Distinct per-(row, token-coverage) state so a wrong slice OR a wrong
   *  offset both change bytes. */
  const stateFor = (row: number, off: number) => ({
    conv: Float32Array.from({ length: CONV_N }, (_, i) => row * 1000 + off * 10 + i),
    rec: Float32Array.from({ length: REC_N }, (_, i) => row * 1000 + off * 10 + 100 + i),
  });
  /** Overwrite `c`'s state slots the way the linear-attn layer does (fresh
   *  arrays per forward; qwen3_5.ts LinearAttention.forward). */
  const setState = (c: SSMCache, rows: { row: number; off: number }[]) => {
    const B = rows.length;
    const conv = new Float32Array(B * CONV_N);
    const rec = new Float32Array(B * REC_N);
    rows.forEach(({ row, off }, b) => {
      conv.set(stateFor(row, off).conv, b * CONV_N);
      rec.set(stateFor(row, off).rec, b * REC_N);
    });
    c.conv?.dispose();
    c.recurrent?.dispose();
    c.conv = MlxArray.fromFloat32(conv, [B, ...CONV_SHAPE]);
    c.recurrent = MlxArray.fromFloat32(rec, [B, ...REC_SHAPE]);
  };

  test("extractRow through merge/steps/filter == solo replay (bytes + per-row offset)", () => {
    const lens = [5, 3, 4];
    // Solo replay caches: "prefill" = state at coverage lens[b].
    const solos = lens.map((L, b) => {
      const c = new SSMCache();
      setState(c, [{ row: b, off: L }]);
      c.advance(L);
      return c;
    });
    const soloStep = (b: number) => {
      const c = solos[b]!;
      setState(c, [{ row: b, off: c.offset + 1 }]);
      c.advance(1);
    };
    /** The joiner's freshly-prefilled SERIAL cache (twin of solo b). */
    const twin = (b: number) => {
      const c = new SSMCache();
      setState(c, [{ row: b, off: solos[b]!.offset }]);
      c.advance(solos[b]!.offset);
      return c;
    };
    let rowIds = [0]; // rowIds[b] = which solo occupies batched row b
    let batched = twin(0); // adopt path: the lone row's serial cache IS the batch
    const join = (solo: number) => {
      const t = twin(solo);
      const next = SSMCache.mergeRows(batched, t);
      batched.dispose();
      t.dispose();
      batched = next;
      rowIds.push(solo);
    };
    const batchedStep = () => {
      setState(batched, rowIds.map((row, b) => ({ row, off: batched.rowOffset(b) + 1 })));
      batched.advance(1);
      for (const row of rowIds) soloStep(row);
    };
    const checkAll = () => {
      rowIds.forEach((row, b) => {
        expect(batched.rowOffset(b)).toBe(solos[row]!.offset); // independent bookkeeping
        const ex = batched.extractRow(b);
        expect(ex.offset).toBe(solos[row]!.offset);
        expect(ex.offsets).toBeNull(); // extracted caches are SERIAL
        expect(bytes(ex.conv!)).toEqual(bytes(solos[row]!.conv!));
        expect(bytes(ex.recurrent!)).toEqual(bytes(solos[row]!.recurrent!));
        ex.dispose();
      });
    };

    join(1); // adopted serial prev (offsets null) seeds [prev.offset, solo.offset]
    expect(batched.offsets).toEqual([5, 3]);
    expect(batched.offset).toBe(5); // shared max, unchanged semantics
    batchedStep();
    batchedStep();
    checkAll(); // [7, 5]
    join(2); // mid-decode join of a batched prev
    expect(batched.offsets).toEqual([7, 5, 4]);
    batchedStep();
    batchedStep();
    checkAll(); // [9, 7, 6]
    batched.filter([0, 2]); // evict the middle row
    rowIds = [0, 2];
    expect(batched.offsets).toEqual([9, 6]);
    batchedStep();
    checkAll();
    batched.dispose();
    for (const c of solos) c.dispose();
  });
});

// --- Scheduler end-to-end (stub model, single full-attention layer) --------
// Drives the REAL BatchScheduler: row A adopts, row B merges in (A gets a
// nonzero left pad on B's extend-join... and vice versa), B finishes FIRST
// inside the 2-row batch (the case that previously destroyed its KV), A
// finishes last as a merged lone row. Both must land in the prompt cache
// keyed by exactly [promptIds + fed], byte-identical to a solo replay.

const D = 4, V = 8, HD = 2;

/** k/v written per forward: each token's value broadcast over D — the cache
 *  bytes ARE the token history, so byte equality proves coverage exactness. */
const kvFromIds = (ids: MlxArray): MlxArray => {
  const [B, L] = ids.shape as [number, number];
  const f = ids.astype(Dtype.float32);
  const col = ops.reshape(f, [B, 1, L, 1]);
  f.dispose();
  const k = ops.concatAxis([col, col, col, col], 3); // [B,1,L,D]
  col.dispose();
  return k;
};

const stubModel = {
  config: { modelType: "stub" },
  makeCache: (): Cache[] => [new KVCache()],
  forwardHidden(ids: MlxArray, caches: Cache[]): MlxArray {
    const [B, L] = ids.shape as [number, number];
    const k = kvFromIds(ids);
    for (const c of caches) {
      const [rk, rv] = c.updateAndFetch(k, k);
      rk.dispose(); rv.dispose();
    }
    k.dispose();
    return ops.zeros([B, L, HD], Dtype.float32);
  },
  logitsFromHidden(h: MlxArray): MlxArray {
    const [B, N] = h.shape as [number, number, number];
    return ops.zeros([B, N, V], Dtype.float32); // argmax → token 0 every step
  },
} as unknown as RuntimeModel;

const soloReplay = (tokens: number[]): KVCache => {
  const c = new KVCache();
  const feed = (toks: number[]) => {
    const ids = ops.fromInt32(toks, [1, toks.length]);
    const k = kvFromIds(ids);
    ids.dispose();
    const [rk, rv] = c.updateAndFetch(k, k);
    rk.dispose(); rv.dispose(); k.dispose();
  };
  feed(tokens);
  return c;
};

describe("BatchScheduler per-row extraction (stub model)", () => {
  test("finished rows in a multi-row batch put() exact serial caches", async () => {
    const puts: { tokens: number[]; caches: Cache[] }[] = [];
    const pc: RowPromptCache = {
      take: () => null,
      put: (tokens, caches) => { puts.push({ tokens: [...tokens], caches }); },
    };
    const sched = new BatchScheduler(stubModel, { maxBatch: 2, promptCache: pc });

    const promptA = Array.from({ length: 300 }, (_, i) => 1000 + i);
    const promptB = Array.from({ length: 256 }, (_, i) => 2000 + i);
    const submit = (promptIds: number[], maxTokens: number) =>
      sched.submit({
        promptIds, maxTokens, eosTokenIds: [],
        sample: (l) => ops.argmaxAxis(l, -1),
        onToken: () => {},
      });
    const [stA, stB] = await Promise.all([submit(promptA, 10), submit(promptB, 3)]);
    expect(stA.generatedTokens).toBe(10);
    expect(stB.generatedTokens).toBe(3);

    // B finished inside the 2-row batch; A finished last (merged, lone).
    // Coverage = tokens whose KV ENTERED: B's last token fed (A was still
    // live, so a forward ran at B's finishing step → 3 tokens); A's last
    // token never fed (no live sibling → no forward at its final step → 9
    // of 10). The offset check in #putOrDispose (offset === tokens.length)
    // held for both — that IS the fed-exactness regression.
    // THREE puts: A's admission boundary snapshot (A5 — strict prefix
    // promptA[:-1], 299 ≥ 256 gate; B at 255 stays under it) plus the two
    // finish-time extractions this test is about.
    expect(puts.length).toBe(3);
    const snapA = puts.find((p) => p.tokens[0] === 1000 && p.tokens.length === promptA.length - 1)!;
    expect(snapA.tokens).toEqual(promptA.slice(0, -1));
    const putB = puts.find((p) => p.tokens[0] === 2000)!;
    const putA = puts.find((p) => p.tokens[0] === 1000 && p.tokens.length > promptA.length)!;
    expect(putB.tokens).toEqual([...promptB, 0, 0, 0]);
    expect(putA.tokens).toEqual([...promptA, ...Array(9).fill(0)]);

    // Byte equality vs a solo replay of the same token coverage.
    for (const p of [putA, putB]) {
      expect(p.caches.length).toBe(1);
      const ex = p.caches[0] as KVCache;
      expect(ex).toBeInstanceOf(KVCache);
      expect(ex.offset).toBe(p.tokens.length);
      const solo = soloReplay(p.tokens);
      const [ek, ev] = ex.temporalView();
      const [sk, sv] = solo.temporalView();
      expect(bytes(ek)).toEqual(bytes(sk));
      expect(bytes(ev)).toEqual(bytes(sv));
      for (const a of [ek, ev, sk, sv]) a.dispose();
      solo.dispose();
      for (const c of p.caches) c.dispose();
    }
  }, 30_000);

  test("substantiality gate: merged rows with prompts < 256 are not put()", async () => {
    const puts: { tokens: number[] }[] = [];
    const pc: RowPromptCache = {
      take: () => null,
      put: (tokens, caches) => {
        puts.push({ tokens });
        for (const c of caches) c.dispose();
      },
    };
    const sched = new BatchScheduler(stubModel, { maxBatch: 2, promptCache: pc });
    const submit = (base: number, maxTokens: number) =>
      sched.submit({
        promptIds: Array.from({ length: 8 }, (_, i) => base + i),
        maxTokens, eosTokenIds: [],
        sample: (l) => ops.argmaxAxis(l, -1),
        onToken: () => {},
      });
    const [a, b] = await Promise.all([submit(100, 8), submit(200, 3)]);
    expect(a.generatedTokens).toBe(8);
    expect(b.generatedTokens).toBe(3);
    // B (merged, in-batch finish) gated out by promptTokens < 256; A's
    // final lone finish is merged too → same gate. No entries.
    expect(puts.length).toBe(0);
  }, 30_000);
});

// --- Scheduler end-to-end (HYBRID stub: full-attention + SSM layer) ---------
// The Qwen3.5 shape: one plain KVCache layer and one SSMCache layer in the
// same inners list. The SSM state is an order-sensitive integer fold of every
// token that FED a forward — so byte equality of the extracted recurrent state
// vs a host replay over exactly [promptIds + fed] proves coverage exactness,
// and the scheduler's per-row offset gate (#extractRowCaches) proves the
// bookkeeping. Same scenario as the single-layer test: B finishes FIRST
// inside the 2-row batch, A finishes last as a merged lone row.

/** Order-sensitive fold, exact in f32 (values stay < 2^24). */
const ssmFold = (r: number, tok: number) => (r * 31 + tok) % 65536;

/** The stub linear-attn layer: recurrent [B,1,1,1] = fold over the row's fed
 *  tokens, conv [B,1,1] = the row's last fed token. Fresh arrays per forward +
 *  advance(L), like qwen3_5.ts LinearAttention.forward. */
const ssmUpdate = (ids: MlxArray, c: SSMCache): void => {
  const [B, L] = ids.shape as [number, number];
  const toks = ids.toIntTokens();
  const cur = c.recurrent ? c.recurrent.toFloat32() : new Float32Array(B);
  const rec = new Float32Array(B);
  const conv = new Float32Array(B);
  for (let b = 0; b < B; b++) {
    let r = cur[b]!;
    for (let t = 0; t < L; t++) r = ssmFold(r, toks[b * L + t]!);
    rec[b] = r;
    conv[b] = toks[b * L + L - 1]!;
  }
  c.conv?.dispose();
  c.recurrent?.dispose();
  c.conv = MlxArray.fromFloat32(conv, [B, 1, 1]);
  c.recurrent = MlxArray.fromFloat32(rec, [B, 1, 1, 1]);
  c.advance(L);
};

const hybridStub = {
  config: { modelType: "stub" },
  makeCache: (): Cache[] => [new KVCache(), new SSMCache()],
  forwardHidden(ids: MlxArray, caches: Cache[]): MlxArray {
    const [B, L] = ids.shape as [number, number];
    for (const c of caches) {
      if (c instanceof SSMCache) {
        ssmUpdate(ids, c); // SSM inners pass through the step UNWRAPPED
        continue;
      }
      const k = kvFromIds(ids);
      const [rk, rv] = c.updateAndFetch(k, k);
      rk.dispose(); rv.dispose(); k.dispose();
    }
    return ops.zeros([B, L, HD], Dtype.float32);
  },
  logitsFromHidden(h: MlxArray): MlxArray {
    const [B, N] = h.shape as [number, number, number];
    return ops.zeros([B, N, V], Dtype.float32); // argmax → token 0 every step
  },
} as unknown as RuntimeModel;

describe("BatchScheduler per-row extraction (hybrid stub: KV + SSM)", () => {
  test("finished rows put() exact serial caches for BOTH layer kinds", async () => {
    const puts: { tokens: number[]; caches: Cache[] }[] = [];
    const pc: RowPromptCache = {
      take: () => null,
      put: (tokens, caches) => { puts.push({ tokens: [...tokens], caches }); },
    };
    const sched = new BatchScheduler(hybridStub, { maxBatch: 2, promptCache: pc });

    const promptA = Array.from({ length: 300 }, (_, i) => 1000 + i);
    const promptB = Array.from({ length: 256 }, (_, i) => 2000 + i);
    const submit = (promptIds: number[], maxTokens: number) =>
      sched.submit({
        promptIds, maxTokens, eosTokenIds: [],
        sample: (l) => ops.argmaxAxis(l, -1),
        onToken: () => {},
      });
    const [stA, stB] = await Promise.all([submit(promptA, 10), submit(promptB, 3)]);
    expect(stA.generatedTokens).toBe(10);
    expect(stB.generatedTokens).toBe(3);

    // Same three puts as the single-layer scenario (see that test's coverage
    // math): A's boundary snapshot + the two finish-time extractions. The
    // extractions REQUIRE the SSM per-row offset gate to have passed.
    expect(puts.length).toBe(3);
    const putB = puts.find((p) => p.tokens[0] === 2000)!;
    const putA = puts.find((p) => p.tokens[0] === 1000 && p.tokens.length > promptA.length)!;
    expect(putB.tokens).toEqual([...promptB, 0, 0, 0]);
    expect(putA.tokens).toEqual([...promptA, ...Array(9).fill(0)]);

    for (const p of [putA, putB]) {
      expect(p.caches.length).toBe(2);
      const kv = p.caches[0] as KVCache;
      const ssm = p.caches[1] as SSMCache;
      expect(kv).toBeInstanceOf(KVCache);
      expect(ssm).toBeInstanceOf(SSMCache);
      // KV row: byte equality vs a solo replay (as before).
      expect(kv.offset).toBe(p.tokens.length);
      const solo = soloReplay(p.tokens);
      const [ek, ev] = kv.temporalView();
      const [sk, sv] = solo.temporalView();
      expect(bytes(ek)).toEqual(bytes(sk));
      expect(bytes(ev)).toEqual(bytes(sv));
      for (const a of [ek, ev, sk, sv]) a.dispose();
      solo.dispose();
      // SSM row: coverage-exact offset, SERIAL shape, state == host fold
      // over exactly [promptIds + fed] (order-sensitive — any dropped,
      // duplicated, or reordered fed token changes the value).
      expect(ssm.offset).toBe(p.tokens.length);
      expect(ssm.offsets).toBeNull();
      let r = 0;
      for (const t of p.tokens) r = ssmFold(r, t);
      expect([...ssm.recurrent!.toFloat32()]).toEqual([r]);
      expect([...ssm.conv!.toFloat32()]).toEqual([p.tokens[p.tokens.length - 1]!]);
      for (const c of p.caches) c.dispose();
    }

    // The boundary snapshot rides the same hybrid list: SSM clone covers
    // exactly promptA[:-1] (state advanced through the pre-boundary chunk).
    const snapA = puts.find((p) => p.tokens.length === promptA.length - 1)!;
    expect(snapA.tokens).toEqual(promptA.slice(0, -1));
    const snapSsm = snapA.caches[1] as SSMCache;
    expect(snapSsm).toBeInstanceOf(SSMCache);
    expect(snapSsm.offset).toBe(promptA.length - 1);
    let rs = 0;
    for (const t of snapA.tokens) rs = ssmFold(rs, t);
    expect([...snapSsm.recurrent!.toFloat32()]).toEqual([rs]);
    for (const c of snapA.caches) c.dispose();
  }, 30_000);
});
