// Dedicated serial GLM-5.2 correctness graph over the direct Colibri artifact.
//
// G2 deliberately favors an auditable dequantize->f32 path. Routed experts are
// resolved by their exact tensor names and composed in route order. G3 swaps
// that expert resolver for bounded slabs/LRU without changing this graph.

import type { ModelConfig } from "../config";
import { loadModelConfig } from "../config";
import { gpuStream, MlxArray } from "../mlx/array";
import { synchronize } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import {
  argmaxLastPosition,
  LoraState,
  type Cache,
  type QuantizedLinear,
} from "./gemma4-base";
import {
  Glm52DsaSelectionState,
  glm52DsaScoresMlx,
  type Glm52DsaLayerSelection,
} from "./glm52-dsa";
import { MLACache } from "./glm52-cache";
import {
  loadGlm52Config,
  type Glm52Config,
} from "./glm52-config";
import {
  Glm52Mla,
  partialInterleavedRopeMlx,
  rmsNormF32Mlx,
  type Glm52MlaWeightSource,
} from "./glm52-mla";
import { validateGlm52ContainerLayout } from "./glm52-layout";
import {
  composeGlm52MoeOutputsMlx,
  planGlm52MoeBatchF32,
  routeGlm52MoeF32,
  type Glm52RoutedExpertOutput,
} from "./glm52-moe";
import type { Glm52ExpertExecutionBackend } from "./glm52-streamed-experts";
import {
  Glm52ExpertRuntime,
  type Glm52ExpertRuntimeOptions,
} from "./glm52-residency";
import { ColibriGlm52ResidentWeights } from "./glm52-resident-weights";
import { ColibriGlm52Weights } from "./glm52-weights";

export interface Glm52WeightSource extends Glm52MlaWeightSource {
  readonly weightsBytes: number;
  has(name: string): boolean;
  embedding(
    ids: MlxArray,
    name: string,
    vocabSize: number,
    hiddenSize: number,
  ): MlxArray;
  dispose(): void;
}

export interface Glm52ModelCapabilities {
  readonly dsa: boolean;
  /** The artifact contains the complete native MTP metadata/tensor family. */
  readonly mtpMetadata: boolean;
  /** The native MTP weights/tier are loaded for this model instance. */
  readonly mtpEnabled?: boolean;
}

export interface Glm52StreamedOpenOptions
extends Omit<Glm52ExpertRuntimeOptions, "fixedBytes"> {
  /** KV/transient/allocator/Bun/OS reserve, excluding resident weights. */
  readonly reserveBytes: number;
}

interface DsaStep {
  readonly key: MlxArray;
  readonly selection: Glm52DsaLayerSelection;
}

function swiglu(
  source: Glm52WeightSource,
  input: MlxArray,
  prefix: string,
  intermediate: number,
  hidden: number,
): MlxArray {
  const gate = source.linear(
    input,
    `${prefix}.gate_proj.weight`,
    intermediate,
    hidden,
  );
  const up = source.linear(
    input,
    `${prefix}.up_proj.weight`,
    intermediate,
    hidden,
  );
  const activated = ops.silu(gate);
  const product = ops.mul(activated, up);
  gate.dispose();
  up.dispose();
  activated.dispose();
  const output = source.linear(
    product,
    `${prefix}.down_proj.weight`,
    hidden,
    intermediate,
  );
  product.dispose();
  return output;
}

class Glm52DsaIndexer {
  readonly prefix: string;

  constructor(
    readonly config: Glm52Config,
    readonly weights: Glm52WeightSource,
    readonly layer: number,
  ) {
    this.prefix = `model.layers.${layer}.self_attn.indexer`;
  }

