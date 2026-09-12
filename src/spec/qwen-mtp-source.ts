// Native Qwen3.8 MTP draft source — the Qwen-TRAINED multi-step prediction
// head, split from the raw release's last shard and published as
// mlx-community/Qwen3.8-27B-MTP-* (model_type "qwen3_5_mtp", block_size 3).
//
// Reference implementation (locate + port + gate, don't design):
// mlx_vlm/speculative/drafters/qwen3_5_mtp/qwen3_5_mtp.py. Mechanism, per
// step: h = fc(concat(rms_emb(embed(token)), rms_hidden(hidden))) → ONE
// full-attention decoder layer (own KVCache, positions continue the target
// sequence) → norm → the TARGET's lm_head → next draft token; recursive for
// the block ("trained with multiple steps"). The drafter is NOT standalone:
// it binds the target's embed_tokens + lm_head (mtp_use_dedicated_embeddings
// false) and consumes the target's PRE-final-norm last-layer hidden (mlx-vlm
// captures it with skip_final_norm=True) — carried here by the tapLayers
// machinery, NOT the seam's post-norm anchorHidden.
//
// Row convention (predict-2-ahead): drafter KV row at position p is built
// from (embed(token at position p+1), hidden at position p). Invariant
// across rounds: after commit, the drafter offset equals the next pending
// token's position minus zero — i.e. draft() always opens by building the
// pending token's row from the TARGET's TRUE hidden at the emitted position
// (held over from the verify tap). Computationally identical to mlx-vlm's
// commit-time "seed" append, just performed at the top of the next round.
//
// Companion projections may be dense or quantized according to their metadata.
// Published drafter norms are already sanitized to runtime layout; no +1.0 shift.

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { materializeCopy } from "../mlx/materialize";
import { toLogprobs } from "../sampler";
import { loadModelConfig, type ModelConfig } from "../config";
import { Weights } from "../weights";
import { KVCache } from "../model/gemma4-base";
import { MtpModule } from "./qwen-mtp-module";
import type { DraftProvider, DraftSource, DraftRowCheckpoint, DraftRowGroup, DraftPrefillGroup, DraftRowSampling, GroupedDraftProvider, QwenMtpTarget, TargetView } from "./source";
import { QwenMtpRows, type MtpRowState } from "./qwen-mtp-rows";
import { captureQwenMtpState, restoreQwenMtpState } from "./qwen-mtp-state";
import type { Cache } from "../model/gemma4";
import { applyStateChanges, cleanupFailure, disposeResources } from "../engine/resources";
import { artifactIdentity } from "../model/artifact-identity";
import { configFingerprint } from "../model/fingerprint";
import type { PreparedStateChange } from "../contracts/resources";

type Sampler = (logprobs: MlxArray, step: number) => MlxArray;

const DRAFT_PREFILL_CHUNK = 2048;

export class QwenMtpProvider implements DraftProvider {
  readonly grouped: GroupedDraftProvider = {
    checkpointNamespace: () => this.#checkpointNamespace,
    open: options => this.#openRows(options.target, options.sampling, options.checkpoints),
    openPrefill: options => this.#openRows(options.target, null, options.checkpoints),
  };
  readonly id: string;
  readonly weightsBytes: number;
  readonly #module: MtpModule;
  readonly #config: ModelConfig;
  readonly #resources: DisposableStack;
  readonly #checkpointNamespace: string;

  private constructor(id: string, config: ModelConfig, weightsBytes: number, module: MtpModule, resources: DisposableStack, checkpointNamespace: string) {
    this.id = id;
    this.#config = config;
    this.#module = module;
    this.weightsBytes = weightsBytes;
    this.#resources = resources;
    this.#checkpointNamespace = checkpointNamespace;
  }

