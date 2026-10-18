import host.ts.Source
namespace Host.Ts.Sources.Inference.Generation.Prefill
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/generation/prefill.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { PrefillStep } from "../contracts/portable/prefill";
import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Cache } from "../contracts/mlx/cache";
import * as ops from "@mlx-bun/mlx/ops";
import { clearCache } from "@mlx-bun/mlx/ffi";
import { leaseCacheStates } from "../state/leases";
import { withResource } from "../runtime/resources";
import type { MlxPhaseDispatch } from "./phase-dispatch";

/** State views with explicit ownership are released even on deferred errors.
 * Owned views precede borrowed state, preserving the serial eval ordering. */
export function evalCacheState(cache: Cache[]): void {
  withResource(leaseCacheStates(cache), (state) => { if (state.length) ops.evalAll([...state]); });
}

/** Forward one prompt step of one sequence through the operation its planned
 * phase names. Drains evaluate state (the composed caches converted inside
 * their own appends), then clear the allocator cache. Finals return owned
 * hidden state without forcing eval. */
export async function executeMlxPrefillStep(
  phases: MlxPhaseDispatch, cache: Cache[], prompt: readonly number[], step: PrefillStep,
): Promise<MlxArray | null> {
  const chunk = prompt.slice(step.start, step.end);
  const ids = ops.fromInt32(chunk, [1, chunk.length]);
  let hidden: MlxArray;
  try { hidden = await phases.prompt(step.phase, 1, chunk.length)(ids, cache, null); }
  finally { ids.dispose(); }
  if (step.kind === "final") return hidden;
  hidden.dispose();
  evalCacheState(cache);
  clearCache();
  return null;
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Generation.Prefill