  projectAndSelect(
    input: MlxArray,
    cache: MLACache,
    state: Glm52DsaSelectionState,
  ): DsaStep {
    const [batch, tokens, hidden] = input.shape;
    if (batch !== 1)
      throw new Error("G2 DSA correctness path is serial (batch size 1)");
    if (hidden !== this.config.hiddenSize)
      throw new Error(`DSA hidden width ${hidden} != ${this.config.hiddenSize}`);

    const positionOffset = cache.offset;
    const qA = this.weights.linear(
      input,
      `model.layers.${this.layer}.self_attn.q_a_proj.weight`,
      this.config.qLoraRank,
      this.config.hiddenSize,
    );
    const qNorm = rmsNormF32Mlx(
      qA,
      this.weights.tensor(
        `model.layers.${this.layer}.self_attn.q_a_layernorm.weight`,
      ),
      this.config.rmsNormEps,
    );
    qA.dispose();
    const queryFlat = this.weights.linear(
      qNorm,
      `${this.prefix}.wq_b.weight`,
      this.config.indexNumHeads * this.config.indexHeadDim,
      this.config.qLoraRank,
    );
    qNorm.dispose();
    const queryRaw = ops.reshape(queryFlat, [
      batch,
      tokens!,
      this.config.indexNumHeads,
      this.config.indexHeadDim,
    ]);
    queryFlat.dispose();
    const query = partialInterleavedRopeMlx(
      queryRaw,
      positionOffset,
      this.config.qkRopeHeadDim,
      this.config.ropeTheta,
      1,
    );
    queryRaw.dispose();

    const keyRaw = this.weights.linear(
      input,
      `${this.prefix}.wk.weight`,
      this.config.indexHeadDim,
      this.config.hiddenSize,
    );
    const keyNorm = ops.layerNorm(
      keyRaw,
      this.weights.tensor(`${this.prefix}.k_norm.weight`),
      this.weights.tensor(`${this.prefix}.k_norm.bias`),
      1e-6,
    );
    keyRaw.dispose();
    const key = partialInterleavedRopeMlx(
      keyNorm,
      positionOffset,
      this.config.qkRopeHeadDim,
      this.config.ropeTheta,
      1,
    );
    keyNorm.dispose();

    const headWeights = this.weights.linear(
      input,
      `${this.prefix}.weights_proj.weight`,
      this.config.indexNumHeads,
      this.config.hiddenSize,
    );

    let allKeys = key;
    if (cache.dsa?.offset) {
      const prior = cache.dsa.fetch();
      allKeys = ops.concatAxis([prior, key], 1);
      prior.dispose();
    }
    const contextLength = allKeys.shape[1]!;
    let selection: Glm52DsaLayerSelection;
    if (contextLength <= this.config.indexTopk) {
      selection = state.selectFull(
        this.layer,
        new Float32Array(contextLength),
      );
    } else {
      if (tokens !== 1) {
        if (allKeys !== key) allKeys.dispose();
        query.dispose();
        headWeights.dispose();
        key.dispose();
        throw new Error(
          "G2 DSA sparse prefill beyond index_topk is not yet supported; " +
          "use serial decode or a shorter prefill",
        );
      }
      const query2d = ops.reshape(query, [
        this.config.indexNumHeads,
        this.config.indexHeadDim,
      ]);
      const keys2d = ops.reshape(allKeys, [
        contextLength,
        this.config.indexHeadDim,
      ]);
      const weights1d = ops.reshape(headWeights, [
        this.config.indexNumHeads,
      ]);
      const scores = glm52DsaScoresMlx(query2d, keys2d, weights1d);
      selection = state.selectFull(this.layer, scores.toFloat32());
      query2d.dispose();
      keys2d.dispose();
      weights1d.dispose();
      scores.dispose();
    }
    if (allKeys !== key) allKeys.dispose();
    query.dispose();
    headWeights.dispose();
    return { key, selection };
  }
}

class Glm52Mlp {
  constructor(
    readonly config: Glm52Config,
    readonly weights: Glm52WeightSource,
    readonly layer: number,
    readonly expertBackend: Glm52ExpertExecutionBackend | null = null,
  ) {}

