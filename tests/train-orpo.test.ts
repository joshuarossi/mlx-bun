// ORPO loss math — validated against a standalone JS reference (the oracle
// ladder's base rung; no model weights, pure mlx array ops). Covers log1mexp
// stability, the log-odds, the L_NLL + λ·L_OR reduction, and that the loss is
// differentiable through lw/lr (the autograd path the trainer relies on).
//
// Reference (paper / TRL ORPO):
//   logodds = (ℓw - ℓr) - (log(1-e^ℓw) - log(1-e^ℓr))
//   L_NLL   = mean(-ℓw)            (unweighted SFT term)
//   L_OR    = mean(softplus(-logodds))
//   loss    = L_NLL + λ·L_OR

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import {
  log1mexp, orpoLossFromLogps, combineFullNll, respSpanFromMask,
  spanLogpMeanFromHidden, responseOnlyLogpMean,
} from "../src/train/loss";

const arr = (xs: number[]) => MlxArray.fromFloat32(new Float32Array(xs), [xs.length]);
const scalar = (a: MlxArray) => a.toFloat32()[0]!;

// --- JS reference --------------------------------------------------------
const refLog1mexp = (x: number) => Math.log(1 - Math.exp(x));
const softplus = (x: number) => Math.log1p(Math.exp(-Math.abs(x))) + Math.max(x, 0);
function refOrpoLoss(lw: number[], lr: number[], lambda: number): number {
  const B = lw.length;
  let nll = 0;
  let or = 0;
  for (let b = 0; b < B; b++) {
    nll += -lw[b]!;
    const logodds = lw[b]! - lr[b]! - (refLog1mexp(lw[b]!) - refLog1mexp(lr[b]!));
    or += softplus(-logodds);
  }
  return nll / B + lambda * (or / B);
}

describe("log1mexp", () => {
  test("matches log(1-exp(x)) for well-negative x", () => {
    const x = arr([-1.0, -0.5, -2.0, -3.5]);
    const got = log1mexp(x);
    const g = got.toFloat32();
    for (const [i, xi] of [-1.0, -0.5, -2.0, -3.5].entries())
      expect(g[i]!).toBeCloseTo(refLog1mexp(xi), 5);
    x.dispose();
    got.dispose();
  });

  test("does not produce NaN/-inf as x→0⁻ (clamped)", () => {
    const x = arr([-1e-6, -1e-4]);
    const got = log1mexp(x);
    for (const v of got.toFloat32()) expect(Number.isFinite(v)).toBe(true);
    x.dispose();
    got.dispose();
  });
});

describe("orpoLossFromLogps vs JS reference", () => {
  for (const lambda of [0.1, 0.5, 1.0]) {
    test(`λ=${lambda}`, () => {
      const lwv = [-0.5, -1.2, -0.8];
      const lrv = [-1.5, -1.0, -2.3]; // mix: chosen better, rejected better, chosen better
      const lw = arr(lwv);
      const lr = arr(lrv);
      const loss = orpoLossFromLogps(lw, lr, lambda);
      expect(scalar(loss)).toBeCloseTo(refOrpoLoss(lwv, lrv, lambda), 4);
      lw.dispose();
      lr.dispose();
      loss.dispose();
    });
  }

  test("preferring chosen (higher ℓw) lowers the OR term", () => {
    // Same NLL (same ℓw), but a worse rejected → larger margin → smaller L_OR.
    const lw = arr([-0.8]);
    const close = orpoLossFromLogps(lw, arr([-0.9]), 1.0);
    const far = orpoLossFromLogps(lw, arr([-3.0]), 1.0);
    expect(scalar(far)).toBeLessThan(scalar(close));
    lw.dispose();
    close.dispose();
    far.dispose();
  });
});

describe("orpoLossFromLogps sft_scope regression pin (response scope BIT-IDENTICAL to pre-sft_scope)", () => {
  // Exact f32 values captured from the pre-change orpoLossFromLogps on this
  // machine (2026-07-01, before the nllFull parameter existed). The response
  // scope (nllFull absent) must reproduce them bit-for-bit: same ops, same
  // order — any drift here means the "response" path is no longer the old code.
  const pins: Array<{ lw: number[]; lr: number[]; lam: number; v: number }> = [
    { lw: [-0.5, -1.2, -0.8], lr: [-1.5, -1.0, -2.3], lam: 0.1, v: 0.87177973985672 },
    { lw: [-0.5, -1.2, -0.8], lr: [-1.5, -1.0, -2.3], lam: 1.0, v: 1.2177971601486206 },
    { lw: [-0.7], lr: [-1.9], lam: 0.1, v: 0.7164066433906555 },
  ];
  for (const p of pins) {
    test(`λ=${p.lam} B=${p.lw.length} → ${p.v}`, () => {
      const lw = arr(p.lw);
      const lr = arr(p.lr);
      const loss = orpoLossFromLogps(lw, lr, p.lam); // nllFull absent = response scope
      expect(scalar(loss)).toBe(p.v); // exact — not toBeCloseTo
      lw.dispose(); lr.dispose(); loss.dispose();
    });
  }
});

