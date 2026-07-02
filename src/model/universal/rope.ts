// Universal rope factory — faithful port of mlx_lm/models/rope_utils.py
// (oracle venv, mlx-lm 0.31.3): initialize_rope with the default / linear /
// llama3 (Llama3RoPE) / yarn (YarnRoPE) / longrope (SuScaledRoPE) /
// proportional (ProportionalRoPE) variants.
//
// Porting discipline (three-level fidelity tree, L1): every frequency
// table is computed with the SAME mlx float32 ops the oracle uses at
// module init — not host-side float64 math — so the freqs bytes match the
// oracle's bit-for-bit. Host math (Math.log/floor/ceil) is used only where
// the oracle uses python-float math (yarn correction range, mscale, su
// scale), which is IEEE double on both sides.
//
// The existing runtime paths (ops.rope default, gemma4's proportional
// freqs) are untouched; this factory serves the universal (Tier-0) models.

import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";

/** Raw HF `rope_scaling` dict (values read exactly like the oracle). */
export type RopeScalingConfig = Record<string, unknown>;

const num = (v: unknown, fallback: number): number =>
  typeof v === "number" ? v : fallback;

const requireNum = (sc: RopeScalingConfig, key: string): number => {
  const v = sc[key];
  if (typeof v !== "number") throw new Error(`rope_scaling.${key} missing or not a number`);
  return v;
};

/** One rope instance (shared across layers — identical params ⇒ identical
 *  values). `apply` returns a NEW array; the caller owns disposal of both. */
export class UniversalRope {
  constructor(
    readonly dims: number,
    readonly traditional: boolean,
    /** Base for native fast_rope; null when `freqs` supplies the table. */
    readonly base: number | null,
    /** fast_rope scale (1/factor for "linear", else 1). */
    readonly scale: number,
    /** Precomputed frequency table (llama3/yarn/longrope/proportional). */
    readonly freqs: MlxArray | null,
    /** Pre-rope input scale on x[..., :dims] (yarn mscale / su scale). */
    readonly preScale: number,
    /** Apply preScale even when it is exactly 1.0 (SuScaledRoPE does; Yarn
     *  skips when mscale == 1.0). */
    readonly preScaleAlways: boolean,
  ) {}

  apply(x: MlxArray, offset: number): MlxArray {
    let input = x;
    let scaled: MlxArray | null = null;
    if (this.preScaleAlways || this.preScale !== 1.0) {
      // x[..., :dims] = preScale * x[..., :dims] (weak-scalar mul)
      const D = x.shape[x.shape.length - 1]!;
      if (this.dims === D) {
        scaled = ops.mulScalar(x, this.preScale);
      } else {
        const start = x.shape.map(() => 0);
        const stop = [...x.shape];
        stop[stop.length - 1] = this.dims;
        const head = x.slice(start, stop);
        const headScaled = ops.mulScalar(head, this.preScale);
        head.dispose();
        scaled = ops.sliceUpdate(x, headScaled, start, stop);
        headScaled.dispose();
      }
      input = scaled;
    }
    const out = ops.ropeScaled(
      input, this.dims, this.traditional, this.base, this.scale, offset, this.freqs,
    );
    scaled?.dispose();
    return out;
  }

  dispose(): void {
    this.freqs?.dispose();
  }
}

/** SmolLM3 NoPE: identity stand-in for disabled-rope layers. */
export class NoRope extends UniversalRope {
  constructor() {
    super(0, false, null, 1, null, 1, false);
  }
  override apply(x: MlxArray, _offset: number): MlxArray {
    // Return an owned copy-view so callers can dispose uniformly.
    return x.slice(x.shape.map(() => 0), [...x.shape]);
  }
}

/** `base ** (arange(0, dims, 2) / dims)` with the oracle's dtypes:
 *  int32 arange for llama3 (no explicit dtype in the source), float32
 *  arange for yarn/longrope. Integer÷integer divides to float32 in mlx,
 *  so both spellings compute the pow in f32. */
