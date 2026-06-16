// Gemma 4 text model — line-for-line port of mlx-lm's gemma4_text.py
// (oracle venv site-packages), covering the paths our target models
// exercise: 12B (dense), e4b (per-layer-input embeddings + KV-shared
// layers), 26B-A4B (MoE block: router + gather_qmm experts).
//
// Parity notes (see PLAN.md Phase 2 findings):
// - SDPA scale is 1.0 (Gemma4 normalizes q/k instead).
// - Full-attention layers: global_head_dim 512, 1 global KV head,
//   attention_k_eq_v (V = same projection as K, with un-scaled RMS norm);
//   ProportionalRoPE rotates only partial_rotary_factor·dims dims.
// - Python-float scalars promote weakly to the array dtype.
// - Replicate mlx python helper implementations exactly (x**3 is
//   mx.power, not x·x·x — they round differently in bf16).
//
// Masks: ports base.py create_attention_mask/create_causal_mask. Sliding
// layers use a plain (non-rotating) cache + window masks — numerically
// identical to mlx-lm's RotatingKVCache, at the cost of unbounded cache
// growth past the window (memory optimization deferred).

import type { ModelConfig } from "../config";
import { quantFor } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { isExpertTracing, recordRouting } from "../expert-trace";

// The shared, config-independent machinery lives in gemma4-base.ts
// (Phase B extraction); this file keeps the architecture-specific
// assembly that Phase C generates per model. Re-export the base so
// existing importers keep one entry point.
export * from "./gemma4-base";
import {
  argmaxLastPosition,
  bidirMask,
  disposing,
  isCompiledTrace,
  KVCache,
  logitSoftcap,
  LoraState,
  QuantizedEmbedding,
  QuantizedKVCache,
  QuantizedLinear,
  QuantizedSwitchLinear,
  RMSNorm,
  RotatingKVCache,
  RotatingQuantizedKVCache,
  quantizedSdpa,
  type Cache,
  type Mask,
  type SharedKv,
  type LoraWeights,
} from "./gemma4-base";
import { fusedGeglu, fusedGeluEnabled, fusedGeluSupported } from "./fused-geglu-kernel";
import { Checkpoint } from "../mlx/checkpoint";
import { flashAttention, getTrainingAttn, flashSupported } from "./flash-attention";

/** Optional gradient-checkpointing context for the training forward. When set,
 *  forwardLayers wraps each layer in a Checkpoint so its interior activations
 *  are recomputed in the backward pass. `byLayer` maps a layer index to that
 *  layer's trainable LoRA weights (re-swapped inside the closure so they are
 *  explicit checkpoint inputs — required because the autograd primals are
 *  disposed before the recompute). `keepAlive` collects the per-layer
 *  Checkpoint objects; the trainer disposes them after value_and_grad. */
export interface GradCheckpointCtx {
  byLayer: Map<number, LoraWeights[]>;
  keepAlive: Checkpoint[];
}

class Attention {
  readonly isSliding: boolean;
  readonly windowSize: number;
  readonly useKEqV: boolean;
  readonly hasKv: boolean;
  readonly headDim: number;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly ropeBase: number | null;
  readonly ropeFreqs: MlxArray | null;
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear | null;
  readonly vProj: QuantizedLinear | null;
  readonly oProj: QuantizedLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm | null;
  readonly vNorm: RMSNorm | null;

