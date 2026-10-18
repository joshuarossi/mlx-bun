import host.ts.Source
namespace Host.Ts.Sources.Inference.State.Rollback
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/rollback.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { SpeculativeTransaction } from "../contracts/portable/rollback";
import type { Cache } from "../contracts/mlx/cache";
import type { KvStorageScheme } from "../contracts/portable/composition";
import { isRotatingPlainCache } from "./capabilities";

/** Whether a serial run's caches, composed with the KV scheme `kv`, can drop
 * the rejected tail of a verify block (`rollbackVerifyBlock`): bf16 storage
 * that trims, a plain ring, or a recurrence that restores and replays. */
export function rollsBackVerifyBlock(kv: KvStorageScheme, caches: readonly Cache[]): boolean {
  return kv.kind === "bf16" && caches.every(cache =>
    cache.isTrimmable() || isRotatingPlainCache(cache) || typeof cache.specRoundRollback === "function");
}

/** Drop the rejected tail of a verify block of `block` positions that one
 * concat write appended, keeping `accepted`: a recurrence restores its
 * pre-round snapshot and bit-exactly replays the accepted prefix; other storage
 * trims the rest. A plain ring stops being trimmable once it wraps, but the
 * block was one concat write that keeps the newest window-1 positions plus the
 * block in temporal order, so its rollback trim drops the tail physically
 * (at least the window remains: `accepted` >= 1). */
export function rollbackVerifyBlock(caches: readonly Cache[], accepted: number, block: number): void {
  for (const cache of caches) {
    if (cache.specRoundRollback) cache.specRoundRollback(accepted);
    else cache.trim(block - accepted, isRotatingPlainCache(cache));
  }
}

interface TransactionLayer<Acceptance> {
  fits(drafts: number): boolean;
  begin(drafts: number): void;
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
    // A zero-candidate round consumes only the committed pending token.
    // It cannot reject any input, so retaining rollback state is unnecessary.
    begin: drafts => { if (drafts > 0) cache.specRoundBegin(); },
    resolve(accepted: readonly number[], drafts: number) {
      if (drafts === 0) return;
      if (accepted.every(count => count === drafts)) cache.specRoundCommit();
      else cache.specRoundRollback(accepted.every(count => count === accepted[0])
        ? accepted[0]! + 1 : accepted.map(count => count + 1));
    },
  })), (accepted, drafts) => accepted.length === rows &&
    accepted.every(count => Number.isSafeInteger(count) && count >= 0 && count <= drafts));
}

/** A one-position window whose input may itself be rejected: a step built from a sample not yet read. `resolve`
 * keeps each row's input (1) or drops it (0), restoring that row's state from before the window. */
export function bindRowStepRollback(
  caches: readonly RowSpeculativeState[], rows: number,
): SpeculativeTransaction<readonly number[]> {
  return bindTransaction(caches.map(cache => ({
    fits: () => true,
    begin: () => cache.specRoundBegin(),
    resolve(kept: readonly number[]) {
      if (kept.every(count => count === 1)) cache.specRoundCommit();
      else cache.specRoundRollback(kept.every(count => count === kept[0]) ? kept[0]! : kept);
    },
  })), (kept, inputs) => inputs === 1 && kept.length === rows && kept.every(count => count === 0 || count === 1));
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
      try { for (const layer of layers) layer.begin(drafts); }
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
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.Rollback
