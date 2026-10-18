import host.ts.Source
namespace Host.Ts.Sources.Inference.State.Leases
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/state/leases.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxArray } from "@mlx-bun/mlx/array";
import { type Cache } from "../contracts/mlx/cache";
import type { StateView } from "../contracts/portable/resources";
import { disposeResources,ownResource } from "../runtime/resources";

/** Compatibility boundary for legacy state(). Numerical code consumes a lease,
 * never the legacy ownership marker. No copy, evaluation or fence is added. */
export function leaseCacheState(cache: Cache): StateView<MlxArray> {
  return ownResource<readonly MlxArray[]>(cache.state(), cache.stateNeedsDispose ? disposeResources : () => {});
}

/** Preserve the existing prefill evaluation order: temporary views first,
 * borrowed state second. Partial acquisition releases every acquired view. */
export function leaseCacheStates(caches: readonly Cache[]): StateView<MlxArray> {
  const leases: StateView<MlxArray>[] = [];
  const close = () => disposeResources(leases.map((lease) => ({ dispose: () => lease.close() })));
  try {
    for (const owned of [true, false]) {
      for (const cache of caches) if (!!cache.stateNeedsDispose === owned) leases.push(leaseCacheState(cache));
    }
    return ownResource(leases.flatMap((lease) => [...lease.borrow()]), close);
  } catch (error) {
    try { close(); } catch (cleanupError) { throw new AggregateError([error, cleanupError], "state view acquisition failed"); }
    throw error;
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.State.Leases
