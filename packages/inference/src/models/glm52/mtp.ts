import type { MlxArray } from "@mlx-bun/mlx/array";
import type { NativeMtpHead } from "../../contracts/mlx/drafter";
import * as ops from "@mlx-bun/mlx/ops";
import type { Glm52Config } from "../../artifacts/glm52-config";
import type { Glm52WeightSource } from "../../contracts/mlx/glm52-weights";
import type { MLACache } from "../../state/glm52-cache";
import { rmsNormF32Mlx } from "./mla";

/** What the MTP graph reads of the GLM-5.2 model it shares weights with. */
export interface Glm52MtpHost {
  readonly glmConfig: Glm52Config;
  readonly weights: Glm52WeightSource;
  logitsFromHidden(hidden: MlxArray): MlxArray;
}

/** The MTP decoder layer (the layer after the target's last). */
export interface Glm52MtpLayer {
  forwardAsync(input: MlxArray, cache: MLACache, dsaState: null): Promise<MlxArray>;
}

/** Native MTP numerical graph. Tokens, anchor hidden and compressed state may
 * have one or several rows; sampling and state retention belong to callers. */
export class Glm52MtpGraph implements NativeMtpHead {
  constructor(readonly model: Glm52MtpHost, readonly layer: Glm52MtpLayer) {}

  get hiddenSize(): number { return this.model.glmConfig.hiddenSize; }

  get cache(): NativeMtpHead["cache"] {
    const config = this.model.glmConfig;
    return { kvLoraRank: config.kvLoraRank, ropeHeadDim: config.qkRopeHeadDim, maxTokens: config.maxPositionEmbeddings };
  }

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