  forward(input: MlxArray): MlxArray {
    const prefix = `model.layers.${this.layer}.mlp`;
    if (this.layer < this.config.firstKDenseReplace) {
      return swiglu(
        this.weights,
        input,
        prefix,
        this.config.intermediateSize,
        this.config.hiddenSize,
      );
    }
    if (this.expertBackend)
      throw new Error("streamed GLM routed experts require forwardAsync()");

    const router = this.weights.tensor(`${prefix}.gate.weight`);
    const routerTranspose = ops.transposeAxes(router, [1, 0]);
    const logits = ops.matmul(input, routerTranspose);
    routerTranspose.dispose();
    const logitsHost = logits.toFloat32();
    logits.dispose();
    const correctionBias = this.weights
      .tensor(`${prefix}.gate.e_score_correction_bias`)
      .toFloat32();
    const [batch, tokens] = input.shape;

    const sharedIntermediate =
      this.config.moeIntermediateSize * this.config.numSharedExperts;
    const shared = sharedIntermediate > 0
      ? swiglu(
          this.weights,
          input,
          `${prefix}.shared_experts`,
          sharedIntermediate,
          this.config.hiddenSize,
        )
      : null;

    const batchOutputs: MlxArray[] = [];
    try {
      for (let b = 0; b < batch!; b++) {
        const tokenOutputs: MlxArray[] = [];
        try {
          for (let token = 0; token < tokens!; token++) {
            const base = (b * tokens! + token) * this.config.numRoutedExperts;
            const route = routeGlm52MoeF32(
              logitsHost.subarray(
                base,
                base + this.config.numRoutedExperts,
              ),
              correctionBias,
              {
                topK: this.config.numExpertsPerToken,
                normalize: this.config.normTopkProb,
                routedScale: this.config.routedScalingFactor,
              },
            );
            const row = input.slice(
              [b, token, 0],
              [b + 1, token + 1, this.config.hiddenSize],
            );
            const routed: Array<Glm52RoutedExpertOutput<MlxArray>> = [];
            try {
              for (const expertId of route.indices) {
                routed.push({
                  expertId,
                  output: swiglu(
                    this.weights,
                    row,
                    `${prefix}.experts.${expertId}`,
                    this.config.moeIntermediateSize,
                    this.config.hiddenSize,
                  ),
                });
              }
              const sharedRow = shared?.slice(
                [b, token, 0],
                [b + 1, token + 1, this.config.hiddenSize],
              ) ?? null;
              const output = composeGlm52MoeOutputsMlx(
                route,
                routed,
                sharedRow,
              );
              sharedRow?.dispose();
              tokenOutputs.push(output);
            } finally {
              row.dispose();
              for (const contribution of routed)
                contribution.output.dispose();
            }
          }
          const batchOutput = tokenOutputs.length === 1
            ? tokenOutputs[0]!
            : ops.concatAxis(tokenOutputs, 1);
          batchOutputs.push(batchOutput);
        } finally {
          if (tokenOutputs.length > 1)
            for (const output of tokenOutputs) output.dispose();
        }
      }
      return batchOutputs.length === 1
        ? batchOutputs[0]!
        : ops.concatAxis(batchOutputs, 0);
    } finally {
      shared?.dispose();
      if (batchOutputs.length > 1)
        for (const output of batchOutputs) output.dispose();
    }
  }

  async forwardAsync(input: MlxArray): Promise<MlxArray> {
    const prefix = `model.layers.${this.layer}.mlp`;
    if (this.layer < this.config.firstKDenseReplace || !this.expertBackend)
      return this.forward(input);

    const router = this.weights.tensor(`${prefix}.gate.weight`);
    const routerTranspose = ops.transposeAxes(router, [1, 0]);
    const logits = ops.matmul(input, routerTranspose);
    routerTranspose.dispose();
    const logitsHost = logits.toFloat32();
    logits.dispose();
    const correctionBias = this.weights
      .tensor(`${prefix}.gate.e_score_correction_bias`)
      .toFloat32();
    const [batch, tokens] = input.shape;
    const logitsByRow: Float32Array[] = [];
    for (let row = 0; row < batch! * tokens!; row++) {
      const begin = row * this.config.numRoutedExperts;
      logitsByRow.push(
        logitsHost.subarray(begin, begin + this.config.numRoutedExperts),
      );
    }
    const plan = planGlm52MoeBatchF32(
      logitsByRow,
      correctionBias,
      {
        topK: this.config.numExpertsPerToken,
        normalize: this.config.normTopkProb,
        routedScale: this.config.routedScalingFactor,
      },
    );
    const sharedIntermediate =
      this.config.moeIntermediateSize * this.config.numSharedExperts;
    const shared = sharedIntermediate > 0
      ? swiglu(
          this.weights,
          input,
          `${prefix}.shared_experts`,
          sharedIntermediate,
          this.config.hiddenSize,
        )
      : null;
    try {
      return await this.expertBackend.execute({
        layer: this.layer,
        input,
        plan,
        shared,
      });
    } finally {
      shared?.dispose();
    }
  }
}