describe("orpoLossFromLogps with nllFull (sft_scope: full)", () => {
  test("L = meanAll(nllFull) + λ·L_OR — the OR term still uses response-only lw/lr", () => {
    const lwv = [-0.5, -1.2];
    const lrv = [-1.5, -1.0];
    const nllv = [1.7, 0.9]; // arbitrary positive full-scope NLLs (≠ -lw)
    const lambda = 0.25;
    // JS reference: same OR term as refOrpoLoss, NLL replaced by mean(nllv).
    let or = 0;
    for (let b = 0; b < lwv.length; b++) {
      const logodds = lwv[b]! - lrv[b]! - (refLog1mexp(lwv[b]!) - refLog1mexp(lrv[b]!));
      or += softplus(-logodds);
    }
    const ref = (nllv[0]! + nllv[1]!) / 2 + lambda * (or / lwv.length);
    const lw = arr(lwv);
    const lr = arr(lrv);
    const nllFull = arr(nllv);
    const loss = orpoLossFromLogps(lw, lr, lambda, nllFull);
    expect(scalar(loss)).toBeCloseTo(ref, 5);
    lw.dispose(); lr.dispose(); nllFull.dispose(); loss.dispose();
  });

  test("is differentiable through lw, lr AND nllFull", () => {
    const vag = new ValueAndGrad(
      (p) => orpoLossFromLogps(p[0]!, p[1]!, 0.1, p[2]!),
      [0, 1, 2],
    );
    const lw = arr([-0.5, -1.2]);
    const lr = arr([-1.5, -1.0]);
    const nllFull = arr([1.7, 0.9]);
    const { value, grads } = vag.apply([lw, lr, nllFull]);
    ops.evalAll([value, ...grads]);
    expect(Number.isFinite(scalar(value))).toBe(true);
    expect(grads.length).toBe(3);
    // Read grads through ops.contiguous: the mean vjp is a stride-0 broadcast
    // view, and raw toFloat32 readback on non-contiguous arrays is garbage (the
    // established op-parity lesson).
    const read = (g: MlxArray) => {
      const c = ops.contiguous(g);
      const v = Array.from(c.toFloat32());
      c.dispose();
      return v;
    };
    for (const g of grads) for (const v of read(g)) expect(Number.isFinite(v)).toBe(true);
    // d(loss)/d(nllFull) = 1/B exactly (the meanAll) — the SFT term is unweighted.
    for (const v of read(grads[2]!)) expect(v).toBeCloseTo(0.5, 6);
    value.dispose();
    for (const g of grads) g.dispose();
    vag.dispose(); lw.dispose(); lr.dispose(); nllFull.dispose();
  });
});

describe("respSpanFromMask", () => {
  test("finds the contiguous supervised span (mask[t+1]==1 convention)", () => {
    // L=5 ids, prompt len 3 → mask [0,0,0,1,1]; T=4 input positions.
    expect(respSpanFromMask([0, 0, 0, 1, 1], 4)).toEqual({ startT: 2, M: 2 });
    // all-response after BOS: prompt len 1 → every position supervised.
    expect(respSpanFromMask([0, 1, 1, 1, 1], 4)).toEqual({ startT: 0, M: 4 });
    // no response at all.
    expect(respSpanFromMask([0, 0, 0, 0, 0], 4)).toEqual({ startT: -1, M: 0 });
  });
});

describe("combineFullNll", () => {
  test("-(nP·pm + nR·lw)/(nP+nR), and -lw when there are no prompt predictions", () => {
    const pm = arr([-2.0]);
    const lw = arr([-0.5]);
    // 3 prompt predictions + 2 response → -(3·(-2.0) + 2·(-0.5))/5 = 1.4
    const full = combineFullNll(pm, lw, 3, 2);
    expect(scalar(full)).toBeCloseTo(1.4, 6);
    full.dispose();
    // no prompt → response-only NLL
    const noP = combineFullNll(null, lw, 0, 2);
    expect(scalar(noP)).toBeCloseTo(0.5, 6);
    noP.dispose();
    pm.dispose(); lw.dispose();
  });
});

