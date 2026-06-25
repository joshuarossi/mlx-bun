// DiffusionGemma-26B-A4B-it (model_type "diffusion_gemma") — the first
// NON-autoregressive model in the codebase. Instead of a left-to-right AR loop
// it runs an ENCODER prefill over the prompt (builds a KV cache) and then a
// DECODER pass over a fixed 256-token "canvas" that it denoises over a few
// steps. This file is the D1 static graph: one full forward
//   encoder(prompt) -> cache ;  decoder(canvas, cache) -> hidden -> tied head
// held bit-exact (KL/argmax where the quantized GEMV is 1-ULP off) against the
// mlx-optiq reference (optiq IS the oracle here — stock mlx-lm can't load it).
//
// Ported verbatim from optiq/vlm/_mlxvlm/models/diffusion_gemma/language.py.
// Reuses mlx-bun's quantized primitives (QuantizedLinear/Embedding/SwitchLinear,
// RMSNorm, KVCache/RotatingKVCache) from gemma4-base. Architecture deltas vs
// gemma4 (verified against the checkpoint, see docs/design/diffusion-gemma-port.md):
//   - attention scale=1.0, NO attention softcap (only final-logit softcap 30 fp32)
//   - QK/V-norm POST-proj / PRE-RoPE; v_norm is RMSNormNoScale; V gets no RoPE
//   - full-attention layers (5,11,17,23,29) reuse k as v (no v_proj), hd=512 kv=2,
//     partial-rotary 0.25; sliding layers hd=256 kv=8
//   - per layer: parallel dense-MLP + 128-expert top-8 MoE, summed via 7 RMSNorms
//     and a per-layer `layer_scalar`
//   - experts use a FUSED gate_up_proj SwitchLinear (split at moe_intermediate)
//   - plain nn.RMSNorm everywhere (NO Gemma 1+weight offset) — weights used as-is
//   - tied LM head via the 4-bit QuantizedEmbedding.asLinear
//   - SelfConditioning MLP wraps the canvas embeddings every step (zero signal on
//     the first step still applies its RMSNormNoScale post-norm)

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import {
  disposing,
  KVCache,
  LoraState,
  QuantizedEmbedding,
  QuantizedLinear,
  QuantizedSwitchLinear,
  RMSNorm,
  RotatingKVCache,
  type Cache,
} from "./gemma4-base";
import { DiffusionVisionTower } from "../vision/diffusion-vision";

/** A mask in the shape ops.sdpa wants: a mode string + optional bool array.
 *  `null` array with mode "" means "no mask" (full attention). */
interface SdpaMask {
  mode: "" | "causal" | "array";
  arr: MlxArray | null;
}
const NO_MASK: SdpaMask = { mode: "", arr: null };

/** KVCache / RotatingKVCache both expose temporalView() (chronological K/V
 *  sliced to offset); the base Cache interface does not declare it. The decoder
 *  only ever uses those two concrete caches. */
type TemporalCache = Cache & { temporalView(): [MlxArray, MlxArray] };

/** geglu(gate, x) = gelu_approx(gate) * x  (reference language.py:geglu). */
function geglu(gate: MlxArray, x: MlxArray): MlxArray {
  const act = ops.geluApprox(gate);
  const out = ops.mul(act, x);
  act.dispose();
  return out;
}

/** Fused fp32-upcast tanh softcap: tanh(x_fp32 / cap) * cap. Stays f32 (the
 *  reference make_compiled_softcap returns f32; the golden is dumped f32). */
function softcapFp32(logits: MlxArray, cap: number): MlxArray {
  const xf = logits.astype(Dtype.float32);
  const capArr = ops.scalarLike(cap, xf);
  const scaled = ops.div(xf, capArr);
  xf.dispose();
  const t = ops.tanh(scaled);
  scaled.dispose();
  const out = ops.mul(t, capArr);
  t.dispose();
  capArr.dispose();
  return out;
}

/** Dense MLP: down(geglu(gate(x), up(x))). */
class DiffMLP {
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;
  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }
  forward(x: MlxArray): MlxArray {
    const g = this.gate.forward(x);
    const u = this.up.forward(x);
    const m = geglu(g, u);
    g.dispose();
    u.dispose();
    const out = this.down.forward(m);
    m.dispose();
    return out;
  }
}

/** Router: pre-projection RMSNorm (no-scale) * scale * hidden**-0.5, top-8
 *  argpartition, softmax(precise) * per_expert_scale[idx]. */
class DiffRouter {
  readonly proj: QuantizedLinear;
  readonly scale: MlxArray; // per-hidden-dim scale (applied AFTER the no-scale norm)
  readonly rootSize: number; // hidden**-0.5
  readonly perExpertScale: MlxArray;
  readonly eps: number;
  readonly numExperts: number;
  readonly topK: number;
  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.proj = QuantizedLinear.load(weights, `${prefix}.proj`, config);
    this.scale = weights.tensor(`${prefix}.scale`);
    this.rootSize = Math.pow(t.hiddenSize, -0.5);
    this.perExpertScale = weights.tensor(`${prefix}.per_expert_scale`);
    this.eps = t.rmsNormEps;
    this.numExperts = t.numExperts;
    this.topK = t.topKExperts;
  }
  /** x: [T, H] -> { indices: [T, k], weights: [T, k] }. */
  forward(x: MlxArray): { indices: MlxArray; weights: MlxArray } {
    // Match the reference EXACTLY (do NOT fold the post-scale into the norm
    // weight — that changes the bf16 rounding and shifts the softmax weights):
    //   x = rms_norm(x, None, eps); x = x * scale * hidden**-0.5
    let normed = ops.rmsNorm(x, null, this.eps);
    normed = disposing(normed, ops.mul(normed, this.scale));
    normed = disposing(normed, ops.mulScalar(normed, this.rootSize));
    const scores = this.proj.forward(normed);
    normed.dispose();
    const part = ops.argpartitionAxis(scores, this.numExperts - this.topK, -1);
    const [T] = scores.shape as [number, number];
    const indices = part.slice([0, this.numExperts - this.topK], [T, this.numExperts]);
    part.dispose();
    let w = ops.takeAlongAxis(scores, indices, -1);
    scores.dispose();
    w = disposing(w, ops.softmaxAxis(w, -1, true));
    const gathered = ops.takeAxis(this.perExpertScale, indices, 0);
    w = disposing(w, ops.mul(w, gathered));
    gathered.dispose();
    return { indices, weights: w };
  }
}

