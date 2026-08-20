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
// Weights are plain bf16 (DenseLinear); the published drafter snapshots are
// already sanitized (norms in runtime layout — no +1.0 shift here).

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { toLogprobs } from "../sampler";
import { loadModelConfig, type ModelConfig } from "../config";
import { Weights } from "../weights";
import { disposing, KVCache, RMSNorm, type Mask } from "../model/gemma4-base";
import { DenseLinear } from "../model/universal/modules";
import { Qwen35Model } from "../model/qwen3_5";
import type { DraftProvider, DraftSource, TargetView } from "./source";

type Sampler = (logprobs: MlxArray, step: number) => MlxArray;

const DRAFT_PREFILL_CHUNK = 2048;

/** Dense-weight clone of Qwen3Attention.forward (src/model/qwen3_5.ts —
 *  ops copied verbatim; only the projection flavor differs: the drafter is
 *  bf16, the target's class hardwires QuantizedLinear). */
class MtpAttention {
  readonly qProj: DenseLinear;
  readonly kProj: DenseLinear;
  readonly vProj: DenseLinear;
  readonly oProj: DenseLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly scale: number;
  readonly ropeDims: number;
  readonly ropeBase: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeDims = Math.trunc(this.headDim * t.partialRotaryFactor);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
    const dense = (path: string): DenseLinear =>
      new DenseLinear(weights.tensor(`${path}.weight`), null);
    this.qProj = dense(`${prefix}.q_proj`);
    this.kProj = dense(`${prefix}.k_proj`);
    this.vProj = dense(`${prefix}.v_proj`);
    this.oProj = dense(`${prefix}.o_proj`);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
  }

  forward(x: MlxArray, mask: Mask, cache: KVCache): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    const qp = this.qProj.forward(x);
    const qpr = disposing(qp, ops.reshape(qp, [B, L, this.nHeads, this.headDim * 2]));
    const [qHeads, gateHeads] = ops.split(qpr, [this.headDim], -1) as [MlxArray, MlxArray];
    qpr.dispose();
    const gate = disposing(gateHeads, ops.reshape(gateHeads, [B, L, this.nHeads * this.headDim]));

    let k = this.kProj.forward(x);
    let v = this.vProj.forward(x);

    let q = this.qNorm.forward(qHeads);
    qHeads.dispose();
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    k = disposing(k, this.kNorm.forward(k));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    q = disposing(q, ops.rope(q, this.ropeDims, this.ropeBase, cache.offset, null));
    k = disposing(k, ops.rope(k, this.ropeDims, this.ropeBase, cache.offset, null));

    const [keys, values] = cache.updateAndFetch(k, v);
    k.dispose();
    v.dispose();
    const attn = ops.sdpa(q, keys, values, this.scale, mask.mode, mask.arr);
    keys.dispose();
    values.dispose();
    q.dispose();

    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const sig = ops.sigmoid(gate);
    gate.dispose();
    const gated = ops.mul(merged, sig);
    merged.dispose();
    sig.dispose();
    const out = this.oProj.forward(gated);
    gated.dispose();
    return out;
  }
}

