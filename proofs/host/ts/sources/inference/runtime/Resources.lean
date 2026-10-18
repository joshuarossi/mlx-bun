import host.ts.Source
namespace Host.Ts.Sources.Inference.Runtime.Resources
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/runtime/resources.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { DisposableResource, PreparedStateChange, ResourceOwner } from "../contracts/portable/resources";

export function ownResource<T>(value: T, release: (value: T) => void): ResourceOwner<T> {
  let held: { value: T } | undefined = { value };
  const borrow = () => {
    if (!held) throw new Error("resource ownership has ended");
    return held.value;
  };
  return {
    borrow,
    transfer() { const result = borrow(); held = undefined; return result; },
    close() {
      if (!held) return;
      const result = held.value;
      held = undefined;
      release(result);
    },
  };
}

/** Attempt every release once. One failed destructor must not leak siblings. */
export function disposeResources(resources: Iterable<DisposableResource>): void {
  const errors: unknown[] = [];
  for (const resource of new Set(resources)) {
    try { resource.dispose(); } catch (error) { errors.push(error); }
  }
  if (errors.length === 1) throw errors[0];
  if (errors.length) throw new AggregateError(errors, "resource cleanup failed");
}

/** Used at failure boundaries to retain the execution error as well as cleanup. */
export function cleanupFailure(error: unknown, cleanup: () => void): never {
  try { cleanup(); }
  catch (cleanupError) { throw new AggregateError([error, cleanupError], "execution and cleanup failed"); }
  throw error;
}

/** Complete every preparation before publishing any owner's replacement.
 * Old state is released only after all owners have committed. */
export function applyStateChanges(prepare: readonly (() => PreparedStateChange)[]): void {
  const changes: PreparedStateChange[] = [];
  try {
    for (const build of prepare) changes.push(build());
    for (const change of changes) change.commit();
  } catch (error) { return cleanupFailure(error, () => disposeResources(changes.splice(0))); }
  disposeResources(changes);
}

export function withResource<T, R>(owner: Pick<ResourceOwner<T>, "borrow" | "close">, use: (value: T) => R): R {
  try { return use(owner.borrow()); }
  catch (error) { cleanupFailure(error, () => owner.close()); }
  finally { owner.close(); }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Runtime.Resources
