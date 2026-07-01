// DSpark smoke test — exercises the loss math, data round-trip, and param
// save/load at tiny scale WITHOUT loading the GPU model. (The module forward
// and the losslessness gate need the real model — see scripts/dspark-ab.ts.)
//
//   bun scripts/dspark-smoke.ts [--tmp <dir>]

import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { ValueAndGrad } from "../src/mlx/autograd";
import { AdamW } from "../src/train/optimizer";
import { DSparkDrafter, DEFAULT_DSPARK_CONFIG, type DSparkTrainOut, type TargetDims } from "../src/spec/dspark/module";
import { dsparkLoss, analyticAcceptance, positionWeights } from "../src/spec/dspark/loss";
import { writeDSparkShard, DSparkShard, sampleBatch, type DSparkRecord } from "../src/spec/dspark/data";
import { processLogits, probsOf, sampleToken, sampleResidual, KeyStream } from "../src/spec/dspark/sample";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const TMP = process.argv.includes("--tmp")
  ? process.argv[process.argv.indexOf("--tmp") + 1]!
  : mkdtempSync(join(tmpdir(), "dspark-smoke-"));

let pass = 0, fail = 0;
function check(name: string, cond: boolean, detail = ""): void {
  if (cond) { pass++; console.log(`  ✓ ${name}`); }
  else { fail++; console.log(`  ✗ ${name} ${detail}`); }
}

