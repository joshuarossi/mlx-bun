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
import type { TokenLogprobs } from "../contracts/portable/generation";
import { StepExtras } from "./types";

export function stepExtrasArrays(extras: StepExtras | null): MlxArray[] {
  return extras
    ? [extras.sel, extras.topIdx, extras.topVals].filter(
        (array): array is MlxArray => array !== null,
      )
    : [];
}

export function disposeStepExtras(extras: StepExtras | null): void {
  if (!extras) return;
  extras.sel?.dispose();
  extras.topIdx?.dispose();
  extras.topVals?.dispose();
}

/** Read captured probabilities with their token, without adding casts behind
 * the next decode step. Consumes the capture on success and failure. */
export function readStepExtras(extras: StepExtras | null): TokenLogprobs | undefined {
  if (!extras) return undefined;
  try {
    const out: TokenLogprobs = {};
    if (extras.sel) out.logprob = extras.sel.toFloat32Host()[0]!;
    if (extras.topIdx && extras.topVals) {
      const ids = extras.topIdx.toIntTokens();
      const vals = extras.topVals.toFloat32Host();
      out.top = Array.from(ids, (id, i) => ({ id, logprob: vals[i]! }))
        .sort((a, b) => b.logprob - a.logprob);
    }
    return out;
  } finally { disposeStepExtras(extras); }
}
