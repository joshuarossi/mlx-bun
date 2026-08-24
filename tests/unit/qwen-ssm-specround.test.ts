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
import * as ops from "../../src/mlx/ops";

const g = await Bun.file(`${import.meta.dir}/../fixtures/qwen-delta-golden.json`).json();

const bf16 = (vals: number[], shape: number[]): MlxArray => {
  const f = MlxArray.fromFloat32(Float32Array.from(vals), shape);
  const b = f.astype(Dtype.bfloat16);
  f.dispose();
  return b;
};

describe("gated-DeltaNet kernel prefix property (spec-round rollback replay)", () => {
  test("full window == prefix replay + chained tail, bit-exact y and state", () => {
    const { B, HK, HV, DK, DV } = g as {
      B: number; HK: number; HV: number; DK: number; DV: number;
    };
    expect(B).toBe(1);
    const T = g.prefill.T as number;
    expect(T).toBeGreaterThan(1);
    const aLog = bf16(g.A_log, [HV]);
    const dtBias = bf16(g.dt_bias, [HV]);

    const slice = (vals: number[], perTok: number, from: number, to: number) =>
      vals.slice(from * perTok, to * perTok);
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
      const pfx = yPfx.toFloat32();
      const tail = yTail.toFloat32();
      const perTok = HV * DV;
      for (let i = 0; i < keep * perTok; i++) expect(pfx[i]).toBe(full[i]);
      for (let i = 0; i < (T - keep) * perTok; i++)
        expect(tail[i]).toBe(full[keep * perTok + i]);
      const s1 = sFull.toFloat32();
      const s2 = sTail.toFloat32();
      for (let i = 0; i < s1.length; i++) expect(s2[i]).toBe(s1[i]);

      for (const x of [yFull, sFull, yPfx, sPfx, yTail, sTail]) x.dispose();
    }
    aLog.dispose();
    dtBias.dispose();
  });
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
      calls.push(keep);
      cache.advance(keep);
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
