// UniversalDense — the Tier-0 config-driven dense llama-family module
// (docs/design/generic-model-support.md §3.1). One module, shaped exactly
// like qwen3.ts, with every arch delta selected by the UniversalArgs
// descriptor (archs.ts). Monolith path only: no perf kernels, no compiled
// decode, no kv-quant — slow, never broken. The bar is L1 bit-exactness
// vs mlx-lm on this machine's GPU (tests/universal-parity.test.ts).
//
// Porting discipline: each branch transcribes its mlx-lm source op-for-op
// (q/k-norm before vs after reshape, rope order, scale points, softcap,
// mask kinds). The descriptor selects branches; it never approximates.

import type { ModelConfig } from "../../config";
import type { Weights } from "../../weights";
import { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import {
  argmaxLastPosition,
  createCausalMask,
  disposing,
  FINFO_MIN,
  KVCache,
  logitSoftcap,
  LoraState,
  QuantizedLinear,
  RMSNorm,
  RotatingKVCache,
  type Cache,
  type Mask,
} from "../gemma4-base";
import { genericArgsFor, type UniversalArgs } from "./archs";
import { initializeRope, NoRope, phi3SuRope, UniversalRope } from "./rope";
import {
  loadEmbedding,
  loadLayerNorm,
  loadLinear,
  loadRmsNorm,
  WeightAudit,
  type AnyEmbedding,
  type AnyLinear,
  type AnyNorm,
} from "./modules";

/** Rope for one attention module, per the descriptor (llama's
 *  initialize_rope, the plain-nn.RoPE archs, or phi3's Su/linear branch). */
function buildRope(a: UniversalArgs): UniversalRope {
  const ropeDims = Math.floor(a.headDim * a.partialRotaryFactor);
  if (a.rope === "phi3") {
    const sc = a.ropeScaling;
    if (sc && ["longrope", "su"].includes(String(sc.type))) {
      return phi3SuRope(
        ropeDims,
        a.ropeTheta,
        a.maxPositionEmbeddings ?? 131072,
        a.originalMaxPositionEmbeddings,
        (sc.long_factor as number[] | number | undefined) ?? 1.0,
      );
    }
    let scale = 1.0;
    if (sc && String(sc.type) === "linear") scale = 1 / (sc.factor as number);
    return new UniversalRope(ropeDims, a.ropeTraditional, a.ropeTheta, scale, null, 1, false);
  }
  if (a.rope === "plain")
    return new UniversalRope(ropeDims, a.ropeTraditional, a.ropeTheta, 1.0, null, 1, false);
  // initialize_rope path (llama, qwen2, qwen3, olmo2, granite, smollm3)
  return initializeRope(a.headDim, a.ropeTheta, a.ropeTraditional, a.ropeScaling, a.maxPositionEmbeddings);
}

class UniversalAttention {
  readonly qProj: AnyLinear | null;
  readonly kProj: AnyLinear | null;
  readonly vProj: AnyLinear | null;
  readonly qkvProj: AnyLinear | null;
  readonly oProj: AnyLinear;
  readonly qNorm: RMSNorm | null;
  readonly kNorm: RMSNorm | null;

  constructor(
    weights: Weights,
    config: ModelConfig,
    prefix: string,
    readonly a: UniversalArgs,
    readonly rope: UniversalRope,
    audit: WeightAudit,
  ) {
    if (a.fusedQkv) {
      this.qkvProj = loadLinear(weights, `${prefix}.qkv_proj`, config, audit);
      this.qProj = this.kProj = this.vProj = null;
    } else {
      this.qProj = loadLinear(weights, `${prefix}.q_proj`, config, audit);
      this.kProj = loadLinear(weights, `${prefix}.k_proj`, config, audit);
      this.vProj = loadLinear(weights, `${prefix}.v_proj`, config, audit);
      this.qkvProj = null;
    }
    this.oProj = loadLinear(weights, `${prefix}.o_proj`, config, audit);
    if (a.qkNorm !== "none") {
      // qwen3 ("head"): RMSNorm(head_dim); olmo2 ("full"): RMSNorm(width) —
      // both live at q_norm/k_norm and use rms_norm_eps.
      this.qNorm = loadRmsNorm(weights, `${prefix}.q_norm`, a.normEps, false, audit);
      this.kNorm = loadRmsNorm(weights, `${prefix}.k_norm`, a.normEps, false, audit);
    } else {
      this.qNorm = this.kNorm = null;
    }
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const a = this.a;
    const [B, L] = x.shape as [number, number, number];

    let q: MlxArray, k: MlxArray, v: MlxArray;
    if (this.qkvProj) {
      // phi3: fused projection, split as ACTIVATIONS (mx.split) like mlx-lm.
      const qkv = this.qkvProj.forward(x);
      const queryPos = a.numHeads * a.headDim;
      const parts = ops.split(qkv, [queryPos, queryPos + a.numKvHeads * a.headDim], -1);
      qkv.dispose();
      [q, k, v] = parts as [MlxArray, MlxArray, MlxArray];
    } else {
      q = this.qProj!.forward(x);
      k = this.kProj!.forward(x);
      v = this.vProj!.forward(x);
    }

    if (a.qkNorm === "full") {
      // olmo2: norm the FLAT projections before any reshape.
      q = disposing(q, this.qNorm!.forward(q));
      k = disposing(k, this.kNorm!.forward(k));
    }

    q = disposing(q, ops.reshape(q, [B, L, a.numHeads, -1]));
    k = disposing(k, ops.reshape(k, [B, L, a.numKvHeads, -1]));
    v = disposing(v, ops.reshape(v, [B, L, a.numKvHeads, -1]));

    if (a.qkNorm === "head") {
      // qwen3: per-head norm over head_dim, BEFORE transpose + rope.
      q = disposing(q, this.qNorm!.forward(q));
      k = disposing(k, this.kNorm!.forward(k));
    }

    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    q = disposing(q, this.rope.apply(q, cache.offset));
    k = disposing(k, this.rope.apply(k, cache.offset));

    const [keys, values] = cache.updateAndFetch(k, v);
    k.dispose();
    v.dispose();

    let attn: MlxArray;
    if (a.attnLogitSoftcap !== null) {
      attn = this.#softcapAttention(q, keys, values, mask, B, L);
    } else {
      attn = ops.sdpa(q, keys, values, a.attnScale, mask.mode, mask.arr);
    }
    keys.dispose();
    values.dispose();
    q.dispose();

    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.oProj.forward(merged);
    merged.dispose();
    return out;
  }

  /** gemma2.py manual attention: scale → GQA 5-d reshape → q·kᵀ →
   *  tanh-softcap → bool-mask via where(finfo.min) → precise softmax → ·v.
   *  ops.sdpa can't express the score softcap. */
  #softcapAttention(
    q: MlxArray, keys: MlxArray, values: MlxArray, mask: Mask, B: number, L: number,
  ): MlxArray {
    const a = this.a;
    const repeats = Math.floor(a.numHeads / a.numKvHeads);
    let queries = ops.mulScalar(q, a.attnScale); // queries * self.scale

    let kk = keys;
    let vv = values;
    let kExp: MlxArray | null = null;
    let vExp: MlxArray | null = null;
    if (repeats > 1) {
      queries = disposing(queries, ops.reshape(queries, [B, a.numKvHeads, repeats, L, a.headDim]));
      kExp = ops.expandDims(keys, 2);
      vExp = ops.expandDims(values, 2);
      kk = kExp;
      vv = vExp;
    }

    const kT = ops.transposeAxes(kk, repeats > 1 ? [0, 1, 2, 4, 3] : [0, 1, 3, 2]);
    let scores = ops.matmul(queries, kT);
    kT.dispose();
    queries.dispose();

    // tanh(scores / cap) * cap — same composition as logitSoftcap.
    scores = disposing(scores, logitSoftcap(scores, a.attnLogitSoftcap!));

    if (mask.mode === "array" && mask.arr) {
      // bool mask: where(mask, scores, finfo(scores.dtype).min)
      const minVal = FINFO_MIN[scores.dtype];
      if (minVal === undefined) throw new Error(`no finfo.min for dtype ${scores.dtypeName}`);
      const minArr = ops.scalarLike(minVal, scores);
      scores = disposing(scores, ops.where(mask.arr, scores, minArr));
      minArr.dispose();
    }

    scores = disposing(scores, ops.softmaxAxis(scores, -1, true));
    let out = ops.matmul(scores, vv);
    scores.dispose();
    kExp?.dispose();
    vExp?.dispose();
    if (repeats > 1) out = disposing(out, ops.reshape(out, [B, a.numHeads, L, a.headDim]));
    return out;
  }
}

