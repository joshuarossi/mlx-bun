// Drafter production over a synthetic target (a fixed embedding and LM head, no
// weights): the DSpark objective's exact values, shard sampling geometry, a
// training run that lowers the loss and writes a servable checkpoint, and the
// calibration provider's unpruned drafting and outcome reporting. Real-target
// regen/train/calibrate runs are separate verification.

import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const native = process.env.MLX_BUN_TEST_NATIVE === "1";
const { MlxArray } = native ? await import("@mlx-bun/mlx/array") : {} as typeof import("@mlx-bun/mlx/array");
const { Dtype } = native ? await import("@mlx-bun/mlx/ffi") : {} as typeof import("@mlx-bun/mlx/ffi");
const ops = native ? await import("@mlx-bun/mlx/ops") : {} as typeof import("@mlx-bun/mlx/ops");
const dspark = native ? await import("../../src/dspark") : {} as typeof import("../../src/dspark");
const { CalibrationProvider } = native ? await import("../../src/dspark/calibrate") : {} as typeof import("../../src/dspark/calibrate");
const { DflashDrafter, DEFAULT_DFLASH_CONFIG, loadDsparkDrafter } = native
  ? await import("@mlx-bun/inference/generation/speculative/loader") : {} as typeof import("@mlx-bun/inference/generation/speculative/loader");
const { declareGraph } = native ? await import("@mlx-bun/inference/models") : {} as typeof import("@mlx-bun/inference/models");
const { isDrafterModelType } = native ? await import("@mlx-bun/inference/models/support") : {} as typeof import("@mlx-bun/inference/models/support");
const { detectDraftKind } = native ? await import("@mlx-bun/inference/generation/speculative/draft-kind") : {} as typeof import("@mlx-bun/inference/generation/speculative/draft-kind");
type MlxArray = import("@mlx-bun/mlx/array").MlxArray;

