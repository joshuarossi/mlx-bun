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
import type { SharedKv } from "../model/gemma4";

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

    const T = (name: string) => w.tensor(name);
    const transposed = (name: string): MlxArray => {
      const a = ops.transposeAxes(T(name), [1, 0]);
      const c = ops.contiguous(a);
      a.dispose();
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
      this.#ordering = ops.reshape(ord32, [this.numCentroids, this.vocabPerCentroid]);
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
        ropeFreqs = MlxArray.fromFloat32(freqs, [n]);
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
  }

  static async load(modelDir: string): Promise<GemmaAssistantDrafter> {
    const cfg = (await Bun.file(`${modelDir}/config.json`).json()) as Record<string, any>;
    return new GemmaAssistantDrafter(await Weights.open(modelDir), cfg);
  }

  /** f32-internal RMSNorm (reference _RMSNorm casts through float32). */
  #rms(x: MlxArray, weight: MlxArray): MlxArray {
    const f = x.astype(Dtype.float32);
    const n = ops.rmsNorm(f, weight, this.eps);
    f.dispose();
    const back = n.astype(x.dtype);
    n.dispose();
    return back;
  }

  /** One draft step. All inputs (1,1,·); sharedKv holds the target's
   *  donor K/V in chronological order. position = target's last position. */
  forward(
    lastTokenEmb: MlxArray, targetHidden: MlxArray,
    sharedKv: { sliding: [MlxArray, MlxArray]; full: [MlxArray, MlxArray] },
    position: number,
  ): DrafterStep {
    let h = ops.concatAxis([lastTokenEmb, targetHidden], 2); // (1,1,2*backbone)
    h = disposing(h, ops.matmul(h, this.#prePT));            // (1,1,256)

    for (const blk of this.#blocks) {
      const [k, v] = blk.layerType === "sliding_attention" ? sharedKv.sliding : sharedKv.full;
      const kLen = k.shape[2]!;

      // sliding-window additive mask over cached K positions
      let mask: MlxArray | null = null;
      if (blk.layerType === "sliding_attention") {
        const firstCached = position - kLen + 1;
        const windowStart = Math.max(0, position - this.slidingWindow + 1);
        const allowedFrom = Math.max(0, windowStart - firstCached);
        if (allowedFrom > 0) {
          const m = new Float32Array(kLen);
          for (let i = 0; i < allowedFrom; i++) m[i] = -1e9;
          const mf = MlxArray.fromFloat32(m, [1, 1, 1, kLen]);
          mask = mf.astype(k.dtype);
          mf.dispose();
        }
      }

      const residual = h;
      let x = this.#rms(h, blk.inputNorm);
      // Q-only attention
      let q = ops.matmul(x, blk.qProj);
      x.dispose();
      q = disposing(q, ops.reshape(q, [1, 1, this.nHeads, blk.headDim]));
      q = disposing(q, this.#rms(q, blk.qNorm));
      q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
      q = disposing(q, ops.rope(q, blk.headDim, blk.ropeBase, position, blk.ropeFreqs));
      let attn = ops.sdpa(q, k, v, Math.pow(blk.headDim, -0.5), mask ? "array" : "", mask);
      q.dispose();
      mask?.dispose();
      attn = disposing(attn, ops.transposeAxes(attn, [0, 2, 1, 3]));
      attn = disposing(attn, ops.reshape(attn, [1, 1, this.nHeads * blk.headDim]));
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

    let token: number;
    if (this.useCentroids) {
      // centroid decode → drafted token (argmax-equivalent shortcut)
      const cScores = ops.matmul(h, this.#centroidsT!);         // (1,1,2048)
      const flat = ops.reshape(cScores, [1, this.numCentroids]);
      cScores.dispose();
      const neg = ops.neg(flat);
      flat.dispose();
      const part = ops.argpartitionAxis(neg, this.topK - 1, -1);
      neg.dispose();
      const topIdx = part.slice([0, 0], [1, this.topK]);        // (1, topK)
      part.dispose();
      const topFlat = ops.reshape(topIdx, [this.topK]);
      topIdx.dispose();
      const candIds = ops.takeAxis(this.#ordering!, topFlat, 0); // (topK, vpc) int32
      topFlat.dispose();
      const candFlat = ops.reshape(candIds, [this.topK * this.vocabPerCentroid]);
      candIds.dispose();
      const candEmb = ops.takeAxis(this.#embed, candFlat, 0);   // (topK*vpc, hidden)
      const hVec = ops.reshape(h, [this.hidden, 1]);
      const scores = ops.matmul(candEmb, hVec);                  // (topK*vpc, 1)
      candEmb.dispose();
      hVec.dispose();
      const scoresFlat = ops.reshape(scores, [1, this.topK * this.vocabPerCentroid]);
      scores.dispose();
      const am = ops.argmaxAxis(scoresFlat, -1);
      scoresFlat.dispose();
      const winner = ops.itemUint32(am);
      am.dispose();
      const tokArr = candFlat.slice([winner], [winner + 1]);
      candFlat.dispose();
      const tokU32 = tokArr.astype(Dtype.uint32);
      tokArr.dispose();
      token = ops.itemUint32(tokU32);
      tokU32.dispose();
    } else {
      // tied-embedding head: token = argmax_v (embed[v] · h) over the
      // full vocab — the dense form the centroid head approximates.
      const V = this.#embed.shape[0]!;
      const hVec = ops.reshape(h, [this.hidden, 1]);
      const scores = ops.matmul(this.#embed, hVec);             // (vocab, 1)
      hVec.dispose();
      const scoresFlat = ops.reshape(scores, [1, V]);
      scores.dispose();
      const am = ops.argmaxAxis(scoresFlat, -1);
      scoresFlat.dispose();
      token = ops.itemUint32(am);
      am.dispose();
    }

    const nextHidden = ops.matmul(h, this.#postPT);           // (1,1,backbone)
    h.dispose();
    return { token, nextHidden };
  }
}

function disposing(old: MlxArray, next: MlxArray): MlxArray {
  old.dispose();
  return next;
}
