import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.DiffusionGemma.Model
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/diffusion-gemma/model.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { MlxCacheLayer, MlxDenoisingPrefillRange, MlxDenoisingDecodeRange, MlxDenoisingAppendRange } from "../../contracts/mlx/graph";
import { cleanupFailure, disposeResources } from "../../runtime/resources";
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
// RMSNorm, the composed cache legos) from packages/inference/src/layers/ and
// packages/inference/src/state/. Architecture deltas vs
// gemma4 (verified against the checkpoint, see `02d723a:docs/design/generic-model-support.md` §6.5):
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

import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { disposing } from "../../layers/helpers";
import { LoraState } from "../../layers/lora";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import type { MlxDeclaredGraph, MlxDenoisingOperations } from "../../contracts/mlx/graph";
import type { TrainableGraph } from "../../contracts/mlx/trainable";
import { declareGraph } from "../capabilities";
import type { PixelInput } from "../../contracts/mlx/media";
import { geglu, GegluMLP, CompiledGeglu, CompiledGegluMLP } from "../../layers/geglu";
import { SortedDiffExperts, UnsortedDiffExperts } from "./experts";
import { compiledLogitSoftcap } from "../../kernels/softcap";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { QuantizedSwitchLinear } from "../../layers/quantized-switch-linear";
import { RMSNorm } from "../../layers/normalization";
import { AttentionMasks } from "../../state/attention-read";
import { composedFullAttentionCache, composedSlidingAttentionCache } from "../../state/bf16-first-kv";
import { maybePageKv } from "../../state/request-policy";
import { deferredTurboQuantKernels } from "../../state/turboquant-attention";
import type { AttentionRead, BlockAttentionCache, Cache, EncoderAttentionCache } from "../../contracts/mlx/cache";
import { DiffusionVisionTower, spliceImageTokens } from "./vision";

/** The caches `makeCache` composes: each serves the window read (encoder
 *  prefill over prompt tokens or an accepted canvas block), the block read (the
 *  decoder canvas pass) and the encoder window read (the vision prompt). */
type DiffusionCache = BlockAttentionCache & EncoderAttentionCache;

/** The read one pass makes on a layer's cache with that layer's keys and
 *  values. The pass names it; no layer inspects its input or its cache. */
type PassRead = (cache: Cache, k: MlxArray, v: MlxArray) => AttentionRead;

/** Encoder prefill over tokens: append, causal, limited to the layer's sliding window. */
const windowRead: PassRead = (cache, k, v) => (cache as DiffusionCache).appendWindow(k, v);
/** Decoder canvas pass: the canvas attends the stored encoder positions (the
 *  newest sliding_window - 1 on sliding layers) and itself, storing nothing. */
const blockRead: PassRead = (cache, k, v) => (cache as DiffusionCache).readBlock(k, v);
/** Vision encoder prefill: append, causal over the whole prompt with no sliding
 *  window, image positions (`media`, bool [L]) attending each other both ways. */
const encoderRead = (media: MlxArray): PassRead =>
  (cache, k, v) => (cache as DiffusionCache).appendEncoderWindow(k, v, media);

/** Router: pre-projection RMSNorm (no-scale) * scale * hidden**-0.5, top-8
 *  argpartition, softmax(precise) * per_expert_scale[idx]. Local, not gemma4's Router:
 *  the reference applies scale and hidden**-0.5 as separate bf16 ops after a no-scale
 *  norm (gemma4's folds them into the norm weight, which rounds differently), softmaxes
 *  in precise mode, and this one stops gradient on the indices. */
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
    const sliced = part.slice([0, this.numExperts - this.topK], [T, this.numExperts]);
    part.dispose();
    // The top-k indices derive from `scores`, so under value_and_grad they sit
    // on the tape and MLX's gather VJP refuses a cotangent for indices
    // ("Cannot calculate VJP with respect to indices"). Integer indices carry
    // no gradient; stopping them here keeps the forward bit-identical and lets
    // the value gather still backpropagate into `scores`. (Main's copy of this
    // router lacks the stop and fails the same way under MLX 0.32.2.)
    const indices = ops.stopGradient(sliced);
    sliced.dispose();
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
 *  moe_intermediate_size) + a down SwitchLinear (gemma4's SwitchGLU holds separate
 *  gate and up projections; the geglu between them is the shared one). _gather_sort / _scatter_unsort
 *  exactly as mlx_lm.models.switch_layers (sort threshold idx.size >= 64). */
