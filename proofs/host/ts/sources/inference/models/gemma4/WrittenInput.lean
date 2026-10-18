import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.WrittenInput
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/written-input.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../../contracts/mlx/cache";
import type { Gemma4Phase } from "./blocks";

type MediaForward = (hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray) => MlxArray;

/** Prepared media request data before entering the fixed operation its range
 * names. A request's image mask declares its bidirectional attention spans. */
export function writtenMedia(embedScale: number, operation: MediaForward,
  embeds: MlxArray, caches: Cache[], bidir: MlxArray | null, ids: MlxArray): MlxArray {
  const hidden = ops.mulScalar(embeds, embedScale);
  return operation(hidden, caches, bidir ? { bidirectional: bidir } : "window", ids);
}

/** Per-layer-input media positions take token zero's input, as the reference
 * does. The masks are request data; the file names this input operation. */
export function writtenInputMedia(embedScale: number, operation: MediaForward,
  embeds: MlxArray, caches: Cache[], bidir: MlxArray | null, ids: MlxArray, multimodal: MlxArray | null): MlxArray {
  const zeroing = multimodal ?? bidir;
  let inputIds = ids;
  if (zeroing) {
    using condition = ops.reshape(zeroing, ids.shape);
    using zero = ops.zeros(ids.shape, ids.dtype);
    inputIds = ops.where(condition, zero, ids);
  }
  try { return writtenMedia(embedScale, operation, embeds, caches, bidir, inputIds); }
  finally { if (inputIds !== ids) inputIds.dispose(); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.WrittenInput
