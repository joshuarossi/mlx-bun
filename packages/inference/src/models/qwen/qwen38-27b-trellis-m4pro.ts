// Qwen3.8-27B Trellis 3.2bpw (mlx-bun/Qwen3.8-27B-Trellis-3.2bpw) on the
// M4 Pro GPU (applegpu_g16s) — the graph for this exact artifact on this exact
// GPU family.
//
// Selected at load only for the artifact's graph fingerprint on that device.
// Everything is decided at construction: for every request shape it serves, the
// graph resolves each of the 64 layers into a closure of direct calls to
// specific layers, and each layer runs one kernel. A forward picks the plan its
// row count matches:
//
//   rows      MLP gate/up                 MLP down                   affine projections   attention (KV4)
//   1         factored, one row           factored, one row          MLX qmv              fused 4-bit decode
//   2..3      factored, shared rows       factored, shared rows      3/4-bit multi-row    folded GQA
//   4         factored, shared rows       simdgroup matrix           3/4-bit multi-row    folded GQA
//   5..8      simdgroup matrix            simdgroup matrix           3/4-bit matrix       folded GQA
//   2048      ANE+GPU whole-MLP split     (in the split)             z/out/o ANE+GPU      folded GQA
//   other     packed-Trellis prefill (TrellisLinear)                 MLX qmm              folded GQA
//
// (factored: weights contribute their Trellis code value; the scale applies once
// per output.) Down projections take the 3-bit block-interleaved kernels where
// the artifact stores that layout. Every verify width submits the graph every
// four layers so host construction overlaps GPU work; prefill chunks evaluate
// per layer. The ANE plan exists only when the Neural Engine bridge loads.
//
// Requests these plans do not cover keep the generic Qwen35Model forward:
// several sequences at once, independent-row appends, vision positions, array
// attention masks, mounted adapters, and KV caches other than BF16 or 4-bit
// group-64. Measured on M4 Pro 24 GB against the same artifact on the generic
// graph: see the PR introducing this file.

import type { MlxArray } from "@mlx-bun/mlx/array";
import { deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Weights } from "../../artifacts/weights";
import type { ModelConfig } from "../../artifacts/config";
import type { Cache, Mask } from "../../contracts/mlx/cache";
import type { TokenGroup } from "../../contracts/mlx/token-work";
import type { SSMCache } from "../../state/ssm";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { TrellisLinear } from "../../layers/trellis-linear";
import { compiledSwiglu } from "../../layers/swiglu";
import { FactoredGateUpRow, FactoredGateUpRows, FactoredMixedGateUp, MmaGateUp } from "../../layers/trellis-gate-up";
import { FactoredDownK3iRow, FactoredDownK3iRows, FactoredDownRow, FactoredDownRows, MmaDown, MmaDownK3i } from "../../layers/trellis-down";
import { Affine3MmaLinear, Affine3RowsLinear, Affine4MmaLinear, Affine4RowsLinear } from "../../layers/affine-verify-linear";
import { kv4DecodeAttention } from "../../layers/kv4-decode-attention";
import { foldedQuantizedSdpa } from "../../layers/quantized-attention";
import { AneAffineSplit, AneTrellisMlpSplit, AneTrellisMlpSplitK3i, aneAvailable, type AneMlpSplit }
  from "../../layers/ane-prefill-split";
import {
  GatedDeltaNet, Qwen35Model, Qwen3Attention, type AttentionLinear, type AttentionLinearLoader, type Qwen3Layer,
  type QuantizedAttentionCore,
} from "./qwen3_5";
import { qwen38TrellisTqFingerprint } from "./qwen38-27b-trellis-tq";

export const QWEN38_TRELLIS_M4PRO_GRAPH = "qwen3.8-27b-trellis-3.2bpw-m4pro";
const DEVICE = "applegpu_g16s";
/** mlx-bun/Qwen3.8-27B-Trellis-3.2bpw (qwen38TrellisTqFingerprint). */
const FINGERPRINT = "cfa205c8f5af046a";

