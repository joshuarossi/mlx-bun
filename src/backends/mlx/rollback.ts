import type { SpeculativeTransaction } from "../../inference/rollback";
import type { Cache } from "../../model/gemma4-base";

interface TransactionLayer<Acceptance> {
  fits(drafts: number): boolean;
  begin(): void;
  resolve(accepted: Acceptance, drafts: number): void;
}

/** State storage that can retain a different verified prefix for each row.
 * Both attention and recurrent layouts implement this same transaction. */
export interface RowSpeculativeState {
  specRoundBegin(): void;
  specRoundCommit(): void;
  specRoundRollback(keep: number | readonly number[]): void;
}

export function bindRowCacheRollback(
  caches: readonly RowSpeculativeState[], rows: number,
): SpeculativeTransaction<readonly number[]> {
  return bindTransaction(caches.map(cache => ({
    fits: () => true,
    begin: () => cache.specRoundBegin(),
    resolve(accepted: readonly number[], drafts: number) {
      if (accepted.every(count => count === drafts)) cache.specRoundCommit();
      else cache.specRoundRollback(accepted.every(count => count === accepted[0])
        ? accepted[0]! + 1 : accepted.map(count => count + 1));
    },
  })), (accepted, drafts) => accepted.length === rows &&
    accepted.every(count => Number.isSafeInteger(count) && count >= 0 && count <= drafts));
}

/** Bind the recurrent transaction or the trim implementation once.
 * Ring-capacity checks still happen at each safe boundary before any writes. */
export function bindCacheRollback(caches: readonly Cache[]): SpeculativeTransaction {
  const layers = caches.map((cache) => {
    const { specRoundBegin: begin, specRoundCommit: commit, specRoundRollback: rollback } = cache;
    const hasRound = [begin, commit, rollback].some((method) => method !== undefined);
    if (hasRound && !(typeof begin === "function" && typeof commit === "function" && typeof rollback === "function"))
      throw new Error("cache exposes an incomplete speculative transaction");
    return {
      fits(drafts: number) {
        if ("maxSize" in cache && typeof cache.maxSize === "number")
          return cache.offset + drafts + 1 < cache.maxSize;
        return hasRound || cache.isTrimmable();
      },
      begin: () => begin?.call(cache),
      resolve(accepted: number, drafts: number) {
        if (accepted < drafts) {
          if (rollback) rollback.call(cache, accepted + 1);
          else cache.trim(drafts - accepted);
        } else commit?.call(cache);
      },
    };
  });
  return bindTransaction(layers, (accepted, drafts) =>
    Number.isSafeInteger(accepted) && accepted >= 0 && accepted <= drafts);
}

/** One transaction lifecycle for scalar and row-wise state bindings. */
function bindTransaction<Acceptance>(
  layers: readonly TransactionLayer<Acceptance>[],
  accepts: (accepted: Acceptance, drafts: number) => boolean,
): SpeculativeTransaction<Acceptance> {
  let active: number | undefined;
  let invalid = false;
  const validate = (drafts: number) => {
    if (invalid) throw new Error("speculative state is invalid and must be discarded");
    if (!Number.isSafeInteger(drafts) || drafts < 0) throw new Error("invalid speculative draft count");
  };
  return {
    canBegin(drafts) { validate(drafts); return active === undefined && layers.every((layer) => layer.fits(drafts)); },
    begin(drafts) {
      validate(drafts);
      if (active !== undefined || !layers.every((layer) => layer.fits(drafts)))
        throw new Error("speculative state cannot begin this round");
      active = drafts;
      try { for (const layer of layers) layer.begin(); }
      catch (error) { invalid = true; throw error; }
    },
    resolve(accepted) {
      if (invalid) throw new Error("speculative state is invalid and must be discarded");
      if (active === undefined || !accepts(accepted, active)) throw new Error("invalid speculative acceptance count");
      try { for (const layer of layers) layer.resolve(accepted, active); }
      catch (error) { invalid = true; throw error; }
      active = undefined;
    },
  };
}