  static async load(dir: string): Promise<QwenMtpProvider> {
    const config = await loadModelConfig(dir);
    if (config.modelType !== "qwen3_5_mtp")
      throw new Error(`${dir}: not a qwen3_5_mtp drafter (model_type ${config.modelType})`);
    const weights = await Weights.open(dir);
    using resources = new DisposableStack();
    resources.defer(() => weights.dispose());
    const weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    const module = new MtpModule(weights, config, resources);
    // Stable across restarts and distinct for differently folded/quantized
    // companions. Hash once at provider load, outside inference execution.
    const identity = await artifactIdentity(configFingerprint(config),
      [...weights.shards.files].map(([name, shard]) => ({ name, path: shard.path })));
    return new QwenMtpProvider(
      dir.split("/").filter(Boolean).at(-1) ?? "qwen-mtp",
      config, weightsBytes, module, resources.move(), `qwen-mtp-v1:${identity}`,
    );
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    return new QwenMtpSource(this.#target(opts.target), this.#module, opts.sampler, this.#checkpointNamespace);
  }

  #target(view: TargetView): QwenMtpTarget {
    if (this.#resources.disposed)
      throw new Error("qwen MTP provider is disposed");
    const target = view.qwenMtp;
    if (!target)
      throw new Error("qwen MTP drafting requires a qwen3_5-family target");
    if (target.hiddenSize !== this.#config.text.hiddenSize) {
      throw new Error(
        `qwen MTP drafter hidden ${this.#config.text.hiddenSize} != target ` +
        `${target.hiddenSize} — split from a different checkpoint?`,
      );
    }
    return target;
  }

  #openRows(view: TargetView, sampling: DraftRowSampling | null,
    checkpoints: readonly (DraftRowCheckpoint | null)[]): DraftRowGroup & DraftPrefillGroup {
    const target = this.#target(view);
    const rows = new QwenMtpRows(target, this.#module, sampling, []);
    const prepareAppend = (checkpoints: readonly (DraftRowCheckpoint | null)[]) => {
      const states: Array<MtpRowState | null> = [];
      let change: PreparedStateChange | undefined;
      try {
        for (const checkpoint of checkpoints) states.push(checkpoint ? restoreQwenMtpState(checkpoint) : null);
        change = rows.prepareAppend(states);
        disposeResources(states.splice(0).flatMap(state => state ? [state.cache, state.hidden] : []));
        return change;
      } catch (error) {
        return cleanupFailure(error, () => disposeResources([
          ...states.flatMap(state => state ? [state.cache, state.hidden] : []), ...(change ? [change] : []),
        ]));
      }
    };
    const append = (checkpoints: readonly (DraftRowCheckpoint | null)[]) => applyStateChanges([() => prepareAppend(checkpoints)]);
    try { append(checkpoints); }
    catch (error) { return cleanupFailure(error, () => rows.dispose()); }
    return {
      namespace: this.#checkpointNamespace, prefillMode: "full", tapLayers: [target.layerCount - 1],
      get rowCount() { return rows.rowCount; },
      append, prepareAppend, prefill: (tokens, context) => rows.prefill(tokens, context!), materialize: rows.materialize.bind(rows),
      filterRows: rows.filterRows.bind(rows),
      draft: rows.draft.bind(rows), commit: rows.commit.bind(rows),
      capture(row) {
        const state = rows.extractRow(row);
        try { return captureQwenMtpState(state); }
        finally { disposeResources([state.cache, state.hidden]); }
      },
      dispose: rows.dispose.bind(rows),
    };
  }


  dispose(): void {
    // Release cached transpose views before their native weight maps. MLX
    // retains buffers needed by outstanding GPU commands until completion.
    this.#resources.dispose();
  }
}

export class QwenMtpSource implements DraftSource {
  // Full-prompt target prefill (the bonus token exists before round 1, and
  // the tap covers every prompt position — mlx-vlm's flow).
  readonly prefillMode = "full" as const;
  readonly weightsBytes = 0; // provider owns the drafter weights
  /** Pre-final-norm tap: the LAST layer's output stream (index nLayers-1).
   *  The seam's anchorHidden is post-final-norm and is deliberately unused. */
  readonly tapLayers: number[];

  readonly #target: QwenMtpTarget;
  readonly #module: MtpModule;
  readonly #sampler: Sampler;
  #cache = new KVCache();
  readonly checkpoint: NonNullable<DraftSource["checkpoint"]>;
  #prefilledTokens = 0;
  #hasDrafted = false;
  /** Target pre-norm hidden at the position preceding the next pending
   *  token: prefill's last tapped row, then each commit's vCtx row at the
   *  emitted position. draft() consumes it to build the pending row. [1,1,H] */
  #pendingTrueHidden: MlxArray | null = null;
  #roundAppended = 0;
  #closed = false;