class UniversalMLP {
  readonly gate: AnyLinear | null;
  readonly up: AnyLinear | null;
  readonly gateUp: AnyLinear | null;
  readonly down: AnyLinear;

  constructor(
    weights: Weights,
    config: ModelConfig,
    prefix: string,
    readonly kind: UniversalArgs["mlp"],
    audit: WeightAudit,
  ) {
    if (kind === "fused_swiglu") {
      this.gateUp = loadLinear(weights, `${prefix}.gate_up_proj`, config, audit);
      this.gate = this.up = null;
      this.down = loadLinear(weights, `${prefix}.down_proj`, config, audit);
    } else if (kind === "gelu_mlp") {
      // starcoder2: c_fc → gelu(precise) → c_proj
      this.gate = loadLinear(weights, `${prefix}.c_fc`, config, audit);
      this.up = this.gateUp = null;
      this.down = loadLinear(weights, `${prefix}.c_proj`, config, audit);
    } else {
      this.gate = loadLinear(weights, `${prefix}.gate_proj`, config, audit);
      this.up = loadLinear(weights, `${prefix}.up_proj`, config, audit);
      this.gateUp = null;
      this.down = loadLinear(weights, `${prefix}.down_proj`, config, audit);
    }
  }

  forward(x: MlxArray): MlxArray {
    if (this.kind === "gelu_mlp") {
      const h = this.gate!.forward(x);
      const g = ops.geluPrecise(h);
      h.dispose();
      const out = this.down.forward(g);
      g.dispose();
      return out;
    }

    let gate: MlxArray;
    let up: MlxArray;
    if (this.kind === "fused_swiglu") {
      const gu = this.gateUp!.forward(x);
      const half = Math.floor(gu.shape[gu.shape.length - 1]! / 2);
      const parts = ops.split(gu, [half], -1); // mx.split(x, 2, axis=-1)
      gu.dispose();
      [gate, up] = parts as [MlxArray, MlxArray];
    } else {
      gate = this.gate!.forward(x);
      up = this.up!.forward(x);
    }

    let act: MlxArray;
    if (this.kind === "geglu") {
      act = ops.geluPrecise(gate); // gemma-1: nn.gelu (erf)
    } else if (this.kind === "geglu_approx") {
      act = ops.geluApprox(gate); // gemma2: nn.gelu_approx
    } else {
      // swiglu — the L1-verified uncompiled composition (minicpm5/qwen3):
      const sig = ops.sigmoid(gate);
      act = ops.mul(gate, sig);
      sig.dispose();
    }
    gate.dispose();
    const hidden = ops.mul(act, up);
    act.dispose();
    up.dispose();
    const out = this.down.forward(hidden);
    hidden.dispose();
    return out;
  }
}

