import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.MediaInput
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/media-input.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../contracts/mlx/cache";
import type { MlxPromptInput } from "../contracts/mlx/media";

/** Preserve the ordinary generator's projection geometry for a prepared
 * embedding sequence: process the whole prompt, then project only its tip. */
export function bindEmbeddingsInput(
  prefill: (ids: MlxArray, caches: Cache[], start: number, phase: "tail" | "decode", width: number) => MlxArray,
): MlxPromptInput {
  return { prefill(ids, caches, start, phase, width) {
    using hidden = prefill(ids, caches, start, phase, width);
    const [batch, length, hiddenWidth] = hidden.shape;
    return hidden.slice([0, length! - 1, 0], [batch!, length!, hiddenWidth!]);
  } };
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.MediaInput
