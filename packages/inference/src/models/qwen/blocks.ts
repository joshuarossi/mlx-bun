// The Qwen 3.5 decoder blocks (port target: mlx_lm.models.qwen3_5 and the
// qwen3_next Attention/MLP/RMSNormGated it reuses): the gated DeltaNet block,
// the gated full-attention block, the two MLP blocks and the layer composing
// them. Each block is built once from the weights and the quant table and reads
// its state through the cache contract for the phase its caller names
// (`ReadPhase`). No block inspects its input to choose a phase, builds a mask
// or chooses an attention kernel: the cache was composed with its read.

import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import type { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { TrellisLinear, fusedGateUpEligible, fusedGateUpSwiglu } from "../../layers/trellis-linear";
import { disposing } from "../../layers/helpers";
import { compiledSwiglu } from "../../layers/swiglu";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { RMSNorm } from "../../layers/normalization";
import { CompiledGatedRMSNorm, CompiledResidualRMSNorm } from "../../layers/compiled-normalization";
import { CompiledSiluRMSHeads } from "../../layers/delta-heads";
import type { AttentionRead, Cache, CommittedAttentionCache, GatedDeltaCache, GatedDeltaHeads, GatedDeltaParameters } from "../../contracts/mlx/cache";
import { applyInterleavedRope } from "../../layers/qwen-mrope";
import type { MropeForwardState } from "../../contracts/mlx/positions";
import type { ReadPhase } from "../graph";

const PREFIX = "language_model";

/** The attention read each phase names. A committed span reads through
 * `appendCommitted`, so the cache must be composed for committed appends. */
const appendFor: Readonly<Record<ReadPhase, (cache: Cache, k: MlxArray, v: MlxArray) => AttentionRead>> = {
  decode: (cache, k, v) => (cache as CommittedAttentionCache).appendDecode(k, v),
  window: (cache, k, v) => (cache as CommittedAttentionCache).appendWindow(k, v),
  committed: (cache, k, v) => (cache as CommittedAttentionCache).appendCommitted(k, v),
};

/** The recurrence each phase names. A committed span is a window for the
 * recurrence. */
const recurFor: Readonly<Record<ReadPhase,
  (cache: GatedDeltaCache, qkv: MlxArray, a: MlxArray, b: MlxArray, layer: GatedDeltaParameters) => MlxArray>> = {
  decode: (cache, qkv, a, b, layer) => cache.recurDecode(qkv, a, b, layer),
  window: (cache, qkv, a, b, layer) => cache.recurWindow(qkv, a, b, layer),
  committed: (cache, qkv, a, b, layer) => cache.recurWindow(qkv, a, b, layer),
};

/** The projection arithmetic each phase names. A committed span projects each
 * position with one-row arithmetic (`QuantizedLinear`'s independent rows), the
 * bits of appending the span one token at a time; decode and window rows share
 * one matmul. */
const projectRowsApart: Readonly<Record<ReadPhase, boolean>> = { decode: false, window: false, committed: true };

// ── Compiled activations ─────────────────────────────────────────────────────
// The oracle (mlx_lm/models/activations.py + qwen3_next.py) wraps BOTH swiglu
// activations in `@partial(mx.compile, shapeless=True)`. We match it: every
// activation site below (the MLP swiglu, the RMSNormGated `_precise_swiglu`, and
// the conv `nn.silu`) runs through a compiled closure unconditionally, so the
// dispatched kernel set matches the oracle op-for-op (= mlx-lm, bit-exact). Traced
// once (shapeless), replayed thereafter; autograd-safe (mx.compile threads VJP
// through the traced graph). `compiledSwiglu` lives in layers/swiglu.

/** qwen3_next.py `_precise_swiglu(h, gate, x)`:
 *    gate = nn.silu(gate.astype(f32)); x = x.astype(f32); (gate*x).astype(h.dtype)
 *  Used by Qwen3NextRMSNormGated. Inputs: (h=hidden for the out dtype, gate=z,
 *  x=rms_norm(hidden)). mx.compile fuses the two casts + silu + mul + cast. */
let _preciseSwigluClosure: CompiledFunction | null = null;
export function compiledPreciseSwiglu(h: MlxArray, gate: MlxArray, x: MlxArray): MlxArray {
  if (!_preciseSwigluClosure) {
    _preciseSwigluClosure = new CompiledFunction((inputs) => {
      const hh = inputs[0]!, g = inputs[1]!, xx = inputs[2]!;
      const gf = g.astype(Dtype.float32);
      const sig = ops.sigmoid(gf);
      const silu = ops.mul(gf, sig); gf.dispose(); sig.dispose();
      const xf = xx.astype(Dtype.float32);
      const prod = ops.mul(silu, xf); silu.dispose(); xf.dispose();
      const out = prod.astype(hh.dtype); prod.dispose();
      return [out];
    });
  }
  return _preciseSwigluClosure.apply([h, gate, x])[0]!;
}

/** mlx.nn.silu is `@partial(mx.compile, shapeless=True) def silu(x): x*sigmoid(x)`
 *  — a COMPILED kernel, not a standalone sigmoid+mul. Used for the conv
 *  activation `nn.silu(conv1d(...))`, matching mlx-lm's fused BV2ISigmoid…_V_. */
let _siluClosure: CompiledFunction | null = null;
export function compiledSilu(x: MlxArray): MlxArray {
  if (!_siluClosure) {
    _siluClosure = new CompiledFunction((inputs) => {
      const xx = inputs[0]!;
      const sig = ops.sigmoid(xx);
      const out = ops.mul(xx, sig); sig.dispose(); // x * sigmoid(x)
      return [out];
    });
  }
  return _siluClosure.apply([x])[0]!;
}

// NOTE: the attention output gate is `self.o_proj(output * mx.sigmoid(gate))`
// INLINE in mlx-lm (qwen3_next.py) — NOT @mx.compile. It is intentionally kept
// as a standalone sigmoid + multiply in Qwen3Attention.forward so the dispatched
// kernel set matches the reference; there is no compiled-output-gate helper.

/** A projection the blocks can run: affine-quantized here, dense or quantized
 *  in the MTP companion. Only QuantizedLinear reads `independentRows`. */
export interface AttentionLinear { forward(x: MlxArray, independentRows?: boolean): MlxArray }
export interface QwenAttentionProjections<L extends AttentionLinear> {
  readonly qProj: L; readonly kProj: L; readonly vProj: L; readonly oProj: L;
}
export interface QwenDeltaProjections<L extends AttentionLinear> {
  readonly inProjQkv: L; readonly inProjZ: L; readonly inProjB: L; readonly inProjA: L; readonly outProj: L;
}
export type AttentionLinearLoader<L extends AttentionLinear> = (weights: Weights, path: string, config: ModelConfig) => L;

/** Gated-DeltaNet linear-attention block (mlx-lm GatedDeltaNet): projections,
 *  then the recurrence its cache runs (`GatedDeltaCache`), then the gated norm
 *  with z and the output projection. `loadLinear` chooses the projection layer
 *  (default QuantizedLinear); the graph is the same. */
export class GatedDeltaNet<L extends AttentionLinear = QuantizedLinear> {
  /** Per-model seam; null retains the oracle graph (weightless rms_norm, then a
   *  scalar multiply). When set, the scale rides in as the norm's weight: MLX's
   *  kernel writes `w * T(x * inv)`, the same bf16 product, in one kernel. bf16 only. */
  qkScale: { readonly q: MlxArray; readonly k: MlxArray } | null = null;
  readonly inProjQkv: L;
  readonly inProjZ: L;
  readonly inProjB: L;
  readonly inProjA: L;
  readonly outProj: L;
  readonly convWeight: MlxArray;
  readonly aLog: MlxArray;
  readonly dtBias: MlxArray;
  readonly normWeight: MlxArray;
  readonly eps: number;
  readonly numKHeads: number;
  readonly numVHeads: number;
  readonly headKDim: number;
  readonly headVDim: number;
  readonly keyDim: number;
  readonly valueDim: number;
  readonly convKernel: number;
  /** What this block lends its recurrent cache on every call: its recurrence
   *  weights and the glue between the convolution and the recurrence. */
  readonly recurrence: GatedDeltaParameters;

  constructor(weights: Weights, config: ModelConfig, prefix: string,
    loadLinear: AttentionLinearLoader<L> = QuantizedLinear.load as unknown as AttentionLinearLoader<L>,
    projections?: QwenDeltaProjections<L>) {
    const t = config.text;
    this.numKHeads = t.linearNumKeyHeads;
    this.numVHeads = t.linearNumValueHeads;
    this.headKDim = t.linearKeyHeadDim;
    this.headVDim = t.linearValueHeadDim;
    this.keyDim = this.headKDim * this.numKHeads;
    this.valueDim = this.headVDim * this.numVHeads;
    this.convKernel = t.linearConvKernelDim;
    this.eps = t.rmsNormEps;
    this.inProjQkv = projections?.inProjQkv ?? loadLinear(weights, `${prefix}.in_proj_qkv`, config);
    this.inProjZ = projections?.inProjZ ?? loadLinear(weights, `${prefix}.in_proj_z`, config);
    this.inProjB = projections?.inProjB ?? loadLinear(weights, `${prefix}.in_proj_b`, config);
    this.inProjA = projections?.inProjA ?? loadLinear(weights, `${prefix}.in_proj_a`, config);
    this.outProj = projections?.outProj ?? loadLinear(weights, `${prefix}.out_proj`, config);
    this.convWeight = weights.tensor(`${prefix}.conv1d.weight`);
    this.aLog = weights.tensor(`${prefix}.A_log`);
    this.dtBias = weights.tensor(`${prefix}.dt_bias`);
    this.normWeight = weights.tensor(`${prefix}.norm.weight`);
    this.recurrence = Object.freeze({
      convWeight: this.convWeight, aLog: this.aLog, dtBias: this.dtBias,
      heads: (convolved: MlxArray) => this.heads(convolved),
    });
  }

  /** The glue between the convolution and the recurrence: silu, the split into
   *  q, k and v heads, and the q/k norms and scale (inv_scale = head_k_dim ** -0.5;
   *  q *= inv_scale², k *= inv_scale), folded into the norm weight when
   *  `qkScale` is set. Borrows `convolved`; the cache owns the heads. */
  protected heads(convolved: MlxArray): GatedDeltaHeads {
    const [B, S] = convolved.shape as [number, number, number];
    const convOut = compiledSilu(convolved);
    const [qFlat, kFlat, vFlat] = ops.split(
      convOut, [this.keyDim, 2 * this.keyDim], -1,
    ) as [MlxArray, MlxArray, MlxArray];
    convOut.dispose();
    let q = ops.reshape(qFlat, [B, S, this.numKHeads, this.headKDim]);
    qFlat.dispose();
    let k = ops.reshape(kFlat, [B, S, this.numKHeads, this.headKDim]);
    kFlat.dispose();
    const v = disposing(vFlat, ops.reshape(vFlat, [B, S, this.numVHeads, this.headVDim]));
    const invScale = Math.pow(this.headKDim, -0.5);
    const folded = this.qkScale && q.dtype === Dtype.bfloat16 ? this.qkScale : null;
    q = disposing(q, ops.rmsNorm(q, folded?.q ?? null, 1e-6));
    if (!folded) q = disposing(q, ops.mulScalar(q, invScale * invScale));
    k = disposing(k, ops.rmsNorm(k, folded?.k ?? null, 1e-6));
    if (!folded) k = disposing(k, ops.mulScalar(k, invScale));
    return { q, k, v };
  }

  /** `x` [B, S, hidden] (borrowed) to an owned [B, S, hidden], reading `cache`
   *  for `phase`. */
  forward(x: MlxArray, cache: GatedDeltaCache, phase: ReadPhase): MlxArray {
    const [B, S] = x.shape as [number, number, number];
    const rowsApart = projectRowsApart[phase];
    const prof = (globalThis as Record<string, unknown>).__deltaProf as
      Record<string, number>
      | undefined;

    const t0 = prof ? performance.now() : 0;
    const qkv = this.inProjQkv.forward(x, rowsApart); // [B,S,convDim]
    let z = this.inProjZ.forward(x, rowsApart);
    z = disposing(z, ops.reshape(z, [B, S, this.numVHeads, this.headVDim]));
    const b = this.inProjB.forward(x, rowsApart); // [B,S,numVHeads]
    const a = this.inProjA.forward(x, rowsApart);
    if (prof) { ops.evalAll([qkv, z, b, a]); prof.proj = (prof.proj ?? 0) + performance.now() - t0; }
    const tr = prof ? performance.now() : 0;

    // The cache consumes qkv, a and b: convolution, glue and recurrence.
    const out = recurFor[phase](cache, qkv, a, b, this.recurrence);
    if (prof) { ops.evalAll([out]); prof.recur = (prof.recur ?? 0) + performance.now() - tr; }
    const to = prof ? performance.now() : 0;

    // RMSNormGated: silu(z_f32) * rms_norm(out)_f32, cast back to out dtype.
    const gated = this.rmsNormGated(out, z);
    out.dispose();
    z.dispose();
    const merged = ops.reshape(gated, [B, S, this.valueDim]);
    gated.dispose();
    const result = this.outProj.forward(merged, rowsApart);
    merged.dispose();
    if (prof) { ops.evalAll([result]); prof.out = (prof.out ?? 0) + performance.now() - to; }
    return result;
  }

  protected rmsNormGated(hidden: MlxArray, gate: MlxArray): MlxArray {
    const xn = ops.rmsNorm(hidden, this.normWeight, this.eps); // bf16
    // Oracle: _precise_swiglu(hidden, gate, xn) — ALWAYS one @mx.compile kernel
    // (matches mlx-lm; no unfused silu+mul+cast).
    const res = compiledPreciseSwiglu(hidden, gate, xn);
    xn.dispose();
    return res;
  }
}

/** How an attention block reads its cache, fixed when the block is built.
 * `read` appends `k` and `v` (borrowed) for `phase` and returns the read the
 * block attends once and disposes. */
export interface AttentionReadStrategy {
  read(cache: Cache, phase: ReadPhase, k: MlxArray, v: MlxArray): AttentionRead;
}

/** The cache's own read for the phase: the default strategy. */
export const cacheRead: AttentionReadStrategy = Object.freeze({
  read: (cache: Cache, phase: ReadPhase, k: MlxArray, v: MlxArray) => appendFor[phase](cache, k, v),
});

/** Full (softmax) attention with output gate + q/k norm + partial RoPE.
 *  `loadLinear` chooses the projection type (the MTP companion loads dense or
 *  quantized heads); `reads` is how the block reads its cache (the cache's own
 *  read unless a graph injects its kernels). The graph itself is the same. */
export class Qwen3Attention<L extends AttentionLinear = QuantizedLinear> {
  readonly qProj: L;
  readonly kProj: L;
  readonly vProj: L;
  readonly oProj: L;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly scale: number;
  readonly ropeDims: number;
  readonly ropeBase: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string,
    // The default projection type L is QuantizedLinear (the loader's own type).
    loadLinear: AttentionLinearLoader<L> = QuantizedLinear.load as unknown as AttentionLinearLoader<L>,
    readonly reads: AttentionReadStrategy = cacheRead,
    projections?: QwenAttentionProjections<L>) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeDims = Math.trunc(this.headDim * t.partialRotaryFactor);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
    this.qProj = projections?.qProj ?? loadLinear(weights, `${prefix}.q_proj`, config);
    this.kProj = projections?.kProj ?? loadLinear(weights, `${prefix}.k_proj`, config);
    this.vProj = projections?.vProj ?? loadLinear(weights, `${prefix}.v_proj`, config);
    this.oProj = projections?.oProj ?? loadLinear(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
  }

  /** `x` [B, L, hidden] (borrowed) to an owned [B, L, hidden], appending to
   *  `cache` and attending through the read `phase` names. Media forwards
   *  supply their own positions in `mrope`. */
  forward(x: MlxArray, cache: Cache, phase: ReadPhase, mrope: MropeForwardState | null = null): MlxArray {
    return mrope ? this.forwardMedia(x, cache, phase, mrope) : this.forwardText(x, cache, phase);
  }

  forwardText(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    const offArr = cache.ropeOffsetArr;
    const position = offArr
      ? (value: MlxArray) => ops.ropeDynamic(value, this.ropeDims, this.ropeBase, offArr, null)
      : (value: MlxArray) => ops.rope(value, this.ropeDims, this.ropeBase, cache.offset, null);
    return this.forwardPositioned(x, cache, phase, position);
  }

  forwardMedia(x: MlxArray, cache: Cache, phase: ReadPhase, mrope: MropeForwardState): MlxArray {
    return this.forwardPositioned(x, cache, phase, value => applyInterleavedRope(value, mrope));
  }

  protected forwardPositioned(x: MlxArray, cache: Cache, phase: ReadPhase, position: (value: MlxArray) => MlxArray): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    const rowsApart = projectRowsApart[phase];
    // Diagnostic sub-phase timing (same switch as GatedDeltaNet): projections
    // and RoPE, cache append and attention, gated output. Barriers only when set.
    const prof = (globalThis as Record<string, unknown>).__deltaProf as Record<string, number> | undefined;
    let tp = prof ? performance.now() : 0;
    const lap = (key: string, arrays: MlxArray[]) => {
      if (!prof) return;
      ops.evalAll(arrays);
      const now = performance.now();
      prof[key] = (prof[key] ?? 0) + now - tp;
      tp = now;
    };

    // q_proj emits 2× head_dim per head → split into queries + gate.
    const qp = this.qProj.forward(x, rowsApart);
    const qpr = disposing(qp, ops.reshape(qp, [B, L, this.nHeads, this.headDim * 2]));
    const [qHeads, gateHeads] = ops.split(qpr, [this.headDim], -1) as [MlxArray, MlxArray];
    qpr.dispose();
    const gate = disposing(gateHeads, ops.reshape(gateHeads, [B, L, this.nHeads * this.headDim]));

    let k = this.kProj.forward(x, rowsApart);
    let v = this.vProj.forward(x, rowsApart);

    // q/k norm over head_dim BEFORE transpose (reference order).
    let q = this.qNorm.forward(qHeads);
    qHeads.dispose();
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    k = disposing(k, this.kNorm.forward(k));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    // Batched decode: the row layout exposes each row's REAL position as
    // ropeOffsetArr (rows have different prompt lengths); the dynamic-offset
    // kernel is the same fast::rope, bit-exact vs the static form
    // (`02d723a:tests/unit/compile.test.ts`). Single rows: scalar offset.
    // Media forwards supply their own 3D interleaved positions. The reference
    // never uses the fused fast-rope kernel when position_ids are supplied,
    // so this IS the oracle's own arithmetic. Text-only stays on ops.rope.
    q = disposing(q, position(q));
    k = disposing(k, position(k));

    lap("attnProj", [q, k, v, gate]);
    const read = this.reads.read(cache, phase, k, v);
    k.dispose();
    v.dispose();
    let attn: MlxArray;
    try { attn = read.attend(q, this.scale); } finally { read.dispose(); }
    q.dispose();
    lap("attnSdpa", [attn]);

    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    // qwen3_next.py:158  return self.o_proj(output * mx.sigmoid(gate))
    // INLINE, not @mx.compile — copy the exact ops.
    const sig = ops.sigmoid(gate);
    gate.dispose();
    const gated = ops.mul(merged, sig);
    merged.dispose();
    sig.dispose();
    const out = this.oProj.forward(gated, rowsApart);
    gated.dispose();
    lap("attnOut", [out]);
    return out;
  }
}

