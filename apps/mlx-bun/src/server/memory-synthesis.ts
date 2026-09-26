import { runSynthesis, type SynthesisOptions, type SynthesisSummary } from "../memory/pipeline";
import type { SynthesisEvent } from "../memory/events";
import { createLoopbackMemoryClient, type MemoryClientHttp } from "./memory-completion-client";

/** Owns synthesis runs until their pipeline and pending completions settle.
 * Close stops admission, cancels all runs, and joins them before engine drain. */
export function createMemorySynthesis(options: {
  root: string;
  apiUrl: () => string;
  http?: MemoryClientHttp;
  run?: typeof runSynthesis;
}) {
  const shutdown = new AbortController();
  const pending = new Set<Promise<SynthesisSummary>>();
  let closing: Promise<void> | undefined;
  return {
    async run(input: Pick<SynthesisOptions, "dryRun" | "signal">, onEvent: (event: SynthesisEvent) => void) {
      shutdown.signal.throwIfAborted();
      const signal = AbortSignal.any([shutdown.signal, ...[input.signal, options.http?.signal].filter((s): s is AbortSignal => !!s)]);
      signal.throwIfAborted();
      const client = createLoopbackMemoryClient(options.apiUrl, { ...options.http, signal });
      const work = Promise.resolve().then(() => {
        signal.throwIfAborted();
        return (options.run ?? runSynthesis)({ ...input, root: options.root, client, signal }, onEvent);
      });
      pending.add(work);
      try { return await work; } finally { pending.delete(work); }
    },
    close(): Promise<void> {
      if (closing) return closing;
      shutdown.abort(new Error("memory synthesis owner closed"));
      return closing = Promise.allSettled([...pending]).then(() => {});
    },
  };
}
