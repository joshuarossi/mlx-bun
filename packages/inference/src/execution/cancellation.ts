import type { CancelReason, Cancellation } from "../contracts/generation";

export class GenerationCancelled extends Error {
  constructor(readonly reason: CancelReason) {
    super(`generation cancelled: ${reason}`);
    this.name = "GenerationCancelled";
  }
}

export function throwIfCancelled(cancellation: Cancellation): void {
  if (cancellation.reason !== undefined) throw new GenerationCancelled(cancellation.reason);
}

export class CancellationSource implements Cancellation {
  #reason: CancelReason | undefined;
  #listeners = new Set<(reason: CancelReason) => void>();
  get reason(): CancelReason | undefined { return this.#reason; }

  subscribe(listener: (reason: CancelReason) => void): () => void {
    if (this.#reason !== undefined) {
      listener(this.#reason);
      return () => {};
    }
    this.#listeners.add(listener);
    return () => { this.#listeners.delete(listener); };
  }

  cancel(reason: CancelReason): void {
    if (this.#reason !== undefined) return;
    this.#reason = reason;
    const listeners = [...this.#listeners];
    this.#listeners.clear();
    // A faulty observer cannot prevent the remaining owners from cancelling.
    for (const listener of listeners) {
      try { listener(reason); } catch { /* Observers do not own settlement. */ }
    }
  }
}