function baseFreqs(dims: number, base: number, arangeDtype: Dtype): MlxArray {
  const ar = ops.arange(0, dims, 2, arangeDtype);
  const dimsScalar = arangeDtype === Dtype.int32
    ? ops.fromInt32([dims], [])
    : MlxArray.fromFloat32(new Float32Array([dims]), []);
  const exps = ops.div(ar, dimsScalar); // → float32
  ar.dispose();
  dimsScalar.dispose();
  const baseScalar = ops.scalarLike(base, exps);
  const out = ops.pow(baseScalar, exps);
  baseScalar.dispose();
  exps.dispose();
  return out; // float32 [dims/2]
}

/** Llama3RoPE frequency table (rope_utils.py:74-108, verbatim). */
function llama3Freqs(dims: number, base: number, sc: RopeScalingConfig): MlxArray {
  const factor = requireNum(sc, "factor");
  const lowFreqFactor = num(sc.low_freq_factor, 1.0);
  const highFreqFactor = num(sc.high_freq_factor, 4.0);
  const oldContextLen = num(sc.original_max_position_embeddings, 8192);

  const lowFreqWavelen = oldContextLen / lowFreqFactor;
  const highFreqWavelen = oldContextLen / highFreqFactor;

  let freqs = baseFreqs(dims, base, Dtype.int32);
  const wavelens = ops.mulScalar(freqs, 2 * Math.PI);

  // freqs = where(wavelens > low_freq_wavelen, freqs * factor, freqs)
  const lfw = ops.scalarLike(lowFreqWavelen, wavelens);
  const gtLow = ops.less(lfw, wavelens);
  const freqsTimesFactor = ops.mulScalar(freqs, factor);
  const freqs1 = ops.where(gtLow, freqsTimesFactor, freqs);
  for (const a of [gtLow, freqsTimesFactor, freqs]) a.dispose();
  freqs = freqs1;

  // is_medium = (wavelens > high_freq_wavelen) & (wavelens < low_freq_wavelen)
  const hfw = ops.scalarLike(highFreqWavelen, wavelens);
  const gtHigh = ops.less(hfw, wavelens);
  const ltLow = ops.less(wavelens, lfw);
  const isMedium = ops.logicalAnd(gtHigh, ltLow);
  for (const a of [hfw, lfw, gtHigh, ltLow]) a.dispose();

  // smooth_factors = (old_context_len / wavelens - low) / (high - low)
  const oldScalar = ops.scalarLike(oldContextLen, wavelens);
  const oldOverWav = ops.div(oldScalar, wavelens);
  oldScalar.dispose();
  wavelens.dispose();
  const lowScalar = ops.scalarLike(lowFreqFactor, oldOverWav);
  const numArr = ops.sub(oldOverWav, lowScalar);
  oldOverWav.dispose();
  lowScalar.dispose();
  const denScalar = ops.scalarLike(highFreqFactor - lowFreqFactor, numArr);
  const smooth = ops.div(numArr, denScalar);
  numArr.dispose();
  denScalar.dispose();

  // smooth_freqs = freqs / ((1 - smooth) / factor + smooth)
  const one = ops.scalarLike(1, smooth);
  const oneMinus = ops.sub(one, smooth);
  one.dispose();
  const factorScalar = ops.scalarLike(factor, oneMinus);
  const scaledDown = ops.div(oneMinus, factorScalar);
  oneMinus.dispose();
  factorScalar.dispose();
  const denom = ops.add(scaledDown, smooth);
  scaledDown.dispose();
  smooth.dispose();
  const smoothFreqs = ops.div(freqs, denom);
  denom.dispose();

  const out = ops.where(isMedium, smoothFreqs, freqs);
  for (const a of [isMedium, smoothFreqs, freqs]) a.dispose();
  return out;
}

