// DFlash 2 drafter for Qwen3.8-27B (incoai/Qwen3.8-27B-DFlash2, Apache-2.0).
// Port of z-lab/dflash@07ebd93 `dflash/model_mlx.py` (DFlash2DraftModel),
// cross-checked against Splash `runtime/model/DFlashDraft.cpp`, SGLang PR
// #35371 and vLLM PR #52816. Five Qwen3-style layers draft one block
// [anchor, MASK×(G−1)] in a single pass:
//   context  c = hidden_norm(fc(concat(target layers 5,19,33,47,61)))
//            — each layer projects c with its own k/v (k_norm, RoPE at the
//            row's absolute position) into a K/V prefix the block attends to.
//   layer    n = rms(x); D = kernel_projection(n) → [stage, tap, group]
//            x += Conv₁(Attn(Conv₀(n)));  m = rms(x); D' from m
//            x += Conv₁(MLP(Conv₀(m)))
//            Conv(y)[t,c] = Σ_τ (base[τ,c] + D[t,τ,c/16])·y[t−τ,c], y[−1] = 0
//   output   rows 1..G−1 → norm → the TARGET's lm_head (the drafter has no
//            embedding or head of its own).
//   selector top-16 per position; greedy left-to-right walk scoring
//            logit + Σ_r pred[prev,r]·z[r]·succ[cand,r], z = hidden_projection(h).
// Attention is bidirectional within the block. The 2048-row sliding window
// over context is not applied: context longer than 2047 rows attends to all
// of it (verification keeps outputs exact; acceptance can drop).
//
// Target basis: a TurboQuant R1 fold stores the residual stream as h·R1,
// R1 = diag(s)·M with M = MLX's hadamard_transform/√n (x ↦ x·M), and folds the
// final-norm gain γ into the head. The drafter was trained on the unrotated
// model: taps reach fc as tap·R1ᵀ (folded into fc at load as fc·diag(s)·M),
// embedding rows are rotated back as (x·Mᵀ)⊙s, and draft hiddens enter the
// folded head as ((v/γ)⊙s)·M. For n = 5120 = 20·256, M is orthogonal but NOT
// symmetric, so x·Mᵀ needs the dense transpose, not a second transform.

import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { Weights } from "../../artifacts/weights";
import type { DraftProjection } from "../../contracts/mlx/draft-projection";
import type { Dflash2ContextAttention, Dflash2DrafterModel, Dflash2TargetBasis } from "../../contracts/mlx/drafter";
import { isDflash2Architecture } from "./dflash2-artifact";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { Affine4MmaLinear } from "../../layers/affine-verify-linear";

export interface Dflash2Config {
  hidden: number;
  layers: number;
  heads: number;
  kvHeads: number;
  headDim: number;
  eps: number;
  ropeTheta: number;
  blockSize: number;
  maskTokenId: number;
  convGroupSize: number;
  topK: number;
  targetLayerIds: number[];
  numTargetLayers: number;
}


/** A projection: BF16 (transposed), or quantized at load. 4-bit projections
 *  run 5..8-row inputs (a drafting block, a commit's accepted rows) on the
 *  simdgroup matrix unit and every other row count through MLX's quantized
 *  matmul. */
type MatW =
  | { kind: "bf16"; t: MlxArray }
  | { kind: "quant"; linear: QuantizedLinear; mma: Affine4MmaLinear | null };

function matmulW(x: MlxArray, m: MatW): MlxArray {
  if (m.kind === "bf16") return ops.matmul(x, m.t);
  const rows = x.size / x.shape.at(-1)!;
  return m.mma && rows >= 5 && rows <= 8 ? m.mma.forward(x) : m.linear.forward(x);
}
function quantW(source: MlxArray, bits: number): MatW {
  const q = ops.quantize(source, 64, bits);
  ops.evalAll([q.packed, q.scales, q.biases]);
  const linear = new QuantizedLinear(q.packed, q.scales, q.biases, { bits, groupSize: 64, mode: "affine" });
  const mma = bits === 4 && q.scales.shape[0]! % 8 === 0 && (q.scales.shape[1]! * 64) % 256 === 0 ? new Affine4MmaLinear(linear) : null;
  return { kind: "quant", linear, mma };
}
function disposeW(m: MatW): void {
  if (m.kind === "bf16") m.t.dispose();
  else { m.linear.w.dispose(); m.linear.scales.dispose(); m.linear.biases!.dispose(); }
}

