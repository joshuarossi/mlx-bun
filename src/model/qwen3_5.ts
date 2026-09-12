// Concrete model graph for Qwen3.5 hybrid models (e.g. Qwen3.6-27B-OptiQ-4bit).
// Port target: mlx_lm.models.qwen3_5 (+ qwen3_next Attention/MLP/RMSNormGated,
// gated_delta recurrence). The architecture is a 64-layer stack where every
// `fullAttentionInterval`-th layer is standard softmax attention and the rest
// are gated-DeltaNet linear-attention layers. Weights carry a
// `language_model.` prefix.
//
// Parity bars: bf16 KV → bit-exact vs mlx-lm; mixed-precision KV → bit-exact vs
// mlx-optiq (the 16 full-attention layers quantized per kv_config.json, via the
// shared maybeQuantizeKv path).

import type { ModelConfig } from "../config";
import { gatedDeltaState } from "./qwen3-delta-state";
import type { Weights } from "../weights";
import { runtimeFlag } from "../runtime-config";
import { mapTokenGroups, type TokenGroup } from "./token-groups";
import { MlxArray } from "../mlx/array";
import { Dtype, deviceArchitecture } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import { CompiledFunction } from "../mlx/compile";
import { qwenAppendChunkSize } from "./qwen-append";
import { TrellisLinear, fusedGateUpEligible, fusedGateUpSwiglu, TRELLIS_MATVEC_MAX_M } from "./trellis-linear";
import {
  argmaxLastPosition,
  disposeTriple,
  disposing,
  KVCache,
  LoraState,
  QuantizedEmbedding,
  QuantizedLinear,
  quantizedSdpa,
  RMSNorm,
  type Cache,
  type Mask,
} from "./gemma4-base";
import { qwen35WeightsView } from "./qwen3_5-checkpoint";
import { materializeCopy } from "../mlx/materialize";
import { gatedDeltaUpdate, SSMCache } from "./qwen3-delta";
import type { QwenConvolution } from "./qwen-conv";
import {
  activeMrope, applyInterleavedRope, buildMropePositions, mropeInvFreq,
  setActiveMrope, type MropeRequestState,
} from "./qwen3-mrope";

const PREFIX = "language_model";

// ── Compiled activations ─────────────────────────────────────────────────────
// The oracle (mlx_lm/models/activations.py + qwen3_next.py) wraps BOTH swiglu
// activations in `@partial(mx.compile, shapeless=True)`. We match it: every
// activation site below (the MLP swiglu, the RMSNormGated `_precise_swiglu`, and
// the conv `nn.silu`) runs through a compiled closure unconditionally, so the
// dispatched kernel set matches the oracle op-for-op (= mlx-lm, bit-exact). Traced
// once (shapeless), replayed thereafter; autograd-safe (mx.compile threads VJP
// through the traced graph). `compiledSwiglu` is exported so the parity test can
// assert the closure exists and the MLP actually uses it.

/** activations.py: `@mx.compile def swiglu(gate, x): return nn.silu(gate) * x`.
 *  nn.silu(g) == g * sigmoid(g); mx.compile fuses sigmoid+mul+mul → one kernel. */
let _swigluClosure: CompiledFunction | null = null;
export function compiledSwiglu(gate: MlxArray, up: MlxArray): MlxArray {
  if (!_swigluClosure) {
    _swigluClosure = new CompiledFunction((inputs) => {
      const g = inputs[0]!, u = inputs[1]!;
      const sig = ops.sigmoid(g);
      const silu = ops.mul(g, sig); sig.dispose();
      const out = ops.mul(silu, u); silu.dispose();
      return [out];
    });
  }
  return _swigluClosure.apply([gate, up])[0]!;
}

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