class UniversalLayer {
  readonly attn: UniversalAttention;
  readonly mlp: UniversalMLP;
  /** pre/gemma2/glm4: input_layernorm. post (olmo2): unused (null). */
  readonly inputNorm: AnyNorm | null;
  /** pre: post_attention_layernorm (pre-MLP). post: post_attention (on
   *  attn out). gemma2: post_attention (on attn out). glm4:
   *  post_attention (pre-MLP). */
  readonly postAttnNorm: AnyNorm;
  /** gemma2: pre_feedforward. glm4: post_self_attn (on attn out). */
  readonly extraNorm1: AnyNorm | null;
  /** gemma2: post_feedforward. glm4: post_mlp. post: post_feedforward. */
  readonly extraNorm2: AnyNorm | null;

  constructor(
    weights: Weights,
    config: ModelConfig,
    prefix: string,
    readonly a: UniversalArgs,
    rope: UniversalRope,
    audit: WeightAudit,
  ) {
    this.attn = new UniversalAttention(weights, config, `${prefix}.self_attn`, a, rope, audit);
    this.mlp = new UniversalMLP(weights, config, `${prefix}.mlp`, a.mlp, audit);
    const norm = (name: string): AnyNorm =>
      a.norm === "layernorm"
        ? loadLayerNorm(weights, `${prefix}.${name}`, a.normEps, audit)
        : loadRmsNorm(weights, `${prefix}.${name}`, a.normEps, a.norm === "rmsnorm_plus_one", audit);

    this.postAttnNorm = norm("post_attention_layernorm");
    if (a.block === "post") {
      this.inputNorm = null;
      this.extraNorm1 = null;
      this.extraNorm2 = norm("post_feedforward_layernorm");
    } else if (a.block === "gemma2") {
      this.inputNorm = norm("input_layernorm");
      this.extraNorm1 = norm("pre_feedforward_layernorm");
      this.extraNorm2 = norm("post_feedforward_layernorm");
    } else if (a.block === "glm4") {
      this.inputNorm = norm("input_layernorm");
      this.extraNorm1 = norm("post_self_attn_layernorm");
      this.extraNorm2 = norm("post_mlp_layernorm");
    } else {
      this.inputNorm = norm("input_layernorm");
      this.extraNorm1 = null;
      this.extraNorm2 = null;
    }
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const a = this.a;
    if (a.block === "post") {
      // olmo2: h = x + norm(attn(x)); out = h + norm(mlp(h))
      const r1 = this.attn.forward(x, mask, cache);
      const n1 = disposing(r1, this.postAttnNorm.forward(r1));
      const h = ops.add(x, n1);
      n1.dispose();
      const r2 = this.mlp.forward(h);
      const n2 = disposing(r2, this.extraNorm2!.forward(r2));
      const out = ops.add(h, n2);
      h.dispose();
      n2.dispose();
      return out;
    }
    if (a.block === "gemma2") {
      // h = x + postAttn(attn(inputNorm(x))); out = h + postFfn(mlp(preFfn(h)))
      const xn = this.inputNorm!.forward(x);
      const r1 = this.attn.forward(xn, mask, cache);
      xn.dispose();
      const n1 = disposing(r1, this.postAttnNorm.forward(r1));
      const h = ops.add(x, n1);
      n1.dispose();
      const fn = this.extraNorm1!.forward(h);
      const r2 = this.mlp.forward(fn);
      fn.dispose();
      const n2 = disposing(r2, this.extraNorm2!.forward(r2));
      const out = ops.add(h, n2);
      h.dispose();
      n2.dispose();
      return out;
    }
    if (a.block === "glm4") {
      // x1 = x + postSelfAttn(attn(inputNorm(x)));
      // out = postMlp(mlp(postAttn(x1))) + x1
      const xn = this.inputNorm!.forward(x);
      const r1 = this.attn.forward(xn, mask, cache);
      xn.dispose();
      const n1 = disposing(r1, this.extraNorm1!.forward(r1));
      const x1 = ops.add(x, n1);
      n1.dispose();
      const pn = this.postAttnNorm.forward(x1);
      const r2 = this.mlp.forward(pn);
      pn.dispose();
      const n2 = disposing(r2, this.extraNorm2!.forward(r2));
      const out = ops.add(n2, x1);
      n2.dispose();
      x1.dispose();
      return out;
    }
    // pre (llama family): h = x + r·mult; out = h + r·mult
    const xn = this.inputNorm!.forward(x);
    let r1 = this.attn.forward(xn, mask, cache);
    xn.dispose();
    if (a.residualMultiplier !== null)
      r1 = disposing(r1, ops.mulScalar(r1, a.residualMultiplier));
    const h = ops.add(x, r1);
    r1.dispose();
    const hn = this.postAttnNorm.forward(h);
    let r2 = this.mlp.forward(hn);
    hn.dispose();
    if (a.residualMultiplier !== null)
      r2 = disposing(r2, ops.mulScalar(r2, a.residualMultiplier));
    const out = ops.add(h, r2);
    h.dispose();
    r2.dispose();
    return out;
  }
}