  constructor(
    weights: Weights, config: ModelConfig, prefix: string, layerType: string,
    hasKv = true,
  ) {
    const t = config.text;
    this.hasKv = hasKv;
    this.isSliding = layerType === "sliding_attention";
    this.windowSize = t.slidingWindow;
    this.headDim = this.isSliding ? t.headDim : t.globalHeadDim;
    this.nHeads = t.numAttentionHeads;
    this.useKEqV = t.attentionKEqV && !this.isSliding;
    this.nKvHeads = this.useKEqV ? t.numGlobalKeyValueHeads : t.numKeyValueHeads;

    const rp = t.ropeParameters[this.isSliding ? "sliding_attention" : "full_attention"]!;
    if (rp.ropeType === "default") {
      this.ropeBase = rp.ropeTheta;
      this.ropeFreqs = null;
    } else if (rp.ropeType === "proportional") {
      // Port of rope_utils.ProportionalRoPE.__init__. The rotated freqs
      // MUST be computed on-device in f32 (arange/dims, then base**x)
      // exactly like the reference — computing them host-side in f64 and
      // rounding to f32 lands 17/64 of them 1 ulp off (f64 pow ≠ f32
      // powf), a latent knife-edge that Phase 10's tiled values exposed
      // as a 1-ulp q-rope divergence at layer 11 (Phase 2 porting rule:
      // replicate the helper's IMPLEMENTATION, not its formula).
      const rotated = Math.floor(this.headDim * rp.partialRotaryFactor);
      const n = this.headDim / 2;
      const exponentsRaw = ops.arange(0, rotated, 2, Dtype.float32);
      const dims = ops.scalarLike(this.headDim, exponentsRaw);
      const exponents = ops.div(exponentsRaw, dims);
      const base = ops.scalarLike(rp.ropeTheta, exponents);
      let rotFreqs = ops.pow(base, exponents);
      if (rp.factor !== 1.0) {
        const f = ops.scalarLike(rp.factor, rotFreqs);
        rotFreqs = disposing(rotFreqs, ops.mul(f, rotFreqs));
        f.dispose();
      }
      this.ropeBase = null;
      const tailLen = n - rotated / 2;
      if (tailLen > 0) {
        const tail = MlxArray.fromFloat32(
          new Float32Array(tailLen).fill(Infinity), [tailLen],
        );
        this.ropeFreqs = ops.concatAxis([rotFreqs, tail], 0);
        tail.dispose();
      } else {
        this.ropeFreqs = rotFreqs;
      }
      for (const a of [exponentsRaw, dims, exponents, base])
        a.dispose();
      if (this.ropeFreqs !== rotFreqs) rotFreqs.dispose();
    } else {
      throw new Error(`unsupported rope_type ${rp.ropeType}`);
    }

    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = hasKv ? QuantizedLinear.load(weights, `${prefix}.k_proj`, config) : null;
    this.vProj = hasKv && !this.useKEqV
      ? QuantizedLinear.load(weights, `${prefix}.v_proj`, config) : null;
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = hasKv
      ? new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps) : null;
    this.vNorm = hasKv ? new RMSNorm(null, t.rmsNormEps) : null;
  }

  /** A number offset takes the static fast::rope; an array offset (set by
   *  compiled-decode trace adapters) takes the dynamic variant — same
   *  kernel, offset read from the array (bit-exactness asserted in
   *  tests/compile.test.ts). */
  rope(x: MlxArray, offset: number | MlxArray): MlxArray {
    return typeof offset === "number"
      ? ops.rope(x, this.headDim, this.ropeBase, offset, this.ropeFreqs)
      : ops.ropeDynamic(x, this.headDim, this.ropeBase, offset, this.ropeFreqs);
  }

  /** Returns the attention output plus the fetched KV (for KV-shared
   *  sharer layers and the speculative drafter). The SharedKv arrays are
   *  owned by the caller (forwardLayers) and disposed after the pass. */
  forward(
    x: MlxArray, mask: Mask, cache: Cache | null, sharedIn: SharedKv | null,
  ): { out: MlxArray; shared: SharedKv } {
    const [B, L] = x.shape as [number, number, number];

    let q = this.qProj.forward(x);
    q = disposing(q, ops.reshape(q, [B, L, this.nHeads, this.headDim]));
    q = disposing(q, this.qNorm.forward(q));

    let shared: SharedKv;
    if (!this.hasKv) {
      if (!sharedIn) throw new Error("KV-shared layer received no shared KV");
      shared = sharedIn;
    } else {
      if (!cache) throw new Error("donor layer requires a cache");
      let k = this.kProj!.forward(x);
      k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
      let v: MlxArray;
      if (this.vProj) {
        v = this.vProj.forward(x);
        v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
      } else {
        v = k; // attention_k_eq_v: shared projection; norms differ below
      }

      const offset = cache.offset;
      // Capture the RoPE offset array ONCE (like `offset` above): the
      // updateAndFetch below advances cache.offset, so re-reading
      // cache.ropeOffsetArr for Q *after* the write would hand K and Q
      // different positions. Harmless today (real caches leave it unset;
      // compiled-decode passes a constant trace input), but a hard
      // prerequisite for batched decode, where ropeOffsetArr carries per-row
      // positions derived from the pre-write offset and MUST be identical for
      // this step's K and Q.
      const offsetArr = cache.ropeOffsetArr;

      const kNormed = this.kNorm!.forward(k);
      const kT = ops.transposeAxes(kNormed, [0, 2, 1, 3]);
      kNormed.dispose();
      const kRoped = this.rope(kT, offsetArr ?? offset);
      kT.dispose();

      const vNormed = this.vNorm!.forward(v);
      const vT = ops.transposeAxes(vNormed, [0, 2, 1, 3]);
      vNormed.dispose();
      if (v !== k) v.dispose();
      k.dispose();

      if (cache instanceof QuantizedKVCache || cache instanceof RotatingQuantizedKVCache) {
        const [kq, vq] = cache.updateAndFetchQuantized(kRoped, vT);
        kRoped.dispose();
        vT.dispose();
        shared = {
          kind: "quant", keys: kq, values: vq, offset,
          groupSize: cache.groupSize, bits: cache.bits,
          offsetArr,
        };
      } else {
        const [keys, values] = cache.updateAndFetch(kRoped, vT);
        kRoped.dispose();
        vT.dispose();
        shared = { kind: "plain", keys, values, offset, offsetArr };
      }
    }

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    q = disposing(q, this.rope(q, shared.offsetArr ?? shared.offset));

    let attn: MlxArray;
    const ta = getTrainingAttn();
    if (shared.kind === "quant") {
      attn = quantizedSdpa(q, shared.keys, shared.values, 1.0, mask, shared.groupSize, shared.bits);
    } else if (
      ta === "flash" && flashSupported(q) && (mask.mode === "causal" || mask.mode === "array")
    ) {
      // Training: ops.sdpa's dK vjp is wrong, so use the validated flash kernel.
      // Full layers → window 0 (pure causal); sliding layers → their window.
      const window = this.isSliding ? this.windowSize : 0;
      attn = flashAttention(q, shared.keys, shared.values, 1.0, true, window);
    } else {
      attn = ops.sdpa(q, shared.keys, shared.values, 1.0, mask.mode, mask.arr);
    }
    q.dispose();
    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.oProj.forward(merged);
    merged.dispose();
    return { out, shared };
  }
}

