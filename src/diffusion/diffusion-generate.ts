// DiffusionGemma denoising generation engine (port D2). Block-diffusion, NOT
// autoregressive: prefill the prompt once, then for each canvas block fill a
// fixed-length canvas with uniform-random token ids and un-mask it over <=48
// denoising steps, feeding the previous step's soft embeddings back in
// (self-conditioning). Ported verbatim from
// optiq/vlm/_mlxvlm/generate/diffusion.py (stream_diffusion_generate).
//
// RNG parity: canvas init + per-step re-noise call ops.randint with the GLOBAL
// mlx key (ops.randomSeed). Calling them in the same order as the reference
// reproduces its draws bit-for-bit → token-for-token parity on a fixed seed.
//
// Implements the public-API default sampler (confidence-threshold) AND the
// model-default (entropy-bound). temperature 0 (greedy) is the default and the
// only RNG consumers then are the canvas draws.

import type { DiffusionGemmaModel } from "../model/diffusion-gemma";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { disposing } from "../model/gemma4-base";

export interface DiffusionGenOptions {
  maxTokens: number;
  maxDenoisingSteps?: number; // default 48
  minCanvasLength?: number; // default 64
  maxCanvasLength?: number; // default model canvas (256)
  fullCanvas?: boolean; // force full model canvas each block
  sampler?: "confidence-threshold" | "entropy-bound"; // default confidence-threshold
  threshold?: number; // confidence accept threshold (default 0.9)
  entropyBound?: number; // entropy sampler bound (default 0.1)
  temperature?: number; // default 0 (greedy)
  tMin?: number; // schedule (default 0.4)
  tMax?: number; // schedule (default 0.8)
  // stable+confident early stop. The shipped checkpoint loads
  // generation_config=None in optiq, so this is OFF in the oracle (entropy runs
  // all steps). Only enabled when BOTH are provided (mirrors stopping_config).
  stabilityThreshold?: number;
  confidenceThreshold?: number;
  eosTokenIds?: number[]; // default [1, 106] (the tokenizer stopping set; NOT 50)
  seed?: bigint; // global RNG seed (default 0)
  /** Image-text-to-text: when set, `promptIds` are the SPLICED ids (with the
   *  <|image|> run) and the encoder prefills with the merged vision features +
   *  bidirectional overlay instead of the plain text path. Channel-first
   *  [1,3,H,W]. Caller keeps ownership. */
  visionPixels?: MlxArray;
}

export interface DiffusionGenResult {
  tokens: number[]; // emitted tokens (EOS-trimmed, EOS excluded)
  blocks: number[][]; // per-block final argmax canvases (full, pre-trim)
  steps: number; // total denoising steps run
  finishReason: "stop" | "length";
}

const I32 = Dtype.int32;

/** logits / schedule_temperature (the diffusion linear temperature schedule). */
function linearTemp(curStep: number, maxSteps: number, tMin: number, tMax: number): number {
  return tMin + (tMax - tMin) * (curStep / maxSteps);
}

/** confidence = exp(token_logit - logsumexp(logits)) in fp32 (per position). */
function tokenProbability(processed: MlxArray, tokenIds: MlxArray): MlxArray {
  const lf = processed.astype(Dtype.float32);
  const tokExp = ops.expandDims(tokenIds, -1); // [1, L, 1]
  const gathered = ops.takeAlongAxis(lf, tokExp, -1); // [1, L, 1]
  tokExp.dispose();
  const [b, l] = gathered.shape as [number, number, number];
  const tokLogits = ops.reshape(gathered, [b, l]); // squeeze(-1)
  gathered.dispose();
  const lse = ops.logsumexpAxis(lf, -1, false); // [1, L]
  lf.dispose();
  const diff = ops.sub(tokLogits, lse);
  tokLogits.dispose();
  lse.dispose();
  const conf = ops.exp(diff);
  diff.dispose();
  return conf;
}

/** entropy chain (reference _diffusion_entropy_probs_chain): returns
 *  { probs, entropy } in fp32. probs = exp(logits - logsumexp). */
function entropyProbsChain(processed: MlxArray): { probs: MlxArray; entropy: MlxArray } {
  const lf = processed.astype(Dtype.float32);
  const lse = ops.logsumexpAxis(lf, -1, true); // [1, L, 1]
  const logProbs = ops.sub(lf, lse);
  lf.dispose();
  lse.dispose();
  const probs = ops.exp(logProbs);
  const prod = ops.mul(probs, logProbs);
  logProbs.dispose();
  const summed = ops.sumAxis(prod, -1, false); // [1, L]
  prod.dispose();
  const entropy = ops.mulScalar(summed, -1);
  summed.dispose();
  return { probs, entropy };
}

