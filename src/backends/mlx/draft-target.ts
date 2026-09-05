import type { RuntimeModel } from "../../model/factory";
import { Gemma4Model, type Cache } from "../../model/gemma4";
import { Qwen35Model } from "../../model/qwen3_5";
import type { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import type { TargetView, AssistantTarget } from "../../spec/source";

/** Class checks and live cache layout stay at the compatibility boundary.
 * A replacement graph supplies the same ports without becoming these classes. */
export function bindLegacyDraftTarget(model: RuntimeModel, caches: Cache[]): TargetView {
  if (model instanceof Gemma4Model) {
    let sliding = -1, full = -1;
    for (let i = 0; i < model.numDonors; i++) {
      if (model.layers[i]!.layerType === "sliding_attention") sliding = i;
      else full = i;
    }
    const view = (index: number): [MlxArray, MlxArray] => {
      const cache = caches[index];
      if (!cache || !("temporalView" in cache) || typeof cache.temporalView !== "function")
        throw new Error("assistant target has no plain donor view");
      return cache.temporalView();
    };
    const assistant: AssistantTarget | undefined = sliding >= 0 && full >= 0 ? {
      position: () => caches[0]!.offset - 1,
      embedScaled(token) {
        const ids = ops.fromInt32([token], [1, 1]);
        let embedded: MlxArray | undefined;
        try { embedded = model.embed.encode(ids); return ops.mulScalar(embedded, model.embedScale); }
        finally { ids.dispose(); embedded?.dispose(); }
      },
      readDonors() {
        const slidingView = view(sliding);
        try { return { sliding: slidingView, full: view(full) }; }
        catch (error) { for (const array of slidingView) array.dispose(); throw error; }
      },
    } : undefined;
    return Object.freeze({ identity: model, assistant, gemmaTaps: Object.freeze({
      layerCount: model.layers.length,
      projection: Object.freeze({ embed: model.embed, logitsFromHidden: model.logitsFromHidden.bind(model) }),
    }) });
  }
  if (model instanceof Qwen35Model) return Object.freeze({ identity: model, qwenMtp: Object.freeze({
    hiddenSize: model.config.text.hiddenSize, layerCount: model.config.text.numHiddenLayers,
    embed: model.embed.encode.bind(model.embed), logitsFromHidden: model.logitsFromHidden.bind(model),
  }) });
  return Object.freeze({ identity: model });
}
