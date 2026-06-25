// DiffusionGemma LoRA fine-tuning (port D5). DiffusionGemma is a discrete
// block-diffusion LM, so the AR cross-entropy trainer doesn't apply — train LoRA
// with the model's NATIVE denoising objective (port of optiq
// vlm/diffusion_gemma/lora.py `diffusion_loss` + `train_diffusion_lora`):
//   corrupt the target canvas to a random noise level t∈[t_min,t_max] (replace
//   each token with prob t by a uniform-random token — the same corruption the
//   inference canvas starts from), run one encoder+decoder forward, and minimise
//   cross-entropy on the CORRUPTED positions (predict the clean token).
//
// LoRA is injected on the decoder blocks (DEFAULT_LORA_KEYS = attn q/k/v/o +
// dense MLP gate/up/down). The encoder reuses those same blocks (weight-tied,
// only per-layer scalars differ), so one injection trains both paths. Experts/
// router stay frozen (their routing indices are stop_gradient'd so the MoE
// backward differentiates only the activations). Adapter saved in the
// AdapterManager.mount layout (lora_a/lora_b), mountable for inference.

import * as ops from "../mlx/ops";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { ValueAndGrad } from "../mlx/autograd";
import { DiffusionGemmaModel } from "../model/diffusion-gemma";
import { AdamW } from "./optimizer";
import {
  attachForTraining,
  buildTrainableLora,
  detachTraining,
  flatParams,
  type TrainableLora,
} from "./lora-params";

export const DEFAULT_LORA_KEYS = [
  "self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj", "self_attn.o_proj",
  "mlp.gate_proj", "mlp.up_proj", "mlp.down_proj",
];

export interface DiffusionPair {
  promptIds: number[];
  targetIds: number[];
}

export interface DiffusionLoraConfig {
  rank?: number; // default 8
  scale?: number; // default 8.0 (diffusion is scale-sensitive; AR's 20 collapses)
  iters?: number; // default 200
  learningRate?: number; // default 1e-4
  tMin?: number; // default 0.4
  tMax?: number; // default 0.8
  seed?: number; // default 0
  reportEvery?: number; // default 10
  onReport?: (iter: number, avgLoss: number) => void;
}

/** swap/restore the differentiated primals into the LoRA leaves (port of the
 *  trainer.ts private helpers — primals order is [...A, ...B]). */
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
function restorePrimals(lora: TrainableLora, saved: MlxArray[]): void {
  for (let i = 0; i < lora.targets.length; i++) {
    lora.targets[i]!.lw.a = saved[2 * i]!;
    lora.targets[i]!.lw.b = saved[2 * i + 1]!;
  }
}
function writeParam(lora: TrainableLora, i: number, p: MlxArray): void {
  const n = lora.targets.length;
  if (i < n) lora.targets[i]!.lw.a = p;
  else lora.targets[i - n]!.lw.b = p;
}

/** sum all elements -> scalar []. */
function sumAll(a: MlxArray): MlxArray {
  const flat = ops.reshape(a, [a.size]);
  const s = ops.sumAxis(flat, 0, false);
  flat.dispose();
  return s;
}

/** Denoising cross-entropy on corrupted canvas positions (the reference
 *  diffusion_loss). Returns a scalar loss MlxArray, differentiable w.r.t. the
 *  mounted LoRA. */