function randLogits(rng: () => number, A: number, G: number, V: number): MlxArray {
  const data = new Float32Array(A * G * V);
  for (let i = 0; i < data.length; i++) data[i] = (rng() - 0.5) * 4;
  return MlxArray.fromFloat32(data, [A, G, V]);
}
function makeRng(seed: number): () => number {
  let s = seed >>> 0 || 1;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

const rng = makeRng(7);
const A = 3, G = 5, V = 64, H = 32;

// ---- 1. position weights ----
console.log("position weights");
{
  const w = positionWeights(G);
  const f = w.toFloat32();
  check("shape [1,γ]", w.shape[0] === 1 && w.shape[1] === G);
  check("w_1 = 1", Math.abs(f[0]! - 1) < 1e-6);
  check("monotone decreasing", f[0]! > f[1]! && f[1]! > f[4]!);
  w.dispose();
}

// ---- 2. loss: finite, and TV→0 when draft == target ----
console.log("loss");
{
  const w = positionWeights(G);
  const tl = randLogits(rng, A, G, V);
  const dlRand = randLogits(rng, A, G, V);
  const conf = ops.softmaxAxis(randLogits(rng, A, G, 2), 2, true); // dummy [A,G,2]
  const confScalar = conf.slice([0, 0, 0], [A, G, 1]);
  conf.dispose();
  const confAG = ops.reshape(confScalar, [A, G]);
  confScalar.dispose();
  const xsArr = new Int32Array(A * G);
  for (let i = 0; i < xsArr.length; i++) xsArr[i] = Math.floor(rng() * V);
  const xStar = MlxArray.fromInt32(xsArr, [A, G]);

  const outRand: DSparkTrainOut = { draftLogits: dlRand, conf: confAG };
  const r1 = dsparkLoss(outRand, tl, xStar, G, w);
  const lv = r1.loss.toFloat32()[0]!;
  const tv1 = r1.tv.toFloat32()[0]!;
  check("loss finite", Number.isFinite(lv), `loss=${lv}`);
  check("tv > 0 for random draft", tv1 > 0.1, `tv=${tv1}`);
  for (const a of [r1.loss, r1.ce, r1.tv, r1.conf]) a.dispose();

  // draft == target → TV ≈ 0
  const dlMatch = ops.add(tl, MlxArray.fromFloat32(new Float32Array(A * G * V), [A, G, V]));
  const outMatch: DSparkTrainOut = { draftLogits: dlMatch, conf: confAG };
  const r2 = dsparkLoss(outMatch, tl, xStar, G, w);
  const tv2 = r2.tv.toFloat32()[0]!;
  check("tv ≈ 0 when draft == target", tv2 < 1e-3, `tv=${tv2}`);
  for (const a of [r2.loss, r2.ce, r2.tv, r2.conf]) a.dispose();

  // analytic acceptance: draft==target → per-pos accept ≈ 1, τ ≈ γ+1
  const dlMatch2 = ops.add(tl, MlxArray.fromFloat32(new Float32Array(A * G * V), [A, G, V]));
  const m = analyticAcceptance({ draftLogits: dlMatch2, conf: confAG }, tl);
  dlMatch2.dispose();
  check("analytic per-pos accept ≈ 1", m.perPos.every((x) => x > 0.99), `perPos=${m.perPos.map((x) => x.toFixed(3))}`);
  check("analytic τ ≈ γ+1", Math.abs(m.tau - (G + 1)) < 0.05, `τ=${m.tau}`);

  dlMatch.dispose(); dlRand.dispose(); confAG.dispose(); xStar.dispose(); tl.dispose(); w.dispose();
}

// ---- 3. data shard round-trip ----
console.log("data round-trip");
{
  const records: DSparkRecord[] = [];
  for (let s = 0; s < 4; s++) {
    const L = 20 + s;
    const ids: number[] = [];
    for (let i = 0; i < L; i++) ids.push((s * 7 + i) % V);
    const hb = MlxArray.fromFloat32(new Float32Array(L * H).map(() => rng()), [L, H]).astype(Dtype.bfloat16);
    const cont = ops.contiguous(hb); hb.dispose();
    records.push({ ids, hiddenBf16: cont.rawBytes() });
    cont.dispose();
  }
  const meta = writeDSparkShard(TMP, 0, records, H);
  check("shard meta nSeq", meta.nSeq === 4);
  const shard = DSparkShard.load(join(TMP, "shard_00000"));
  check("shard hidden shape", shard.hidden.shape[0] === meta.nTokens && shard.hidden.shape[1] === H);
  const batch = sampleBatch(shard, A, G, makeRng(3));
  check("sampleBatch non-null", batch !== null);
  if (batch) {
    check("hCtx shape [A,H]", batch.hCtx.shape[0] === batch.size && batch.hCtx.shape[1] === H);
    check("targetHidden shape [A,γ,H]", batch.targetHidden.shape[1] === G && batch.targetHidden.shape[2] === H);
    check("blockToks length γ", batch.blockToks.every((b) => b.length === G));
    batch.hCtx.dispose(); batch.targetHidden.dispose();
  }
  shard.dispose();
}

// ---- 4. module param init + save/load ----
console.log("module params");
{
  const dims: TargetDims = { hiddenSize: H, vocabSize: V, eps: 1e-6 };
  const d = DSparkDrafter.initFromDims(dims, { ...DEFAULT_DSPARK_CONFIG, gamma: G, dDraft: 32, nLayers: 2, nHeads: 4, markovRank: 16 }, "smoke-target");
  const flat = d.flatParams();
  check("flatParams count == names", flat.length === d.names.length);
  // W2 init is zeros (pure-DFlash start)
  const w2 = d.get("markov.w2").toFloat32();
  check("markov.w2 init zero", w2.every((x) => x === 0));
  const saveDir = join(TMP, "ckpt");
  d.save(saveDir);
  const d2 = DSparkDrafter.load(saveDir);
  check("reloaded names match", JSON.stringify(d2.names) === JSON.stringify(d.names));
  const a = d.get("ctx_proj").toFloat32();
  const b = d2.get("ctx_proj").toFloat32();
  check("ctx_proj round-trips", a.length === b.length && a.every((v, i) => Math.abs(v - b[i]!) < 1e-6));
  d.dispose(); d2.dispose();
}

// ---- 5. forward + grad through a stub model (validates autograd wiring) ----
console.log("forward + grad (stub model)");
{
  // duck-typed stand-in exposing only what the module forward touches:
  // embed.scales.dtype, embed.encode, logitsFromHidden.
  const fakeEmbed = MlxArray.fromFloat32(new Float32Array(V * H).map(() => (rng() - 0.5) * 0.1), [V, H]).eval();
  const fakeHead = MlxArray.fromFloat32(new Float32Array(H * V).map(() => (rng() - 0.5) * 0.1), [H, V]).eval();
  const fakeScales = MlxArray.fromFloat32(new Float32Array([1]), [1]).astype(Dtype.bfloat16).eval();
  const stub = {
    embed: {
      scales: fakeScales,
      encode(ids: MlxArray): MlxArray { return ops.takeAxis(fakeEmbed, ids, 0); },
    },
    logitsFromHidden(h: MlxArray): MlxArray {
      const hf = h.dtype === Dtype.float32 ? h : h.astype(Dtype.float32);
      const o = ops.matmul(hf, fakeHead);
      if (hf !== h) hf.dispose();
      return o;
    },
  } as unknown as import("../src/model/gemma4").Gemma4Model;

  const dims: TargetDims = { hiddenSize: H, vocabSize: V, eps: 1e-6 };
  const d = DSparkDrafter.initFromDims(dims, { ...DEFAULT_DSPARK_CONFIG, gamma: G, dDraft: 32, nLayers: 2, nHeads: 4, markovRank: 16 }, "smoke");
  const nParams = d.names.length;
  const w = positionWeights(G);

  // constants
  const hCtx = MlxArray.fromFloat32(new Float32Array(A * H).map(() => rng()), [A, H]);
  const anchorToks = Array.from({ length: A }, () => Math.floor(rng() * V));
  const anchorIds = MlxArray.fromInt32(new Int32Array(anchorToks), [A]);
  const anchorEmb = stub.embed.encode(anchorIds); anchorIds.dispose();
  const prev = new Int32Array(A * G).map(() => Math.floor(rng() * V));
  const xs = new Int32Array(A * G).map(() => Math.floor(rng() * V));
  const prevToks = MlxArray.fromInt32(prev, [A, G]);
  const xStar = MlxArray.fromInt32(xs, [A, G]);
  const tgtHidden = MlxArray.fromFloat32(new Float32Array(A * G * H).map(() => rng()), [A, G, H]);
  const targetLogits = stub.logitsFromHidden(tgtHidden); tgtHidden.dispose();

  // plain forward
  const out = d.forwardTrain(stub, hCtx, anchorEmb, prevToks);
  check("forwardTrain draftLogits [A,γ,V]", out.draftLogits.shape[0] === A && out.draftLogits.shape[1] === G && out.draftLogits.shape[2] === V);
  check("forwardTrain conf [A,γ]", out.conf.shape[0] === A && out.conf.shape[1] === G);
  const confF = out.conf.toFloat32();
  check("conf in (0,1)", confF.every((x) => x > 0 && x < 1));
  out.draftLogits.dispose(); out.conf.dispose();

  // value + grad
  const vag = new ValueAndGrad((primals) => {
    return d.useParams(primals, () => {
      const o = d.forwardTrain(stub, hCtx, anchorEmb, prevToks);
      const { loss, ce, tv, conf } = dsparkLoss(o, targetLogits, xStar, G, w);
      o.draftLogits.dispose(); o.conf.dispose(); ce.dispose(); tv.dispose(); conf.dispose();
      return loss;
    });
  }, Array.from({ length: nParams }, (_, i) => i));

  const { value, grads } = vag.apply(d.flatParams());
  const lv = value.toFloat32()[0]!;
  check("grad-loss finite", Number.isFinite(lv), `loss=${lv}`);
  check("one grad per param", grads.length === nParams);
  check("grad shapes match params", grads.every((g, i) => JSON.stringify(g.shape) === JSON.stringify(d.get(d.names[i]!).shape)));
  const g0 = grads.find((_, i) => d.names[i] === "ctx_proj")!.toFloat32();
  check("ctx_proj grad finite & nonzero", g0.every(Number.isFinite) && g0.some((x) => x !== 0));
  value.dispose();

  // optimizer step actually moves a param
  const before = d.get("ctx_proj").toFloat32();
  const opt = new AdamW(d.flatParams(), { lr: 1e-2, weightDecay: 0 }, (i, p) => d.installParam(i, p));
  opt.step(grads); opt.evalState();
  const after = d.get("ctx_proj").toFloat32();
  check("AdamW step moves ctx_proj", before.some((v, i) => Math.abs(v - after[i]!) > 1e-9));

  // inference forward yields γ tokens + confidences
  const blk = d.forwardInfer(stub, hCtx.slice([0, 0], [1, H]), anchorToks[0]!, G);
  check("forwardInfer yields γ tokens", blk.tokens.length === G && blk.conf.length === G);
  check("infer tokens in vocab", blk.tokens.every((t) => t >= 0 && t < V));

  vag.dispose(); opt.dispose(); d.dispose(); w.dispose();
  hCtx.dispose(); anchorEmb.dispose(); prevToks.dispose(); xStar.dispose(); targetLogits.dispose();
  fakeEmbed.dispose(); fakeHead.dispose(); fakeScales.dispose();
}

// ---- 6. speculative-SAMPLING losslessness (the temp>0 gate) ----
// The accept/residual rule must make the emitted token distributed exactly as
// the target p, for ANY draft q. We Monte-Carlo the EXACT decision in
// verifySampling (host-side: u < min(1, p/q) accept, else resample residual)
// on small explicit dists, and separately check the MLX helpers are well-formed.
console.log("speculative sampling losslessness");
{
  const Vs = 6;
  const mk = (seed: number): number[] => {
    const r = makeRng(seed);
    const x = Array.from({ length: Vs }, () => r() + 1e-3);
    const s = x.reduce((a, b) => a + b, 0);
    return x.map((v) => v / s);
  };
  const P = mk(11), Q = mk(99); // arbitrary, different dists
  const sampleFrom = (dist: number[], u: number): number => {
    let c = 0;
    for (let i = 0; i < dist.length; i++) { c += dist[i]!; if (u < c) return i; }
    return dist.length - 1;
  };
  const resid = (() => {
    const r = P.map((p, i) => Math.max(0, p - Q[i]!));
    const s = r.reduce((a, b) => a + b, 0);
    return s > 1e-12 ? r.map((v) => v / s) : P;
  })();
  const N = 200_000;
  const r = makeRng(2024);
  const counts = new Array(Vs).fill(0);
  for (let t = 0; t < N; t++) {
    const x = sampleFrom(Q, r());          // draft sample
    const u = r();                          // accept test
    if (u < Math.min(1, P[x]! / Q[x]!)) counts[x]++;
    else counts[sampleFrom(resid, r())]++;  // residual resample
  }
  const freq = counts.map((c) => c / N);
  const maxErr = Math.max(...freq.map((f, i) => Math.abs(f - P[i]!)));
  check("emit distribution == target p (any q)", maxErr < 0.01, `maxErr=${maxErr.toFixed(4)}`);

  // device helpers well-formed
  const tl = MlxArray.fromFloat32(new Float32Array(Vs).map(() => (rng() - 0.5) * 3), [1, Vs]);
  const dl = MlxArray.fromFloat32(new Float32Array(Vs).map(() => (rng() - 0.5) * 3), [1, Vs]);
  const cfg = { temperature: 0.8, seed: 1 };
  const tScaled = processLogits(tl, cfg);
  const pVec = probsOf(tScaled);
  const psum = pVec.toFloat32().reduce((a, b) => a + b, 0);
  check("processLogits→probs sums to 1", Math.abs(psum - 1) < 1e-4, `sum=${psum}`);
  const dScaled = processLogits(dl, cfg);
  const qVec = probsOf(dScaled);
  const keys = new KeyStream(5);
  const corr = sampleResidual(pVec, qVec, keys.next());
  check("sampleResidual in-vocab", corr >= 0 && corr < Vs, `tok=${corr}`);
  const bonus = sampleToken(tScaled, keys.next());
  check("sampleToken in-vocab", bonus >= 0 && bonus < Vs, `tok=${bonus}`);
  // temp>0 sampling varies with seed (not deterministic argmax)
  const draws = new Set<number>();
  for (let i = 0; i < 40; i++) draws.add(sampleToken(tScaled, new KeyStream(i).next()));
  check("sampling explores >1 token", draws.size > 1, `unique=${draws.size}`);
  tScaled.dispose(); pVec.dispose(); dScaled.dispose(); qVec.dispose(); tl.dispose(); dl.dispose();
}

rmSync(TMP, { recursive: true, force: true });
console.log(`\n[dspark-smoke] ${pass} passed, ${fail} failed`);
process.exit(fail === 0 ? 0 : 1);
