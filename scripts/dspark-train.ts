// DSpark training — fit the draft module against frozen e4b's own outputs.
// Reuses the autograd/optimizer spine (ValueAndGrad + AdamW + warmup-cosine);
// the draft params are the ONLY trainable leaves, e4b stays frozen. Watch τ on
// held-out (analyticAcceptance), NOT loss — τ is the number that matters; the
// W2=0 init means the module starts as pure DFlash and τ should climb as the
// Markov head learns intra-block dependency.
//
// GPU JOB — Josh runs this, not an agent session. Prereq: shards from
// scripts/dspark-regen.ts.
//
//   bun scripts/dspark-train.ts --data ~/.cache/mlx-bun/dspark-data \
//       --out ~/.cache/mlx-bun/dspark/e4b-v1 --iters 2000 --batch 4 --gamma 5

import { Gemma4Model } from "../src/model/gemma4";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { Dtype } from "../src/mlx/ffi";
import { ValueAndGrad } from "../src/mlx/autograd";
import { AdamW, warmupCosineSchedule } from "../src/train/optimizer";
import { DSparkDrafter, DEFAULT_DSPARK_CONFIG, type DSparkConfig } from "../src/spec/dspark/module";
import { dsparkLoss, analyticAcceptance, positionWeights } from "../src/spec/dspark/loss";
import { DSparkShard, listShards, sampleBatch, type DSparkBatch } from "../src/spec/dspark/data";

const { Registry } = await import("../src/registry");
const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");

function arg(name: string, def?: string): string {
  const i = process.argv.indexOf(`--${name}`);
  if (i >= 0 && i + 1 < process.argv.length) return process.argv[i + 1]!;
  if (def !== undefined) return def;
  throw new Error(`missing --${name}`);
}
const num = (n: string, d: string) => parseInt(arg(n, d), 10);
const fnum = (n: string, d: string) => parseFloat(arg(n, d));

const MODEL = arg("model", "gemma-4-e4b-it-OptiQ-4bit");
const DATA = arg("data");
const OUT = arg("out");
const ITERS = num("iters", "2000");
const BATCH = num("batch", "4");
const GAMMA = num("gamma", String(DEFAULT_DSPARK_CONFIG.gamma));
const LR = fnum("lr", "1e-4");
const WARMUP = num("warmup", "100");
const EVAL_EVERY = num("eval-every", "100");
const SEED = num("seed", "0");

const cfg: DSparkConfig = { ...DEFAULT_DSPARK_CONFIG, gamma: GAMMA };

// deterministic rng (Date/Math.random avoided to keep runs reproducible)
function makeRng(seed: number): () => number {
  let s = seed >>> 0 || 0x9e3779b9;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}
const rng = makeRng(SEED);

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const weights = await Weights.open(dir);
const model = createModel(weights, config) as Gemma4Model;
const targetId = `${MODEL}@${config.text.hiddenSize}x${config.text.vocabSize}`;

const allShards = listShards(DATA);
if (allShards.length === 0) throw new Error(`no shards under ${DATA} (run dspark-regen first)`);
// 80/10/10 split by shard; with 1 shard, train==val (smoke).
const nVal = Math.max(1, Math.floor(allShards.length * 0.1));
const trainShards = allShards.length > 2 ? allShards.slice(0, allShards.length - 2 * nVal) : allShards;
const valShards = allShards.length > 2 ? allShards.slice(allShards.length - 2 * nVal, allShards.length - nVal) : allShards;
console.log(`[dspark-train] ${allShards.length} shards (${trainShards.length} train / ${valShards.length} val), γ=${GAMMA}, batch=${BATCH}, iters=${ITERS}`);

const drafter = DSparkDrafter.init(model, cfg, targetId, SEED);
const nParams = drafter.names.length;
console.log(`[dspark-train] ${nParams} param tensors; dDraft=${cfg.dDraft} layers=${cfg.nLayers} r=${cfg.markovRank}`);

const w = positionWeights(GAMMA); // [1,γ] position weights, constant
const HDT = model.embed.scales.dtype; // head/activation dtype

// --- per-step constants, captured by the loss closure ---
let cHCtx: MlxArray;       // [A,H] bf16
let cAnchorEmb: MlxArray;  // [A,H] (raw embed)
let cPrevToks: MlxArray;   // [A,γ] int32
let cXStar: MlxArray;      // [A,γ] int32
let cTargetLogits: MlxArray; // [A,γ,V] f32 (frozen target)

/** Build the per-step tensors from a sampled batch. Caller disposes via
 *  disposeStep(). */
