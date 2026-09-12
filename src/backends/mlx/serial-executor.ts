import type { SpecRunServices } from "../../spec/serve-loop";
import { cleanupFailure, disposeResources, ownResource } from "../../engine/resources";
import { bindGeneration } from "../../generate";
import type { RuntimeModel } from "../../model/factory";
import { Qwen35Model } from "../../model/qwen3_5";
import type { Cache } from "../../model/gemma4";
import type { MlxPrefixCache } from "./checkpoint-state";
import type { SsdCacheStore } from "../../ssd-cache";
import type { DraftProvider } from "../../spec/source";
import type { SerialRun, Vision } from "../../serve/generation-gateway";
import { bindContinuationPolicy } from "./continuation";
import { runtimeConfig, withRuntimeConfig, type RuntimeConfig } from "../../runtime-config";
import { bindLegacySpeculativeModel } from "./speculative";

/** Native serial execution depends on this bound port, never a model union.
 * Weights remain borrowed. The gateway supplies the exclusive runtime lease. */
export interface MlxSerialBinding {
  readonly runtime: RuntimeConfig;
  readonly generate: ReturnType<typeof bindGeneration>;
  readonly speculate?: (
    promptIds: Parameters<SerialRun>[0], options: Parameters<SerialRun>[1],
    onToken: Parameters<SerialRun>[2], services?: SpecRunServices,
  ) => ReturnType<SerialRun>;
  makeCache(): Cache[];
  enterMedia?(vision?: Vision): () => void;
}

/** Family-specific context is bound once at the compatibility boundary. */
export function bindLegacySerialModel(
  model: RuntimeModel,
  draft?: { provider: DraftProvider; numDraftTokens: number },
): MlxSerialBinding {
  const speculative = draft ? bindLegacySpeculativeModel(model, draft.provider) : undefined;
  return {
    runtime: runtimeConfig(),
    generate: bindGeneration(model),
    makeCache: model.makeCache.bind(model),
    ...(speculative && draft ? { speculate: (async (prompt, options, onToken, services) => {
      const { specRun } = await import("../../spec/serve-loop");
      return specRun(speculative, draft.numDraftTokens, prompt, options, onToken, services);
    }) satisfies NonNullable<MlxSerialBinding["speculate"]> } : {}),
    ...(model instanceof Qwen35Model ? { enterMedia(vision?: Vision) {
      const previous = model.mrope;
      if (vision?.mrope) model.mrope = vision.mrope;
      return () => { model.mrope = previous; };
    } } : {}),
  };
}

export interface MlxSerialServices {
  readonly promptCache: MlxPrefixCache & { readonly maxBytes?: number };
  readonly checkpoints: Pick<SsdCacheStore, "findGenerationCheckpoint" | "restore" |
    "storeGenerationCheckpoint" | "removeGenerationCheckpoints"> | null;
  readonly checkpointEveryTokens?: number;
  readonly checkpointPersistence?: import("./continuation-persistence").ContinuationPersistence;
  /** Artifact, implementation, state ABI and codec identity captured at load. */
  readonly identity: unknown;
  adapterNamespace(adapters: string[]): string;
  cloneState(caches: Cache[]): Cache[];
}

/** Cache lookup, replay, prompt snapshots and checkpoint persistence belong to
 * native execution. HTTP only composes this service and frames its output.
 * The caller transfers prepared native inputs; caches created/taken here are
 * owned until returned to the prefix store or disposed after execution. */