export class UniversalDenseModel {
  readonly config: ModelConfig;
  readonly args: UniversalArgs;
  readonly weightsBytes: number;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  readonly embed: AnyEmbedding;
  readonly layers: UniversalLayer[];
  readonly finalNorm: AnyNorm;
  readonly lmHead: AnyLinear | null;
  readonly sharedRope: UniversalRope;
  readonly ropes: UniversalRope[];

  constructor(weights: Weights, config: ModelConfig, args?: UniversalArgs) {
    const a = args ?? genericArgsFor(config);
    if (!a)
      throw new Error(`UniversalDenseModel: no descriptor for model_type ${config.modelType}`);
    this.config = config;
    this.args = a;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((acc, f) => acc + f.mmap.size, 0);

    const audit = new WeightAudit();
    this.embed = loadEmbedding(weights, "model.embed_tokens", config, audit);
    // One rope instance shared by every rope-bearing layer (identical
    // params ⇒ identical table); NoPE layers (smollm3) get the no-op.
    this.sharedRope = buildRope(a);
    const noRope = new NoRope();
    this.ropes = Array.from({ length: a.numHiddenLayers }, (_, i) =>
      a.noRopeLayers && a.noRopeLayers[i] === 0 ? noRope : this.sharedRope,
    );
    this.layers = Array.from(
      { length: a.numHiddenLayers },
      (_, i) => new UniversalLayer(weights, config, `model.layers.${i}`, a, this.ropes[i]!, audit),
    );
    this.finalNorm = a.norm === "layernorm"
      ? loadLayerNorm(weights, "model.norm", a.normEps, audit)
      : loadRmsNorm(weights, "model.norm", a.normEps, a.norm === "rmsnorm_plus_one", audit);
    this.lmHead = a.tieWordEmbeddings
      ? null
      : loadLinear(weights, "lm_head", config, audit);

    // Load-time weight audit: unconsumed tensors (outside the arch's
    // sanitize drops) are a LOAD ERROR, never a silently-wrong model.
    audit.finish(weights, a.dropWeightPatterns);
  }

