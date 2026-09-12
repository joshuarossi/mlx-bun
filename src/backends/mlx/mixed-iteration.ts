import type { MlxArray } from "../../mlx/array";
import type { Cache } from "../../model/gemma4-base";
import type { TokenGroup } from "../../model/token-groups";

export type MlxForwardWork = (ids: MlxArray, cache: Cache[]) => Promise<MlxArray>;
export interface MlxPreparationWork {
  /** Real prompt tokens across all rows, not a padded sequence width. */
  readonly maxTokens?: number;
  readonly forward?: MlxForwardWork;
}

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
  const preparing = options.prepare(async (ids, cache) => {
    if (captured) return options.forward(ids, cache);
    captured = true;
    return new Promise<MlxArray>((resolve, reject) => {
      pending = { group: { ids, cache }, resolve, reject }; notify();
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
    await options.decode(async (ids, cache) => {
      if (mixed) return options.forward(ids, cache);
      const outputs = options.mixed([{ ids, cache }, held.group]);
      mixed = true; preparedHidden = outputs[1]!;
      return outputs[0]!;
    });
    // A final unread token can retire decode without another model call.
    preparedHidden ??= await options.forward(held.group.ids, held.group.cache);
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
