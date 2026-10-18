import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Glm52.Model
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/glm52/model.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import { bindGraphCaches } from "../cache-composition";
import type { MlxCacheLayer } from "../../contracts/mlx/graph";
// Dedicated GLM-5.2 correctness graph over the direct Colibri artifact.
//
// G2 deliberately favors an auditable dequantize->f32 path. Routed experts are
// resolved by their exact tensor names and composed in route order. G3 swaps
// that expert resolver for bounded slabs/LRU without changing this graph.

import { gpuStream,MlxArray } from "@mlx-bun/mlx/array";
import { synchronize } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../../artifacts/config";
import { loadModelConfig } from "../../artifacts/config";
import {
loadGlm52Config,
type Glm52Config,
} from "../../artifacts/glm52-config";
import { validateGlm52ContainerLayout } from "../../artifacts/glm52/layout";
import { ColibriGlm52ResidentWeights } from "../../artifacts/glm52/resident-weights";
import { ColibriGlm52Weights } from "../../artifacts/glm52/weights";
import { type Cache, type LatentAttentionCache } from "../../contracts/mlx/cache";
import { LoraState } from "../../layers/lora";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import type { MlxRowTable, MlxCapturingForward, MlxDeclaredGraph, MlxHeadForward, MlxKnownOperations, MlxPromptRange, MlxTokenPhases } from "../../contracts/mlx/graph";
import { declareGraph } from "../capabilities";
import { type QuantizedLinear } from "../../layers/quantized-linear";
import type { CacheCodecProvider } from "../../state/persistence-types";
import { BF16_KV, type KvStorageScheme } from "../../contracts/portable/composition";
import {
glm52DsaScoresMlx,
Glm52DsaSelectionState,
type Glm52DsaSelectionObserver,
} from "./dsa";
import { Glm52MtpGraph } from "./mtp";
import { Glm52Mla,partialInterleavedRopeMlx,rmsNormF32Mlx,type Glm52MlaBatchedSelection,GLM52_PHASE_READS,type Glm52PhaseReads } from "./mla";
import {
composeGlm52MoeOutputsMlx,
planGlm52MoeBatchF32,
routeGlm52MoeF32,
type Glm52RoutedExpertOutput,
} from "./moe";
import { Glm52PilotTracker } from "./pilot";
import {
Glm52ExpertRuntime,
type Glm52ExpertRuntimeOptions,
} from "./residency";
import type { Glm52ExpertExecutionBackend } from "./streamed-experts";
import { NATIVE_MTP_DRAFT } from "../drafters";

export interface Glm52ModelCapabilities {
  readonly dsa: boolean;
  /** The artifact contains the complete native MTP metadata/tensor family. */
  readonly mtpMetadata: boolean;
  /** The native MTP weights/tier are loaded for this model instance. */
  readonly mtpEnabled?: boolean;
  /** Draft tokens per round the loaded MTP tier was planned for. */
  readonly mtpDraftTokens?: number;
}

/** The composition's KV scheme and paging, which a GLM-5.2 graph's latent
 * caches compose (`composedLatentCache`): the latent, RoPE key and DSA index
 * key stored as the scheme names, in pages under paging. */
export interface Glm52LatentCaches {
  readonly kv: KvStorageScheme;
  readonly pagedKv: { readonly blockSize: number } | null;
}

/** f32 latent state, unpaged: the checkpoint-native storage (`MLACache`). */
export const GLM52_F32_CACHES: Glm52LatentCaches = Object.freeze({ kv: BF16_KV, pagedKv: null });

export interface Glm52StreamedOpenOptions
extends Omit<Glm52ExpertRuntimeOptions, "fixedBytes"> {
  /** The latent caches' scheme and paging (default f32, unpaged). */
  readonly caches?: Glm52LatentCaches;
  /** KV/transient/allocator/Bun/OS reserve, excluding resident weights. */
  readonly reserveBytes: number;
  /** Internal counterfactual control; indexer weights remain resident. */
  readonly enableDsa?: boolean;
  /**
   * Stage-2 benchmark seam: build long contexts with dense batched prefill,
   * then exercise exact DSA on one-token decode. Normal serving stays exact.
   */
  readonly dsaPrefillMode?: "exact" | "dense-benchmark";
  /** Exact prompt length covered by `dense-benchmark`; required in that mode. */
  readonly dsaBenchmarkPrefillTokens?: number;
}

