import host.ts.Source
namespace Host.Ts.Sources.Inference.Artifacts.WeightAudit
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/artifacts/weight-audit.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Universal-tier primitives: dense (unquantized) linear/embedding modules
// (mlx nn.Linear / nn.Embedding semantics), quantized-or-dense
// loader helpers, norm loaders, and the load-time weight audit.
//
// The quantized paths delegate to the proven QuantizedLinear/QuantizedEmbedding
// primitives (packages/inference/src/layers/); the
// dense paths are verbatim ports of mlx.nn.Linear (`mx.addmm(bias, x, W.T)`
// / `x @ W.T`) and mlx.nn.Embedding (`weight[ids]`, `x @ weight.T`).

import { MlxArray } from "@mlx-bun/mlx/array";
import type { Weights } from "./weights";

/** Records every tensor a universal load consumes; `finish` diffs against
 *  the shard index so a descriptor mistake is a LOAD error (unconsumed /
 *  missing tensors named), never a silently-wrong model
 *  (`02d723a:docs/design/generic-model-support.md` §4.1). */
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
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Artifacts.WeightAudit