/** Text positions are selected by the text phase, never by media state. */
export class Qwen3TextAttention<L extends AttentionLinear = QuantizedLinear> extends Qwen3Attention<L> {
  constructor(weights: Weights, config: ModelConfig, prefix: string, projections: QwenAttentionProjections<L>, reads: AttentionReadStrategy = cacheRead) {
    super(weights, config, prefix, undefined, reads, projections);
  }
  override forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    return this.forwardText(x, cache, phase);
  }
}

/** Media phases bind the interleaved positions variant explicitly. */
export class Qwen3MediaAttention<L extends AttentionLinear = QuantizedLinear> extends Qwen3Attention<L> {
  constructor(weights: Weights, config: ModelConfig, prefix: string, projections: QwenAttentionProjections<L>, reads: AttentionReadStrategy = cacheRead) {
    super(weights, config, prefix, undefined, reads, projections);
  }
  override forward(x: MlxArray, cache: Cache, phase: ReadPhase, mrope: MropeForwardState | null = null): MlxArray {
    return this.forwardMedia(x, cache, phase, mrope!);
  }
}

/** Recurrence block with every projection named at its call site. */
export class QwenGatedDeltaNet<L extends AttentionLinear = QuantizedLinear> extends GatedDeltaNet<L> {
  constructor(weights: Weights, config: ModelConfig, prefix: string, projections: QwenDeltaProjections<L>) {
    super(weights, config, prefix, undefined, projections);
  }
}

