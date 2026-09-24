import { readAssistantDonors } from "./assistant-target";
import type { RuntimeModel } from "../../../models/factory";
import { Gemma4Model } from "../../../models/gemma4/model";
import { type Cache } from "../../../contracts/mlx/cache";
import { Qwen35Model } from "../../../models/qwen/qwen3_5";
import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { TargetView } from "../source";

/** Class checks and live cache layout stay at the compatibility boundary.
 * A replacement graph supplies the same ports without becoming these classes. */
export function bindLegacyDraftTarget(model: RuntimeModel, caches: Cache[]): TargetView {
  if (model instanceof Gemma4Model) {
    let sliding = -1, full = -1;
    for (let i = 0; i < model.numDonors; i++) {
      if (model.layers[i]!.layerType === "sliding_attention") sliding = i;
      else full = i;
    }
    return Object.freeze({ identity: model, assistantRows: sliding >= 0 && full >= 0 ? {
      hiddenSize: model.config.text.hiddenSize,
      embed(ids: MlxArray) { using embedded = model.embed.encode(ids); return ops.mulScalar(embedded, model.embedScale); },
      readDonors: () => readAssistantDonors(caches[sliding]!, caches[full]!),
    } : undefined, gemmaTaps: Object.freeze({
      layerCount: model.layers.length,
      projection: Object.freeze({ embed: model.embed, logitsFromHidden: model.logitsFromHidden.bind(model) }),
    }) });
  }
  if (model instanceof Qwen35Model) return Object.freeze({ identity: model, qwenMtp: Object.freeze({
    hiddenSize: model.config.text.hiddenSize, layerCount: model.config.text.numHiddenLayers,
    embed: model.embed.encode.bind(model.embed), logitsFromHidden: model.logitsFromHidden.bind(model),
    vocabularyHead: model.lmHead ? Object.freeze({ w: model.lmHead.w, scales: model.lmHead.scales,
      biases: model.lmHead.biases, spec: model.lmHead.spec, vocabSize: model.config.text.vocabSize }) : undefined,
  }) });
  return Object.freeze({ identity: model });
}
