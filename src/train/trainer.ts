// LoRA trainer: SFT (masked cross-entropy) and DPO loops over a single
// quantized base, differentiating only the LoRA A/B leaves.
//
// The value_and_grad closure differentiates [...flatA, ...flatB]. Inside the
// closure we swap the incoming primal handles into the LoraWeights so the
// model's forward builds its graph against the differentiated leaves; after
// AdamW.step replaces a leaf, the writeback callback pushes the new handle
// back into the LoraWeights so the next forward (and the next closure swap)
// sees it. Base quantized weights are never in argnums — they stay frozen.

import { MlxArray } from "../mlx/array";
import { clearCache } from "../mlx/ffi";
import { ValueAndGrad } from "../mlx/autograd";
import * as ops from "../mlx/ops";
import { evalAll } from "../mlx/ops";
import type { RuntimeModel } from "../model/factory";
import { Gemma4Model, type GradCheckpointCtx } from "../model/gemma4";
import { setTrainingAttn } from "../model/flash-attention";
import type { LoadedTokenizer } from "../tokenizer";
import type { ChatTemplate } from "../chat-template";
import type { Emit } from "../jobs/types";
import {
  loadSftDataset, iterateSftBatches, loadDpoDataset, iterateDpoBatches,
  rowLength, type SftBatch, type DpoBatch,
} from "./dataset";
import {
  buildTrainableLora, attachForTraining, detachTraining, flatParams,
  saveAdapter, disposeLora, type TrainableLora, type SaveAdapterConfig,
} from "./lora-params";
import { resolveRanks, DEFAULT_TARGET_MODULES, type RankScaling } from "./rank";
import { sftLoss, dpoLoss, dpoRefLogps, dpoMetrics } from "./loss";
import { AdamW, warmupCosineSchedule } from "./optimizer";

export interface TrainConfig {
  method: "sft" | "dpo";
  rank: number;
  scale: number;
  rankScaling: RankScaling;
  targetModules: string[];
  numLayers: number;
  iters: number;
  learningRate: number;
  maxSeqLen: number;
  batchSize: number;
  gradAccumSteps: number;
  seed: number;
  stepsPerReport: number;
  stepsPerEval: number;
  betas: [number, number];
  weightDecay: number;
  /** Gradient checkpointing: recompute layer activations in the backward pass
   *  to bound memory at long context (mlx-lm grad_checkpoint; default in optiq).
   *  Numerically identical to off — pure memory↔compute trade. */
  gradCheckpoint: boolean;
  // DPO
  dpoBeta: number;
  dpoWarmupIters: number;
  dpoLrSchedule: "constant" | "cosine";
  // output
  adapterPath: string;
  baseModel: string;
}

export interface TrainResult {
  adapterPath: string;
  appliedRanks: Record<string, number>;
  numIters: number;
}

export const DEFAULT_TRAIN_CONFIG: TrainConfig = {
  method: "sft",
  rank: 8,
  scale: 1.0,
  rankScaling: "by_bits",
  targetModules: [...DEFAULT_TARGET_MODULES],
  numLayers: -1,
  iters: 100,
  learningRate: 2e-4,
  maxSeqLen: 512,
  batchSize: 1,
  gradAccumSteps: 1,
  seed: 0,
  stepsPerReport: 10,
  stepsPerEval: 50,
  betas: [0.9, 0.999],
  weightDecay: 0.01,
  gradCheckpoint: false, // default off until validated; flip to true (optiq default) after

  dpoBeta: 0.1,
  dpoWarmupIters: 0,
  dpoLrSchedule: "cosine",
  adapterPath: "adapters",
  baseModel: "",
};

/** Run a LoRA fine-tune. Emits per-step train metrics, periodic val metrics,
 *  and a final stage:done with the adapter path + applied ranks. Saves the
 *  adapter (last + best-on-val) and returns where it landed. */