/** The same recurrence and projections with a fused normalization/gate tail. */
export class QwenFusedGatedDeltaNet<L extends AttentionLinear = QuantizedLinear> extends QwenGatedDeltaNet<L> {
  readonly #gatedNorm: CompiledGatedRMSNorm;
  constructor(weights: Weights, config: ModelConfig, prefix: string, projections: QwenDeltaProjections<L>) {
    super(weights, config, prefix, projections);
    this.#gatedNorm = new CompiledGatedRMSNorm(this.normWeight, this.eps);
  }
  protected override rmsNormGated(hidden: MlxArray, gate: MlxArray): MlxArray {
    return this.#gatedNorm.forward(hidden, gate);
  }
}

/** Fused convolution activation/Q/K norms as well as the normalization/gate tail. */
export class QwenFusedHeadsDeltaNet<L extends AttentionLinear = QuantizedLinear> extends QwenFusedGatedDeltaNet<L> {
  readonly #headOperation: CompiledSiluRMSHeads;
  constructor(weights: Weights, config: ModelConfig, prefix: string, projections: QwenDeltaProjections<L>) {
    super(weights, config, prefix, projections);
    this.#headOperation = new CompiledSiluRMSHeads(this.numKHeads, this.numVHeads, this.headVDim);
  }
  protected override heads(convolved: MlxArray): GatedDeltaHeads {
    if (!this.qkScale) throw new Error("QwenFusedHeadsDeltaNet requires folded Q/K scales");
    const [q, k, v] = this.#headOperation.forward(convolved, this.qkScale.q, this.qkScale.k);
    return { q, k, v };
  }
}