/** The one MTP decoder block: fc-merge → attention → swiglu MLP → norm. */
class MtpModule {
  readonly fc: DenseLinear;
  readonly preFcNormEmbedding: RMSNorm;
  readonly preFcNormHidden: RMSNorm;
  readonly attn: MtpAttention;
  readonly mlpGate: DenseLinear;
  readonly mlpUp: DenseLinear;
  readonly mlpDown: DenseLinear;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly finalNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig) {
    const eps = config.text.rmsNormEps;
    const dense = (path: string): DenseLinear =>
      new DenseLinear(weights.tensor(`${path}.weight`), null);
    this.fc = dense("fc");
    this.preFcNormEmbedding = new RMSNorm(weights.tensor("pre_fc_norm_embedding.weight"), eps);
    this.preFcNormHidden = new RMSNorm(weights.tensor("pre_fc_norm_hidden.weight"), eps);
    this.attn = new MtpAttention(weights, config, "layers.0.self_attn");
    this.mlpGate = dense("layers.0.mlp.gate_proj");
    this.mlpUp = dense("layers.0.mlp.up_proj");
    this.mlpDown = dense("layers.0.mlp.down_proj");
    this.inputNorm = new RMSNorm(weights.tensor("layers.0.input_layernorm.weight"), eps);
    this.postAttnNorm = new RMSNorm(weights.tensor("layers.0.post_attention_layernorm.weight"), eps);
    this.finalNorm = new RMSNorm(weights.tensor("norm.weight"), eps);
  }

  /** One block forward over [1,S,·]: token embeddings ([1,S,H], target
   *  embed_tokens output) paired with hiddens ([1,S,H], target pre-final-norm
   *  or the module's own chained output). Appends S rows to `cache`; returns
   *  the module output [1,S,H] (post final norm — what the target lm_head
   *  consumes AND what chains into the next step's `hidden`). */
  forward(tokenEmbeds: MlxArray, hiddens: MlxArray, cache: KVCache): MlxArray {
    const embNorm = this.preFcNormEmbedding.forward(tokenEmbeds);
    const hidNorm = this.preFcNormHidden.forward(hiddens);
    const joined = ops.concatAxis([embNorm, hidNorm], 2);
    embNorm.dispose();
    hidNorm.dispose();
    const x = this.fc.forward(joined);
    joined.dispose();

    // Decoder layer (Qwen3Layer.forward shape, dense weights).
    const L = x.shape[1]!;
    const mask = cache.makeMask(L, null);
    const xn = this.inputNorm.forward(x);
    const r = this.attn.forward(xn, mask, cache);
    xn.dispose();
    mask.arr?.dispose();
    const h = ops.add(x, r);
    x.dispose();
    r.dispose();
    const hn = this.postAttnNorm.forward(h);
    const g = this.mlpGate.forward(hn);
    const u = this.mlpUp.forward(hn);
    hn.dispose();
    const silu = ops.silu(g);
    g.dispose();
    const act = ops.mul(silu, u);
    silu.dispose();
    u.dispose();
    const m = this.mlpDown.forward(act);
    act.dispose();
    const out = ops.add(h, m);
    h.dispose();
    m.dispose();
    return disposing(out, this.finalNorm.forward(out));
  }
}

export class QwenMtpProvider implements DraftProvider {
  readonly id: string;
  readonly weightsBytes: number;
  readonly #module: MtpModule;
  readonly #config: ModelConfig;

  private constructor(id: string, config: ModelConfig, weights: Weights, module: MtpModule) {
    this.id = id;
    this.#config = config;
    this.#module = module;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
  }

  static async load(dir: string): Promise<QwenMtpProvider> {
    const config = await loadModelConfig(dir);
    if (config.modelType !== "qwen3_5_mtp")
      throw new Error(`${dir}: not a qwen3_5_mtp drafter (model_type ${config.modelType})`);
    const weights = await Weights.open(dir);
    return new QwenMtpProvider(
      dir.split("/").filter(Boolean).at(-1) ?? "qwen-mtp",
      config, weights, new MtpModule(weights, config),
    );
  }