class MLP {
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
    // Fused GeGLU perf kernel (opt-in, not in a compiled trace): one pass
    // instead of ~9 element-wise kernels. Off → the bit-exact spelled path.
    let h: MlxArray;
    if (fusedGeluEnabled() && !isCompiledTrace() && fusedGeluSupported(g)) {
      h = fusedGeglu(g, u);
      g.dispose();
      u.dispose();
    } else {
      const act = ops.geluApprox(g);
      g.dispose();
      h = ops.mul(act, u);
      act.dispose();
      u.dispose();
    }
    const out = this.down.forward(h);
    h.dispose();
    return out;
  }
}

// --- MoE block (26B-A4B) — port of reference Router/Experts/SwitchGLU ----
// (gemma4_text.py + switch_layers.py in the oracle venv). The checkpoint
// ships pre-stacked switch_glu tensors [experts, out, in/packed]; only the
// quantized path exists here (all our targets are OptiQ quants).

/** Port of reference Router: norm -> scale -> project -> top-k -> renormalize. */
class Router {
  readonly proj: QuantizedLinear;
  /** scale · hidden_size^-0.5, precomputed (identical ops to the per-call
   *  product in the reference: bf16 array × weak scalar). */
  readonly normWeight: MlxArray;
  readonly perExpertScale: MlxArray;
  readonly eps: number;
  readonly numExperts: number;
  readonly topK: number;
  /** Decoder layer index (parsed from the weight prefix) — for E0 tracing. */
  readonly layerIdx: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.layerIdx = Number(prefix.match(/layers\.(\d+)/)?.[1] ?? -1);
    this.proj = QuantizedLinear.load(weights, `${prefix}.proj`, config);
    // weights.tensor() returns the Weights-owned cached array — do NOT
    // dispose it (a second model over the same Weights would get a dead
    // handle; Weights.dispose() frees it at end of life)
    const scale = weights.tensor(`${prefix}.scale`);
    this.normWeight = ops.mulScalar(scale, Math.pow(t.hiddenSize, -0.5));
    this.perExpertScale = weights.tensor(`${prefix}.per_expert_scale`);
    this.eps = t.rmsNormEps;
    this.numExperts = t.numExperts;
    this.topK = t.topKExperts;
  }

  /** x [B, L, H] → { indices [B, L, k] (uint32), weights [B, L, k] }. */
  forward(x: MlxArray): { indices: MlxArray; weights: MlxArray } {
    const normed = ops.rmsNorm(x, this.normWeight, this.eps);
    const scores = this.proj.forward(normed);
    normed.dispose();

    const part = ops.argpartitionAxis(scores, this.numExperts - this.topK, -1);
    const [B, L] = scores.shape as [number, number, number];
    let indices: MlxArray;
    if (isCompiledTrace()) {
      const start = ops.fromInt32([this.numExperts - this.topK], [1]);
      indices = ops.sliceDynamic(part, start, [2], [B, L, this.topK]);
      start.dispose();
    } else {
      indices = part.slice([0, 0, this.numExperts - this.topK], [B, L, this.numExperts]);
    }
    part.dispose();

    let w = ops.takeAlongAxis(scores, indices, -1);
    scores.dispose();
    w = disposing(w, ops.softmaxAxis(w, -1, false));
    const gathered = ops.takeAxis(this.perExpertScale, indices, 0);
    w = disposing(w, ops.mul(w, gathered));
    gathered.dispose();
    if (isExpertTracing()) recordRouting(this.layerIdx, indices);
    return { indices, weights: w };
  }
}

/** Port of switch_layers.SwitchGLU (geglu activation), quantized path. */
class SwitchGLU {
  readonly gate: QuantizedSwitchLinear;
  readonly up: QuantizedSwitchLinear;
  readonly down: QuantizedSwitchLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedSwitchLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedSwitchLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedSwitchLinear.load(weights, `${prefix}.down_proj`, config);
  }

  /** x [B, L, H], indices [B, L, k] → [B, L, k, H]. */
  forward(x: MlxArray, indices: MlxArray): MlxArray {
    // x → [B, L, 1, 1, H] (reference expand_dims(x, (-2, -3)))
    let h = ops.expandDims(x, -2);
    h = disposing(h, ops.expandDims(h, -3));

    // Sort tokens by expert when there are many rows (reference threshold).
    const doSort = indices.size >= 64;
    let idx = indices;
    let invOrder: MlxArray | null = null;
    let order: MlxArray | null = null;
    if (doSort) {
      // _gather_sort: flatten indices, argsort, gather rows by order // k
      const k = indices.shape[indices.ndim - 1]!;
      const idxFlat = ops.reshape(indices, [indices.size]);
      order = ops.argsortAxis(idxFlat, 0);
      invOrder = ops.argsortAxis(order, 0);
      const kScalar = ops.scalarLike(k, order);
      const rowIdx = ops.floorDivide(order, kScalar);
      kScalar.dispose();
      const [, , , , H] = h.shape as number[];
      const flat = ops.reshape(h, [-1, 1, H!]);
      h.dispose();
      h = ops.takeAxis(flat, rowIdx, 0);
      flat.dispose();
      rowIdx.dispose();
      idx = ops.takeAxis(idxFlat, order, 0);
      idxFlat.dispose();
    }

    const xUp = this.up.forward(h, idx, doSort);
    const xGate = this.gate.forward(h, idx, doSort);
    h.dispose();
    // GeGLU activation: gelu_approx(gate) · up (same composition as MLP)
    const act = ops.geluApprox(xGate);
    xGate.dispose();
    const mid = ops.mul(act, xUp);
    act.dispose();
    xUp.dispose();
    let y = this.down.forward(mid, idx, doSort);
    mid.dispose();
    if (idx !== indices) idx.dispose();

    if (doSort) {
      // _scatter_unsort: restore row order, unflatten to indices.shape
      y = disposing(y, ops.takeAxis(y, invOrder!, 0));
      invOrder!.dispose();
      order!.dispose();
      const [B, L, k] = indices.shape as number[];
      const H = y.shape[y.ndim - 1]!;
      y = disposing(y, ops.reshape(y, [B!, L!, k!, 1, H]));
    }

    // squeeze(-2)
    const shape = y.shape;
    shape.splice(shape.length - 2, 1);
    return disposing(y, ops.reshape(y, shape));
  }
}

