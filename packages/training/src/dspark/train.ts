// Drafter training loop (DSpark paper §3.3): the KV-injection drafter learns
// from a frozen target's regenerated shards (regen.ts), driven by the DSpark
// objective (loss.ts). The target contributes only its embedding and LM head
// (target.ts): p^t is recomputed from the stored final hiddens, so shards hold
// O(d) per token, not O(V).
//
// Hidden-layer taps are needed at regen only; training reads shards, so the
// target may be any graph declaring the draft projection.

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { ValueAndGrad } from "@mlx-bun/mlx/autograd";
import type { RuntimeModel } from "@mlx-bun/inference/models";
import { DflashDrafter, DEFAULT_DFLASH_CONFIG, type DflashConfig } from "@mlx-bun/inference/generation/speculative/loader";
import { AdamW, warmupCosineSchedule } from "../optimizer";
import { dsparkLoss, analyticAcceptance, positionWeights } from "./loss";
import { DflashShard, listDflashShards, sampleDflashBatch, type DflashBatch, type DflashShardMeta } from "./data";
import { saveDrafter } from "./checkpoint";
import { draftProjection } from "./target";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

export interface DrafterTrainConfig {
  /** Shard directory written by `regenDrafterData`. */
  dataDir: string;
  /** Checkpoint directory (best held-out τ is saved here). */
  outDir: string;
  /** Identity stamped into dspark.json, e.g. `gemma-4-e4b-it-OptiQ-4bit@2560x262144`. */
  targetId: string;
  /** Drafter architecture. `tapLayers` MUST equal the regen's. */
  drafter: DflashConfig;
  iters: number;
  /** Anchors per step. */
  batch: number;
  /** Cap on the prefix context each anchor attends. */
  maxCtx: number;
  lr: number;
  warmup: number;
  evalEvery: number;
  /** Held-out anchors per evaluation. */
  evalAnchors: number;
  seed: number;
  /** Steps a loaded shard serves before the next one is loaded. */
  usesPerShard: number;
  /** Warm-start parameters from `outDir` when a checkpoint exists there (the
   *  optimizer and schedule restart; the checkpoint's own config wins). */
  resume: boolean;
}

export const DEFAULT_DRAFTER_TRAIN_CONFIG: Omit<DrafterTrainConfig, "dataDir" | "outDir" | "targetId"> = {
  drafter: DEFAULT_DFLASH_CONFIG, iters: 6000, batch: 8, maxCtx: 512, lr: 1.5e-3, warmup: 150,
  evalEvery: 500, evalAnchors: 256, seed: 0, usesPerShard: 200, resume: false,
};

export type DrafterTrainProgress =
  | { type: "start"; shards: number; train: number; validation: number; parameters: number; resumed: boolean; config: DflashConfig }
  | { type: "step"; step: number; iters: number; lr: number; loss: number }
  | { type: "eval"; step: number; tau: number; perPosition: number[]; saved: boolean };

export interface DrafterTrainResult { bestTau: number; steps: number; outDir: string }

/** xorshift32 stream shared by sampling and validation (a fixed seed reproduces a run). */
function makeRng(seed: number): () => number {
  let s = seed >>> 0 || 0x9e3779b9;
  return () => { s ^= s << 13; s >>>= 0; s ^= s >> 17; s ^= s << 5; s >>>= 0; return s / 0x100000000; };
}

