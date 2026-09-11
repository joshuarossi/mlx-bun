// FAST (no model load): the SSMCache speculative verify-round contract that
// unblocks native Qwen MTP (and any drafter on a gated-DeltaNet target).
//
// Two halves:
//  1. The KERNEL PREFIX PROPERTY the rollback replay relies on — processing
//     a T-token window in one gated_delta_update call, versus processing its
//     first k tokens then chaining the rest from the intermediate state, is
//     BIT-EXACT in both y and the final recurrent state (the kernel's
//     per-thread loop is serial, so the prefix arithmetic is identical).
//     Uses the real-geometry inputs from tests/fixtures/qwen-delta-golden.json.
//  2. The SSMCache round bookkeeping: snapshot restore on rollback, replay
//     dispatch with the kept-token count, commit/dispose lifecycle, and the
//     armed-round guard rails.
//
// The end-to-end serve-loop gate (real weights, rollbacks under real rejects,
// token-identical to non-spec greedy) is tests/qwen35-spec-ngram.test.ts;
// the native-MTP pairing gate is tests/qwen38-mtp.test.ts.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import { gatedDeltaUpdate, SSMCache } from "../../src/model/qwen3-delta";
import { gatedDeltaState } from "../../src/model/qwen3-delta-state";
import { createHash } from "node:crypto";
import * as ops from "../../src/mlx/ops";

const g = await Bun.file(`${import.meta.dir}/../fixtures/qwen-delta-golden.json`).json();