function bindStep(batch: DSparkBatch): void {
  const A = batch.size;
  cHCtx = batch.hCtx; // own
  // anchor embedding (raw, no scale — tok_proj learns the scale)
  const anchorIds = ops.fromInt32(batch.anchorToks, [A]);
  cAnchorEmb = model.embed.encode(anchorIds); // [A,H]
  anchorIds.dispose();
  // prevToks = [x0, x*_1..x*_{γ-1}]; xStar = [x*_1..x*_γ]
  const prev: number[] = [];
  const xs: number[] = [];
  for (let a = 0; a < A; a++) {
    prev.push(batch.anchorToks[a]!);
    for (let k = 0; k < GAMMA - 1; k++) prev.push(batch.blockToks[a]![k]!);
    for (let k = 0; k < GAMMA; k++) xs.push(batch.blockToks[a]![k]!);
  }
  cPrevToks = ops.fromInt32(prev, [A, GAMMA]);
  cXStar = ops.fromInt32(xs, [A, GAMMA]);
  // frozen target distribution: logits over the γ block positions
  const tl = model.logitsFromHidden(batch.targetHidden); // [A,γ,V]
  cTargetLogits = tl.dtype === Dtype.float32 ? tl : tl.astype(Dtype.float32);
  if (cTargetLogits !== tl) tl.dispose();
  batch.targetHidden.dispose();
}
function disposeStep(): void {
  cHCtx.dispose(); cAnchorEmb.dispose(); cPrevToks.dispose(); cXStar.dispose(); cTargetLogits.dispose();
}

// --- ValueAndGrad over the draft params ---
const vag = new ValueAndGrad((primals) => {
  return drafter.useParams(primals, () => {
    const out = drafter.forwardTrain(model, cHCtx, cAnchorEmb, cPrevToks);
    const { loss, ce, tv, conf } = dsparkLoss(out, cTargetLogits, cXStar, GAMMA, w);
    out.draftLogits.dispose(); out.conf.dispose();
    ce.dispose(); tv.dispose(); conf.dispose();
    return loss;
  });
}, Array.from({ length: nParams }, (_, i) => i));

const opt = new AdamW(
  drafter.flatParams(),
  { lr: LR, betas: [0.9, 0.999], eps: 1e-8, weightDecay: 0.0 },
  (i, p) => drafter.installParam(i, p),
);
const schedule = warmupCosineSchedule(LR, WARMUP, ITERS);

// --- held-out τ probe (no grad) ---
// Average analytic acceptance over many anchors so the held-out τ is stable
// enough to read a TREND (a single 4-anchor batch jitters wildly).
const EVAL_ANCHORS = parseInt(arg("eval-anchors", "256"), 10);
function evalTau(): { tau: number; perPos: number[] } {
  const shardDir = valShards[Math.floor(rng() * valShards.length)]!;
  const shard = DSparkShard.load(shardDir);
  try {
    let tauSum = 0, n = 0;
    const perPos = new Array(GAMMA).fill(0);
    const evalBatch = 16;
    for (let g = 0; g < Math.ceil(EVAL_ANCHORS / evalBatch); g++) {
      const batch = sampleBatch(shard, evalBatch, GAMMA, rng);
      if (!batch) break;
      bindStep(batch);
      const out = drafter.forwardTrain(model, cHCtx, cAnchorEmb, cPrevToks);
      const m = analyticAcceptance(out, cTargetLogits);
      out.draftLogits.dispose(); out.conf.dispose();
      disposeStep();
      tauSum += m.tau * batch.size; n += batch.size;
      m.perPos.forEach((v, i) => { perPos[i] += v * batch.size; });
    }
    if (n === 0) return { tau: 0, perPos: [] };
    return { tau: tauSum / n, perPos: perPos.map((v) => v / n) };
  } finally {
    shard.dispose();
  }
}

// --- train loop ---
let bestTau = 0;
let shardCursor = 0;
let shard: DSparkShard | null = null;
let shardUses = 0;
const USES_PER_SHARD = 200;

const t0 = performance.now();
for (let step = 1; step <= ITERS; step++) {
  if (!shard || shardUses >= USES_PER_SHARD) {
    shard?.dispose();
    shard = DSparkShard.load(trainShards[shardCursor % trainShards.length]!);
    shardCursor++;
    shardUses = 0;
  }
  const batch = sampleBatch(shard, BATCH, GAMMA, rng);
  shardUses++;
  if (!batch) continue;

  bindStep(batch);
  opt.lr = schedule(step);
  const { value, grads } = vag.apply(drafter.flatParams());
  const loss = value.toFloat32()[0]!;
  value.dispose();
  opt.step(grads); // disposes grads, installs new params via callback
  opt.evalState();
  disposeStep();

  if (step % 20 === 0 || step === 1) {
    console.log(`step ${step}/${ITERS}  lr=${opt.lr.toExponential(2)}  loss=${loss.toFixed(4)}`);
  }
  if (step % EVAL_EVERY === 0 || step === ITERS) {
    const { tau, perPos } = evalTau();
    const pp = perPos.map((x) => x.toFixed(2)).join(",");
    console.log(`  ── held-out τ=${tau.toFixed(3)}  per-pos accept=[${pp}]`);
    if (tau > bestTau) {
      bestTau = tau;
      drafter.save(OUT);
      console.log(`  ✓ new best τ=${tau.toFixed(3)} → saved ${OUT}`);
    }
  }
}
shard?.dispose();
const mins = ((performance.now() - t0) / 60000).toFixed(1);
console.log(`[dspark-train] done in ${mins} min; best held-out τ=${bestTau.toFixed(3)}; checkpoint ${OUT}`);