  /** LoRA hot-swap targets — quantized linears only (dense checkpoints
   *  serve without adapter support at Tier-0). */
  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    const put = (path: string, lin: AnyLinear | null) => {
      if (lin instanceof QuantizedLinear) out.set(path, lin);
    };
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `model.layers.${i}`;
      put(`${p}.self_attn.q_proj`, l.attn.qProj);
      put(`${p}.self_attn.k_proj`, l.attn.kProj);
      put(`${p}.self_attn.v_proj`, l.attn.vProj);
      put(`${p}.self_attn.qkv_proj`, l.attn.qkvProj);
      put(`${p}.self_attn.o_proj`, l.attn.oProj);
      put(`${p}.mlp.gate_proj`, l.mlp.gate);
      put(`${p}.mlp.up_proj`, l.mlp.up);
      put(`${p}.mlp.gate_up_proj`, l.mlp.gateUp);
      put(`${p}.mlp.down_proj`, l.mlp.down);
    }
    return out;
  }

  makeCache(): Cache[] {
    const a = this.args;
    return Array.from({ length: a.numHiddenLayers }, (_, i) => {
      const sliding = a.layerTypes?.[i] === "sliding_attention" && a.slidingWindow;
      return sliding ? new RotatingKVCache(a.slidingWindow!) : new KVCache();
    });
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    let h = this.embed.encode(ids);
    if (this.args.embedMultiplier !== null)
      h = disposing(h, ops.mulScalar(h, this.args.embedMultiplier));
    return this.forwardLayers(h, cache);
  }

  forwardEmbeddings(_embeds: MlxArray, _cache: Cache[], _bidir: MlxArray | null): MlxArray {
    throw new Error("universal-dense input-embedding path is not supported");
  }

  protected forwardLayers(h0: MlxArray, cache: Cache[]): MlxArray {
    const a = this.args;
    const L = h0.shape[1]!;

    // Masks, mirroring the per-arch mlx-lm model __call__:
    let faMask: Mask;
    let swaMask: Mask | null = null;
    if (a.maskArray) {
      // gemma2: create_attention_mask(h, cache[0], return_array=True)
      faMask = L === 1
        ? { mode: "", arr: null }
        : { mode: "array", arr: createCausalMask(L, cache[0]!.offset, null) };
    } else if (a.layerTypes && a.layerTypes.includes("sliding_attention")) {
      // llama.py: fa mask from the first full layer, swa mask (windowed)
      // from the first sliding layer.
      const faIdx = a.layerTypes.indexOf("full_attention");
      const swaIdx = a.layerTypes.indexOf("sliding_attention");
      faMask = cache[faIdx === -1 ? 0 : faIdx]!.makeMask(L, null);
      swaMask = cache[swaIdx]!.makeMask(L, a.slidingWindow);
    } else {
      faMask = cache[0]!.makeMask(L, null);
    }

    let cur = h0;
    for (let i = 0; i < this.layers.length; i++) {
      const mask = a.layerTypes?.[i] === "sliding_attention" && swaMask ? swaMask : faMask;
      const next = this.layers[i]!.forward(cur, mask, cache[i]!);
      cur.dispose();
      cur = next;
    }
    faMask.arr?.dispose();
    swaMask?.arr?.dispose();
    return disposing(cur, this.finalNorm.forward(cur));
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    let logits = this.lmHead ? this.lmHead.forward(h) : this.embed.asLinear(h);
    if (this.args.finalLogitSoftcap !== null)
      logits = disposing(logits, logitSoftcap(logits, this.args.finalLogitSoftcap));
    if (this.args.logitsDivisor !== null) {
      const d = ops.scalarLike(this.args.logitsDivisor, logits);
      logits = disposing(logits, ops.div(logits, d));
      d.dispose();
    }
    return logits;
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