/** Gated-DeltaNet linear-attention layer (mlx-lm GatedDeltaNet). */
export class GatedDeltaNet {
  /** Per-model experiment seam; null retains the oracle graph. The same
   * implementation advances speculative rollback prefixes. Borrowed inputs,
   * owned activation and independent state tail; no global runtime mutation. */
  convolution: QwenConvolution | null = null;
  readonly inProjQkv: QuantizedLinear;
  readonly inProjZ: QuantizedLinear;
  readonly inProjB: QuantizedLinear;
  readonly inProjA: QuantizedLinear;
  readonly outProj: QuantizedLinear;
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

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.numKHeads = t.linearNumKeyHeads;
    this.numVHeads = t.linearNumValueHeads;
    this.headKDim = t.linearKeyHeadDim;
    this.headVDim = t.linearValueHeadDim;
    this.keyDim = this.headKDim * this.numKHeads;
    this.valueDim = this.headVDim * this.numVHeads;
    this.convKernel = t.linearConvKernelDim;
    this.eps = t.rmsNormEps;
    this.inProjQkv = QuantizedLinear.load(weights, `${prefix}.in_proj_qkv`, config);
    this.inProjZ = QuantizedLinear.load(weights, `${prefix}.in_proj_z`, config);
    this.inProjB = QuantizedLinear.load(weights, `${prefix}.in_proj_b`, config);
    this.inProjA = QuantizedLinear.load(weights, `${prefix}.in_proj_a`, config);
    this.outProj = QuantizedLinear.load(weights, `${prefix}.out_proj`, config);
    this.convWeight = weights.tensor(`${prefix}.conv1d.weight`);
    this.aLog = weights.tensor(`${prefix}.A_log`);
    this.dtBias = weights.tensor(`${prefix}.dt_bias`);
    this.normWeight = weights.tensor(`${prefix}.norm.weight`);
  }

  #convolve(qkv: MlxArray, state: MlxArray, rowLengths?: readonly number[]): [MlxArray, MlxArray] {
    if (this.convolution) {
      const result = this.convolution(qkv, state, this.convWeight);
      if (!rowLengths) return result;
      using input = ops.concatAxis([state, qkv], 1);
      const tail = this.#convTail(input, qkv.shape[1]!, rowLengths);
      result[1].dispose();
      return [result[0], tail];
    }
    const [, S, D] = qkv.shape as [number, number, number];
    const input = ops.concatAxis([state, qkv], 1);
    // MLX copy and contiguous can both alias the whole prefill buffer.
    // Materialize only the tail so cache residency follows its logical size.
    const tail = this.#convTail(input, S, rowLengths);
    const conv = ops.conv1d(input, this.convWeight, 1, 0, 1, D);
    input.dispose();
    const out = compiledSilu(conv);
    conv.dispose();
    return [out, tail];
  }

  #convTail(input: MlxArray, processed: number, rowLengths?: readonly number[]): MlxArray {
    const [B, , D] = input.shape as [number, number, number];
    const nKeep = this.convKernel - 1;
    if (rowLengths) {
      using indices = ops.fromInt32(rowLengths.flatMap(length =>
        Array.from({ length: nKeep }, (_, position) => length + position)), [B, nKeep, 1]);
      return ops.takeAlongAxis(input, indices, 1);
    }
    using view = input.slice([0, processed, 0], [B, processed + nKeep, D]);
    return materializeCopy(view);
  }

  forward(x: MlxArray, cache: SSMCache, independentRows = false, mask?: MlxArray | null): MlxArray {
    const [B, S] = x.shape as [number, number, number];
    const convDim = this.keyDim * 2 + this.valueDim;
    const nKeep = this.convKernel - 1;
    const prof = (globalThis as Record<string, unknown>).__deltaProf as
      Record<string, number>
      | undefined;

    // Armed speculative verify round (serve loop, serial lane): this forward
    // must be rewindable. Snapshot = hand the REPLACED state slots to the
    // round instead of disposing (free — arrays are immutable); record the
    // position-local kernel inputs (qkv/a/b) and install the prefix replay.
    const spec = cache.specRound;
    if (spec) {
      if (!spec.armed)
        throw new Error("GatedDeltaNet: spec round already recorded this round");
      spec.armed = false;
      spec.S = S;
      spec.replay = (c, keep) => this.#replaySpecPrefix(c, keep);
    }

    const t0 = prof ? performance.now() : 0;
    let qkv = this.inProjQkv.forward(x, independentRows); // [B,S,convDim]
    let z = this.inProjZ.forward(x, independentRows);
    z = disposing(z, ops.reshape(z, [B, S, this.numVHeads, this.headVDim]));
    const b = this.inProjB.forward(x, independentRows); // [B,S,numVHeads]
    const a = this.inProjA.forward(x, independentRows);
    if (prof) { ops.evalAll([qkv, z, b, a]); prof.proj = (prof.proj ?? 0) + performance.now() - t0; }
    const tc = prof ? performance.now() : 0; // [B,S,numVHeads]

    // The model shares one padding mask across recurrent layers. Direct layer
    // callers can request the same cache-owned mask without a model wrapper.
    using localMask = mask === undefined ? cache.prefillPadding?.makeMask(S) ?? null : null;
    const ssmMask = mask ?? localMask;
    if (ssmMask) {
      using expanded = ops.reshape(ssmMask, [B, S, 1]);
      using zero = MlxArray.fromBytesCopy(new Uint8Array(qkv.dtype === Dtype.float32 ? 4 : 2), [], qkv.dtype);
      qkv = disposing(qkv, ops.where(expanded, qkv, zero));
    }
    // Convolution keeps each row's last real-token tail, including empty rows.
    const convState =
      cache.conv ?? ops.zeros([B, nKeep, convDim], x.dtype);
    const [convOut, newConv] = this.#convolve(qkv, convState, cache.prefillPadding?.convolutionLengths(S));
    if (!cache.conv) convState.dispose();
    if (spec) spec.qkv = qkv;
    else qkv.dispose();
    if (spec) spec.prevConv = cache.conv;
    else cache.conv?.dispose();
    cache.conv = newConv;

    if (prof) { ops.evalAll([convOut]); prof.conv = (prof.conv ?? 0) + performance.now() - tc; }
    const tn = prof ? performance.now() : 0;

    const [qFlat, kFlat, vFlat] = ops.split(
      convOut, [this.keyDim, 2 * this.keyDim], -1,
    ) as [MlxArray, MlxArray, MlxArray];
    convOut.dispose();
    let q = ops.reshape(qFlat, [B, S, this.numKHeads, this.headKDim]);
    qFlat.dispose();
    let k = ops.reshape(kFlat, [B, S, this.numKHeads, this.headKDim]);
    kFlat.dispose();
    const v = disposing(vFlat, ops.reshape(vFlat, [B, S, this.numVHeads, this.headVDim]));

    // inv_scale = head_k_dim ** -0.5; q *= inv_scale², k *= inv_scale.
    const invScale = Math.pow(this.headKDim, -0.5);
    q = disposing(q, ops.rmsNorm(q, null, 1e-6));
    q = disposing(q, ops.mulScalar(q, invScale * invScale));
    k = disposing(k, ops.rmsNorm(k, null, 1e-6));
    k = disposing(k, ops.mulScalar(k, invScale));
    if (prof) { ops.evalAll([q, k]); prof.norms = (prof.norms ?? 0) + performance.now() - tn; }
    const tk = prof ? performance.now() : 0;

    const [out, newState] = gatedDeltaUpdate(
      q, k, v, a, b, this.aLog, this.dtBias, cache.recurrent, ssmMask,
    );
    if (prof) { ops.evalAll([out]); prof.kernel = (prof.kernel ?? 0) + performance.now() - tk; }
    const to = prof ? performance.now() : 0;
    q.dispose();
    k.dispose();
    v.dispose();
    if (spec) {
      spec.a = a;
      spec.b = b;
      spec.prevRecurrent = cache.recurrent;
    } else {
      a.dispose();
      b.dispose();
      cache.recurrent?.dispose();
    }
    cache.recurrent = newState;
    cache.advance(S);

    // RMSNormGated: silu(z_f32) * rms_norm(out)_f32, cast back to out dtype.
    const gated = this.rmsNormGated(out, z);
    out.dispose();
    z.dispose();
    const merged = ops.reshape(gated, [B, S, this.valueDim]);
    gated.dispose();
    const result = this.outProj.forward(merged, independentRows);
    merged.dispose();
    if (prof) { ops.evalAll([result]); prof.out = (prof.out ?? 0) + performance.now() - to; }
    return result;
  }

  /** Speculative rollback replay: with the pre-round snapshot RESTORED onto
   *  `cache`, re-advance the first `keep` window tokens from the recorded
   *  position-local inputs. Every op mirrors forward() on the same values —
   *  conv windows, silu, per-position norms, and the kernel's serial prefix
   *  are all independent of the rejected tail — so the resulting conv +
   *  recurrent state is BIT-EXACTLY what a forward over only the accepted
   *  prefix would have produced. Output projections (z / out_proj) are state-
   *  free and skipped: only the states matter here. */
  #replaySpecPrefix(cache: SSMCache, keep: number | readonly number[]): void {
    const r = cache.specRound;
    if (!r || !r.qkv || !r.a || !r.b)
      throw new Error("GatedDeltaNet replay without recorded round inputs");
    const B = r.qkv.shape[0]!;
    const count = typeof keep === "number" ? keep : Math.max(...keep);
    const rowLengths = typeof keep === "number" ? undefined : keep;
    const convDim = this.keyDim * 2 + this.valueDim;
    const nKeep = this.convKernel - 1;

    const qkvPfxView = r.qkv.slice([0, 0, 0], [B, count, convDim]);
    const qkvPfx = ops.contiguous(qkvPfxView);
    qkvPfxView.dispose();
    const convState = cache.conv ?? ops.zeros([B, nKeep, convDim], qkvPfx.dtype);
    const [convOut, newConv] = this.#convolve(qkvPfx, convState, rowLengths);
    if (!cache.conv) convState.dispose();
    qkvPfx.dispose();
    cache.conv?.dispose();
    cache.conv = newConv;

    const [qFlat, kFlat, vFlat] = ops.split(
      convOut, [this.keyDim, 2 * this.keyDim], -1,
    ) as [MlxArray, MlxArray, MlxArray];
    convOut.dispose();
    let q = rowLengths ? null : ops.reshape(qFlat, [B, count, this.numKHeads, this.headKDim]);
    qFlat.dispose();
    let k = ops.reshape(kFlat, [B, count, this.numKHeads, this.headKDim]);
    kFlat.dispose();
    const v = disposing(vFlat, ops.reshape(vFlat, [B, count, this.numVHeads, this.headVDim]));
    const invScale = Math.pow(this.headKDim, -0.5);
    if (q) {
      q = disposing(q, ops.rmsNorm(q, null, 1e-6));
      q = disposing(q, ops.mulScalar(q, invScale * invScale));
    }
    k = disposing(k, ops.rmsNorm(k, null, 1e-6));
    k = disposing(k, ops.mulScalar(k, invScale));

    const aPfxView = r.a.slice([0, 0, 0], [B, count, this.numVHeads]);
    const aPfx = ops.contiguous(aPfxView);
    aPfxView.dispose();
    const bPfxView = r.b.slice([0, 0, 0], [B, count, this.numVHeads]);
    const bPfx = ops.contiguous(bPfxView);
    bPfxView.dispose();

    let newState: MlxArray;
    if (rowLengths) {
      // Unequal prefixes need a row-length-aware recurrence. The state-only
      // kernel omits query/output work. Uniform replay retains its measured
      // kernel until the separate optimization demonstrates a serving win.
      newState = gatedDeltaState(k, v, aPfx, bPfx, this.aLog, this.dtBias, cache.recurrent, rowLengths);
    } else {
      const [output, state] = gatedDeltaUpdate(q!, k, v, aPfx, bPfx, this.aLog, this.dtBias, cache.recurrent);
      output.dispose(); newState = state;
    }
    q?.dispose();
    k.dispose();
    v.dispose();
    aPfx.dispose();
    bPfx.dispose();
    cache.recurrent?.dispose();
    cache.recurrent = newState;
    if (typeof keep === "number") cache.advance(keep);
    else cache.advanceRows(keep);
  }

  private rmsNormGated(hidden: MlxArray, gate: MlxArray): MlxArray {
    const xn = ops.rmsNorm(hidden, this.normWeight, this.eps); // bf16
    // Oracle: _precise_swiglu(hidden, gate, xn) — ALWAYS one @mx.compile kernel
    // (matches mlx-lm; no unfused silu+mul+cast).
    const res = compiledPreciseSwiglu(hidden, gate, xn);
    xn.dispose();
    return res;
  }
}