const root = mkdtempSync(join(tmpdir(), "mlx-bun-dspark-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const V = 32, H = 16, M = 3, GAMMA = 3, D = 32;
const TAPS = [1, 2, 3];

function random(seed: number) {
  let s = seed >>> 0 || 1;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

/** A target with a fixed embedding table and head; exactly the ports a drafter reads. */
function syntheticTarget() {
  const r = random(7);
  const table = MlxArray.fromFloat32(Float32Array.from({ length: V * H }, () => (r() - 0.5) * 0.4), [V, H]).eval();
  const head = MlxArray.fromFloat32(Float32Array.from({ length: H * V }, () => (r() - 0.5) * 0.4), [H, V]).eval();
  const scales = MlxArray.fromFloat32(new Float32Array([1]), [1]).astype(Dtype.bfloat16).eval();
  const projection = {
    embed: { scales, encode: (ids: MlxArray) => ops.takeAxis(table, ids, 0) },
    logitsFromHidden: (h: MlxArray) => {
      const f = h.dtype === Dtype.float32 ? h : h.astype(Dtype.float32);
      const out = ops.matmul(f, head);
      if (f !== h) f.dispose();
      return out;
    },
  };
  const model = {
    graphCapabilities: declareGraph({ hiddenLayerTaps: true }),
    config: { text: { hiddenSize: H, vocabSize: V, rmsNormEps: 1e-6, numHiddenLayers: 3 }, eosTokenIds: [] },
    draftTarget: () => ({ identity: {}, hiddenLayerTaps: { layerCount: 3, projection } }),
  };
  return { model: model as never, projection, dispose: () => { table.dispose(); head.dispose(); scales.dispose(); } };
}

/** `count` shards of one sequence each; the hidden at (position p, tap t, feature f) encodes its indices. */
function writeShards(dir: string, count: number, length = 24, respStart = 6, taps = TAPS) {
  const r = random(11);
  for (let shard = 0; shard < count; shard++) {
    const ids = Array.from({ length }, () => Math.floor(r() * V));
    const values = Float32Array.from({ length: length * taps.length * H }, () => r() - 0.5);
    const hidden = MlxArray.fromFloat32(values, [length, taps.length * H]).astype(Dtype.bfloat16);
    dspark.writeDflashShard(dir, shard, [{ ids, respStart, hiddenMlBf16: hidden.rawBytes() }], H, taps.length, taps);
    hidden.dispose();
  }
}

describe.skipIf(!native)("DSpark objective", () => {
  const scalar = (a: MlxArray) => { const v = a.toFloat32()[0]!; a.dispose(); return v; };
  /** A one-anchor batch whose draft and target logits are the given rows, conf as given. */
  function lossOf(draft: number[][], target: number[][], conf: number[], xStar: number[], gamma: number) {
    const rows = (x: number[][]) => MlxArray.fromFloat32(Float32Array.from(x.flat()), [1, gamma, x[0]!.length]);
    const out = { draftLogits: rows(draft), conf: MlxArray.fromFloat32(Float32Array.from(conf), [1, gamma]) };
    const tgt = rows(target), xs = MlxArray.fromInt32(Int32Array.from(xStar), [1, gamma]), w = dspark.positionWeights(gamma);
    const { loss, ce, tv, conf: bce } = dspark.dsparkLoss(out as never, tgt, xs, gamma, w);
    const result = { loss: scalar(loss), ce: scalar(ce), tv: scalar(tv), conf: scalar(bce) };
    for (const a of [out.draftLogits, out.conf, tgt, xs, w]) a.dispose();
    return result;
  }

  test("identical distributions: TV is 0, the acceptance label is 1, CE is log V, BCE is -log c", () => {
    const flat = [[0, 0, 0]];
    const got = lossOf(flat, flat, [0.5], [0], 1);
    expect(got.tv).toBeCloseTo(0, 6);
    expect(got.ce).toBeCloseTo(Math.log(3), 5);
    expect(got.conf).toBeCloseTo(Math.log(2), 5);
    expect(got.loss).toBeCloseTo(0.1 * Math.log(3) + 0.9 * 0 + 1.0 * Math.log(2), 5);
  });

  test("positions are weighted exp(-k/gamma); TV is the L1 distance", () => {
    // Position 0: draft uniform vs target one-hot-ish -> l1 = |1/3-1| + 2*|1/3-0| when the target is a delta.
    const draft = [[0, 0, 0], [0, 0, 0]], target = [[60, 0, 0], [0, 0, 0]];
    const got = lossOf(draft, target, [0.5, 0.5], [0, 0], 2);
    const l1 = 2 / 3 + 2 * (1 / 3); // 4/3 for the delta target vs uniform draft
    const w = [1, Math.exp(-0.5)];
    expect(got.tv).toBeCloseTo(w[0]! * l1 + w[1]! * 0, 3);
    expect(got.ce).toBeCloseTo((w[0]! + w[1]!) * Math.log(3), 5);
    // c*_0 = 1 - l1/2 = 1/3; BCE at c = 0.5 for label 1/3, position 1 has label 1.
    const bce0 = -(1 / 3) * Math.log(0.5) - (2 / 3) * Math.log(0.5), bce1 = -Math.log(0.5);
    expect(got.conf).toBeCloseTo(w[0]! * bce0 + w[1]! * bce1, 3);
  });

  test("analytic acceptance: per-position 1 - TV/2 and tau = 1 + sum of cumulative products", () => {
    const draft = MlxArray.fromFloat32(Float32Array.from([0, 0, 0, 0, 0, 0]), [1, 2, 3]);
    const target = MlxArray.fromFloat32(Float32Array.from([0, 0, 0, 60, 0, 0]), [1, 2, 3]);
    const measured = dspark.analyticAcceptance({ draftLogits: draft, conf: draft } as never, target);
    draft.dispose(); target.dispose();
    expect(measured.perPos[0]).toBeCloseTo(1, 5);
    expect(measured.perPos[1]).toBeCloseTo(1 / 3, 4);
    expect(measured.tau).toBeCloseTo(1 + 1 + 1 / 3, 4);
  });
});

describe.skipIf(!native)("drafter shards", () => {
  test("a batch left-pads the prefix, masks the padding, and gathers the block's target hiddens at g..g+gamma-1", () => {
    const dir = join(root, "shards-geometry");
    writeShards(dir, 1, 24, 6);
    const shard = dspark.DflashShard.load(dspark.listDflashShards(dir)[0]!);
    try {
      expect(shard.seqLen).toEqual([24]);
      expect(shard.respStart).toEqual([6]);
      const maxCtx = 12;
      const batch = dspark.sampleDflashBatch(shard, 6, GAMMA, maxCtx, random(3))!;
      expect(batch.size).toBe(6);
      const mask = batch.ctxMask.toFloat32(), hCtx = batch.hCtx.astype(Dtype.float32).toFloat32(), target = batch.targetHidden.astype(Dtype.float32).toFloat32();
      const all = shard.hiddenMl.astype(Dtype.float32).toFloat32();
      const mH = M * H;
      for (let a = 0; a < batch.size; a++) {
        // Recover the anchor position from its token history: the row's last real context column is the anchor.
        const real = Array.from({ length: maxCtx }, (_, j) => mask[a * maxCtx + j]!);
        const nReal = real.reduce((x, y) => x + y, 0);
        expect(real.slice(0, maxCtx - nReal).every(v => v === 0)).toBe(true); // padding first
        expect(real.slice(maxCtx - nReal).every(v => v === 1)).toBe(true);
        const lastCtx = hCtx.subarray((a * maxCtx + maxCtx - 1) * mH, (a * maxCtx + maxCtx) * mH);
        const g = Array.from({ length: 24 }, (_, p) => p).find(p => all.subarray(p * mH, (p + 1) * mH).every((v, i) => v === lastCtx[i]))!;
        expect(g).toBeGreaterThanOrEqual(6);                                  // anchors sit in the response
        expect(nReal).toBe(Math.min(g + 1, maxCtx));
        expect(batch.anchorToks[a]).toBe(shard.ids[g]);
        for (let k = 0; k < GAMMA; k++) {
          expect(batch.blockToks[a]![k]).toBe(shard.ids[g + 1 + k]);          // x*_k is the token AFTER the predicting position
          const finalLayer = all.subarray((g + k) * mH + (M - 1) * H, (g + k) * mH + M * H); // last tap, position g+k
          expect(Array.from(target.subarray((a * GAMMA + k) * H, (a * GAMMA + k + 1) * H))).toEqual(Array.from(finalLayer));
        }
      }
      for (const array of [batch.hCtx, batch.ctxMask, batch.targetHidden]) array.dispose();
    } finally { shard.dispose(); }
  });
});

describe.skipIf(!native)("trainDrafter", () => {
  const drafter = { ...DEFAULT_DFLASH_CONFIG, gamma: GAMMA, dDraft: D, nLayers: 1, nHeads: 4, markovRank: 8, tapLayers: TAPS };
  const config = (dataDir: string, outDir: string, over: Record<string, unknown> = {}) => ({
    ...dspark.DEFAULT_DRAFTER_TRAIN_CONFIG, dataDir, outDir, targetId: "synthetic@16x32", drafter,
    iters: 40, batch: 4, maxCtx: 16, lr: 5e-3, warmup: 2, evalEvery: 20, evalAnchors: 16, ...over,
  });

  test("lowers the loss, saves the best held-out checkpoint, and writes a directory the DSpark loader accepts", async () => {
    const data = join(root, "train-data"), out = join(root, "train-out");
    writeShards(data, 6);
    const target = syntheticTarget();
    const steps: number[] = [], evals: { step: number; tau: number; saved: boolean }[] = [];
    try {
      const result = await dspark.trainDrafter(target.model, config(data, out), event => {
        if (event.type === "step") steps.push(event.loss);
        if (event.type === "eval") evals.push(event);
      });
      expect(steps).toHaveLength(40);
      const mean = (xs: number[]) => xs.reduce((a, b) => a + b, 0) / xs.length;
      expect(mean(steps.slice(-8))).toBeLessThan(mean(steps.slice(0, 8)) - 0.5);
      expect(evals.map(e => e.step)).toEqual([20, 40]);
      expect(evals[0]!.saved).toBe(true);
      expect(result.bestTau).toBe(Math.max(...evals.filter(e => e.saved).map(e => e.tau)));
      const meta = JSON.parse(readFileSync(join(out, "dspark.json"), "utf8"));
      expect(meta.target_id).toBe("synthetic@16x32");
      expect(meta.config.tapLayers).toEqual(TAPS);
      // The directory declares itself a companion drafter and is detected as a DSpark draft, not an assistant.
      expect(isDrafterModelType(JSON.parse(readFileSync(join(out, "config.json"), "utf8")).model_type)).toBe(true);
      expect(await detectDraftKind(out)).toBe("dspark");
      const loaded = loadDsparkDrafter(out);
      expect(loaded.cfg.gamma).toBe(GAMMA);
      loaded.dispose();
    } finally { target.dispose(); }
  });

  test("the same seed reproduces the run; a different seed does not", async () => {
    const data = join(root, "repro-data");
    writeShards(data, 6);
    const run = async (seed: number) => {
      const target = syntheticTarget(), losses: number[] = [];
      try { await dspark.trainDrafter(target.model, config(data, join(root, `repro-${seed}-${losses.length}`), { iters: 4, evalEvery: 4, seed }), e => { if (e.type === "step") losses.push(e.loss); }); }
      finally { target.dispose(); }
      return losses;
    };
    const a = await run(0), b = await run(0), c = await run(1);
    expect(b).toEqual(a);
    expect(c).not.toEqual(a);
  });

  test("resume warm-starts from the checkpoint and its own configuration", async () => {
    const data = join(root, "resume-data"), out = join(root, "resume-out");
    writeShards(data, 6);
    const first = syntheticTarget();
    try {
      await dspark.trainDrafter(first.model, config(data, out, { iters: 20, evalEvery: 20 }));
      const firstLoss = async (over: Record<string, unknown>, into: string) => {
        let loss = NaN, resumed = "";
        await dspark.trainDrafter(first.model, config(data, into, { iters: 2, evalEvery: 2, ...over }), e => {
          if (e.type === "start") resumed = `${e.resumed}:${e.config.dDraft}`;
          if (e.type === "step" && Number.isNaN(loss)) loss = e.loss;
        });
        return { loss, resumed };
      };
      const fresh = await firstLoss({}, join(root, "resume-fresh"));
      // The checkpoint's own dDraft (32) wins over the requested 64, and its weights start the run.
      const warm = await firstLoss({ resume: true, drafter: { ...drafter, dDraft: 64 } }, out);
      expect(fresh.resumed).toBe("false:32");
      expect(warm.resumed).toBe("true:32");
      expect(warm.loss).toBeLessThan(fresh.loss - 0.5);
    } finally { first.dispose(); }
  });

  test("refuses shards recorded with different tap layers than the drafter reads", async () => {
    const data = join(root, "taps-data");
    writeShards(data, 4, 24, 6, [1, 2]);
    const target = syntheticTarget();
    try {
      await expect(dspark.trainDrafter(target.model, config(data, join(root, "taps-out")))).rejects.toThrow("tap layers");
    } finally { target.dispose(); }
  });
});

describe.skipIf(!native)("calibration provider", () => {
  test("drafts the full unpruned block even when the checkpoint carries thresholds, and reports each verified round's outcomes", () => {
    const seen: { thresholds?: number[]; minConf?: number }[] = [];
    const conf = [0.9, 0.4, 0.2];
    const fake = {
      cfg: { ...DEFAULT_DFLASH_CONFIG, gamma: 3, tapLayers: TAPS, sts: { thresholds: [0, 0.8, 0.8], target: 0.5 } },
      forwardInfer(_model: unknown, _h: unknown, _anchor: number, _gamma: number, opts: { thresholds?: number[]; minConf?: number }) {
        seen.push({ thresholds: opts.thresholds, minConf: opts.minConf });
        return { tokens: [5, 6, 7], conf };
      },
      dispose() {},
    };
    const rounds: { pos: number; conf: number; accepted: boolean }[][] = [];
    const provider = new CalibrationProvider(fake as never, round => rounds.push(round), "fake");
    const projection = { embed: { encode: () => { throw new Error("unused"); }, scales: { dtype: Dtype.bfloat16 } }, logitsFromHidden: () => { throw new Error("unused"); } };
    const source = provider.open({ target: { identity: {}, hiddenLayerTaps: { layerCount: 3, projection } } as never });
    const context = MlxArray.fromFloat32(new Float32Array(1 * 4 * M * H), [1, 4, M * H]);
    source.prefill([1, 2, 3], context);
    expect(source.draft([9], 3, 0)).toEqual([5, 6, 7]);
    expect(seen).toEqual([{ thresholds: [], minConf: undefined }]);
    const verified = MlxArray.fromFloat32(new Float32Array(1 * 4 * M * H), [1, 4, M * H]);
    source.commit(3, 1, verified); // one of three accepted
    expect(rounds).toEqual([[{ pos: 0, conf: 0.9, accepted: true }, { pos: 1, conf: 0.4, accepted: false }, { pos: 2, conf: 0.2, accepted: false }]]);
    source.dispose();
  });
});

describe.skipIf(!native)("calibration output", () => {
  test("writeSts sets config.sts and preserves every other field of dspark.json", () => {
    const dir = join(root, "sts-write");
    const d = DflashDrafter.initFromDims({ hiddenSize: H, vocabSize: V, eps: 1e-6 }, { ...DEFAULT_DFLASH_CONFIG, gamma: GAMMA, dDraft: D, nLayers: 1, nHeads: 4, markovRank: 8, tapLayers: TAPS }, "t");
    dspark.saveDrafter(d, dir); d.dispose();
    const before = JSON.parse(readFileSync(join(dir, "dspark.json"), "utf8"));
    expect(dspark.readSts(dir)).toBeUndefined();
    dspark.writeSts(dir, { thresholds: [0, 0.6, 0.7], target: 0.5, samples: 123 });
    const after = JSON.parse(readFileSync(join(dir, "dspark.json"), "utf8"));
    expect(after.config.sts).toEqual({ thresholds: [0, 0.6, 0.7], target: 0.5, samples: 123 });
    expect({ ...after, config: { ...after.config, sts: undefined } }).toEqual({ ...before, config: { ...before.config, sts: undefined } });
    expect(dspark.readSts(dir)?.samples).toBe(123);
    expect(() => dspark.writeSts(join(root, "no-such"), { thresholds: [], target: 0.5 })).toThrow("no dspark.json");
  });
});
