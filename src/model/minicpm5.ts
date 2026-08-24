// Concrete model graph for MiniCPM5-1B-OptiQ-4bit.
// Port target: mlx_lm.models.llama from the oracle venv.

import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { unrotateValues as tqUnrotateValues } from "../mlx/turboquant-ops";
import {
  argmaxLastPosition,
  disposeTriple,
  disposing,
  KVCache,
  LoraState,
  QuantizedKVCache,
  TurboQuantKVCache,
  QuantizedEmbedding,
  QuantizedLinear,
  quantizedSdpa,
  RMSNorm,
  isCompiledTrace,
  type Cache,
  type Mask,
} from "./gemma4-base";
import { CompiledFunction } from "../mlx/compile";
import { runtimeValue } from "../runtime-config";

/** Verbatim port of mlx_lm/models/activations.py:
 *    `@partial(mx.compile, shapeless=True) def swiglu(gate, x): return nn.silu(gate) * x`
 *  mx.compile fuses sigmoid + mul + mul into ONE kernel (mlx-lm's decode
 *  `CV2ISigmoid…Multiply`) instead of our three separate dispatches. Traced
 *  once, replayed thereafter. Used on the decode (M=1) path only. */
let _swigluClosure: CompiledFunction | null = null;
export function compiledSwiglu(gate: MlxArray, up: MlxArray): MlxArray {
  if (!_swigluClosure) {
    _swigluClosure = new CompiledFunction((inputs) => {
      const g = inputs[0]!, u = inputs[1]!;              // nn.silu(gate) * x
      const sig = ops.sigmoid(g);
      const silu = ops.mul(g, sig); sig.dispose();
      const out = ops.mul(silu, u); silu.dispose();
      return [out];
    });
  }
  return _swigluClosure.apply([gate, up])[0]!;
}

import { flashAttention, getTrainingAttn, flashSupported } from "./flash-attention";

// Shared prompt-prefix plan (lever 7). When set, the attention ropes the
// concatenated [prompt(P); chosenResp(Rc); rejectedResp(Rr)] sequence
// BLOCK-WISE — prompt at offset 0, EACH response reset to offset P — instead of
// the uniform cache.offset. This is what lets one forward over the concat be
// bit-exact with the two separate [prompt;resp] forwards (each response sees the
// prompt's RoPE positions, not shifted-by-the-other-response). Set by
// orpoLossPrefixShared around the forward (single-threaded), cleared after; null
// → the normal uniform-offset rope (every other forward is untouched). The
// matching block-sparse attention mask rides in via PrefixSharedCache.makeMask.
export interface PrefixPlan { P: number; Rc: number; Rr: number }
let _prefixPlan: PrefixPlan | null = null;
export function setMiniCpmPrefixPlan(p: PrefixPlan | null): void {
  _prefixPlan = p;
}
/** True while a block-wise prefix-shared RoPE plan is active (ORPO forward).
 *  The generated debranched fast path must fall back to the monolith then. */
export function miniCpmPrefixPlanActive(): boolean {
  return _prefixPlan != null;
}

/** Block-wise RoPE for the prefix-shared concat [prompt; chosen; rejected] along
 *  the sequence axis (axis 2 of [B,H,T,D]): prompt rotated at offset 0, each
 *  response at offset P (reset). RoPE is per-token, so roping each contiguous
 *  block at its scalar offset and concatenating == roping with per-token
 *  position-ids [0..P-1, P..P+Rc-1, P..P+Rr-1]. Caller disposes the input. */
function ropeBlocks(x: MlxArray, dims: number, base: number, plan: PrefixPlan): MlxArray {
  const { P, Rc, Rr } = plan;
  const [B, H, , D] = x.shape as [number, number, number, number];
  const blocks: { start: number; len: number; off: number }[] = [
    { start: 0, len: P, off: 0 },
    { start: P, len: Rc, off: P },
    { start: P + Rc, len: Rr, off: P },
  ].filter((b) => b.len > 0);
  const parts = blocks.map((b) => {
    const sl = x.slice([0, 0, b.start, 0], [B, H, b.start + b.len, D]);
    const r = ops.rope(sl, dims, base, b.off, null);
    sl.dispose();
    return r;
  });
  const out = ops.concatAxis(parts, 2);
  for (const p of parts) p.dispose();
  return out;
}

