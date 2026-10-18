import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Universal.Blocks
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/universal/blocks.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { WeightAudit } from "../../artifacts/weight-audit";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../../contracts/mlx/cache";
import type { TrellisRepresentations } from "../../kernels/trellis/index";
import { disposing } from "../../layers/helpers";
import { QuantizedLinear, QuantizedLinearPlain } from "../../layers/quantized-linear";
import { TrellisLinear } from "../../layers/trellis-linear";
import { TrellisReducePrompt, TrellisScatterPrompt, TrellisExpandReducePrompt, TrellisExpandScatterPrompt, type RowProjection } from "../../layers/trellis-prompt";
import { RMSNorm } from "../../layers/normalization";
import { compiledSwiglu } from "../../layers/swiglu";
import { initializeRope, phi3SuRope, UniversalRope } from "../../layers/rope";
import { loadLayerNorm, loadLinear, loadRmsNorm, type AnyLinear, type AnyNorm } from "../../layers/loading";
import { softcapAttentionReads } from "../../state/softcap-attention";
import { cleanupFailure } from "../../runtime/resources";
import type { ReadPhase } from "../graph";
import type { AttentionReadStrategy } from "../qwen/blocks";
import type { UniversalArgs } from "./archs";

/** The score-softcapped read as a block's read strategy: decode reads
 * `appendDecode`, a window `appendWindow`; this graph has no committed append
 * (its `appendKnown` is the window read), so a committed span reads as a window. */
export function softcapRead(softcap: number, window: number | null, arrayMasks: boolean): AttentionReadStrategy {
  const reads = softcapAttentionReads(softcap, window, arrayMasks);
  const byPhase: Readonly<Record<ReadPhase, typeof reads.appendDecode>> = {
    decode: reads.appendDecode, window: reads.appendWindow, committed: reads.appendWindow,
  };
  return Object.freeze({ read: (cache: Cache, phase: ReadPhase, k: MlxArray, v: MlxArray) => byPhase[phase](cache, k, v) });
}

/** Adapter carriers retain the artifact projection payload and dimensions. */
function adapterTarget(_weights: Weights, _config: ModelConfig, _path: string, linear: AnyLinear): QuantizedLinear | TrellisLinear | null {
  return linear instanceof QuantizedLinear || linear instanceof TrellisLinear ? linear : null;
}

export function stockProjection(base: AnyLinear): RowProjection {
  return base instanceof QuantizedLinear ? new QuantizedLinearPlain(base) : base;
}
export function packedProjection(base: TrellisLinear): RowProjection {
  return base.geometry.axis === 1 ? new TrellisReducePrompt(base) : new TrellisScatterPrompt(base);
}
export function expandedProjection(base: TrellisLinear): RowProjection {
  return base.geometry.axis === 1 ? new TrellisExpandReducePrompt(base) : new TrellisExpandScatterPrompt(base);
}

// Read exact MLX dtype metadata at load. These lazy probes never evaluate or
// allocate an expanded weight; owning norms, ropes and payloads are reused.
export function normType(norm: AnyNorm | null, dtype: Dtype, width: number): Dtype {
  if (!norm) return dtype;
  using x = ops.zeros([1, width], dtype), out = norm.forward(x); return out.dtype;
}
function linearType(base: AnyLinear, dtype: Dtype): Dtype {
  if (base instanceof TrellisLinear) return dtype;
  using x = ops.zeros([1, base.inFeatures], dtype), out = stockProjection(base).forward(x); return out.dtype;
}
function promotedType(a: Dtype, b: Dtype): Dtype {
  using x = ops.zeros([1], a), y = ops.zeros([1], b), out = ops.add(x,y); return out.dtype;
}
export function projectionFacts(layers: readonly UniversalLayer[], input: Dtype, width: number): {types: Map<AnyLinear,Dtype>; output: Dtype} {
  const types = new Map<AnyLinear,Dtype>();
  const linear = (base: AnyLinear, dtype: Dtype) => { types.set(base,dtype); return linearType(base,dtype); };
  let current = input;
  for (const layer of layers) {
    const a = layer.a, attn = layer.attn, mlp = layer.mlp;
    const xn = a.block === "post" ? current : normType(layer.inputNorm,current,width);
    let q: Dtype, k: Dtype, v: Dtype;
    if (attn.qkvProj) q = k = v = linear(attn.qkvProj,xn);
    else { q = linear(attn.qProj!,xn); k = linear(attn.kProj!,xn); v = linear(attn.vProj!,xn); }
    q = normType(attn.qNorm,q,a.qkNorm === "full" ? a.numHeads*a.headDim : a.headDim);
    k = normType(attn.kNorm,k,a.qkNorm === "full" ? a.numKvHeads*a.headDim : a.headDim);
    let attended: Dtype;
    if (attn.softcap !== null) attended = promotedType(promotedType(q,k),v);
    else {
      using qq=ops.zeros([1,a.numHeads,1,a.headDim],q), kk=ops.zeros([1,a.numKvHeads,1,a.headDim],k), vv=ops.zeros([1,a.numKvHeads,1,a.headDim],v);
      using out=ops.sdpa(qq,kk,vv,a.attnScale,"causal"); attended=out.dtype;
    }
    let r = linear(attn.oProj,attended);
    if (a.block === "post" || a.block === "gemma2") r = normType(layer.postAttnNorm,r,width);
    else if (a.block === "glm4") r = normType(layer.extraNorm1,r,width);
    const h = promotedType(current,r);
    const hn = a.block === "post" ? h : normType(a.block === "gemma2" ? layer.extraNorm1 : layer.postAttnNorm,h,width);
    let mid: Dtype;
    if (mlp.gateUp) mid=linear(mlp.gateUp,hn);
    else {
      const gate=linear(mlp.gate!,hn);
      mid=mlp.up ? promotedType(gate,linear(mlp.up,hn)) : gate;
    }
    let out = linear(mlp.down,mid);
    if (a.block === "post" || a.block === "gemma2" || a.block === "glm4") out=normType(layer.extraNorm2,out,width);
    current=promotedType(h,out);
  }
  return {types,output:current};
}

