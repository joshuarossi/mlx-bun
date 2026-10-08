import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../contracts/mlx/cache";
import { cleanupFailure, disposeResources } from "../runtime/resources";
import type { MlxAutoregressiveBinding } from "./bindings/autoregressive";

/** Append an already accepted grammar span in one graph call. This operation
 * intentionally does not use the fill append policy: splitting the span changes
 * the historical grammar path's arithmetic. Inputs/state are borrowed. Record
 * committed IDs before projection so failures cannot hide written state.
 * The sampler must retain its result before returning: tensor cleanup can fail
 * after sampling. All temporary tensors belong to this operation. */
export async function appendGrammarSpan(
  graph: MlxAutoregressiveBinding["graph"], state: Cache[], ids: readonly number[],
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
    hidden = await graph.forwardHidden(input, state);
    const consumed = input; input = null; consumed.dispose();
    committed(ids);
    if (!sampleLast) return;
    const [, length, width] = hidden.shape as [number, number, number];
    last = hidden.slice([0, length - 1, 0], [1, length, width]);
    const full = hidden; hidden = null; full.dispose();
    logits = graph.projectLogits(last, { type: "all" });
    const selected = last; last = null; selected.dispose();
    sampleLast(logits);
  } catch (error) { return cleanupFailure(error, close); }
  finally { close(); }
}
