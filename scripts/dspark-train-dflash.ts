// Train the faithful DFlash drafter (multi-layer KV injection). Parallel to
// dspark-train.ts; reuses the loss (dsparkLoss) and optimizer spine.
//
//   bun scripts/dspark-train-dflash.ts --data <dflash-shards> --out <ckpt> --iters 6000 --batch 8

import { Gemma4Model } from "../src/model/gemma4";
import { MlxArray } from "../src/mlx/array";
import * as ops from "../src/mlx/ops";
import { Dtype } from "../src/mlx/ffi";
import { ValueAndGrad } from "../src/mlx/autograd";
import { AdamW, warmupCosineSchedule } from "../src/train/optimizer";
import { DflashDrafter, DEFAULT_DFLASH_CONFIG, type DflashConfig } from "../src/spec/dspark/module-dflash";
import { dsparkLoss, analyticAcceptance, positionWeights } from "../src/spec/dspark/loss";
import { DflashShard, listDflashShards, sampleDflashBatch, type DflashBatch } from "../src/spec/dspark/data-dflash";
import { existsSync } from "node:fs";
import { join } from "node:path";

const { Registry } = await import("../src/registry");
const { loadModelConfig } = await import("../src/config");
const { Weights } = await import("../src/weights");
const { createModel } = await import("../src/model/factory");

const arg = (n: string, d?: string) => { const i = process.argv.indexOf(`--${n}`); if (i >= 0 && i + 1 < process.argv.length) return process.argv[i + 1]!; if (d !== undefined) return d; throw new Error(`missing --${n}`); };
const num = (n: string, d: string) => parseInt(arg(n, d), 10);
const fnum = (n: string, d: string) => parseFloat(arg(n, d));

const MODEL = arg("model", "gemma-4-e4b-it-OptiQ-4bit");
const DATA = arg("data");
const OUT = arg("out");
const ITERS = num("iters", "6000");
const BATCH = num("batch", "8");
const GAMMA = num("gamma", String(DEFAULT_DFLASH_CONFIG.gamma));
const MAX_CTX = num("max-ctx", "512");
const LR = fnum("lr", "1.5e-3");
const WARMUP = num("warmup", "150");
const EVAL_EVERY = num("eval-every", "500");
const SEED = num("seed", "0");
const DDRAFT = num("ddraft", String(DEFAULT_DFLASH_CONFIG.dDraft));
const NHEADS = num("nheads", String(DEFAULT_DFLASH_CONFIG.nHeads));
const cfg: DflashConfig = { ...DEFAULT_DFLASH_CONFIG, gamma: GAMMA, dDraft: DDRAFT, nHeads: NHEADS };

function makeRng(seed: number) { let s = seed >>> 0 || 0x9e3779b9; return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; }; }
const rng = makeRng(SEED);

const dir = new Registry().resolve(MODEL).path;
const config = await loadModelConfig(dir);
const model = createModel(await Weights.open(dir), config) as Gemma4Model;
const targetId = `${MODEL}@${config.text.hiddenSize}x${config.text.vocabSize}`;

const allShards = listDflashShards(DATA);
if (allShards.length === 0) throw new Error(`no shards under ${DATA}`);
const nVal = Math.max(1, Math.floor(allShards.length * 0.1));
const trainShards = allShards.length > 2 ? allShards.slice(0, allShards.length - 2 * nVal) : allShards;
const valShards = allShards.length > 2 ? allShards.slice(allShards.length - 2 * nVal, allShards.length - nVal) : allShards;
console.log(`[train-dflash] ${allShards.length} shards (${trainShards.length} train/${valShards.length} val), γ=${GAMMA}, batch=${BATCH}, maxCtx=${MAX_CTX}, iters=${ITERS}`);

// --resume: warm-start params from an existing checkpoint (survives kills). The
// optimizer/LR-schedule restart from step 1 and re-warm quickly; the expensive
// learned params are preserved. Config comes from the checkpoint on resume.
const RESUME = process.argv.includes("--resume");
const resuming = RESUME && existsSync(join(OUT, "dspark.json"));
const drafter = resuming ? DflashDrafter.load(OUT) : DflashDrafter.init(model, cfg, targetId, SEED);
if (resuming) console.log(`[train-dflash] RESUMED from ${OUT} (params warm-started; optimizer re-warms)`);
const nParams = drafter.names.length;
console.log(`[train-dflash] ${nParams} params; dDraft=${cfg.dDraft} layers=${cfg.nLayers} m=${drafter.m} tapLayers=${cfg.tapLayers}`);

const w = positionWeights(GAMMA);