/** 128-expert top-8 MoE with a FUSED gate_up SwitchLinear (split at
 *  moe_intermediate_size) + a down SwitchLinear. _gather_sort / _scatter_unsort
 *  exactly as mlx_lm.models.switch_layers (sort threshold idx.size >= 64). */
class DiffExperts {
  readonly gateUp: QuantizedSwitchLinear;
  readonly down: QuantizedSwitchLinear;
  readonly hiddenDims: number; // moe_intermediate_size (split point)
  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gateUp = QuantizedSwitchLinear.load(weights, `${prefix}.gate_up_proj`, config);
    this.down = QuantizedSwitchLinear.load(weights, `${prefix}.down_proj`, config);
    this.hiddenDims = config.text.moeIntermediateSize;
  }
  /** x: [T, H], indices/weights: [T, k] -> [T, H]. */
  forward(x: MlxArray, indices: MlxArray, weights: MlxArray): MlxArray {
    let h = ops.expandDims(x, -2); // [T, 1, H]
    h = disposing(h, ops.expandDims(h, -3)); // [T, 1, 1, H]
    const doSort = indices.size >= 64;
    let idx = indices;
    let order: MlxArray | null = null;
    let invOrder: MlxArray | null = null;
    if (doSort) {
      const k = indices.shape[indices.ndim - 1]!;
      const idxFlat = ops.reshape(indices, [indices.size]);
      order = ops.argsortAxis(idxFlat, 0);
      invOrder = ops.argsortAxis(order, 0);
      const kS = ops.scalarLike(k, order);
      const rowIdx = ops.floorDivide(order, kS);
      kS.dispose();
      const H = h.shape[h.ndim - 1]!;
      const flat = ops.reshape(h, [-1, 1, H]);
      h.dispose();
      h = ops.takeAxis(flat, rowIdx, 0);
      flat.dispose();
      rowIdx.dispose();
      idx = ops.takeAxis(idxFlat, order, 0);
      idxFlat.dispose();
    }

    const gateUp = this.gateUp.forward(h, idx, doSort);
    h.dispose();
    const parts = ops.split(gateUp, [this.hiddenDims], -1);
    gateUp.dispose();
    const gate = parts[0]!;
    const up = parts[1]!;
    const mid = geglu(gate, up);
    gate.dispose();
    up.dispose();
    let y = this.down.forward(mid, idx, doSort);
    mid.dispose();
    if (idx !== indices) idx.dispose();

    if (doSort) {
      y = disposing(y, ops.takeAxis(y, invOrder!, 0));
      invOrder!.dispose();
      order!.dispose();
      const shape = [...indices.shape, 1, y.shape[y.ndim - 1]!]; // [T, k, 1, H]
      y = disposing(y, ops.reshape(y, shape));
    }
    // squeeze(-2): [T, k, 1, H] -> [T, k, H]
    {
      const shape = y.shape;
      shape.splice(shape.length - 2, 1);
      y = disposing(y, ops.reshape(y, shape));
    }
    // (y * weights[..., None]).sum(axis=-2) -> [T, H]
    const w = ops.expandDims(weights, -1);
    const wy = ops.mul(y, w);
    w.dispose();
    y.dispose();
    return disposing(wy, ops.sumAxis(wy, -2, false));
  }
}

/** SelfConditioning: post_norm(inputs_embeds + down(geglu(gate(pre_norm(signal)),
 *  up(pre_norm(signal))))). pre_norm is RMSNorm, post_norm is RMSNormNoScale. */
class SelfConditioning {
  readonly preNorm: RMSNorm;
  readonly postNorm: RMSNorm; // RMSNormNoScale (null weight)
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;
  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const eps = config.text.rmsNormEps;
    this.preNorm = new RMSNorm(weights.tensor(`${prefix}.pre_norm.weight`), eps);
    this.postNorm = new RMSNorm(null, eps);
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }
  forward(inputsEmbeds: MlxArray, signal: MlxArray): MlxArray {
    const normed = this.preNorm.forward(signal);
    const g = this.gate.forward(normed);
    const u = this.up.forward(normed);
    normed.dispose();
    const m = geglu(g, u);
    g.dispose();
    u.dispose();
    const s = this.down.forward(m);
    m.dispose();
    const sum = ops.add(inputsEmbeds, s);
    s.dispose();
    const out = this.postNorm.forward(sum);
    sum.dispose();
    return out;
  }
}

/** Attention with the encoder (decoder=false, cache.updateAndFetch) and decoder
 *  (decoder=true, reads encoder K/V from cache temporal state and concatenates
 *  the canvas K/V) paths. scale=1.0, no softcap. */