class DiffExperts {
  readonly gateUp: QuantizedSwitchLinear;
  readonly down: QuantizedSwitchLinear;
  readonly hiddenDims: number; // moe_intermediate_size (split point)
  constructor(weights: Weights, config: ModelConfig, prefix: string, readonly compiledGeglu: boolean) {
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
    const mid = geglu(gate, up, this.compiledGeglu);
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
  readonly activation = new CompiledGeglu();
  readonly preNorm: RMSNorm;
  readonly postNorm: RMSNorm; // RMSNormNoScale (null weight)
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;
  constructor(weights: Weights, config: ModelConfig, prefix: string, readonly compiledGeglu: boolean) {
    const eps = config.text.rmsNormEps;
    this.preNorm = new RMSNorm(weights.tensor(`${prefix}.pre_norm.weight`), eps);
    this.postNorm = new RMSNorm(null, eps);
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }
  forward(inputsEmbeds: MlxArray, signal: MlxArray): MlxArray {
    const normed = this.preNorm.forward(signal);
    const m = this.activation.forward(this.gate.forward(normed), this.up.forward(normed));
    normed.dispose();
    const s = this.down.forward(m);
    m.dispose();
    const sum = ops.add(inputsEmbeds, s);
    s.dispose();
    const out = this.postNorm.forward(sum);
    sum.dispose();
    return out;
  }
}

/** Attention through the read its pass names: the encoder passes append to the
 *  cache, the decoder canvas pass reads the stored encoder K/V with the canvas
 *  K/V without storing them. The cache builds the mask. scale=1.0, no softcap. */
class DiffAttention {
  readonly isSliding: boolean;
  readonly headDim: number;
  readonly nHeads: number;
  readonly nKvHeads: number;
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
    // packages/inference/src/models/gemma4/model.ts initialize_rope.
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