let cHCtx: MlxArray, cMask: MlxArray, cAnchor: MlxArray, cPrev: MlxArray, cXStar: MlxArray, cTgt: MlxArray;
function bind(batch: DflashBatch): void {
  const A = batch.size;
  cHCtx = batch.hCtx; cMask = batch.ctxMask;
  const aIds = ops.fromInt32(batch.anchorToks, [A]); cAnchor = model.embed.encode(aIds); aIds.dispose();
  const prev: number[] = [], xs: number[] = [];
  for (let a = 0; a < A; a++) { prev.push(batch.anchorToks[a]!); for (let k = 0; k < GAMMA - 1; k++) prev.push(batch.blockToks[a]![k]!); for (let k = 0; k < GAMMA; k++) xs.push(batch.blockToks[a]![k]!); }
  cPrev = ops.fromInt32(prev, [A, GAMMA]); cXStar = ops.fromInt32(xs, [A, GAMMA]);
  const tl = model.logitsFromHidden(batch.targetHidden); cTgt = tl.dtype === Dtype.float32 ? tl : tl.astype(Dtype.float32); if (cTgt !== tl) tl.dispose();
  batch.targetHidden.dispose();
}
function unbind(): void { cHCtx.dispose(); cMask.dispose(); cAnchor.dispose(); cPrev.dispose(); cXStar.dispose(); cTgt.dispose(); }

const vag = new ValueAndGrad((primals) => drafter.useParams(primals, () => {
  const out = drafter.forwardTrain(model, cHCtx, cMask, cAnchor, cPrev);
  const { loss, ce, tv, conf } = dsparkLoss(out, cTgt, cXStar, GAMMA, w);
  out.draftLogits.dispose(); out.conf.dispose(); ce.dispose(); tv.dispose(); conf.dispose();
  return loss;
}), Array.from({ length: nParams }, (_, i) => i));

const opt = new AdamW(drafter.flatParams(), { lr: LR, weightDecay: 0.0 }, (i, p) => drafter.installParam(i, p));
const schedule = warmupCosineSchedule(LR, WARMUP, ITERS);

const EVAL_ANCHORS = num("eval-anchors", "256");
function evalTau(): { tau: number; perPos: number[] } {
  const shard = DflashShard.load(valShards[Math.floor(rng() * valShards.length)]!);
  try {
    let tauSum = 0, n = 0; const perPos = new Array(GAMMA).fill(0);
    for (let g = 0; g < Math.ceil(EVAL_ANCHORS / 16); g++) {
      const b = sampleDflashBatch(shard, 16, GAMMA, MAX_CTX, rng); if (!b) break;
      bind(b);
      const out = drafter.forwardTrain(model, cHCtx, cMask, cAnchor, cPrev);
      const mo = analyticAcceptance(out, cTgt); out.draftLogits.dispose(); out.conf.dispose(); unbind();
      tauSum += mo.tau * b.size; n += b.size; mo.perPos.forEach((v, i) => perPos[i] += v * b.size);
    }
    return n ? { tau: tauSum / n, perPos: perPos.map((v) => v / n) } : { tau: 0, perPos: [] };
  } finally { shard.dispose(); }
}

let bestTau = 0, shardCursor = 0, shard: DflashShard | null = null, shardUses = 0;
const USES = 200;
const t0 = performance.now();
for (let step = 1; step <= ITERS; step++) {
  if (!shard || shardUses >= USES) { shard?.dispose(); shard = DflashShard.load(trainShards[shardCursor % trainShards.length]!); shardCursor++; shardUses = 0; }
  const b = sampleDflashBatch(shard, BATCH, GAMMA, MAX_CTX, rng); shardUses++;
  if (!b) continue;
  bind(b); opt.lr = schedule(step);
  const { value, grads } = vag.apply(drafter.flatParams());
  const loss = value.toFloat32()[0]!; value.dispose();
  opt.step(grads); opt.evalState(); unbind();
  if (step % 50 === 0 || step === 1) console.log(`step ${step}/${ITERS}  lr=${opt.lr.toExponential(2)}  loss=${loss.toFixed(4)}`);
  if (step % EVAL_EVERY === 0 || step === ITERS) {
    const { tau, perPos } = evalTau();
    console.log(`  ── held-out τ=${tau.toFixed(3)}  per-pos=[${perPos.map((x) => x.toFixed(2)).join(",")}]`);
    if (tau > bestTau) { bestTau = tau; drafter.save(OUT); console.log(`  ✓ best τ=${tau.toFixed(3)} → ${OUT}`); }
  }
}
shard?.dispose();
console.log(`[train-dflash] done in ${((performance.now() - t0) / 60000).toFixed(1)} min; best τ=${bestTau.toFixed(3)}; ckpt ${OUT}`);