/** per-position entropy -sum(p*logp) over vocab, fp32. */
function tokenEntropy(processed: MlxArray): MlxArray {
  const { probs, entropy } = entropyProbsChain(processed);
  probs.dispose();
  return entropy;
}

/** soft embeddings from precomputed probs (entropy sampler path):
 *  (probs.astype(w) @ w).astype(w) * embed_scale. */
function softEmbeddingsFromProbs(probs: MlxArray, weight: MlxArray, embedScale: number): MlxArray {
  const pc = probs.astype(weight.dtype);
  const m = ops.matmul(pc, weight);
  pc.dispose();
  const mc = m.astype(weight.dtype);
  m.dispose();
  const out = ops.mulScalar(mc, embedScale);
  mc.dispose();
  return out;
}

/** confidence-threshold acceptance mask (reference _diffusion_confidence_transfer_mask). */
function confidenceTransferMask(
  confidence: MlxArray,
  unrevealed: MlxArray,
  threshold: number,
  forceAll: boolean,
): MlxArray {
  if (forceAll) return ops.logicalNot(ops.logicalNot(unrevealed)); // copy of unrevealed
  const thr = ops.scalarLike(threshold, confidence);
  const ge = ops.greaterEqual(confidence, thr);
  thr.dispose();
  const transfer = ops.logicalAnd(unrevealed, ge);
  ge.dispose();
  const hasUnrevealed = ops.anyAxis(unrevealed, -1, true); // [1, 1]
  const hasTransfer = ops.anyAxis(transfer, -1, true); // [1, 1]
  const notTransfer = ops.logicalNot(hasTransfer);
  hasTransfer.dispose();
  const needsForce = ops.logicalAnd(hasUnrevealed, notTransfer); // [1, 1]
  hasUnrevealed.dispose();
  notTransfer.dispose();
  const negInf = ops.scalarLike(-Infinity, confidence);
  const maskedConf = ops.where(unrevealed, confidence, negInf); // [1, L]
  negInf.dispose();
  const best = ops.argmaxAxis(maskedConf, -1); // [1]
  maskedConf.dispose();
  const L = confidence.shape[confidence.shape.length - 1]!;
  const positions = ops.arange(0, L, 1, I32); // [L]
  const posRow = ops.reshape(positions, [1, L]);
  positions.dispose();
  const bestCol = ops.reshape(best, [1, 1]);
  best.dispose();
  const eq = ops.equal(posRow, bestCol); // [1, L]
  posRow.dispose();
  bestCol.dispose();
  const forced = ops.logicalAnd(eq, needsForce); // broadcast [1, L]
  eq.dispose();
  needsForce.dispose();
  const out = ops.logicalOr(transfer, forced);
  transfer.dispose();
  forced.dispose();
  return out;
}

/** entropy-bound acceptance mask (reference _diffusion_entropy_transfer_mask):
 *  sort positions by ascending entropy; accept the lowest-entropy prefix while
 *  cumsum - cummax <= bound; unsort. */
function entropyTransferMask(entropy: MlxArray, bound: number): MlxArray {
  const sortedIdx = ops.argsortAxis(entropy, -1); // [1, L]
  const sortedEnt = ops.takeAlongAxis(entropy, sortedIdx, -1);
  const cum = ops.cumsum(sortedEnt, -1);
  const cmax = ops.cummax(sortedEnt, -1);
  sortedEnt.dispose();
  const delta = ops.sub(cum, cmax);
  cum.dispose();
  cmax.dispose();
  const boundArr = ops.scalarLike(bound, delta);
  const sortedSel = ops.lessEqual(delta, boundArr); // [1, L] bool
  delta.dispose();
  boundArr.dispose();
  // put_along_axis: scatter sortedSel back via sortedIdx into a zero mask.
  const zeros = ops.zeros(sortedSel.shape, sortedSel.dtype);
  const out = ops.putAlongAxis(zeros, sortedIdx, sortedSel, -1);
  zeros.dispose();
  sortedIdx.dispose();
  sortedSel.dispose();
  return out;
}