  /** `offset` is the RoPE position of `x`'s first token, which the pass chooses
   *  (the reference encoder ropes every pass from 0). */
  forward(x: MlxArray, cache: Cache, read: PassRead, offset: number): MlxArray {
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

    let attended: AttentionRead;
    try { attended = read(cache, k, v); } finally { k.dispose(); v.dispose(); }
    let attn: MlxArray;
    try { attn = attended.attend(q, 1.0); } finally { attended.dispose(); q.dispose(); }

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
  readonly mlp: GegluMLP;
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

  constructor(weights: Weights, config: ModelConfig, idx: number, compiledGeglu: boolean) {
    const t = config.text;
    const prefix = `model.decoder.layers.${idx}`;
    this.layerType = t.layerTypes[idx]!;
    const norm = (n: string) => new RMSNorm(weights.tensor(`${prefix}.${n}.weight`), t.rmsNormEps);
    this.attn = new DiffAttention(weights, config, `${prefix}.self_attn`, this.layerType);
    this.mlp = new GegluMLP(weights, config, `${prefix}.mlp`, compiledGeglu);
    this.router = new DiffRouter(weights, config, `${prefix}.router`);
    this.experts = new DiffExperts(weights, config, `${prefix}.experts`, compiledGeglu);
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
    cache: Cache,
    read: PassRead,
    offset: number,
    layerScalar: MlxArray | null,
  ): MlxArray { return this.forwardWith(x,cache,read,offset,layerScalar,this.mlp,this.experts); }

  forwardWith(x: MlxArray, cache: Cache, read: PassRead, offset: number, layerScalar: MlxArray | null,
    mlp: {forward(x:MlxArray):MlxArray}, experts: {forward(x:MlxArray,indices:MlxArray,weights:MlxArray):MlxArray}): MlxArray {
    // attention
    let residual = x;
    let h = this.inputNorm.forward(x);
    h = disposing(h, this.attn.forward(h, cache, read, offset));
    h = disposing(h, this.postAttnNorm.forward(h));
    h = disposing(h, ops.add(residual, h));

    // parallel dense-MLP + MoE feedforward
    residual = h;
    const dense = this.preFfNorm.forward(h);
    let h1 = mlp.forward(dense);
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
    h2 = disposing(h2, experts.forward(h2, indices, topw));
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

export class DiffusionGemmaModel implements MlxDeclaredGraph, MlxDenoisingOperations {
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
  /** Denoising rows interleave through their own grouped method; images enter as
   * the method's pixel prefill input. */
  get graphCapabilities(): GraphDeclaration {
    return declareGraph({ method: "denoising", media: { input: "pixels", video: false } });
  }
  /** The denoising objective: LoRA on the decoder blocks (the encoder reuses them, weight-tied). */
  get trainable(): TrainableGraph {
    return {
      denoising: {
        vocabSize: this.config.text.vocabSize,
        layerModulePaths: this.layers.map((_, i) => `model.decoder.layers.${i}`),
        canvasLogits: (promptIds, canvas) => (this as unknown as DiffusionGemmaModel & { makeCache(): Cache[] }).forwardCanvasLogitsArr(promptIds, canvas),
      },
    };
  }
  pixelInput(): PixelInput | null {
    const tower = this.visionTower;
    return tower ? { preprocess: bytes => tower.preprocess(bytes), spliceTokens: (ids, softTokens, tokenIds) => spliceImageTokens(ids, [softTokens], tokenIds) } : null;
  }
  /** Dedicated DiffusionGemma SigLIP vision tower (image-text-to-text). */
  readonly visionTower: DiffusionVisionTower | null;
  readonly imageTokenId: number;

  /** The graph binds compiled GeGLU and softcap closures, matching the
   * reference's mx.compile'd operations. */
  readonly makeCache!: () => Cache[];
  readonly denoisingDecode: readonly MlxDenoisingDecodeRange[];
  readonly denoisingAppend: readonly MlxDenoisingAppendRange[];
  readonly denoisingPrefill: readonly MlxDenoisingPrefillRange[];
  readonly #canvasLayers: readonly {forward: DiffDecoderLayer["forward"]}[];
  readonly #unsortedLayers: readonly {forward: DiffDecoderLayer["forward"]}[];
  readonly #sortedLayers: readonly {forward: DiffDecoderLayer["forward"]}[];
  /** The composition this graph was built for: its KV scheme and paging are its caches' (`makeCache`). */

  constructor(weights: Weights, config: ModelConfig) {
    const t = config.text;
    this.config = config;

    this.weightsBytes = [...weights.shards.files.values()].reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, "model.decoder.embed_tokens", config);
    this.embedScale = Math.pow(t.hiddenSize, 0.5);
    this.layers = Array.from(
      { length: t.numHiddenLayers },
      (_, i) => new DiffDecoderLayer(weights, config, i, true),
    );
    this.finalNorm = new RMSNorm(weights.tensor("model.decoder.norm.weight"), t.rmsNormEps);
    this.selfConditioning = new SelfConditioning(weights, config, "model.decoder.self_conditioning", true);
    this.encoderLayerScalars = this.layers.map((_, i) =>
      weights.tensor(`model.encoder.language_model.layers.${i}.layer_scalar`),
    );
    this.canvasLength = t.canvasLength ?? 256;
    this.#unsortedLayers = this.layers.map(layer=>{
      const mlp = new CompiledGegluMLP(layer.mlp), experts = new UnsortedDiffExperts(layer.experts);
      return {forward:(x:MlxArray,cache:Cache,read:PassRead,offset:number,scalar:MlxArray|null)=>layer.forwardWith(x,cache,read,offset,scalar,mlp,experts)};
    });
    this.#sortedLayers = this.layers.map(layer=>{
      const mlp = new CompiledGegluMLP(layer.mlp), experts = new SortedDiffExperts(layer.experts);
      return {forward:(x:MlxArray,cache:Cache,read:PassRead,offset:number,scalar:MlxArray|null)=>layer.forwardWith(x,cache,read,offset,scalar,mlp,experts)};
    });
    this.#canvasLayers = this.canvasLength * t.topKExperts < 64 ? this.#unsortedLayers : this.#sortedLayers;
    const boundary = Math.ceil(64/t.topKExperts);
    const ranges = [{from:1,to:boundary-1,layers:this.#unsortedLayers},{from:boundary,to:Infinity,layers:this.#sortedLayers}].filter(range=>range.from<=range.to);
    this.denoisingDecode = ranges.map(range=>({from:range.from,to:range.to,operation:(canvas,cache,feedback)=>this.decoderLogits(canvas,cache,feedback,range.layers)}));
    this.denoisingAppend = ranges.map(range=>({from:range.from,to:range.to,operation:(tokens,cache)=>this.extendPrefill(tokens,cache,range.layers)}));
    this.denoisingPrefill = ranges.map(range=>({from:range.from,to:range.to,operation:(ids,pixels)=>{
        const cache = this.makeCache();
        try {
          if (pixels) this.encodeVisionPrefill(ids,pixels,cache,range.layers);
          else this.#encodePrompt(ids,cache,range.layers);
          return cache;
        } catch(error) { cleanupFailure(error,()=>disposeResources(cache)); }
      }}));
    this.softcap = t.finalLogitSoftcapping ?? 30.0;
    this.slidingWindow = t.slidingWindow;
    const raw = (config as unknown as { raw: Record<string, any> }).raw;
    this.imageTokenId = (raw.image_token_id as number) ?? 258880;
    this.visionTower = raw.vision_config ? new DiffusionVisionTower(weights, config) : null;


    this.cacheLayers = this.layers.map(layer=>layer.layerType === "sliding_attention" ? {kind:"sliding" as const,window:this.slidingWindow}:{kind:"full" as const,turboQuant:"deferred" as const});
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

  /** The vision prompt's image positions, bool [N]: every <|image|> token. The
   *  encoder window read lets them attend each other both ways (reference
   *  _vision_block_overlay). */
  #imagePositions(splicedIds: number[]): MlxArray {
    const flags = splicedIds.map((id) => (id === this.imageTokenId ? 1 : 0));
    using ints = MlxArray.fromInt32(Int32Array.from(flags), [flags.length]);
    return ints.astype(Dtype.bool);
  }

  /** Image-text-to-text encoder prefill: merged embeddings through all layers,
   *  each reading through the encoder window (causal over the whole prompt, no
   *  sliding window, image positions both ways; reference _make_encoder_masks +
   *  _vision_block_overlay, one mask for every layer), filling `cache`. The
   *  canvas decoder then reads it like the text path. */
  encodeVisionPrefill(splicedIds: number[], pixels: MlxArray, cache: Cache[], layers: readonly {forward:DiffDecoderLayer["forward"]}[] = this.layers): void {
    let h = this.#embedInputsVision(splicedIds, pixels); // [1, L, hidden] (*embed_scale)
    using media = this.#imagePositions(splicedIds);
    const read = encoderRead(media);
    for (let i = 0; i < this.layers.length; i++) {
      const layer = layers[i]!;
      const next = layer.forward(h, cache[i]!, read, 0, this.encoderLayerScalars[i]!);
      h.dispose();
      h = next;
    }
    h.dispose();
  }

  /** Releases the rope frequency tables its layers built; the weights are its owner's. */
  dispose(): void {
    disposeResources(this.layers.flatMap(layer => layer.attn.ropeFreqs ? [layer.attn.ropeFreqs] : []));
  }

  /** One cache per layer, the lego the composition's KV scheme names for it
   *  (bf16, bf16-first affine, per listed layer under a per-layer scheme, or
   *  TurboQuant on full-attention layers, read deferred as Gemma 4 reads it), a
   *  ring of the sliding window on sliding layers, all sharing one mask memo;
   *  under the composition's paging the full-attention layers hold pages of
   *  what the scheme names (`maybePageKv`, growing from one block). The encoder
   *  prefill fills them, the decoder canvas pass reads them. */
  readonly cachePaging = true;
  readonly cacheLayers: readonly MlxCacheLayer[];


  /** Encoder prefill: run all layers over the prompt through the window read,
   *  filling the cache. Discards the hidden. */
  encodePrompt(promptIds: number[], cache: Cache[]): void { this.#encodePrompt(promptIds,cache,this.layers); }

  #encodePrompt(promptIds: number[], cache: Cache[], layers: readonly {forward:DiffDecoderLayer["forward"]}[]): void {
    const ids = MlxArray.fromInt32(Int32Array.from(promptIds), [1, promptIds.length]);
    let h = this.embed.encode(ids);
    ids.dispose();
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    for (let i = 0; i < this.layers.length; i++) {
      const next = layers[i]!.forward(h, cache[i]!, windowRead, 0, this.encoderLayerScalars[i]!);
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
    for (let i = 0; i < this.layers.length; i++) {
      const next = this.layers[i]!.forward(h, cache[i]!, windowRead, 0, this.encoderLayerScalars[i]!);
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
    const ls0 = this.encoderLayerScalars[0]!;

    const residual = emb;
    const hn = layer.inputNorm.forward(emb);
    const attnOut = layer.attn.forward(hn, cache[0]!, windowRead, 0);
    hn.dispose();
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
    for (let i = 0; i < this.layers.length; i++) {
      const next = this.layers[i]!.forward(h, cache[i]!, windowRead, 0, this.encoderLayerScalars[i]!);
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

  /** Decoder canvas pass over an on-device canvas: embed canvas -> 30 layers,
   *  each reading its cache through the block read (the cache builds the
   *  reference _make_decoder_masks sliding mask and keeps the newest
   *  sliding_window - 1 encoder positions) -> final norm. Returns hidden
   *  [1, canvasLength, hidden]. The D2 engine drives this per denoising step
   *  (canvas stays on-device). */
  decodeCanvasArr(
    canvasArr: MlxArray,
    cache: Cache[],
    scLogits: MlxArray | null = null,
    scEmbeddings: MlxArray | null = null,
    layers: readonly {forward:DiffDecoderLayer["forward"]}[] = this.layers,
  ): MlxArray {
    let h = this.#embedCanvas(canvasArr, scLogits, scEmbeddings);
    const offset = cache[0]!.offset;
    for (let i = 0; i < this.layers.length; i++) {
      const next = layers[i]!.forward(h, cache[i]!, blockRead, offset, null);
      h.dispose();
      h = next;
    }
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

  /** One denoising-step decoder pass -> softcapped logits [1, canvas, vocab]. */
  decoderLogits(canvasArr: MlxArray, cache: Cache[], scEmbeddings: MlxArray | null, layers = this.#canvasLayers): MlxArray {
    const h = this.decodeCanvasArr(canvasArr, cache, null, scEmbeddings,layers);
    try { return this.logitsFromHidden(h); }
    finally { h.dispose(); }
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
  extendPrefill(canvasArr: MlxArray, cache: Cache[], layers: readonly {forward:DiffDecoderLayer["forward"]}[] = this.layers): void {
    let h = this.embed.encode(canvasArr);
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    for (let i = 0; i < this.layers.length; i++) {
      const next = layers[i]!.forward(h, cache[i]!, windowRead, 0, this.encoderLayerScalars[i]!);
      h.dispose();
      h = next;
    }
    h.dispose();
  }

  /** Tied quantized head + fp32 softcap. hidden [1, L, hidden] -> [1, L, vocab]. */
  logitsFromHidden(h: MlxArray): MlxArray {
    const logits = this.embed.asLinear(h);
    // fp32-upcast tanh softcap, fused like the reference's mx.compile'd make_compiled_softcap
    // (stays f32; the golden is dumped f32). The flag-off arm spells out the same math.
    const wide = logits.astype(Dtype.float32);
    logits.dispose();
    const capped = compiledLogitSoftcap(wide, this.softcap);
    wide.dispose();
    return capped;
  }

  /** D1 entry point: prompt + canvas ids -> softcapped logits [1, canvas, vocab].
   *  Builds a fresh cache, prefills the encoder, runs one decoder pass. */
  forwardCanvasLogits(this: DiffusionGemmaModel & { makeCache(): Cache[] }, promptIds: number[], canvasIds: number[]): MlxArray {
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
  forwardCanvasLogitsArr(this: DiffusionGemmaModel & { makeCache(): Cache[] }, promptIds: number[], canvasArr: MlxArray): MlxArray {
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
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.DiffusionGemma.Model