/** Port of reference Experts: switch_glu then top-k weighted sum. */
class Experts {
  readonly switchGlu: SwitchGLU;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.switchGlu = new SwitchGLU(weights, config, `${prefix}.switch_glu`);
  }

  forward(x: MlxArray, indices: MlxArray, weights: MlxArray): MlxArray {
    const w = ops.expandDims(weights, -1);
    const y = this.switchGlu.forward(x, indices);
    const wy = ops.mul(w, y);
    w.dispose();
    y.dispose();
    return disposing(wy, ops.sumAxis(wy, -2, false));
  }
}

export class DecoderLayer {
  readonly attn: Attention;
  readonly mlp: MLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly preFfNorm: RMSNorm;
  readonly postFfNorm: RMSNorm;
  readonly layerScalar: MlxArray | null;
  readonly layerType: string;
  // 26B-A4B MoE block (dense MLP + routed experts in parallel branches)
  readonly router: Router | null;
  readonly experts: Experts | null;
  readonly postFfNorm1: RMSNorm | null;
  readonly postFfNorm2: RMSNorm | null;
  readonly preFfNorm2: RMSNorm | null;
  // e2b/e4b per-layer input gating
  readonly perLayerGate: QuantizedLinear | null;
  readonly perLayerProjection: QuantizedLinear | null;
  readonly postPerLayerNorm: RMSNorm | null;

  constructor(weights: Weights, config: ModelConfig, prefixBase: string, idx: number, hasKv: boolean) {
    const prefix = `${prefixBase}.layers.${idx}`;
    const t = config.text;
    this.layerType = t.layerTypes[idx]!;
    this.attn = new Attention(weights, config, `${prefix}.self_attn`, this.layerType, hasKv);
    this.mlp = new MLP(weights, config, `${prefix}.mlp`);
    const norm = (n: string) => new RMSNorm(weights.tensor(`${prefix}.${n}.weight`), t.rmsNormEps);
    this.inputNorm = norm("input_layernorm");
    this.postAttnNorm = norm("post_attention_layernorm");
    this.preFfNorm = norm("pre_feedforward_layernorm");
    this.postFfNorm = norm("post_feedforward_layernorm");
    this.layerScalar = weights.has(`${prefix}.layer_scalar`)
      ? weights.tensor(`${prefix}.layer_scalar`)
      : null;
    if (t.enableMoeBlock) {
      this.router = new Router(weights, config, `${prefix}.router`);
      this.experts = new Experts(weights, config, `${prefix}.experts`);
      this.postFfNorm1 = norm("post_feedforward_layernorm_1");
      this.postFfNorm2 = norm("post_feedforward_layernorm_2");
      this.preFfNorm2 = norm("pre_feedforward_layernorm_2");
    } else {
      this.router = this.experts = null;
      this.postFfNorm1 = this.postFfNorm2 = this.preFfNorm2 = null;
    }
    if (t.hiddenSizePerLayerInput > 0) {
      this.perLayerGate = QuantizedLinear.load(weights, `${prefix}.per_layer_input_gate`, config);
      this.perLayerProjection = QuantizedLinear.load(weights, `${prefix}.per_layer_projection`, config);
      this.postPerLayerNorm = norm("post_per_layer_input_norm");
    } else {
      this.perLayerGate = this.perLayerProjection = null;
      this.postPerLayerNorm = null;
    }
  }

