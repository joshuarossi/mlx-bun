import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { Glm52DecoderLayer, Glm52Model } from "../model/glm52";
import type { MLACache } from "../model/glm52-cache";
import { rmsNormF32Mlx } from "../model/glm52-mla";

/** Native MTP numerical graph. Tokens, anchor hidden and compressed state may
 * have one or several rows; sampling and state retention belong to callers. */
export class Glm52MtpGraph {
  constructor(readonly model: Glm52Model, readonly layer: Glm52DecoderLayer) {}

  async forward(ids: MlxArray, hidden: MlxArray, cache: MLACache): Promise<MlxArray> {
    const { glmConfig: config, weights } = this.model;
    const prefix = `model.layers.${config.numHiddenLayers}`;
    using embedded = weights.embedding(ids, "model.embed_tokens.weight", config.vocabSize, config.hiddenSize);
    using embeddedNorm = rmsNormF32Mlx(embedded, weights.tensor(`${prefix}.enorm.weight`), config.rmsNormEps);
    using hiddenNorm = rmsNormF32Mlx(hidden, weights.tensor(`${prefix}.hnorm.weight`), config.rmsNormEps);
    using joined = ops.concatAxis([embeddedNorm, hiddenNorm], 2);
    using projected = weights.linear(joined, `${prefix}.eh_proj.weight`, config.hiddenSize, 2 * config.hiddenSize);
    return await this.layer.forwardAsync(projected, cache, null);
  }

  project(hidden: MlxArray): MlxArray {
    const { glmConfig: config, weights } = this.model;
    using normalized = rmsNormF32Mlx(hidden,
      weights.tensor(`model.layers.${config.numHiddenLayers}.shared_head.norm.weight`), config.rmsNormEps);
    return this.model.logitsFromHidden(normalized);
  }
}
