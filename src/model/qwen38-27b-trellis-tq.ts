// Qwen3.8-27B packed-Trellis (TurboQuant) — THE graph for this exact quant.
//
// One hand-written forward for one model and one quantization map. It is
// selected at load only when the artifact's graph fingerprint (architecture plus
// the COMPLETE per-tensor quantization table) is one this file was built for;
// every other Qwen3.5-family artifact keeps the generic Qwen35Model.
//
// What is compile-time here: the 48 DeltaNet + 16 attention layer pattern, the
// shapes, and the codec and bit width of every tensor. What is NOT: batch rows,
// window width and KV scheme. Those belong to the scheduler, the method and the
// request; they arrive as runtime dimensions and kernels specialize on row count
// through template parameters at dispatch. The graph never schedules.
//
// Everything that is decidable from the quant map is decided ONCE, at
// construction, into a per-layer plan of direct calls: no per-forward layer-kind,
// codec or eligibility branching. Each optimization that changes arithmetic is
// individually switchable so it can be A/B-measured through the server in the
// batched lane; an optimization earns its default there, on identical-output
// items, and the bundle on the frozen 64.
//
// Owned by this file today: the layer sequence, residual stream and the MLP
// block. Still delegated to the generic blocks, in the order they are being
// taken over: DeltaNet glue (conv/activation/split/norms between the projections
// and the recurrence), attention glue, the affine width>1 projections.
//
// Served split of a width-3 verify forward (batched lane, barrier-corrected):
// Trellis MLP ~68 ms, DeltaNet projections ~17, attention ~8, DeltaNet
// conv/norms/recurrence ~6, head+norms+residuals ~9  (109 ms total).

import { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { Weights } from "../weights";
import { quantFor, type ModelConfig } from "../config";
import { runtimeFlag, runtimeValue } from "../runtime-config";
import { QuantizedLinear, type Cache, type Mask } from "./gemma4-base";
import { Qwen35Model, compiledSwiglu, type Qwen3Layer } from "./qwen3_5";
import type { SSMCache } from "./qwen3-delta";
import {
  TrellisLinear, TRELLIS_MATVEC_MAX_M, fusedGateUpEligible, fusedGateUpSwiglu,
  fusedGateUpSwigluMixed, mixedGateUpEligible, type MixedGateUpTail,
} from "./trellis-linear";

export const QWEN38_TRELLIS_TQ_GRAPH = "qwen3.8-27b-trellis-tq";

/** Graph fingerprints this file was built and qualified for. */
export const QWEN38_TRELLIS_TQ_FINGERPRINTS: ReadonlySet<string> = new Set([
  "cfa205c8f5af046a", // qwen38-trellis-global-exit5-h39-q4b-v2 (11.99 GB incumbent)
]);

/** Architecture plus the complete language-model quantization table. Two
 *  artifacts share a fingerprint only if every tensor has the same codec. */
export function qwen38TrellisTqFingerprint(config: ModelConfig): string {
  const t = config.text;
  const q = config.quantization as unknown as { bits?: number; groupSize?: number; mode?: string; overrides?: Record<string, unknown> } | null;
  const roles = ["linear_attn.in_proj_qkv", "linear_attn.in_proj_z", "linear_attn.in_proj_a", "linear_attn.in_proj_b",
    "linear_attn.out_proj", "self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj", "self_attn.o_proj",
    "mlp.gate_proj", "mlp.up_proj", "mlp.down_proj"];
  const table: unknown[] = [];
  for (let layer = 0; layer < t.numHiddenLayers; layer++)
    for (const role of roles) table.push(quantFor(config.quantization, `language_model.model.layers.${layer}.${role}`));
  table.push(quantFor(config.quantization, "language_model.lm_head"), quantFor(config.quantization, "language_model.model.embed_tokens"));
  const payload = JSON.stringify({
    modelType: config.modelType, hiddenSize: t.hiddenSize, intermediateSize: t.intermediateSize,
    layers: t.numHiddenLayers, fullAttentionInterval: t.fullAttentionInterval,
    heads: t.numAttentionHeads, kvHeads: t.numKeyValueHeads, headDim: t.headDim,
    linear: [t.linearNumKeyHeads, t.linearNumValueHeads, t.linearKeyHeadDim, t.linearValueHeadDim, t.linearConvKernelDim],
    vocabSize: t.vocabSize, tied: t.tieWordEmbeddings, defaults: q ? [q.bits, q.groupSize, q.mode] : null, table,
  });
  const hash = new Bun.CryptoHasher("sha256");
  hash.update(payload);
  return hash.digest("hex").slice(0, 16);
}

/** Is this exactly a quant this graph was built for? `MLX_BUN_QWEN38_TQ_GRAPH=0`
 *  keeps the generic model (the A/B control). */
export function qwen38TrellisTqAccepts(config: ModelConfig): boolean {
  if (!runtimeFlag("MLX_BUN_QWEN38_TQ_GRAPH", true)) return false;
  if (config.modelType !== "qwen3_5" && config.modelType !== "qwen3_5_text") return false;
  return QWEN38_TRELLIS_TQ_FINGERPRINTS.has(qwen38TrellisTqFingerprint(config));
}

/** `MLX_BUN_QWEN38_TQ_MIXED_GATEUP`: unset or `split` = on with the split-exact tail,
 *  `fused` (or the earlier `1`) = on with the float32-sigmoid tail, `0`/`off` = off. */
function mixedGateUpOption(): MixedGateUpTail | "off" {
  const value = runtimeValue("MLX_BUN_QWEN38_TQ_MIXED_GATEUP")?.trim().toLowerCase();
  if (value === "0" || value === "off") return "off";
  return value === "1" || value === "fused" ? "fused" : "split";
}

type MlpStep = (hidden: MlxArray, independentRows: boolean) => MlxArray;
type LayerStep = (x: MlxArray, faMask: Mask, cache: Cache, independentRows: boolean, ssmMask: MlxArray | null) => MlxArray;

export interface Qwen38TqPlanSummary {
  readonly graph: string;
  readonly fingerprint: string;
  readonly mlp: Readonly<Record<"fused" | "mixedFused" | "split", number>>;
  readonly options: Readonly<Record<string, boolean | string>>;
}

export class Qwen38TrellisTQ extends Qwen35Model {
  readonly graph = QWEN38_TRELLIS_TQ_GRAPH;
  readonly plan: Qwen38TqPlanSummary;
  readonly #steps: LayerStep[];
  #qkScale: { q: MlxArray; k: MlxArray } | null = null;

  constructor(weights: Weights, config: ModelConfig) {
    super(weights, config);
    const options = {
      // Layers whose gate and up were allocated DIFFERENT bit widths fall off the
      // same-k fused kernel onto two projections plus a separate SwiGLU. One kernel
      // templated on both widths restores the fusion (q4b: 10 of 64 layers; verify
      // forward about -1 ms). Default "split": the kernel reproduces the split path's
      // compiled-swiglu arithmetic bit for bit, so no output changes. "fused" uses the
      // float32 sigmoid of the other 54 layers instead (last bits differ, sampled
      // trajectories re-roll). "off" keeps the two projections: the A/B control.
      mixedGateUp: mixedGateUpOption(),
      // DeltaNet's q/k scale as the weight of the norm before it: bit-identical
      // (see GatedDeltaNet.qkScale), 96 fewer kernels per forward. `=0` is the control.
      foldQkScale: runtimeFlag("MLX_BUN_QWEN38_TQ_FOLD_QK_SCALE", true),
    };
    if (options.foldQkScale) {
      const dim = config.text.linearKeyHeadDim, invScale = Math.pow(dim, -0.5);
      this.#qkScale = { q: ops.filledBf16(invScale * invScale, dim), k: ops.filledBf16(invScale, dim) };
      for (const layer of this.layers) if (layer.linearAttn) layer.linearAttn.qkScale = this.#qkScale;
    }
    const counts = { fused: 0, mixedFused: 0, split: 0 };
    this.#steps = this.layers.map(layer => this.#layerStep(layer, options, counts));
    this.plan = Object.freeze({ graph: this.graph, fingerprint: qwen38TrellisTqFingerprint(config),
      mlp: Object.freeze(counts), options: Object.freeze(options) });
    // Provenance for every run: which graph served, and with which levers.
    console.error(`[graph] ${this.graph} ${this.plan.fingerprint} mlp fused=${counts.fused} mixedFused=${counts.mixedFused} ` +
      `split=${counts.split} options=${JSON.stringify(options)}`);
  }

  /** Resolve one layer into a closure of direct calls. */
  #layerStep(layer: Qwen3Layer, options: { mixedGateUp: MixedGateUpTail | "off" }, counts: Record<string, number>): LayerStep {
    const mlp = this.#mlpStep(layer, options, counts);
    const { inputNorm, postAttnNorm } = layer;
    if (layer.isLinear) {
      const block = layer.linearAttn!;
      return (x, _faMask, cache, independentRows, ssmMask) => {
        using normed = inputNorm.forward(x);
        using mixed = block.forward(normed, cache as SSMCache, independentRows, ssmMask);
        using hidden = ops.add(x, mixed);
        using post = postAttnNorm.forward(hidden);
        using out = mlp(post, independentRows);
        return ops.add(hidden, out);
      };
    }
    const block = layer.selfAttn!;
    return (x, faMask, cache, independentRows) => {
      using normed = inputNorm.forward(x);
      using mixed = block.forward(normed, faMask, cache, independentRows, null);
      using hidden = ops.add(x, mixed);
      using post = postAttnNorm.forward(hidden);
      using out = mlp(post, independentRows);
      return ops.add(hidden, out);
    };
  }

  /** The MLP strategy is a property of the quant map, fixed at load. Small
   *  windows (rows <= TRELLIS_MATVEC_MAX_M) take the packed kernels; wider
   *  inputs (prefill) keep the generic block, which owns tiling and expansion. */
  #mlpStep(layer: Qwen3Layer, options: { mixedGateUp: MixedGateUpTail | "off" }, counts: Record<string, number>): MlpStep {
    const { gate, up, down } = layer.mlp;
    const generic: MlpStep = (hidden, independentRows) => layer.mlp.forward(hidden, true, independentRows);
    if (!(gate instanceof TrellisLinear) || !(up instanceof TrellisLinear) || down instanceof QuantizedLinear) {
      counts.split!++;
      return generic;
    }
    const rows = (hidden: MlxArray) => hidden.shape.slice(0, -1).reduce((a, b) => a * b, 1);
    if (fusedGateUpEligible(gate, up)) {
      counts.fused!++;
      return (hidden, independentRows) => {
        if (rows(hidden) > TRELLIS_MATVEC_MAX_M) return generic(hidden, independentRows);
        using mid = fusedGateUpSwiglu(hidden, gate, up);
        return down.forward(mid);
      };
    }
    const tail = options.mixedGateUp;
    if (tail !== "off" && mixedGateUpEligible(gate, up)) {
      counts.mixedFused!++;
      return (hidden, independentRows) => {
        if (rows(hidden) > TRELLIS_MATVEC_MAX_M) return generic(hidden, independentRows);
        using mid = fusedGateUpSwigluMixed(hidden, gate, up, tail);
        return down.forward(mid);
      };
    }
    counts.split!++;
    return (hidden, independentRows) => {
      if (rows(hidden) > TRELLIS_MATVEC_MAX_M) return generic(hidden, independentRows);
      using g = gate.forward(hidden, true);
      using u = up.forward(hidden, true);
      using mid = compiledSwiglu(g, u);
      return down.forward(mid);
    };
  }

  /** Text forward over the pre-resolved plan. Vision positions, the active
   *  vision mRoPE state and the diagnostic profiler keep the generic loop,
   *  which owns those concerns. Consumes h0, like the generic implementation. */
  protected override forwardLayers(h0: MlxArray, cache: Cache[], independentRows = false,
    positions?: MlxArray): MlxArray {
    if (positions || this.mrope || (globalThis as Record<string, unknown>).__deltaProf)
      return super.forwardLayers(h0, cache, independentRows, positions);
    const L = h0.shape[1]!;
    const faMask = cache[this.faIdx]!.makeMask(L, null);
    using ssmMask = (cache[0] as SSMCache).prefillPadding?.makeMask(L) ?? null;
    const bounded = L > TRELLIS_MATVEC_MAX_M;
    let h: MlxArray | null = h0;
    try {
      for (let i = 0; i < this.#steps.length; i++) {
        const next = this.#steps[i]!(h, faMask, cache[i]!, independentRows, ssmMask);
        h.dispose();
        h = next;
        if (bounded) {
          // Prefill chunks: bound the live graph per layer, including the
          // recurrent tail, exactly as the generic loop does.
          const state = cache[i]!.state();
          try { ops.evalAll([h, ...state]); }
          finally { if (cache[i]!.stateNeedsDispose) for (const a of state) a.dispose(); }
        }
        this.captureLayer(i, h);
      }
      const out = this.finalNorm.forward(h);
      h.dispose();
      h = null;
      return out;
    } finally {
      faMask.arr?.dispose();
      h?.dispose();
    }
  }
}