/** The width classes whose rows the fused Trellis gate/up kernel takes (up to `TRELLIS_MATVEC_MAX_M` rows). */
const FUSED_GATE_UP_WIDTHS: ReadonlySet<number> = new Set<number>([1, 2, 3, 4]);

/** The MLP over Trellis-coded projections (a packed-Trellis artifact's
 *  `mode: "trellis"` entries). Its input is the post-attention norm's output,
 *  which RMSNorm writes as a fresh aligned row-contiguous array: the gate and up
 *  projections take that layout as given, so the Trellis prefill matches the
 *  native small-prefill matmul without an evaluation. */
export class TrellisMlp {
  readonly kind = "trellis";
  /** Gate and up share the geometry the fused gate/up kernel takes. */
  readonly #fusedGateUp: boolean;

  constructor(readonly gate: TrellisLinear, readonly up: TrellisLinear, readonly down: TrellisLinear) {
    this.#fusedGateUp = fusedGateUpEligible(gate, up);
  }

  /** `x` [.., hidden] (borrowed, row-contiguous) to an owned [.., hidden].
   *  Every phase computes the same rows; `width` is the class of `x`'s rows,
   *  named by the caller. */
  forward(x: MlxArray, _phase: ReadPhase, width: number): MlxArray {
    // Packed-trellis decode (up to four rows): gate, up and the swiglu in ONE
    // kernel — x read once, no gate/up vectors materialized. This Lab path
    // retains the packed activation arithmetic documented in
    // `02d723a:docs/design/turboquant.md`.
    if (this.#fusedGateUp && FUSED_GATE_UP_WIDTHS.has(width)) {
      const hidden = fusedGateUpSwiglu(x, this.gate, this.up);
      const out = this.down.forward(hidden);
      hidden.dispose();
      return out;
    }
    const g = this.gate.forward(x, true);
    const u = this.up.forward(x, true);
    // Oracle: down_proj(swiglu(gate_proj(x), up_proj(x))) — swiglu ALWAYS compiled
    // (mlx-lm's @mx.compile swiglu; no unfused silu+mul, matches its kernel set).
    const hidden = compiledSwiglu(g, u);
    g.dispose();
    u.dispose();
    const out = this.down.forward(hidden);
    hidden.dispose();
    return out;
  }
}