export class Glm52DecoderLayer {
  readonly mla: Glm52Mla;
  readonly mlp: Glm52Mlp;
  readonly dsa: Glm52DsaIndexer | null;
  readonly inputNorm: MlxArray;
  readonly postAttentionNorm: MlxArray;

  constructor(
    readonly config: Glm52Config,
    readonly weights: Glm52WeightSource,
    readonly layer: number,
    hasDsa: boolean,
    expertBackend: Glm52ExpertExecutionBackend | null = null,
  ) {
    const prefix = `model.layers.${layer}`;
    this.mla = new Glm52Mla(config, weights, layer);
    this.mlp = new Glm52Mlp(config, weights, layer, expertBackend);
    this.inputNorm = weights.tensor(`${prefix}.input_layernorm.weight`);
    this.postAttentionNorm = weights.tensor(
      `${prefix}.post_attention_layernorm.weight`,
    );
    this.dsa = hasDsa && config.indexerTypes[layer] === "full"
      ? new Glm52DsaIndexer(config, weights, layer)
      : null;
  }

  forward(
    input: MlxArray,
    cache: MLACache,
    dsaState: Glm52DsaSelectionState | null,
  ): MlxArray {
    const normalized = rmsNormF32Mlx(
      input,
      this.inputNorm,
      this.config.rmsNormEps,
    );
    let dsaKey: MlxArray | null = null;
    let selection: Glm52DsaLayerSelection | null = null;
    if (this.dsa) {
      if (!dsaState) throw new Error("DSA full layer has no selection state");
      const step = this.dsa.projectAndSelect(normalized, cache, dsaState);
      dsaKey = step.key;
      selection = step.selection;
    } else if (dsaState) {
      selection = dsaState.selectShared(this.layer, cache.offset + input.shape[1]!);
    }
    const positions = selection?.mode === "sparse"
      ? selection.positions
      : null;
    const attention = this.mla.forward(
      normalized,
      cache,
      dsaKey,
      "auto",
      positions,
    );
    normalized.dispose();
    dsaKey?.dispose();
    const residual = ops.add(input, attention);
    attention.dispose();
    const postNorm = rmsNormF32Mlx(
      residual,
      this.postAttentionNorm,
      this.config.rmsNormEps,
    );
    const feedForward = this.mlp.forward(postNorm);
    postNorm.dispose();
    const output = ops.add(residual, feedForward);
    residual.dispose();
    feedForward.dispose();
    return output;
  }

  async forwardAsync(
    input: MlxArray,
    cache: MLACache,
    dsaState: Glm52DsaSelectionState | null,
  ): Promise<MlxArray> {
    const normalized = rmsNormF32Mlx(
      input,
      this.inputNorm,
      this.config.rmsNormEps,
    );
    let dsaKey: MlxArray | null = null;
    let selection: Glm52DsaLayerSelection | null = null;
    if (this.dsa) {
      if (!dsaState) throw new Error("DSA full layer has no selection state");
      const step = this.dsa.projectAndSelect(normalized, cache, dsaState);
      dsaKey = step.key;
      selection = step.selection;
    } else if (dsaState) {
      selection = dsaState.selectShared(
        this.layer,
        cache.offset + input.shape[1]!,
      );
    }
    const positions = selection?.mode === "sparse"
      ? selection.positions
      : null;
    const attention = this.mla.forward(
      normalized,
      cache,
      dsaKey,
      "auto",
      positions,
    );
    normalized.dispose();
    dsaKey?.dispose();
    const residual = ops.add(input, attention);
    attention.dispose();
    const postNorm = rmsNormF32Mlx(
      residual,
      this.postAttentionNorm,
      this.config.rmsNormEps,
    );
    let feedForward: MlxArray | null = null;
    try {
      feedForward = await this.mlp.forwardAsync(postNorm);
      return ops.add(residual, feedForward);
    } finally {
      postNorm.dispose();
      residual.dispose();
      feedForward?.dispose();
    }
  }
}

