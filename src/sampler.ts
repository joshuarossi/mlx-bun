// Sampling — port of mlx-lm's sample_utils.make_sampler /
// make_logits_processors (temperature, top-p, top-k, repetition penalty).
// All filtering happens on-device; only the chosen token id crosses to JS.
// Seeded: each step derives a fresh key from (seed, step) so runs are
// reproducible without sharing global RNG state.

import { Dtype } from "./mlx/ffi";
import { MlxArray } from "./mlx/array";
import * as ops from "./mlx/ops";

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
  seed?: number;
  /** HLG tone-curve sampling. When enabled, replaces temperature's flat slope
   *  with the piecewise curve (temperature becomes the mid gain). Off/undefined
   *  ⇒ the plain temperature path, unchanged. docs/design/hlg-sampling.md. */
  hlg?: HlgConfig;
}

export interface LogitsProcessorOptions {
  repetitionPenalty?: number;
  repetitionContextSize?: number;
}

/** logprobs [1, V] → sampled token array (uint32, shape [1]). */
export type Sampler = (logprobs: MlxArray, step: number) => MlxArray;

/** (deviceTokens [n] | null, logits [1, V]) → logits [1, V]. */
export type LogitsProcessor = (tokens: MlxArray | null, logits: MlxArray) => MlxArray;

const GOLDEN = 0x9e3779b97f4a7c15n;

function stepKey(seed: number, step: number): MlxArray {
  const mixed = (BigInt(seed) ^ ((BigInt(step) + 1n) * GOLDEN)) & 0xffffffffffffffffn;
  return ops.randomKey(mixed);
}

function negInfLike(a: MlxArray): MlxArray {
  return ops.scalarLike(-Infinity, a);
}

/** apply_top_p: keep the smallest set of tokens whose cumulative
 *  probability exceeds top_p; others → -inf. */
function applyTopP(lp: MlxArray, topP: number): MlxArray {
  const probs = ops.exp(lp);
  const sortedIdx = ops.argsortAxis(lp, -1);
  const sortedProbs = ops.takeAlongAxis(probs, sortedIdx, -1);
  const cum = ops.cumsum(sortedProbs, -1);
  // scatter arange back through sortedIdx to invert the permutation
  const V = lp.shape[lp.shape.length - 1]!;
  const zerosIdx = ops.zeros(sortedIdx.shape, sortedIdx.dtype);
  const ar = ops.arange(0, V, 1, sortedIdx.dtype);
  const arB = ops.reshape(ar, sortedIdx.shape);
  const inverse = ops.putAlongAxis(zerosIdx, sortedIdx, arB, -1);
  const cumOrig = ops.takeAlongAxis(cum, inverse, -1);
  const threshold = ops.scalarLike(1 - topP, cumOrig);
  const keep = ops.less(threshold, cumOrig); // cum > 1 - topP
  const ninf = negInfLike(lp);
  const out = ops.where(keep, lp, ninf);
  for (const a of [probs, sortedIdx, sortedProbs, cum, zerosIdx, ar, arB, inverse, cumOrig, threshold, keep, ninf])
    a.dispose();
  return out;
}

/** apply_top_k: all but the k highest logprobs → -inf. */
function applyTopK(lp: MlxArray, topK: number): MlxArray {
  const V = lp.shape[lp.shape.length - 1]!;
  const negLp = ops.neg(lp);
  const part = ops.argpartitionAxis(negLp, topK - 1, -1);
  const maskIdx = part.slice([0, topK], [1, V]);
  const ninf = negInfLike(lp);
  const out = ops.putAlongAxis(lp, maskIdx, ninf, -1);
  for (const a of [negLp, part, maskIdx, ninf]) a.dispose();
  return out;
}

/** HLG sampling parameters — a piecewise tone curve on the logprobs.
 *  See docs/design/hlg-sampling.md. Knobs are in nats (the logprob unit). */