/** The MLP over affine-quantized projections. */
export class AffineMlp {
  readonly kind = "affine";

  constructor(readonly gate: QuantizedLinear, readonly up: QuantizedLinear, readonly down: QuantizedLinear) {}

  /** `x` [.., hidden] (borrowed) to an owned [.., hidden], with the projection
   *  arithmetic `phase` names; every width class takes the same kernels. */
  forward(x: MlxArray, phase: ReadPhase, _width: number): MlxArray {
    const rowsApart = projectRowsApart[phase];
    const g = this.gate.forward(x, rowsApart);
    const u = this.up.forward(x, rowsApart);
    // Oracle: down_proj(swiglu(gate_proj(x), up_proj(x))) — swiglu ALWAYS compiled.
    const hidden = compiledSwiglu(g, u);
    g.dispose();
    u.dispose();
    const out = this.down.forward(hidden, rowsApart);
    hidden.dispose();
    return out;
  }
}

export type QwenMlp = TrellisMlp | AffineMlp;

/** The MLP block the written-down quant table names for `prefix`: Trellis when
 *  its gate, up and down entries are `mode: "trellis"`, affine when none is.
 *  A table that mixes the two in one MLP has no block here and is refused. */
export function loadQwenMlp(weights: Weights, config: ModelConfig, prefix: string, representations?: import("../../kernels/trellis/index").TrellisRepresentations): QwenMlp {
  const paths = [`${prefix}.gate_proj`, `${prefix}.up_proj`, `${prefix}.down_proj`] as const;
  const trellis = paths.map(path => TrellisLinear.isTrellis(config, path));
  if (trellis.every(Boolean)) {
    // M4 Pro measurements support the 27B down projection at M3/4. The
    // operation also checks variant, dtype and packed-code layout eligibility.
    const sharedScatterCodebook = config.text.hiddenSize === 5120 && config.text.intermediateSize === 17408;
    return new TrellisMlp(TrellisLinear.load(weights, paths[0], config, false, representations), TrellisLinear.load(weights, paths[1], config, false, representations),
      TrellisLinear.load(weights, paths[2], config, sharedScatterCodebook, representations));
  }
  if (!trellis.some(Boolean))
    return new AffineMlp(QuantizedLinear.load(weights, paths[0], config), QuantizedLinear.load(weights, paths[1], config),
      QuantizedLinear.load(weights, paths[2], config));
  throw new Error(`${prefix}: the quant table codes ${paths.filter((_, i) => trellis[i]).join(", ")} as Trellis and ` +
    "the rest affine; a Qwen 3.5 MLP block takes all three projections in one representation");
}

