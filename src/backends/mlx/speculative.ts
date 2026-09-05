import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { Cache } from "../../model/gemma4";
import type { RuntimeModel } from "../../model/factory";
import type { Sampler } from "../../sampler";
import type { DraftProvider, DraftSource } from "../../spec/source";
import { flagOn } from "../../runtime-config";
import type { SpeculativeTransaction } from "../../inference/rollback";
import { bindCacheRollback } from "./rollback";
import type { GraphDescriptor } from "../../inference/graph";
import { bindLegacyDraftTarget } from "./draft-target";

/** Bound target operations and draft construction for one speculative run.
 * A replacement graph supplies this entire port, including any hidden taps.
 * The verifier never needs a RuntimeModel or an artifact-family check. */
export interface MlxSpeculativeBinding {
  readonly descriptor: GraphDescriptor;
  readonly eosTokenIds: readonly number[];
  readonly prefillTailSplit: boolean;
  makeCache(): Cache[];
  openDraft(sampler: Sampler, caches: Cache[]): DraftSource;
  bindRollback(caches: Cache[]): SpeculativeTransaction;
  forward(ids: MlxArray, caches: Cache[], tapLayers?: number[]):
    Promise<{ hidden: MlxArray; ctxML: MlxArray | null }>;
  projectLogits(hidden: MlxArray): MlxArray;
  /** Establish the implementation's verify kernel context; restore on close. */
  pinVerify?(): { close(): void };
}

/** Legacy mutable tap/kernel fields require the gateway's exclusive lease. */
export function bindLegacySpeculativeModel(model: RuntimeModel, provider: DraftProvider): MlxSpeculativeBinding {
  return {
    descriptor: Object.freeze({ id: `legacy-spec:${model.config.modelType}`, backend: "mlx",
      graphAbi: "mlx-hidden-bsh-v1", stateAbi: "legacy-cache-array-v1", artifact: "legacy-resident-model" }),
    eosTokenIds: model.config.eosTokenIds,
    prefillTailSplit: flagOn("MLX_BUN_PREFILL_TAIL_SPLIT", true),
    makeCache: model.makeCache.bind(model),
    openDraft: (sampler, caches) => provider.open({ sampler, target: bindLegacyDraftTarget(model, caches) }),
    bindRollback: bindCacheRollback,
    forward: (ids, caches, tapLayers) => legacyForwardWithTaps(model, ids, caches, tapLayers),
    projectLogits: model.logitsFromHidden.bind(model),
    ...("setSpecKernelPinned" in model ? {
      pinVerify() {
        model.setSpecKernelPinned(true);
        return { close() { model.setSpecKernelPinned(false); } };
      },
    } : {}),
  };
}

export function assertMlxSpeculativeBinding(binding: MlxSpeculativeBinding): void {
  const descriptor = binding.descriptor;
  if (descriptor.backend !== "mlx" || descriptor.graphAbi !== "mlx-hidden-bsh-v1" ||
      descriptor.stateAbi !== "legacy-cache-array-v1")
    throw new Error(`speculative binding ${descriptor.id} has an incompatible backend, graph, or state ABI`);
}

/** Run one target forward, and when `tapLayers` is set (⟹ a Gemma4 target — a
 *  DSpark-style source), also return the captured multi-layer context
 *  [1,L,m*H] (tapLayers concatenated on the feature axis; index nLayers is the
 *  post-finalNorm sentinel). Non-tapping sources get ctxML=null and never
 *  touch model.hiddenTap. Mirrors generate-dflash.ts forwardTapped. */
async function legacyForwardWithTaps(
  model: RuntimeModel,
  ids: MlxArray,
  caches: Cache[],
  tapLayers: number[] | undefined,
): Promise<{ hidden: MlxArray; ctxML: MlxArray | null }> {
  if (!tapLayers) {
    const asyncModel = model as RuntimeModel & {
      forwardHiddenAsync?: (
        ids: MlxArray,
        caches: Cache[],
      ) => Promise<MlxArray>;
    };
    const hidden = typeof asyncModel.forwardHiddenAsync === "function"
      ? await asyncModel.forwardHiddenAsync(ids, caches)
      : model.forwardHidden(ids, caches);
    return { hidden, ctxML: null };
  }
  if (!("hiddenTap" in model)) throw new Error("target graph does not support hidden taps");
  const m = model;
  const previousTap = m.hiddenTap;
  const cap = new Map<number, MlxArray>();
  m.hiddenTap = { layers: new Set(tapLayers), captured: cap };
  let hidden: MlxArray | null = null;
  try {
    hidden = model.forwardHidden(ids, caches);
    const perLayer = tapLayers.map((li) => {
      const a = cap.get(li);
      if (!a) throw new Error(`spec tap: layer ${li} not captured`);
      return a;
    });
    const ctxML = ops.concatAxis(perLayer, 2); // [1,L,m*H]
    for (const [, a] of cap) a.dispose();
    cap.clear(); // consumed — the finally must not double-dispose
    const out = { hidden, ctxML };
    hidden = null; // ownership returned to the caller
    return out;
  } finally {
    // On any throw (forward mid-capture, missing layer, concat), free the
    // partially-captured tap tensors and the orphaned hidden. On success both
    // are already gone (cap cleared, hidden nulled).
    hidden?.dispose();
    for (const [, a] of cap) a.dispose();
    m.hiddenTap = previousTap;
  }
}