/** Submit the graph every four layers at verify widths (measured best on M4 Pro). */
const ASYNC_EVERY = 4;
/** ANE prefill: channel fraction and the chunk size its programs serve. */
const ANE_FRACTION = 0.55, ANE_SEQ = 2048;
const ANE_AFFINE = /\.(in_proj_z|out_proj|o_proj)$/;

/** This artifact on this GPU family. */
export function qwen38TrellisM4ProAccepts(config: ModelConfig): boolean {
  if (config.modelType !== "qwen3_5" && config.modelType !== "qwen3_5_text") return false;
  return deviceArchitecture() === DEVICE && qwen38TrellisTqFingerprint(config) === FINGERPRINT;
}

type Step = (x: MlxArray, faMask: Mask, cache: Cache, independentRows: boolean, ssmMask: MlxArray | null) => MlxArray;
/** post-attention-normed hidden, residual → residual + MLP(hidden). */
type MlpStep = (hidden: MlxArray, residual: MlxArray, independentRows: boolean) => MlxArray;
type PlanKind = "row" | "rows" | "rows4" | "verify" | "prefill" | "prefillAne";

const decodeCore: QuantizedAttentionCore = (q, keys, values, scale, _mask, groupSize, bits) =>
  kv4DecodeAttention(q, keys, values, scale, groupSize, bits);
const foldedCore: QuantizedAttentionCore = (q, keys, values, scale, _mask, groupSize, bits) =>
  foldedQuantizedSdpa(q, keys, values, scale, groupSize, bits);

export class Qwen38TrellisM4Pro extends Qwen35Model {
  readonly graph = QWEN38_TRELLIS_M4PRO_GRAPH;
  /** Verify forward cost by rows relative to one decode step (M4 Pro 24 GB). */
  readonly verifyRoundCosts: ReadonlyMap<number, number> = new Map([
    [1, 1], [2, 1.3], [3, 1.46], [4, 1.68], [5, 1.82], [6, 1.92], [7, 1.93], [8, 1.94],
  ]);
  readonly #plans: Record<Exclude<PlanKind, "prefillAne">, Step[]> & { prefillAne: Step[] | null };
  readonly #headRows: Affine4RowsLinear | null;
  readonly #headMma: Affine4MmaLinear | null;
  readonly #qkScale: { q: MlxArray; k: MlxArray };
  /** A tapped group's capture callback while its forward runs on a plan. */
  #captureHook: ((layer: number, hidden: MlxArray) => void) | null = null;
  /** The last ANE MLP split built; the next layer's split shares its buffers (layers run one at a time). */
  #aneMlpShare: AneMlpSplit | undefined;

