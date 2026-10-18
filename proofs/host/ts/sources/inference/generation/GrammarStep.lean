import host.ts.Source
namespace Host.Ts.Sources.Inference.Generation.GrammarStep
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/generation/grammar-step.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../contracts/mlx/cache";
import { cleanupFailure, disposeResources } from "../runtime/resources";
import type { MlxPhaseDispatch } from "./phase-dispatch";

/** Append an already accepted grammar span in one graph call: known tokens
 * (`appendKnown`), a single position through `decode`. This operation
 * intentionally does not use the fill append policy: splitting the span changes
 * the historical grammar path's arithmetic. Inputs/state are borrowed. Record
 * committed IDs before projection so failures cannot hide written state.
 * The sampler must retain its result before returning: tensor cleanup can fail
 * after sampling. All temporary tensors belong to this operation. */
export async function appendGrammarSpan(
  phases: MlxPhaseDispatch, state: Cache[], ids: readonly number[],
  committed: (ids: readonly number[]) => void, sampleLast?: (logits: MlxArray) => void,
): Promise<void> {
  let input: MlxArray | null = null, hidden: MlxArray | null = null;
  let last: MlxArray | null = null, logits: MlxArray | null = null;
  const close = () => {
    const owned = [input, hidden, last, logits];
    input = hidden = last = logits = null;
    disposeResources(owned.filter((array): array is MlxArray => array !== null));
  };
  try {
    input = ops.fromInt32([...ids], [1, ids.length]);
    hidden = await (ids.length === 1 ? phases.decode(1)(input, state, null) : phases.known(ids.length)(input, state));
    const consumed = input; input = null; consumed.dispose();
    committed(ids);
    if (!sampleLast) return;
    const [, length, width] = hidden.shape as [number, number, number];
    last = hidden.slice([0, length - 1, 0], [1, length, width]);
    const full = hidden; hidden = null; full.dispose();
    logits = phases.logits(1)(last);
    const selected = last; last = null; selected.dispose();
    sampleLast(logits);
  } catch (error) { return cleanupFailure(error, close); }
  finally { close(); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Generation.GrammarStep
