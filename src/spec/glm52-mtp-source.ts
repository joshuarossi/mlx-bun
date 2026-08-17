// Native GLM-5.2 MTP draft source.
//
// The target and MTP row share embeddings, the output head, and the resident
// dense target weights. Only the MTP layer's own dense tensors and int8 routed
// experts add model weight residency. The generic speculative serve loop owns
// verification, grammar composition, target-cache rollback, sampling, and
// telemetry. Prompt lookup remains the model-free alternative DraftProvider;
// selecting one provider per request prevents two independent draft histories
// from advancing the target or grammar state twice.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { toLogprobs } from "../sampler";
import { Glm52DecoderLayer, Glm52Model } from "../model/glm52";
import { MLACache } from "../model/glm52-cache";
import { rmsNormF32Mlx } from "../model/glm52-mla";
import type { DraftProvider, DraftSource } from "./source";

type Sampler = (logprobs: MlxArray, step: number) => MlxArray;

function lastToken(feed: readonly number[]): number {
  const token = feed.at(-1);
  if (!Number.isSafeInteger(token) || token! < 0)
    throw new Error("native MTP requires a non-empty non-negative token feed");
  return token!;
}

export class Glm52NativeMtpProvider implements DraftProvider {
  readonly id = "glm52-native-mtp";
  readonly weightsBytes = 0;
  readonly #layer: Glm52DecoderLayer;

  constructor(readonly model: Glm52Model) {
    if (!model.capabilities.mtpMetadata)
      throw new Error("GLM-5.2 artifact does not contain a complete MTP row");
    if (model.capabilities.mtpEnabled === false)
      throw new Error("native GLM-5.2 MTP is disabled for this model instance");
    if (model.glmConfig.numNextnPredictLayers !== 1) {
      throw new Error(
        `native GLM-5.2 MTP requires exactly one next-token layer; got ` +
        `${model.glmConfig.numNextnPredictLayers}`,
      );
    }
    const mtpBackend = model.expertRuntime?.mtpExecutor ?? null;
    if (model.expertBackend && !mtpBackend) {
      throw new Error(
        "streamed GLM-5.2 MTP requires the bounded int8 MTP expert tier",
      );
    }
    this.#layer = new Glm52DecoderLayer(
      model.glmConfig,
      model.weights,
      model.glmConfig.numHiddenLayers,
      false,
      mtpBackend,
    );
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    if (opts.target.model !== this.model)
      throw new Error("native MTP provider was opened for a different target");
    return new Glm52NativeMtpSource(this.model, this.#layer, opts.sampler);
  }

  dispose(): void {
    // The target model owns every shared/MTP weight and the expert tier.
  }
}

export class Glm52NativeMtpSource implements DraftSource {
  readonly prefillMode = "full" as const;
  readonly pinTargetKernelFamily = true;
  readonly weightsBytes = 0;
  #cache: MLACache;
  #roundStart = 0;
  #lastDraftCount = 0;
  #closed = false;