export interface HlgParams {
  /** m — mid-region slope. Folds temperature: m = 1/temperature. */
  gain: number;
  /** w — half-width of the linear mid region. Infinity ⇒ no rolloff (pure temperature). */
  width: number;
  /** β_h — highlight rolloff scale. ≤ 0 ⇒ no shoulder (highlights stay linear). */
  shoulder: number;
  /** β_t — shadow rolloff scale. ≤ 0 ⇒ no toe (shadows stay linear). */
  toe: number;
  /** pivot (middle grey) placement — changes where the curve centers, hence its
   *  shape. "top": μ = max(ℓ) − offset. "entropy": μ = Σp·ℓ = −H (center of mass
   *  in tonal space). "median": μ = the logprob at the 50% cumulative-mass
   *  boundary (auto-levels). */
  pivot?: "top" | "entropy" | "median";
  /** shift applied to the pivot base: μ = base − pivotOffset. */
  pivotOffset?: number;
}

const HLG_LOG_EPS = 1e-9;

/** Pivot (middle grey) μ_base for the tone curve, in logprob units — the same
 *  curve, centered three different ways. Operates on the full logprob vector. */
function hlgPivotBase(
  lp: MlxArray,
  mode: "top" | "entropy" | "median",
  k: <T extends MlxArray>(a: T) => T,
): MlxArray {
  if (mode === "entropy") {
    // center of mass in tonal space: μ = Σ p·ℓ = −H  (p = exp(ℓ); ℓ are logprobs)
    const probs = k(ops.exp(lp));
    return k(ops.sumAxis(k(ops.mul(probs, lp)), -1, true));
  }
  if (mode === "median") {
    // logprob at the 50% cumulative-mass boundary (auto-levels / histogram median)
    const probs = k(ops.exp(lp));
    const idxDesc = k(ops.argsortAxis(k(ops.neg(lp)), -1)); // ascending of −ℓ = ℓ descending
    const sortedProbs = k(ops.takeAlongAxis(probs, idxDesc, -1));
    const sortedLp = k(ops.takeAlongAxis(lp, idxDesc, -1));
    const cum = k(ops.cumsum(sortedProbs, -1));
    const keep = k(ops.greaterEqual(cum, k(ops.scalarLike(0.5, cum))));
    const masked = k(ops.where(keep, sortedLp, k(ops.scalarLike(-Infinity, sortedLp))));
    return k(ops.maxAxis(masked, -1, true)); // first crossover = max logprob of the ≥0.5 suffix
  }
  return k(ops.maxAxis(lp, -1, true)); // "top": the peak
}

/** Remap logprobs through the centered curve g(z), z = ℓ − μ:
 *    toe (z < −w):   −m·w − m·β_t·ln(1 + (−z − w)/β_t)   gentle shadow rolloff
 *    mid (|z| ≤ w):   m·z                                 contrast gain
 *    shoulder(z > w): m·w + m·β_h·ln(1 + ( z − w)/β_h)    highlight rolloff
 *  Monotone in ℓ ⇒ ranking-preserving (argmax unchanged). With width = ∞ (or
 *  β_h, β_t ≤ 0) it returns mulScalar(lp, m) — temperature T = 1/m — bit-exact
 *  by construction (the same op the temperature path uses). `-inf` (masked)
 *  tokens map to `-inf`. */
export function applyHlg(lp: MlxArray, p: HlgParams): MlxArray {
  const m = p.gain;
  const hasShoulder = Number.isFinite(p.width) && p.shoulder > 0;
  const hasToe = Number.isFinite(p.width) && p.toe > 0;
  // No-rolloff regime ≡ temperature: identical op to the temperature sampler.
  if (!hasShoulder && !hasToe) return ops.mulScalar(lp, m);

  const w = p.width;
  const off = p.pivotOffset ?? 0;
  const tmp: MlxArray[] = [];
  const k = <T extends MlxArray>(a: T): T => {
    tmp.push(a);
    return a;
  };

  // pivot μ = base(mode) − off ; centered coordinate z = ℓ − μ
  const base = hlgPivotBase(lp, p.pivot ?? "top", k);
  const mu = k(ops.sub(base, k(ops.scalarLike(off, base))));
  const z = k(ops.sub(lp, mu));
  const wC = k(ops.scalarLike(w, lp));
  let g: MlxArray = k(ops.mulScalar(z, m)); // mid: m·z

  if (hasShoulder) {
    const bh = p.shoulder;
    const inner = k(ops.add(k(ops.scalarLike(1, lp)), k(ops.mulScalar(k(ops.sub(z, wC)), 1 / bh))));
    const clamped = k(ops.maximum(inner, k(ops.scalarLike(HLG_LOG_EPS, lp))));
    const shoulder = k(ops.add(k(ops.scalarLike(m * w, lp)), k(ops.mulScalar(k(ops.log(clamped)), m * bh))));
    g = k(ops.where(k(ops.greaterEqual(z, wC)), shoulder, g));
  }
  if (hasToe) {
    const bt = p.toe;
    const negz = k(ops.neg(z));
    const inner = k(ops.add(k(ops.scalarLike(1, lp)), k(ops.mulScalar(k(ops.sub(negz, wC)), 1 / bt))));
    const clamped = k(ops.maximum(inner, k(ops.scalarLike(HLG_LOG_EPS, lp))));
    const toe = k(ops.sub(k(ops.scalarLike(-m * w, lp)), k(ops.mulScalar(k(ops.log(clamped)), m * bt))));
    g = k(ops.where(k(ops.less(z, k(ops.scalarLike(-w, lp)))), toe, g));
  }

  for (const a of tmp) if (a !== g) a.dispose();
  return g;
}