interface DsaStep {
  readonly key: MlxArray;
  /** Borrowed from the request-local selection state; do not dispose here. */
  readonly selectedPositions: MlxArray | Glm52MlaBatchedSelection | null;
}

/** Native MTP verifies at most gamma+1 rows under the 64-slot expert union. */
const GLM52_DSA_SPARSE_DECODE_BATCH_MAX = 8;

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
    cache: LatentAttentionCache,
    state: Glm52DsaSelectionState,
    forceDense = false,
  ): DsaStep {
    const [batch, tokens, hidden] = input.shape;
    if (hidden !== this.config.hiddenSize)
      throw new Error(`DSA hidden width ${hidden} != ${this.config.hiddenSize}`);

    const positionOffset = batch! > 1
      ? (cache.rowOffsets.length
          ? cache.rowOffsets
          : new Array(batch!).fill(0) as number[])
      : cache.offset;
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
      batch!,
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
    const prior = cache.storedIndexKeys();
    if (prior) {
      allKeys = ops.concatAxis([prior, key], 1);
      prior.dispose();
    }
    const contextLength = allKeys.shape[1]!;
    let selectedPositions: MlxArray | Glm52MlaBatchedSelection | null;
    if (forceDense || contextLength <= this.config.indexTopk) {
      state.selectFullDense(this.layer, contextLength);
      selectedPositions = null;
    } else if (batch! > 1) {
      const rowSelections: Array<MlxArray | null> = [];
      for (let row = 0; row < batch!; row++) {
        const rowContext = (cache.rowOffsets[row] ?? 0) + tokens!;
        if (rowContext <= this.config.indexTopk) {
          rowSelections.push(null);
          continue;
        }
        const pad = contextLength - rowContext;
        const queryRow = query.slice(
          [row, 0, 0, 0],
          [row + 1, 1, this.config.indexNumHeads, this.config.indexHeadDim],
        );
        const query2d = ops.reshape(queryRow, [
          this.config.indexNumHeads,
          this.config.indexHeadDim,
        ]);
        queryRow.dispose();
        const keysRow = allKeys.slice(
          [row, pad, 0],
          [row + 1, contextLength, this.config.indexHeadDim],
        );
        const keys2d = ops.reshape(keysRow, [
          rowContext,
          this.config.indexHeadDim,
        ]);
        keysRow.dispose();
        const weightsRow = headWeights.slice(
          [row, 0, 0],
          [row + 1, 1, this.config.indexNumHeads],
        );
        const weights1d = ops.reshape(weightsRow, [this.config.indexNumHeads]);
        weightsRow.dispose();
        const scores = glm52DsaScoresMlx(query2d, keys2d, weights1d);
        rowSelections.push(state.selectFullDevice(this.layer, scores, row));
        query2d.dispose();
        keys2d.dispose();
        weights1d.dispose();
        scores.dispose();
      }
      selectedPositions = { rows: rowSelections };
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
      selectedPositions = state.selectFullDevice(this.layer, scores);
      query2d.dispose();
      keys2d.dispose();
      weights1d.dispose();
      scores.dispose();
    }
    if (allKeys !== key) allKeys.dispose();
    query.dispose();
    headWeights.dispose();
    return { key, selectedPositions };
  }
}