/** YarnRoPE (rope_utils.py:128-181, verbatim): returns [freqs, mscale]. */
function yarnFreqs(
  dims: number,
  base: number,
  scalingFactor: number,
  originalMaxPositionEmbeddings: number,
  betaFast: number,
  betaSlow: number,
  mscale: number,
  mscaleAllDim: number,
): [MlxArray, number] {
  const findCorrectionDim = (numRotations: number): number =>
    (dims * Math.log(originalMaxPositionEmbeddings / (numRotations * 2 * Math.PI))) /
    (2 * Math.log(base));
  let low = Math.floor(findCorrectionDim(betaFast));
  let high = Math.ceil(findCorrectionDim(betaSlow));
  low = Math.max(low, 0);
  high = Math.min(high, dims - 1);
  const getMscale = (scale: number, m: number): number =>
    scale <= 1 ? 1.0 : 0.1 * m * Math.log(scale) + 1.0;
  const outMscale =
    getMscale(scalingFactor, mscale) / getMscale(scalingFactor, mscaleAllDim);

  const freqExtra = baseFreqs(dims, base, Dtype.float32);
  const freqInter = ops.mulScalar(freqExtra, scalingFactor);

  // freq_mask = 1 - linear_ramp_mask(low, high, dims // 2)
  let maxVal = high;
  if (low === maxVal) maxVal += 0.001; // prevent singularity (oracle comment)
  const arangeHalf = ops.arange(0, Math.floor(dims / 2), 1, Dtype.float32);
  const minScalar = ops.scalarLike(low, arangeHalf);
  const shifted = ops.sub(arangeHalf, minScalar);
  arangeHalf.dispose();
  minScalar.dispose();
  const rangeScalar = ops.scalarLike(maxVal - low, shifted);
  const linear = ops.div(shifted, rangeScalar);
  shifted.dispose();
  rangeScalar.dispose();
  const lo = ops.scalarLike(0, linear);
  const hi = ops.scalarLike(1, linear);
  const ramp = ops.clip(linear, lo, hi);
  for (const a of [linear, lo, hi]) a.dispose();
  const one = ops.scalarLike(1, ramp);
  const freqMask = ops.sub(one, ramp);
  ramp.dispose();

  // freqs = (inter * extra) / (inter * mask + extra * (1 - mask))
  const numArr = ops.mul(freqInter, freqExtra);
  const interMasked = ops.mul(freqInter, freqMask);
  const oneMinusMask = ops.sub(one, freqMask);
  one.dispose();
  const extraMasked = ops.mul(freqExtra, oneMinusMask);
  oneMinusMask.dispose();
  const den = ops.add(interMasked, extraMasked);
  const freqs = ops.div(numArr, den);
  for (const a of [freqExtra, freqInter, freqMask, numArr, interMasked, extraMasked, den])
    a.dispose();
  return [freqs, outMscale];
}

/** SuScaledRoPE (rope_utils.py:10-71): [freqs, scale]. NOTE the oracle uses
 *  long_factor for ALL positions (short_factor is accepted and ignored). */
function suFreqsAndScale(
  dims: number,
  base: number,
  maxPositionEmbeddings: number,
  originalMaxPositionEmbeddings: number,
  longFactor: number[] | number,
  longMscale?: number,
): [MlxArray, number] {
  const freqs0 = baseFreqs(dims, base, Dtype.float32);
  const lf = Array.isArray(longFactor)
    ? MlxArray.fromFloat32(new Float32Array(longFactor), [longFactor.length])
    : MlxArray.fromFloat32(new Float32Array([longFactor]), []);
  const freqs = ops.mul(lf, freqs0);
  lf.dispose();
  freqs0.dispose();

  const factor = maxPositionEmbeddings / originalMaxPositionEmbeddings;
  const defaultScale =
    factor <= 1.0
      ? 1.0
      : Math.sqrt(1 + Math.log(factor) / Math.log(originalMaxPositionEmbeddings));
  // python: `long_mscale or default` — 0 is falsy there too.
  const scale = longMscale ? longMscale : defaultScale;
  return [freqs, scale];
}

/** ProportionalRoPE (rope_utils.py:199-232): rotate the first rotated_dims,
 *  ∞-freq (identity) padding for the rest. */