/** Rope for one attention module, per the descriptor (llama's
 *  initialize_rope, the plain-nn.RoPE archs, or phi3's Su/linear branch). */
export function buildRope(a: UniversalArgs): UniversalRope {
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

export class UniversalAttention {
  readonly qProj: AnyLinear | null;
  readonly kProj: AnyLinear | null;
  readonly vProj: AnyLinear | null;
  readonly qkvProj: AnyLinear | null;
  readonly oProj: AnyLinear;
  readonly qNorm: RMSNorm | null;
  readonly kNorm: RMSNorm | null;
  /** Bound at construction: the score softcap composes the manual attention
   * over dense K/V arrays (any storage, fetched dense) as this block's read;
   * without it, the block reads through the cache's own read, which also
   * attends encoded KV. */
  readonly softcap: number | null;
  /** The projections adapters mount on, read at load. */
  readonly adapters: { readonly q: QuantizedLinear | TrellisLinear | null; readonly k: QuantizedLinear | TrellisLinear | null;
    readonly v: QuantizedLinear | TrellisLinear | null; readonly qkv: QuantizedLinear | TrellisLinear | null; readonly o: QuantizedLinear | TrellisLinear | null };

  constructor(
    weights: Weights,
    config: ModelConfig,
    prefix: string,
    readonly a: UniversalArgs,
    readonly rope: UniversalRope,
    audit: WeightAudit,
    /** How the block reads its cache, composed by the graph from the descriptor. */
    readonly reads: AttentionReadStrategy,
    representations?: TrellisRepresentations,
  ) {
    this.softcap = a.attnLogitSoftcap;
    const load = (name: string) => loadLinear(weights, `${prefix}.${name}`, config, audit, representations);
    const target = (name: string, linear: AnyLinear | null) =>
      linear && adapterTarget(weights, config, `${prefix}.${name}`, linear);
    if (a.fusedQkv) {
      this.qkvProj = load("qkv_proj");
      this.qProj = this.kProj = this.vProj = null;
    } else {
      this.qProj = load("q_proj");
      this.kProj = load("k_proj");
      this.vProj = load("v_proj");
      this.qkvProj = null;
    }
    this.oProj = load("o_proj");
    this.adapters = Object.freeze({ q: target("q_proj", this.qProj), k: target("k_proj", this.kProj),
      v: target("v_proj", this.vProj), qkv: target("qkv_proj", this.qkvProj), o: target("o_proj", this.oProj) });
    if (a.qkNorm !== "none") {
      // qwen3 ("head"): RMSNorm(head_dim); olmo2 ("full"): RMSNorm(width) —
      // both live at q_norm/k_norm and use rms_norm_eps.
      this.qNorm = loadRmsNorm(weights, `${prefix}.q_norm`, a.normEps, false, audit);
      this.kNorm = loadRmsNorm(weights, `${prefix}.k_norm`, a.normEps, false, audit);
    } else {
      this.qNorm = this.kNorm = null;
    }
  }

  /** `x` [B, L, hidden] (borrowed) to an owned [B, L, hidden], appending to
   *  `cache` and attending through the read `phase` names. */
  forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
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

    // Batched decode: the scheduler's mask wrapper exposes each row's REAL
    // position as ropeOffsetArr (rows have different prompt lengths under
    // left-padding; the scalar offset would mis-position every padded row by
    // its pad amount — the 2026-07-03 uneven-batch bug). One row: the scalar
    // offset.
    const offArr = (cache as { ropeOffsetArr?: MlxArray }).ropeOffsetArr;
    q = disposing(q, offArr
      ? this.rope.applyDynamic(q, offArr)
      : this.rope.apply(q, cache.offset));
    k = disposing(k, offArr
      ? this.rope.applyDynamic(k, offArr)
      : this.rope.apply(k, cache.offset));

    // The read holds its mask: a failed release keeps the attention output
    // from leaking, and an attention failure stays the primary error.
    let attn: MlxArray;
    try {
      const read = this.reads.read(cache, phase, k, v);
      try { attn = read.attend(q, a.attnScale); }
      catch (error) { return cleanupFailure(error, () => read.dispose()); }
      try { read.dispose(); }
      catch (error) { return cleanupFailure(error, () => attn.dispose()); }
    } finally { k.dispose(); v.dispose(); q.dispose(); }

    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const out = this.oProj.forward(merged);
    merged.dispose();
    return out;
  }
}

