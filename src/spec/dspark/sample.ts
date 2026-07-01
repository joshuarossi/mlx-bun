// Sampling support for DSpark speculative decoding at temperature > 0.
//
// Lossless speculative SAMPLING (Leviathan/Chen): a drafted token x sampled
// from draft dist q is accepted w.p. min(1, p(x)/q(x)) where p is the target
// dist; on rejection x is resampled from the residual norm(relu(p − q)); if the
// whole block is accepted a bonus token is sampled from p. The emitted stream is
// then distributed EXACTLY as if the target sampled token-by-token from p —
// independent of q (q only moves the acceptance rate τ). This is the
// temperature analog of the greedy longest-prefix gate.
//
// `p` and `q` must be the SAME processing applied to target/draft logits — so we
// reuse the server sampler's exact top-p/top-k/temperature path (sampler.ts).
// HLG/curve samplers are out of scope here; the caller rejects them.

import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";
import { applyTopP, applyTopK, toLogprobs } from "../../sampler";

export interface DSparkSampleConfig {
  /** temperature > 0 enables sampling; 0 ⇒ greedy (handled by the caller). */
  temperature: number;
  topP?: number;
  topK?: number;
  seed?: number;
}

const GOLDEN = 0x9e3779b97f4a7c15n;
const U64 = 0xffffffffffffffffn;

/** Seeded stream of mlx random keys — reproducible draws without sharing global
 *  RNG state (same derivation as sampler.ts stepKey). */
export class KeyStream {
  #seed: bigint;
  #ctr = 0;
  constructor(seed = 0) { this.#seed = BigInt(seed >>> 0); }
  next(): MlxArray {
    const mixed = (this.#seed ^ ((BigInt(this.#ctr++) + 1n) * GOLDEN)) & U64;
    return ops.randomKey(mixed);
  }
}

/**
 * Processed categorical logits for one position: logits [1,V] → masked +
 * temperature-scaled logits [1,V] (the input to randomCategorical;
 * softmax(·) is the sampling distribution). Mirrors makeSampler's top-p/top-k/
 * temperature path exactly. temperature must be > 0.
 */
export function processLogits(logits: MlxArray, cfg: DSparkSampleConfig): MlxArray {
  if (cfg.temperature <= 0) throw new Error("processLogits requires temperature > 0");
  const lp = toLogprobs(logits); // [1,V]
  let cur = lp;
  const owned: MlxArray[] = [lp];
  if (cfg.topP && cfg.topP > 0 && cfg.topP < 1) { cur = applyTopP(cur, cfg.topP); owned.push(cur); }
  if (cfg.topK && cfg.topK > 0) { cur = applyTopK(cur, cfg.topK); owned.push(cur); }
  const scaled = ops.mulScalar(cur, 1 / cfg.temperature);
  for (const a of owned) a.dispose();
  return scaled;
}

/** softmax of processed logits → probability vector [1,V]. */
export function probsOf(scaled: MlxArray): MlxArray {
  return ops.softmaxAxis(scaled, 1, true);
}

/** Sample one token id from processed logits [1,V] (∝ softmax). */
export function sampleToken(scaled: MlxArray, key: MlxArray): number {
  const t = ops.randomCategorical(scaled, key); // [1] uint32
  const id = ops.itemUint32(t);
  t.dispose();
  return id;
}

/** Probability mass a [1,V] distribution assigns to token id (host scalar). */
export function probAtToken(probs: MlxArray, id: number): number {
  const sl = probs.slice([0, id], [1, id + 1]); // [1,1]
  const v = sl.toFloat32()[0]!;
  sl.dispose();
  return v;
}

/** Sample one token from the residual norm(relu(p − q)) over [1,V]. Falls back
 *  to sampling from p if the residual is degenerate (mass ≈ 0). */
export function sampleResidual(p: MlxArray, q: MlxArray, key: MlxArray): number {
  const diff = ops.sub(p, q);
  const zero = MlxArray.fromFloat32(new Float32Array([0]), []);
  const relu = ops.maximum(diff, zero);
  diff.dispose(); zero.dispose();
  const mass = ops.sumAxis(relu, 1, true); // [1,1]
  const massV = mass.toFloat32()[0]!;
  if (!(massV > 1e-12)) {
    // degenerate (p ⪯ q everywhere) — sample from p directly.
    relu.dispose(); mass.dispose();
    const lp = ops.log(p);
    const id = sampleToken(lp, key);
    lp.dispose();
    return id;
  }
  const resid = ops.div(relu, mass); // normalized [1,V]
  relu.dispose(); mass.dispose();
  // randomCategorical samples ∝ exp(logits) → feed log(resid).
  const eps = MlxArray.fromFloat32(new Float32Array([1e-30]), []);
  const safe = ops.add(resid, eps);
  resid.dispose(); eps.dispose();
  const logits = ops.log(safe);
  safe.dispose();
  const id = sampleToken(logits, key);
  logits.dispose();
  return id;
}

export { Dtype };