class DiffAttention {
  readonly isSliding: boolean;
  readonly headDim: number;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly slidingWindow: number;
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear;
  readonly vProj: QuantizedLinear | null;
  readonly oProj: QuantizedLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm;
  readonly vNorm: RMSNorm; // RMSNormNoScale (null weight)
  readonly ropeBase: number | null;
  readonly ropeFreqs: MlxArray | null;

  constructor(weights: Weights, config: ModelConfig, prefix: string, layerType: string) {
    const t = config.text;
    this.isSliding = layerType === "sliding_attention";
    this.slidingWindow = t.slidingWindow;
    this.headDim = this.isSliding ? t.headDim : t.globalHeadDim;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = this.isSliding ? t.numKeyValueHeads : t.numGlobalKeyValueHeads;

    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    // Full-attention layers have no v_proj — they reuse the (pre-norm) k tensor.
    this.vProj = this.isSliding
      ? QuantizedLinear.load(weights, `${prefix}.v_proj`, config)
      : null;
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
    this.vNorm = new RMSNorm(null, t.rmsNormEps);

    // RoPE: default (sliding, theta 1e4) or proportional (full, partial 0.25,
    // theta 1e6). Proportional rotates only floor(head_dim*factor) dims; the
    // unrotated tail is freq=Infinity (cos=1, sin=0 → identity). Mirrors
    // gemma4.ts initialize_rope.
    const rp = t.ropeParameters[this.isSliding ? "sliding_attention" : "full_attention"]!;
    if (rp.ropeType === "default") {
      this.ropeBase = rp.ropeTheta;
      this.ropeFreqs = null;
    } else {
      const rotated = Math.floor(this.headDim * rp.partialRotaryFactor);
      const n = this.headDim / 2;
      const exponentsRaw = ops.arange(0, rotated, 2, Dtype.float32);
      const dims = ops.scalarLike(this.headDim, exponentsRaw);
      const exponents = ops.div(exponentsRaw, dims);
      exponentsRaw.dispose();
      dims.dispose();
      const base = ops.scalarLike(rp.ropeTheta, exponents);
      let rotFreqs = ops.pow(base, exponents);
      base.dispose();
      exponents.dispose();
      if (rp.factor !== 1.0) {
        const f = ops.scalarLike(rp.factor, rotFreqs);
        rotFreqs = disposing(rotFreqs, ops.mul(f, rotFreqs));
        f.dispose();
      }
      this.ropeBase = null;
      const tailLen = n - rotated / 2;
      if (tailLen > 0) {
        const tail = MlxArray.fromFloat32(new Float32Array(tailLen).fill(Infinity), [tailLen]);
        this.ropeFreqs = ops.concatAxis([rotFreqs, tail], 0);
        rotFreqs.dispose();
        tail.dispose();
      } else {
        this.ropeFreqs = rotFreqs;
      }
    }
  }

  #rope(x: MlxArray, offset: number): MlxArray {
    return ops.rope(x, this.headDim, this.ropeBase, offset, this.ropeFreqs);
  }

  forward(
    x: MlxArray,
    mask: SdpaMask,
    cache: Cache | null,
    decoder: boolean,
    offset: number,
  ): MlxArray {
    const [B, L] = x.shape as [number, number, number];

    const qFlat = this.qProj.forward(x);
    let q = ops.reshape(qFlat, [B, L, this.nHeads, this.headDim]);
    qFlat.dispose();
    q = disposing(q, this.qNorm.forward(q));
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    q = disposing(q, this.#rope(q, offset));

    const kFlat = this.kProj.forward(x);
    const kReshaped = ops.reshape(kFlat, [B, L, this.nKvHeads, this.headDim]);
    kFlat.dispose();
    // v reuses the pre-norm k tensor on full layers (v_proj is None there).
    let vReshaped: MlxArray;
    if (this.vProj) {
      const vFlat = this.vProj.forward(x);
      vReshaped = ops.reshape(vFlat, [B, L, this.nKvHeads, this.headDim]);
      vFlat.dispose();
    } else {
      vReshaped = kReshaped;
    }

    let k = this.kNorm.forward(kReshaped);
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    k = disposing(k, this.#rope(k, offset));
    let v = this.vNorm.forward(vReshaped); // no RoPE on V
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));
    if (vReshaped !== kReshaped) vReshaped.dispose();
    kReshaped.dispose();

    let maskMode = mask.mode;
    let maskArr = mask.arr;
    let maskArrOwned = false;

    if (decoder) {
      // Read the encoder K/V (chronological, sliced to offset) from the cache
      // and concatenate the canvas K/V. No cache update on the canvas pass.
      if (cache) {
        let [encK, encV] = (cache as TemporalCache).temporalView();
        if (this.isSliding) {
          const window = Math.max(this.slidingWindow - 1, 0);
          const encoderLen = encK.shape[2]!;
          if (window && encoderLen > window && offset >= encoderLen) {
            const trimK = encK.slice([0, 0, encoderLen - window, 0], encK.shape);
            const trimV = encV.slice([0, 0, encoderLen - window, 0], encV.shape);
            encK.dispose();
            encV.dispose();
            encK = trimK;
            encV = trimV;
            if (maskArr) {
              const ks = maskArr.shape;
              const keep = window + L;
              const trimmed = maskArr.slice(
                [0, 0, 0, ks[3]! - keep],
                ks,
              );
              maskArr = trimmed;
              maskArrOwned = true;
              maskMode = "array";
            }
          }
        }
        const kCat = ops.concatAxis([encK, k], 2);
        const vCat = ops.concatAxis([encV, v], 2);
        encK.dispose();
        encV.dispose();
        k.dispose();
        v.dispose();
        k = kCat;
        v = vCat;
      }
    } else if (cache) {
      const [fk, fv] = cache.updateAndFetch(k, v);
      k.dispose();
      v.dispose();
      k = fk;
      v = fv;
    }

    const attn = ops.sdpa(q, k, v, 1.0, maskMode, maskArr);
    q.dispose();
    k.dispose();
    v.dispose();
    if (maskArrOwned) maskArr!.dispose();

    let out = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    out = disposing(out, ops.reshape(out, [B, L, this.nHeads * this.headDim]));
    const o = this.oProj.forward(out);
    out.dispose();
    return o;
  }
}