/** swiglu(gate, up) = nn.silu(gate) * up as ONE call — the whole activation,
 *  not just silu. Defaults to the `@mx.compile` version (compiledSwiglu) — the
 *  same libmlx kernel mlx-lm dispatches (L1-faithful), bit-identical to the old
 *  uncompiled composition but one dispatch instead of three. Set to null to force
 *  the uncompiled path (the slower same-parity opt-in). */
export type SwigluFn = (gate: MlxArray, up: MlxArray) => MlxArray;

export class UniversalMLP {
  readonly gate: AnyLinear | null;
  readonly up: AnyLinear | null;
  readonly gateUp: AnyLinear | null;
  readonly down: AnyLinear;
  /** Fused swiglu (silu(gate)*up), default = the oracle's `@mx.compile` closure.
   *  Only consumed for the swiglu / fused_swiglu kinds; geglu/geglu_approx/gelu_mlp
   *  are unaffected (the oracle does NOT @mx.compile those — gemma/gemma2/starcoder2
   *  use a plain nn.gelu composition). Set to null for the uncompiled composition. */
  swigluFn: SwigluFn | null = compiledSwiglu;
  /** The projections adapters mount on, read at load. */
  readonly adapters: { readonly gate: QuantizedLinear | TrellisLinear | null; readonly up: QuantizedLinear | TrellisLinear | null;
    readonly gateUp: QuantizedLinear | TrellisLinear | null; readonly down: QuantizedLinear | TrellisLinear | null };

  constructor(
    weights: Weights,
    config: ModelConfig,
    prefix: string,
    readonly kind: UniversalArgs["mlp"],
    audit: WeightAudit,
    representations?: TrellisRepresentations,
  ) {
    const load = (name: string) => loadLinear(weights, `${prefix}.${name}`, config, audit, representations);
    const target = (name: string, linear: AnyLinear) => adapterTarget(weights, config, `${prefix}.${name}`, linear);
    if (kind === "fused_swiglu") {
      this.gateUp = load("gate_up_proj");
      this.gate = this.up = null;
      this.down = load("down_proj");
      this.adapters = Object.freeze({ gate: null, up: null, gateUp: target("gate_up_proj", this.gateUp), down: target("down_proj", this.down) });
    } else if (kind === "gelu_mlp") {
      // starcoder2: c_fc → gelu(precise) → c_proj
      this.gate = load("c_fc");
      this.up = this.gateUp = null;
      this.down = load("c_proj");
      this.adapters = Object.freeze({ gate: target("c_fc", this.gate), up: null, gateUp: null, down: target("c_proj", this.down) });
    } else {
      this.gate = load("gate_proj");
      this.up = load("up_proj");
      this.gateUp = null;
      this.down = load("down_proj");
      this.adapters = Object.freeze({ gate: target("gate_proj", this.gate), up: target("up_proj", this.up), gateUp: null,
        down: target("down_proj", this.down) });
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

    // swiglu / fused_swiglu run silu(gate)*up as ONE fused call (mlx-lm's
    // `@mx.compile swiglu`), matching the oracle kernel set exactly. This is the
    // default (swigluFn = compiledSwiglu); null forces the uncompiled composition.
    if (this.swigluFn && (this.kind === "swiglu" || this.kind === "fused_swiglu")) {
      const hidden = this.swigluFn(gate, up);
      gate.dispose();
      up.dispose();
      const out = this.down.forward(hidden);
      hidden.dispose();
      return out;
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

export class UniversalLayer {
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
    reads: AttentionReadStrategy,
    representations?: TrellisRepresentations,
  ) {
    this.attn = new UniversalAttention(weights, config, `${prefix}.self_attn`, a, rope, audit, reads, representations);
    this.mlp = new UniversalMLP(weights, config, `${prefix}.mlp`, a.mlp, audit, representations);
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

  forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    const a = this.a;
    if (a.block === "post") {
      // olmo2: h = x + norm(attn(x)); out = h + norm(mlp(h))
      const r1 = this.attn.forward(x, cache, phase);
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
      const r1 = this.attn.forward(xn, cache, phase);
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
      const r1 = this.attn.forward(xn, cache, phase);
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
    let r1 = this.attn.forward(xn, cache, phase);
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

"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Universal.Blocks
