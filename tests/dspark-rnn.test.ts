// RNN sequential head (paper Eq 6 shape, design-doc faithful — the DSpark PDF
// is not in this repo) as a config-selected alternative to the Markov head
// (Eq 5) in src/spec/dspark/module-dflash.ts. Model-free, CPU-only: same tiny
// stub-model pattern as scripts/dspark-dflash-smoke.ts.
//
// Gate (c) is the key faithfulness check: rnn.wO is zero-init and rnn.*
// params are appended AFTER every shared/markov name in both buildNames()
// and initFromDims(), so a seeded rng handed to an "rnn" config and a
// "markov" config draws IDENTICAL values for every param the two configs
// share — an rnn drafter must therefore produce the exact same forwardInfer
// tokens as a markov drafter at init (both heads emit B=0).

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { AdamW } from "../src/train/optimizer";
import { DflashDrafter, DEFAULT_DFLASH_CONFIG, type TargetDims } from "../src/spec/dspark/module-dflash";
import { dsparkLoss, positionWeights } from "../src/spec/dspark/loss";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

function rng(seed: number): () => number {
  let s = seed >>> 0 || 1;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

const A = 3, G = 5, V = 64, H = 32, m = 3, dDraft = 32;
const baseCfg = { ...DEFAULT_DFLASH_CONFIG, gamma: G, dDraft, nLayers: 2, nHeads: 4, markovRank: 16, tapLayers: [1, 2, 3] };
const dims: TargetDims = { hiddenSize: H, vocabSize: V, eps: 1e-6 };

/** Fresh stub model (only embed.scales.dtype, embed.encode, logitsFromHidden
 *  are used by module-dflash.ts) built from a seeded rng so every caller gets
 *  bit-identical embed/head weights. */
function makeStub(seed: number) {
  const r = rng(seed);
  const fakeEmbed = MlxArray.fromFloat32(new Float32Array(V * H).map(() => (r() - 0.5) * 0.1), [V, H]).eval();
  const fakeHead = MlxArray.fromFloat32(new Float32Array(H * V).map(() => (r() - 0.5) * 0.1), [H, V]).eval();
  const fakeScales = MlxArray.fromFloat32(new Float32Array([1]), [1]).astype(Dtype.bfloat16).eval();
  const stub = {
    embed: { scales: fakeScales, encode: (ids: MlxArray) => ops.takeAxis(fakeEmbed, ids, 0) },
    logitsFromHidden: (h: MlxArray) => {
      const hf = h.dtype === Dtype.float32 ? h : h.astype(Dtype.float32);
      const o = ops.matmul(hf, fakeHead);
      if (hf !== h) hf.dispose();
      return o;
    },
  } as unknown as import("../src/model/gemma4").Gemma4Model;
  return { stub, dispose: () => { fakeEmbed.dispose(); fakeHead.dispose(); fakeScales.dispose(); } };
}

/** Common training-forward fixture tensors, seeded. Caller disposes. */
function makeTrainInputs(seed: number, stub: ReturnType<typeof makeStub>["stub"]) {
  const r = rng(seed);
  const Lctx = 7;
  const mH = m * H;
  const hCtx = MlxArray.fromFloat32(new Float32Array(A * Lctx * mH).map(() => r()), [A, Lctx, mH]);
  const maskData = new Float32Array(A * Lctx).fill(1);
  for (let c = 0; c < 2; c++) maskData[c] = 0; // row 0 has 2 left-pads
  const ctxMask = MlxArray.fromFloat32(maskData, [A, Lctx]);
  const anchorIds = MlxArray.fromInt32(Int32Array.from({ length: A }, () => Math.floor(r() * V)), [A]);
  const anchorEmb = stub.embed.encode(anchorIds); anchorIds.dispose();
  const prevToks = MlxArray.fromInt32(new Int32Array(A * G).map(() => Math.floor(r() * V)), [A, G]);
  const xStar = MlxArray.fromInt32(new Int32Array(A * G).map(() => Math.floor(r() * V)), [A, G]);
  const tgtHidden = MlxArray.fromFloat32(new Float32Array(A * G * H).map(() => r()), [A, G, H]);
  const targetLogits = stub.logitsFromHidden(tgtHidden); tgtHidden.dispose();
  return {
    hCtx, ctxMask, anchorEmb, prevToks, xStar, targetLogits,
    dispose: () => { hCtx.dispose(); ctxMask.dispose(); anchorEmb.dispose(); prevToks.dispose(); xStar.dispose(); targetLogits.dispose(); },
  };
}

describe("DSpark RNN sequential head (Eq 6)", () => {
  test("(a) forwardTrain shapes + conf range under seqHead=rnn", () => {
    const cfg = { ...baseCfg, seqHead: "rnn" as const };
    const { stub, dispose: disposeStub } = makeStub(11);
    const d = DflashDrafter.initFromDims(dims, cfg, "t-rnn");
    const inp = makeTrainInputs(12, stub);

    const out = d.forwardTrain(stub, inp.hCtx, inp.ctxMask, inp.anchorEmb, inp.prevToks);
    expect(out.draftLogits.shape).toEqual([A, G, V]);
    expect(out.conf.shape).toEqual([A, G]);
    const cf = out.conf.toFloat32();
    expect(cf.every((x) => x > 0 && x < 1)).toBe(true);
    out.draftLogits.dispose(); out.conf.dispose();

    d.dispose(); inp.dispose(); disposeStub();
  });

  test("(b) autograd through dsparkLoss: finite loss, nonzero rnn.wO grad, AdamW moves rnn.wO", () => {
    const cfg = { ...baseCfg, seqHead: "rnn" as const };
    const { stub, dispose: disposeStub } = makeStub(21);
    const d = DflashDrafter.initFromDims(dims, cfg, "t-rnn");
    const inp = makeTrainInputs(22, stub);
    const w = positionWeights(G);
    const nParams = d.names.length;

    expect(d.names).toContain("rnn.wH");
    expect(d.names).toContain("rnn.bH");
    expect(d.names).toContain("rnn.wO");

    const vag = new ValueAndGrad((primals) => d.useParams(primals, () => {
      const o = d.forwardTrain(stub, inp.hCtx, inp.ctxMask, inp.anchorEmb, inp.prevToks);
      const { loss, ce, tv, conf } = dsparkLoss(o, inp.targetLogits, inp.xStar, G, w);
      o.draftLogits.dispose(); o.conf.dispose(); ce.dispose(); tv.dispose(); conf.dispose();
      return loss;
    }), Array.from({ length: nParams }, (_, i) => i));
    const { value, grads } = vag.apply(d.flatParams());

    expect(Number.isFinite(value.toFloat32()[0]!)).toBe(true);
    expect(grads.length).toBe(nParams);

    const idxWH = d.names.indexOf("rnn.wH");
    const idxWO = d.names.indexOf("rnn.wO");
    const idxBH = d.names.indexOf("rnn.bH");
    const whGrad = grads[idxWH]!.toFloat32();
    const woGrad = grads[idxWO]!.toFloat32();
    const bhGrad = grads[idxBH]!.toFloat32();
    expect(whGrad.every(Number.isFinite)).toBe(true);
    expect(woGrad.every(Number.isFinite)).toBe(true);
    expect(bhGrad.every(Number.isFinite)).toBe(true);
    // dL/d(rnn.wO) = s^T · dL/dB ≠ 0 at init — the key autograd-flows check.
    expect(woGrad.some((x) => x !== 0)).toBe(true);

    value.dispose();
    const before = d.get("rnn.wO").toFloat32();
    const opt = new AdamW(d.flatParams(), { lr: 1e-2, weightDecay: 0 }, (i, p) => d.installParam(i, p));
    opt.step(grads); opt.evalState();
    const after = d.get("rnn.wO").toFloat32();
    expect(before.some((v, i) => Math.abs(v - after[i]!) > 1e-9)).toBe(true);

    vag.dispose(); opt.dispose(); d.dispose(); w.dispose(); inp.dispose(); disposeStub();
  });

  test("(c) init-equivalence: rnn and markov drafters (same seed) produce IDENTICAL forwardInfer tokens", () => {
    const rnnCfg = { ...baseCfg, seqHead: "rnn" as const };
    const markovCfg = { ...baseCfg, seqHead: "markov" as const };
    const { stub, dispose: disposeStub } = makeStub(31);

    const dRnn = DflashDrafter.initFromDims(dims, rnnCfg, "t-rnn", 777);
    const dMarkov = DflashDrafter.initFromDims(dims, markovCfg, "t-markov", 777);

    // shared params must be bit-identical (rnn.* appended last ⟹ same rng draws)
    for (const n of dMarkov.names) {
      const a = dRnn.get(n).toFloat32();
      const b = dMarkov.get(n).toFloat32();
      expect(Array.from(a)).toEqual(Array.from(b));
    }
    // both heads are zero-init ⟹ B=0 everywhere at t=0
    const rnnWO = dRnn.get("rnn.wO").toFloat32();
    const markovW2 = dMarkov.get("markov.w2").toFloat32();
    expect(rnnWO.every((x) => x === 0)).toBe(true);
    expect(markovW2.every((x) => x === 0)).toBe(true);

    const Lctx = 7, mH = m * H;
    const r = rng(32);
    const hCtxData = new Float32Array(1 * Lctx * mH).map(() => r());
    const hCtx1Rnn = MlxArray.fromFloat32(hCtxData, [1, Lctx, mH]);
    const hCtx1Markov = MlxArray.fromFloat32(hCtxData.slice(), [1, Lctx, mH]);

    const blkRnn = dRnn.forwardInfer(stub, hCtx1Rnn, 3, G);
    const blkMarkov = dMarkov.forwardInfer(stub, hCtx1Markov, 3, G);

    expect(blkRnn.tokens).toEqual(blkMarkov.tokens);
    expect(blkRnn.conf).toEqual(blkMarkov.conf);
    expect(blkRnn.draftLogits!.toFloat32()).toEqual(blkMarkov.draftLogits!.toFloat32());

    blkRnn.draftLogits!.dispose(); blkMarkov.draftLogits!.dispose();
    hCtx1Rnn.dispose(); hCtx1Markov.dispose();
    dRnn.dispose(); dMarkov.dispose(); disposeStub();
  });

  test("(d) save/load round-trip preserves seqHead=rnn, params, and forwardInfer tokens", () => {
    const cfg = { ...baseCfg, seqHead: "rnn" as const };
    const { stub, dispose: disposeStub } = makeStub(41);
    const d = DflashDrafter.initFromDims(dims, cfg, "t-rnn", 555);

    // nudge rnn.wO off zero so the round-trip is checking real values, not
    // just zeros-matching-zeros.
    const r = rng(42);
    const nudge = new Float32Array(16 * V).map(() => (r() - 0.5) * 0.05);
    d.installParam(d.names.indexOf("rnn.wO"), MlxArray.fromFloat32(nudge, [16, V]).eval());

    const Lctx = 7, mH = m * H;
    const hCtxData = new Float32Array(1 * Lctx * mH).map(() => r());
    const hCtx1a = MlxArray.fromFloat32(hCtxData, [1, Lctx, mH]);
    const before = d.forwardInfer(stub, hCtx1a, 5, G);

    const TMP = mkdtempSync(join(tmpdir(), "dspark-rnn-test-"));
    try {
      d.save(TMP);
      const loaded = DflashDrafter.load(TMP);
      expect(loaded.cfg.seqHead).toBe("rnn");
      expect(loaded.names).toContain("rnn.wH");
      expect(loaded.names).toContain("rnn.wO");
      expect(Array.from(loaded.get("rnn.wO").toFloat32())).toEqual(Array.from(d.get("rnn.wO").toFloat32()));

      const hCtx1b = MlxArray.fromFloat32(hCtxData.slice(), [1, Lctx, mH]);
      const after = loaded.forwardInfer(stub, hCtx1b, 5, G);
      expect(after.tokens).toEqual(before.tokens);
      expect(after.conf).toEqual(before.conf);

      after.draftLogits!.dispose(); hCtx1b.dispose(); loaded.dispose();
    } finally {
      rmSync(TMP, { recursive: true, force: true });
    }

    before.draftLogits!.dispose(); hCtx1a.dispose();
    d.dispose(); disposeStub();
  });

  test("(e) forwardInfer with minConf pruning works under rnn (>=1 token, prefix-identical)", () => {
    const cfg = { ...baseCfg, seqHead: "rnn" as const };
    const { stub, dispose: disposeStub } = makeStub(51);
    const d = DflashDrafter.initFromDims(dims, cfg, "t-rnn", 999);

    const r = rng(52);
    const Lctx = 7, mH = m * H;
    const hCtxData = new Float32Array(1 * Lctx * mH).map(() => r());
    const hCtx1 = MlxArray.fromFloat32(hCtxData, [1, Lctx, mH]);

    const blk = d.forwardInfer(stub, hCtx1, 3, G);
    expect(blk.tokens.length).toBe(G);

    // conf.w/b are zero-init ⟹ every c_k = sigma(0) = 0.5 regardless of seqHead.
    const keep = d.forwardInfer(stub, hCtx1, 3, G, { minConf: 0.4 });
    expect(keep.tokens.length).toBe(G);
    expect(keep.tokens).toEqual(blk.tokens);
    keep.draftLogits!.dispose();

    const pruned = d.forwardInfer(stub, hCtx1, 3, G, { minConf: 0.6 });
    expect(pruned.tokens.length).toBeGreaterThanOrEqual(1);
    expect(pruned.conf.length).toBe(pruned.tokens.length);
    expect(pruned.draftLogits!.shape[1]).toBe(pruned.tokens.length);
    // prefix-identical to the unpruned block (pruning truncates, never re-draws)
    for (let i = 0; i < pruned.tokens.length; i++) expect(pruned.tokens[i]).toBe(blk.tokens[i]);
    pruned.draftLogits!.dispose();

    blk.draftLogits!.dispose();
    hCtx1.dispose();
    d.dispose(); disposeStub();
  });
});
