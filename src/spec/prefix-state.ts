import type { Cache } from "../model/gemma4";
import type { DisposableResource } from "../contracts/resources";
import { cleanupFailure } from "../engine/resources";

/** One most-recent, exact prefill boundary. Taking transfers ownership; a
 * recurrent target cannot be trimmed to an arbitrary common prefix. The
 * provider owns this state and releases it before its weights at shutdown. */
export interface SpeculativePrefixState extends DisposableResource {
  readonly tokens: number[];
  readonly targetIdentity: object;
  readonly namespace: string;
  readonly bytes: number;
  readonly target: Cache[];
}

export class SpeculativePrefixStore<T extends SpeculativePrefixState> {
  #entry: T | null = null;

  take(prompt: readonly number[], targetIdentity: object, namespace: string,
    maxBytes: number): T | null {
    const entry = this.#entry;
    this.#entry = null;
    if (!entry) return null;
    if (entry.bytes <= maxBytes && entry.targetIdentity === targetIdentity &&
      entry.namespace === namespace && entry.tokens.length < prompt.length &&
      entry.tokens.every((token, index) => prompt[index] === token))
      return entry;
    entry.dispose();
    return null;
  }

  /** Takes ownership even when the entry exceeds the configured RAM budget. */
  put(entry: T, maxBytes: number): void {
    try { this.dispose(); }
    catch (error) { cleanupFailure(error, () => entry.dispose()); }
    if (entry.bytes <= maxBytes && maxBytes > 0) this.#entry = entry;
    else entry.dispose();
  }

  dispose(): void {
    const entry = this.#entry;
    this.#entry = null;
    entry?.dispose();
  }
}