export class Qwen3Layer {
  readonly isLinear: boolean;
  readonly linearAttn: GatedDeltaNet | null = null;
  readonly selfAttn: Qwen3Attention | null = null;
  readonly mlp: QwenMlp;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, layerIdx: number, representations?: import("../../kernels/trellis/index").TrellisRepresentations) {
    const prefix = `${PREFIX}.model.layers.${layerIdx}`;
    this.isLinear = (layerIdx + 1) % config.text.fullAttentionInterval !== 0;
    if (this.isLinear)
      this.linearAttn = new GatedDeltaNet(weights, config, `${prefix}.linear_attn`);
    else this.selfAttn = new Qwen3Attention(weights, config, `${prefix}.self_attn`);
    this.mlp = loadQwenMlp(weights, config, `${prefix}.mlp`, representations);
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }

  /** One layer over `x` [.., hidden] (borrowed) for `phase`; `width` is the class of `x`'s rows, which picks the
   *  MLP's kernels. */
  forward(x: MlxArray, cache: Cache, phase: ReadPhase, mrope: MropeForwardState | null, width: number): MlxArray {
    using h = this.forwardAttn(x, cache, phase, mrope);
    return this.forwardMlp(h, phase, width);
  }

  forwardAttn(x: MlxArray, cache: Cache, phase: ReadPhase, mrope: MropeForwardState | null = null): MlxArray {
    using xn = this.inputNorm.forward(x);
    using r = this.isLinear
      ? this.linearAttn!.forward(xn, cache as GatedDeltaCache, phase)
      : this.selfAttn!.forward(xn, cache, phase, mrope);
    return ops.add(x, r);
  }

  forwardMlp(h: MlxArray, phase: ReadPhase, width: number): MlxArray {
    using hn = this.postAttnNorm.forward(h);
    // Diagnostic (same switch as the attention/DeltaNet sub-phases): settle the
    // pending attention block first so the MLP is timed alone.
    const prof = (globalThis as Record<string, unknown>).__deltaProf as Record<string, number> | undefined;
    let t0 = 0;
    if (prof) { ops.evalAll([hn]); t0 = performance.now(); }
    // RMSNorm allocates an aligned row-contiguous output, the layout the
    // Trellis MLP takes as given.
    using m = this.mlp.forward(hn, phase, width);
    if (prof) { ops.evalAll([m]); prof.mlp = (prof.mlp ?? 0) + performance.now() - t0; }
    return ops.add(h, m);
  }
}

