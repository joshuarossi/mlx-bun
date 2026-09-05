import type { DisposableResource, ResourceOwner } from "../contracts/resources";

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

export function withResource<T, R>(owner: Pick<ResourceOwner<T>, "borrow" | "close">, use: (value: T) => R): R {
  try { return use(owner.borrow()); }
  catch (error) { cleanupFailure(error, () => owner.close()); }
  finally { owner.close(); }
}