export function diffusionGenerate(
  model: DiffusionGemmaModel,
  promptIds: number[],
  opts: DiffusionGenOptions,
): DiffusionGenResult {
  const t = model.config.text;
  const vocab = t.vocabSize;
  const modelCanvas = model.canvasLength;
  const maxSteps = opts.maxDenoisingSteps ?? 48;
  const fullCanvas = opts.fullCanvas ?? false;
  const maxCanvas = fullCanvas ? modelCanvas : Math.min(modelCanvas, opts.maxCanvasLength ?? modelCanvas);
  const minCanvas = Math.min(maxCanvas, opts.minCanvasLength ?? 64);
  const sampler = opts.sampler ?? "confidence-threshold";
  const threshold = opts.threshold ?? 0.9;
  const entropyBound = opts.entropyBound ?? 0.1;
  const temperature = opts.temperature ?? 0;
  const tMin = opts.tMin ?? 0.4;
  const tMax = opts.tMax ?? 0.8;
  // Stable-stop is OFF unless both thresholds are explicitly provided (the
  // oracle ships generation_config=None → stopping_config None → never stops).
  const stableStop = opts.stabilityThreshold !== undefined && opts.confidenceThreshold !== undefined;
  const stabilityThreshold = opts.stabilityThreshold ?? 1;
  const stopConfidence = opts.confidenceThreshold ?? 0.005;
  const eosIds = new Set(opts.eosTokenIds ?? [1, 106]);
  const maxNewTokens = opts.maxTokens;

  if (temperature > 0) throw new Error("diffusion temperature>0 (categorical sampling) not wired yet");

  ops.randomSeed(opts.seed ?? 0n);

  const cache = opts.visionPixels
    ? model.prefillVision(promptIds, opts.visionPixels)
    : model.prefill(promptIds);
  const dequantWeight = model.dequantEmbedWeight();

  const emitted: number[] = [];
  const blocks: number[][] = [];
  let totalSteps = 0;
  let generated = 0;
  let finishReason: "stop" | "length" = "length";
  let stopped = false;
  let isFirstBlock = true;

  try {
    while (generated < maxNewTokens) {
      const remaining = maxNewTokens - generated;
      const canvasLength = fullCanvas
        ? modelCanvas
        : Math.min(maxCanvas, Math.max(remaining, minCanvas));

      if (!isFirstBlock) {
        // Continuation: prefill the encoder over the previous accepted block.
        const prev = blocks[blocks.length - 1]!;
        const prevArr = MlxArray.fromInt32(Int32Array.from(prev), [1, prev.length]);
        model.extendPrefill(prevArr, cache);
        prevArr.dispose();
      }
      isFirstBlock = false;

      let currentCanvas = ops.randint(0, vocab, [1, canvasLength], I32); // RNG: init
      let draftReveal = ops.zeros([1, canvasLength], Dtype.bool);
      let draftCanvas: MlxArray = ops.logicalNot(ops.logicalNot(draftReveal)); // placeholder, replaced below
      draftCanvas.dispose();
      draftCanvas = ops.reshape(currentCanvas, [1, canvasLength]); // alias copy
      let argmaxCanvas = ops.reshape(currentCanvas, [1, canvasLength]);
      let scEmbeddings: MlxArray | null = null;
      const history: MlxArray[] = [];
      let stepsThisCanvas = 0;

      for (let curStep = maxSteps; curStep >= 1; curStep--) {
        stepsThisCanvas++;
        const logits = model.decoderLogits(currentCanvas, cache, scEmbeddings);
        const schedT = linearTemp(curStep, maxSteps, tMin, tMax);
        // Match the reference EXACTLY: divide (not reciprocal-multiply) — the
        // f32 rounding differs and the confidence threshold is a hard cutoff
        // that flips acceptance on a 1-ULP difference, diverging the trajectory.
        const schedArr = ops.scalarLike(schedT, logits);
        const processed = ops.div(logits, schedArr);
        schedArr.dispose();
        logits.dispose();

        argmaxCanvas.dispose();
        argmaxCanvas = ops.argmaxAxis(processed, -1).astype(I32); // [1, L]

        if (curStep === 1) {
          processed.dispose();
          break;
        }

        // temperature 0 → denoiser canvas is the argmax.
        const denoiser = argmaxCanvas;

        let acceptance: MlxArray;
        let nextSc: MlxArray | null = null;
        if (sampler === "entropy-bound") {
          // cur_step > 1 always here (cur_step==1 breaks before the sampler):
          // entropy AND the next soft embeddings come from the SAME entropy
          // chain (reference _diffusion_entropy_and_soft_embeddings) — NOT the
          // softmax-precise path the confidence sampler uses.
          const { probs, entropy } = entropyProbsChain(processed);
          acceptance = entropyTransferMask(entropy, entropyBound);
          entropy.dispose();
          nextSc = softEmbeddingsFromProbs(probs, dequantWeight, model.embedScale);
          probs.dispose();
          // accepted/current update (entropy variant)
          const accepted = ops.where(acceptance, denoiser, currentCanvas);
          const noise = ops.randint(0, vocab, [1, canvasLength], I32); // RNG: re-noise
          const newCurrent = ops.where(acceptance, accepted, noise);
          noise.dispose();
          currentCanvas.dispose();
          currentCanvas = newCurrent;
          draftReveal.dispose();
          draftReveal = ops.logicalNot(ops.logicalNot(acceptance)); // = acceptance
          draftCanvas.dispose();
          draftCanvas = ops.reshape(argmaxCanvas, [1, canvasLength]);
          accepted.dispose();
        } else {
          const unrevealed = ops.logicalNot(draftReveal);
          const confidence = tokenProbability(processed, denoiser);
          acceptance = confidenceTransferMask(confidence, unrevealed, threshold, false);
          confidence.dispose();
          const accepted = ops.where(acceptance, denoiser, draftCanvas);
          const revealOrAccept = ops.logicalOr(draftReveal, acceptance);
          const noise = ops.randint(0, vocab, [1, canvasLength], I32); // RNG: re-noise
          const newCurrent = ops.where(revealOrAccept, accepted, noise);
          noise.dispose();
          currentCanvas.dispose();
          currentCanvas = newCurrent;
          const newReveal = ops.logicalOr(draftReveal, acceptance);
          draftReveal.dispose();
          draftReveal = newReveal;
          const newDraft = ops.where(acceptance, accepted, draftCanvas);
          draftCanvas.dispose();
          draftCanvas = newDraft;
          unrevealed.dispose();
          revealOrAccept.dispose();
          accepted.dispose();
        }
        acceptance.dispose();

        // Early stop 1 (confidence sampler): all positions revealed.
        if (sampler === "confidence-threshold") {
          const allRevealed = ops.allReduce(draftReveal);
          const done = ops.itemBool(allRevealed);
          allRevealed.dispose();
          if (done) {
            processed.dispose();
            break;
          }
        }

        // Early stop 2: stable + confident (only when explicitly configured;
        // the as-loaded oracle has stopping_config None and never stops here).
        if (
          stableStop &&
          stableAndConfident(argmaxCanvas, processed, history, stabilityThreshold, stopConfidence)
        ) {
          processed.dispose();
          break;
        }

        // Self-conditioning feedback for the next step.
        if (curStep > 1) {
          if (nextSc === null) nextSc = model.softEmbeddings(processed, dequantWeight);
          if (scEmbeddings) scEmbeddings.dispose();
          scEmbeddings = nextSc;
        }
        processed.dispose();
      }

      if (scEmbeddings) scEmbeddings.dispose();
      for (const hh of history) hh.dispose();
      currentCanvas.dispose();
      draftReveal.dispose();
      draftCanvas.dispose();

      // Emit from the final argmax canvas.
      const blockTokens = [...argmaxCanvas.astype(Dtype.float32).toFloat32()].map((x) =>
        Math.round(x),
      );
      argmaxCanvas.dispose();
      blocks.push(blockTokens);
      totalSteps += stepsThisCanvas;

      for (const tok of blockTokens) {
        generated++;
        if (eosIds.has(tok)) {
          stopped = true;
          finishReason = "stop";
          break;
        }
        emitted.push(tok);
        if (generated >= maxNewTokens) {
          stopped = true;
          finishReason = "length";
          break;
        }
      }
      if (stopped) break;
    }
  } finally {
    dequantWeight.dispose();
    for (const c of cache) c.dispose();
  }

  return { tokens: emitted, blocks, steps: totalSteps, finishReason };
}

