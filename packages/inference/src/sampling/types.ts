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
import type { SampledToken,SamplingSession } from "../contracts/portable/sampling";
import { type CurveParams } from "./curve";

/** Resolved HLG sampling config (the user-facing knobs). The mid gain is NOT
 *  here — it folds from temperature (m = 1/T) when the sampler is built. */
export interface HlgConfig {
  enabled: boolean;
  width: number;
  shoulder: number;
  toe: number;
  pivot?: "top" | "entropy" | "median";
  pivotOffset: number;
  /** Use the LITERAL HLG OETF (gamma below 1/12, log above) instead of the
   *  parametric toe/mid/shoulder curve. Ignores gain/width/shoulder/toe/pivot. */
  oetf?: boolean;
  /** Use the LITERAL HLG EOTF (inverse OETF → OOTF gamma) — the decode/display
   *  direction (suppresses the tail). Ignores the parametric knobs. */
  eotf?: boolean;
  /** EOTF only: nominal peak display luminance L_W (cd/m²) → OOTF gamma.
   *  Default 1000 (γ = 1.2). Lower = flatter (more diverse), higher = sharper. */
  lw?: number;
  /** Use the FULL HLG chain: OETF signal shape → OOTF scaling (applyHlgPipeline).
   *  γ from `lw`. Ignores the parametric knobs. */
  pipeline?: boolean;
  /** Pipeline only: α = max brightness — the top logit the OOTF scales everything
   *  under ("the most confidence we want"). Default 5. For the shaper, reused as
   *  `out_scale` (default 12). */
  maxBrightness?: number;
  /** Use the user-specified HLGShaper (windowed anchor → piecewise OETF with a
   *  cubic suppress-toe → OOTF → ×out_scale). `lw`→L_W, `maxBrightness`→out_scale. */
  shaper?: boolean;
  /** Shaper only: W = nats of headroom below the top logit that span the curve
   *  (`x = clamp((ℓ−ℓmax)/W + 1, 0, 1)`). Default 10. */
  window?: number;
  /** Shaper only: s_m — mid sharpness (how hard above-median tokens are elevated). */
  sM?: number;
  /** Shaper only: A — shoulder compression (how hard top-end confidence is tamed). */
  shoulderA?: number;
  /** Shaper only: target top-to-reference logit gap (out_scale auto-derives from this
   *  so it's decoupled from W). Default 15. */
  targetGap?: number;
  /** Shaper only: reference token nats below the top for the auto out_scale. Default 4. */
  refGap?: number;
  /** Shaper only: curve geometry (the pivots / toe / mid power). Default to the
   *  HLGShaper constants (xM 0.55, yM 0.5, xFloor 0.2, yFloor 0.18, p 2.0) when unset. */
  xM?: number; yM?: number; xFloor?: number; yFloor?: number; p?: number;
  /** Optional explicit mid gain m. Default: folds from temperature (m = 1/T),
   *  so temperature stays the contrast knob. An explicit value decouples mid
   *  contrast from temperature — needed to probe mid-boost while holding the
   *  model's recommended temperature fixed. */
  gain?: number;
}

export interface SamplerOptions {
  temperature?: number;
  topP?: number;
  topK?: number;
  /** min-p: keep tokens whose probability ≥ minP · p(top token). mlx-lm's
   *  `min_p`. Applied after top-p, before XTC/top-k (reference chain order). */
  minP?: number;
  /** Minimum number of tokens min-p may never filter out. Default 1. */
  minTokensToKeep?: number;
  /** XTC ("exclude top choices"): with this probability per step, drop every
   *  token above the threshold EXCEPT the least likely of them. */
  xtcProbability?: number;
  /** Probability a token must exceed to be an XTC removal candidate. [0, 0.5]. */
  xtcThreshold?: number;
  /** Token ids XTC never removes (mlx-lm's server passes EOS + "\n"). */
  xtcSpecialTokens?: number[];
  seed?: number;
  /** HLG tone-curve sampling. When enabled, replaces temperature's flat slope
   *  with the piecewise curve (temperature becomes the mid gain). Off/undefined
   *  ⇒ the plain temperature path, unchanged. docs/archive/hlg-sampling.md. */
  hlg?: HlgConfig;
  /** v2 log-prob transfer-curve sampler. When set, the drawn monotone curve
   *  REPLACES temperature+softmax entirely (stochastic, seeded) — see
   *  src/lab/curve/curve-sampler.ts. Identity curve ≡ temperature 1. */
  curve?: CurveParams;
}

export interface LogitsProcessorOptions {
  /** Additive per-token-id logit bias, applied before any penalty
   *  (mlx-lm's `logit_bias`: {tokenId: bias}). */
  logitBias?: Record<number, number>;
  repetitionPenalty?: number;
  repetitionContextSize?: number;
  /** OpenAI-style presence penalty: subtracted ONCE from a token's logit if it
   *  occurred at all in the recent window. May be negative. */
  presencePenalty?: number;
  presenceContextSize?: number;
  /** OpenAI-style frequency penalty: subtracted once PER OCCURRENCE of the
   *  token in the recent window. May be negative. */
  frequencyPenalty?: number;
  frequencyContextSize?: number;
}

/** logprobs [1, V] → sampled token array (uint32, shape [1]). */
export type Sampler = (logprobs: MlxArray, step: number) => MlxArray;

/** (deviceTokens [n] | null, logits [1, V]) → logits [1, V]. */
export type LogitsProcessor = (tokens: MlxArray | null, logits: MlxArray) => MlxArray;

/** Optional arrays captured from the same post-processor logprobs used to
 * sample a token. The caller controls readback timing and owns disposal. */
export interface StepExtras {
  sel: MlxArray | null;
  topIdx: MlxArray | null;
  topVals: MlxArray | null;
}

export type StepSample<T> = SampledToken<T, StepExtras>;

interface StepGrammar {
  readonly isTerminated: boolean;
  ready(): Promise<void>;
  applyMask(logits: MlxArray): MlxArray;
  accept(token: number): void;
}

export interface StepSamplerOptions extends SamplerOptions, LogitsProcessorOptions {
  grammar?: StepGrammar | null;
}

interface StepSamplerConfigBase {
  /** The grammar owner already awaited ready(), or this sampler must do it. */
  grammarWait: "external" | "before-sample";
  /** Update processor history in sample(), or let the decode loop commit later. */
  historyUpdate: "after-sample" | "manual";
  initialHistory?: readonly number[];
  captureSelectedLogprob?: boolean;
  captureTopLogprobs?: number;
  /** Eager-number mode can advance grammar after sampling. */
  acceptGrammar?: boolean;
  eosTokenIds?: readonly number[];
  /** Reuse a sampler already shared with a speculative draft source. */
  sampler?: Sampler;
}

export interface DeviceStepSamplerConfig extends StepSamplerConfigBase {
  tokenRepresentation: "device";
  grammarWait: "external";
}

export interface NumberStepSamplerConfig extends StepSamplerConfigBase {
  tokenRepresentation: "number";
  grammarWait: "before-sample";
}

export type DeviceStepSampler = SamplingSession<MlxArray, MlxArray, StepSample<MlxArray>>;
export type NumberStepSampler = SamplingSession<MlxArray, MlxArray, Promise<StepSample<number>>>;
