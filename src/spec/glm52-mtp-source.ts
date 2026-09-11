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
import { Glm52MtpGraph } from "./glm52-mtp-graph";
import type { DraftProvider, DraftSource, GroupedDraftProvider, TargetView, DraftRowSampling, DraftRowCheckpoint, DraftRowGroup, DraftPrefillGroup } from "./source";
import { Glm52MtpRows, type Glm52MtpRowState } from "./glm52-mtp-rows";
import { captureGlm52MtpState, restoreGlm52MtpState } from "./glm52-mtp-state";
import { applyStateChanges, disposeResources } from "../engine/resources";

type Sampler = (logprobs: MlxArray, step: number) => MlxArray;

function lastToken(feed: readonly number[]): number {
  const token = feed.at(-1);
  if (!Number.isSafeInteger(token) || token! < 0)
    throw new Error("native MTP requires a non-empty non-negative token feed");
  return token!;
}

export class Glm52NativeMtpProvider implements DraftProvider {
  readonly grouped: GroupedDraftProvider = {
    open: options => this.#openRows(options.target, options.sampling, options.checkpoints),
    openPrefill: options => this.#openRows(options.target, null, options.checkpoints),
  };
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
    if (opts.target.identity !== this.model)
      throw new Error("native MTP provider was opened for a different target");
    return new Glm52NativeMtpSource(this.model, this.#layer, opts.sampler);
  }

  #openRows(target: TargetView, sampling: DraftRowSampling | null,
    checkpoints: readonly (DraftRowCheckpoint | null)[]): DraftRowGroup & DraftPrefillGroup {
    if (target.identity !== this.model) throw new Error("native MTP provider was opened for a different target");
    const rows = new Glm52MtpRows(new Glm52MtpGraph(this.model, this.#layer), sampling);
    const prepareAppend = (checkpoints: readonly (DraftRowCheckpoint | null)[]) => {
      const states: (Glm52MtpRowState | null)[] = [];
      try {
        for (const checkpoint of checkpoints) states.push(checkpoint ? restoreGlm52MtpState(checkpoint, () => rows.makeCache()) : null);
        return rows.prepareAppend(states);
      } finally { disposeResources(states.flatMap(state => state ? [state.cache, state.hidden] : [])); }
    };
    const append = (states: readonly (DraftRowCheckpoint | null)[]) => applyStateChanges([() => prepareAppend(states)]);
    try { append(checkpoints); } catch (error) { rows.dispose(); throw error; }
    return {
      namespace: "glm52-native-mtp-v1", prefillMode: "full", tapLayers: [],
      get rowCount() { return rows.rowCount; },
      append, prepareAppend, prefill: (tokens, context) => rows.prefill(tokens, context!),
      materialize: rows.materialize.bind(rows), filterRows: rows.filterRows.bind(rows),
      draft: rows.draft.bind(rows), commit: rows.commit.bind(rows),
      capture(row) {
        const state = rows.extractRow(row);
        try { return captureGlm52MtpState(state); }
        finally { state.cache.dispose(); state.hidden.dispose(); }
      },
      dispose: rows.dispose.bind(rows),
    };
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
  readonly #graph: Glm52MtpGraph;
  #roundStart = 0;
  #lastDraftCount = 0;
  #closed = false;

  constructor(
    readonly model: Glm52Model,
    readonly layer: Glm52DecoderLayer,
    readonly sampler: Sampler,
  ) {
    this.#graph = new Glm52MtpGraph(model, layer);
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
    using ids = ops.fromInt32([token], [1, 1]);
    using output = await this.#graph.forward(ids, hidden, this.#cache);
    using logits = this.#graph.project(output);
    // Sampling consumes [B,V], independently of the graph's token dimension.
    using flat = ops.reshape(logits, [1, logits.shape.at(-1)!]);
    using logprobs = toLogprobs(flat);
    using sampled = this.sampler(logprobs, sampleStep);
    return { hidden: ops.contiguous(output), token: ops.itemUint32(sampled) };
  }

  async #absorb(acceptedTokens: readonly number[], verifiedHidden: MlxArray): Promise<void> {
    const count = acceptedTokens.length;
    using ids = ops.fromInt32([...acceptedTokens], [1, count]);
    using trueRows = verifiedHidden.slice([0, 0, 0], [1, count, this.model.glmConfig.hiddenSize]);
    using output = await this.#graph.forward(ids, trueRows, this.#cache);
    output.eval();
  }

  #checkOpen(): void {
    if (this.#closed) throw new Error("native MTP source is closed");
  }
}