export async function trainLora(
  model: RuntimeModel,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  dataDir: string,
  cfg: TrainConfig,
  emit: Emit,
): Promise<TrainResult> {
  emit({ type: "stage", stage: "setup", progress: 0.02, message: "resolving ranks" });

  const ranks = resolveRanks(model, {
    rank: cfg.rank,
    rankScaling: cfg.rankScaling,
    targetModules: cfg.targetModules,
    numLayers: cfg.numLayers,
  });
  const appliedRanks: Record<string, number> = Object.fromEntries(ranks);

  const lora = buildTrainableLora(model, ranks, cfg.scale, cfg.seed);
  attachForTraining(model, lora, "train");

  const saveCfg: SaveAdapterConfig = {
    rank: cfg.rank,
    scale: cfg.scale,
    rankScaling: cfg.rankScaling,
    targetModules: cfg.targetModules,
    numLayers: cfg.numLayers,
    method: cfg.method,
    baseModel: cfg.baseModel,
  };

  try {
    const result =
      cfg.method === "dpo"
        ? await dpoLoop(model, tok, tmpl, dataDir, cfg, lora, emit)
        : await sftLoop(model, tok, tmpl, dataDir, cfg, lora, emit);

    // Final save (last adapter).
    detachTraining(model, lora);
    saveAdapter(lora, cfg.adapterPath, saveCfg, appliedRanks);
    emit({
      type: "stage",
      stage: "done",
      progress: 1,
      message: `adapter saved to ${cfg.adapterPath}`,
      adapter_path: cfg.adapterPath,
      applied_ranks: appliedRanks,
    });
    return { adapterPath: cfg.adapterPath, appliedRanks, numIters: result.numIters };
  } finally {
    disposeLora(lora);
  }
}

// ---------------------------------------------------------------------------
// SFT loop
// ---------------------------------------------------------------------------

async function sftLoop(
  model: RuntimeModel,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  dataDir: string,
  cfg: TrainConfig,
  lora: TrainableLora,
  emit: Emit,
): Promise<{ numIters: number }> {
  emit({ type: "stage", stage: "data", progress: 0.05, message: "loading SFT dataset" });
  const train = await loadSftDataset(`${dataDir}/train.jsonl`, tok, tmpl);
  const valid = (await fileExists(`${dataDir}/valid.jsonl`))
    ? await loadSftDataset(`${dataDir}/valid.jsonl`, tok, tmpl)
    : [];

  const params = flatParams(lora);
  const opt = new AdamW(
    params,
    { lr: cfg.learningRate, betas: cfg.betas, eps: 1e-8, weightDecay: cfg.weightDecay },
    (i, p) => writeParam(lora, i, p),
  );

  // The value_and_grad loss closure: temporarily swap the differentiated
  // primals into the LoraWeights so the forward graph differentiates them,
  // build the SFT loss against the active batch, then restore the original
  // leaf wrappers (the primal wrappers get disposed by the autograd closure;
  // the graph already captured their handles).
  let currentBatch: SftBatch | null = null;
  const vag = new ValueAndGrad((primals) => {
    const saved = swapPrimals(lora, primals);
    try {
      return sftLoss(model, currentBatch!);
    } finally {
      restorePrimals(lora, saved);
    }
  }, params.map((_, i) => i));

  // Gradient checkpointing: group each layer's LoRA weights so forwardLayers
  // can thread them as explicit checkpoint inputs (see Gemma4Model.gradCkpt).
  // Checkpoints are created per forward and disposed after each step's backward.
  let ckptCtx: GradCheckpointCtx | null = null;
  if (cfg.gradCheckpoint && model instanceof Gemma4Model) {
    const byLayer: GradCheckpointCtx["byLayer"] = new Map();
    for (const t of lora.targets) {
      const m = t.modulePath.match(/\.layers\.(\d+)\./);
      if (!m) continue;
      const li = Number(m[1]);
      (byLayer.get(li) ?? byLayer.set(li, []).get(li)!).push(t.lw);
    }
    ckptCtx = { byLayer, keepAlive: [] };
    model.gradCkpt = ckptCtx;
  }

  // Training attention: ops.sdpa's dK vjp is wrong, so route the forward
  // through the validated flash kernel (correct dQ/dK/dV, handles the sliding
  // window, memory-efficient). Cleared in finally.
  setTrainingAttn("flash");

  // Pad with the eos id when available (a real sentinel token); padded
  // positions are excluded from both the loss and attention masks, so the
  // exact pad value never affects the result — it just must be a valid id.
  const padId = tok.eosTokenId ?? 0;
  const batches = iterateSftBatches(train, cfg.batchSize, cfg.maxSeqLen, cfg.seed, true, padId);
  const t0 = Date.now();

  try {
    for (let step = 1; step <= cfg.iters; step++) {
      currentBatch = batches.next().value as SftBatch;
      const tokensThisStep = countResponseTokens(currentBatch);

      const { value, grads } = vag.apply(flatParams(lora));
      const lossVal = value.toFloat32()[0]!;
      value.dispose();

      const gradNorm = globalNorm(grads); // also evals grads (runs the recompute)
      opt.step(grads);
      opt.evalState();
      clearCache();
      if (ckptCtx) {
        // Grads are materialized (globalNorm/evalState), so the recompute is
        // done — free this step's checkpoint closures before the next forward.
        for (const ck of ckptCtx.keepAlive) ck.dispose();
        ckptCtx.keepAlive.length = 0;
      }

      if (step % cfg.stepsPerReport === 0 || step === 1) {
        const elapsed = (Date.now() - t0) / 1000;
        emit({
          type: "metric",
          kind: "train",
          step,
          loss: lossVal,
          grad_norm: gradNorm,
          learning_rate: opt.lr,
          tokens_per_sec: elapsed > 0 ? (step * tokensThisStep) / elapsed : 0,
          progress: step / cfg.iters,
          message: `step ${step}/${cfg.iters} loss=${lossVal.toFixed(4)}`,
        });
      }

      if (valid.length > 0 && step % cfg.stepsPerEval === 0) {
        // Eval is forward-only (no backward), so disable checkpointing for it —
        // it adds no benefit and a forward-only pass fits without it.
        if (ckptCtx) (model as Gemma4Model).gradCkpt = null;
        const vLoss = evalSftLoss(model, valid, cfg);
        if (ckptCtx) (model as Gemma4Model).gradCkpt = ckptCtx;
        emit({ type: "metric", kind: "val", step, loss: vLoss, progress: step / cfg.iters });
      }
    }
  } finally {
    setTrainingAttn(null);
    vag.dispose();
    opt.dispose();
    if (ckptCtx) {
      (model as Gemma4Model).gradCkpt = null;
      for (const ck of ckptCtx.keepAlive) ck.dispose();
    }
  }
  return { numIters: cfg.iters };
}