interface Layer {
  inNorm: MlxArray; postNorm: MlxArray;
  q: MatW; k: MatW; v: MatW; o: MatW; qNorm: MlxArray; kNorm: MlxArray;
  gate: MatW; up: MatW; down: MatW;
  attnBase: MlxArray; attnProj: MatW; mlpBase: MlxArray; mlpProj: MatW;
}

function readConfig(raw: Record<string, any>): Dflash2Config {
  if (!isDflash2Architecture(raw.architectures))
    throw new Error(`Dflash2Drafter: expected architectures[0]==="DFlash2DraftModel", got ${JSON.stringify(raw.architectures)}`);
  const d = raw.dflash_config ?? {};
  if (d.conv_kernel_size !== 2) throw new Error(`Dflash2Drafter: conv_kernel_size ${d.conv_kernel_size} not implemented (two-tap only)`);
  if ((raw.rope_parameters?.rope_type ?? "default") !== "default") throw new Error("Dflash2Drafter: only default RoPE is implemented");
  return {
    hidden: raw.hidden_size, layers: raw.num_hidden_layers, heads: raw.num_attention_heads,
    kvHeads: raw.num_key_value_heads, headDim: raw.head_dim, eps: raw.rms_norm_eps,
    ropeTheta: raw.rope_parameters?.rope_theta ?? raw.rope_theta,
    blockSize: d.block_size, maskTokenId: d.mask_token_id, convGroupSize: d.conv_group_size,
    topK: d.selector_top_k, targetLayerIds: d.target_layer_ids, numTargetLayers: raw.num_target_layers,
  };
}

export class Dflash2Drafter implements Dflash2DrafterModel {
  readonly cfg: Dflash2Config;
  readonly tapLayers: number[];
  /** Draft tokens per block (block size minus the anchor). */
  readonly gamma: number;
  #w: Weights | null;
  #fc: MatW;
  #hiddenNorm: MlxArray;
  #norm: MlxArray;
  #selProj: MatW;
  #pred: MlxArray;
  #succ: MlxArray;
  #layers: Layer[] = [];
  #signs: MlxArray | null = null;
  #finalGain: MlxArray | null = null;
  /** Dense Mᵀ [H, H] (bf16; every entry is ±1/√H). */
  #hadamardT: MlxArray | null = null;

