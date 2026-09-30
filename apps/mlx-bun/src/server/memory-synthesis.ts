import { runSynthesis, type SynthesisOptions, type SynthesisSummary } from "../memory/pipeline";
import type { SynthesisEvent } from "../memory/events";
import type { MemoryCompletionClient } from "../memory/model";

/** A run's completions, and what the run gives back when it settles (a residency lease on the model that answers them). */
export type SynthesisClient = MemoryCompletionClient & { release?(): void };

/** Owns synthesis runs until their pipeline and pending completions settle.
 * Close stops admission, cancels all runs, and joins them; the composition
 * closes the completion source only after that. */
export function createMemorySynthesis(options: {
  root: string;
  /** One run's completions; the signal ends them when the run is cancelled. */
  client(signal: AbortSignal): SynthesisClient | Promise<SynthesisClient>;
  run?: typeof runSynthesis;
}) {
  const shutdown = new AbortController();
  const pending = new Set<Promise<SynthesisSummary>>();
  let closing: Promise<void> | undefined;
  return {
    async run(input: Pick<SynthesisOptions, "dryRun" | "signal">, onEvent: (event: SynthesisEvent) => void) {
      shutdown.signal.throwIfAborted();
      const signal = AbortSignal.any([shutdown.signal, ...(input.signal ? [input.signal] : [])]);
      signal.throwIfAborted();
      const work = Promise.resolve().then(async () => {
        const client = await options.client(signal);
        try {
          signal.throwIfAborted();
          return await (options.run ?? runSynthesis)({ ...input, root: options.root, client, signal }, onEvent);
        } finally { client.release?.(); }
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
