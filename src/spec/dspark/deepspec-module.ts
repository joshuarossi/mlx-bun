// DeepSpec's Gemma4DSparkModel — semi-autoregressive draft model, ported
// verbatim (copy-verbatim methodology: transcribe THEIR forward, then port
// op-for-op) from github.com/deepseek-ai/DeepSpec (MIT), files:
//   deepspec/modeling/dspark/gemma4/modeling.py   (Gemma4DSparkModel)
//   deepspec/modeling/dspark/common.py            (extract_context_feature)
//   deepspec/modeling/dspark/markov_head.py       (VanillaMarkov)
//   deepspec/eval/dspark/draft_ops.py             (inference-time draft loop)
//   deepspec/utils/sampling.py                    (sample_tokens, temp=0 argmax)
// Cross-checked against the installed HF reference (transformers
// models/gemma4/modeling_gemma4.py) for Gemma4RMSNorm, apply_rotary_pos_emb,
// Gemma4TextRotaryEmbedding (rope_type "proportional" via
// modeling_rope_utils._compute_proportional_rope_parameters), and
// Gemma4TextScaledWordEmbedding — since Gemma4DSparkModel subclasses/reuses
// those directly rather than redefining them.
//
// This is a DRAFT model for target-Gemma4 speculative decoding: not
// causal, not autoregressive over the whole sequence — it predicts a
// γ-token block in one backbone pass (context-conditioned, bidirectional
// within the block), then a cheap sequential Markov correction walks the
// block left-to-right applying a low-rank transition bias per step.
//
// This module is STATELESS server-lifetime weights. Per-request context
// K/V (the incremental cache DeepSpec threads through consecutive draft
// rounds via a DynamicCache) is NOT stored here — see `projectContext` /
// `draftBlock` below for the seam.

import { Weights } from "../../weights";
import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import * as ops from "../../mlx/ops";

function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}

// ---------------------------------------------------------------------------
// Config (their config.json field names, verbatim keys — no renaming so the
// mapping to the checkpoint stays obvious).
// ---------------------------------------------------------------------------

export interface DeepspecConfig {
  architectures: string[];
  hidden_size: number;
  num_hidden_layers: number;
  num_attention_heads: number;
  global_head_dim: number;
  num_global_key_value_heads: number;
  attention_k_eq_v: boolean;
  intermediate_size: number;
  hidden_activation: string;
  rms_norm_eps: number;
  final_logit_softcapping: number | null;
  vocab_size: number;
  block_size: number;
  mask_token_id: number;
  target_layer_ids: number[];
  num_target_layers: number;
  markov_rank: number;
  markov_head_type: string;
  enable_confidence_head: boolean;
  confidence_head_with_markov: boolean;
  rope_theta: number;
  partial_rotary_factor: number;
  /** Not in the checkpoint's config.json (draft_ops.py takes it as a call
   *  arg to build_dspark_proposal); default 0 = confidence head disabled
   *  functionally even when weights exist (threshold<=0 ⇒ full γ block). */
  confidence_threshold: number;
}