  private constructor(w: Weights, cfg: Dflash2Config, bits: number, basis: Dflash2TargetBasis | null) {
    this.#w = w;
    this.cfg = cfg;
    this.tapLayers = cfg.targetLayerIds;
    this.gamma = cfg.blockSize - 1;
    const T = (name: string) => w.tensor(name);
    // Splash quantizes projections only; convs, norms and codebooks stay BF16.
    const mat = (name: string, quantize: boolean): MatW => {
      if (!quantize || !bits) return { kind: "bf16", t: ops.transposeAxes(T(name), [1, 0]) };
      using source = T(name);
      return quantW(source, bits);
    };
    this.#fc = basis ? this.#foldedFc(T("fc.weight"), basis.signs, bits) : mat("fc.weight", true);
    this.#hiddenNorm = T("hidden_norm.weight");
    this.#norm = T("norm.weight");
    this.#selProj = mat("candidate_selector.hidden_projection.weight", false);
    this.#pred = T("candidate_selector.predecessor_codebook");
    this.#succ = T("candidate_selector.successor_codebook");
    for (let i = 0; i < cfg.layers; i++) {
      const p = `layers.${i}`;
      this.#layers.push({
        inNorm: T(`${p}.input_layernorm.weight`), postNorm: T(`${p}.post_attention_layernorm.weight`),
        q: mat(`${p}.self_attn.q_proj.weight`, true), k: mat(`${p}.self_attn.k_proj.weight`, true),
        v: mat(`${p}.self_attn.v_proj.weight`, true), o: mat(`${p}.self_attn.o_proj.weight`, true),
        qNorm: T(`${p}.self_attn.q_norm.weight`), kNorm: T(`${p}.self_attn.k_norm.weight`),
        gate: mat(`${p}.mlp.gate_proj.weight`, true), up: mat(`${p}.mlp.up_proj.weight`, true),
        down: mat(`${p}.mlp.down_proj.weight`, true),
        attnBase: this.#baseKernel(T(`${p}.attention_conv.base_kernel`)),
        attnProj: mat(`${p}.attention_conv.kernel_projection.weight`, false),
        mlpBase: this.#baseKernel(T(`${p}.mlp_conv.base_kernel`)),
        mlpProj: mat(`${p}.mlp_conv.kernel_projection.weight`, false),
      });
    }
    if (basis) {
      this.#signs = MlxArray.fromFloat32(basis.signs, [cfg.hidden]);
      this.#finalGain = MlxArray.fromFloat32(basis.finalGain, [cfg.hidden]);
      const eye = new Float32Array(cfg.hidden * cfg.hidden);
      for (let i = 0; i < cfg.hidden; i++) eye[i * cfg.hidden + i] = 1;
      using identity = MlxArray.fromFloat32(eye, [cfg.hidden, cfg.hidden]);
      using dense = ops.hadamardTransform(identity, 1 / Math.sqrt(cfg.hidden)); // rows e_i·M
      using transposed = ops.transposeAxes(dense, [1, 0]);
      using contiguous = ops.contiguous(transposed);
      this.#hadamardT = contiguous.astype(Dtype.bfloat16);
      this.#hadamardT.eval();
    }
    if (bits) this.#releaseCheckpoint();
  }

  /** Quantized projections own their storage; copy the remaining BF16 tensors
   *  out of the checkpoint map so its 3.85 GB mapping can be released. */
  #releaseCheckpoint(): void {
    const own = (a: MlxArray): MlxArray => {
      const copy = a.dtype === Dtype.float32 ? ops.contiguous(a) : ops.mulScalar(a, 1);
      copy.eval(); a.dispose(); return copy;
    };
    const ownW = (m: MatW): MatW => {
      if (m.kind !== "bf16") return m;
      const t = ops.contiguous(m.t); // materializes the transposed view
      t.eval(); m.t.dispose(); return { kind: "bf16", t };
    };
    this.#hiddenNorm = own(this.#hiddenNorm); this.#norm = own(this.#norm);
    this.#pred = own(this.#pred); this.#succ = own(this.#succ); this.#selProj = ownW(this.#selProj);
    for (const l of this.#layers) {
      l.inNorm = own(l.inNorm); l.postNorm = own(l.postNorm); l.qNorm = own(l.qNorm); l.kNorm = own(l.kNorm);
      l.attnBase = own(l.attnBase); l.mlpBase = own(l.mlpBase);
      l.attnProj = ownW(l.attnProj); l.mlpProj = ownW(l.mlpProj);
    }
    const w = this.#w!;
    w.dispose();
    for (const file of w.shards.files.values()) file.mmap.unmap();
    this.#w = null;
  }

  /** fc acting on target-basis taps: per tap block, fc_k·diag(s)·M (f32 fold). */
  #foldedFc(source: MlxArray, signs: Float32Array, bits: number): MatW {
    const H = this.cfg.hidden, m = this.cfg.targetLayerIds.length;
    using s = MlxArray.fromFloat32(signs, [H]);
    using f = source.astype(Dtype.float32);
    source.dispose();
    using blocks = ops.reshape(f, [H, m, H]);
    using signed = ops.mul(blocks, s);
    using rotated = ops.hadamardTransform(signed, 1 / Math.sqrt(H));
    using flat = ops.reshape(rotated, [H, m * H]);
    using folded = flat.astype(Dtype.bfloat16);
    if (!bits) {
      const t = ops.transposeAxes(folded, [1, 0]);
      t.eval();
      return { kind: "bf16", t };
    }
    return quantW(folded, bits);
  }

  /** `dir`: the drafter checkpoint. `bits` 0 keeps BF16 projections. */
  static async load(dir: string, opts: { bits?: number; basis?: Dflash2TargetBasis | null } = {}): Promise<Dflash2Drafter> {
    const raw = (await Bun.file(`${dir}/config.json`).json()) as Record<string, any>;
    const cfg = readConfig(raw);
    const w = await Weights.open(dir);
    try { return new Dflash2Drafter(w, cfg, opts.bits ?? 4, opts.basis ?? null); }
    catch (error) { w.dispose(); throw error; }
  }

  /** [stage, tap, H] base kernel as f32 [1, 1, stage, tap, H] for broadcasting. */
  #baseKernel(source: MlxArray): MlxArray {
    using f = source.astype(Dtype.float32);
    source.dispose();
    return ops.reshape(f, [1, 1, 2, 2, this.cfg.hidden]);
  }

  #rms(x: MlxArray, weight: MlxArray): MlxArray { return ops.rmsNorm(x, weight, this.cfg.eps); }

  /** x·R1ᵀ = (x·Mᵀ)⊙s over the last axis (target basis → drafter basis). */
  #fromTarget(x: MlxArray): MlxArray {
    if (!this.#signs) return ops.contiguous(x);
    using h = ops.matmul(x.dtype === Dtype.bfloat16 ? x : x.astype(Dtype.bfloat16), this.#hadamardT!);
    using back = ops.mul(h, this.#signs);
    return back.astype(x.dtype);
  }

  /** (v/γ)·R1 (drafter's normed hidden → input of the target's folded head). */
  #toTargetHead(v: MlxArray): MlxArray {
    if (!this.#signs) return ops.contiguous(v);
    const n = v.shape[v.shape.length - 1]!;
    using f = v.astype(Dtype.float32);
    using unscaled = ops.div(f, this.#finalGain!);
    using signed = ops.mul(unscaled, this.#signs);
    using h = ops.hadamardTransform(signed, 1 / Math.sqrt(n));
    return h.astype(v.dtype);
  }

  /** Per-row dynamic coefficients [B,G,stage,tap,H] (f32) for one conv site. */
  #coefficients(n: MlxArray, proj: MatW, base: MlxArray): MlxArray {
    const B = n.shape[0]!, G = n.shape[1]!, H = this.cfg.hidden, groups = H / this.cfg.convGroupSize;
    using d = matmulW(n, proj);
    using d32 = d.astype(Dtype.float32);
    using grouped = ops.reshape(d32, [B, G, 2, 2, groups, 1]);
    using wide = ops.broadcastTo(grouped, [B, G, 2, 2, groups, this.cfg.convGroupSize]);
    using perChannel = ops.reshape(wide, [B, G, 2, 2, H]);
    return ops.add(perChannel, base);
  }

  /** Two-tap conv of y [B,G,H] with stage `stage` of coef; f32 result. */
  #conv(y: MlxArray, coef: MlxArray, stage: number): MlxArray {
    const B = y.shape[0]!, G = y.shape[1]!, H = this.cfg.hidden;
    using c0 = coef.slice([0, 0, stage, 0, 0], [B, G, stage + 1, 1, H]);
    using c1 = coef.slice([0, 0, stage, 1, 0], [B, G, stage + 1, 2, H]);
    using t0 = ops.reshape(c0, [B, G, H]);
    using t1 = ops.reshape(c1, [B, G, H]);
    using y32 = y.astype(Dtype.float32);
    using head = ops.zeros([B, 1, H], Dtype.float32);
    using body = y32.slice([0, 0, 0], [B, G - 1, H]);
    using prev = ops.concatAxis([head, body], 1);
    using a = ops.mul(t0, y32);
    using b = ops.mul(t1, prev);
    return ops.add(a, b);
  }

  #rope(x: MlxArray, position: number | MlxArray): MlxArray {
    return typeof position === "number"
      ? ops.rope(x, this.cfg.headDim, this.cfg.ropeTheta, position, null)
      : ops.ropeDynamic(x, this.cfg.headDim, this.cfg.ropeTheta, position, null);
  }

  /** Target taps [B,L,5·H] (target basis; fc carries the R1 fold) → context rows [B,L,H]. */
  projectContext(taps: MlxArray): MlxArray {
    using projected = matmulW(taps, this.#fc);
    return this.#rms(projected, this.#hiddenNorm);
  }

  /** Context rows → per-layer K/V [B,kv,L,D] at absolute positions from `position`. */
  projectContextKVRows(context: MlxArray, position: number | MlxArray): { k: MlxArray; v: MlxArray }[] {
    const B = context.shape[0]!, L = context.shape[1]!, { kvHeads, headDim } = this.cfg;
    return this.#layers.map(layer => {
      using kFlat = matmulW(context, layer.k);
      using k4 = ops.reshape(kFlat, [B, L, kvHeads, headDim]);
      using kn = this.#rms(k4, layer.kNorm);
      using kT = ops.transposeAxes(kn, [0, 2, 1, 3]);
      using vFlat = matmulW(context, layer.v);
      using v4 = ops.reshape(vFlat, [B, L, kvHeads, headDim]);
      return { k: this.#rope(kT, position), v: ops.transposeAxes(v4, [0, 2, 1, 3]) };
    });
  }

  /** One block per anchor: up to `depth` (≤ gamma) greedy tokens per row. */
  draftRows(context: Dflash2ContextAttention, projection: DraftProjection, anchors: readonly number[],
    position: number | MlxArray, depth: number): number[][] {
    const steps = Math.min(this.cfg.blockSize, Math.max(1, depth) + 1) - 1;
    if (!steps) return anchors.map(() => []);
    using tokens = this.draftRowsDevice(context, projection, anchors, position, depth);
    const flat = tokens.toIntTokens();
    return anchors.map((_, row) => flat.slice(row * steps, (row + 1) * steps));
  }

  /** The same proposals left on the device: [B, steps] uint32, row-major. */
  draftRowsDevice(context: Dflash2ContextAttention, projection: DraftProjection, anchors: readonly number[],
    position: number | MlxArray, depth: number): MlxArray {
    const B = anchors.length, G = Math.min(this.cfg.blockSize, Math.max(1, depth) + 1);
    const { hidden: H, heads, kvHeads, headDim } = this.cfg;
    using ids = ops.fromInt32(anchors.flatMap(anchor => [anchor, ...Array(G - 1).fill(this.cfg.maskTokenId)]), [B, G]);
    using embedded = projection.embed.encode(ids);
    let x = this.#fromTarget(embedded);
    try {
      for (const [li, layer] of this.#layers.entries()) {
        {
          using n = this.#rms(x, layer.inNorm);
          using coef = this.#coefficients(n, layer.attnProj, layer.attnBase);
          using a32 = this.#conv(n, coef, 0);
          using a = a32.astype(x.dtype);
          using qFlat = matmulW(a, layer.q);
          using q4 = ops.reshape(qFlat, [B, G, heads, headDim]);
          using qn = this.#rms(q4, layer.qNorm);
          using qT = ops.transposeAxes(qn, [0, 2, 1, 3]);
          using q = this.#rope(qT, position);
          using kFlat = matmulW(a, layer.k);
          using k4 = ops.reshape(kFlat, [B, G, kvHeads, headDim]);
          using kn = this.#rms(k4, layer.kNorm);
          using kT = ops.transposeAxes(kn, [0, 2, 1, 3]);
          using k = this.#rope(kT, position);
          using vFlat = matmulW(a, layer.v);
          using v4 = ops.reshape(vFlat, [B, G, kvHeads, headDim]);
          using v = ops.transposeAxes(v4, [0, 2, 1, 3]);
          using attn = context.attend(li, q, k, v, 1 / Math.sqrt(headDim));
          using attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
          using attnFlat = ops.reshape(attnT, [B, G, heads * headDim]);
          using out = matmulW(attnFlat, layer.o);
          using finished = this.#conv(out, coef, 1);
          using x32 = x.astype(Dtype.float32);
          using sum = ops.add(x32, finished);
          x.dispose();
          x = sum.astype(embedded.dtype);
        }
        {
          using m = this.#rms(x, layer.postNorm);
          using coef = this.#coefficients(m, layer.mlpProj, layer.mlpBase);
          using inner32 = this.#conv(m, coef, 0);
          using inner = inner32.astype(x.dtype);
          using g = matmulW(inner, layer.gate);
          using u = matmulW(inner, layer.up);
          using act = ops.silu(g);
          using prod = ops.mul(act, u);
          using mlp = matmulW(prod, layer.down);
          using finished = this.#conv(mlp, coef, 1);
          using x32 = x.astype(Dtype.float32);
          using sum = ops.add(x32, finished);
          x.dispose();
          x = sum.astype(embedded.dtype);
        }
      }
      using rows = x.slice([0, 1, 0], [B, G, H]);
      using h = this.#rms(rows, this.#norm);
      using headInput = this.#toTargetHead(h);
      using logits = projection.logitsFromHidden(headInput);
      using z = matmulW(h, this.#selProj);
      using columns = this.#select(logits, z, anchors, G - 1); // [steps, B]
      using rowsMajor = ops.transposeAxes(columns, [1, 0]);
      return ops.contiguous(rowsMajor);
    } finally { x.dispose(); }
  }

  /** Greedy candidate-path walk (fp32 scores, as vLLM requires). */
  #select(logits: MlxArray, z: MlxArray, anchors: readonly number[], steps: number): MlxArray {
    const B = anchors.length, V = logits.shape[2]!, R = z.shape[2]!, K = this.cfg.topK;
    const tokens: MlxArray[] = [];
    using anchorIds = ops.fromInt32([...anchors], [B]);
    let previous = anchorIds.astype(Dtype.uint32);
    try {
      for (let p = 0; p < steps; p++) {
        using row = logits.slice([0, p, 0], [B, p + 1, V]);
        using flat = ops.reshape(row, [B, V]);
        using scores = flat.astype(Dtype.float32);
        using negated = ops.mulScalar(scores, -1);
        using order = ops.argpartitionAxis(negated, K - 1, -1);
        using local = order.slice([0, 0], [B, K]);
        using unary = ops.takeAlongAxis(scores, local, -1);
        const candidates = local;
        using zRow = z.slice([0, p, 0], [B, p + 1, R]);
        using zFlat = ops.reshape(zRow, [B, R]);
        using z32 = zFlat.astype(Dtype.float32);
        using predRows = ops.takeAxis(this.#pred, previous, 0);
        using pred32 = predRows.astype(Dtype.float32);
        using weighted = ops.mul(pred32, z32);
        using column = ops.reshape(weighted, [B, R, 1]);
        using candidateFlat = ops.reshape(candidates, [B * K]);
        using succRows = ops.takeAxis(this.#succ, candidateFlat, 0);
        using succ32 = succRows.astype(Dtype.float32);
        using succ3 = ops.reshape(succ32, [B, K, R]);
        using edge3 = ops.matmul(succ3, column);
        using edge = ops.reshape(edge3, [B, K]);
        using total = ops.add(unary, edge);
        using best = ops.argmaxAxis(total, -1);
        using bestCol = ops.reshape(best, [B, 1]);
        using chosen = ops.takeAlongAxis(candidates, bestCol, -1);
        const token = ops.reshape(chosen, [1, B]);
        tokens.push(token);
        previous.dispose();
        using flatToken = ops.reshape(token, [B]);
        previous = flatToken.astype(Dtype.uint32);
      }
      return ops.concatAxis(tokens, 0);
    } finally {
      previous.dispose();
      for (const token of tokens) token.dispose();
    }
  }

  dispose(): void {
    disposeW(this.#fc); disposeW(this.#selProj);
    this.#hiddenNorm.dispose(); this.#norm.dispose(); this.#pred.dispose(); this.#succ.dispose();
    for (const l of this.#layers) {
      l.inNorm.dispose(); l.postNorm.dispose(); l.qNorm.dispose(); l.kNorm.dispose();
      for (const m of [l.q, l.k, l.v, l.o, l.gate, l.up, l.down, l.attnProj, l.mlpProj]) disposeW(m);
      l.attnBase.dispose(); l.mlpBase.dispose();
    }
    this.#signs?.dispose(); this.#finalGain?.dispose(); this.#hadamardT?.dispose();
    this.#w?.dispose();
  }
}