/** A recurrent decoder layer whose mixer and MLP are named by its graph. */
export class QwenDeltaLayer {
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  constructor(weights: Weights, config: ModelConfig, prefix: string,
    readonly mixer: { forward(x: MlxArray, cache: GatedDeltaCache, phase: ReadPhase): MlxArray },
    readonly mlp: { forward(x: MlxArray): MlxArray }) {
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }
  forwardAttn(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    using normed = this.inputNorm.forward(x);
    using mixed = this.mixer.forward(normed, cache as GatedDeltaCache, phase);
    return ops.add(x, mixed);
  }
  forwardMlp(x: MlxArray): MlxArray {
    using normed = this.postAttnNorm.forward(x);
    using hidden = this.mlp.forward(normed);
    return ops.add(x, hidden);
  }
  forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    using hidden = this.forwardAttn(x, cache, phase);
    return this.forwardMlp(hidden);
  }
}

/** Full-attention decoder layer; text and media mixers are separate bindings. */
export class QwenAttentionLayer {
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  constructor(weights: Weights, config: ModelConfig, prefix: string,
    readonly mixer: { forward(x: MlxArray, cache: Cache, phase: ReadPhase, positions?: MropeForwardState | null): MlxArray },
    readonly mlp: { forward(x: MlxArray): MlxArray }) {
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }
  forwardAttn(x: MlxArray, cache: Cache, phase: ReadPhase, positions: MropeForwardState | null = null): MlxArray {
    using normed = this.inputNorm.forward(x);
    using mixed = this.mixer.forward(normed, cache, phase, positions);
    return ops.add(x, mixed);
  }
  forwardMlp(x: MlxArray): MlxArray {
    using normed = this.postAttnNorm.forward(x);
    using hidden = this.mlp.forward(normed);
    return ops.add(x, hidden);
  }
  forward(x: MlxArray, cache: Cache, phase: ReadPhase, positions: MropeForwardState | null = null): MlxArray {
    using hidden = this.forwardAttn(x, cache, phase, positions);
    return this.forwardMlp(hidden);
  }
}