export class LlamaAttention {
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear;
  readonly vProj: QuantizedLinear;
  readonly oProj: QuantizedLinear;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly scale: number;
  readonly ropeBase: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    this.vProj = QuantizedLinear.load(weights, `${prefix}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    let q = this.qProj.forward(x);
    let k = this.kProj.forward(x);
    let v = this.vProj.forward(x);

    q = disposing(q, ops.reshape(q, [B, L, this.nHeads, this.headDim]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    // RoPE: a number offset takes the static fast::rope; an array offset
    // (per-row positions for left-padded batched decode) takes the dynamic
    // variant — same kernel, offset read from the array. Captured once: rope
    // runs before updateAndFetch, so K and Q share the pre-write offset.
    const offsetArr = cache.ropeOffsetArr;
    const ropeStep = (x: MlxArray): MlxArray =>
      _prefixPlan
        ? ropeBlocks(x, this.headDim, this.ropeBase, _prefixPlan)
        : offsetArr
          ? ops.ropeDynamic(x, this.headDim, this.ropeBase, offsetArr, null)
          : ops.rope(x, this.headDim, this.ropeBase, cache.offset, null);
    q = disposing(q, ropeStep(q));
    k = disposing(k, ropeStep(k));
    let attn: MlxArray;
    if (cache instanceof QuantizedKVCache) {
      const [keys, values] = cache.updateAndFetchQuantized(k, v);
      k.dispose();
      v.dispose();
      attn = quantizedSdpa(q, keys, values, this.scale, mask, cache.groupSize, cache.bits);
      disposeTriple(keys);
      disposeTriple(values);
    } else if (cache instanceof TurboQuantKVCache) {
      // Deferred-V: sdpa runs on rotated values, then one InvFWHT on the
      // output (linear in V) — see TurboQuantKVCache.updateAndFetchDeferredV.
      const [keys, values] = cache.updateAndFetchDeferredV(k, v);
      k.dispose();
      v.dispose();
      const rotated = ops.sdpa(q, keys, values, this.scale, mask.mode, mask.arr);
      keys.dispose();
      values.dispose();
      attn = tqUnrotateValues(rotated);
      rotated.dispose();
    } else {
      const [keys, values] = cache.updateAndFetch(k, v);
      k.dispose();
      v.dispose();
      // Training: ops.sdpa's dK vjp is wrong, so route the backward through
      // the validated flash kernel. MiniCPM5 is full-attention → window 0.
      const ta = getTrainingAttn();
      if (ta === "flash" && flashSupported(q) && (mask.mode === "causal" || mask.mode === "array")) {
        attn = flashAttention(q, keys, values, this.scale, true, 0);
      } else {
        attn = ops.sdpa(q, keys, values, this.scale, mask.mode, mask.arr);
      }
      keys.dispose();
      values.dispose();
    }
    q.dispose();
    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.oProj.forward(merged);
    merged.dispose();
    return out;
  }
}

export class LlamaMLP {
  readonly gate: QuantizedLinear;
  readonly up: QuantizedLinear;
  readonly down: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = QuantizedLinear.load(weights, `${prefix}.gate_proj`, config);
    this.up = QuantizedLinear.load(weights, `${prefix}.up_proj`, config);
    this.down = QuantizedLinear.load(weights, `${prefix}.down_proj`, config);
  }

  /** MLP: returns mlp(x); the caller adds the residual when given. */
  forward(x: MlxArray, residual?: MlxArray): MlxArray {
    const H = x.shape[x.shape.length - 1]!;
    const M = x.shape.reduce((a, b) => a * b, 1) / H;
    const gate = this.gate.forward(x);
    const up = this.up.forward(x);
    // Decode (M=1): fuse silu·up into one kernel (mlx_lm activations.py swiglu).
    // Plain sigmoid+mul+mul otherwise (M>1 prefill/training, or inside a compile
    // trace) — identical math either way. MLX_BUN_COMPILED_SWIGLU=0 disables.
    let hidden: MlxArray;
    if (M === 1 && !isCompiledTrace() && runtimeValue("MLX_BUN_COMPILED_SWIGLU") !== "0") {
      hidden = compiledSwiglu(gate, up);
      gate.dispose();
      up.dispose();
    } else {
      const sig = ops.sigmoid(gate);
      const silu = ops.mul(gate, sig);
      gate.dispose();
      sig.dispose();
      hidden = ops.mul(silu, up);
      silu.dispose();
      up.dispose();
    }
    const m = this.down.forward(hidden);
    hidden.dispose();
    if (residual == null) return m;
    return disposing(m, ops.add(residual, m));
  }
}

export class LlamaLayer {
  readonly attn: LlamaAttention;
  readonly mlp: LlamaMLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.attn = new LlamaAttention(weights, config, `${prefix}.self_attn`);
    this.mlp = new LlamaMLP(weights, config, `${prefix}.mlp`);
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const xn = this.inputNorm.forward(x);
    const a = this.attn.forward(xn, mask, cache);
    xn.dispose();
    const h = ops.add(x, a);
    a.dispose();
    const hn = this.postAttnNorm.forward(h);
    // Pass the residual h INTO the MLP so the fused kernel absorbs it (out = h + mlp).
    const out = this.mlp.forward(hn, h);
    hn.dispose();
    h.dispose();
    return out;
  }
}

export class MiniCPM5Model {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  readonly embed: QuantizedEmbedding;
  readonly layers: LlamaLayer[];
  readonly finalNorm: RMSNorm;
  readonly lmHead: QuantizedLinear;

  constructor(weights: Weights, config: ModelConfig) {
    if (config.text.tieWordEmbeddings)
      throw new Error("llama tied embeddings are not supported yet");
    this.config = config;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, "model.embed_tokens", config);
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new LlamaLayer(weights, config, `model.layers.${i}`),
    );
    this.finalNorm = new RMSNorm(weights.tensor("model.norm.weight"), config.text.rmsNormEps);
    this.lmHead = QuantizedLinear.load(weights, "lm_head", config);
  }

  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `model.layers.${i}`;
      out.set(`${p}.self_attn.q_proj`, l.attn.qProj);
      out.set(`${p}.self_attn.k_proj`, l.attn.kProj);
      out.set(`${p}.self_attn.v_proj`, l.attn.vProj);
      out.set(`${p}.self_attn.o_proj`, l.attn.oProj);
      out.set(`${p}.mlp.gate_proj`, l.mlp.gate);
      out.set(`${p}.mlp.up_proj`, l.mlp.up);
      out.set(`${p}.mlp.down_proj`, l.mlp.down);
    }
    return out;
  }

  makeCache(): Cache[] {
    return this.layers.map(() => new KVCache());
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    const h = this.embed.encode(ids);
    return this.forwardLayers(h, cache);
  }

  forwardEmbeddings(_embeds: MlxArray, _cache: Cache[], _bidir: MlxArray | null): MlxArray {
    throw new Error("llama vision/input-embedding path is not supported");
  }

  protected forwardLayers(h0: MlxArray, cache: Cache[]): MlxArray {
    const h = this.runLayerRange(h0, 0, this.layers.length, cache);
    h0.dispose(); // runLayerRange keeps its input alive; we own h0 here
    return disposing(h, this.finalNorm.forward(h));
  }

  /** Run decoder layers `[aIdx, bIdx)` on hidden `h`, returning the residual
   *  stream after the last layer in the range (NO finalNorm). The input `h` is
   *  NEVER disposed — the caller owns it (for segmented backward `h` is a leaf
   *  whose lifetime is managed by the autograd closure); intra-range
   *  intermediates ARE disposed. Building block for `forwardLayers` and the
   *  segmented-backward training path (docs/design/orpo-training.md).
   *  MiniCPM5 is plain full-attention with no KV-sharing, so each layer reads
   *  its own stateless `cache[i]` and a single causal mask. */
  runLayerRange(h: MlxArray, aIdx: number, bIdx: number, cache: Cache[]): MlxArray {
    if (aIdx >= bIdx) return h;
    const L = h.shape[1]!;
    const mask = cache[aIdx]!.makeMask(L, null);
    let cur = h;
    for (let i = aIdx; i < bIdx; i++) {
      const next = this.layers[i]!.forward(cur, mask, cache[i]!);
      if (i > aIdx) cur.dispose(); // keep the input boundary leaf; drop interiors
      cur = next;
    }
    mask.arr?.dispose();
    return cur;
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    return this.lmHead.forward(h);
  }

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