// Literal HLG OETF (ARIB STD-B67 / ITU-R BT.2100) — the actual transfer
// function, exact constants. Input L = p/p_max ∈ (0,1] (exposure-normalized: the
// top token is reference white). Output V ∈ [0,1]:
//   V = √3 · √L                for 0 ≤ L ≤ 1/12   (gamma/sqrt: shadows → 0 softly)
//   V = a·ln(12L − b) + c      for 1/12 < L ≤ 1    (log: highlights compressed)
// We sample ∝ V by feeding log(V) to the categorical draw. Monotone in ℓ ⇒
// ranking-preserving. No knobs — this is HLG itself.
const HLG_A = 0.17883277;
const HLG_B = 0.28466892; // 1 − 4a
const HLG_C = 0.55991073; // 0.5 − a·ln(4a)
const HLG_SQRT3 = Math.sqrt(3);
const HLG_KNEE = 1 / 12;

export function applyHlgOetf(lp: MlxArray): MlxArray {
  const tmp: MlxArray[] = [];
  const k = <T extends MlxArray>(a: T): T => {
    tmp.push(a);
    return a;
  };

  // L = p / p_max = exp(ℓ − ℓmax) ∈ (0, 1]
  const lmax = k(ops.maxAxis(lp, -1, true));
  const L = k(ops.exp(k(ops.sub(lp, lmax))));

  // lower (L ≤ 1/12): V = √3 · √L
  const lo = k(ops.mulScalar(k(ops.sqrt(L)), HLG_SQRT3));
  // upper (L > 1/12): V = a·ln(12L − b) + c   (clamp the arg > 0 for the unused lane)
  const arg = k(ops.maximum(k(ops.sub(k(ops.mulScalar(L, 12)), k(ops.scalarLike(HLG_B, L)))), k(ops.scalarLike(HLG_LOG_EPS, L))));
  const hi = k(ops.add(k(ops.mulScalar(k(ops.log(arg)), HLG_A)), k(ops.scalarLike(HLG_C, L))));
  const V = k(ops.where(k(ops.greaterEqual(L, k(ops.scalarLike(HLG_KNEE, L)))), hi, lo));

  // sample ∝ V  →  logits = log(V)
  const out = ops.log(k(ops.maximum(V, k(ops.scalarLike(HLG_LOG_EPS, V)))));
  for (const a of tmp) a.dispose();
  return out;
}

/** OOTF system gamma from nominal peak display luminance L_W (cd/m²).
 *  γ = 1.2 + 0.42·log10(L_W/1000); γ = 1.2 exactly at L_W = 1000. */
export function hlgGammaForLw(lw: number): number {
  return 1.2 + 0.42 * Math.log10(lw / 1000);
}