/** One decoder layer: attention residual + a PARALLEL dense-MLP + MoE branch,
 *  combined through 7 RMSNorms and scaled by `layer_scalar` (the encoder pass
 *  overrides it with the per-layer encoder scalar). */
class DiffDecoderLayer {
  readonly layerType: string;
  readonly attn: DiffAttention;
  readonly mlp: DiffMLP;
  readonly router: DiffRouter;
  readonly experts: DiffExperts;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly preFfNorm: RMSNorm;
  readonly postFfNorm: RMSNorm;
  readonly postFfNorm1: RMSNorm;
  readonly postFfNorm2: RMSNorm;
  readonly preFfNorm2: RMSNorm;
  readonly layerScalar: MlxArray;

  constructor(weights: Weights, config: ModelConfig, idx: number) {
    const t = config.text;
    const prefix = `model.decoder.layers.${idx}`;
    this.layerType = t.layerTypes[idx]!;
    const norm = (n: string) => new RMSNorm(weights.tensor(`${prefix}.${n}.weight`), t.rmsNormEps);
    this.attn = new DiffAttention(weights, config, `${prefix}.self_attn`, this.layerType);
    this.mlp = new DiffMLP(weights, config, `${prefix}.mlp`);
    this.router = new DiffRouter(weights, config, `${prefix}.router`);
    this.experts = new DiffExperts(weights, config, `${prefix}.experts`);
    this.inputNorm = norm("input_layernorm");
    this.postAttnNorm = norm("post_attention_layernorm");
    this.preFfNorm = norm("pre_feedforward_layernorm");
    this.postFfNorm = norm("post_feedforward_layernorm");
    this.postFfNorm1 = norm("post_feedforward_layernorm_1");
    this.postFfNorm2 = norm("post_feedforward_layernorm_2");
    this.preFfNorm2 = norm("pre_feedforward_layernorm_2");
    this.layerScalar = weights.tensor(`${prefix}.layer_scalar`);
  }

  forward(
    x: MlxArray,
    mask: SdpaMask,
    cache: Cache | null,
    decoder: boolean,
    offset: number,
    layerScalar: MlxArray | null,
  ): MlxArray {
    // attention
    let residual = x;
    let h = this.inputNorm.forward(x);
    h = disposing(h, this.attn.forward(h, mask, cache, decoder, offset));
    h = disposing(h, this.postAttnNorm.forward(h));
    h = disposing(h, ops.add(residual, h));

    // parallel dense-MLP + MoE feedforward
    residual = h;
    const dense = this.preFfNorm.forward(h);
    let h1 = this.mlp.forward(dense);
    dense.dispose();
    h1 = disposing(h1, this.postFfNorm1.forward(h1));

    const shape = residual.shape;
    const hidden = shape[shape.length - 1]!;
    const flat = ops.reshape(residual, [-1, hidden]);
    const { indices: rawIdx, weights: topw } = this.router.forward(flat);
    // stop_gradient the routing indices so the MoE backward (gather_qmm vjp)
    // doesn't try to differentiate the non-differentiable top-k indices (the
    // reference does this in training mode). Identity in the forward, so D1/D2
    // stay bit-exact; required for D5 LoRA grads to flow through the experts.
    const indices = ops.stopGradient(rawIdx);
    rawIdx.dispose();
    let h2 = this.preFfNorm2.forward(flat);
    flat.dispose();
    h2 = disposing(h2, this.experts.forward(h2, indices, topw));
    indices.dispose();
    topw.dispose();
    h2 = disposing(h2, ops.reshape(h2, shape));
    h2 = disposing(h2, this.postFfNorm2.forward(h2));

    const sum = ops.add(h1, h2);
    h1.dispose();
    h2.dispose();
    h = this.postFfNorm.forward(sum);
    sum.dispose();
    h = disposing(h, ops.add(residual, h));
    residual.dispose();

    const scalar = layerScalar ?? this.layerScalar;
    h = disposing(h, ops.mul(h, scalar));
    return h;
  }
}

export class DiffusionGemmaModel {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  readonly embed: QuantizedEmbedding;
  readonly embedScale: number;
  readonly layers: DiffDecoderLayer[];
  readonly finalNorm: RMSNorm;
  readonly selfConditioning: SelfConditioning;
  readonly encoderLayerScalars: MlxArray[];
  readonly canvasLength: number;
  readonly softcap: number;
  readonly slidingWindow: number;
  // Shared RuntimeModel surface. LoRA mounts onto the (quantized) decoder
  // linears like the AR models; the diffusion engine activates it per request.
  readonly loraState = new LoraState();
  /** Dedicated DiffusionGemma SigLIP vision tower (image-text-to-text). */
  readonly visionTower: DiffusionVisionTower | null;
  readonly imageTokenId: number;