/** stable (last `stabilityThreshold` argmax canvases identical) AND confident
 *  (mean token entropy < bound). Mutates `history` like the reference. */
function stableAndConfident(
  argmaxCanvas: MlxArray,
  processed: MlxArray,
  history: MlxArray[],
  stabilityThreshold: number,
  confidenceThreshold: number,
): boolean {
  let stable: boolean;
  if (history.length === stabilityThreshold) {
    stable = history.every((canvas) => {
      const eq = ops.equal(argmaxCanvas, canvas);
      const all = ops.allReduce(eq);
      eq.dispose();
      const v = ops.itemBool(all);
      all.dispose();
      return v;
    });
  } else {
    stable = false;
  }
  // Push an INDEPENDENT copy (add-zero forces a fresh buffer): a reshape/view
  // would alias argmaxCanvas and read freed/overwritten data once the caller
  // disposes argmaxCanvas next step → false "stable" → premature stop.
  const zero = ops.scalarLike(0, argmaxCanvas);
  history.push(ops.add(argmaxCanvas, zero));
  zero.dispose();
  if (history.length > stabilityThreshold) history.shift()!.dispose();
  if (!stable) return false;

  const entropy = tokenEntropy(processed);
  const meanEnt = ops.meanAll(entropy, false);
  entropy.dispose();
  const thr = ops.scalarLike(confidenceThreshold, meanEnt);
  const lt = ops.less(meanEnt, thr);
  meanEnt.dispose();
  thr.dispose();
  const confident = ops.itemBool(lt);
  lt.dispose();
  return confident;
}