// Literal HLG EOTF (signal → display linear) = inverse OETF then OOTF — the
// DECODE direction. Treat p/p_max as the signal E'. The inverse OETF squares the
// lower half (E = E'²/3) so the tail is SUPPRESSED (the opposite of the OETF,
// which expands it). The OOTF on a single-"pixel" (grayscale) distribution has
// no colour channels for luminance to couple, so it reduces exactly to a gamma
// power law E^γ — i.e. temperature. Sample ∝ E^γ ⇒ logits = γ·log(E).
export function applyHlgEotf(lp: MlxArray, gamma: number): MlxArray {
  const tmp: MlxArray[] = [];
  const k = <T extends MlxArray>(a: T): T => {
    tmp.push(a);
    return a;
  };

  const d = k(ops.sub(lp, k(ops.maxAxis(lp, -1, true)))); // ℓ − ℓmax ≤ 0
  const Ep = k(ops.exp(d)); // signal E' = p/p_max ∈ (0, 1]
  // log E from the inverse OETF, computed stably per branch (the deep tail
  // underflows if E is formed directly, so the lower branch stays in log-space):
  //   E' ≤ 1/2:  E = E'²/3            → log E = 2·(ℓ−ℓmax) − ln3   (exact)
  //   E' > 1/2:  E = (exp((E'−c)/a)+b)/12 → log E = log(that)      (well-conditioned)
  const logElo = k(ops.sub(k(ops.mulScalar(d, 2)), k(ops.scalarLike(Math.log(3), d))));
  const hiArg = k(ops.exp(k(ops.mulScalar(k(ops.sub(Ep, k(ops.scalarLike(HLG_C, Ep)))), 1 / HLG_A))));
  const hiE = k(ops.mulScalar(k(ops.add(hiArg, k(ops.scalarLike(HLG_B, Ep)))), 1 / 12));
  const logEhi = k(ops.log(hiE));
  const logE = k(ops.where(k(ops.greaterEqual(Ep, k(ops.scalarLike(0.5, Ep)))), logEhi, logElo));
  // OOTF (grayscale) → gamma: sample ∝ E^γ ⇒ logits = γ·log(E)
  const out = ops.mulScalar(logE, gamma);
  for (const a of tmp) a.dispose();
  return out;
}

// The FULL HLG chain: OETF signal shape, THEN OOTF scaling.
//   1. E  = p/p_max ∈ (0,1]               (top token = the max-brightness reference)
//   2. E' = √(3E)         for E ≤ 1/12    (gamma/√ toe below the knee)
//        = a·ln(12E−b)+c  for E > 1/12    (log highlights above the knee)
//   3. R_d = α · E'^γ                      (OOTF: α = max brightness, scales everything
//                                           under it; γ = 1.2+0.42·log10(L_W/1000))
// R_d are the final logits → categorical. α > 0 ⇒ monotone (ranking preserved).
export function applyHlgPipeline(lp: MlxArray, alpha: number, gamma: number): MlxArray {
  const tmp: MlxArray[] = [];
  const k = <T extends MlxArray>(a: T): T => {
    tmp.push(a);
    return a;
  };

  // 1. E = p/p_max ∈ (0,1]
  const E = k(ops.exp(k(ops.sub(lp, k(ops.maxAxis(lp, -1, true))))));
  // 2. OETF: √(3E) below the knee, a·ln(12E−b)+c above
  const lo = k(ops.sqrt(k(ops.mulScalar(E, 3))));
  const arg = k(ops.maximum(k(ops.sub(k(ops.mulScalar(E, 12)), k(ops.scalarLike(HLG_B, E)))), k(ops.scalarLike(HLG_LOG_EPS, E))));
  const hi = k(ops.add(k(ops.mulScalar(k(ops.log(arg)), HLG_A)), k(ops.scalarLike(HLG_C, E))));
  const Eprime = k(ops.where(k(ops.greaterEqual(E, k(ops.scalarLike(HLG_KNEE, E)))), hi, lo));
  // 3. OOTF: R_d = α · E'^γ = α · exp(γ·log E')
  const EpGamma = k(ops.exp(k(ops.mulScalar(k(ops.log(k(ops.maximum(Eprime, k(ops.scalarLike(HLG_LOG_EPS, Eprime)))))), gamma))));
  const out = ops.mulScalar(EpGamma, alpha);
  for (const a of tmp) a.dispose();
  return out;
}