  constructor(target: QwenMtpTarget, module: MtpModule, sampler: Sampler,
    namespace = "qwen-mtp-v1") {
    this.#target = target;
    this.#module = module;
    this.#sampler = sampler;
    this.tapLayers = [target.layerCount - 1];
    this.checkpoint = {
      namespace,
      restore: (tokens, attachment) => {
        this.#checkOpen();
        if (this.#prefilledTokens !== 0 || this.#hasDrafted)
          throw new Error("Qwen MTP checkpoint restore requires a fresh source");
        const state = restoreQwenMtpState({ processedTokens: tokens, attachment });
        try { disposeResources([this.#cache, ...(this.#pendingTrueHidden ? [this.#pendingTrueHidden] : [])]); }
        catch (error) { return cleanupFailure(error, () => disposeResources([state.cache, state.hidden])); }
        this.#cache = state.cache;
        this.#pendingTrueHidden = state.hidden;
        this.#prefilledTokens = tokens;
      },
      capture: (tokens) => {
        this.#checkOpen();
        if (!this.#pendingTrueHidden || this.#cache.offset !== tokens - 1 || this.#roundAppended !== 0)
          throw new Error("Qwen MTP snapshot requires an aligned committed boundary");
        return captureQwenMtpState({ cache: this.#cache, hidden: this.#pendingTrueHidden }).attachment;
      },
    };
  }

  /** Drafter prefill: rows for positions 0..L-2, keyed (token_{p+1}, h_p) —
   *  the (pending, h_{L-1}) row is NOT built here (the pending token is
   *  sampled after target prefill); its true hidden is kept for round 1. */
  async prefill(promptIds: number[], ctxML?: MlxArray): Promise<void> {
    this.#checkOpen();
    if (!ctxML)
      throw new Error("qwen MTP prefill requires the tapped pre-final-norm context");
    try {
      if (this.#hasDrafted)
        throw new Error("qwen MTP prefill cannot follow drafting");
      const L = promptIds.length;
      const start = this.#prefilledTokens;
      const H = ctxML.shape[2]!;
      if (L <= start || ctxML.shape[1]! !== L - start)
        throw new Error(`qwen MTP tap covered ${ctxML.shape[1]} of ${L - start} new prompt positions`);
      if (start > 0) {
        if (!this.#pendingTrueHidden || this.#cache.offset !== start - 1)
          throw new Error("qwen MTP prefix state is not aligned");
        this.#stepOne(promptIds[start]!, this.#pendingTrueHidden).dispose();
      }
      this.#pendingTrueHidden?.dispose();
      // A slice would retain the complete prompt buffer in the saved prefix.
      // Materialize this one row before handing off the prefill state.
      using tail = ctxML.slice([0, L - start - 1, 0], [1, L - start, H]);
      this.#pendingTrueHidden = materializeCopy(tail);
      for (let pos = start; pos + 1 < L; pos += DRAFT_PREFILL_CHUNK) {
        const n = Math.min(DRAFT_PREFILL_CHUNK, L - 1 - pos);
        const shifted = promptIds.slice(pos + 1, pos + 1 + n);
        const ids = ops.fromInt32(shifted, [1, n]);
        const embeds = this.#target.embed(ids);
        ids.dispose();
        const hiddens = ctxML.slice([0, pos - start, 0], [1, pos + n - start, H]);
        const out = this.#module.forward(embeds, hiddens, this.#cache);
        embeds.dispose();
        hiddens.dispose();
        out.dispose(); // prefill outputs are not seeds; only KV matters here
        // Bound the lazy KV graph at each chunk. Evaluating the unused output
        // would also execute attention and the MLP, which prefill does not need.
        ops.evalAll(this.#cache.state());
      }
      if (this.#cache.offset !== L - 1)
        throw new Error(`qwen MTP prefill offset ${this.#cache.offset}, expected ${L - 1}`);
      // Also covers a restored-prefix bridge with no subsequent full chunk.
      ops.evalAll([this.#pendingTrueHidden, ...this.#cache.state()]);
      this.#prefilledTokens = L;
    } finally {
      ctxML?.dispose(); // ownership per the seam contract
    }
  }

  async draft(feed: number[], n: number, stepBase: number): Promise<number[]> {
    this.#checkOpen();
    this.#hasDrafted = true;
    if (this.#roundAppended !== 0)
      throw new Error("qwen MTP draft called before the prior round committed");
    if (n <= 0) return [];
    const pending = feed.at(-1);
    if (!Number.isSafeInteger(pending) || pending! < 0)
      throw new Error("qwen MTP requires a non-empty token feed");

    const drafts: number[] = [];
    let chained: MlxArray | null = null;
    const startOffset = this.#cache.offset;
    try {
      // Build the pending token's row from the TRUE target hidden at the
      // preceding position (prefill tail on round 1, verify tap afterwards).
      if (!this.#pendingTrueHidden)
        throw new Error("qwen MTP draft before prefill/commit");
      const out = this.#stepOne(pending!, this.#pendingTrueHidden);
      this.#pendingTrueHidden.dispose();
      this.#pendingTrueHidden = null;
      this.#roundAppended++;
      chained = out;
      drafts.push(this.#sample(out, stepBase));
      while (drafts.length < n) {
        const out = this.#stepOne(drafts.at(-1)!, chained!);
        chained!.dispose();
        chained = out;
        this.#roundAppended++;
        drafts.push(this.#sample(out, stepBase + drafts.length));
      }
      return drafts;
    } catch (error) {
      const appended = this.#cache.offset - startOffset;
      if (appended > 0) this.#cache.trim(appended);
      this.#roundAppended = 0;
      throw error;
    } finally {
      chained?.dispose();
    }
  }

  /** mlx-vlm accept semantics: keep drafted rows for accepted positions,
   *  trim the rejected tail, then append the missing accepted row (all-accept
   *  case) and the correction/bonus row using the TARGET's verified pre-norm
   *  hiddens — harvesting the last output as the next round's seed. */
  async commit(
    d: number,
    kAccept: number,
    vCtxML?: MlxArray,
    _verifiedHidden?: MlxArray,
    acceptedTokens: readonly number[] = [],
  ): Promise<void> {
    this.#checkOpen();
    try {
      if (!vCtxML)
        throw new Error("qwen MTP commit requires the tapped verify context");
      if (kAccept > 0 && acceptedTokens.length !== kAccept)
        throw new Error(
          `qwen MTP received ${acceptedTokens.length} accepted tokens for k=${kAccept}`,
        );
      // Rows appended this round cover window tokens 0..d-1 (pending +
      // drafts[0..d-2]); rows keyed by ACCEPTED window tokens (0..kAccept)
      // survive — trim the rejected tail.
      const trim = Math.max(this.#roundAppended - 1 - kAccept, 0);
      if (trim > 0) this.#cache.trim(trim);

      // All-accept case: window token d (= drafts[d-1]) has no drafted row —
      // append it from the TRUE verify hidden (vCtx row d-1, the hidden at
      // its preceding position). The correction/bonus row is NOT built here:
      // the serve loop re-feeds that token in the next draft()'s `feed`, and
      // draft() opens by building its row from #pendingTrueHidden below.
      const H = vCtxML.shape[2]!;
      if (kAccept === d && d > 0) {
        const ids = ops.fromInt32([acceptedTokens[kAccept - 1]!], [1, 1]);
        const embeds = this.#target.embed(ids);
        ids.dispose();
        const hidden = vCtxML.slice([0, d - 1, 0], [1, d, H]);
        const out = this.#module.forward(embeds, hidden, this.#cache);
        embeds.dispose();
        hidden.dispose();
        out.dispose();
      }
      // Next round's pending row input: the target's verified pre-norm
      // hidden at the emitted position.
      this.#pendingTrueHidden?.dispose();
      this.#pendingTrueHidden = vCtxML.slice([0, kAccept, 0], [1, kAccept + 1, H]);
    } finally {
      vCtxML?.dispose(); // seam: commit takes ownership
      this.#roundAppended = 0;
    }
  }

  dispose(): void {
    if (this.#closed) return;
    this.#closed = true;
    this.#cache.dispose();
    this.#pendingTrueHidden?.dispose();
  }

  /** One module forward for (token, hidden) — appends one KV row. */
  #stepOne(token: number, hidden: MlxArray): MlxArray {
    using ids = ops.fromInt32([token], [1, 1]);
    using embed = this.#target.embed(ids);
    ids.dispose();
    return this.#module.forward(embed, hidden, this.#cache);
  }

  /** Sample a draft token from the module output via the TARGET's lm head
   *  and the request sampler (per-step RNG stream discipline). */
  #sample(moduleOut: MlxArray, step: number): number {
    using logits = this.#target.logitsFromHidden(moduleOut);
    // Sampler contract is [1, V] (the main decode loop's shape). moduleOut
    // is [1, 1, H] → logits [1, 1, V]; without this reshape any sampler
    // that slices 2-D (top-k) throws "[slice] Invalid number of indices…
    // dimension 3" — the serve-lane MTP 500 (chat defaults carry the
    // model's top_k=20; the greedy bench harness never hit it).
    const V = logits.shape[logits.shape.length - 1]!;
    using flat = ops.reshape(logits, [1, V]);
    logits.dispose();
    using logprobs = toLogprobs(flat);
    flat.dispose();
    using tok = this.#sampler(logprobs, step);
    logprobs.dispose();
    return ops.itemUint32(tok);
  }

  #checkOpen(): void {
    if (this.#closed) throw new Error("qwen MTP source is closed");
  }
}