/** Full (softmax) attention with output gate + q/k norm + partial RoPE. */
export class Qwen3Attention {
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear;
  readonly vProj: QuantizedLinear;
  readonly oProj: QuantizedLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly scale: number;
  readonly ropeDims: number;
  readonly ropeBase: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeDims = Math.trunc(this.headDim * t.partialRotaryFactor);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
    this.qProj = QuantizedLinear.load(weights, `${prefix}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${prefix}.k_proj`, config);
    this.vProj = QuantizedLinear.load(weights, `${prefix}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${prefix}.o_proj`, config);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache, independentRows = false): MlxArray {
    const [B, L] = x.shape as [number, number, number];

    // q_proj emits 2× head_dim per head → split into queries + gate.
    const qp = this.qProj.forward(x, independentRows);
    const qpr = disposing(qp, ops.reshape(qp, [B, L, this.nHeads, this.headDim * 2]));
    const [qHeads, gateHeads] = ops.split(qpr, [this.headDim], -1) as [MlxArray, MlxArray];
    qpr.dispose();
    const gate = disposing(gateHeads, ops.reshape(gateHeads, [B, L, this.nHeads * this.headDim]));

    let k = this.kProj.forward(x, independentRows);
    let v = this.vProj.forward(x, independentRows);

    // q/k norm over head_dim BEFORE transpose (reference order).
    let q = this.qNorm.forward(qHeads);
    qHeads.dispose();
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    k = disposing(k, this.kNorm.forward(k));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    // Batched decode: the scheduler's mask wrapper exposes each row's REAL
    // position as ropeOffsetArr (rows have different prompt lengths); the
    // dynamic-offset kernel is the same fast::rope, bit-exact vs the static
    // form (tests/unit/compile.test.ts). Serial lane: scalar offset, unchanged.
    // Vision requests (serial lane only) install activeMrope for the current
    // forward: 3D interleaved positions via the manual apply — the reference
    // never uses the fused fast-rope kernel when position_ids are supplied,
    // so this IS the oracle's own arithmetic. Text-only stays on ops.rope.
    const mr = activeMrope;
    const offArr = (cache as { ropeOffsetArr?: MlxArray }).ropeOffsetArr;
    if (mr) {
      q = disposing(q, applyInterleavedRope(q, mr));
      k = disposing(k, applyInterleavedRope(k, mr));
    } else {
      q = disposing(q, offArr
        ? ops.ropeDynamic(q, this.ropeDims, this.ropeBase, offArr, null)
        : ops.rope(q, this.ropeDims, this.ropeBase, cache.offset, null));
      k = disposing(k, offArr
        ? ops.ropeDynamic(k, this.ropeDims, this.ropeBase, offArr, null)
        : ops.rope(k, this.ropeDims, this.ropeBase, cache.offset, null));
    }

    let attn: MlxArray;
    const quantized = cache.quantizedAttention;
    if (cache.attentionState) {
      const view = cache.attentionState.appendAndFetch(k, v);
      k.dispose(); v.dispose();
      try { attn = view.attend(q, this.scale, mask); } finally { view.dispose(); }
    } else if (quantized) {
      const [keys, values] = quantized.updateAndFetchQuantized(k, v);
      k.dispose();
      v.dispose();
      attn = quantizedSdpa(q, keys, values, this.scale, mask, quantized.groupSize, quantized.bits);
      disposeTriple(keys);
      disposeTriple(values);
    } else {
      const [keys, values] = cache.updateAndFetch(k, v);
      k.dispose();
      v.dispose();
      attn = ops.sdpa(q, keys, values, this.scale, mask.mode, mask.arr);
      keys.dispose();
      values.dispose();
    }
    q.dispose();

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
    const out = this.oProj.forward(gated, independentRows);
    gated.dispose();
    return out;
  }
}

