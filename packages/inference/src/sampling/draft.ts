// Sampling support for the DSpark/DFlash drafter at temperature > 0: the
// drafter samples each position from the server sampler's exact
// top-p/top-k/temperature distribution (sampler.ts), using a seeded key stream
// that does not touch global RNG state. HLG/curve samplers are out of scope;
// the caller rejects them.

import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { applyTopP, applyTopK, toLogprobs } from "./index";
import { stepKey } from "./sampler";

export interface DSparkSampleConfig {
  /** temperature > 0 enables sampling; 0 ⇒ greedy (handled by the caller). */
  temperature: number;
  topP?: number;
  topK?: number;
  seed?: number;
}

/** Seeded stream of mlx random keys — reproducible draws without sharing global
 *  RNG state: draw n is `stepKey(seed >>> 0, n)`. */
export class KeyStream {
  #seed: number;
  #ctr = 0;
  constructor(seed = 0) { this.#seed = seed >>> 0; }
  next(): MlxArray {
    return stepKey(this.#seed, this.#ctr++);
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

/** Sample one token id from processed logits [1,V] (∝ softmax). */
export function sampleToken(scaled: MlxArray, key: MlxArray): number {
  const t = ops.randomCategorical(scaled, key); // [1] uint32
  const id = ops.itemUint32(t);
  t.dispose();
  return id;
}
