// Sampling — port of mlx-lm's sample_utils.make_sampler /
// make_logits_processors (temperature, top-p, top-k, min-p, XTC,
// repetition/presence/frequency penalties, logit bias).
// All filtering happens on-device; only the chosen token id crosses to JS.
// Seeded: each step derives a fresh key from (seed, step) so runs are
// reproducible without sharing global RNG state. (mlx-lm draws XTC's
// uniform and the categorical from one global stream; we split the
// per-step key into (xtc, categorical) subkeys instead — deterministic,
// and the XTC-off path is unchanged.)

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { applyCurve } from "./curve";
import { applyMinP,applyTopK,applyTopP,applyXtc } from "./filters";
import { HlgParams,applyHlg,applyHlgEotf,applyHlgOetf,applyHlgPipeline,applyHlgShaper,hlgGammaForLw } from "./hlg";
import { Sampler,SamplerOptions } from "./types";

const GOLDEN = 0x9e3779b97f4a7c15n;

export function stepKey(seed: number, step: number): MlxArray {
  const mixed = (BigInt(seed) ^ ((BigInt(step) + 1n) * GOLDEN)) & 0xffffffffffffffffn;
  return ops.randomKey(mixed);
}

export function makeSampler(opts: SamplerOptions = {}): Sampler {
  const {
    temperature = 0, topP = 0, topK = 0, minP = 0, minTokensToKeep = 1,
    xtcProbability = 0, xtcThreshold = 0, xtcSpecialTokens = [],
    seed = 0, hlg, curve,
  } = opts;

  // v2 curve sampler: the drawn log-prob transfer curve REPLACES temperature +
  // softmax. Stochastic and seeded by design (the curve IS the sampling shape),
  // so it overrides the greedy default — the designer wants variety across N.
  if (curve) {
    return (lp, step) => {
      const shaped = applyCurve(lp, curve);
      const tok = ops.randomCategorical(shaped, stepKey(seed, step));
      shaped.dispose();
      return tok;
    };
  }

  // Greedy: HLG is a no-op (a monotone curve cannot move the argmax), so the
  // greedy path is untouched whether or not HLG is enabled.
  if (temperature === 0)
    return (lp) => ops.argmaxAxis(lp, -1);

  // HLG is a REPLACEMENT sampler: when enabled, the tone curve IS the whole
  // post-logits step — its toe does the tail control that top_p/top_k would, so
  // they are NOT applied. Otherwise we do exactly what we used to: top_p, top_k,
  // then temperature scaling. (Temperature still folds into the mid gain m = 1/T
  // unless the config sets an explicit gain.)
  if (hlg?.enabled === true) {
    const useOetf = hlg.oetf === true;
    const useEotf = hlg.eotf === true;
    const usePipeline = hlg.pipeline === true;
    const eotfGamma = hlgGammaForLw(hlg.lw ?? 1000);
    const alpha = hlg.maxBrightness ?? 5;
    const params: HlgParams = {
      gain: hlg.gain ?? 1 / temperature,
      width: hlg.width,
      shoulder: hlg.shoulder,
      toe: hlg.toe,
      pivot: hlg.pivot,
      pivotOffset: hlg.pivotOffset,
    };
    return (lp, step) => {
      const scaled = hlg.shaper === true
        ? applyHlgShaper(lp, { lw: hlg.lw, outScale: hlg.maxBrightness, window: hlg.window, sM: hlg.sM, A: hlg.shoulderA, targetGap: hlg.targetGap, refGap: hlg.refGap, xM: hlg.xM, yM: hlg.yM, xFloor: hlg.xFloor, yFloor: hlg.yFloor, p: hlg.p })
        : usePipeline ? applyHlgPipeline(lp, alpha, eotfGamma)
        : useEotf ? applyHlgEotf(lp, eotfGamma) : useOetf ? applyHlgOetf(lp) : applyHlg(lp, params);
      const key = stepKey(seed, step);
      const tok = ops.randomCategorical(scaled, key);
      scaled.dispose();
      key.dispose();
      return tok;
    };
  }

  // Filter chain order matches mlx-lm's make_sampler: top_p → min_p → xtc →
  // top_k, then categorical(logprobs / temperature).
  return (lp, step) => {
    let cur = lp;
    const owned: MlxArray[] = [];
    let key = stepKey(seed, step);
    if (topP > 0 && topP < 1) { cur = applyTopP(cur, topP); owned.push(cur); }
    if (minP !== 0) { cur = applyMinP(cur, minP, minTokensToKeep); owned.push(cur); }
    if (xtcProbability > 0) {
      // Split the step key: subkey 0 → XTC's uniform, subkey 1 → categorical.
      const split = ops.randomSplitNum(key, 2);
      const row0 = split.slice([0, 0], [1, 2]);
      const row1 = split.slice([1, 0], [2, 2]);
      const xtcKey = ops.reshape(row0, [2]);
      key.dispose();
      key = ops.reshape(row1, [2]);
      for (const a of [split, row0, row1]) a.dispose();
      cur = applyXtc(cur, xtcProbability, xtcThreshold, xtcSpecialTokens, xtcKey);
      owned.push(cur);
      xtcKey.dispose();
    }
    if (topK > 0) { cur = applyTopK(cur, topK); owned.push(cur); }
    const scaled = ops.mulScalar(cur, 1 / temperature);
    const tok = ops.randomCategorical(scaled, key);
    scaled.dispose();
    key.dispose();
    for (const a of owned) a.dispose();
    return tok;
  };
}

/** logits [..., V] → logprobs [..., V] (logits - logsumexp). */
export function toLogprobs(logits: MlxArray): MlxArray {
  const lse = ops.logsumexpAxis(logits, -1, true);
  const out = ops.sub(logits, lse);
  lse.dispose();
  return out;
}