/** MLP projections are affine-quantized (QuantizedLinear) or, in a Q2b
 *  packed-trellis artifact, TrellisLinear — chosen per module by the config's
 *  quantization entry (`mode: "trellis"`). */
export type MlpLinear = QuantizedLinear | TrellisLinear;
function loadMlpLinear(weights: Weights, path: string, config: ModelConfig): MlpLinear {
  if (!TrellisLinear.isTrellis(config, path)) return QuantizedLinear.load(weights, path, config);
  // M4 Pro measurements support the 27B down projection at M3/4. The
  // operation also checks variant, dtype and packed-code layout eligibility.
  const useSharedScatterCodebook = config.text.hiddenSize === 5120 &&
    config.text.intermediateSize === 17408 && path.endsWith(".down_proj");
  return TrellisLinear.load(weights, path, config, useSharedScatterCodebook);
}

export class Qwen3MLP {
  readonly gate: MlpLinear;
  readonly up: MlpLinear;
  readonly down: MlpLinear;

  constructor(weights: Weights, config: ModelConfig, prefix: string) {
    this.gate = loadMlpLinear(weights, `${prefix}.gate_proj`, config);
    this.up = loadMlpLinear(weights, `${prefix}.up_proj`, config);
    this.down = loadMlpLinear(weights, `${prefix}.down_proj`, config);
  }