function readConfig(raw: Record<string, any>): DeepspecConfig {
  const arch = raw.architectures?.[0];
  if (arch !== "Gemma4DSparkModel")
    throw new Error(`DeepspecDrafter: expected architectures[0]==="Gemma4DSparkModel", got ${JSON.stringify(raw.architectures)}`);

  // RoPE: their config nests rope params under rope_parameters.full_attention
  // (matches Gemma4TextConfig / Gemma4TextRotaryEmbedding's per-layer-type
  // dict); ground truth also allows a flat rope_theta/partial_rotary_factor
  // for simplified checkpoints — accept either shape.
  const ropeFull = raw.rope_parameters?.full_attention ?? raw.rope_parameters ?? {};
  const ropeTheta = ropeFull.rope_theta ?? raw.rope_theta ?? 1e6;
  const partialRotary = ropeFull.partial_rotary_factor ?? raw.partial_rotary_factor ?? 1.0;

  const targetLayerIds: number[] = raw.target_layer_ids;
  if (!Array.isArray(targetLayerIds) || targetLayerIds.length === 0)
    throw new Error("DeepspecDrafter: config.target_layer_ids must be a non-empty array");

  // Silent-wrongness guards (2026-07-06 port review): each of these variants
  // would LOAD cleanly and compute wrong math — this module implements only
  // the released-checkpoint shape. Refuse loudly instead.
  if (!raw.attention_k_eq_v)
    throw new Error(
      "DeepspecDrafter: attention_k_eq_v=false checkpoints need a real v_proj path — not implemented (this module wires V ≡ K)",
    );
  if ((raw.markov_rank ?? 0) > 0 && (raw.markov_head_type ?? "vanilla") !== "vanilla")
    throw new Error(
      `DeepspecDrafter: markov_head_type "${raw.markov_head_type}" not implemented (gated/rnn heads ship markov_w1/w2 too and would silently get vanilla math) — only "vanilla"`,
    );
  if ((raw.hidden_activation ?? "gelu_pytorch_tanh") !== "gelu_pytorch_tanh")
    throw new Error(
      `DeepspecDrafter: hidden_activation "${raw.hidden_activation}" not implemented — the MLP hardcodes gelu_pytorch_tanh`,
    );

  return {
    architectures: raw.architectures,
    hidden_size: raw.hidden_size,
    num_hidden_layers: raw.num_hidden_layers,
    num_attention_heads: raw.num_attention_heads,
    global_head_dim: raw.global_head_dim,
    num_global_key_value_heads: raw.num_global_key_value_heads,
    attention_k_eq_v: !!raw.attention_k_eq_v,
    intermediate_size: raw.intermediate_size,
    hidden_activation: raw.hidden_activation ?? "gelu_pytorch_tanh",
    rms_norm_eps: raw.rms_norm_eps ?? 1e-6,
    final_logit_softcapping: raw.final_logit_softcapping ?? null,
    vocab_size: raw.vocab_size,
    block_size: raw.block_size,
    mask_token_id: raw.mask_token_id,
    target_layer_ids: targetLayerIds,
    num_target_layers: raw.num_target_layers,
    markov_rank: raw.markov_rank ?? 0,
    markov_head_type: raw.markov_head_type ?? "vanilla",
    enable_confidence_head: !!raw.enable_confidence_head,
    confidence_head_with_markov: !!raw.confidence_head_with_markov,
    rope_theta: ropeTheta,
    partial_rotary_factor: partialRotary,
    confidence_threshold: raw.confidence_threshold ?? 0,
  };
}

// ---------------------------------------------------------------------------
// Per-layer weights.
// ---------------------------------------------------------------------------

interface Layer {
  qProjT: MlxArray; // [hidden, nHeads*headDim] (transposed for x@W)
  kProjT: MlxArray; // [hidden, nKvHeads*headDim]
  oProjT: MlxArray; // [nHeads*headDim, hidden]
  qNorm: MlxArray;  // [headDim]
  kNorm: MlxArray;  // [headDim]
  // v_norm has with_scale=False (Gemma4RMSNorm(..., with_scale=False)) — no
  // weight tensor in the checkpoint; represented as `null` into ops.rmsNorm.
  inputNorm: MlxArray;
  postAttnNorm: MlxArray;
  preFfNorm: MlxArray;
  postFfNorm: MlxArray;
  gateProjT: MlxArray;
  upProjT: MlxArray;
  downProjT: MlxArray;
  layerScalar: MlxArray; // [1]
}

/** Per-layer context K/V rows, already projected + normed + roped —
 *  cacheable across draft rounds (see projectContext doc). */
export interface ContextKV {
  k: MlxArray; // [1, nKvHeads, ctxLen, headDim]
  v: MlxArray; // [1, nKvHeads, ctxLen, headDim] (v ≡ k when attention_k_eq_v)
}

export interface DraftBlockResult {
  /** Sequentially-sampled draft tokens, length 0..gamma (0 iff confidence
   *  truncation fires at the very first position — EMPTY proposal). */
  tokens: number[];
  /** Per-position sigmoid confidence, aligned with `tokens` (same length;
   *  empty when the confidence head is disabled). */
  conf: number[];
  /** Raw base_logits (post target-forward, PRE-Markov-bias, post-softcap)
   *  for the full block [1, gamma, vocab] (float32 COPY; sampling runs in
   *  model dtype separately) — caller disposes. NOTE: the reference
   *  verifier's temp>0 draft_probs come from the Markov-CORRECTED logits
   *  (draft_ops.py:140-143), NOT these — at temp 0 (our oracle regime) the
   *  distinction is moot (verify degenerates to argmax token-match), but a
   *  future temp>0 verify must add the per-position Markov bias first. */
  baseLogits: MlxArray;
}

export class DeepspecDrafter {
  readonly cfg: DeepspecConfig;
  /** === config.target_layer_ids, alias for the ground-truth term. */
  readonly tapLayers: number[];
  /** === config.block_size (γ), alias for the ground-truth term. */
  readonly gamma: number;
  readonly hidden: number;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly eps: number;
  readonly embedScale: number;
  readonly ropeFreqs: MlxArray; // proportional-RoPE freqs, [headDim/2]