  forward(
    x: MlxArray, mask: Mask, cache: Cache | null,
    sharedIn: SharedKv | null, perLayerInput: MlxArray | null,
  ): { h: MlxArray; shared: SharedKv } {
    let h = this.inputNorm.forward(x);
    const { out, shared } = this.attn.forward(h, mask, cache, sharedIn);
    h.dispose();
    h = out;
    h = disposing(h, this.postAttnNorm.forward(h));
    h = disposing(h, ops.add(x, h));

    const residual = h;
    let f: MlxArray;
    if (this.router && this.experts) {
      // MoE: dense MLP and routed experts as parallel branches off h
      // (reference DecoderLayer, enable_moe path)
      let h1 = this.preFfNorm.forward(h);
      h1 = disposing(h1, this.mlp.forward(h1));
      h1 = disposing(h1, this.postFfNorm1!.forward(h1));

      const { indices, weights: topKWeights } = this.router.forward(h);
      let h2 = this.preFfNorm2!.forward(h);
      h2 = disposing(h2, this.experts.forward(h2, indices, topKWeights));
      h2 = disposing(h2, this.postFfNorm2!.forward(h2));
      indices.dispose();
      topKWeights.dispose();

      f = ops.add(h1, h2);
      h1.dispose();
      h2.dispose();
    } else {
      f = this.preFfNorm.forward(h);
      f = disposing(f, this.mlp.forward(f));
    }
    f = disposing(f, this.postFfNorm.forward(f));
    h = ops.add(residual, f);
    residual.dispose();
    f.dispose();

    // per-layer input gating (reference gemma4_text DecoderLayer)
    if (this.perLayerGate && this.perLayerProjection && this.postPerLayerNorm && perLayerInput) {
      const res2 = h;
      let gate = this.perLayerGate.forward(h);
      gate = disposing(gate, ops.geluApprox(gate));
      gate = disposing(gate, ops.mul(gate, perLayerInput));
      gate = disposing(gate, this.perLayerProjection.forward(gate));
      gate = disposing(gate, this.postPerLayerNorm.forward(gate));
      h = ops.add(res2, gate);
      res2.dispose();
      gate.dispose();
    }

    if (this.layerScalar) h = disposing(h, ops.mul(h, this.layerScalar));
    return { h, shared };
  }
}

export class Gemma4Model {
  readonly config: ModelConfig;
  /** Total weight-shard bytes (for the conditional wired-limit scope). */
  readonly weightsBytes: number;
  /** Weight-name prefix ("language_model.model" or "model"). */
  readonly prefixBase: string;
  /** Active LoRA adapters for the current generation (see LoraState). */
  readonly loraState = new LoraState();
  readonly embed: QuantizedEmbedding;
  readonly layers: DecoderLayer[];
  readonly finalNorm: RMSNorm;
  readonly embedScale: number;
  readonly windowSize: number;
  /** Donor count: layers [0, numDonors) own caches; the rest share. */
  readonly numDonors: number;
  /** layer idx → donor layer idx whose fetched KV it consumes (self for donors). */
  readonly previousKvs: number[];
  /** layer idx → cache index (donors only; -1 for sharers). */
  readonly cacheIndex: number[];
  /** Set by the trainer to enable gradient checkpointing in forwardLayers
   *  (null = off; the non-checkpointed path is untouched). */
  gradCkpt: GradCheckpointCtx | null = null;
  // e2b/e4b per-layer input machinery
  readonly perLayerEmbed: QuantizedEmbedding | null;
  readonly perLayerModelProjection: QuantizedLinear | null;
  readonly perLayerProjectionNorm: RMSNorm | null;
  readonly perLayerWidth: number;

  constructor(weights: Weights, config: ModelConfig) {
    const t = config.text;
    if (t.hiddenSize === 0 || !config.text.tieWordEmbeddings)
      throw new Error("only tied-embedding text configs are supported");

    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    // gemma4_unified prefixes weights with language_model.; gemma4_text doesn't
    const prefixBase = weights.has("language_model.model.embed_tokens.weight")
      ? "language_model.model" : "model";
    this.prefixBase = prefixBase;
    this.embed = QuantizedEmbedding.load(weights, `${prefixBase}.embed_tokens`, config);

    this.numDonors = t.numHiddenLayers - t.numKvSharedLayers;
    this.layers = Array.from(
      { length: t.numHiddenLayers },
      (_, i) => new DecoderLayer(weights, config, prefixBase, i, i < this.numDonors),
    );
    // previous_kvs (reference Gemma4TextModel): sharer j uses the LAST
    // donor of its own layer type
    this.previousKvs = this.layers.map((_, i) => i);
    if (t.numKvSharedLayers > 0) {
      const lastByType: Record<string, number> = {};
      for (let i = 0; i < this.numDonors; i++)
        lastByType[this.layers[i]!.layerType] = i;
      for (let j = this.numDonors; j < this.layers.length; j++) {
        const donor = lastByType[this.layers[j]!.layerType];
        if (donor === undefined)
          throw new Error(`no donor layer of type ${this.layers[j]!.layerType}`);
        this.previousKvs[j] = donor;
      }
    }
    this.cacheIndex = this.layers.map((_, i) => (i < this.numDonors ? i : -1));

    this.finalNorm = new RMSNorm(
      weights.tensor(`${prefixBase}.norm.weight`),
      t.rmsNormEps,
    );
    this.embedScale = Math.sqrt(t.hiddenSize);
    this.windowSize = t.slidingWindow;

    if (t.hiddenSizePerLayerInput > 0) {
      this.perLayerEmbed = QuantizedEmbedding.load(weights, `${prefixBase}.embed_tokens_per_layer`, config);
      this.perLayerModelProjection = QuantizedLinear.load(weights, `${prefixBase}.per_layer_model_projection`, config);
      this.perLayerProjectionNorm = new RMSNorm(
        weights.tensor(`${prefixBase}.per_layer_projection_norm.weight`), t.rmsNormEps,
      );
      this.perLayerWidth = t.hiddenSizePerLayerInput;
    } else {
      this.perLayerEmbed = this.perLayerModelProjection = null;
      this.perLayerProjectionNorm = null;
      this.perLayerWidth = 0;
    }
  }

