// Universal-tier primitives: dense (unquantized) linear/embedding modules
// (Phase 1.5 — mlx nn.Linear / nn.Embedding semantics), quantized-or-dense
// loader helpers, norm loaders, and the load-time weight audit.
//
// The quantized paths delegate to the proven gemma4-base primitives; the
// dense paths are verbatim ports of mlx.nn.Linear (`mx.addmm(bias, x, W.T)`
// / `x @ W.T`) and mlx.nn.Embedding (`weight[ids]`, `x @ weight.T`).

import { MlxArray } from "@mlx-bun/mlx/array";
import type { Weights } from "./weights";

/** Records every tensor a universal load consumes; `finish` diffs against
 *  the shard index so a descriptor mistake is a LOAD error (unconsumed /
 *  missing tensors named), never a silently-wrong model
 *  (docs/design/generic-model-support.md §3.4). */
export class WeightAudit {
  readonly consumed = new Set<string>();

  use(name: string): void {
    this.consumed.add(name);
  }

  /** `drop` = the arch's sanitize rules (tensors mlx-lm discards on load,
   *  e.g. rotary_emb.inv_freq, or lm_head.weight under tied embeddings). */
  finish(weights: Weights, drop: RegExp[]): void {
    const unconsumed = weights.tensorNames.filter(
      (n) => !this.consumed.has(n) && !drop.some((re) => re.test(n)),
    );
    if (unconsumed.length > 0)
      throw new Error(
        `weight audit: ${unconsumed.length} tensor(s) in the checkpoint were not consumed ` +
        `by the universal module (descriptor mismatch?): ${unconsumed.slice(0, 12).join(", ")}` +
        (unconsumed.length > 12 ? ", …" : ""),
      );
  }
}

/** Load a tensor and record it in the audit. */
export function tensorUsed(weights: Weights, audit: WeightAudit, name: string): MlxArray {
  audit.use(name);
  return weights.tensor(name);
}