  #w: Weights;
  #embed: MlxArray;      // [vocab, hidden]
  #fcT: MlxArray;        // [taps*hidden, hidden] transposed (fc.weight is [hidden, taps*hidden])
  #hiddenNorm: MlxArray; // [hidden]
  #norm: MlxArray;       // [hidden]
  #lmHeadT: MlxArray;    // [hidden, vocab] transposed
  #layers: Layer[] = [];
  #markovW1: MlxArray | null; // [vocab, markovRank] embedding
  #markovW2T: MlxArray | null; // [markovRank, vocab] transposed (stored as Linear [vocab, rank])
  #confW: MlxArray | null;   // [1, confDim] proj weight (Linear storage)
  #confWT: MlxArray | null;  // [confDim, 1] transpose view, built once (per-call transpose+cast leaked — review fix)
  #confB: MlxArray | null;   // [1]

  private constructor(w: Weights, cfg: DeepspecConfig) {
    this.#w = w;
    this.cfg = cfg;
    this.tapLayers = cfg.target_layer_ids;
    this.gamma = cfg.block_size;
    this.hidden = cfg.hidden_size;
    this.nHeads = cfg.num_attention_heads;
    this.nKvHeads = cfg.num_global_key_value_heads; // k_eq_v enforced in readConfig (no v_proj path)
    this.headDim = cfg.global_head_dim;
    this.eps = cfg.rms_norm_eps;
    this.embedScale = Math.sqrt(cfg.hidden_size);

    const T = (name: string) => w.tensor(name);
    // Lazy transpose VIEW — no contiguous copy. The src/spec/drafter.ts
    // pattern (contiguous + eval) would materialize every matmul weight a
    // second time: on the real 6.86 GB checkpoint that's ~+4.8 GB resident
    // (lm_head alone ~2 GB), decisive on a 24 GB box. mlx's steel GEMM
    // dispatches a transposed-B operand natively, so the view costs nothing
    // per matmul. (2026-07-06 port review, MEDIUM-memory finding.)
    const transposed = (name: string): MlxArray => ops.transposeAxes(T(name), [1, 0]);

    this.#embed = T("embed_tokens.weight");
    this.#fcT = transposed("fc.weight");
    this.#hiddenNorm = T("hidden_norm.weight");
    this.#norm = T("norm.weight");
    this.#lmHeadT = transposed("lm_head.weight");

    // Proportional RoPE freqs (mlx_lm.models.rope_utils.ProportionalRoPE,
    // transformers._compute_proportional_rope_parameters): rotated_dims =
    // int(head_dim * partial_rotary_factor); exponents over [0, rotated_dims)
    // step 2, divided by FULL head_dim (not rotated_dims); tail padded with
    // +inf ⇒ angle pos/∞ = 0 ⇒ cos=1, sin=0 — the identity rotation, i.e.
    // passthrough on those dims (freqs is the wavelength array fast::rope
    // divides position by, same convention as src/spec/drafter.ts's
    // ProportionalRoPE port; verified vs mlx_lm rope_utils.ProportionalRoPE).
    const rotatedDims = Math.floor(this.headDim * cfg.partial_rotary_factor);
    const n = this.headDim / 2;
    const freqs = new Float32Array(n).fill(Infinity);
    for (let k = 0; k < rotatedDims / 2; k++) {
      freqs[k] = Math.pow(cfg.rope_theta, (2 * k) / this.headDim);
    }
    this.ropeFreqs = MlxArray.fromFloat32(freqs, [n]);

    for (let i = 0; i < cfg.num_hidden_layers; i++) {
      const p = `layers.${i}`;
      this.#layers.push({
        qProjT: transposed(`${p}.self_attn.q_proj.weight`),
        kProjT: transposed(`${p}.self_attn.k_proj.weight`),
        oProjT: transposed(`${p}.self_attn.o_proj.weight`),
        qNorm: T(`${p}.self_attn.q_norm.weight`),
        kNorm: T(`${p}.self_attn.k_norm.weight`),
        inputNorm: T(`${p}.input_layernorm.weight`),
        postAttnNorm: T(`${p}.post_attention_layernorm.weight`),
        preFfNorm: T(`${p}.pre_feedforward_layernorm.weight`),
        postFfNorm: T(`${p}.post_feedforward_layernorm.weight`),
        gateProjT: transposed(`${p}.mlp.gate_proj.weight`),
        upProjT: transposed(`${p}.mlp.up_proj.weight`),
        downProjT: transposed(`${p}.mlp.down_proj.weight`),
        layerScalar: T(`${p}.layer_scalar`),
      });
    }

    if (cfg.markov_rank > 0) {
      this.#markovW1 = T("markov_head.markov_w1.weight"); // [vocab, rank] embedding
      this.#markovW2T = transposed("markov_head.markov_w2.weight"); // stored [vocab,rank] Linear → T is [rank,vocab]
    } else {
      this.#markovW1 = null;
      this.#markovW2T = null;
    }

    if (cfg.enable_confidence_head) {
      this.#confW = T("confidence_head.proj.weight"); // [1, confDim]
      this.#confWT = ops.transposeAxes(this.#confW, [1, 0]); // [confDim,1] view
      this.#confB = T("confidence_head.proj.bias");   // [1]
    } else {
      this.#confW = null;
      this.#confWT = null;
      this.#confB = null;
    }
  }

  static async load(dir: string): Promise<DeepspecDrafter> {
    const raw = (await Bun.file(`${dir}/config.json`).json()) as Record<string, any>;
    const cfg = readConfig(raw);
    const w = await Weights.open(dir);
    return new DeepspecDrafter(w, cfg);
  }

  /** f32-internal RMSNorm (Gemma4RMSNorm casts through float32 internally:
   *  `hidden_states.float()` → norm → `* weight.float()` → `.type_as`).
   *  weight=null reproduces `with_scale=False` (v_norm). */
  #rms(x: MlxArray, weight: MlxArray | null): MlxArray {
    const f = x.dtype === Dtype.float32 ? x : x.astype(Dtype.float32);
    const n = ops.rmsNorm(f, weight, this.eps);
    if (f !== x) f.dispose();
    if (n.dtype === x.dtype) return n;
    const back = n.astype(x.dtype);
    n.dispose();
    return back;
  }

  #geluTanhMlp(x: MlxArray, layer: Layer): MlxArray {
    const g = ops.matmul(x, layer.gateProjT);
    const u = ops.matmul(x, layer.upProjT);
    const act = ops.geluApprox(g); // gelu_pytorch_tanh == config.hidden_activation
    g.dispose();
    let mlp = ops.mul(act, u);
    act.dispose();
    u.dispose();
    mlp = disposing(mlp, ops.matmul(mlp, layer.downProjT));
    return mlp;
  }

  /**
   * extract_context_feature (common.py):
   *   torch.cat([hidden_states[0 if lid==-1 else lid+1] for lid in layer_ids], -1)
   * i.e. tap i (target_layer_ids[i], never -1 for this checkpoint) reads the
   * TARGET's post-layer-i residual output (list-of-all-hidden-states
   * convention: index 0 = embedding, index L+1 = output of layer L). The
   * caller is expected to hand us exactly that: targetHiddens is the
   * concatenation over taps, [1, L, taps*hidden], already ordered to match
   * config.target_layer_ids (ascending, enforced upstream by
   * validate_target_layer_ids).
   *
   * context = hidden_norm(fc(target_hiddens))   — modeling.py _forward_backbone:
   *   target_hidden_states = self.hidden_norm(self.fc(target_hidden_states))
   *
   * Returns the projected+normed context hidden [1, L, hidden] (still needs
   * per-layer k_proj + k_norm + rope to become cacheable ContextKV — see
   * projectContextKV).
   */
  projectContext(targetHiddens: MlxArray): MlxArray {
    const proj = ops.matmul(targetHiddens, this.#fcT); // [1,L,hidden]
    return disposing(proj, this.#rms(proj, this.#hiddenNorm));
  }

  /**
   * Per-layer context K/V rows, projected + normed + ROPE'd, ready to cache
   * across draft rounds.
   *
   * Justification for caching at this stage (from modeling.py's
   * Gemma4DSparkAttention.forward, transcribed above the port below):
   *   k_ctx = self.k_proj(target_hidden_states)          # per-layer proj
   *   k = torch.cat([k_ctx, k_noise], dim=1).view(...)    # concat BEFORE norm
   *   k = self.k_norm(k).transpose(1, 2)                  # norm over the concat
   *   k = apply_gemma4_rotary_pos_emb(k, cos, sin, ...)   # rope over the concat
   *   if past_key_values is not None:
   *       k, v = past_key_values.update(k, v, self.layer_idx, cache_kwargs)  # CACHE AFTER ROPE
   *
   * Gemma4RMSNorm normalizes over the LAST axis (head_dim) independently per
   * row; concatenation happens along the sequence axis. So k_norm(cat(ctx,
   * noise))[i] == k_norm(ctx)[i] for every ctx row i — norming the context
   * rows alone and norming them as part of a larger concat batch produce
   * IDENTICAL values (RMSNorm has no cross-row term). RoPE likewise applies
   * per-position (absolute position index, stable per context row across
   * rounds) independent of what else shares the batch. Caching post-norm,
   * post-rope context K rows is therefore bit-exact equivalent to
   * recomputing them fresh inside every round's concat — which is exactly
   * what DeepSpec's own DynamicCache.update-after-rope does (it caches the
   * already roped/normed tensor, then crop() drops only the noise suffix).
   *
   * v ≡ k when attention_k_eq_v (v_proj is absent; v_norm is the SAME
   * concat-then-scale-less-norm, over k_proj's output — v gets NO rope).
   */
  projectContextKV(contextHidden: MlxArray, positions: number[]): ContextKV[] {
    const L = contextHidden.shape[1]!;
    if (positions.length !== L)
      throw new Error(`projectContextKV: ${positions.length} positions for ${L} context rows`);
    const out: ContextKV[] = [];
    for (const layer of this.#layers) {
      const kFlat = ops.matmul(contextHidden, layer.kProjT); // [1,L,nKvHeads*headDim]
      const k4 = ops.reshape(kFlat, [1, L, this.nKvHeads, this.headDim]);
      kFlat.dispose();
      // v ≡ k pre-norm (attention_k_eq_v: v_ctx = k_ctx, same tensor before
      // the two norms diverge — v_norm has no weight).
      const vNormed = this.#rms(k4, null); // scale-less
      const kNormed = this.#rms(k4, layer.kNorm);
      k4.dispose();

      const kT = ops.transposeAxes(kNormed, [0, 2, 1, 3]); // [1,nKvHeads,L,headDim]
      kNormed.dispose();
      const vT = ops.transposeAxes(vNormed, [0, 2, 1, 3]);
      vNormed.dispose();

      // RoPE over context rows at their absolute positions. mx.fast.rope's
      // static `offset` assumes contiguous positions starting at offset; our
      // context rows ARE contiguous (0..L-1 by construction — the taps are
      // read at the same prompt/verified positions every round), so a single
      // rope(offset=positions[0]) call matches apply_gemma4_rotary_pos_emb
      // row-for-row. Guard the assumption explicitly.
      assertContiguous(positions);
      const kRoped = ops.rope(kT, this.headDim, null, positions[0]!, this.ropeFreqs);
      kT.dispose();
      out.push({ k: kRoped, v: vT });
    }
    return out;
  }

  /**
   * One backbone forward over the noise block, given cached context K/V —
   * modeling.py Gemma4DSparkModel._forward_backbone + Gemma4DSparkAttention,
   * transcribed inline per-layer below. Non-causal SDPA (scale=1.0) over
   * [ctx rows ++ block rows]; q uses only the block's own positions.
   *
   * blockIds: token ids for the noise block, length gamma — [anchor, MASK,
   * MASK, ..., MASK] (create_noise_embed: only position 0 gets the real
   * anchor token when block_keep_mask; MASK elsewhere — at inference every
   * anchor is "kept" so this is always [anchor, mask_token_id × (γ-1)]).
   * blockPositions: absolute positions for the γ block rows (contiguous,
   * anchorPos..anchorPos+γ-1 — create_position_ids's per-block arange).
   */
  #forwardBackbone(ctxKV: ContextKV[], blockIds: number[], blockPositions: number[]): MlxArray {
    const G = blockIds.length;
    assertContiguous(blockPositions);
    const idsArr = ops.fromInt32(blockIds, [1, G]);
    const idsU32 = idsArr.astype(Dtype.uint32);
    idsArr.dispose();
    const embRaw = ops.takeAxis(this.#embed, idsU32, 0); // [G,hidden] (takeAxis over vocab axis)
    idsU32.dispose();
    const embFlat = ops.reshape(embRaw, [1, G, this.hidden]);
    embRaw.dispose();
    // Gemma4TextScaledWordEmbedding.forward: embed(ids) * embed_scale
    let h = ops.mulScalar(embFlat, this.embedScale);
    embFlat.dispose();

    for (let li = 0; li < this.#layers.length; li++) {
      const layer = this.#layers[li]!;
      const { k: kCtx, v: vCtx } = ctxKV[li]!;
      const ctxLen = kCtx.shape[2]!;

      const residual = h;
      const x = this.#rms(h, layer.inputNorm);

      // q = q_norm(q_proj(x).view(B,q_len,nHeads,headDim)).transpose(1,2)
      const qFlat = ops.matmul(x, layer.qProjT); // [1,G,nHeads*headDim]
      const q4 = ops.reshape(qFlat, [1, G, this.nHeads, this.headDim]);
      qFlat.dispose();
      const qNormed = this.#rms(q4, layer.qNorm);
      q4.dispose();
      const qT = ops.transposeAxes(qNormed, [0, 2, 1, 3]); // [1,nHeads,G,headDim]
      qNormed.dispose();
      // rope on q uses the LAST q_len positions (cos[:, -q_len:, :]) — here
      // q_len == G == the whole block, so "last q_len" is just the block's
      // own positions, contiguous from blockPositions[0].
      const qRoped = ops.rope(qT, this.headDim, null, blockPositions[0]!, this.ropeFreqs);
      qT.dispose();

      // k_noise = k_proj(x); norm+rope IDENTICALLY to the cached context
      // rows (concat-then-norm == norm-then-concat per the RMSNorm argument
      // in projectContextKV's doc comment).
      const kNoiseFlat = ops.matmul(x, layer.kProjT);
      const kNoise4 = ops.reshape(kNoiseFlat, [1, G, this.nKvHeads, this.headDim]);
      kNoiseFlat.dispose();
      const vNoiseNormed = this.#rms(kNoise4, null);
      const kNoiseNormed = this.#rms(kNoise4, layer.kNorm);
      kNoise4.dispose();
      const kNoiseT = ops.transposeAxes(kNoiseNormed, [0, 2, 1, 3]);
      kNoiseNormed.dispose();
      const vNoiseT = ops.transposeAxes(vNoiseNormed, [0, 2, 1, 3]);
      vNoiseNormed.dispose();
      const kNoiseRoped = ops.rope(kNoiseT, this.headDim, null, blockPositions[0]!, this.ropeFreqs);
      kNoiseT.dispose();
      x.dispose();

      // k = cat([k_ctx, k_noise], dim=seq); v = cat([v_ctx, v_noise], dim=seq)
      const kFull = ops.concatAxis([kCtx, kNoiseRoped], 2); // [1,nKvHeads,ctxLen+G,headDim]
      kNoiseRoped.dispose();
      const vFull = ops.concatAxis([vCtx, vNoiseT], 2);
      vNoiseT.dispose();

      // non-causal SDPA, scale=1.0 (QK-norm replaces the usual 1/sqrt(d))
      const attnOut = ops.sdpa(qRoped, kFull, vFull, 1.0, "", null);
      qRoped.dispose();
      kFull.dispose();
      vFull.dispose();
      void ctxLen;

      const attnT = ops.transposeAxes(attnOut, [0, 2, 1, 3]); // [1,G,nHeads,headDim]
      attnOut.dispose();
      const attnFlat = ops.reshape(attnT, [1, G, this.nHeads * this.headDim]);
      attnT.dispose();
      let attn = ops.matmul(attnFlat, layer.oProjT);
      attnFlat.dispose();
      attn = disposing(attn, this.#rms(attn, layer.postAttnNorm));
      h = ops.add(residual, attn);
      residual.dispose();
      attn.dispose();

      const res2 = h;
      const f = this.#rms(h, layer.preFfNorm);
      let mlp = this.#geluTanhMlp(f, layer);
      f.dispose();
      mlp = disposing(mlp, this.#rms(mlp, layer.postFfNorm));
      h = ops.add(res2, mlp);
      res2.dispose();
      mlp.dispose();

      // Gemma4DSparkDecoderLayer.forward: `return hidden_states * self.layer_scalar`
      // — the scalar multiplies the WHOLE layer output (residual-sum
      // INCLUDED, not just the sublayer delta).
      h = disposing(h, ops.mul(h, layer.layerScalar));
    }

    return disposing(h, this.#rms(h, this.#norm));
  }

  /** lm_head(h) then softcap: `tanh(logits/cap)*cap` (compute_logits). */
  #computeLogits(h: MlxArray): MlxArray {
    const logits = ops.matmul(h, this.#lmHeadT);
    if (this.cfg.final_logit_softcapping === null) return logits;
    const cap = this.cfg.final_logit_softcapping;
    const capArr = ops.scalarLike(cap, logits);
    const scaled = ops.div(logits, capArr);
    logits.dispose();
    const t = ops.tanh(scaled);
    scaled.dispose();
    const out = ops.mul(t, capArr);
    t.dispose();
    capArr.dispose();
    return out;
  }

  /** B_k = markov_w2(markov_w1(prevTok)) — VanillaMarkov.compute_step_bias /
   *  project_bias(get_prev_embeddings(token_ids)). Returns [1,vocab] in MODEL
   *  dtype (bf16 on the real checkpoint) — the reference samples over the
   *  bf16 `logits + bias` sum, and softcapped logits in [-30,30] have bf16
   *  steps ~0.125-0.25, so an f32 sum here reorders near-ties vs torch and
   *  derails the sequential block (2026-07-06 port review, fidelity fix). */
  #markovStepBias(prevTok: number): MlxArray {
    if (!this.#markovW1 || !this.#markovW2T)
      throw new Error("markovStepBias: markov_rank == 0 (no markov head)");
    const idxArr = ops.fromInt32([prevTok], [1]);
    const idxU32 = idxArr.astype(Dtype.uint32);
    idxArr.dispose();
    const e1 = ops.takeAxis(this.#markovW1, idxU32, 0); // [1,rank]
    idxU32.dispose();
    const bias = ops.matmul(e1, this.#markovW2T); // [1,vocab], model dtype
    e1.dispose();
    return bias;
  }

  /** c_k = sigmoid(proj([h_k; markov_w1[prevTok]])). h1 is [1,hidden]
   *  (already the right dtype/shape row for this position). AcceptRatePredictor
   *  is nn.Linear(confDim,1) — proj.weight is [1,confDim]; we compute
   *  features @ proj.weight^T + bias without transposing storage (row-vector
   *  dot via matmul against a [confDim,1] view). */
  #confidence(h1: MlxArray, prevTok: number): number {
    if (!this.#confW || !this.#confB)
      throw new Error("confidence: confidence head disabled");
    let feat = h1;
    let ownFeat = false;
    if (this.cfg.confidence_head_with_markov) {
      if (!this.#markovW1) throw new Error("confidence_head_with_markov requires markov_rank > 0");
      const idxArr = ops.fromInt32([prevTok], [1]);
      const idxU32 = idxArr.astype(Dtype.uint32);
      idxArr.dispose();
      const e1 = ops.takeAxis(this.#markovW1, idxU32, 0); // [1,rank]
      idxU32.dispose();
      const e1f = e1.dtype === h1.dtype ? e1 : disposing(e1, e1.astype(h1.dtype));
      feat = ops.concatAxis([h1, e1f], 1); // [1, hidden+rank]
      e1f.dispose();
      ownFeat = true;
    }
    // Reference precision (AcceptRatePredictor / predict_confidence_step):
    // the nn.Linear runs in MODEL dtype (bf16 on the real checkpoint) and is
    // .float()ed AFTER — computing it in f32 here flipped borderline
    // threshold comparisons vs torch (2026-07-06 port review). So: matmul +
    // bias in feat's dtype against the precomputed transpose view, then cast.
    let z = ops.matmul(feat, this.#confWT!);
    if (ownFeat) feat.dispose();
    z = disposing(z, ops.add(z, this.#confB));
    if (z.dtype !== Dtype.float32) z = disposing(z, z.astype(Dtype.float32));
    z = disposing(z, ops.sigmoid(z));
    const v = z.toFloat32()[0]!;
    z.dispose();
    return v;
  }

  /**
   * The whole per-round draft. Two-pass structure, matching the source
   * exactly (draft_ops.py build_dspark_proposal calls sample_draft_tokens
   * for the FULL block first, THEN predicts confidence over the full
   * sampled sequence, THEN truncates — confidence does not short-circuit
   * sampling):
   *
   *   base_draft_logits = model.compute_logits(proposal_hidden_states)      # [1,γ,V], softcapped
   *   sampled_tokens, draft_logits = model.sample_draft_tokens(             # full γ, sequential Markov
   *       base_draft_logits, first_prev_token_ids=anchor, temperature=0)
   *   confidence_logits = predict_confidence_step(                         # full γ, over the SAMPLED prevs
   *       proposal_hidden_states,
   *       prev_token_ids=cat([anchor, sampled_tokens[:, :-1]]))
   *   proposal_draft_tokens = _confident_prefix_length(confidence_logits, threshold)
   *   verify_input_ids = cat([anchor, sampled_tokens[:, :proposal_draft_tokens]])
   *
   * Transcribed sequential Markov sampling (modeling.py sample_draft_tokens
   * → markov_head.py VanillaMarkov.sample_block_tokens, temperature=0 ⇒
   * sample_tokens's argmax branch — RNG-free):
   *   prev = first_prev_token_ids   # == anchorTok
   *   for k in range(block_size):
   *       step_logits = base_logits[:,k] + markov_w2(markov_w1(prev))
   *       tok = argmax(step_logits)
   *       prev = tok
   *
   * Transcribed confidence truncation (draft_ops.py _confident_prefix_length):
   *   if threshold <= 0: return block_size          # disabled — full γ
   *   below = sigmoid(confidence_logits) < threshold
   *   if not below.any(): return block_size
   *   return first index where below is True         # ℓ can be 0 (EMPTY proposal)
   *
   * ctxKV: this round's cached context K/V (see projectContextKV/crop notes
   * on the class doc — caller owns cache lifetime and crop-after-round).
   * anchorTok: the just-verified/bonus token starting this block.
   * anchorPos: its absolute sequence position (blockPositions[0]).
   */
  draftBlock(ctxKV: ContextKV[], anchorTok: number, anchorPos: number): DraftBlockResult {
    const G = this.gamma;
    const V = this.cfg.vocab_size;
    const blockIds = [anchorTok, ...Array(G - 1).fill(this.cfg.mask_token_id)];
    const blockPositions = Array.from({ length: G }, (_, i) => anchorPos + i);

    const h = this.#forwardBackbone(ctxKV, blockIds, blockPositions); // [1,G,hidden]
    const baseLogitsRaw = this.#computeLogits(h); // [1,G,vocab], softcapped, model dtype

    // Pass 1: sequential Markov-biased argmax sampling over the FULL block —
    // in MODEL dtype end to end (reference precision: modeling.py
    // compute_logits → apply_step_logits → sample_tokens all run bf16; the
    // argmax is over the bf16 sum. f32 here reordered near-ties vs torch —
    // 2026-07-06 port review, fidelity fix).
    const sampledTokens: number[] = [];
    let prevTok = anchorTok;
    for (let k = 0; k < G; k++) {
      const base1 = baseLogitsRaw.slice([0, k, 0], [1, k + 1, V]);
      const baseFlat = ops.reshape(base1, [1, V]);
      base1.dispose();
      let stepLogits = baseFlat;
      if (this.#markovW1) {
        const bias = this.#markovStepBias(prevTok); // [1,V], model dtype
        stepLogits = ops.add(baseFlat, bias);
        baseFlat.dispose();
        bias.dispose();
      }
      const am = ops.argmaxAxis(stepLogits, -1);
      const tok = ops.itemUint32(am);
      am.dispose();
      stepLogits.dispose();
      sampledTokens.push(tok);
      prevTok = tok;
    }

    // The returned artifact is an f32 COPY (callers read/compare host-side);
    // sampling above never touches it.
    const baseLogits =
      baseLogitsRaw.dtype === Dtype.float32 ? baseLogitsRaw : disposing(baseLogitsRaw, baseLogitsRaw.astype(Dtype.float32));

    // Pass 2: confidence over the full block, prev_token_ids = [anchor,
    // sampled[:-1]] (_predict_confidence_logits) — independent of pass 1's
    // truncation decision, computed for every position.
    let proposalLen = G;
    if (this.#confW) {
      const confVals: number[] = [];
      let confPrev = anchorTok;
      for (let k = 0; k < G; k++) {
        const h1 = h.slice([0, k, 0], [1, k + 1, this.hidden]);
        const h1Flat = ops.reshape(h1, [1, this.hidden]);
        h1.dispose();
        const cVal = this.#confidence(h1Flat, confPrev);
        h1Flat.dispose();
        confVals.push(cVal);
        confPrev = sampledTokens[k]!;
      }
      if (this.cfg.confidence_threshold > 0) {
        const idx = confVals.findIndex((c) => c < this.cfg.confidence_threshold);
        proposalLen = idx === -1 ? G : idx;
      }
      const tokens = sampledTokens.slice(0, proposalLen);
      const conf = confVals.slice(0, proposalLen);
      h.dispose();
      return { tokens, conf, baseLogits };
    }

    h.dispose();
    return { tokens: sampledTokens, conf: [], baseLogits };
  }

  dispose(): void {
    this.#embed.dispose();
    this.#fcT.dispose();
    this.#hiddenNorm.dispose();
    this.#norm.dispose();
    this.#lmHeadT.dispose();
    this.ropeFreqs.dispose();
    for (const l of this.#layers) {
      l.qProjT.dispose(); l.kProjT.dispose(); l.oProjT.dispose();
      l.qNorm.dispose(); l.kNorm.dispose();
      l.inputNorm.dispose(); l.postAttnNorm.dispose();
      l.preFfNorm.dispose(); l.postFfNorm.dispose();
      l.gateProjT.dispose(); l.upProjT.dispose(); l.downProjT.dispose();
      l.layerScalar.dispose();
    }
    this.#markovW1?.dispose();
    this.#markovW2T?.dispose();
    this.#confW?.dispose();
    this.#confWT?.dispose();
    this.#confB?.dispose();
    this.#w.dispose();
  }
}

function assertContiguous(positions: number[]): void {
  for (let i = 1; i < positions.length; i++) {
    if (positions[i] !== positions[i - 1]! + 1)
      throw new Error(`DeepspecDrafter: expected contiguous positions, got ${JSON.stringify(positions)}`);
  }
}
