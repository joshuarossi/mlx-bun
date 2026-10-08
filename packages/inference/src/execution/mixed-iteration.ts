import type { MlxArray } from "@mlx-bun/mlx/array";
import type { TokenGroup } from "../contracts/mlx/token-work";

/** Join two method-owned work producers at their forward boundary. Decode
 * finishes sampling/publication/retirement before preparation can join rows.
 * The model owns packing; this coordinator never merges caches or samples.
 * A restored/cancelled preparation need not produce a forward at all. */
export async function runMixedTokenIteration(options: {
  prepare(forward: MlxForwardWork): Promise<void>;
  decode(forward: MlxForwardWork): Promise<void>;
  forward: MlxForwardWork;
  mixed(groups: readonly TokenGroup[]): MlxArray[];
}): Promise<boolean> {
  let notify!: () => void;
  const offered = new Promise<void>(resolve => { notify = resolve; });
  let pending: { group: TokenGroup; resolve(hidden: MlxArray): void; reject(error: unknown): void } | undefined;
  let captured = false;
  let preparationError: unknown;
  let preparationFailed = false;
  const preparing = options.prepare(async (ids, cache, policy) => {
    if (captured) return options.forward(ids, cache, policy);
    captured = true;
    return new Promise<MlxArray>((resolve, reject) => {
      pending = { group: { ids, cache, ...policy }, resolve, reject }; notify();
    });
  }).catch(error => { preparationFailed = true; preparationError = error; }).finally(notify);
  await offered;
  if (!pending) {
    await preparing;
    if (preparationFailed) throw preparationError;
    return false;
  }
  const held = pending;
  let preparedHidden: MlxArray | undefined;
  let mixed = false;
  try {
    await options.decode(async (ids, cache, policy) => {
      if (mixed) return options.forward(ids, cache, policy);
      const outputs = options.mixed([{ ids, cache, ...policy }, held.group]);
      mixed = true; preparedHidden = outputs[1]!;
      return outputs[0]!;
    });
    // A final unread token can retire decode without another model call.
    preparedHidden ??= await options.forward(held.group.ids, held.group.cache, held.group);
    held.resolve(preparedHidden); preparedHidden = undefined;
    await preparing;
    if (preparationFailed) throw preparationError;
    return true;
  } catch (error) {
    preparedHidden?.dispose(); held.reject(error);
    await preparing;
    throw error;
  }
}

import { MlxForwardWork } from "../contracts/mlx/forward-work";
export { type MlxForwardWork,type MlxPreparationWork } from "../contracts/mlx/forward-work";