// ── User-specified HLGShaper (windowed-anchor input) ────────────────────────
// logit → windowed-anchor signal x∈[0,1] (top W nats span the curve; min-max
// over the 262k vocab dumped every candidate into the shoulder, so we anchor at
// the top instead) → piecewise OETF (log shoulder above x_m, power mid, CUBIC
// toe that suppresses to 0) → OOTF (normalize to peak, ^γ) → ×out_scale →
// softmax. Geometry constants derived once from the default knobs, exactly as
// HLGShaper.__init__ does (cubic toe coeffs from a 2×2 solve).
export interface HlgShaperParams {
  lw?: number; // L_W (cd/m²) → OOTF γ
  outScale?: number; // explicit override; default auto-derived from targetGap/refGap
  targetGap?: number; // desired top-1-to-reference final-logit gap (sets sharpness, W-independent)
  refGap?: number; // reference token sits this many nats below the top
  window?: number; // W: nats below the top spanning the curve
  xM?: number; yM?: number; xFloor?: number; yFloor?: number; p?: number;
  sM?: number; // mid sharpness — how hard above-median tokens are elevated
  A?: number; // shoulder compression — how hard confidence is tamed
}

export function applyHlgShaper(lp: MlxArray, opts: HlgShaperParams = {}): MlxArray {
  const lw = opts.lw ?? 1200, window = opts.window ?? 10;
  const xM = opts.xM ?? 0.55, yM = opts.yM ?? 0.5, xFloor = opts.xFloor ?? 0.2, yFloor = opts.yFloor ?? 0.18;
  const p = opts.p ?? 2.0, sM = opts.sM ?? 0.7, A = opts.A ?? 0.35;
  const targetGap = opts.targetGap ?? 15, refGap = opts.refGap ?? 4;
  // geometry derived per call (cheap scalar math), exactly as HLGShaper.__init__
  const dxf = xM - xFloor;
  const kc = (yM - sM * dxf - yFloor) / Math.pow(dxf, p); // mid reaches y_floor
  const sFloor = sM + kc * p * Math.pow(dxf, p - 1); // mid slope at the toe join
  const det = -Math.pow(xFloor, 4); // solve [[xf³,xf²],[3xf²,2xf]]·[e,f]=[y_floor,s_floor]
  const ec = (yFloor * (2 * xFloor) - xFloor ** 2 * sFloor) / det;
  const fc = (xFloor ** 3 * sFloor - yFloor * (3 * xFloor ** 2)) / det;
  const yPeak = yM + A * Math.log(1 + (sM / A) * (1 - xM));
  const gamma = 1.2 + 0.42 * Math.log10(Math.max(lw, 1e-3) / 1000);

  // out_scale AUTO-derived so the top-1-to-reference final-logit gap = targetGap,
  // INDEPENDENT of W — decouples the two knobs so W is a clean 1-D sweep. The
  // reference token sits refGap nats below the top; its post-shape value is the
  // scalar curve evaluated in JS (no device cost). Calibrated so W=5 ⇒ os ≈ 18.
  const oetfS = (xx: number): number => {
    let yy: number;
    if (xx >= xM) yy = yM + A * Math.log(Math.max(1 + (sM / A) * (xx - xM), 1e-9));
    else if (xx >= xFloor) yy = yM - sM * (xM - xx) - kc * Math.pow(Math.max(xM - xx, 0), p);
    else yy = ec * xx ** 3 + fc * xx ** 2;
    return Math.max(yy, 0);
  };
  const shapeS = (xx: number): number => Math.pow(Math.max(oetfS(xx) / yPeak, 1e-9), gamma);
  const xRef = Math.max(0, Math.min(1, 1 - refGap / window));
  const outScale = opts.outScale ?? targetGap / Math.max(1e-6, 1 - shapeS(xRef));

  const tmp: MlxArray[] = [];
  const k = <T extends MlxArray>(a: T): T => {
    tmp.push(a);
    return a;
  };
  const C = (v: number, like: MlxArray): MlxArray => k(ops.scalarLike(v, like));

  // x = clamp((ℓ − ℓmax)/W + 1, 0, 1) — windowed anchor at the top
  const lmax = k(ops.maxAxis(lp, -1, true));
  const x = k(ops.clip(k(ops.add(k(ops.mulScalar(k(ops.sub(lp, lmax)), 1 / window)), C(1, lp))), C(0, lp), C(1, lp)));

  // OETF: up (x≥x_m) log shoulder, mid power, toe (x<x_floor) cubic suppress
  const upArg = k(ops.maximum(k(ops.add(C(1, x), k(ops.mulScalar(k(ops.sub(x, C(xM, x))), sM / A)))), C(1e-9, x)));
  const up = k(ops.add(C(yM, x), k(ops.mulScalar(k(ops.log(upArg)), A))));
  const dm = k(ops.sub(C(xM, x), x));
  const dmPow = k(ops.exp(k(ops.mulScalar(k(ops.log(k(ops.maximum(dm, C(1e-9, x))))), p))));
  const mid = k(ops.sub(k(ops.sub(C(yM, x), k(ops.mulScalar(dm, sM)))), k(ops.mulScalar(dmPow, kc))));
  const x2 = k(ops.square(x));
  const x3 = k(ops.mul(x, x2));
  const toe = k(ops.add(k(ops.mulScalar(x3, ec)), k(ops.mulScalar(x2, fc))));
  const upMid = k(ops.where(k(ops.greaterEqual(x, C(xM, x))), up, mid));
  const y = k(ops.maximum(k(ops.where(k(ops.greaterEqual(x, C(xFloor, x))), upMid, toe)), C(0, x)));

  // OOTF: r = (max(y/y_peak, 1e-9))^γ ; then softmax(r · out_scale)
  const yn = k(ops.maximum(k(ops.mulScalar(y, 1 / yPeak)), C(1e-9, y)));
  const r = k(ops.exp(k(ops.mulScalar(k(ops.log(yn)), gamma))));
  const out = ops.mulScalar(r, outScale);
  for (const a of tmp) a.dispose();
  return out;
}

