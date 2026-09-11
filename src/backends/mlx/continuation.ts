import type { ContinuationPersistence } from "./continuation-persistence";
import type { Cache } from "../../model/gemma4-base";
import type { GenerateOptions } from "../../generate";
import type { ResolvedExecution } from "../../contracts/execution";
import type { SsdCacheStore } from "../../ssd-cache";
import { generationCheckpointKey } from "../../serve/checkpoint-identity";
import { disposeResources } from "../../engine/resources";

export interface OrdinaryContinuationState {
  caches: Cache[];
  cacheTokens: number[];
  generatedTokens: number;
  pendingToken: number;
  seed: number;
}
/** Request-owned policy. Restore and captureOwned transfer cache ownership.
 * No store or key knowledge enters the driver. */
export interface OrdinaryContinuation {
  readonly interval: number;
  restore(namespace: string): OrdinaryContinuationState | null;
  resumeSampling(state: Omit<OrdinaryContinuationState, "caches">): void;
  captureOwned(state: Omit<OrdinaryContinuationState, "seed">): void;
  complete(): void;
}
export type ContinuationStore = Pick<SsdCacheStore, "findGenerationCheckpoint" | "restore" |
  "storeGenerationCheckpoint" | "removeGenerationCheckpoints">;

/** Shared persistence policy for compatibility and grouped ordinary drivers. */
export function bindContinuationPolicy(input: {
  store: ContinuationStore;
  restore: (entry: NonNullable<ReturnType<ContinuationStore["findGenerationCheckpoint"]>>) => ReturnType<ContinuationStore["restore"]>;
  prompt: number[]; options: GenerateOptions; execution: ResolvedExecution;
  identity: unknown; namespace: string;
  persistence?: ContinuationPersistence;
}) {
  const { store, options, prompt, namespace } = input;
  const key = generationCheckpointKey(prompt, options, namespace, input.execution, input.identity);
  let seed = options.seed ?? 0;
  const attempt = input.persistence?.begin(key);
  return {
    key,
    restore(): OrdinaryContinuationState | null {
      if (input.persistence && !input.persistence.canRestore(key)) return null;
      const entry = store.findGenerationCheckpoint(prompt, key, namespace);
      const restored = entry ? input.restore(entry) : null;
      if (!restored) return null;
      const metadata = restored.header.generationCheckpoint;
      if (!metadata || metadata.originalPromptTokens !== prompt.length ||
          metadata.generatedTokens !== restored.tokens.length - prompt.length) {
        disposeResources(restored.caches);
        throw new Error("generation checkpoint has inconsistent continuation metadata");
      }
      seed = metadata.seed;
      return { caches: restored.caches, cacheTokens: restored.tokens,
        generatedTokens: metadata.generatedTokens, pendingToken: metadata.pendingToken, seed };
    },
    async capture(state: Omit<OrdinaryContinuationState, "seed">): Promise<void> {
      const stored = await store.storeGenerationCheckpoint(state.cacheTokens, state.caches, {
        key, cacheNs: namespace, originalPromptTokens: prompt.length,
        generatedTokens: state.generatedTokens, pendingToken: state.pendingToken,
        seed, seedWasExplicit: options.seedWasExplicit === true,
      });
      if (stored) console.log(`[generation-checkpoint] saved ${state.generatedTokens} emitted tokens`);
    },
    captureOwned(state: Omit<OrdinaryContinuationState, "seed">): void {
      if (!input.persistence || !attempt) { disposeResources(state.caches); throw new Error("owned continuation requires persistence coordinator"); }
      input.persistence.enqueue(attempt, state, { key, cacheNs: namespace, originalPromptTokens: prompt.length,
        generatedTokens: state.generatedTokens, pendingToken: state.pendingToken,
        seed, seedWasExplicit: options.seedWasExplicit === true });
    },
    release() { if (input.persistence && attempt) input.persistence.release(attempt); },
    complete() {
      if (input.persistence && attempt) input.persistence.complete(attempt);
      else store.removeGenerationCheckpoints(key);
    },
  };
}