/** A residual/normalization kernel between the recurrent mixer and its MLP. */
export class QwenResidualDeltaLayer extends QwenDeltaLayer {
  readonly #residualNorm: CompiledResidualRMSNorm;
  constructor(...args: ConstructorParameters<typeof QwenDeltaLayer>) {
    super(...args);
    this.#residualNorm = new CompiledResidualRMSNorm(this.postAttnNorm.weight!, this.postAttnNorm.eps);
  }
  override forward(x: MlxArray, cache: Cache, phase: ReadPhase): MlxArray {
    using normed = this.inputNorm.forward(x);
    using mixed = this.mixer.forward(normed, cache as GatedDeltaCache, phase);
    const [residual, normalized] = this.#residualNorm.forward(x, mixed);
    try {
      using hidden = this.mlp.forward(normalized);
      return ops.add(residual, hidden);
    } finally { residual.dispose(); normalized.dispose(); }
  }
}

/** The corresponding residual/normalization kernel after full attention. */
export class QwenResidualAttentionLayer extends QwenAttentionLayer {
  readonly #residualNorm: CompiledResidualRMSNorm;
  constructor(...args: ConstructorParameters<typeof QwenAttentionLayer>) {
    super(...args);
    this.#residualNorm = new CompiledResidualRMSNorm(this.postAttnNorm.weight!, this.postAttnNorm.eps);
  }
  override forward(x: MlxArray, cache: Cache, phase: ReadPhase, positions: MropeForwardState | null = null): MlxArray {
    using normed = this.inputNorm.forward(x);
    using mixed = this.mixer.forward(normed, cache, phase, positions);
    const [residual, normalized] = this.#residualNorm.forward(x, mixed);
    try {
      using hidden = this.mlp.forward(normalized);
      return ops.add(residual, hidden);
    } finally { residual.dispose(); normalized.dispose(); }
  }
}