export class Glm52Model {
  readonly config: ModelConfig;
  readonly glmConfig: Glm52Config;
  readonly weights: Glm52WeightSource;
  readonly weightsBytes: number;
  readonly capabilities: Glm52ModelCapabilities;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  readonly layers: Glm52DecoderLayer[];
  readonly finalNorm: MlxArray;
  readonly expertBackend: Glm52ExpertExecutionBackend | null;
  readonly expertRuntime: Glm52ExpertRuntime | null;

  constructor(
    weights: Glm52WeightSource,
    config: ModelConfig,
    glmConfig: Glm52Config,
    capabilities: Glm52ModelCapabilities,
    expertBackend: Glm52ExpertExecutionBackend | null = null,
    expertRuntime: Glm52ExpertRuntime | null = null,
  ) {
    if (config.modelType !== "glm_moe_dsa" ||
        glmConfig.modelType !== "glm_moe_dsa") {
      throw new Error("Glm52Model requires glm_moe_dsa configuration");
    }
    if (config.text.numHiddenLayers !== glmConfig.numHiddenLayers)
      throw new Error("generic and dedicated GLM-5.2 configs disagree");
    this.weights = weights;
    this.config = config;
    this.glmConfig = glmConfig;
    this.weightsBytes = weights.weightsBytes;
    this.capabilities = capabilities;
    this.expertBackend = expertBackend;
    this.expertRuntime = expertRuntime;
    this.layers = Array.from(
      { length: glmConfig.numHiddenLayers },
      (_, layer) => new Glm52DecoderLayer(
        glmConfig,
        weights,
        layer,
        capabilities.dsa,
        expertBackend,
      ),
    );
    this.finalNorm = weights.tensor("model.norm.weight");
  }

  static async open(modelDir: string): Promise<Glm52Model> {
    const glmConfig = await loadGlm52Config(modelDir);
    const config = await loadModelConfig(modelDir);
    const weights = ColibriGlm52Weights.open(modelDir);
    try {
      const detected = validateGlm52ContainerLayout(
        weights.container,
        glmConfig,
      );
      return new Glm52Model(weights, config, glmConfig, {
        dsa: detected.hasDsa,
        mtpMetadata: detected.hasMtp,
      });
    } catch (error) {
      weights.dispose();
      throw error;
    }
  }

  static async openStreamed(
    modelDir: string,
    options: Glm52StreamedOpenOptions,
  ): Promise<Glm52Model> {
    const glmConfig = await loadGlm52Config(modelDir);
    const config = await loadModelConfig(modelDir);
    const weights = ColibriGlm52ResidentWeights.open(modelDir, {
      includeMtp: options.enableMtp !== false,
    });
    let runtime: Glm52ExpertRuntime | null = null;
    try {
      const detected = validateGlm52ContainerLayout(
        weights.container,
        glmConfig,
      );
      runtime = await Glm52ExpertRuntime.open(modelDir, glmConfig, {
        ...options,
        fixedBytes: weights.weightsBytes + options.reserveBytes,
      });
      return new Glm52Model(
        weights,
        config,
        glmConfig,
        {
          dsa: detected.hasDsa,
          mtpMetadata: detected.hasMtp,
          mtpEnabled: detected.hasMtp && options.enableMtp !== false,
        },
        runtime.executor,
        runtime,
      );
    } catch (error) {
      runtime?.close();
      weights.dispose();
      throw error;
    }
  }

  loraTargets(): Map<string, QuantizedLinear> {
    return new Map();
  }

  makeCache(): MLACache[] {
    return this.layers.map((layer) => new MLACache({
      kvLoraRank: this.glmConfig.kvLoraRank,
      ropeHeadDim: this.glmConfig.qkRopeHeadDim,
      maxTokens: this.glmConfig.maxPositionEmbeddings,
      ...(this.capabilities.dsa && layer.dsa
        ? { dsa: { headDim: this.glmConfig.indexHeadDim } }
        : {}),
    }));
  }