  constructor(weights: Weights, config: ModelConfig) {
    super(weights, config);
    // DeltaNet's q/k scale as the weight of the norm before it: bit-identical
    // (see GatedDeltaNet.qkScale), 96 fewer kernels per forward.
    const dim = config.text.linearKeyHeadDim, invScale = Math.pow(dim, -0.5);
    this.#qkScale = { q: ops.filledBf16(invScale * invScale, dim), k: ops.filledBf16(invScale, dim) };
    for (const layer of this.layers) if (layer.linearAttn) layer.linearAttn.qkScale = this.#qkScale;
    // Each projection's layer follows its stored width (3 or 4 bits).
    const rows4: AttentionLinearLoader<AttentionLinear> = (w, path, c) => {
      const lin = QuantizedLinear.load(w, path, c);
      return lin.spec.bits === 3 ? new Affine3RowsLinear(lin) : new Affine4RowsLinear(lin);
    };
    const mma: AttentionLinearLoader<AttentionLinear> = (w, path, c) => {
      const lin = QuantizedLinear.load(w, path, c);
      return lin.spec.bits === 3 ? new Affine3MmaLinear(lin) : new Affine4MmaLinear(lin);
    };
    this.#plans = {
      row: this.#build(weights, config, "row", null, decodeCore),
      rows: this.#build(weights, config, "rows", rows4, foldedCore),
      rows4: this.#build(weights, config, "rows4", rows4, foldedCore),
      verify: this.#build(weights, config, "verify", mma, foldedCore),
      prefill: this.#build(weights, config, "prefill", null, foldedCore),
      prefillAne: this.#buildAnePlan(weights, config),
    };
    this.#headRows = this.lmHead ? new Affine4RowsLinear(this.lmHead) : null;
    this.#headMma = this.lmHead ? new Affine4MmaLinear(this.lmHead) : null;
    console.error(`[graph] ${this.graph} ${FINGERPRINT} ane-prefill=${this.#plans.prefillAne ? "on" : "off"}`);
  }

  /** One plan: per-layer closures over this plan's blocks and MLP layers.
   *  `loadLinear` null keeps the base model's QuantizedLinear blocks. */
  #build(weights: Weights, config: ModelConfig, kind: PlanKind, loadLinear: AttentionLinearLoader<AttentionLinear> | null,
    core: QuantizedAttentionCore): Step[] {
    return this.layers.map((layer, i) => {
      const prefix = `language_model.model.layers.${i}`;
      const mlp = this.#mlpStep(layer, kind);
      const { inputNorm, postAttnNorm } = layer;
      if (layer.isLinear) {
        let block: GatedDeltaNet<AttentionLinear> = layer.linearAttn!;
        if (loadLinear) {
          block = new GatedDeltaNet(weights, config, `${prefix}.linear_attn`, loadLinear);
          block.qkScale = this.#qkScale;
        }
        return (x, _faMask, cache, independentRows, ssmMask) => {
          using normed = inputNorm.forward(x);
          using mixed = block.forward(normed, cache as SSMCache, independentRows, ssmMask);
          using hidden = ops.add(x, mixed);
          using post = postAttnNorm.forward(hidden);
          return mlp(post, hidden, independentRows);
        };
      }
      const block = new Qwen3Attention(weights, config, `${prefix}.self_attn`, loadLinear ?? undefined, core);
      return (x, faMask, cache, independentRows) => {
        using normed = inputNorm.forward(x);
        using mixed = block.forward(normed, faMask, cache, independentRows, null);
        using hidden = ops.add(x, mixed);
        using post = postAttnNorm.forward(hidden);
        return mlp(post, hidden, independentRows);
      };
    });
  }

  /** The ANE prefill plan, or null without the Neural Engine bridge (or when
   *  its programs cannot be built on this machine). Each layer builds its
   *  program for the ANE chunk here; the system ANE cache keeps the compiled
   *  programs across processes. Projections of one shape share buffers. */
  #buildAnePlan(weights: Weights, config: ModelConfig): Step[] | null {
    if (!aneAvailable()) return null;
    const started = performance.now();
    try {
      const affineShares = new Map<string, AneAffineSplit>();
      const load: AttentionLinearLoader<AttentionLinear> = (w, path, c) => {
        const lin = QuantizedLinear.load(w, path, c);
        if (!ANE_AFFINE.test(path)) return lin;
        const shape = `${lin.inFeatures}:${lin.outFeatures}`;
        const split = AneAffineSplit.build(lin, ANE_FRACTION, ANE_SEQ, affineShares.get(shape));
        affineShares.set(shape, split);
        return split;
      };
      const plan = this.#build(weights, config, "prefillAne", load, foldedCore);
      console.error(`[ane] prefill programs ready in ${Math.round(performance.now() - started)} ms`);
      return plan;
    } catch (error) {
      console.warn(`ANE prefill plan unavailable: ${(error as Error).message}`);
      return null;
    }
  }

  /** The MLP of one layer in one plan. */
  #mlpStep(layer: Qwen3Layer, kind: PlanKind): MlpStep {
    const { gate, up, down } = layer.mlp;
    if (!(gate instanceof TrellisLinear) || !(up instanceof TrellisLinear) || !(down instanceof TrellisLinear))
      throw new Error(`${QWEN38_TRELLIS_M4PRO_GRAPH}: expected Trellis gate/up/down in every MLP`);
    if (kind === "prefill") return (hidden, residual, independentRows) => {
      using out = layer.mlp.forward(hidden, true, independentRows);
      return ops.add(residual, out);
    };
    const k3i = down.geometry.blockInterleave === 2;
    if (kind === "prefillAne") {
      const split = this.#aneMlpShare =
        (k3i ? AneTrellisMlpSplitK3i : AneTrellisMlpSplit).build(gate, up, down, ANE_FRACTION, ANE_SEQ, this.#aneMlpShare);
      return (hidden, residual) => {
        using out = split.forward(hidden, compiledSwiglu);
        return ops.add(residual, out);
      };
    }
    const sameWidth = gate.geometry.k === up.geometry.k;
    const gateUp = kind === "verify" ? new MmaGateUp(gate, up)
      : !sameWidth ? new FactoredMixedGateUp(gate, up)
      : kind === "row" ? new FactoredGateUpRow(gate, up) : new FactoredGateUpRows(gate, up);
    const project = kind === "row" ? (k3i ? new FactoredDownK3iRow(down) : new FactoredDownRow(down))
      : kind === "rows" ? (k3i ? new FactoredDownK3iRows(down) : new FactoredDownRows(down))
      : (k3i ? new MmaDownK3i(down) : new MmaDown(down));
    return (hidden, residual) => {
      using mid = gateUp.forward(hidden);
      using out = project.forward(mid);
      return ops.add(residual, out);
    };
  }

  #planFor(L: number): Step[] {
    const p = this.#plans;
    return L === 1 ? p.row : L <= 3 ? p.rows : L === 4 ? p.rows4 : L <= 8 ? p.verify
      : p.prefillAne && L === ANE_SEQ ? p.prefillAne : p.prefill;
  }

  /** One tapped group (speculative verify, draft-tapped prefill) runs a plan,
   *  forwarding each layer output and the final hidden to its capture callback.
   *  Several groups keep the generic token packing. */
  override forwardHiddenMixed(work: readonly TokenGroup[]): MlxArray[] {
    const only = work.length === 1 ? work[0]! : null;
    if (!only?.captureLayer) return super.forwardHiddenMixed(work);
    const previous = this.#captureHook;
    this.#captureHook = only.captureLayer;
    try {
      const out = this.forwardLayers(this.embed.encode(only.ids), only.cache);
      only.captureLayer(this.layers.length, out);
      return [out];
    } finally { this.#captureHook = previous; }
  }

  protected override captureLayer(i: number, h: MlxArray): void {
    super.captureLayer(i, h);
    this.#captureHook?.(i, h);
  }

  /** The output head for the rows it serves: the verify-width affine kernels
   *  at 2..8 rows, QuantizedLinear otherwise. */
  override logitsFromHidden(h: MlxArray): MlxArray {
    const rows = h.size / h.shape.at(-1)!;
    if (!this.#headRows || !this.#headMma || this.loraState.active.length || rows < 2 || rows > 8) return super.logitsFromHidden(h);
    return rows >= 5 ? this.#headMma.forward(h) : this.#headRows.forward(h);
  }

  /** Text forward over the plan the row count matches. Consumes h0. */
  protected override forwardLayers(h0: MlxArray, cache: Cache[], independentRows = false, positions?: MlxArray): MlxArray {
    const kv = cache[this.faIdx]!.quantizedAttention;
    if (positions || this.mrope || independentRows || h0.shape[0] !== 1 || this.loraState.active.length ||
        (kv && (kv.bits !== 4 || kv.groupSize !== 64)) || (globalThis as Record<string, unknown>).__deltaProf)
      return super.forwardLayers(h0, cache, independentRows, positions);
    const L = h0.shape[1]!;
    const faMask = cache[this.faIdx]!.makeMask(L, null);
    if (faMask.arr) {
      faMask.arr.dispose();
      return super.forwardLayers(h0, cache, independentRows, positions);
    }
    using ssmMask = (cache[0] as SSMCache).prefillPadding?.makeMask(L) ?? null;
    const steps = this.#planFor(L), bounded = L > 8;
    let h: MlxArray | null = h0;
    try {
      for (let i = 0; i < steps.length; i++) {
        const next = steps[i]!(h, faMask, cache[i]!, independentRows, ssmMask);
        h.dispose();
        h = next;
        if (!bounded && i % ASYNC_EVERY === ASYNC_EVERY - 1 && i + 1 < steps.length) ops.asyncEvalAll([h]);
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
    } finally { h?.dispose(); }
  }
}
