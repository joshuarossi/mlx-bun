import type { Cache } from "../contracts/mlx/cache";
import type { ResolvedExecution } from "../contracts/portable/execution";
import { generationCheckpointKey } from "../generation/checkpoint-identity";
import type { GenerateOptions } from "../generation/index";
import { disposeResources } from "../runtime/resources";
import type { MlxPrefixCache } from "../state/checkpoint";
import type { ContinuationPersistence } from "./continuation-persistence";

/** Cache and checkpoint services the application binds once per loaded model;
 * the gateway binding reads them for paged state and qualified continuation. */
export interface ContinuationServices {
  readonly promptCache: MlxPrefixCache & { readonly maxBytes?: number };
  readonly checkpoints: ContinuationStore | null;
  readonly checkpointEveryTokens?: number;
  readonly checkpointPersistence?: ContinuationPersistence;
  /** Artifact, implementation, state ABI and codec identity captured at load. */
  readonly identity: unknown;
  adapterNamespace(adapters: string[]): string;
  cloneState(caches: Cache[]): Cache[];
}

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

import { ContinuationStore,OrdinaryContinuationState } from "./continuation-types";
export { type ContinuationStore,type OrdinaryContinuation,type OrdinaryContinuationState } from "./continuation-types";