  constructor(
    readonly model: Glm52Model,
    readonly layer: Glm52DecoderLayer,
    readonly sampler: Sampler,
  ) {
    this.#cache = new MLACache({
      kvLoraRank: model.glmConfig.kvLoraRank,
      ropeHeadDim: model.glmConfig.qkRopeHeadDim,
      maxTokens: model.glmConfig.maxPositionEmbeddings,
      role: "mtp",
    });
  }

  get cacheOffset(): number {
    return this.#cache.offset;
  }

  get cacheBytes(): number {
    return this.#cache.byteLength;
  }

  /** Caller-owned zero-copy snapshot for the v3 KV persistence writer. */
  clonePersistentCache(): MLACache {
    this.#checkOpen();
    if (this.#lastDraftCount !== 0)
      throw new Error("native MTP cache cannot snapshot an uncommitted round");
    if (this.#cache.offset === 0)
      throw new Error("native MTP cache cannot snapshot empty state");
    const state = this.#cache.fetch();
    const clone = new MLACache({
      kvLoraRank: this.#cache.kvLoraRank,
      ropeHeadDim: this.#cache.ropeHeadDim,
      maxTokens: this.#cache.maxTokens,
      role: "mtp",
    });
    try {
      clone.restoreCompressedState(state.latent, state.rope, null, this.#cache.offset);
      return clone;
    } catch (error) {
      state.latent.dispose();
      state.rope.dispose();
      clone.dispose();
      throw error;
    }
  }

  /**
   * Adopt one restored `mtp-mla` cache. Ownership transfers only after every
   * role/geometry/offset check passes; the source disposes it thereafter.
   */
  restorePersistentCache(cache: MLACache): void {
    this.#checkOpen();
    if (this.#lastDraftCount !== 0)
      throw new Error("native MTP cache cannot restore during a draft round");
    if (this.#cache.offset !== 0)
      throw new Error("native MTP cache restore requires an empty source");
    if (cache.role !== "mtp" || cache.dsa)
      throw new Error("native MTP restore requires one mtp-mla cache");
    if (
      cache.kvLoraRank !== this.#cache.kvLoraRank ||
      cache.ropeHeadDim !== this.#cache.ropeHeadDim ||
      cache.maxTokens !== this.#cache.maxTokens
    ) {
      throw new Error("native MTP restored cache geometry does not match model");
    }
    if (cache.offset <= 0 || cache.batchSize !== 1)
      throw new Error("native MTP restored cache must contain one non-empty row");
    this.#cache.dispose();
    this.#cache = cache;
    this.#roundStart = cache.offset;
  }

  prefill(_promptIds: number[]): void {
    this.#checkOpen();
    if (this.#cache.offset !== 0)
      throw new Error("native MTP source cannot be prefilled twice");
    // Direct Colibri intentionally leaves MTP KV empty here ("niente
    // prefill"): its first draft opens a decode-only window from the target
    // anchor hidden and pending token. Seeding this cache with the prompt
    // would change both the oracle state and the first speculative round.
  }

  async draft(
    feed: number[],
    n: number,
    stepBase: number,
    anchorHidden?: MlxArray,
  ): Promise<number[]> {
    this.#checkOpen();
    if (!anchorHidden)
      throw new Error("native MTP drafting requires the target anchor hidden");
    if (!Number.isSafeInteger(n) || n < 0)
      throw new Error(`native MTP draft length must be non-negative; got ${n}`);
    if (this.#lastDraftCount !== 0)
      throw new Error("native MTP draft called before the prior round committed");
    const [batch, tokens, hidden] = anchorHidden.shape;
    if (batch !== 1 || tokens !== 1 || hidden !== this.model.glmConfig.hiddenSize) {
      throw new Error(
        `native MTP anchor must be [1,1,${this.model.glmConfig.hiddenSize}], ` +
        `got [${anchorHidden.shape.join(",")}]`,
      );
    }

    this.#roundStart = this.#cache.offset;
    let token = lastToken(feed);
    let state: MlxArray | null = ops.contiguous(anchorHidden);
    const drafts: number[] = [];
    try {
      for (let position = 0; position < n; position++) {
        const nextState = await this.#step(token, state, stepBase + position);
        state.dispose();
        state = nextState.hidden;
        token = nextState.token;
        drafts.push(token);
      }
      this.#lastDraftCount = drafts.length;
      return drafts;
    } catch (error) {
      const appended = this.#cache.offset - this.#roundStart;
      if (appended > 0) this.#cache.trim(appended);
      throw error;
    } finally {
      state?.dispose();
    }
  }

  async commit(
    d: number,
    kAccept: number,
    vCtxML?: MlxArray,
    verifiedHidden?: MlxArray,
    acceptedTokens: readonly number[] = [],
  ): Promise<void> {
    this.#checkOpen();
    vCtxML?.dispose();
    if (d !== this.#lastDraftCount)
      throw new Error(`native MTP commit d=${d}, expected ${this.#lastDraftCount}`);
    if (!Number.isSafeInteger(kAccept) || kAccept < 0 || kAccept > d)
      throw new Error(`native MTP accepted ${kAccept} outside [0,${d}]`);
    if (acceptedTokens.length !== kAccept)
      throw new Error(
        `native MTP received ${acceptedTokens.length} accepted tokens for k=${kAccept}`,
      );
    if (kAccept > 0 && !verifiedHidden)
      throw new Error("native MTP absorption requires verified target hidden rows");

    try {
      // Only the first speculative MTP row is conditioned on a true target
      // hidden. Later rows use earlier MTP hiddens, so accepted positions are
      // rebuilt below from the target's verified hidden window.
      const speculativeTail = Math.max(d - 1, 0);
      if (speculativeTail > 0) this.#cache.trim(speculativeTail);
      if (kAccept > 0)
        await this.#absorb(acceptedTokens, verifiedHidden!);
      const expected = this.#roundStart + (d > 0 ? 1 : 0) + kAccept;
      if (this.#cache.offset !== expected) {
        throw new Error(
          `native MTP cache committed to ${this.#cache.offset}, expected ${expected}`,
        );
      }
    } catch (error) {
      const appended = this.#cache.offset - this.#roundStart;
      if (appended > 0) this.#cache.trim(appended);
      throw error;
    } finally {
      this.#lastDraftCount = 0;
    }
  }

  dispose(): void {
    if (this.#closed) return;
    this.#closed = true;
    this.#cache.dispose();
  }

  async #step(
    token: number,
    hidden: MlxArray,
    sampleStep: number,
  ): Promise<{ hidden: MlxArray; token: number }> {
    const config = this.model.glmConfig;
    const ids = ops.fromInt32([token], [1, 1]);
    let embedded: MlxArray | null = null;
    let embeddedNorm: MlxArray | null = null;
    let hiddenNorm: MlxArray | null = null;
    let joined: MlxArray | null = null;
    let projected: MlxArray | null = null;
    let output: MlxArray | null = null;
    let headInput: MlxArray | null = null;
    let logits: MlxArray | null = null;
    let logprobs: MlxArray | null = null;
    let sampled: MlxArray | null = null;
    try {
      embedded = this.model.weights.embedding(
        ids,
        "model.embed_tokens.weight",
        config.vocabSize,
        config.hiddenSize,
      );
      embeddedNorm = rmsNormF32Mlx(
        embedded,
        this.model.weights.tensor(
          `model.layers.${config.numHiddenLayers}.enorm.weight`,
        ),
        config.rmsNormEps,
      );
      hiddenNorm = rmsNormF32Mlx(
        hidden,
        this.model.weights.tensor(
          `model.layers.${config.numHiddenLayers}.hnorm.weight`,
        ),
        config.rmsNormEps,
      );
      joined = ops.concatAxis([embeddedNorm, hiddenNorm], 2);
      projected = this.model.weights.linear(
        joined,
        `model.layers.${config.numHiddenLayers}.eh_proj.weight`,
        config.hiddenSize,
        2 * config.hiddenSize,
      );
      output = await this.layer.forwardAsync(projected, this.#cache, null);
      headInput = rmsNormF32Mlx(
        output,
        this.model.weights.tensor(
          `model.layers.${config.numHiddenLayers}.shared_head.norm.weight`,
        ),
        config.rmsNormEps,
      );
      logits = this.model.logitsFromHidden(headInput);
      logprobs = toLogprobs(logits);
      sampled = this.sampler(logprobs, sampleStep);
      return {
        hidden: ops.contiguous(output),
        token: ops.itemUint32(sampled),
      };
    } finally {
      ids.dispose();
      embedded?.dispose();
      embeddedNorm?.dispose();
      hiddenNorm?.dispose();
      joined?.dispose();
      projected?.dispose();
      output?.dispose();
      headInput?.dispose();
      logits?.dispose();
      logprobs?.dispose();
      sampled?.dispose();
    }
  }

  async #absorb(
    acceptedTokens: readonly number[],
    verifiedHidden: MlxArray,
  ): Promise<void> {
    const config = this.model.glmConfig;
    const k = acceptedTokens.length;
    const ids = ops.fromInt32([...acceptedTokens], [1, k]);
    let embedded: MlxArray | null = null;
    let embeddedNorm: MlxArray | null = null;
    let trueRows: MlxArray | null = null;
    let hiddenNorm: MlxArray | null = null;
    let joined: MlxArray | null = null;
    let projected: MlxArray | null = null;
    let output: MlxArray | null = null;
    try {
      embedded = this.model.weights.embedding(
        ids,
        "model.embed_tokens.weight",
        config.vocabSize,
        config.hiddenSize,
      );
      embeddedNorm = rmsNormF32Mlx(
        embedded,
        this.model.weights.tensor(
          `model.layers.${config.numHiddenLayers}.enorm.weight`,
        ),
        config.rmsNormEps,
      );
      trueRows = verifiedHidden.slice(
        [0, 0, 0],
        [1, k, config.hiddenSize],
      );
      hiddenNorm = rmsNormF32Mlx(
        trueRows,
        this.model.weights.tensor(
          `model.layers.${config.numHiddenLayers}.hnorm.weight`,
        ),
        config.rmsNormEps,
      );
      joined = ops.concatAxis([embeddedNorm, hiddenNorm], 2);
      projected = this.model.weights.linear(
        joined,
        `model.layers.${config.numHiddenLayers}.eh_proj.weight`,
        config.hiddenSize,
        2 * config.hiddenSize,
      );
      output = await this.layer.forwardAsync(projected, this.#cache, null);
      output.eval();
    } finally {
      ids.dispose();
      embedded?.dispose();
      embeddedNorm?.dispose();
      trueRows?.dispose();
      hiddenNorm?.dispose();
      joined?.dispose();
      projected?.dispose();
      output?.dispose();
    }
  }

  #checkOpen(): void {
    if (this.#closed) throw new Error("native MTP source is closed");
  }
}
