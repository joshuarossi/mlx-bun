// Gemma-4 "-assistant" drafter — port of optiq's
// runtime/spec/drafters/gemma_assistant.py (itself a port of Ollama's
// x/models/gemma4/assistant.go, MIT).
//
// Q-only 4-layer transformer: K/V come from the TARGET's last sliding-
// and full-attention donor caches at call time; pre/post projections
// bridge target hidden space (backbone) <-> drafter space.
//
// Two output-head variants ship across the Gemma-4 drafter family — we
// pick by TENSOR PRESENCE, not config (the larger artifacts declare
// num_centroids in config.json but don't ship the centroid tensors —
// the field is vestigial):
//   - CENTROID head (small E2B/E4B drafters, `gemma4_assistant`):
//     2048 centroids, top-32 × 128 tokens via a precomputed ordering.
//   - TIED-EMBEDDING head (larger 12B/26B `gemma4_unified_assistant`):
//     no centroids, no separate lm_head — logits = embed_tokens · h over
//     the full vocab (the dense form the centroid head approximates).
//
// Implementation deviation (centroid path, argmax-equivalent): the
// reference scatters candidate scores into full-vocab logits initialised
// to -1e30 and argmaxes; we argmax over the 4096 candidate scores and map
// through candidate ids directly — same winner, no 262k materialisation.
// The drafter's numeric details only influence acceptance RATE, never
// output correctness (the target's verify decides every token).