  /** LoRA-mountable linears, keyed by weight-file module path: optiq
   *  mount.py's 7 target suffixes PLUS the e2b/e4b per-layer-input
   *  projections — mlx-lm's trainer targets those on e4b and optiq's
   *  mount silently drops their trained weights (deviation documented in
   *  PLAN Phase 8 findings; we apply every adapter weight we can map).
   *  Expert pools stay non-targets (LoRASwitchLinear is future work). */
  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `${this.prefixBase}.layers.${i}`;
      const add = (suffix: string, lin: QuantizedLinear | null) => {
        if (lin) out.set(`${p}.${suffix}`, lin);
      };
      add("self_attn.q_proj", l.attn.qProj);
      add("self_attn.k_proj", l.attn.kProj);
      add("self_attn.v_proj", l.attn.vProj);
      add("self_attn.o_proj", l.attn.oProj);
      add("mlp.gate_proj", l.mlp.gate);
      add("mlp.up_proj", l.mlp.up);
      add("mlp.down_proj", l.mlp.down);
      add("per_layer_input_gate", l.perLayerGate);
      add("per_layer_projection", l.perLayerProjection);
    }
    return out;
  }

  /** Caches for donor layers only (sharers consume donors' fetched KV). */
  makeCache(): Cache[] {
    return this.layers.slice(0, this.numDonors).map((l) =>
      l.layerType === "sliding_attention"
        ? new RotatingKVCache(this.windowSize)
        : new KVCache(),
    );
  }

  /** ids [1, L] → final-norm hidden states [1, L, hidden]. */
  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    let h = this.embed.encode(ids);
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    return this.forwardLayers(h, cache, null, ids);
  }

  /** Per-layer inputs (reference _get_per_layer_inputs +
   *  _project_per_layer_inputs): [1, L, nLayers, perLayerWidth]. */
  protected computePerLayerInputs(ids: MlxArray, hScaled: MlxArray): MlxArray {
    const t = this.config.text;
    const B = ids.shape[0]!;
    const L = ids.shape[1]!;
    let pli = this.perLayerEmbed!.encode(ids); // [B, L, nLayers*width]
    pli = disposing(pli, ops.mulScalar(pli, Math.sqrt(this.perLayerWidth)));
    pli = disposing(pli, ops.reshape(pli, [B, L, t.numHiddenLayers, this.perLayerWidth]));

    let proj = this.perLayerModelProjection!.forward(hScaled);
    proj = disposing(proj, ops.mulScalar(proj, 1 / Math.sqrt(t.hiddenSize)));
    proj = disposing(proj, ops.reshape(proj, [B, L, t.numHiddenLayers, this.perLayerWidth]));
    proj = disposing(proj, this.perLayerProjectionNorm!.forward(proj));

    let combined = ops.add(proj, pli);
    proj.dispose();
    pli.dispose();
    combined = disposing(combined, ops.mulScalar(combined, Math.SQRT1_2));
    return combined;
  }

  /** Pre-merged (unscaled) input embeddings → hidden states. Used by the
   *  vision path; `bidir` (bool [L]) marks image tokens, which attend
   *  bidirectionally among themselves (use_bidirectional_attention:
   *  "vision" — text stays causal). */
  forwardEmbeddings(embeds: MlxArray, cache: Cache[], bidir: MlxArray | null): MlxArray {
    if (this.perLayerWidth > 0)
      throw new Error("vision + per-layer-input models not supported yet");
    const h = ops.mulScalar(embeds, this.embedScale);
    return this.forwardLayers(h, cache, bidir, null);
  }

  /** Consumes h. */
  protected forwardLayers(
    h0: MlxArray, cache: Cache[], bidir: MlxArray | null, ids: MlxArray | null,
  ): MlxArray {
    const B = h0.shape[0]!;
    const L = h0.shape[1]!;
    let h = h0;

    // one mask per layer type, computed from the first cache of that type
    const masks = new Map<string, Mask>();
    for (let i = 0; i < this.numDonors; i++) {
      const type = this.layers[i]!.layerType;
      if (!masks.has(type)) {
        const window = type === "sliding_attention" ? this.windowSize : null;
        if (bidir && L > 1) {
          const c = cache[i]!;
          if (c.offset !== 0)
            throw new Error("bidirectional image masks require offset-0 prefill");
          masks.set(type, bidirMask(L, window, bidir));
        } else {
          masks.set(type, cache[i]!.makeMask(L, window));
        }
      }
    }

    // per-layer inputs (e2b/e4b)
    let perLayer: MlxArray | null = null;
    if (this.perLayerWidth > 0) {
      if (!ids) throw new Error("per-layer-input models require token ids");
      perLayer = this.computePerLayerInputs(ids, h);
    }

    const intermediates: (SharedKv | null)[] = Array(this.layers.length).fill(null);
    for (let i = 0; i < this.layers.length; i++) {
      const layer = this.layers[i]!;
      const ci = this.cacheIndex[i]!;
      const sharedIn = ci === -1 ? (intermediates[this.previousKvs[i]!] ?? null) : null;
      let pls: MlxArray | null = null;
      if (perLayer) {
        if (isCompiledTrace()) {
          const start = ops.fromInt32([i], [1]);
          pls = ops.sliceDynamic(perLayer, start, [2], [B, L, 1, this.perLayerWidth]);
          start.dispose();
        } else {
          pls = perLayer.slice([0, 0, i, 0], [B, L, i + 1, this.perLayerWidth]);
        }
        const r = ops.reshape(pls, [B, L, this.perLayerWidth]);
        pls.dispose();
        pls = r;
      }
      const mask = masks.get(layer.layerType)!;
      const layerCache = ci === -1 ? null : cache[ci]!;
      const { h: next, shared } = this.gradCkpt
        ? this.runCheckpointedLayer(i, layer, h, mask, layerCache, sharedIn, pls)
        : layer.forward(h, mask, layerCache, sharedIn, pls);
      pls?.dispose();
      h.dispose();
      h = next;
      intermediates[i] = shared;
    }
    perLayer?.dispose();
    // dispose donor-fetched KV (each donor's shared entry exactly once)
    for (let i = 0; i < this.numDonors; i++) {
      const s = intermediates[i];
      if (!s) continue;
      if (s.kind === "plain") {
        s.keys.dispose();
        s.values.dispose();
      } else {
        for (const t of [s.keys, s.values])
          for (const a of [t.packed, t.scales, t.biases]) a.dispose();
      }
    }
    for (const m of masks.values()) m.arr?.dispose();

    return disposing(h, this.finalNorm.forward(h));
  }

  // --- Segmented-backward support (docs/design/segmented-backward-training.md
  // §4 Phase B). These are ADDITIVE — forwardLayers is untouched. The segmented
  // driver builds masks + per-layer inputs ONCE, then drives runLayerRange per
  // segment, threading the KV-shared donor K/V across segment boundaries.

  /** Donor layer indices that KV-sharing sharers reuse (e4b: {22,23} — the last
   *  donor of each attention type; empty for dense models). Their fetched K/V
   *  must survive across segment boundaries (saved as detached boundaries). */
  get reusedDonors(): Set<number> {
    return new Set(this.previousKvs.filter((d, i) => d !== i));
  }

  /** Per-layer-type training masks (offset-0, full-sequence, no bidir) — built
   *  once, shared across all segments. Mirrors forwardLayers' mask construction.
   *  Caller owns the returned arrays (dispose each mask.arr). */
  makeTrainingMasks(cache: Cache[], L: number): Map<string, Mask> {
    const masks = new Map<string, Mask>();
    for (let i = 0; i < this.numDonors; i++) {
      const type = this.layers[i]!.layerType;
      if (!masks.has(type)) {
        const window = type === "sliding_attention" ? this.windowSize : null;
        masks.set(type, cache[i]!.makeMask(L, window));
      }
    }
    return masks;
  }

  /** e2b/e4b training entry: the SCALED input embedding (the first segment
   *  boundary) plus the per-layer-input tensor [B,L,nLayers,width] (a detached
   *  boundary, sliced per layer inside runLayerRange). perLayer is null for dense
   *  models. Caller owns both. */
  embedForSegmented(ids: MlxArray): { hScaled: MlxArray; perLayer: MlxArray | null } {
    let h = this.embed.encode(ids);
    h = disposing(h, ops.mulScalar(h, this.embedScale));
    const perLayer = this.perLayerWidth > 0 ? this.computePerLayerInputs(ids, h) : null;
    return { hScaled: h, perLayer };
  }

  /** Dispose a fetched donor K/V (plain or quantized) — mirrors forwardLayers'
   *  donor cleanup. */
  private static disposeSharedKv(s: SharedKv): void {
    if (s.kind === "plain") {
      s.keys.dispose();
      s.values.dispose();
    } else {
      for (const t of [s.keys, s.values])
        for (const a of [t.packed, t.scales, t.biases]) a.dispose();
    }
  }

  /** Run decoder layers `[aIdx, bIdx)` on hidden `h`, returning the residual
   *  stream after the last layer in the range (NO finalNorm) plus the fetched
   *  K/V of any reused-donor layers in the range (`donorKvOut`, for later
   *  segments). The input `h` is NEVER disposed (the caller / vjp owns the
   *  boundary leaf); intra-range hidden intermediates and per-layer slices ARE
   *  disposed. Non-reused donors' K/V are disposed; reused donors' K/V are
   *  returned (caller threads + disposes). NOT gradient-checkpointed — the
   *  segmentation IS the memory strategy.
   *
   *  @param masks     per-layer-type masks (makeTrainingMasks), shared, caller-owned.
   *  @param perLayer  the [B,L,nLayers,width] tensor (caller-owned) or null.
   *  @param donorKvIn fetched K/V of reused donors from EARLIER segments, keyed
   *                   by donor layer index (caller-owned; not disposed here). */
  runLayerRange(
    h: MlxArray, aIdx: number, bIdx: number, cache: Cache[],
    masks: Map<string, Mask>, perLayer: MlxArray | null,
    donorKvIn: Map<number, SharedKv>,
  ): { h: MlxArray; donorKvOut: Map<number, SharedKv> } {
    const donorKvOut = new Map<number, SharedKv>();
    if (aIdx >= bIdx) return { h, donorKvOut };
    const B = h.shape[0]!;
    const L = h.shape[1]!;
    const reused = this.reusedDonors;
    let cur = h;
    for (let i = aIdx; i < bIdx; i++) {
      const layer = this.layers[i]!;
      const ci = this.cacheIndex[i]!;
      const isDonor = ci !== -1;
      let sharedIn: SharedKv | null = null;
      if (!isDonor) {
        const donor = this.previousKvs[i]!;
        sharedIn = donorKvOut.get(donor) ?? donorKvIn.get(donor) ?? null;
        if (!sharedIn) throw new Error(`runLayerRange: donor ${donor} K/V not available for sharer ${i}`);
      }
      let pls: MlxArray | null = null;
      if (perLayer) {
        const sl = perLayer.slice([0, 0, i, 0], [B, L, i + 1, this.perLayerWidth]);
        pls = ops.reshape(sl, [B, L, this.perLayerWidth]);
        sl.dispose();
      }
      const mask = masks.get(layer.layerType)!;
      const { h: next, shared } = layer.forward(cur, mask, isDonor ? cache[ci]! : null, sharedIn, pls);
      pls?.dispose();
      if (i > aIdx) cur.dispose(); // keep the input boundary leaf; drop interiors
      cur = next;
      if (isDonor) {
        if (reused.has(i)) donorKvOut.set(i, shared);
        else Gemma4Model.disposeSharedKv(shared);
      }
      // sharer: `shared` === sharedIn (owned by donorKvIn/Out) — do not dispose.
    }
    return { h: cur, donorKvOut };
  }

  /** Run one layer under gradient checkpointing: its interior activations are
   *  dropped and recomputed in the backward pass. The layer's LoRA params, h,
   *  the mask array (if any), pls, and a sharer's donor KV are threaded as
   *  explicit checkpoint inputs (the closure must be pure and self-contained —
   *  it re-runs during the backward, and captured autograd primals would be
   *  stale). A donor layer also emits its fetched K/V as checkpoint outputs so
   *  the (retained, small) tensors reach the sharer layers downstream. */
  private runCheckpointedLayer(
    i: number, layer: DecoderLayer, h: MlxArray, mask: Mask,
    layerCache: Cache | null, sharedIn: SharedKv | null, pls: MlxArray | null,
  ): { h: MlxArray; shared: SharedKv | null } {
    const ctx = this.gradCkpt!;
    const lws = ctx.byLayer.get(i) ?? [];
    const isSharer = layerCache === null;
    const sIn = isSharer && sharedIn && sharedIn.kind === "plain" ? sharedIn : null;
    const hasMaskArr = mask.arr !== null;
    const hasPls = pls !== null;
    const maskMode = mask.mode;

    // Input order: [h, maskArr?, pls?, sharedInK?, sharedInV?, (lora_a, lora_b)*]
    const inputs: MlxArray[] = [h];
    if (hasMaskArr) inputs.push(mask.arr!);
    if (hasPls) inputs.push(pls!);
    if (sIn) inputs.push(sIn.keys, sIn.values);
    for (const lw of lws) inputs.push(lw.a, lw.b);

    const ck = new Checkpoint((ins) => {
      let k = 0;
      const hIn = ins[k++]!;
      const mArr = hasMaskArr ? ins[k++]! : null;
      const plsIn = hasPls ? ins[k++]! : null;
      const sharedInRebuilt: SharedKv | null = sIn
        ? { kind: "plain", keys: ins[k++]!, values: ins[k++]!, offset: 0 }
        : null;
      const saved = lws.map((lw) => [lw.a, lw.b] as [MlxArray, MlxArray]);
      for (const lw of lws) { lw.a = ins[k++]!; lw.b = ins[k++]!; }
      try {
        const out = layer.forward(hIn, { mode: maskMode, arr: mArr }, layerCache, sharedInRebuilt, plsIn);
        if (!isSharer && out.shared && out.shared.kind === "plain")
          return [out.h, out.shared.keys, out.shared.values];
        return [out.h];
      } finally {
        lws.forEach((lw, j) => { lw.a = saved[j]![0]; lw.b = saved[j]![1]; });
      }
    });
    ctx.keepAlive.push(ck);

    const outs = ck.apply(inputs);
    const shared: SharedKv | null =
      !isSharer && outs.length === 3
        ? { kind: "plain", keys: outs[1]!, values: outs[2]!, offset: 0 }
        : null;
    return { h: outs[0]!, shared };
  }

  /** hidden [1, L, hidden] → softcapped logits [1, L, vocab]. */
  logitsFromHidden(h: MlxArray): MlxArray {
    let logits = this.embed.asLinear(h);
    const softcap = this.config.text.finalLogitSoftcapping;
    if (softcap !== null) logits = disposing(logits, logitSoftcap(logits, softcap));
    return logits;
  }

  /** tokens → logits [1, L, vocab] (compat path used by parity tests). */
  forward(tokens: number[] | MlxArray, cache: Cache[]): MlxArray {
    const ids = Array.isArray(tokens)
      ? ops.fromInt32(tokens, [1, tokens.length])
      : tokens;
    const h = this.forwardHidden(ids, cache);
    if (Array.isArray(tokens)) ids.dispose();
    const logits = this.logitsFromHidden(h);
    h.dispose();
    return logits;
  }

  /** Greedy generation (parity harness); returns generated token ids. */
  generate(promptTokens: number[], maxTokens: number, eosIds: number[] = []): number[] {
    const cache = this.makeCache();
    const out: number[] = [];
    try {
      let tokens = promptTokens;
      for (let step = 0; step < maxTokens; step++) {
        const logits = this.forward(tokens, cache);
        const next = argmaxLastPosition(logits);
        logits.dispose();
        if (eosIds.includes(next)) break;
        out.push(next);
        tokens = [next];
      }
    } finally {
      for (const c of cache) c.dispose();
    }
    return out;
  }
}