  /** Pin streamed Q4 expert jobs to the row-independent M=1 kernel family.
   * Native MTP enables this only around the batched target verify forward. */
  setSpecKernelPinned(enabled: boolean): void {
    this.expertRuntime?.executor.setFixedKernelFamily(enabled);
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    if (this.expertBackend)
      throw new Error("streamed GLM model requires forwardHiddenAsync()");
    const tokenCount = ids.shape[1] ?? 1;
    const firstOffset = cache[0]?.offset ?? 0;
    if (
      this.capabilities.dsa &&
      tokenCount > 1 &&
      firstOffset + tokenCount > this.glmConfig.indexTopk
    ) {
      if (ids.shape.length !== 2 || ids.shape[0] !== 1) {
        throw new Error(
          "G2 DSA sparse prefill requires serial [1,T] token ids",
        );
      }
      // Colibri selects independently for every query row. G2 preserves that
      // behavior with a deliberately serial correctness fallback once a
      // multi-token prefill crosses index_topk; G6 may vectorize it.
      const rows: MlxArray[] = [];
      try {
        for (let token = 0; token < tokenCount; token++) {
          const row = ids.slice([0, token], [1, token + 1]);
          try {
            rows.push(this.forwardHidden(row, cache));
          } finally {
            row.dispose();
          }
        }
        if (rows.length === 1) return rows[0]!;
        return ops.concatAxis(rows, 1);
      } finally {
        if (rows.length > 1)
          for (const row of rows) row.dispose();
      }
    }
    const embedded = this.weights.embedding(
      ids,
      "model.embed_tokens.weight",
      this.glmConfig.vocabSize,
      this.glmConfig.hiddenSize,
    );
    try {
      return this.forwardEmbeddings(embedded, cache, null);
    } finally {
      embedded.dispose();
    }
  }

  async forwardHiddenAsync(ids: MlxArray, cache: Cache[]): Promise<MlxArray> {
    const tokenCount = ids.shape[1] ?? 1;
    const firstOffset = cache[0]?.offset ?? 0;
    if (
      this.capabilities.dsa &&
      tokenCount > 1 &&
      firstOffset + tokenCount > this.glmConfig.indexTopk
    ) {
      if (ids.shape.length !== 2 || ids.shape[0] !== 1) {
        throw new Error(
          "G3 DSA sparse prefill requires serial [1,T] token ids",
        );
      }
      const rows: MlxArray[] = [];
      try {
        for (let token = 0; token < tokenCount; token++) {
          const row = ids.slice([0, token], [1, token + 1]);
          try {
            rows.push(await this.forwardHiddenAsync(row, cache));
          } finally {
            row.dispose();
          }
        }
        if (rows.length === 1) return rows[0]!;
        return ops.concatAxis(rows, 1);
      } finally {
        if (rows.length > 1)
          for (const row of rows) row.dispose();
      }
    }
    const embedded = this.weights.embedding(
      ids,
      "model.embed_tokens.weight",
      this.glmConfig.vocabSize,
      this.glmConfig.hiddenSize,
    );
    try {
      return await this.forwardEmbeddingsAsync(embedded, cache, null);
    } finally {
      embedded.dispose();
    }
  }

  forwardEmbeddings(
    embeddings: MlxArray,
    cache: Cache[],
    _bidir: MlxArray | null,
  ): MlxArray {
    if (cache.length !== this.layers.length)
      throw new Error(`GLM cache has ${cache.length} layers, expected ${this.layers.length}`);
    const dsaState = this.capabilities.dsa
      ? new Glm52DsaSelectionState(this.glmConfig.indexTopk)
      : null;
    // The RuntimeModel contract keeps caller-provided embeddings caller-owned.
    // Take our own handle before entering the consuming layer loop.
    let current = ops.contiguous(embeddings);
    for (let layer = 0; layer < this.layers.length; layer++) {
      const layerCache = cache[layer];
      if (!(layerCache instanceof MLACache))
        throw new Error(`GLM layer ${layer} requires MLACache`);
      const next = this.layers[layer]!.forward(
        current,
        layerCache,
        dsaState,
      );
      current.dispose();
      current = next;
    }
    const output = rmsNormF32Mlx(
      current,
      this.finalNorm,
      this.glmConfig.rmsNormEps,
    );
    current.dispose();
    return output;
  }

