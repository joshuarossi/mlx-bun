import type { PrefillStep } from "../../inference/prefill";
import type { MlxArray } from "../../mlx/array";
import type { Cache } from "../../model/gemma4";
import * as ops from "../../mlx/ops";
import { clearCache } from "../../mlx/ffi";

/** State views with explicit ownership are released even on deferred errors.
 * Owned views precede borrowed state, preserving the serial eval ordering. */
export function evalCacheState(cache: Cache[]): void {
  const owned: MlxArray[] = [];
  try {
    for (const state of cache) if (state.stateNeedsDispose) owned.push(...state.state());
    const borrowed = cache.flatMap((state) => state.stateNeedsDispose ? [] : state.state());
    ops.evalAll([...owned, ...borrowed]);
  } finally { for (const view of owned) view.dispose(); }
}

/** Forward once. Drains evaluate state, apply KV maintenance, then clear the
 * allocator cache. Finals return owned hidden state without forcing eval. */
export async function executeMlxPrefillStep(
  forward: (ids: MlxArray, cache: Cache[]) => MlxArray | Promise<MlxArray>,
  cache: Cache[], prompt: readonly number[], step: PrefillStep,
  maintain: () => void,
): Promise<MlxArray | null> {
  const chunk = prompt.slice(step.start, step.end);
  const ids = ops.fromInt32(chunk, [1, chunk.length]);
  let hidden: MlxArray;
  try { hidden = await forward(ids, cache); }
  finally { ids.dispose(); }
  if (step.kind === "final") return hidden;
  hidden.dispose();
  evalCacheState(cache);
  maintain();
  clearCache();
  return null;
}