export function diffusionLoss(
  model: DiffusionGemmaModel,
  promptIds: number[],
  targetIds: number[],
  tMin: number,
  tMax: number,
  vocab: number,
): MlxArray {
  const L = targetIds.length;
  // t ~ U(t_min, t_max) scalar; corrupt[i] = U(0,1) < t ; noise ~ randint
  const t = ops.randomUniform([1], Dtype.float32, tMin, tMax, null);
  const u = ops.randomUniform([1, L], Dtype.float32, 0, 1, null);
  const corrupt = ops.less(u, t); // bool [1, L]
  u.dispose();
  t.dispose();
  const noise = ops.randint(0, vocab, [1, L], Dtype.int32);
  const target = MlxArray.fromInt32(Int32Array.from(targetIds), [1, L]);
  const canvas = ops.where(corrupt, noise, target);
  noise.dispose();

  const logits = model.forwardCanvasLogitsArr(promptIds, canvas); // [1, L, vocab] f32
  canvas.dispose();

  // cross_entropy(reduction=none) = logsumexp(logits) - logit_at_target
  const lse = ops.logsumexpAxis(logits, -1, false); // [1, L]
  const tExp = ops.expandDims(target, -1); // [1, L, 1]
  const gathered = ops.takeAlongAxis(logits, tExp, -1); // [1, L, 1]
  tExp.dispose();
  logits.dispose();
  const tgt = ops.reshape(gathered, [1, L]);
  gathered.dispose();
  const ce = ops.sub(lse, tgt); // [1, L]
  lse.dispose();
  tgt.dispose();
  target.dispose();

  const corruptF = corrupt.astype(Dtype.float32);
  corrupt.dispose();
  const masked = ops.mul(ce, corruptF);
  ce.dispose();
  const num = sumAll(masked);
  masked.dispose();
  const cnt = sumAll(corruptF);
  corruptF.dispose();
  const one = ops.scalarLike(1, cnt);
  const denom = ops.maximum(cnt, one);
  cnt.dispose();
  one.dispose();
  const loss = ops.div(num, denom);
  num.dispose();
  denom.dispose();
  return loss;
}

/** Train a LoRA adapter on DiffusionGemma with the denoising objective. Returns
 *  the TrainableLora (caller saves it via saveAdapter) + the loss history. */
export function trainDiffusionLora(
  model: DiffusionGemmaModel,
  pairs: DiffusionPair[],
  cfg: DiffusionLoraConfig = {},
): { lora: TrainableLora; losses: number[] } {
  const rank = cfg.rank ?? 8;
  const scale = cfg.scale ?? 8.0;
  const iters = cfg.iters ?? 200;
  const lr = cfg.learningRate ?? 1e-4;
  const tMin = cfg.tMin ?? 0.4;
  const tMax = cfg.tMax ?? 0.8;
  const seed = cfg.seed ?? 0;
  const reportEvery = cfg.reportEvery ?? 10;
  const vocab = model.config.text.vocabSize;
  if (pairs.length === 0) throw new Error("no training pairs");

  ops.randomSeed(BigInt(seed >>> 0));

  // LoRA on every decoder block's attn + dense MLP (skips full-layer v_proj
  // automatically — buildTrainableLora filters to existing loraTargets).
  const ranks = new Map<string, number>();
  for (let i = 0; i < model.layers.length; i++)
    for (const key of DEFAULT_LORA_KEYS) ranks.set(`model.decoder.layers.${i}.${key}`, rank);
  const lora = buildTrainableLora(model, ranks, scale, seed);
  attachForTraining(model, lora, "train");
  model.loraState.active = ["train"];

  const params = flatParams(lora);
  const opt = new AdamW(
    params,
    { lr, betas: [0.9, 0.999], eps: 1e-8, weightDecay: 0.01 },
    (i, p) => writeParam(lora, i, p),
  );

  let current: DiffusionPair = pairs[0]!;
  const vag = new ValueAndGrad((primals) => {
    const saved = swapPrimals(lora, primals);
    try {
      return diffusionLoss(model, current.promptIds, current.targetIds, tMin, tMax, vocab);
    } finally {
      restorePrimals(lora, saved);
    }
  }, params.map((_, i) => i));

  const losses: number[] = [];
  try {
    for (let it = 0; it < iters; it++) {
      current = pairs[it % pairs.length]!;
      if (current.targetIds.length === 0) continue;
      const { value, grads } = vag.apply(flatParams(lora));
      opt.step(grads); // takes ownership of grads + writes via writeParam
      ops.evalAll([...flatParams(lora), value]);
      const lossNum = value.astype(Dtype.float32).toFloat32()[0]!;
      value.dispose();
      losses.push(lossNum);
      if ((it + 1) % reportEvery === 0) {
        const window = losses.slice(-reportEvery);
        cfg.onReport?.(it + 1, window.reduce((a, b) => a + b, 0) / window.length);
      }
    }
  } catch (e) {
    // On failure, undo the mount so the model is left clean.
    detachTraining(model, lora);
    model.loraState.active = [];
    vag.dispose();
    throw e;
  }
  // On success leave the trained LoRA ATTACHED + ACTIVE so the model is
  // immediately usable; the caller saves it (saveAdapter) and may detach.
  vag.dispose();
  model.loraState.active = ["train"];
  return { lora, losses };
}