  async forwardEmbeddingsAsync(
    embeddings: MlxArray,
    cache: Cache[],
    _bidir: MlxArray | null,
  ): Promise<MlxArray> {
    if (cache.length !== this.layers.length)
      throw new Error(`GLM cache has ${cache.length} layers, expected ${this.layers.length}`);
    const dsaState = this.capabilities.dsa
      ? new Glm52DsaSelectionState(this.glmConfig.indexTopk)
      : null;
    let current = ops.contiguous(embeddings);
    try {
      for (let layer = 0; layer < this.layers.length; layer++) {
        const layerCache = cache[layer];
        if (!(layerCache instanceof MLACache))
          throw new Error(`GLM layer ${layer} requires MLACache`);
        const next = await this.layers[layer]!.forwardAsync(
          current,
          layerCache,
          dsaState,
        );
        // The streamed path is a bounded-residency graph. Detach every layer
        // before advancing so dense-prefix and post-expert compose graphs
        // cannot retain transient dequantized weights across layer boundaries.
        next.eval();
        synchronize(gpuStream);
        current.dispose();
        current = next;
      }
      return rmsNormF32Mlx(
        current,
        this.finalNorm,
        this.glmConfig.rmsNormEps,
      );
    } finally {
      current.dispose();
    }
  }

  logitsFromHidden(hidden: MlxArray): MlxArray {
    return this.weights.linear(
      hidden,
      "lm_head.weight",
      this.glmConfig.vocabSize,
      this.glmConfig.hiddenSize,
    );
  }

  forward(tokens: number[] | MlxArray, cache: Cache[]): MlxArray {
    if (this.expertBackend)
      throw new Error("streamed GLM model requires forwardAsync()");
    const ids = Array.isArray(tokens)
      ? ops.fromInt32(tokens, [1, tokens.length])
      : tokens;
    const hidden = this.forwardHidden(ids, cache);
    if (Array.isArray(tokens)) ids.dispose();
    const logits = this.logitsFromHidden(hidden);
    hidden.dispose();
    return logits;
  }

  async forwardAsync(
    tokens: number[] | MlxArray,
    cache: Cache[],
  ): Promise<MlxArray> {
    const offsets = cache.map((layer) => layer.offset);
    const ids = Array.isArray(tokens)
      ? ops.fromInt32(tokens, [1, tokens.length])
      : tokens;
    let hidden: MlxArray | null = null;
    try {
      hidden = await this.forwardHiddenAsync(ids, cache);
      return this.logitsFromHidden(hidden);
    } catch (error) {
      const rollbackErrors: unknown[] = [];
      for (let layer = 0; layer < cache.length; layer++) {
        const appended = cache[layer]!.offset - offsets[layer]!;
        if (appended <= 0) continue;
        try {
          cache[layer]!.trim(appended, true);
        } catch (rollbackError) {
          rollbackErrors.push(rollbackError);
        }
      }
      if (rollbackErrors.length) {
        throw new AggregateError(
          [error, ...rollbackErrors],
          "streamed GLM forward failed and cache rollback was incomplete",
        );
      }
      throw error;
    } finally {
      hidden?.dispose();
      if (Array.isArray(tokens)) ids.dispose();
    }
  }

  generate(
    promptTokens: number[],
    maxTokens: number,
    eosIds: number[] = this.glmConfig.eosTokenIds,
  ): number[] {
    const cache = this.makeCache();
    const output: number[] = [];
    try {
      let tokens = promptTokens;
      for (let step = 0; step < maxTokens; step++) {
        const logits = this.forward(tokens, cache);
        const next = argmaxLastPosition(logits);
        logits.dispose();
        if (eosIds.includes(next)) break;
        output.push(next);
        tokens = [next];
      }
      return output;
    } finally {
      for (const layer of cache) layer.dispose();
      this.expertRuntime?.flushUsage();
    }
  }

  async generateAsync(
    promptTokens: number[],
    maxTokens: number,
    eosIds: number[] = this.glmConfig.eosTokenIds,
  ): Promise<number[]> {
    const cache = this.makeCache();
    const output: number[] = [];
    try {
      let tokens = promptTokens;
      for (let step = 0; step < maxTokens; step++) {
        const logits = await this.forwardAsync(tokens, cache);
        const next = argmaxLastPosition(logits);
        logits.dispose();
        if (eosIds.includes(next)) break;
        output.push(next);
        tokens = [next];
      }
      return output;
    } finally {
      for (const layer of cache) layer.dispose();
      await this.expertRuntime?.finishUsage();
    }
  }

  dispose(): void {
    this.weights.dispose();
    this.expertRuntime?.close();
  }
}
