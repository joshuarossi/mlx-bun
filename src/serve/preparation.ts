/** Host-side admission before grammar/media preparation can allocate native
 * resources. The implementation shares the generation execution domain. */
export interface PreparationExecutor {
  reserve?(kind: "media" | "constraint", signal?: AbortSignal): Promise<import("../contracts/resources").DisposableResource>;
  run<T>(prepare: () => Promise<T>, signal?: AbortSignal): Promise<T>;
}

import { AdmissionPool } from "../engine/admission";
import { CancellationSource } from "../engine/cancellation";

export async function acquireReservation(pool: AdmissionPool, signal?: AbortSignal) {
  signal?.throwIfAborted();
  const cancellation = new CancellationSource();
  const abort = () => cancellation.cancel("requested");
  signal?.addEventListener("abort", abort, { once: true });
  try { return await pool.acquire(cancellation); }
  finally { signal?.removeEventListener("abort", abort); }
}

/** One retained media preparation at a time; grammar rows may form a batch. */
export function createPreparationExecutor(
  run: PreparationExecutor["run"], grammarCapacity: number,
): PreparationExecutor & { close(): void } {
  const media = new AdmissionPool(1);
  const constraints = new AdmissionPool(Math.max(1, grammarCapacity));
  return {
    run,
    async reserve(kind, signal) {
      return acquireReservation(kind === "media" ? media : constraints, signal);
    },
    close() { media.close(); constraints.close(); },
  };
}