  forward(x: MlxArray, inputRowContiguous = false, independentRows = false): MlxArray {
    // Packed-trellis decode (M ≤ 4): gate, up and the swiglu in ONE kernel —
    // x read once, no gate/up vectors materialized. This Lab path retains
    // the packed activation arithmetic documented in turboquant.md.
    if (this.gate instanceof TrellisLinear && this.up instanceof TrellisLinear &&
        fusedGateUpEligible(this.gate, this.up) &&
        x.shape.slice(0, -1).reduce((a, b) => a * b, 1) <= TRELLIS_MATVEC_MAX_M) {
      const hidden = fusedGateUpSwiglu(x, this.gate, this.up);
      const out = this.down instanceof QuantizedLinear ? this.down.forward(hidden, independentRows) : this.down.forward(hidden);
      hidden.dispose();
      return out;
    }
    const g = this.gate instanceof TrellisLinear ? this.gate.forward(x, inputRowContiguous) : this.gate.forward(x, independentRows);
    const u = this.up instanceof TrellisLinear ? this.up.forward(x, inputRowContiguous) : this.up.forward(x, independentRows);
    // Oracle: down_proj(swiglu(gate_proj(x), up_proj(x))) — swiglu ALWAYS compiled
    // (mlx-lm's @mx.compile swiglu; no unfused silu+mul, matches its kernel set).
    const hidden = compiledSwiglu(g, u);
    g.dispose();
    u.dispose();
    const out = this.down instanceof QuantizedLinear ? this.down.forward(hidden, independentRows) : this.down.forward(hidden);
    hidden.dispose();
    return out;
  }
}

export class Qwen3Layer {
  readonly isLinear: boolean;
  readonly linearAttn: GatedDeltaNet | null = null;
  readonly selfAttn: Qwen3Attention | null = null;
  readonly mlp: Qwen3MLP;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, layerIdx: number) {
    const prefix = `${PREFIX}.model.layers.${layerIdx}`;
    this.isLinear = (layerIdx + 1) % config.text.fullAttentionInterval !== 0;
    if (this.isLinear)
      this.linearAttn = new GatedDeltaNet(weights, config, `${prefix}.linear_attn`);
    else this.selfAttn = new Qwen3Attention(weights, config, `${prefix}.self_attn`);
    this.mlp = new Qwen3MLP(weights, config, `${prefix}.mlp`);
    this.inputNorm = new RMSNorm(weights.tensor(`${prefix}.input_layernorm.weight`), config.text.rmsNormEps);
    this.postAttnNorm = new RMSNorm(weights.tensor(`${prefix}.post_attention_layernorm.weight`), config.text.rmsNormEps);
  }

  forward(x: MlxArray, faMask: Mask, cache: Cache, independentRows = false, ssmMask?: MlxArray | null): MlxArray {
    using h = this.forwardAttn(x, faMask, cache, independentRows, ssmMask);
    return this.forwardMlp(h, independentRows);
  }

  forwardAttn(x: MlxArray, faMask: Mask, cache: Cache, independentRows = false, ssmMask?: MlxArray | null): MlxArray {
    using xn = this.inputNorm.forward(x);
    using r = this.isLinear
      ? this.linearAttn!.forward(xn, cache as SSMCache, independentRows, ssmMask)
      : this.selfAttn!.forward(xn, faMask, cache, independentRows);
    return ops.add(x, r);
  }

  forwardMlp(h: MlxArray, independentRows = false): MlxArray {
    using hn = this.postAttnNorm.forward(h);
    // RMSNorm allocates an aligned row-contiguous output. Pass that layout
    // proof so Trellis can match native small-prefill matmul without an eval.
    using m = this.mlp.forward(hn, true, independentRows);
    return ops.add(h, m);
  }
}

