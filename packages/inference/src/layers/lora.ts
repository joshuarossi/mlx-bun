import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

/** Per-adapter LoRA weights for one linear (mlx-lm LoRALinear shapes:
 *  a [in_features, rank], b [rank, out_features], typically f32). */
export interface LoraWeights {
  a: MlxArray;
  b: MlxArray;
  scale: number;
  rank: number;
}

/** Active-adapter state, shared by every mounted linear of one model.
 *  A plain field, NOT a ContextVar port: our generation queue is
 *  serialized, so exactly one request's adapters are active at a time
 *  (PLAN Phase 8 decision). Set/restored by generate(). */
export class LoraState {
  active: string[] = [];
  /** Training-only LoRA-input dropout. `rate` is the drop probability; `seed` is
   *  set per micro-step by the trainer and is CONSTANT across that step's forward
   *  and any recompute (segmented / gradient-checkpoint), so each layer's mask —
   *  keyed by (seed, the linear's dropoutId) — is reproduced exactly in the
   *  backward. `seed === null` (the default, and for inference) disables it. */
  dropoutRate = 0;
  dropoutSeed: number | null = null;
}

/** Inverted LoRA-input dropout, keyed by (seed, id) so it is deterministic —
 *  the same (seed, id, shape) reproduces the mask, which is what makes the
 *  segmented / gradient-checkpoint recompute correct. kept ⇒ x/(1-p),
 *  dropped ⇒ 0 (preserves the expectation). Caller owns the result. */
export function loraInputDropout(x: MlxArray, p: number, seed: number, id: number): MlxArray {
  const key = ops.randomKey(BigInt(seed) * 100003n + BigInt(id));
  const u = ops.randomUniform(x.shape, Dtype.float32, 0, 1, key); // [shape] in [0,1)
  key.dispose();
  const pArr = ops.scalarLike(p, u);
  const keep = ops.less(pArr, u); // u > p ⇒ keep (bool [shape])
  const scaleX = ops.scalarLike(1 / (1 - p), x);
  const zeroX = ops.scalarLike(0, x);
  const mask = ops.where(keep, scaleX, zeroX); // x.dtype
  const xd = ops.mul(x, mask);
  for (const a of [u, pArr, keep, scaleX, zeroX, mask]) a.dispose();
  return xd;
}