  constructor(weights: Weights, config: ModelConfig) {
    const t = config.text;
    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()].reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, "model.decoder.embed_tokens", config);
    this.embedScale = Math.pow(t.hiddenSize, 0.5);
    this.layers = Array.from(
      { length: t.numHiddenLayers },
      (_, i) => new DiffDecoderLayer(weights, config, i),
    );
    this.finalNorm = new RMSNorm(weights.tensor("model.decoder.norm.weight"), t.rmsNormEps);
    this.selfConditioning = new SelfConditioning(weights, config, "model.decoder.self_conditioning");
    this.encoderLayerScalars = this.layers.map((_, i) =>
      weights.tensor(`model.encoder.language_model.layers.${i}.layer_scalar`),
    );
    this.canvasLength = t.canvasLength ?? 256;
    this.softcap = t.finalLogitSoftcapping ?? 30.0;
    this.slidingWindow = t.slidingWindow;
    const raw = (config as unknown as { raw: Record<string, any> }).raw;
    this.imageTokenId = (raw.image_token_id as number) ?? 258880;
    this.visionTower = raw.vision_config ? new DiffusionVisionTower(weights, config) : null;
  }

  /** Build the merged prompt embeddings for an image+text turn: embed the text
   *  ids (image positions → pad) * embed_scale, then scatter the SigLIP vision
   *  features in at the contiguous <|image|> run. `pixels` is channel-first
   *  [1,3,H,W]. Reference EncoderModel._embed_inputs + get_image_features. */
  #embedInputsVision(splicedIds: number[], pixels: MlxArray): MlxArray {
    if (!this.visionTower) throw new Error("this checkpoint has no vision tower");
    const padId = 0; // pad_token_id (reference where(vision_mask, pad, ids))
    const llm = splicedIds.map((id) => (id === this.imageTokenId ? padId : id));
    const ids = MlxArray.fromInt32(Int32Array.from(llm), [1, llm.length]);
    let embeds = this.embed.encode(ids);
    ids.dispose();
    embeds = disposing(embeds, ops.mulScalar(embeds, this.embedScale)); // [1, L, hidden]

    const feats = this.visionTower.getImageFeatures(pixels); // [1, numSoft, hidden]
    const featsCast = feats.astype(embeds.dtype);
    feats.dispose();
    // image tokens are one contiguous run (boi + image*N + eoi)
    const start = splicedIds.indexOf(this.imageTokenId);
    const count = splicedIds.filter((id) => id === this.imageTokenId).length;
    const hidden = embeds.shape[embeds.shape.length - 1]!;
    embeds = disposing(
      embeds,
      ops.sliceUpdate(embeds, featsCast, [0, start, 0], [1, start + count, hidden]),
    );
    featsCast.dispose();
    return embeds;
  }

  /** Encoder attention mask for the vision prompt: causal, OR'd with the
   *  bidirectional image-block overlay (tokens in the same <|image|> block
   *  attend both ways). For N < sliding_window the sliding window is a no-op, so
   *  one mask serves all layers. Reference _make_encoder_masks + _vision_block_overlay. */
  #encoderVisionMask(splicedIds: number[]): MlxArray {
    const N = splicedIds.length;
    const isVision = splicedIds.map((id) => id === this.imageTokenId);
    const bits = new Int32Array(N * N);
    for (let i = 0; i < N; i++)
      for (let j = 0; j < N; j++)
        bits[i * N + j] = i >= j || (isVision[i] && isVision[j]) ? 1 : 0;
    return MlxArray.fromInt32(bits, [1, 1, N, N]).astype(Dtype.bool);
  }

  /** Image-text-to-text encoder prefill: merged embeddings + the causal/overlay
   *  mask through all layers (decoder=false), filling `cache`. The canvas decoder
   *  then reads it like the text path. */
  encodeVisionPrefill(splicedIds: number[], pixels: MlxArray, cache: Cache[]): void {
    let h = this.#embedInputsVision(splicedIds, pixels); // [1, L, hidden] (*embed_scale)
    const maskArr = this.#encoderVisionMask(splicedIds);
    const mask: SdpaMask = { mode: "array", arr: maskArr };
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const next = layer.forward(h, mask, cache[i]!, false, 0, this.encoderLayerScalars[i]!);
      h.dispose();
      h = next;
    }
    maskArr.dispose();
    h.dispose();
  }

  /** Prefill from a pre-spliced image+text prompt → populated cache. */
  prefillVision(splicedIds: number[], pixels: MlxArray): Cache[] {
    const cache = this.makeCache();
    this.encodeVisionPrefill(splicedIds, pixels, cache);
    return cache;
  }

  /** One KVCache (full) / RotatingKVCache (sliding) per layer — the encoder
   *  prefill fills these, the decoder canvas pass reads them. */
  makeCache(): Cache[] {
    return this.layers.map((l) =>
      l.layerType === "sliding_attention"
        ? new RotatingKVCache(this.slidingWindow)
        : new KVCache(),
    );
  }

  /** Encoder prefill: run all layers over the prompt (decoder=false), filling
   *  the cache. Text-only (no vision merge yet — D3). Discards the hidden. */
  encodePrompt(promptIds: number[], cache: Cache[]): void {
    const ids = MlxArray.fromInt32(Int32Array.from(promptIds), [1, promptIds.length]);
    let h = this.embed.encode(ids);
    ids.dispose();
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    const N = promptIds.length;
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const window = layer.layerType === "sliding_attention" ? this.slidingWindow : null;
      const m = cache[i]!.makeMask(N, window) as SdpaMask;
      const next = layer.forward(h, m, cache[i]!, false, 0, this.encoderLayerScalars[i]!);
      if (m.arr) m.arr.dispose();
      h.dispose();
      h = next;
    }
    h.dispose();
  }

  /** Diagnostic: run the encoder, invoking `onLayer(i, h)` after each layer
   *  (h is the raw layer output, pre-final-norm) and `onEmbed(h)` on the
   *  embedding. Returns the final pre-norm hidden. Fills `cache`. */
  encoderTrace(
    promptIds: number[],
    cache: Cache[],
    onEmbed: (h: MlxArray) => void,
    onLayer: (i: number, h: MlxArray) => void,
  ): MlxArray {
    const ids = MlxArray.fromInt32(Int32Array.from(promptIds), [1, promptIds.length]);
    let h = this.embed.encode(ids);
    ids.dispose();
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    onEmbed(h);
    const N = promptIds.length;
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const window = layer.layerType === "sliding_attention" ? this.slidingWindow : null;
      const m = cache[i]!.makeMask(N, window) as SdpaMask;
      const next = layer.forward(h, m, cache[i]!, false, 0, this.encoderLayerScalars[i]!);
      if (m.arr) m.arr.dispose();
      h.dispose();
      h = next;
      onLayer(i, h);
    }
    return h;
  }

  /** Diagnostic: run encoder layer 0 sub-components (attention vs parallel
   *  dense/MoE) and dump each via `cb(name, h)`. */
  diagLayer0(promptIds: number[], cache: Cache[], cb: (name: string, h: MlxArray) => void): void {
    const ids = MlxArray.fromInt32(Int32Array.from(promptIds), [1, promptIds.length]);
    let emb = this.embed.encode(ids);
    ids.dispose();
    emb = disposing(emb, ops.mulScalar(emb, this.embedScale));
    const layer = this.layers[0]!;
    const N = promptIds.length;
    const window = layer.layerType === "sliding_attention" ? this.slidingWindow : null;
    const m = cache[0]!.makeMask(N, window) as SdpaMask;
    const ls0 = this.encoderLayerScalars[0]!;

    const residual = emb;
    const hn = layer.inputNorm.forward(emb);
    const attnOut = layer.attn.forward(hn, m, cache[0]!, false, 0);
    hn.dispose();
    if (m.arr) m.arr.dispose();
    cb("attn_out", attnOut);
    const postAttn = layer.postAttnNorm.forward(attnOut);
    attnOut.dispose();
    const hMid = ops.add(residual, postAttn);
    postAttn.dispose();
    cb("h_mid", hMid);

    const dense = layer.preFfNorm.forward(hMid);
    let h1 = layer.mlp.forward(dense);
    dense.dispose();
    h1 = disposing(h1, layer.postFfNorm1.forward(h1));
    cb("h1", h1);
    h1.dispose();

    const shape = hMid.shape;
    const hidden = shape[shape.length - 1]!;
    const flat = ops.reshape(hMid, [-1, hidden]);
    const { indices, weights } = layer.router.forward(flat);
    cb("router_idx", indices.astype(Dtype.float32));
    cb("router_w", weights.astype(Dtype.float32));
    let h2 = layer.preFfNorm2.forward(flat);
    flat.dispose();
    h2 = disposing(h2, layer.experts.forward(h2, indices, weights));
    indices.dispose();
    weights.dispose();
    h2 = disposing(h2, ops.reshape(h2, shape));
    cb("experts_raw", h2);
    h2 = disposing(h2, layer.postFfNorm2.forward(h2));
    cb("h2", h2);
    h2.dispose();
    void ls0;
    emb.dispose();
    hMid.dispose();
  }

  /** Diagnostic: encoder prefill then finalNorm(h) — matches the reference
   *  EncoderModel.__call__ output (decoder.norm(h)) for per-stage localization. */
  encodePromptHidden(promptIds: number[], cache: Cache[]): MlxArray {
    const ids = MlxArray.fromInt32(Int32Array.from(promptIds), [1, promptIds.length]);
    let h = this.embed.encode(ids);
    ids.dispose();
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    const N = promptIds.length;
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const window = layer.layerType === "sliding_attention" ? this.slidingWindow : null;
      const m = cache[i]!.makeMask(N, window) as SdpaMask;
      const next = layer.forward(h, m, cache[i]!, false, 0, this.encoderLayerScalars[i]!);
      if (m.arr) m.arr.dispose();
      h.dispose();
      h = next;
    }
    return disposing(h, this.finalNorm.forward(h));
  }

  /** Embed the canvas + self-conditioning. For the first step both signals are
   *  None → zero signal (which still applies SelfConditioning's post RMSNorm). */
  #embedCanvas(
    canvasIds: MlxArray,
    scLogits: MlxArray | null,
    scEmbeddings: MlxArray | null,
  ): MlxArray {
    let inputsEmbeds = this.embed.encode(canvasIds);
    inputsEmbeds = disposing(inputsEmbeds, ops.mulScalar(inputsEmbeds, this.embedScale));
    let soft: MlxArray;
    let softOwned = true;
    if (scEmbeddings) {
      soft = scEmbeddings.astype(inputsEmbeds.dtype);
    } else if (scLogits === null) {
      soft = ops.zeros(inputsEmbeds.shape, inputsEmbeds.dtype);
    } else {
      // probs @ embed_tokens.weight (quantized, transpose=false), * embed_scale.
      const probs = ops.softmaxAxis(scLogits, -1, true);
      const probsCast = probs.astype(inputsEmbeds.dtype);
      probs.dispose();
      const se = ops.quantizedMatmul(
        probsCast,
        this.embed.w,
        this.embed.scales,
        this.embed.biases,
        this.embed.spec,
        false,
      );
      probsCast.dispose();
      soft = ops.mulScalar(se, this.embedScale);
      se.dispose();
    }
    const out = this.selfConditioning.forward(inputsEmbeds, soft);
    inputsEmbeds.dispose();
    if (softOwned) soft.dispose();
    return out;
  }

  /** Build the per-layer-type decoder masks (reference _make_decoder_masks).
   *  Returns a map layerType -> SdpaMask. For the dynamic caches used here
   *  encoder_len == valid_encoder_len always, so the only non-None mask is the
   *  sliding-window case once the prompt exceeds sliding_window-1 (1023). */
  #makeDecoderMasks(canvasLength: number, cache: Cache[]): Map<string, SdpaMask> {
    const masks = new Map<string, SdpaMask>();
    const types = new Set(this.layers.map((l) => l.layerType));
    for (const layerType of types) {
      const li = this.layers.findIndex((l) => l.layerType === layerType);
      const c = cache[li]!;
      const offset = c.offset;
      // encoder_len = chronological cache length; for dynamic caches this equals
      // min(offset, maxSize), and valid_encoder_len = min(offset, encoder_len)
      // == encoder_len, so the "trailing invalid" branches never fire here.
      const [encK, encV] = (c as TemporalCache).temporalView();
      const encoderLen = encK.shape[2]!;
      encK.dispose();
      encV.dispose();
      const validEncoderLen = Math.min(offset, encoderLen);
      const keyLen = encoderLen + canvasLength;

      if (layerType === "full_attention") {
        masks.set(layerType, NO_MASK); // encoder_len == valid_encoder_len
        continue;
      }
      const windowPrefix = Math.max(this.slidingWindow - 1, 0);
      if (encoderLen <= windowPrefix) {
        masks.set(layerType, NO_MASK);
        continue;
      }
      // Sliding + wrapped prompt: keep encoder positions [start, valid) + canvas.
      const start = Math.max(0, validEncoderLen - windowPrefix);
      const positions = ops.arange(0, encoderLen, 1, Dtype.int32);
      const startArr = ops.scalarLike(start, positions);
      const validArr = ops.scalarLike(validEncoderLen, positions);
      const geStart = ops.greaterEqual(positions, startArr);
      const ltValid = ops.less(positions, validArr);
      const encMask = ops.logicalAnd(geStart, ltValid);
      positions.dispose();
      startArr.dispose();
      validArr.dispose();
      geStart.dispose();
      ltValid.dispose();
      const canvasMask = ops.fromInt32(new Array(canvasLength).fill(1), [canvasLength]).astype(
        encMask.dtype,
      );
      const row = ops.concatAxis([encMask, canvasMask], 0);
      encMask.dispose();
      canvasMask.dispose();
      const reshaped = ops.reshape(row, [1, 1, 1, keyLen]);
      row.dispose();
      masks.set(layerType, { mode: "array", arr: reshaped });
    }
    return masks;
  }

  /** Decoder canvas pass over an on-device canvas: embed canvas -> 30 layers
   *  (decoder=true) -> final norm. Returns hidden [1, canvasLength, hidden].
   *  The D2 engine drives this per denoising step (canvas stays on-device). */
  decodeCanvasArr(
    canvasArr: MlxArray,
    cache: Cache[],
    scLogits: MlxArray | null = null,
    scEmbeddings: MlxArray | null = null,
  ): MlxArray {
    const canvasLength = canvasArr.shape[canvasArr.shape.length - 1]!;
    let h = this.#embedCanvas(canvasArr, scLogits, scEmbeddings);
    const masks = this.#makeDecoderMasks(canvasLength, cache);
    const offset = cache[0]!.offset;
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const m = masks.get(layer.layerType)!;
      const next = layer.forward(h, m, cache[i]!, true, offset, null);
      h.dispose();
      h = next;
    }
    for (const m of masks.values()) if (m.arr) m.arr.dispose();
    h = disposing(h, this.finalNorm.forward(h));
    return h;
  }

  /** Decoder canvas pass from host ids (D1 path). */
  decodeCanvas(
    canvasIds: number[],
    cache: Cache[],
    scLogits: MlxArray | null = null,
    scEmbeddings: MlxArray | null = null,
  ): MlxArray {
    const ids = MlxArray.fromInt32(Int32Array.from(canvasIds), [1, canvasIds.length]);
    const h = this.decodeCanvasArr(ids, cache, scLogits, scEmbeddings);
    ids.dispose();
    return h;
  }

  // ---- D2 denoising-engine surface ----

  /** Encoder prefill over the prompt -> a fresh populated cache (the denoising
   *  loop reuses it across all steps of a canvas block). */
  prefill(promptIds: number[]): Cache[] {
    const cache = this.makeCache();
    this.encodePrompt(promptIds, cache);
    return cache;
  }

  /** One denoising-step decoder pass -> softcapped logits [1, canvas, vocab]. */
  decoderLogits(canvasArr: MlxArray, cache: Cache[], scEmbeddings: MlxArray | null): MlxArray {
    const h = this.decodeCanvasArr(canvasArr, cache, null, scEmbeddings);
    const logits = this.logitsFromHidden(h);
    h.dispose();
    return logits;
  }

  /** Dequantized embedding table (once per call), for self-conditioning soft
   *  embeddings — matches optiq's `_diffusion_soft_embedding_weight`. */
  dequantEmbedWeight(): MlxArray {
    return ops.dequantize(this.embed.w, this.embed.scales, this.embed.biases, this.embed.spec);
  }

  /** Self-conditioning soft embeddings for the NEXT step (confidence sampler):
   *  softmax(processed, precise) @ dequant(embed) * embed_scale. */
  softEmbeddings(processedLogits: MlxArray, dequantWeight: MlxArray): MlxArray {
    const probs = ops.softmaxAxis(processedLogits, -1, true);
    const probsCast = probs.astype(dequantWeight.dtype);
    probs.dispose();
    const se = ops.matmul(probsCast, dequantWeight);
    probsCast.dispose();
    const cast = se.astype(dequantWeight.dtype);
    se.dispose();
    const out = ops.mulScalar(cast, this.embedScale);
    cast.dispose();
    return out;
  }

  /** Re-prefill the encoder over an accepted canvas block (continuation), so the
   *  next block's decoder sees it as context. Appends to the existing cache. */
  extendPrefill(canvasArr: MlxArray, cache: Cache[]): void {
    let h = this.embed.encode(canvasArr);
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    const N = canvasArr.shape[canvasArr.shape.length - 1]!;
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const window = layer.layerType === "sliding_attention" ? this.slidingWindow : null;
      const m = cache[i]!.makeMask(N, window) as SdpaMask;
      const next = layer.forward(h, m, cache[i]!, false, 0, this.encoderLayerScalars[i]!);
      if (m.arr) m.arr.dispose();
      h.dispose();
      h = next;
    }
    h.dispose();
  }

  /** Tied quantized head + fp32 softcap. hidden [1, L, hidden] -> [1, L, vocab]. */
  logitsFromHidden(h: MlxArray): MlxArray {
    const logits = this.embed.asLinear(h);
    const capped = softcapFp32(logits, this.softcap);
    logits.dispose();
    return capped;
  }

  /** D1 entry point: prompt + canvas ids -> softcapped logits [1, canvas, vocab].
   *  Builds a fresh cache, prefills the encoder, runs one decoder pass. */
  forwardCanvasLogits(promptIds: number[], canvasIds: number[]): MlxArray {
    const cache = this.makeCache();
    try {
      this.encodePrompt(promptIds, cache);
      const h = this.decodeCanvas(canvasIds, cache);
      const logits = this.logitsFromHidden(h);
      h.dispose();
      return logits;
    } finally {
      for (const c of cache) c.dispose();
    }
  }

  /** Training forward over an on-device canvas (D5 LoRA): prompt + canvas array
   *  -> softcapped logits [1, L, vocab], differentiable w.r.t. mounted LoRA. */
  forwardCanvasLogitsArr(promptIds: number[], canvasArr: MlxArray): MlxArray {
    const cache = this.makeCache();
    try {
      this.encodePrompt(promptIds, cache);
      const h = this.decodeCanvasArr(canvasArr, cache);
      const logits = this.logitsFromHidden(h);
      h.dispose();
      return logits;
    } finally {
      for (const c of cache) c.dispose();
    }
  }

  // ---- AR-only RuntimeModel surface (never called on a diffusion model) ----
  // DiffusionGemma is non-autoregressive: generate() detects it and routes to
  // the denoising engine (src/diffusion/diffusion-generate.ts). These exist so
  // the model fits the shared RuntimeModel union; calling them is a bug.
  forwardHidden(_ids: MlxArray, _cache: Cache[]): MlxArray {
    throw new Error("DiffusionGemma is non-autoregressive — use the diffusion engine, not forwardHidden");
  }
  forward(_tokens: number[] | MlxArray, _cache: Cache[]): MlxArray {
    throw new Error("DiffusionGemma is non-autoregressive — use the diffusion engine, not forward");
  }
  generate(_promptTokens: number[], _maxTokens: number, _eosIds?: number[]): number[] {
    throw new Error("DiffusionGemma is non-autoregressive — use diffusionGenerate, not generate");
  }
  forwardEmbeddings(_embeds: MlxArray, _cache: Cache[], _bidir: MlxArray | null): MlxArray {
    throw new Error("DiffusionGemma vision runs through its own encoder merge, not forwardEmbeddings");
  }

  readonly prefixBase = "model.decoder";

  /** LoRA-able decoder linears (the optiq diffusion DEFAULT_LORA_KEYS: attention
   *  q/k/v/o + dense MLP gate/up/down per layer; full layers have no v_proj). */
  loraTargets(): Map<string, QuantizedLinear> {
    const m = new Map<string, QuantizedLinear>();
    this.layers.forEach((layer, i) => {
      const p = `model.decoder.layers.${i}`;
      m.set(`${p}.self_attn.q_proj`, layer.attn.qProj);
      m.set(`${p}.self_attn.k_proj`, layer.attn.kProj);
      if (layer.attn.vProj) m.set(`${p}.self_attn.v_proj`, layer.attn.vProj);
      m.set(`${p}.self_attn.o_proj`, layer.attn.oProj);
      m.set(`${p}.mlp.gate_proj`, layer.mlp.gate);
      m.set(`${p}.mlp.up_proj`, layer.mlp.up);
      m.set(`${p}.mlp.down_proj`, layer.mlp.down);
    });
    return m;
  }
}