function proportionalFreqs(
  dims: number, rotatedDims: number, base: number, factor: number,
): MlxArray {
  if (rotatedDims > dims) throw new Error("rotated_dims should be smaller than dims");
  const ar = ops.arange(0, rotatedDims, 2, Dtype.float32);
  const dimsScalar = MlxArray.fromFloat32(new Float32Array([dims]), []);
  const exps = ops.div(ar, dimsScalar);
  ar.dispose();
  dimsScalar.dispose();
  const baseScalar = ops.scalarLike(base, exps);
  const powed = ops.pow(baseScalar, exps);
  baseScalar.dispose();
  exps.dispose();
  const scaled = ops.mulScalar(powed, factor);
  powed.dispose();
  const padLen = Math.floor((dims - rotatedDims) / 2);
  if (padLen === 0) return scaled;
  const pad = MlxArray.fromFloat32(
    new Float32Array(padLen).fill(Number.POSITIVE_INFINITY), [padLen],
  );
  const out = ops.concatAxis([scaled, pad], 0);
  scaled.dispose();
  pad.dispose();
  return out;
}

/** Port of rope_utils.initialize_rope — the shared entry every
 *  initialize_rope-style arch (llama, qwen2/3, olmo2, granite, …) uses. */
export function initializeRope(
  dims: number,
  base: number,
  traditional: boolean,
  scalingConfig: RopeScalingConfig | null,
  maxPositionEmbeddings: number | null,
): UniversalRope {
  const ropeType = scalingConfig
    ? String(scalingConfig.type ?? scalingConfig.rope_type ?? "default")
    : "default";

  if (ropeType === "default" || ropeType === "linear") {
    const scale = ropeType === "linear" ? 1 / requireNum(scalingConfig!, "factor") : 1.0;
    return new UniversalRope(dims, traditional, base, scale, null, 1, false);
  }

  if (ropeType === "llama3") {
    const freqs = llama3Freqs(dims, base, scalingConfig!);
    return new UniversalRope(dims, traditional, null, 1.0, freqs, 1, false);
  }

  if (ropeType === "yarn" || ropeType === "deepseek_yarn" || ropeType === "telechat3-yarn") {
    const sc = scalingConfig!;
    const [freqs, mscale] = yarnFreqs(
      dims,
      base,
      requireNum(sc, "factor"),
      num(sc.original_max_position_embeddings, 4096),
      num(sc.beta_fast, 32),
      num(sc.beta_slow, 1),
      num(sc.mscale, 1),
      num(sc.mscale_all_dim, 0),
    );
    // YarnRoPE scales x only when mscale != 1.0 (preScaleAlways=false).
    return new UniversalRope(dims, traditional, null, 1.0, freqs, mscale, false);
  }

  if (ropeType === "longrope") {
    const sc = scalingConfig!;
    const [freqs, scale] = suFreqsAndScale(
      dims,
      base,
      maxPositionEmbeddings ?? 131072,
      requireNum(sc, "original_max_position_embeddings"),
      (sc.long_factor as number[] | number | undefined) ?? 1.0,
    );
    // SuScaledRoPE hardcodes traditional=False and ALWAYS pre-scales.
    return new UniversalRope(dims, false, null, 1.0, freqs, scale, true);
  }

  if (ropeType === "proportional") {
    const sc = scalingConfig!;
    const rotatedDims = Math.floor(dims * num(sc.partial_rotary_factor, 1.0));
    const freqs = proportionalFreqs(dims, rotatedDims, base, num(sc.factor, 1.0));
    return new UniversalRope(dims, traditional, null, 1.0, freqs, 1, false);
  }

  throw new Error(`Unsupported RoPE type ${ropeType}`);
}

/** SuScaledRoPE constructed the phi3.py way (NOT via initialize_rope):
 *  original_max_position_embeddings comes from the TOP-LEVEL config, and
 *  rope_dim = head_dim * partial_rotary_factor. */
export function phi3SuRope(
  ropeDim: number,
  base: number,
  maxPositionEmbeddings: number,
  originalMaxPositionEmbeddings: number,
  longFactor: number[] | number,
): UniversalRope {
  const [freqs, scale] = suFreqsAndScale(
    ropeDim, base, maxPositionEmbeddings, originalMaxPositionEmbeddings, longFactor,
  );
  return new UniversalRope(ropeDim, false, null, 1.0, freqs, scale, true);
}