class Glm52Mlp {
  constructor(
    readonly config: Glm52Config,
    readonly weights: Glm52WeightSource,
    readonly layer: number,
    readonly expertBackend: Glm52ExpertExecutionBackend | null = null,
    readonly pilot: Glm52PilotTracker | null = null,
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
    this.pilot?.observeActual(this.layer, plan.routes);
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
    pilot: Glm52PilotTracker | null = null,
    readonly denseBenchmarkPrefillTokens = 0,
  ) {
    const prefix = `model.layers.${layer}`;
    this.mla = new Glm52Mla(config, weights, layer);
    this.mlp = new Glm52Mlp(config, weights, layer, expertBackend, pilot);
    this.inputNorm = weights.tensor(`${prefix}.input_layernorm.weight`);
    this.postAttentionNorm = weights.tensor(
      `${prefix}.post_attention_layernorm.weight`,
    );
    this.dsa = hasDsa && config.indexerTypes[layer] === "full"
      ? new Glm52DsaIndexer(config, weights, layer)
      : null;
  }

  /**
   * Keep a small sparse verify window batched through residual/MLP while
   * evaluating its causal DSA+MLA attention rows serially. This preserves one
   * exact selection per query without collapsing native MTP into full-model
   * M=1 forwards.
   */
  private attend(
    input: MlxArray,
    cache: LatentAttentionCache,
    dsaState: Glm52DsaSelectionState | null,
    reads: Glm52PhaseReads,
  ): MlxArray {
    const normalized = rmsNormF32Mlx(
      input,
      this.inputNorm,
      this.config.rmsNormEps,
    );
    const batch = input.shape[0]!;
    const tokens = input.shape[1]!;
    const denseBenchmarkPrefill =
      this.denseBenchmarkPrefillTokens > 0 &&
      tokens > 1 &&
      cache.offset + tokens <= this.denseBenchmarkPrefillTokens;
    const sparseVerifyBatch =
      dsaState !== null &&
      tokens > 1 &&
      tokens <= GLM52_DSA_SPARSE_DECODE_BATCH_MAX &&
      cache.offset + tokens > this.config.indexTopk &&
      !denseBenchmarkPrefill;

    try {
      if (sparseVerifyBatch) {
        const rows: MlxArray[] = [];
        try {
          for (let token = 0; token < tokens; token++) {
            const row = normalized.slice(
              [0, token, 0],
              [batch, token + 1, this.config.hiddenSize],
            );
            let dsaKey: MlxArray | null = null;
            let positions: MlxArray | Glm52MlaBatchedSelection | null = null;
            try {
              if (this.dsa) {
                const step = this.dsa.projectAndSelect(
                  row,
                  cache,
                  dsaState,
                );
                dsaKey = step.key;
                positions = step.selectedPositions;
              } else {
                positions = batch > 1
                  ? { rows: Array.from({ length: batch }, (_, row) =>
                      dsaState.selectSharedPositions(this.layer, (cache.rowOffsets[row] ?? 0) + 1, row)) }
                  : dsaState.selectSharedPositions(this.layer, cache.offset + 1);
              }
              rows.push(this.mla.forward(
                row,
                cache,
                dsaKey,
                reads.tokenSerial,
                positions,
              ));
            } finally {
              row.dispose();
              dsaKey?.dispose();
            }
          }
          return ops.concatAxis(rows, 1);
        } finally {
          for (const row of rows) row.dispose();
        }
      }

      let dsaKey: MlxArray | null = null;
      let positions: MlxArray | Glm52MlaBatchedSelection | null = null;
      try {
        if (this.dsa) {
          if (!dsaState) throw new Error("DSA full layer has no selection state");
          const step = this.dsa.projectAndSelect(
            normalized,
            cache,
            dsaState,
            denseBenchmarkPrefill,
          );
          dsaKey = step.key;
          positions = step.selectedPositions;
        } else if (dsaState) {
          positions = denseBenchmarkPrefill || cache.offset + tokens <= this.config.indexTopk
            ? null
            : cache.batchSize !== null && cache.batchSize > 1
            ? {
                rows: cache.rowOffsets.map((offset, row) =>
                  dsaState.selectSharedPositions(
                    this.layer,
                    offset + tokens,
                    row,
                  )
                ),
              }
            : dsaState.selectSharedPositions(
                this.layer,
                cache.offset + tokens,
              );
        }
        return this.mla.forward(
          normalized,
          cache,
          dsaKey,
          reads.window,
          positions,
        );
      } finally {
        dsaKey?.dispose();
      }
    } finally {
      normalized.dispose();
    }
  }