export function makeSampler(opts: SamplerOptions = {}): Sampler {
  const { temperature = 0, topP = 0, topK = 0, seed = 0, hlg } = opts;

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

  return (lp, step) => {
    let cur = lp;
    const owned: MlxArray[] = [];
    if (topP > 0 && topP < 1) { cur = applyTopP(cur, topP); owned.push(cur); }
    if (topK > 0) { cur = applyTopK(cur, topK); owned.push(cur); }
    const scaled = ops.mulScalar(cur, 1 / temperature);
    const key = stepKey(seed, step);
    const tok = ops.randomCategorical(scaled, key);
    scaled.dispose();
    key.dispose();
    for (const a of owned) a.dispose();
    return tok;
  };
}

export function makeLogitsProcessors(opts: LogitsProcessorOptions = {}): LogitsProcessor[] {
  const out: LogitsProcessor[] = [];
  const { repetitionPenalty, repetitionContextSize = 20 } = opts;

  if (repetitionPenalty && repetitionPenalty !== 0) {
    if (repetitionPenalty < 0)
      throw new Error("repetitionPenalty must be non-negative");
    out.push((tokens, logits) => {
      if (!tokens) return logits;
      const n = tokens.shape[0]!;
      if (n === 0) return logits;
      const start = Math.max(0, n - repetitionContextSize);
      const recent = tokens.slice([start], [n]);
      const idx = ops.reshape(recent, [1, n - start]);
      const selected = ops.takeAlongAxis(logits, idx, -1);
      const zero = ops.scalarLike(0, selected);
      const isNeg = ops.less(selected, zero);
      const timesP = ops.mulScalar(selected, repetitionPenalty);
      const pen = ops.scalarLike(repetitionPenalty, selected);
      const overP = ops.div(selected, pen);
      const penalized = ops.where(isNeg, timesP, overP);
      const updated = ops.putAlongAxis(logits, idx, penalized, -1);
      for (const a of [recent, idx, selected, zero, isNeg, timesP, pen, overP, penalized])
        a.dispose();
      return updated;
    });
  }
  return out;
}

/** logits [1, V] → logprobs [1, V] (logits - logsumexp). */
export function toLogprobs(logits: MlxArray): MlxArray {
  const lse = ops.logsumexpAxis(logits, -1, true);
  const out = ops.sub(logits, lse);
  lse.dispose();
  return out;
}

export { Dtype };