export async function trainDrafter(
  model: RuntimeModel, config: DrafterTrainConfig, onProgress?: (event: DrafterTrainProgress) => void, signal?: AbortSignal,
): Promise<DrafterTrainResult> {
  const { iters, batch: batchSize, maxCtx } = config;
  const projection = draftProjection(model);
  const rng = makeRng(config.seed);

  const shards = listDflashShards(config.dataDir);
  if (shards.length === 0) throw new Error(`no shards under ${config.dataDir}`);
  const nVal = Math.max(1, Math.floor(shards.length * 0.1));
  const trainShards = shards.length > 2 ? shards.slice(0, shards.length - 2 * nVal) : shards;
  const valShards = shards.length > 2 ? shards.slice(shards.length - 2 * nVal, shards.length - nVal) : shards;

  const text = model.config.text;
  const resuming = config.resume && existsSync(join(config.outDir, "dspark.json"));
  const drafter = resuming ? DflashDrafter.load(config.outDir)
    : DflashDrafter.initFromDims({ hiddenSize: text.hiddenSize, vocabSize: text.vocabSize, eps: text.rmsNormEps },
      config.drafter, config.targetId, config.seed);
  const cfg = drafter.cfg, gamma = cfg.gamma;
  // The shard feature width is m*H: shards regenerated with other taps would train silently wrong.
  const recorded = JSON.parse(readFileSync(join(shards[0]!, "shard.json"), "utf8")) as DflashShardMeta;
  if (recorded.hiddenSize !== text.hiddenSize || recorded.tapLayers.join() !== cfg.tapLayers.join()) {
    drafter.dispose();
    throw new Error(`shards under ${config.dataDir} hold tap layers [${recorded.tapLayers}] of hidden size ${recorded.hiddenSize}, but the drafter reads tap layers [${cfg.tapLayers}] of hidden size ${text.hiddenSize}; pass the same --tap-layers to regen and train`);
  }
  const nParams = drafter.names.length;
  onProgress?.({ type: "start", shards: shards.length, train: trainShards.length, validation: valShards.length,
    parameters: nParams, resumed: resuming, config: cfg });

  const weights = positionWeights(gamma);
  let hCtx: MlxArray, mask: MlxArray, anchor: MlxArray, previous: MlxArray, xStar: MlxArray, targetLogits: MlxArray;
  const bind = (batch: DflashBatch): void => {
    const A = batch.size;
    hCtx = batch.hCtx; mask = batch.ctxMask;
    const anchorIds = ops.fromInt32(batch.anchorToks, [A]); anchor = projection.embed.encode(anchorIds); anchorIds.dispose();
    const prev: number[] = [], next: number[] = [];
    for (let a = 0; a < A; a++) {
      prev.push(batch.anchorToks[a]!);
      for (let k = 0; k < gamma - 1; k++) prev.push(batch.blockToks[a]![k]!);
      for (let k = 0; k < gamma; k++) next.push(batch.blockToks[a]![k]!);
    }
    previous = ops.fromInt32(prev, [A, gamma]); xStar = ops.fromInt32(next, [A, gamma]);
    const logits = projection.logitsFromHidden(batch.targetHidden);
    targetLogits = logits.dtype === Dtype.float32 ? logits : logits.astype(Dtype.float32);
    if (targetLogits !== logits) logits.dispose();
    batch.targetHidden.dispose();
  };
  const unbind = (): void => { hCtx.dispose(); mask.dispose(); anchor.dispose(); previous.dispose(); xStar.dispose(); targetLogits.dispose(); };

  const valueAndGrad = new ValueAndGrad(primals => drafter.useParams(primals, () => {
    const out = drafter.forwardTrain(projection, hCtx, mask, anchor, previous);
    const { loss, ce, tv, conf } = dsparkLoss(out, targetLogits, xStar, gamma, weights);
    out.draftLogits.dispose(); out.conf.dispose(); ce.dispose(); tv.dispose(); conf.dispose();
    return loss;
  }), Array.from({ length: nParams }, (_, i) => i));
  const optimizer = new AdamW(drafter.flatParams(), { lr: config.lr, weightDecay: 0.0 }, (i, p) => drafter.installParam(i, p));
  const schedule = warmupCosineSchedule(config.lr, config.warmup, iters);

  /** Held-out analytic τ: expected accepted length from the drafter's and the
   *  target's distributions, over `evalAnchors` anchors of one validation shard. */
  const evaluate = (): { tau: number; perPos: number[] } => {
    const shard = DflashShard.load(valShards[Math.floor(rng() * valShards.length)]!);
    try {
      let tauSum = 0, n = 0;
      const perPos = new Array<number>(gamma).fill(0);
      for (let g = 0; g < Math.ceil(config.evalAnchors / 16); g++) {
        const held = sampleDflashBatch(shard, 16, gamma, maxCtx, rng);
        if (!held) break;
        bind(held);
        const out = drafter.forwardTrain(projection, hCtx, mask, anchor, previous);
        const measured = analyticAcceptance(out, targetLogits);
        out.draftLogits.dispose(); out.conf.dispose(); unbind();
        tauSum += measured.tau * held.size; n += held.size;
        measured.perPos.forEach((value, i) => { perPos[i]! += value * held.size; });
      }
      return n ? { tau: tauSum / n, perPos: perPos.map(value => value / n) } : { tau: 0, perPos: [] };
    } finally { shard.dispose(); }
  };

  let bestTau = 0, cursor = 0, shard: DflashShard | null = null, uses = 0, steps = 0;
  try {
    for (let step = 1; step <= iters; step++) {
      signal?.throwIfAborted();
      if (!shard || uses >= config.usesPerShard) {
        shard?.dispose();
        shard = DflashShard.load(trainShards[cursor % trainShards.length]!); cursor++; uses = 0;
      }
      const batch = sampleDflashBatch(shard, batchSize, gamma, maxCtx, rng); uses++;
      if (!batch) continue;
      bind(batch); optimizer.lr = schedule(step);
      const { value, grads } = valueAndGrad.apply(drafter.flatParams());
      const loss = value.toFloat32()[0]!; value.dispose();
      optimizer.step(grads); optimizer.evalState(); unbind();
      steps = step;
      onProgress?.({ type: "step", step, iters, lr: schedule(step), loss });
      if (step % config.evalEvery === 0 || step === iters) {
        const { tau, perPos } = evaluate();
        const saved = tau > bestTau;
        if (saved) { bestTau = tau; saveDrafter(drafter, config.outDir); }
        onProgress?.({ type: "eval", step, tau, perPosition: perPos, saved });
      }
    }
  } finally {
    shard?.dispose();
    valueAndGrad.dispose();
    drafter.dispose();
    weights.dispose();
  }
  return { bestTau, steps, outDir: config.outDir };
}