  open(opts: Parameters<DraftProvider["open"]>[0]): DraftSource {
    const target = opts.target.model;
    if (!(target instanceof Qwen35Model))
      throw new Error("qwen MTP drafting requires a qwen3_5-family target");
    if (target.config.text.hiddenSize !== this.#config.text.hiddenSize) {
      throw new Error(
        `qwen MTP drafter hidden ${this.#config.text.hiddenSize} != target ` +
        `${target.config.text.hiddenSize} — split from a different checkpoint?`,
      );
    }
    return new QwenMtpSource(target, this.#module, opts.sampler);
  }

  dispose(): void {
    // Weights are mmap-backed and pinned for the process (house rule: no JS
    // dtors into mlx); the provider owns no other native state.
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

  readonly #target: Qwen35Model;
  readonly #module: MtpModule;
  readonly #sampler: Sampler;
  readonly #cache = new KVCache();
  /** Target pre-norm hidden at the position preceding the next pending
   *  token: prefill's last tapped row, then each commit's vCtx row at the
   *  emitted position. draft() consumes it to build the pending row. [1,1,H] */
  #pendingTrueHidden: MlxArray | null = null;
  #roundAppended = 0;
  #closed = false;

  constructor(target: Qwen35Model, module: MtpModule, sampler: Sampler) {
    this.#target = target;
    this.#module = module;
    this.#sampler = sampler;
    this.tapLayers = [target.config.text.numHiddenLayers - 1];
  }

  /** Drafter prefill: rows for positions 0..L-2, keyed (token_{p+1}, h_p) —
   *  the (pending, h_{L-1}) row is NOT built here (the pending token is
   *  sampled after target prefill); its true hidden is kept for round 1. */
  async prefill(promptIds: number[], ctxML?: MlxArray): Promise<void> {
    this.#checkOpen();
    if (!ctxML)
      throw new Error("qwen MTP prefill requires the tapped pre-final-norm context");
    try {
      if (this.#cache.offset !== 0)
        throw new Error("qwen MTP source cannot be prefilled twice");
      const L = promptIds.length;
      const H = ctxML.shape[2]!;
      if (ctxML.shape[1]! !== L)
        throw new Error(`qwen MTP tap covered ${ctxML.shape[1]} of ${L} prompt positions`);
      this.#pendingTrueHidden = ctxML.slice([0, L - 1, 0], [1, L, H]);
      for (let pos = 0; pos + 1 < L; pos += DRAFT_PREFILL_CHUNK) {
        const n = Math.min(DRAFT_PREFILL_CHUNK, L - 1 - pos);
        const shifted = promptIds.slice(pos + 1, pos + 1 + n);
        const ids = ops.fromInt32(shifted, [1, n]);
        const embeds = this.#target.embed.encode(ids);
        ids.dispose();
        const hiddens = ctxML.slice([0, pos, 0], [1, pos + n, H]);
        const out = this.#module.forward(embeds, hiddens, this.#cache);
        embeds.dispose();
        hiddens.dispose();
        out.dispose(); // prefill outputs are not seeds; only KV matters here
      }
      if (this.#cache.offset !== L - 1)
        throw new Error(`qwen MTP prefill offset ${this.#cache.offset}, expected ${L - 1}`);
    } finally {
      ctxML?.dispose(); // ownership per the seam contract
    }
  }

  async draft(feed: number[], n: number, stepBase: number): Promise<number[]> {
    this.#checkOpen();
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
      drafts.push(this.#sample(out, stepBase));
      chained = out;
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
        const embeds = this.#target.embed.encode(ids);
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
    const ids = ops.fromInt32([token], [1, 1]);
    const embed = this.#target.embed.encode(ids);
    ids.dispose();
    const out = this.#module.forward(embed, hidden, this.#cache);
    embed.dispose();
    return out;
  }

  /** Sample a draft token from the module output via the TARGET's lm head
   *  and the request sampler (per-step RNG stream discipline). */
  #sample(moduleOut: MlxArray, step: number): number {
    const logits = this.#target.logitsFromHidden(moduleOut);
    // Sampler contract is [1, V] (the main decode loop's shape). moduleOut
    // is [1, 1, H] → logits [1, 1, V]; without this reshape any sampler
    // that slices 2-D (top-k) throws "[slice] Invalid number of indices…
    // dimension 3" — the serve-lane MTP 500 (chat defaults carry the
    // model's top_k=20; the greedy bench harness never hit it).
    const V = logits.shape[logits.shape.length - 1]!;
    const flat = ops.reshape(logits, [1, V]);
    logits.dispose();
    const logprobs = toLogprobs(flat);
    flat.dispose();
    const tok = this.#sampler(logprobs, step);
    logprobs.dispose();
    const id = ops.itemUint32(tok);
    tok.dispose();
    return id;
  }

  #checkOpen(): void {
    if (this.#closed) throw new Error("qwen MTP source is closed");
  }
}