describe("sft_scope:'full' toy case (3-token prompt + 2-token response, hand-computed logits)", () => {
  // A fake head where hidden == vocab and logitsFromHidden is the identity, so
  // the "logits" ARE the constructed hidden values — NLL_full is computable by
  // hand: logp[t] = h[t][ids[t+1]] − log Σ_v exp(h[t][v]).
  const fake = { logitsFromHidden: (h: MlxArray) => ops.mulScalar(h, 1) };
  const V = 3;
  const hRows = [
    [0.1, -0.4, 0.3],  // t=0 (prompt: predicts ids[1])
    [0.5, 0.2, -0.1],  // t=1 (prompt: predicts ids[2])
    [-0.2, 0.7, 0.05], // t=2 (response: predicts ids[3])
    [0.3, -0.6, 0.9],  // t=3 (response: predicts ids[4])
  ];
  const ids = [2, 0, 1, 2, 0]; // L=5: 3-token prompt [2,0,1] + 2-token response [2,0]
  const mask = [0, 0, 0, 1, 1]; // response tokens are ids[3], ids[4]
  const T = 4;
  const refLogp = (t: number) => {
    const row = hRows[t]!;
    const lse = Math.log(row.reduce((a, x) => a + Math.exp(x), 0));
    return row[ids[t + 1]!]! - lse;
  };
  const mkH = () => {
    const host = new Float32Array(T * V);
    hRows.forEach((r, t) => r.forEach((x, v) => (host[t * V + v] = x)));
    return MlxArray.fromFloat32(host, [1, T, V]);
  };

  test("spanLogpMeanFromHidden matches the hand-computed span means", () => {
    const h = mkH();
    const respRef = (refLogp(2) + refLogp(3)) / 2;
    const promptRef = (refLogp(0) + refLogp(1)) / 2;
    const lw = spanLogpMeanFromHidden(fake, h, ids, 2, 2);
    const pm = spanLogpMeanFromHidden(fake, h, ids, 0, 2);
    expect(scalar(lw)).toBeCloseTo(respRef, 5);
    expect(scalar(pm)).toBeCloseTo(promptRef, 5);
    // ...and agrees with the mask-driven response head (the "response" path).
    const lwMask = responseOnlyLogpMean(fake as never, h, ids, mask);
    expect(scalar(lwMask)).toBeCloseTo(respRef, 6);
    lw.dispose(); pm.dispose(); lwMask.dispose(); h.dispose();
  });

  test("NLL_full == mean CE over ALL 4 supervised positions (prompt + response)", () => {
    const h = mkH();
    const fullRef = -(refLogp(0) + refLogp(1) + refLogp(2) + refLogp(3)) / 4;
    const { startT, M } = respSpanFromMask(mask, T);
    expect({ startT, M }).toEqual({ startT: 2, M: 2 });
    const lw = spanLogpMeanFromHidden(fake, h, ids, startT, M);
    const pm = spanLogpMeanFromHidden(fake, h, ids, 0, startT);
    const nllFull = combineFullNll(pm, lw, startT, M);
    expect(scalar(nllFull)).toBeCloseTo(fullRef, 5);
    nllFull.dispose(); pm.dispose(); lw.dispose(); h.dispose();
  });

  test("full ORPO loss on the toy: L = NLL_full + λ·softplus(−log_odds(ℓw, ℓr))", () => {
    const h = mkH();
    const lambda = 0.1;
    const lwRef = (refLogp(2) + refLogp(3)) / 2;
    const lrRef = -1.3; // synthetic rejected mean logp
    const fullRef = -(refLogp(0) + refLogp(1) + refLogp(2) + refLogp(3)) / 4;
    const logodds = lwRef - lrRef - (refLog1mexp(lwRef) - refLog1mexp(lrRef));
    const ref = fullRef + lambda * softplus(-logodds);

    const { startT, M } = respSpanFromMask(mask, T);
    const lw = spanLogpMeanFromHidden(fake, h, ids, startT, M);
    const pm = spanLogpMeanFromHidden(fake, h, ids, 0, startT);
    const nllFull = combineFullNll(pm, lw, startT, M);
    const lr = arr([lrRef]);
    const loss = orpoLossFromLogps(lw, lr, lambda, nllFull);
    expect(scalar(loss)).toBeCloseTo(ref, 5);
    loss.dispose(); lr.dispose(); nllFull.dispose(); pm.dispose(); lw.dispose(); h.dispose();
  });
});

describe("orpoLossFromLogps is differentiable through lw/lr", () => {
  test("value_and_grad over [lw, lr] matches the value and gives finite grads", () => {
    const lwv = [-0.5, -1.2];
    const lrv = [-1.5, -1.0];
    const lambda = 0.1;
    const vag = new ValueAndGrad(
      (primals) => orpoLossFromLogps(primals[0]!, primals[1]!, lambda),
      [0, 1],
    );
    const lw = arr(lwv);
    const lr = arr(lrv);
    const { value, grads } = vag.apply([lw, lr]);
    ops.evalAll([value, ...grads]);
    expect(scalar(value)).toBeCloseTo(refOrpoLoss(lwv, lrv, lambda), 4);
    expect(grads.length).toBe(2);
    for (const g of grads) for (const v of g.toFloat32()) expect(Number.isFinite(v)).toBe(true);
    value.dispose();
    for (const g of grads) g.dispose();
    vag.dispose();
    lw.dispose();
    lr.dispose();
  });
});