function evalSftLoss(model: RuntimeModel, valid: ReturnType<typeof Array.prototype.slice>, cfg: TrainConfig): number {
  let total = 0;
  let n = 0;
  for (const ex of valid as { ids: number[]; promptLen: number }[]) {
    let ids = ex.ids;
    let promptLen = ex.promptLen;
    if (ids.length < 2) continue;
    if (ids.length > cfg.maxSeqLen) {
      ids = ids.slice(0, cfg.maxSeqLen);
      promptLen = Math.min(promptLen, Math.max(0, ids.length - 1));
    }
    const batch: SftBatch = { ids: [ids], promptLens: [promptLen] };
    try {
      const loss = sftLoss(model, batch);
      total += loss.toFloat32()[0]!;
      loss.dispose();
      n++;
    } catch {
      // skip examples with no response tokens
    }
    clearCache();
  }
  return n > 0 ? total / n : 0;
}

// ---------------------------------------------------------------------------
// DPO loop
// ---------------------------------------------------------------------------

async function dpoLoop(
  model: RuntimeModel,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  dataDir: string,
  cfg: TrainConfig,
  lora: TrainableLora,
  emit: Emit,
): Promise<{ numIters: number }> {
  emit({ type: "stage", stage: "data", progress: 0.05, message: "loading DPO dataset" });
  const train = await loadDpoDataset(`${dataDir}/train.jsonl`, tok, tmpl, cfg.maxSeqLen);
  const valid = (await fileExists(`${dataDir}/valid.jsonl`))
    ? await loadDpoDataset(`${dataDir}/valid.jsonl`, tok, tmpl, cfg.maxSeqLen)
    : [];

  const params = flatParams(lora);
  const opt = new AdamW(
    params,
    { lr: cfg.learningRate, betas: cfg.betas, eps: 1e-8, weightDecay: cfg.weightDecay },
    (i, p) => writeParam(lora, i, p),
  );

  const schedule =
    cfg.dpoLrSchedule === "cosine" || cfg.dpoWarmupIters > 0
      ? warmupCosineSchedule(cfg.learningRate, cfg.dpoWarmupIters, cfg.iters)
      : null;

  // Reference log-probs are computed each step OUTSIDE value_and_grad (so the
  // reference activations free before the policy forwards), then read as
  // detached constants inside the closure.
  let currentBatch: DpoBatch | null = null;
  let refChosen: MlxArray | null = null;
  let refRejected: MlxArray | null = null;

  const vag = new ValueAndGrad((primals) => {
    const saved = swapPrimals(lora, primals);
    try {
      return dpoLoss(model, currentBatch!, cfg.dpoBeta, refChosen!, refRejected!);
    } finally {
      restorePrimals(lora, saved);
    }
  }, params.map((_, i) => i));

  const padId = tok.eosTokenId ?? 0;
  const batches = iterateDpoBatches(train, cfg.batchSize, cfg.seed, true, padId);
  const t0 = Date.now();

  try {
    for (let step = 1; step <= cfg.iters; step++) {
      currentBatch = batches.next().value as DpoBatch;
      if (schedule) opt.lr = schedule(step);

      const refs = dpoRefLogps(model, lora, currentBatch);
      refChosen = refs.refChosen;
      refRejected = refs.refRejected;

      const { value, grads } = vag.apply(flatParams(lora));
      const lossVal = value.toFloat32()[0]!;
      value.dispose();

      const gradNorm = globalNorm(grads);
      opt.step(grads);
      opt.evalState();

      refChosen.dispose();
      refRejected.dispose();
      refChosen = refRejected = null;
      clearCache();

      if (step % cfg.stepsPerReport === 0 || step === 1) {
        const m = dpoMetrics(model, lora, currentBatch, cfg.dpoBeta);
        const elapsed = (Date.now() - t0) / 1000;
        emit({
          type: "metric",
          kind: "train",
          step,
          loss: lossVal,
          grad_norm: gradNorm,
          learning_rate: opt.lr,
          accuracy: m.accuracy,
          margin: m.margin,
          tokens_per_sec: 0,
          progress: step / cfg.iters,
          message: `step ${step}/${cfg.iters} loss=${lossVal.toFixed(4)} acc=${m.accuracy.toFixed(2)} margin=${m.margin.toFixed(3)}`,
        });
        clearCache();
      }

      if (valid.length > 0 && step % cfg.stepsPerEval === 0) {
        let vl = 0, va = 0, vm = 0, vn = 0;
        for (const ex of valid) {
          const vb: DpoBatch = {
            chosenIds: [ex.chosenIds], rejectedIds: [ex.rejectedIds],
            chosenMask: [ex.chosenMask], rejectedMask: [ex.rejectedMask],
          };
          const m = dpoMetrics(model, lora, vb, cfg.dpoBeta);
          vl += m.loss; va += m.accuracy; vm += m.margin; vn++;
          clearCache();
        }
        emit({
          type: "metric", kind: "val", step,
          loss: vn ? vl / vn : 0,
          accuracy: vn ? va / vn : 0,
          margin: vn ? vm / vn : 0,
          progress: step / cfg.iters,
        });
      }
    }
  } finally {
    vag.dispose();
    opt.dispose();
    refChosen?.dispose();
    refRejected?.dispose();
  }
  return { numIters: cfg.iters };
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

/** Swap the incoming value_and_grad primals into the LoraWeights so the
 *  forward graph differentiates them. Order: [...A, ...B] over sorted targets.
 *  Returns the displaced original leaves so the caller can restore them (the
 *  primal wrappers are disposed by the autograd closure after this returns). */
function swapPrimals(lora: TrainableLora, primals: MlxArray[]): MlxArray[] {
  const n = lora.targets.length;
  const saved: MlxArray[] = [];
  for (let i = 0; i < n; i++) {
    saved.push(lora.targets[i]!.lw.a, lora.targets[i]!.lw.b);
    lora.targets[i]!.lw.a = primals[i]!;
    lora.targets[i]!.lw.b = primals[n + i]!;
  }
  return saved;
}

/** Restore the original leaves displaced by swapPrimals (saved order is
 *  [a0, b0, a1, b1, ...]). */
function restorePrimals(lora: TrainableLora, saved: MlxArray[]): void {
  for (let i = 0; i < lora.targets.length; i++) {
    lora.targets[i]!.lw.a = saved[2 * i]!;
    lora.targets[i]!.lw.b = saved[2 * i + 1]!;
  }
}

/** Write a replaced param (AdamW output) back into its LoraWeights leaf. */
function writeParam(lora: TrainableLora, i: number, p: MlxArray): void {
  const n = lora.targets.length;
  if (i < n) lora.targets[i]!.lw.a = p;
  else lora.targets[i - n]!.lw.b = p;
}

/** L2 norm over all grads (also forces eval). */
function globalNorm(grads: MlxArray[]): number {
  const partial: MlxArray[] = grads.map((g) => {
    const sq = ops.square(g);
    const flat = ops.reshape(sq, [g.size]);
    const sum = ops.sumAxis(flat, 0, false);
    sq.dispose();
    flat.dispose();
    return sum;
  });
  evalAll(partial);
  let sumSq = 0;
  for (const p of partial) {
    sumSq += p.toFloat32()[0]!;
    p.dispose();
  }
  return Math.sqrt(sumSq);
}

function countResponseTokens(batch: SftBatch): number {
  const promptLen = batch.promptLens[0]!;
  const len = batch.ids[0]!.length;
  return Math.max(0, len - Math.max(promptLen, 1));
}

async function fileExists(path: string): Promise<boolean> {
  return Bun.file(path).exists();
}