  forward(
    input: MlxArray,
    cache: LatentAttentionCache,
    dsaState: Glm52DsaSelectionState | null,
    reads: Glm52PhaseReads,
  ): MlxArray {
    const attention = this.attend(input, cache, dsaState, reads);
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
    cache: LatentAttentionCache,
    dsaState: Glm52DsaSelectionState | null,
    reads: Glm52PhaseReads,
  ): Promise<MlxArray> {
    const attention = this.attend(input, cache, dsaState, reads);
    const residual = ops.add(input, attention);
    attention.dispose();
    this.mlp.pilot?.predictNext(this.layer, residual);
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

export class Glm52Model implements MlxDeclaredGraph, MlxTokenPhases {
  readonly config: ModelConfig;
  readonly glmConfig: Glm52Config;
  readonly weights: Glm52WeightSource;
  readonly weightsBytes: number;
  readonly capabilities: Glm52ModelCapabilities;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  /** Attends its own compressed MLA storage, which no KV scheme converts. Adapters
   * are not offered on streamed experts. */
  get graphCapabilities(): GraphDeclaration {
    return declareGraph({
      sparseAttention: this.capabilities?.dsa === true,
      nativeDraft: this.capabilities?.mtpEnabled === true
        ? { kind: NATIVE_MTP_DRAFT, numDraftTokens: this.capabilities.mtpDraftTokens ?? 3 } : null,
    });
  }
  /** The checkpoint's native MTP row (`nativeDraft`): the head's numerics over this model's shared
   * embeddings, output head and resident weights. Refused unless the MTP tier is loaded. */
  nativeDraftHead(): Glm52MtpGraph {
    if (!this.capabilities.mtpMetadata)
      throw new Error("GLM-5.2 artifact does not contain a complete MTP row");
    if (this.capabilities.mtpEnabled === false)
      throw new Error("native GLM-5.2 MTP is disabled for this model instance");
    if (this.glmConfig.numNextnPredictLayers !== 1) {
      throw new Error(
        `native GLM-5.2 MTP requires exactly one next-token layer; got ` +
        `${this.glmConfig.numNextnPredictLayers}`,
      );
    }
    const mtpBackend = this.expertRuntime?.mtpExecutor ?? null;
    if (this.expertBackend && !mtpBackend) {
      throw new Error(
        "streamed GLM-5.2 MTP requires the bounded int8 MTP expert tier",
      );
    }
    return new Glm52MtpGraph(this, new Glm52DecoderLayer(
      this.glmConfig,
      this.weights,
      this.glmConfig.numHiddenLayers,
      false,
      mtpBackend,
    ));
  }
  expertResidency(): Record<string, unknown> | null {
    const runtime = this.expertRuntime;
    return runtime ? { main_residency: runtime.manager.snapshot(), mtp_residency: runtime.mtp?.manager.snapshot() ?? null,
      last_turn: runtime.lastTelemetry, last_repin: runtime.lastRepin } : null;
  }
  readonly layers: Glm52DecoderLayer[];
  readonly finalNorm: MlxArray;
  readonly expertBackend: Glm52ExpertExecutionBackend | null;
  readonly expertRuntime: Glm52ExpertRuntime | null;
  readonly pilot: Glm52PilotTracker | null;
  readonly dsaPrefillMode: "exact" | "dense-benchmark";
  readonly dsaBenchmarkPrefillTokens: number;
  #dsaSelectionObserver: Glm52DsaSelectionObserver | null = null;

  constructor(
    weights: Glm52WeightSource,
    config: ModelConfig,
    glmConfig: Glm52Config,
    capabilities: Glm52ModelCapabilities,
    expertBackend: Glm52ExpertExecutionBackend | null = null,
    expertRuntime: Glm52ExpertRuntime | null = null,
    dsaPrefillMode: "exact" | "dense-benchmark" = "exact",
    dsaBenchmarkPrefillTokens = 0,
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
    this.dsaPrefillMode = dsaPrefillMode;
    if (
      !Number.isSafeInteger(dsaBenchmarkPrefillTokens) ||
      dsaBenchmarkPrefillTokens < 0 ||
      (dsaPrefillMode === "dense-benchmark" && dsaBenchmarkPrefillTokens < 1) ||
      (dsaPrefillMode === "exact" && dsaBenchmarkPrefillTokens !== 0)
    ) {
      throw new Error(
        "dense-benchmark DSA prefill requires a positive exact prompt length",
      );
    }
    this.dsaBenchmarkPrefillTokens = dsaBenchmarkPrefillTokens;
    this.expertBackend = expertBackend;
    this.expertRuntime = expertRuntime;
    this.pilot = expertRuntime?.pilotMeasureEnabled
      ? new Glm52PilotTracker({
          config: glmConfig,
          weights,
          hintK: expertRuntime.pilotHintK,
          twoStep: expertRuntime.pilotTwoStep,
          hintSink: expertRuntime.pilotHintK > 0
            ? expertRuntime.manager
            : undefined,
        })
      : null;
    if (this.pilot) expertRuntime!.attachPilot(this.pilot);
    this.layers = Array.from(
      { length: glmConfig.numHiddenLayers },
      (_, layer) => new Glm52DecoderLayer(
        glmConfig,
        weights,
        layer,
        capabilities.dsa,
        expertBackend,
        this.pilot,
        dsaBenchmarkPrefillTokens,
      ),
    );
    this.finalNorm = weights.tensor("model.norm.weight");

    const multiSequencePrompt: MlxCapturingForward = (ids, cache) => this.#forward(ids, cache, GLM52_PHASE_READS.window);
    this.prompt = [{ from: 1, to: Infinity, operation: multiSequencePrompt }];
    this.promptChunk = this.prompt;
    this.multiSequencePrompt = this.prompt;
    this.multiSequencePromptChunk = this.multiSequencePrompt;
    this.appendKnown = [
      { from: 1, to: 1, operation: (ids, cache) => this.#forward(ids, cache, GLM52_PHASE_READS.oneToken) },
      { from: 2, to: Infinity, operation: (ids, cache) => this.#forward(ids, cache, GLM52_PHASE_READS.window) },
    ];
    this.logits = Object.freeze({
      default: (hidden: MlxArray) => this.logitsFromHidden(hidden),
    });
    this.decode = Object.freeze({
      default: (ids: MlxArray, cache: Cache[]) => this.#forward(ids, cache, GLM52_PHASE_READS.oneToken),
    });
    this.verify = Object.freeze({
      default: async (ids: MlxArray, cache: Cache[]) => {
      const executor = this.expertRuntime?.executor;
      executor?.setFixedKernelFamily(true);
      try { return await this.#forward(ids, cache, GLM52_PHASE_READS.window); }
      finally { executor?.setFixedKernelFamily(false); }
    },
    });

  }

  static async open(modelDir: string, caches: Glm52LatentCaches = GLM52_F32_CACHES): Promise<Glm52LoadedModel> {
    const glmConfig = await loadGlm52Config(modelDir);
    const config = await loadModelConfig(modelDir);
    const weights = ColibriGlm52Weights.open(modelDir);
    try {
      const detected = validateGlm52ContainerLayout(
        weights.container,
        glmConfig,
      );
      return bindGraphCaches(new Glm52Model(weights, config, glmConfig, {
        dsa: detected.hasDsa,
        mtpMetadata: detected.hasMtp,
      }, null, null, "exact", 0), caches);
    } catch (error) {
      weights.dispose();
      throw error;
    }
  }

  static async openStreamed(
    modelDir: string,
    options: Glm52StreamedOpenOptions,
  ): Promise<Glm52LoadedModel> {
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
      const {
        enableDsa: _enableDsa,
        dsaPrefillMode,
        dsaBenchmarkPrefillTokens,
        caches,
        ...runtimeOptions
      } = options;
      runtime = await Glm52ExpertRuntime.open(modelDir, glmConfig, {
        ...runtimeOptions,
        fixedBytes: weights.weightsBytes + options.reserveBytes,
      });
      return bindGraphCaches(new Glm52Model(
        weights,
        config,
        glmConfig,
        {
          dsa: detected.hasDsa && options.enableDsa !== false,
          mtpMetadata: detected.hasMtp,
          mtpEnabled: detected.hasMtp && options.enableMtp !== false,
          mtpDraftTokens: options.mtpDraftTokens ?? 3,
        },
        runtime.executor,
        runtime,
        dsaPrefillMode ?? "exact",
        dsaBenchmarkPrefillTokens ?? 0,
      ), caches ?? GLM52_F32_CACHES);
    } catch (error) {
      runtime?.close();
      weights.dispose();
      throw error;
    }
  }

  loraTargets(): Map<string, QuantizedLinear> {
    return new Map();
  }

  /** One latent attention cache per layer, the lego the composition's KV
   *  scheme and paging name for it (`composedLatentCache`): f32 by default, the
   *  latent, RoPE key and (on a DSA layer) index key encoded f32-first under a
   *  quantized scheme, in pages under paging. */
  get cacheLayers(): readonly MlxCacheLayer[] { return this.layers.map(layer=>({kind:"latent" as const,geometry:{kvLoraRank:this.glmConfig.kvLoraRank,ropeHeadDim:this.glmConfig.qkRopeHeadDim,maxTokens:this.glmConfig.maxPositionEmbeddings,...(this.capabilities.dsa && layer.dsa ? {indexHeadDim:this.glmConfig.indexHeadDim}:{})}})); }


  /** Attach probe-only telemetry for selections computed by FULL DSA layers. */
  setDsaSelectionObserver(observer: Glm52DsaSelectionObserver | null): void {
    this.#dsaSelectionObserver = observer;
  }

  /** The scoring forward (`MlxSequenceForward`) of a resident graph; a streamed
   *  graph's forward is asynchronous, and it refuses this. */
  sequenceHidden(ids: MlxArray, cache: Cache[], width: number): MlxArray {
    if (this.expertBackend)
      throw new Error("a streamed GLM graph has no synchronous scoring forward");
    // One row of one token is a one-query read; every wider scoring forward is a window.
    return this.#sequence(ids, cache, width === 1 ? GLM52_PHASE_READS.oneToken : GLM52_PHASE_READS.window);
  }

  #sequence(ids: MlxArray, cache: Cache[], reads: Glm52PhaseReads): MlxArray {
    const tokenCount = ids.shape[1] ?? 1;
    const firstOffset = cache[0]?.offset ?? 0;
    if (
      this.capabilities.dsa &&
      !(
        this.dsaPrefillMode === "dense-benchmark" &&
        firstOffset + tokenCount <= this.dsaBenchmarkPrefillTokens
      ) &&
      tokenCount > 1 &&
      tokenCount > GLM52_DSA_SPARSE_DECODE_BATCH_MAX &&
      firstOffset + tokenCount > this.glmConfig.indexTopk
    ) {
      // Bound sparse-selection state for long prefills while retaining all
      // request rows in each forward. Short verify windows keep the residual
      // and expert graph batched across both requests and query positions.
      const rows: MlxArray[] = [];
      try {
        for (let token = 0; token < tokenCount; token++) {
          const row = ids.slice([0, token], [ids.shape[0]!, token + 1]);
          try {
            rows.push(this.#sequence(row, cache, GLM52_PHASE_READS.oneToken));
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
      return this.forwardEmbeddings(embedded, cache, reads);
    } finally {
      embedded.dispose();
    }
  }

  async #forward(ids: MlxArray, cache: Cache[], reads: Glm52PhaseReads): Promise<MlxArray> {
    const tokenCount = ids.shape[1] ?? 1;
    const firstOffset = cache[0]?.offset ?? 0;
    if (
      this.capabilities.dsa &&
      !(
        this.dsaPrefillMode === "dense-benchmark" &&
        firstOffset + tokenCount <= this.dsaBenchmarkPrefillTokens
      ) &&
      tokenCount > 1 &&
      tokenCount > GLM52_DSA_SPARSE_DECODE_BATCH_MAX &&
      firstOffset + tokenCount > this.glmConfig.indexTopk
    ) {
      const rows: MlxArray[] = [];
      try {
        for (let token = 0; token < tokenCount; token++) {
          const row = ids.slice([0, token], [ids.shape[0]!, token + 1]);
          try {
            rows.push(await this.#forward(row, cache, GLM52_PHASE_READS.oneToken));
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
      return await this.forwardEmbeddingsAsync(embedded, cache, reads);
    } finally {
      embedded.dispose();
    }
  }

  // Each phase names its MLA reads (`GLM52_PHASE_READS`): windows reconstruct, one token per sequence absorbs.
  readonly prompt: readonly MlxPromptRange[];
  readonly promptChunk: typeof this.prompt;
  readonly multiSequencePromptChunk: typeof this.multiSequencePrompt;
  readonly multiSequencePrompt: readonly MlxPromptRange[];

  /** Known tokens: one sequence's tokens are its rows, so the one-row operation is one token. */
  readonly appendKnown: MlxKnownOperations;
  readonly logits: MlxRowTable<MlxHeadForward>;
  readonly decode: MlxRowTable<MlxCapturingForward>;
  /** A verify window on the row-independent M=1 streamed-expert kernel family
   *  (`setFixedKernelFamily`), so a token's experts take the same kernels
   *  whatever rows verify beside it. Composed into the operation: the scheduler
   *  never pins or unpins it. */
  readonly verify: MlxRowTable<MlxCapturingForward>;

  /** The decoder over `embeddings` (borrowed). `cache` holds one latent
   * attention cache per layer (`makeCache`), which each layer's MLA block reads
   * through the read it was built with, attending as the calling phase's
   * `reads` name. */
  forwardEmbeddings(
    embeddings: MlxArray,
    cache: Cache[],
    reads: Glm52PhaseReads,
  ): MlxArray {
    if (cache.length !== this.layers.length)
      throw new Error(`GLM cache has ${cache.length} layers, expected ${this.layers.length}`);
    const dsaState = this.capabilities.dsa
      ? new Glm52DsaSelectionState(
          this.glmConfig.indexTopk,
          this.#dsaSelectionObserver,
        )
      : null;
    // The RuntimeModel contract keeps caller-provided embeddings caller-owned.
    // Take our own handle before entering the consuming layer loop.
    let current = ops.contiguous(embeddings);
    try {
      for (let layer = 0; layer < this.layers.length; layer++) {
        const next = this.layers[layer]!.forward(
          current,
          cache[layer] as LatentAttentionCache,
          dsaState,
          reads,
        );
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
      dsaState?.dispose();
    }
  }

  /** `forwardEmbeddings` over streamed experts, every layer evaluated before the next. */
  async forwardEmbeddingsAsync(
    embeddings: MlxArray,
    cache: Cache[],
    reads: Glm52PhaseReads,
  ): Promise<MlxArray> {
    if (cache.length !== this.layers.length)
      throw new Error(`GLM cache has ${cache.length} layers, expected ${this.layers.length}`);
    const dsaState = this.capabilities.dsa
      ? new Glm52DsaSelectionState(
          this.glmConfig.indexTopk,
          this.#dsaSelectionObserver,
        )
      : null;
    let current = ops.contiguous(embeddings);
    try {
      for (let layer = 0; layer < this.layers.length; layer++) {
        const next = await this.layers[layer]!.forwardAsync(
          current,
          cache[layer] as LatentAttentionCache,
          dsaState,
          reads,
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
      dsaState?.dispose();
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

  dispose(): void {
    this.weights.dispose();
    this.expertRuntime?.close();
  }
}

import { Glm52WeightSource } from "../../contracts/mlx/glm52-weights";
export { type Glm52WeightSource } from "../../contracts/mlx/glm52-weights";

export type Glm52LoadedModel = Glm52Model & { makeCache(): Cache[]; readonly stateCodecs?: CacheCodecProvider };
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Glm52.Model
