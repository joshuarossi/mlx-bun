// AdamW optimizer over a flat list of MlxArray parameters.
//
// Port of mlx.optimizers.AdamW: decoupled weight decay (Loshchilov &
// Hutter), bias-corrected first/second moments. Each step REPLACES every
// param handle in place (old disposed, new array swapped in) and invokes the
// `write(i, newParam)` callback so the owning LoraWeights.a/b picks up the new
// handle for the next forward.
//
// Update (per param p with grad g, step t):
//   p   <- p - lr * wd * p               (decoupled weight decay)
//   m   <- β1·m + (1-β1)·g
//   v   <- β2·v + (1-β2)·g²
//   m̂  =  m / (1 - β1^t)
//   v̂  =  v / (1 - β2^t)
//   p   <- p - lr * m̂ / (√v̂ + ε)

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";

export interface AdamWOptions {
  lr: number;
  betas?: [number, number];
  eps?: number;
  weightDecay?: number;
}

export class AdamW {
  #params: MlxArray[];
  readonly #write: (i: number, p: MlxArray) => void;
  readonly #m: MlxArray[];
  readonly #v: MlxArray[];
  readonly #b1: number;
  readonly #b2: number;
  readonly #eps: number;
  readonly #wd: number;
  #lr: number;
  #t = 0;

  /** @param params live param arrays (e.g. flatParams(lora)).
   *  @param write callback to push a replaced param back into its owner
   *               (e.g. lw.a / lw.b). If omitted, only the internal array is
   *               updated (the caller must read params via `getParam`). */
  constructor(params: MlxArray[], opts: AdamWOptions, write?: (i: number, p: MlxArray) => void) {
    this.#params = [...params];
    this.#write = write ?? (() => {});
    this.#lr = opts.lr;
    [this.#b1, this.#b2] = opts.betas ?? [0.9, 0.999];
    this.#eps = opts.eps ?? 1e-8;
    this.#wd = opts.weightDecay ?? 0.01;
    // m, v as zeros like each param (handles 0-d params, where ops.zeros's
    // empty shape buffer would trip ptr()).
    this.#m = params.map(zerosLikeF32);
    this.#v = params.map(zerosLikeF32);
  }

  /** Current parameter array at index i (after the latest step). */
  getParam(i: number): MlxArray {
    return this.#params[i]!;
  }

  set lr(value: number) {
    this.#lr = value;
  }
  get lr(): number {
    return this.#lr;
  }

  get step_count(): number {
    return this.#t;
  }

  /** Apply one AdamW update. `grads[i]` is dL/dparams[i]. Takes ownership of
   *  the grads (they are disposed here). */
  step(grads: MlxArray[]): void {
    if (grads.length !== this.#params.length)
      throw new Error(`AdamW.step: ${grads.length} grads for ${this.#params.length} params`);
    this.#t += 1;
    const bc1 = 1 - Math.pow(this.#b1, this.#t);
    const bc2 = 1 - Math.pow(this.#b2, this.#t);

    for (let i = 0; i < this.#params.length; i++) {
      const p = this.#params[i]!;
      const g0 = grads[i]!;
      const g = g0.dtype === Dtype.float32 ? g0 : g0.astype(Dtype.float32);

      // m <- β1·m + (1-β1)·g
      const m0 = this.#m[i]!;
      const mScaled = ops.mulScalar(m0, this.#b1);
      const gScaled = ops.mulScalar(g, 1 - this.#b1);
      const m1 = ops.add(mScaled, gScaled);
      mScaled.dispose();
      gScaled.dispose();
      m0.dispose();
      this.#m[i] = m1;

      // v <- β2·v + (1-β2)·g²
      const v0 = this.#v[i]!;
      const g2 = ops.square(g);
      const vScaled = ops.mulScalar(v0, this.#b2);
      const g2Scaled = ops.mulScalar(g2, 1 - this.#b2);
      const v1 = ops.add(vScaled, g2Scaled);
      g2.dispose();
      vScaled.dispose();
      g2Scaled.dispose();
      v0.dispose();
      this.#v[i] = v1;

      // p <- p - lr·wd·p   (decoupled weight decay)
      let pNext = p;
      if (this.#wd !== 0) {
        const decay = ops.mulScalar(p, this.#lr * this.#wd);
        pNext = ops.sub(p, decay);
        decay.dispose();
      }

      // m̂ / (√v̂ + ε)
      const mHat = ops.mulScalar(m1, 1 / bc1);
      const vHat = ops.mulScalar(v1, 1 / bc2);
      const sqrtV = ops.sqrt(vHat);
      const eps = ops.scalarLike(this.#eps, sqrtV);
      const denom = ops.add(sqrtV, eps);
      const update = ops.div(mHat, denom);
      const lrUpdate = ops.mulScalar(update, this.#lr);
      const pFinal = ops.sub(pNext, lrUpdate);

      for (const a of [mHat, vHat, sqrtV, eps, denom, update, lrUpdate]) a.dispose();
      if (pNext !== p) pNext.dispose();
      if (g !== g0) g.dispose();
      g0.dispose();
      p.dispose();

      this.#params[i] = pFinal;
      this.#write(i, pFinal);
    }
  }

  /** Eval all optimizer state + params (call once per step after `step`). */
  evalState(): void {
    ops.evalAll([...this.#params, ...this.#m, ...this.#v]);
  }

  dispose(): void {
    for (const a of this.#m) a.dispose();
    for (const a of this.#v) a.dispose();
    // params are owned by their LoraWeights; not disposed here.
  }
}

/** Zeros with the same shape as `p`, as float32. Uses mul-by-0 so 0-d
 *  params work (ops.zeros's empty shape buffer trips ptr()). */
function zerosLikeF32(p: MlxArray): MlxArray {
  const f = p.dtype === Dtype.float32 ? p : p.astype(Dtype.float32);
  const z = ops.mulScalar(f, 0);
  if (f !== p) f.dispose();
  return z;
}

/** Linear warmup → cosine decay schedule (to 10% of peak), used by DPO.
 *  Returns lr for a 1-based step. Port of dpo.py lr_schedule. */
export function warmupCosineSchedule(
  peakLr: number,
  warmupIters: number,
  totalIters: number,
): (step: number) => number {
  const minLr = 0.1 * peakLr;
  const warmup = Math.max(warmupIters, 1);
  const remaining = Math.max(totalIters - warmupIters, 1);
  return (step: number) => {
    // step is 1-based; convert to 0-based for the ramp like the reference.
    const s = step - 1;
    if (s < warmup) return Math.min(peakLr, (peakLr * (s + 1)) / warmup);
    const progress = Math.max(0, Math.min(1, (s - warmup) / remaining));
    return minLr + 0.5 * (peakLr - minLr) * (1 + Math.cos(Math.PI * progress));
  };
}