import type { ModelConfig } from "../config";
import { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { disposeResources } from "../engine/resources";
import type { SharedKv } from "../model/gemma4";

/** The graph borrows donor attention; storage owns validity and encoding. */
export interface AssistantAttention {
  attend(query: MlxArray, scale: number, window: number | null): MlxArray;
}
export interface AssistantDonors { sliding: AssistantAttention; full: AssistantAttention; }

/** Legacy plain donor adapter. The common graph never reads cache geometry. */
export function plainAssistantDonors(shared: { sliding: [MlxArray, MlxArray]; full: [MlxArray, MlxArray] },
  position: number): AssistantDonors {
  const bind = ([keys, values]: [MlxArray, MlxArray]): AssistantAttention => ({
    attend(query, scale, window) {
      const length = keys.shape[2]!;
      const from = window === null ? 0 : Math.max(0, Math.max(0, position - window + 1) - (position - length + 1));
      using floats = from ? MlxArray.fromFloat32(Float32Array.from({ length }, (_, i) => i < from ? -1e9 : 0), [1,1,1,length]) : null;
      using mask = floats?.astype(keys.dtype);
      return ops.sdpa(query, keys, values, scale, mask ? "array" : "", mask ?? null);
    },
  });
  return { sliding: bind(shared.sliding), full: bind(shared.full) };
}

export interface DrafterRowsStep { tokens: MlxArray; nextHidden: MlxArray; }

export interface DrafterStep {
  /** Drafted token id. */
  token: number;
  /** Post-projected hidden (1,1,backbone) — feeds the next draft step. */
  nextHidden: MlxArray;
}

interface Block {
  layerType: string;
  headDim: number;
  ropeBase: number | null;
  ropeFreqs: MlxArray | null;
  qProj: MlxArray;
  oProj: MlxArray;
  qNorm: MlxArray;
  inputNorm: MlxArray;
  postAttnNorm: MlxArray;
  preFfNorm: MlxArray;
  postFfNorm: MlxArray;
  gateProj: MlxArray;
  upProj: MlxArray;
  downProj: MlxArray;
  layerScalar: MlxArray;
}

export class GemmaAssistantDrafter {
  readonly hidden: number;
  readonly nHeads: number;
  readonly slidingWindow: number;
  readonly eps: number;
  readonly numCentroids: number;
  readonly topK: number;
  readonly vocabPerCentroid: number;
  #w: Weights;
  #owned: MlxArray[] = [];
  #blocks: Block[] = [];
  readonly useCentroids: boolean;
  #prePT: MlxArray; // pre_projection transposed [in, out]
  #postPT: MlxArray;
  #centroidsT: MlxArray | null = null; // [hidden, numCentroids]
  #ordering: MlxArray | null = null;   // [numCentroids, vocabPerCentroid] int32
  #embed: MlxArray;      // drafter token embeddings [vocab, hidden]
  #norm: MlxArray;

  private constructor(w: Weights, cfg: Record<string, any>) {
    const t = cfg.text_config ?? cfg;
    this.hidden = t.hidden_size;
    this.nHeads = t.num_attention_heads;
    this.slidingWindow = t.sliding_window;
    this.eps = t.rms_norm_eps;
    this.numCentroids = cfg.num_centroids;
    this.topK = cfg.centroid_intermediate_top_k;
    this.vocabPerCentroid = Math.floor(t.vocab_size / this.numCentroids);
    this.#w = w;

    const own = (array: MlxArray) => { this.#owned.push(array); return array; };
    try {
      const T = (name: string) => w.tensor(name);
      // Keep the oracle's strided weight.T: a contiguous transpose changes
      // M4 matmul rounding and allocates a second copy of every linear weight.
      const transposed = (name: string): MlxArray => {
        const c = own(ops.transposeAxes(T(name), [1, 0]));
        c.eval();
        return c;
      };
      this.#prePT = transposed("pre_projection.weight");
      this.#postPT = transposed("post_projection.weight");
      this.#embed = T("model.embed_tokens.weight");
      this.#norm = T("model.norm.weight");
      // Head variant: only the small drafters ship the centroid tensors.
      // The 12B/26B artifacts ship a tied embed_tokens head instead (their
      // config still declares num_centroids — ignore it, trust the tensors).
      this.useCentroids = w.has("masked_embedding.centroids.weight");
      if (this.useCentroids) {
        this.#centroidsT = transposed("masked_embedding.centroids.weight");
        const ord64 = T("masked_embedding.token_ordering");
        const ord32 = ord64.astype(Dtype.int32);
        this.#ordering = own(ops.reshape(ord32, [this.numCentroids, this.vocabPerCentroid]));
        this.#ordering.eval();
        ord32.dispose();
      }

      const ropeP = t.rope_parameters ?? {};
      for (let i = 0; i < t.num_hidden_layers; i++) {
        const layerType = t.layer_types[i];
        const isFull = layerType === "full_attention";
        const headDim = isFull ? t.global_head_dim : t.head_dim;
        const rp = ropeP[layerType] ?? {};
        let ropeBase: number | null = rp.rope_theta ?? (isFull ? 1e6 : 1e4);
        let ropeFreqs: MlxArray | null = null;
        const partial = rp.partial_rotary_factor ?? 1.0;
        if (isFull && partial < 1.0) {
          // ProportionalRoPE freqs, matching the target's donor-K rope
          const rotated = Math.floor(headDim * partial);
          const n = headDim / 2;
          const freqs = new Float32Array(n).fill(Infinity);
          for (let k = 0; k < rotated / 2; k++)
            freqs[k] = Math.pow(ropeBase!, (2 * k) / headDim);
          ropeFreqs = own(MlxArray.fromFloat32(freqs, [n]));
          ropeBase = null;
        }
        const p = `model.layers.${i}`;
        this.#blocks.push({
          layerType, headDim, ropeBase, ropeFreqs,
          qProj: transposed(`${p}.self_attn.q_proj.weight`),
          oProj: transposed(`${p}.self_attn.o_proj.weight`),
          qNorm: T(`${p}.self_attn.q_norm.weight`),
          inputNorm: T(`${p}.input_layernorm.weight`),
          postAttnNorm: T(`${p}.post_attention_layernorm.weight`),
          preFfNorm: T(`${p}.pre_feedforward_layernorm.weight`),
          postFfNorm: T(`${p}.post_feedforward_layernorm.weight`),
          gateProj: transposed(`${p}.mlp.gate_proj.weight`),
          upProj: transposed(`${p}.mlp.up_proj.weight`),
          downProj: transposed(`${p}.mlp.down_proj.weight`),
          layerScalar: T(`${p}.layer_scalar`),
        });
      }
    } catch (error) { disposeResources(this.#owned.splice(0)); throw error; }
  }

  static async load(modelDir: string): Promise<GemmaAssistantDrafter> {
    const cfg = (await Bun.file(`${modelDir}/config.json`).json()) as Record<string, any>;
    const weights = await Weights.open(modelDir);
    try { return new GemmaAssistantDrafter(weights, cfg); }
    catch (error) { weights.dispose(); throw error; }
  }

  dispose(): void { disposeResources([...this.#owned.splice(0), this.#w]); }

  /** f32-internal RMSNorm (reference _RMSNorm casts through float32). */
  #rms(x: MlxArray, weight: MlxArray): MlxArray {
    const f = x.astype(Dtype.float32);
    const n = ops.rmsNorm(f, weight, this.eps);
    f.dispose();
    const back = n.astype(x.dtype);
    n.dispose();
    return back;
  }

  /** The request adapter consumes the same graph as a batch of one.
   * Donors are chronological; position is the target's last position. */
  forward(lastTokenEmb: MlxArray, targetHidden: MlxArray,
    sharedKv: { sliding: [MlxArray, MlxArray]; full: [MlxArray, MlxArray] }, position: number): DrafterStep {
    const result = this.forwardRows(lastTokenEmb, targetHidden, plainAssistantDonors(sharedKv, position), position);
    try { return { token: ops.itemUint32(result.tokens), nextHidden: result.nextHidden }; }
    catch (error) { result.nextHidden.dispose(); throw error; }
    finally { result.tokens.dispose(); }
  }

  #sampleRows(h: MlxArray, B: number): MlxArray {
    if (this.useCentroids) {
      using scores = ops.matmul(h, this.#centroidsT!);
      using flat = ops.reshape(scores, [B, this.numCentroids]);
      using neg = ops.neg(flat);
      using partition = ops.argpartitionAxis(neg, this.topK - 1, -1);
      using top = partition.slice([0, 0], [B, this.topK]);
      using topFlat = ops.reshape(top, [B * this.topK]);
      using candidates = ops.takeAxis(this.#ordering!, topFlat, 0);
      const count = this.topK * this.vocabPerCentroid;
      using ids = ops.reshape(candidates, [B, count]);
      using flatIds = ops.reshape(ids, [B * count]);
      using embeddings = ops.takeAxis(this.#embed, flatIds, 0);
      using matrix = ops.reshape(embeddings, [B, count, this.hidden]);
      using vector = ops.reshape(h, [B, 1, this.hidden]);
      // The oracle rounds each bf16 product before reduction. Matmul's
      // accumulation changes candidate rankings on M1, even at identical h.
      using products = ops.mul(matrix, vector);
      using candidateScores = ops.sumAxis(products, -1, false);
      using maximum = ops.maxAxis(candidateScores, -1, true);
      using winners = ops.equal(candidateScores, maximum);
      // Sparse full-vocabulary argmax chooses the lowest token ID on a tie.
      // Apply that rule directly to the candidates without a vocab-size scatter.
      using sentinel = ops.fromInt32([this.#embed.shape[0]!], []);
      using eligible = ops.where(winners, ids, sentinel);
      using selected = ops.minAxis(eligible, -1, false);
      return selected.astype(Dtype.uint32);
    }
    using rows = ops.reshape(h, [B, this.hidden]);
    using vector = B === 1 ? ops.reshape(h, [this.hidden, 1]) : ops.transposeAxes(rows, [1, 0]);
    using scores = ops.matmul(this.#embed, vector);
    using flat = B === 1 ? ops.reshape(scores, [1, this.#embed.shape[0]!]) : ops.transposeAxes(scores, [1, 0]);
    return ops.argmaxAxis(flat, -1);
  }

  /** Numerical graph only. Callers supply donor validity masks for different
   * row positions; token selection remains on device across the draft chain. */
  forwardRows(lastTokenEmb: MlxArray, targetHidden: MlxArray,
    donors: AssistantDonors, position: number | MlxArray): DrafterRowsStep {
    const B = lastTokenEmb.shape[0]!;
    let h = ops.concatAxis([lastTokenEmb, targetHidden], 2); // (B,1,2*backbone)
    h = disposing(h, ops.matmul(h, this.#prePT));            // (B,1,256)

    for (const blk of this.#blocks) {
      const donor = blk.layerType === "sliding_attention" ? donors.sliding : donors.full;
      const residual = h;
      let x = this.#rms(h, blk.inputNorm);
      // Q-only attention
      let q = ops.matmul(x, blk.qProj);
      x.dispose();
      q = disposing(q, ops.reshape(q, [B, 1, this.nHeads, blk.headDim]));
      q = disposing(q, this.#rms(q, blk.qNorm));
      q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
      q = disposing(q, typeof position === "number"
        ? ops.rope(q, blk.headDim, blk.ropeBase, position, blk.ropeFreqs)
        : ops.ropeDynamic(q, blk.headDim, blk.ropeBase, position, blk.ropeFreqs));
      let attn = donor.attend(q, Math.pow(blk.headDim, -0.5),
        blk.layerType === "sliding_attention" ? this.slidingWindow : null);
      q.dispose();
      attn = disposing(attn, ops.transposeAxes(attn, [0, 2, 1, 3]));
      attn = disposing(attn, ops.reshape(attn, [B, 1, this.nHeads * blk.headDim]));
      attn = disposing(attn, ops.matmul(attn, blk.oProj));
      attn = disposing(attn, this.#rms(attn, blk.postAttnNorm));
      h = ops.add(residual, attn);
      residual.dispose();
      attn.dispose();

      const res2 = h;
      let f = this.#rms(h, blk.preFfNorm);
      const g = ops.matmul(f, blk.gateProj);
      const u = ops.matmul(f, blk.upProj);
      f.dispose();
      const act = ops.geluApprox(g);
      g.dispose();
      let mlp = ops.mul(act, u);
      act.dispose();
      u.dispose();
      mlp = disposing(mlp, ops.matmul(mlp, blk.downProj));
      mlp = disposing(mlp, this.#rms(mlp, blk.postFfNorm));
      h = ops.add(res2, mlp);
      res2.dispose();
      mlp.dispose();

      h = disposing(h, ops.mul(h, blk.layerScalar));
    }

    h = disposing(h, this.#rms(h, this.#norm));

    const tokens = this.#sampleRows(h, B);
    const nextHidden = ops.matmul(h, this.#postPT);           // (B,1,backbone)
    h.dispose();
    return { tokens, nextHidden };
  }
}

function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}