export function createMlxSerialExecutor(binding: MlxSerialBinding, services: MlxSerialServices): SerialRun {
  const { promptCache, checkpoints: ssdStore } = services;
  return (promptIds, options, onToken, vision, trace, execution) => withRuntimeConfig(binding.runtime, async () => {
    if (promptCache.reclaim) {
      const publish = onToken;
      let steps = 0;
      onToken = (token, logprobs) => {
        if (steps++ % 256 === 0) promptCache.reclaim!();
        return publish(token, logprobs);
      };
    }
    let releaseContinuation: (() => void) | undefined;
    let caches: Cache[] = [];
    let retain: (() => void) | undefined;
    let closeMedia: (() => void) | undefined;
    const cleanup = ownResource(null, () => disposeResources([
      { dispose() {
        disposeResources(caches);
        retain?.(); // backing release requires successful cache disposal
      } },
      { dispose: () => closeMedia?.() },
      { dispose: () => releaseContinuation?.() },
      ...[options.grammar, vision?.embeddings, vision?.imageMask,
        vision?.multimodalMask, options.visionPixels].filter((value) => value != null),
    ]));
    try {
      options.signal?.throwIfAborted();
      if (!execution) throw new Error("serial execution requires a resolved plan");
      if (execution.method === "speculative") {
        if (!binding.speculate) throw new Error("resolved speculation requires a bound verifier");
        return await binding.speculate(promptIds, options, onToken, {
          ...(binding.runtime.flag("MLX_BUN_MTP_PROMPT_CACHE", true) && services.promptCache.maxBytes !== 0
            ? { prefixCache: services.promptCache } : {}),
          cloneState: services.cloneState,
          cacheNamespace: options.adapters?.length ? services.adapterNamespace(options.adapters) : "",
        });
      }
      // Cache entries are adapter-specific: KV computed under one adapter
      // must never seed another's (or the base's) prefill.
      const cacheNs = options.adapters?.length ? services.adapterNamespace(options.adapters) : "";
      // Paged-KV request scope (docs/design/kv-cache.md): media
      // prompts (bidir overlay) and LoRA-adapter requests are v1 non-goals —
      // they run the PLAIN cache path even under --paged-kv (scope the flag
      // per request, never 400). Effective value computed ONCE so the
      // prompt-cache bypass below and the generate() options can't disagree.
      const pagedKv = execution.pagedKv ? options.pagedKv : undefined;
      // Paged requests bypass the prompt cache entirely (v1 non-goal:
      // PagedKVCache has no cloneKvCaches/restore path — the vision
      // precedent). Fresh caches per request, disposed on completion.
      const skipPromptCache = !execution.promptCache;
      const checkpointEvery = services.checkpointEveryTokens;
      const checkpointEligible = execution.checkpoint;
      const continuation = checkpointEligible ? bindContinuationPolicy({ store: ssdStore!,
        restore: entry => ssdStore!.restore(entry, binding), prompt: promptIds,
        options, execution, identity: services.identity, namespace: cacheNs, persistence: services.checkpointPersistence }) : null;
      releaseContinuation = continuation?.release;
      const checkpointKey = continuation?.key;
      // Both tiers in one call (Layer 0): take() prefers a strictly-longer
      // SSD prefix, restores it zero-copy, and trims — see PromptCache.take.
      const closeCacheLookup = trace?.begin("cache.lookup_restore", {
        mechanism: "serial",
        bypassed: skipPromptCache,
      });
      const checkpoint = continuation?.restore();
      caches = checkpoint?.caches ?? [];
      const resuming = Boolean(checkpoint);
      const generationPromptIds = checkpoint?.cacheTokens ?? promptIds;
      const entry = skipPromptCache || resuming
        ? null
        : promptCache.take(promptIds, cacheNs);
      if (entry) { caches = entry.caches; retain = entry.retain; }
      if (!checkpoint && !entry) caches = binding.makeCache();
      closeCacheLookup?.();
      // Prompt-boundary snapshot (the multi-turn agent fix, 2026-07-04): the
      // prompt+gen entry put() below is UNTRIMMABLE at context > sliding
      // window (wrapped rings) and under quantized KV (mid-group), so any
      // decode→encode roundtrip drift in the reply the client sends back
      // turns the next turn into a total miss (measured: 12B turn-2 TTFT
      // 8.9 s instead of ~0.2 s). A prompt-ONLY entry is always an exact
      // prefix of the next turn's rendering regardless of reply drift.
      // Zero-copy (cloneKvCaches = slice views); only for substantial cold
      // prefills, where the re-prefill it saves is worth an extra entry.
      // The oracle invariant (mlx-lm insert_segments): a trim-free STRICT
      // prefix of the prompt exists for EVERY substantial request — cap the
      // boundary at len-1 so even a stableLen == len prompt (e4b: the
      // template tail survives the probe render) snapshots prompt[:-1]. An
      // exact repeat then matches with trimNeeded == 0, bypassing
      // isTrimmable() entirely — the only reuse path a wrapped ring has.
      const boundary = Math.min(options.snapshotAt ?? promptIds.length, promptIds.length - 1);
      // Re-snapshot on EVERY substantial request whose stable boundary extends
      // past the cached prefix; the clone is zero-copy views, so re-putting
      // is ~free.
      const snapshotBoundary =
        !skipPromptCache && !resuming && boundary >= 256 &&
        boundary > (entry?.tokens.length ?? 0);
      closeMedia = binding.enterMedia?.(vision);
      if (resuming) {
        const replay = generationPromptIds.slice(promptIds.length);
        console.log(
          `[generation-checkpoint] resuming ${checkpointKey} at ` +
          `${replay.length} emitted tokens`,
        );
        for (const token of replay) {
          options.signal?.throwIfAborted();
          if ((await onToken(token)) === false)
            throw new Error("saved generation prefix triggered a terminal stop while replaying");
        }
      }
      const gen = binding.generate(generationPromptIds, {
        ...options,
        decodePolicy: execution,
        ...(resuming ? { seed: checkpoint!.seed } : {}),
        fill: execution.fill ? options.fill : undefined,
        pagedKv, // request-scoped (undefined strips the server-wide flag)
        cache: caches,
        ...(resuming
          ? {
              initialPendingToken: checkpoint!.pendingToken,
              initialGeneratedTokens: checkpoint!.generatedTokens,
              originalPromptTokens: promptIds.length,
            }
          : {}),
        ...(checkpointEligible
          ? {
              checkpointEveryTokens: checkpointEvery,
              onDecodeCheckpoint: async (state: {
                cacheTokens: number[];
                caches: Cache[];
                generatedTokens: number;
                pendingToken: number;
              }) => {
                if (services.checkpointPersistence)
                  continuation!.captureOwned({ ...state, caches: services.cloneState(state.caches) });
                else await continuation!.capture(state);
              },
            }
          : {}),
        ...(snapshotBoundary
          ? {
              // snapshotAt MUST travel with the hook: generate() splits the
              // prefill at exactly this many tokens and fires the hook while
              // the caches hold exactly that prefix — putting boundary
              // tokens against caches at any other offset is silent KV
              // corruption.
              snapshotAt: boundary,
              onPrefillDone: () => {
                try {
                  const snapshot = ownResource(services.cloneState(caches), disposeResources);
                  try {
                    promptCache.put(promptIds.slice(0, boundary), snapshot.borrow(), cacheNs);
                    snapshot.transfer();
                  } finally { snapshot.close(); }
                } catch (e) {
                  console.warn(`prompt-boundary snapshot skipped: ${(e as Error).message}`);
                }
              },
            }
          : {}),
        ...(vision
          ? {
              promptEmbeddings: vision.embeddings,
              ...(vision.imageMask ? { imageMask: vision.imageMask } : {}),
              ...(vision.multimodalMask ? { multimodalMask: vision.multimodalMask } : {}),
            }
          : {}),
      }, { trace, mechanism: "serial" });
      for await (const t of gen) {
        if ((await onToken(t.token, t.logprobs)) === false) break;
      }
      const s = gen.stats!; // set on completion AND on early break
      continuation?.complete();
      if (!skipPromptCache) {
        // put() fires onPut → the debounced write-behind SSD snapshot
        // (wired below), covering the batch lane's puts too.
        promptCache.put(s.cacheTokens, caches, cacheNs, retain);
        caches = []; retain = undefined; // ownership returned to the prefix store
      }
      return s;
    } catch (error) {
      cleanupFailure(error, () => cleanup.close());
    } finally {
      cleanup.close();
    }
  });
}