export class Qwen35Model {
  readonly config: ModelConfig;
  readonly weightsBytes: number;
  /** Base path for LoRA target keys (weights carry the language_model prefix). */
  readonly prefixBase = "language_model.model";
  readonly loraState = new LoraState();
  readonly embed: QuantizedEmbedding;
  readonly layers: Qwen3Layer[];
  readonly finalNorm: RMSNorm;
  /** null when tied: the output head reuses embed_tokens (embed.asLinear). */
  readonly lmHead: QuantizedLinear | null;
  readonly tied: boolean;
  readonly faIdx: number;

  constructor(weights: Weights, config: ModelConfig) {
    // Checkpoint-generation normalization BEFORE the first tensor() call: the
    // 5.8-family export names the trunk `model.language_model.*` with a
    // top-level `lm_head`, ships `mtp.*` in-repo, and stores RMSNorm gains as
    // γ−1 with HF-layout conv1d. The view maps all of that onto the names and
    // values this graph reads (mlx-lm's post-sanitize space). No-op — nothing
    // installed at all — for artifacts already in that space.
    const view = qwen35WeightsView(weights);
    if (view) weights.setView(view);
    this.config = config;
    this.tied = config.text.tieWordEmbeddings;
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((a, f) => a + f.mmap.size, 0);
    this.embed = QuantizedEmbedding.load(weights, `${PREFIX}.model.embed_tokens`, config);
    this.layers = Array.from(
      { length: config.text.numHiddenLayers },
      (_, i) => new Qwen3Layer(weights, config, i),
    );
    this.finalNorm = new RMSNorm(weights.tensor(`${PREFIX}.model.norm.weight`), config.text.rmsNormEps);
    // Tied models (e.g. Qwen3.5-4B) ship no lm_head; the reference uses
    // embed_tokens.as_linear (mlx-lm qwen3_5 TextModel.__call__).
    this.lmHead = this.tied ? null : QuantizedLinear.load(weights, `${PREFIX}.lm_head`, config);
    this.faIdx = config.text.fullAttentionInterval - 1;
  }

  loraTargets(): Map<string, QuantizedLinear> {
    const out = new Map<string, QuantizedLinear>();
    for (let i = 0; i < this.layers.length; i++) {
      const l = this.layers[i]!;
      const p = `${PREFIX}.model.layers.${i}`;
      if (l.selfAttn) {
        out.set(`${p}.self_attn.q_proj`, l.selfAttn.qProj);
        out.set(`${p}.self_attn.k_proj`, l.selfAttn.kProj);
        out.set(`${p}.self_attn.v_proj`, l.selfAttn.vProj);
        out.set(`${p}.self_attn.o_proj`, l.selfAttn.oProj);
      } else if (l.linearAttn) {
        out.set(`${p}.linear_attn.in_proj_qkv`, l.linearAttn.inProjQkv);
        out.set(`${p}.linear_attn.in_proj_z`, l.linearAttn.inProjZ);
        out.set(`${p}.linear_attn.in_proj_b`, l.linearAttn.inProjB);
        out.set(`${p}.linear_attn.in_proj_a`, l.linearAttn.inProjA);
        out.set(`${p}.linear_attn.out_proj`, l.linearAttn.outProj);
      }
      // Trellis-coded MLP tensors are not LoRA targets (no adapter seam yet).
      if (l.mlp.gate instanceof QuantizedLinear) out.set(`${p}.mlp.gate_proj`, l.mlp.gate);
      if (l.mlp.up instanceof QuantizedLinear) out.set(`${p}.mlp.up_proj`, l.mlp.up);
      if (l.mlp.down instanceof QuantizedLinear) out.set(`${p}.mlp.down_proj`, l.mlp.down);
    }
    return out;
  }

  makeCache(): Cache[] {
    return this.layers.map((l) => (l.isLinear ? new SSMCache() : new KVCache()));
  }