const bf16 = (vals: number[], shape: number[]): MlxArray => {
  const f = MlxArray.fromFloat32(Float32Array.from(vals), shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
};

describe("gated-DeltaNet kernel prefix property (spec-round rollback replay)", () => {
  for (const B of [1, 2]) test(`full window == prefix replay + chained tail at B=${B}, bit-exact y and state`, () => {
    const { HK, HV, DK, DV } = g as {
      HK: number; HV: number; DK: number; DV: number;
    };
    const T = g.prefill.T as number;
    expect(T).toBeGreaterThan(1);
    const aLog = bf16(g.A_log, [HV]);
    const dtBias = bf16(g.dt_bias, [HV]);

    const slice = (vals: number[], perTok: number, from: number, to: number) =>
      Array.from({ length: B }, (_, row) =>
        vals.slice(from * perTok, to * perTok).map(value => value * (row + 1))).flat();
    const load = (from: number, to: number) => ({
      q: bf16(slice(g.prefill.q, HK * DK, from, to), [B, to - from, HK, DK]),
      k: bf16(slice(g.prefill.k, HK * DK, from, to), [B, to - from, HK, DK]),
      v: bf16(slice(g.prefill.v, HV * DV, from, to), [B, to - from, HV, DV]),
      a: bf16(slice(g.prefill.a, HV, from, to), [B, to - from, HV]),
      b: bf16(slice(g.prefill.b, HV, from, to), [B, to - from, HV]),
    });
    const run = (t: ReturnType<typeof load>, state: MlxArray | null) => {
      const [y, s] = gatedDeltaUpdate(t.q, t.k, t.v, t.a, t.b, aLog, dtBias, state);
      for (const x of [t.q, t.k, t.v, t.a, t.b]) x.dispose();
      return [y, s] as const;
    };

    for (let keep = 1; keep < T; keep++) {
      // One-shot over the full window (what the verify forward does).
      const [yFull, sFull] = run(load(0, T), null);
      // Rollback replay over the accepted prefix, then the next round's
      // continuation over the tail from the replayed state.
      const [yPfx, sPfx] = run(load(0, keep), null);
      const [yTail, sTail] = run(load(keep, T), sPfx);

      const full = yFull.toFloat32();
      using chained = ops.concatAxis([yPfx, yTail], 1);
      const replayed = chained.toFloat32();
      for (let i = 0; i < full.length; i++) expect(replayed[i]).toBe(full[i]);
      const s1 = sFull.toFloat32();
      const s2 = sTail.toFloat32();
      for (let i = 0; i < s1.length; i++) expect(s2[i]).toBe(s1[i]);

      for (const x of [yFull, sFull, yPfx, sPfx, yTail, sTail]) x.dispose();
    }
    aLog.dispose();
    dtBias.dispose();
  });
});

test("state-only batched replay matches each row's retained prefix, including zero and unequal lengths", () => {
  const { HK, HV, DK, DV } = g;
  const T = g.prefill.T as number, B = 2;
  const load = (values: number[], shape: number[]) => bf16([...values, ...values.map(value => -value)], shape);
  using q = load(g.prefill.q, [B, T, HK, DK]);
  using k = load(g.prefill.k, [B, T, HK, DK]);
  using v = load(g.prefill.v, [B, T, HV, DV]);
  using a = load(g.prefill.a, [B, T, HV]);
  using b = load(g.prefill.b, [B, T, HV]);
  using aLog = bf16(g.A_log, [HV]);
  using dtBias = bf16(g.dt_bias, [HV]);
  using initial = MlxArray.fromFloat32(Float32Array.from({ length: B * HV * DV * DK },
    (_, index) => Math.sin(index * 0.17) * 0.03), [B, HV, DV, DK]);
  const digest = (array: MlxArray) => {
    using contiguous = ops.contiguous(array);
    return createHash("sha256").update(contiguous.rawBytesView()).digest("hex");
  };
  const row = (array: MlxArray, index: number, length?: number) => {
    const lo = array.shape.map(() => 0), hi = [...array.shape];
    lo[0] = index; hi[0] = index + 1;
    if (length !== undefined) hi[1] = length;
    return array.slice(lo, hi);
  };
  for (const state of [null, initial]) {
    for (const lengths of [[0, T], [1, T - 1], [T - 1, 1], [T, T]]) {
      using actual = gatedDeltaState(k, v, a, b, aLog, dtBias, state, lengths);
      for (let index = 0; index < B; index++) {
        using prior = state ? row(state, index) : ops.zeros([1, HV, DV, DK], Dtype.float32);
        using found = row(actual, index);
        const keep = lengths[index]!;
        if (keep === 0) { expect(digest(found)).toBe(digest(prior)); continue; }
        using qr = row(q, index, keep);
        using kr = row(k, index, keep);
        using vr = row(v, index, keep);
        using ar = row(a, index, keep);
        using br = row(b, index, keep);
        const [output, expected] = gatedDeltaUpdate(qr, kr, vr, ar, br, aLog, dtBias, prior);
        try { expect(digest(found)).toBe(digest(expected)); }
        finally { output.dispose(); expected.dispose(); }
      }
    }
  }
});

describe("SSMCache speculative round lifecycle", () => {
  const tiny = (fill: number): MlxArray =>
    MlxArray.fromFloat32(Float32Array.from([fill]), [1, 1, 1]);

  /** Play the layer's part of an armed round: stash the replaced slots and
   *  install a spy replay (the real layer installs #replaySpecPrefix). */
  const recordRound = (
    c: SSMCache, S: number, calls: number[],
  ): { conv: MlxArray; recurrent: MlxArray } => {
    const r = c.specRound!;
    expect(r.armed).toBe(true);
    r.armed = false;
    r.S = S;
    r.qkv = tiny(9);
    r.a = tiny(9);
    r.b = tiny(9);
    r.replay = (cache, keep) => {
      calls.push(typeof keep === "number" ? keep : Math.max(...keep));
      if (typeof keep === "number") cache.advance(keep);
      else cache.advanceRows(keep);
    };
    const conv = tiny(101);
    const recurrent = tiny(102);
    r.prevConv = c.conv;
    c.conv = conv;
    r.prevRecurrent = c.recurrent;
    c.recurrent = recurrent;
    c.advance(S);
    return { conv, recurrent };
  };

  test("rollback restores the snapshot, replays the kept prefix, fixes offset", () => {
    const c = new SSMCache();
    const conv0 = tiny(1);
    const rec0 = tiny(2);
    c.conv = conv0;
    c.recurrent = rec0;
    c.offset = 7;
    const calls: number[] = [];
    c.specRoundBegin();
    recordRound(c, 4, calls);
    expect(c.offset).toBe(11); // the verify forward advanced the window
    c.specRoundRollback(3);
    expect(c.conv).toBe(conv0); // the exact pre-round arrays are back
    expect(c.recurrent).toBe(rec0);
    expect(calls).toEqual([3]); // replay asked for exactly the kept tokens
    expect(c.offset).toBe(10); // 7 + keep, advanced by the spy replay
    expect(c.specRound).toBeNull();
    c.dispose();
  });

  test("commit keeps the post-round state and frees the round", () => {
    const c = new SSMCache();
    c.conv = tiny(1);
    c.recurrent = tiny(2);
    c.offset = 3;
    const calls: number[] = [];
    c.specRoundBegin();
    const { conv, recurrent } = recordRound(c, 2, calls);
    c.specRoundCommit();
    expect(c.conv).toBe(conv);
    expect(c.recurrent).toBe(recurrent);
    expect(c.offset).toBe(5);
    expect(calls).toEqual([]);
    expect(c.specRound).toBeNull();
    c.dispose();
  });

  test("batched rollback preserves independent row coverage for a common accepted prefix", () => {
    const c = new SSMCache();
    c.conv = tiny(1);
    c.recurrent = tiny(2);
    c.offset = 7;
    c.offsets = [7, 3];
    const calls: number[] = [];
    c.specRoundBegin();
    recordRound(c, 4, calls);
    expect(c.offsets).toEqual([11, 7]);
    c.specRoundRollback(2);
    expect(c.offset).toBe(9);
    expect(c.offsets).toEqual([9, 5]);
    expect(calls).toEqual([2]);
    c.specRoundBegin();
    recordRound(c, 3, calls);
    c.specRoundCommit();
    expect(c.offsets).toEqual([12, 8]);
    c.dispose();
  });

  test("guard rails: unarmed rollback throws; re-begin drops a stale round; dispose is safe mid-round", () => {
    const c = new SSMCache();
    c.conv = tiny(1);
    c.recurrent = tiny(2);
    expect(() => c.specRoundRollback(1)).toThrow(/without an armed round/);
    c.specRoundBegin();
    // Armed but never recorded (forward threw before the SSM layer ran).
    expect(() => c.specRoundRollback(1)).toThrow(/before the verify forward/);
    c.specRoundBegin(); // re-arm over the stale round — must not leak/throw
    const calls: number[] = [];
    recordRound(c, 2, calls);
    expect(() => c.specRoundRollback(5)).toThrow(/outside window/);
    c.dispose(); // mid-round dispose frees snapshot + recordings
    expect(c.specRound).toBeNull();
  });
});


test("retiring the longest recurrent row updates group coverage to its survivors", () => {
  const cache = new SSMCache();
  cache.conv = ops.zeros([2, 3, 6], Dtype.bfloat16);
  cache.recurrent = ops.zeros([2, 1, 2, 2], Dtype.float32);
  cache.offsets = [9, 3]; cache.offset = 9;
  try {
    cache.filterRows([1]);
    expect(cache.offsets).toEqual([3]);
    expect(cache.offset).toBe(3);
    cache.advance(1);
    expect(cache.offsets).toEqual([4]);
    expect(cache.offset).toBe(4);
  } finally { cache.dispose(); }
});