  /** The 27B append path keeps the native M1 affine arithmetic while Trellis
   * shares up to four rows. Other shapes retain single-token execution. */
  createAppend(policy: { hasAdapters: boolean; pagedKv: boolean }) {
    const t = this.config.text;
    if (policy.hasAdapters || policy.pagedKv || this.loraState.active.length || this.mrope ||
        t.hiddenSize !== 5120 || t.intermediateSize !== 17408 || this.layers.length !== 64 ||
        t.headDim !== 256 || t.numAttentionHeads !== 24 || t.numKeyValueHeads !== 4)
      return null;
    if (deviceArchitecture() !== "applegpu_g16s") return null;
    const qualified = (linear: QuantizedLinear | TrellisLinear) => {
      if (linear instanceof TrellisLinear) return true;
      const { mode, bits, groupSize } = linear.spec;
      return mode === "affine" && [2, 3, 4, 6, 8].includes(bits) && [32, 64, 128].includes(groupSize);
    };
    for (const layer of this.layers) {
      const a = layer.linearAttn, s = layer.selfAttn;
      const attention = a ? [a.inProjQkv, a.inProjZ, a.inProjB, a.inProjA, a.outProj]
        : [s!.qProj, s!.kProj, s!.vProj, s!.oProj];
      if (!attention.every(qualified) || ![layer.mlp.gate, layer.mlp.up, layer.mlp.down].every(qualified))
        return null;
    }
    return {
      maxChunkSize: (state: readonly Cache[]) => qwenAppendChunkSize(state[0]!.offset),
      forwardHidden: (ids: MlxArray, cache: Cache[]): MlxArray => {
        if (ids.shape.length !== 2 || ids.shape[0] !== 1 || ids.shape[1]! > 4)
          throw new Error("Qwen committed-token append supports one row and at most four positions");
        const hidden = this.embed.encode(ids);
        return this.forwardLayers(hidden, cache, true);
      },
    };
  }

  forwardHidden(ids: MlxArray, cache: Cache[]): MlxArray {
    const h = this.embed.encode(ids);
    return this.forwardLayers(h, cache);
  }

  /** Attention and DeltaNet retain disjoint row state. Only tokenwise MLP
   * work is eligible for packing; verification can preserve its geometry. */
  forwardHiddenMixed(work: readonly TokenGroup[]): MlxArray[] {
    if (work.length === 1 && !work[0]!.captureLayer) return [this.forwardHidden(work[0]!.ids, work[0]!.cache)];
    const groups: Array<{ h: MlxArray; mask?: Mask; ssmMask?: MlxArray | null }> = [];
    const results: MlxArray[] = [];
    const pack = runtimeFlag("MLX_BUN_MIXED_PACKED_MLP", true);
    const bounded = work.some(group => group.ids.shape[1]! > TRELLIS_MATVEC_MAX_M);
    try {
      for (const { ids, cache } of work) {
        const group: typeof groups[number] = { h: this.embed.encode(ids) }; groups.push(group);
        group.mask = cache[this.faIdx]!.makeMask(ids.shape[1]!, null);
        group.ssmMask = (cache[0] as SSMCache).prefillPadding?.makeMask(ids.shape[1]!);
      }
      for (const [i, layer] of this.layers.entries()) {
        const mids: MlxArray[] = [];
        try {
          for (const [row, group] of groups.entries())
            mids.push(layer.forwardAttn(group.h, group.mask!, work[row]!.cache[i]!, false, group.ssmMask));
          const outputs = mapTokenGroups(work, mids, hidden => layer.forwardMlp(hidden), pack);
          for (const [row, group] of groups.entries()) { group.h.dispose(); group.h = outputs[row]!; }
          // Materialize every layer's recurrent tail as well as the residual.
          // It is not a dependency of h and otherwise pins prefill buffers.
          if (bounded) {
            const caches = work.map(group => group.cache[i]!);
            const state = caches.map(cache => cache.state());
            try { ops.evalAll([...groups.map(group => group.h), ...state.flat()]); }
            finally { for (const [row, cache] of caches.entries())
              if (cache.stateNeedsDispose) for (const value of state[row]!) value.dispose(); }
          }
          for (const [row, group] of groups.entries()) work[row]!.captureLayer?.(i, group.h);
        } finally { for (const mid of mids) mid.dispose(); }
      }
      for (const [row, group] of groups.entries()) {
        const hidden = this.finalNorm.forward(group.h); results.push(hidden);
        work[row]!.captureLayer?.(this.layers.length, hidden);
      }
      return results;
    } catch (error) { for (const result of results) result.dispose(); throw error; }
    finally { for (const group of groups) { group.h.dispose(); group.mask?.arr?.dispose(); group.ssmMask?.dispose(); } }
  }

  /** Active vision mRoPE request state (serial lane; set by the generation
   *  gateway around a vision request's run, null for text-only — which keeps
   *  the bit-exact fast-rope path). While set, forwardLayers installs the
   *  per-forward interleaved cos/sin consumed by every full-attn layer. */
  mrope: MropeRequestState | null = null;
  #mropeInvFreq: MlxArray | null = null;

  /** Vision prefill: spliced input embeddings [1, L, H] (image features
   *  overwriting image-token rows — the caller builds them). Caller keeps
   *  ownership of `embeds`. bidir/ids/multimodal are the Gemma-shaped extras
   *  and are unused: Qwen3.5 vision attends fully causally. */
  forwardEmbeddings(
    embeds: MlxArray, cache: Cache[], _bidir: MlxArray | null,
    _ids: MlxArray | null = null, _multimodal: MlxArray | null = null,
  ): MlxArray {
    const h = ops.contiguous(embeds); // fresh handle — the layer loop consumes it
    return this.forwardLayers(h, cache);
  }

  /** Layer-output tap (same contract as Gemma4Model.hiddenTap): the serve
   *  loop's forwardMaybeTap sets it around prefill/verify forwards so
   *  KV-borrowing draft sources (native Qwen MTP) can read PRE-final-norm
   *  hiddens — layer 63's output stream, what mlx-vlm captures with
   *  skip_final_norm=True. No-op (and graph-identical) when null. */
  hiddenTap: { layers: Set<number>; pos?: number; captured: Map<number, MlxArray> } | null = null;

  /** Store layer `i`'s residual stream ([1,L,H]) if the tap requests it.
   *  Copies so the loop's h.dispose() can't free the capture. */
  protected captureLayer(i: number, h: MlxArray): void {
    const tap = this.hiddenTap;
    if (!tap || !tap.layers.has(i)) return;
    const H = h.shape[2]!;
    const src = tap.pos !== undefined ? h.slice([0, tap.pos, 0], [1, tap.pos + 1, H]) : h;
    const copy = ops.contiguous(src);
    if (src !== h) src.dispose();
    tap.captured.set(i, copy);
  }

  protected forwardLayers(h0: MlxArray, cache: Cache[], independentRows = false): MlxArray {
    const L = h0.shape[1]!;
    // One full-attention mask shared by all full layers (same offset); linear
    // layers see no ssm mask at B=1.
    const faMask = cache[this.faIdx]!.makeMask(L, null);
    using ssmMask = (cache[0] as SSMCache).prefillPadding?.makeMask(L) ?? null;
    // Vision requests: one interleaved-mRoPE cos/sin table per forward,
    // shared by all 12 full-attention layers (positions are layer-invariant).
    let mropeFwd: ReturnType<typeof buildMropePositions> | null = null;
    if (this.mrope) {
      const t = this.config.text;
      const ropeDims = Math.trunc(t.headDim * t.partialRotaryFactor);
      const base = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
      this.#mropeInvFreq ??= mropeInvFreq(ropeDims, base);
      mropeFwd = buildMropePositions(
        this.mrope, cache[this.faIdx]!.offset, L, this.#mropeInvFreq, ropeDims,
      );
      setActiveMrope(mropeFwd);
    }
    let h: MlxArray | null = h0;
    const prof = (globalThis as Record<string, unknown>).__deltaProf as
      Record<string, number>
      | undefined;
    try {
      for (let i = 0; i < this.layers.length; i++) {
        const tl = prof ? performance.now() : 0;
        const next = this.layers[i]!.forward(h, faMask, cache[i]!, independentRows, ssmMask);
        h.dispose();
        h = next;
        if (L > TRELLIS_MATVEC_MAX_M) {
          // Affine prefills also need bounded evaluation: a retained prefix
          // history can leave too little room for the entire deferred graph.
          // Materialize the cache outputs too. In particular, the tiny
          // copied conv tail is not a dependency of `h`; leaving it lazy
          // pins the whole prefill conv buffer until the chunk ends.
          const state = cache[i]!.state();
          try { ops.evalAll([h, ...state]); }
          finally { if (cache[i]!.stateNeedsDispose) for (const a of state) a.dispose(); }
        }
        if (prof) {
          ops.evalAll([h]);
          const key = this.layers[i]!.isLinear ? "layerLin" : "layerFull";
          prof[key] = (prof[key] ?? 0) + performance.now() - tl;
        }
        this.captureLayer(i, h); // native-MTP pre-final-norm tap (no-op unless set)
      }
      const out = disposing(h, this.finalNorm.forward(h));
      h = null; // consumed — the finally must not double-free
      return out;
    } finally {
      if (mropeFwd) {
        setActiveMrope(null);
        mropeFwd.posIds.dispose();
      }
      // A mid-loop layer throw must not strand the mask array or the
      // in-flight [1,L,H] residual (2026-08-18 review).
      faMask.arr?.dispose();
      h?.dispose();
    }
  }

  logitsFromHidden(h: MlxArray): MlxArray {
    return this.tied ? this.embed.asLinear(h) : this.lmHead!.forward(h);
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
