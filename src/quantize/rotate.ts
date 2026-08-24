// Rotation folding for weight quantization (TurboQuant weights, W0/W2).
//
// Folds an orthogonal rotation offline into producer/consumer weight pairs so
// weights are quantized in a basis where outlier channels are smeared into
// near-Gaussian marginals. Recipe, fold table, and the decided deviations from
// the QuaRot/SpinQuant references live in docs/design/turboquant.md —
// notably: γ-fold FIRST (R1 only commutes with gain-free RMSNorm), SpinQuant's
// fully-offline per-head R2 (NOT QuaRot's, which needs a runtime op), NO R4
// half-fold on down_proj's input, NO embedding mean-centering (not an exact
// invariance for RMSNorm models; our gate is logit parity).
//
// R1 = diag(s)·H_n/√n (randomized Hadamard, QuIP#-style), R2 = per-layer
// diag(s₂)·H_d/√d over head_dim. Both require power-of-two dims (mlx
// hadamard_transform); the Kronecker path for other sizes is not implemented
// yet — callers get a clear throw. Folds run in f32 (weights are bf16; the
// references' f64 is fp16-era caution) and cast back to bf16 at the end.
//
// Memory discipline matches the quantizer: every returned array is a LAZY
// graph over the source mmap — the safetensors writer materializes one tensor
// at a time at insert.

import type { MlxArray } from "../mlx/array";
import { MlxArray as Arr } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { Weights } from "../weights";
import type { NamedTensor } from "./safetensors-writer";

/** Deterministic ±1 sign vector — splitmix32 over (seed, lane), so a given
 *  (seed, n, lane) always yields the same signs on every machine. `lane`
 *  separates R1 from each layer's R2 without sign reuse. */
export function signVector(seed: number, n: number, lane: number): Float32Array {
  let state = (seed ^ Math.imul(lane + 1, 0x9e3779b9)) >>> 0;
  const out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    state = (state + 0x9e3779b9) >>> 0;
    let z = state;
    z = Math.imul(z ^ (z >>> 16), 0x21f0aaad);
    z = Math.imul(z ^ (z >>> 15), 0x735a2d97);
    z ^= z >>> 15;
    out[i] = (z & 1) === 0 ? 1 : -1;
  }
  return out;
}

function assertPow2(n: number, what: string): void {
  if (n < 2 || (n & (n - 1)) !== 0)
    throw new Error(
      `rotation fold: ${what}=${n} is not a power of two — the Kronecker ` +
      `Hadamard path is not implemented (docs/design/turboquant.md)`,
    );
}

/** Dispose every argument; returns nothing. Chain hygiene for lazy folds. */
function drop(...arrays: MlxArray[]): void {
  for (const a of arrays) a.dispose();
}

/** x @ (diag(vec)·H/√n) along the LAST axis, in f32. `vec` carries the R1/R2
 *  signs, optionally pre-multiplied with a folded γ. Input may be any float
 *  dtype; output is f32 (caller casts once at the end of its chain). */
function foldLastAxis(x: MlxArray, vec: MlxArray): MlxArray {
  const n = x.shape[x.shape.length - 1]!;
  const f32 = x.astype(Dtype.float32);
  const scaled = ops.mul(f32, vec);
  const h = ops.hadamardTransform(scaled, 1 / Math.sqrt(n));
  drop(f32, scaled);
  return h;
}

/** W' = W @ R1 (input-dim fold; readers of the residual stream). */
function foldInputDim(w: MlxArray, vec: MlxArray): MlxArray {
  return foldLastAxis(w, vec);
}

/** W' = R1ᵀ @ W (output-dim fold; writers of the residual stream). H is
 *  symmetric (Sylvester), so this is the last-axis fold applied to Wᵀ. */
function foldOutputDim(w: MlxArray, vec: MlxArray): MlxArray {
  const t = ops.transposeAxes(w, [1, 0]);
  const h = foldLastAxis(t, vec);
  const back = ops.transposeAxes(h, [1, 0]);
  drop(t, h);
  return back;
}

/** Per-head R2 on the last axis: reshape [..., heads·d] → [..., heads, d],
 *  fold, reshape back. blockdiag(R2) with the same R2 for every head. */
function foldHeadsLastAxis(x: MlxArray, s2: MlxArray, headDim: number): MlxArray {
  const shape = x.shape;
  const last = shape[shape.length - 1]!;
  const heads = last / headDim;
  if (!Number.isInteger(heads))
    throw new Error(`rotation fold: last axis ${last} not divisible by head_dim ${headDim}`);
  const split = ops.reshape(x, [...shape.slice(0, -1), heads, headDim]);
  const h = foldLastAxis(split, s2);
  const merged = ops.reshape(h, shape);
  drop(split, h);
  return merged;
}

export interface FoldGeometry {
  numLayers: number;
  hiddenSize: number;
  numHeads: number;
  numKvHeads: number;
  headDim: number;
}

export interface FoldOptions {
  seed: number;
  /** Apply the R1 residual-stream fold (default true). */
  r1?: boolean;
  /** Apply the per-layer SpinQuant-style R2 v/o fold (default true). */
  r2?: boolean;
}

export interface FoldResult {
  tensors: NamedTensor[];
  /** Provenance for the sidecar: what was folded, with which signs. */
  meta: {
    seed: number;
    r1: boolean;
    r2: boolean;
    hiddenSize: number;
    headDim: number;
    deviations: string[];
  };
}

/** Lane ids for signVector: R1 is lane 0, layer i's R2 is lane i+1. */
const R1_LANE = 0;

/** R1ᵀ·b for a 1-D bias vector: bᵀ·R1 holds the same numbers. */
function foldBias(b: MlxArray, vec: MlxArray): MlxArray {
  return foldLastAxis(b, vec);
}

/**
 * Fold a Llama-family model (tensor names model.embed_tokens / model.layers.N.
 * {input_layernorm, post_attention_layernorm, self_attn.{q,k,v,o}_proj,
 * mlp.{gate,up,down}_proj} / model.norm) per the turboquant-weights recipe:
 * untie → γ-fold → R1 → R2. Returns lazy bf16 tensors for the writer, with
 * norm gains replaced by ones and a separate folded lm_head (untied).
 */
export function foldLlamaWeights(
  weights: Weights,
  geo: FoldGeometry,
  opts: FoldOptions,
): FoldResult {
  const r1 = opts.r1 ?? true;
  const r2 = opts.r2 ?? true;
  const { numLayers, hiddenSize, headDim } = geo;
  if (r1) assertPow2(hiddenSize, "hidden_size");
  if (r2) assertPow2(headDim, "head_dim");

  const required = ["model.embed_tokens.weight", "model.norm.weight"];
  for (const name of required)
    if (!weights.has(name)) throw new Error(`rotation fold: missing tensor ${name}`);
  if (weights.has("lm_head.weight"))
    throw new Error(
      "rotation fold: model already has an untied lm_head — the tied-embedding " +
      "untie step in this fold would clobber it; teach foldLlamaWeights the " +
      "untied case before folding this model",
    );

  // R1 signs (f32 leaf, shared by every R1 fold site). With r1 off, the fold
  // degenerates to identity via an all-ones "signs" vector and no Hadamard —
  // handled by branching instead, to keep the off-arm byte-identical.
  const s1 = Arr.fromFloat32(signVector(opts.seed, hiddenSize, R1_LANE), [hiddenSize]);

  /** γ (bf16 [n]) → f32, optionally ⊙ signs — the per-column premultiplier. */
  const gammaVec = (normName: string, withSigns: boolean): MlxArray => {
    const g = weights.tensor(normName).astype(Dtype.float32);
    if (!withSigns) return g;
    const gs = ops.mul(g, s1);
    g.dispose();
    return gs;
  };

  /** Finish a chain: cast to bf16 and drop the f32 head. */
  const toBf16 = (x: MlxArray): MlxArray => {
    const out = x.astype(Dtype.bfloat16);
    x.dispose();
    return out;
  };

  /** Input-side reader fold: W ⊙ γcols then @R1 (or γ-only when r1 off). */
  const readerFold = (w: MlxArray, vec: MlxArray): MlxArray => {
    if (r1) return foldLastAxis(w, vec);
    const f32 = w.astype(Dtype.float32);
    const scaled = ops.mul(f32, vec);
    f32.dispose();
    return scaled;
  };

  const onesLike = (n: number): MlxArray => {
    const ones = Arr.fromFloat32(new Float32Array(n).fill(1), [n]);
    const out = ones.astype(Dtype.bfloat16);
    ones.dispose();
    return out;
  };

  const tensors: NamedTensor[] = [];

  // Embeddings: write the residual stream → @R1, no γ. lm_head: read the
  // residual after the final norm → γ_final then @R1 — from the SAME source
  // tensor (untie), two independent lazy chains.
  const embed = weights.tensor("model.embed_tokens.weight");
  if (r1) {
    tensors.push({ name: "model.embed_tokens.weight", array: toBf16(foldInputDim(embed, s1)) });
  } else {
    tensors.push({ name: "model.embed_tokens.weight", array: embed });
  }
  const gFinal = gammaVec("model.norm.weight", r1);
  tensors.push({ name: "lm_head.weight", array: toBf16(readerFold(embed, gFinal)) });
  gFinal.dispose();
  tensors.push({ name: "model.norm.weight", array: onesLike(hiddenSize) });

  for (let i = 0; i < numLayers; i++) {
    const L = `model.layers.${i}`;
    const s2 = r2
      ? Arr.fromFloat32(signVector(opts.seed, headDim, i + 1), [headDim])
      : null;

    const gIn = gammaVec(`${L}.input_layernorm.weight`, r1);
    const gPost = gammaVec(`${L}.post_attention_layernorm.weight`, r1);

    for (const p of ["q_proj", "k_proj"]) {
      const w = weights.tensor(`${L}.self_attn.${p}.weight`);
      tensors.push({ name: `${L}.self_attn.${p}.weight`, array: toBf16(readerFold(w, gIn)) });
    }

    // v_proj: reader fold on the input dim, then per-head R2ᵀ on the output
    // dim (via the transposed layout, matching SpinQuant's apply order).
    {
      const w = weights.tensor(`${L}.self_attn.v_proj.weight`);
      const folded = readerFold(w, gIn);
      if (s2) {
        const t = ops.transposeAxes(folded, [1, 0]);
        const h = foldHeadsLastAxis(t, s2, headDim);
        const back = ops.transposeAxes(h, [1, 0]);
        drop(folded, t, h);
        tensors.push({ name: `${L}.self_attn.v_proj.weight`, array: toBf16(back) });
      } else {
        tensors.push({ name: `${L}.self_attn.v_proj.weight`, array: toBf16(folded) });
      }
    }

    // o_proj: per-head R2 on the input dim, R1ᵀ on the output dim. No γ (its
    // input is the attention context, not a norm output). NO full-Hadamard
    // input fold — that is QuaRot's online-op pairing, excluded by design.
    {
      const w = weights.tensor(`${L}.self_attn.o_proj.weight`);
      let cur: MlxArray = w;
      const owned: MlxArray[] = [];
      if (s2) {
        cur = foldHeadsLastAxis(cur, s2, headDim);
        owned.push(cur);
      }
      if (r1) {
        cur = foldOutputDim(cur, s1);
        owned.push(cur);
      }
      if (owned.length === 0) {
        tensors.push({ name: `${L}.self_attn.o_proj.weight`, array: w });
      } else {
        const final = toBf16(cur);
        drop(...owned.slice(0, -1));
        tensors.push({ name: `${L}.self_attn.o_proj.weight`, array: final });
      }
    }

    for (const p of ["gate_proj", "up_proj"]) {
      const w = weights.tensor(`${L}.mlp.${p}.weight`);
      tensors.push({ name: `${L}.mlp.${p}.weight`, array: toBf16(readerFold(w, gPost)) });
    }

    // down_proj: R1ᵀ on the output dim ONLY. Deliberately no input-dim
    // Hadamard — the references' rotate_mlp_output folds the offline half of
    // R4 here, which is only valid with their runtime activation Hadamard.
    {
      const w = weights.tensor(`${L}.mlp.down_proj.weight`);
      if (r1) {
        tensors.push({ name: `${L}.mlp.down_proj.weight`, array: toBf16(foldOutputDim(w, s1)) });
      } else {
        tensors.push({ name: `${L}.mlp.down_proj.weight`, array: w });
      }
    }

    // γ is folded into consumers in EVERY mode (r1 only decides whether the
    // signs ride along) — the module gains are always ones afterward.
    tensors.push({ name: `${L}.input_layernorm.weight`, array: onesLike(hiddenSize) });
    tensors.push({ name: `${L}.post_attention_layernorm.weight`, array: onesLike(hiddenSize) });

    drop(gIn, gPost);
    s2?.dispose();
  }

  s1.dispose();

  return {
    tensors,
    meta: {
      seed: opts.seed,
      r1,
      r2,
      hiddenSize,
      headDim,
      deviations: [
        "no-embedding-mean-centering",
        "no-R4-downproj-input-fold",
        "no-R3",
        "gamma-kept-in-module-as-ones (eps preserved)",
        "fold-precision-f32",
      ],
    },
  };
}

// ---------------------------------------------------------------------------
// qwen3_5 (Qwen 3.8 family): hybrid DeltaNet/full-attention VL trunk + MTP
// companion. R1-ONLY (+γ): the attention output gate (`o_proj(out · σ(gate))`,
// elementwise in head space) does not commute with a per-head rotation, so R2
// is architecturally off for this family — recorded in the design doc.
//
// Residual corridors (docs/design/turboquant.md, W1 map):
//   readers  (@R1 input dim, γ premultiplied): q/k/v_proj,
//     linear_attn.in_proj_{qkv,z,b,a}, mlp.gate/up_proj, lm_head
//   writers  (R1ᵀ output dim): self_attn.o_proj, linear_attn.out_proj,
//     mlp.down_proj, vision_tower.merger.linear_fc2 (weight + bias — the ONLY
//     place the vision tower touches the residual basis; deepstack is empty
//     for qwen3_5 and not ported)
//   untouched (internal bases): q/k_norm, linear_attn.{norm,A_log,conv1d,
//     dt_bias}, the whole pre-merger vision tower
// ---------------------------------------------------------------------------

export interface QwenFoldOptions {
  seed: number;
  /** Tensor-name prefix of the language model ("language_model." for the VL
   *  wrapper trunk; "" would be a bare text model). */
  prefix?: string;
}

/** Fold a qwen3_5 VL trunk (or text-only model when it has no vision tower).
 *  Handles both tied (clones an untied folded lm_head) and untied heads. */
export type FoldOp =
  | { kind: "passthrough" }
  | { kind: "ones"; n: number }
  /** Reader: fold the last (input) axis; γ (by tensor name) premultiplied. */
  | { kind: "input"; gamma?: string }
  /** Writer: R1ᵀ on the output axis of a 2-D [out, in] weight. */
  | { kind: "output" }
  /** Writer bias: R1ᵀ on a 1-D vector. */
  | { kind: "bias" }
  /** MTP fc [H, 2H]: per-block input folds (embed γ, hidden γ) + output fold. */
  | { kind: "mtp-fc"; gammaEmbed: string; gammaHidden: string };

export interface QwenFoldPlan {
  ops: Map<string, FoldOp>;
  /** Names of the γ tensors the executor must preload (tiny, held for the
   *  whole walk so shard release never invalidates them). */
  gammaNames: string[];
  /** Tied-embedding case: emit an extra folded lm_head cloned from `from`. */
  extraHead: { name: string; from: string; gamma: string } | null;
  deviations: string[];
}

/**
 * Classify every tensor of a qwen3_5 VL trunk (or its MTP companion) into a
 * FoldOp — pure name analysis, no arrays. R1-ONLY (+γ): the attention output
 * gate (`o_proj(out · σ(gate))`, elementwise in head space) does not commute
 * with a per-head rotation, so R2 is architecturally off for this family.
 * Corridor map: docs/design/turboquant.md §W1.
 */
export function planQwen35Fold(names: readonly string[], prefix = "language_model."): QwenFoldPlan {
  const P = prefix;
  const has = new Set(names);
  const ops_ = new Map<string, FoldOp>();
  const gammaNames = new Set<string>();
  const finalNorm = `${P}model.norm.weight`;
  const embed = `${P}model.embed_tokens.weight`;
  const head = `${P}lm_head.weight`;
  if (!has.has(embed) || !has.has(finalNorm))
    throw new Error(`qwen fold plan: missing ${embed} or ${finalNorm}`);

  ops_.set(embed, { kind: "input" });
  ops_.set(finalNorm, { kind: "ones", n: 0 });
  gammaNames.add(finalNorm);
  let extraHead: QwenFoldPlan["extraHead"] = null;
  if (has.has(head)) ops_.set(head, { kind: "input", gamma: finalNorm });
  else extraHead = { name: head, from: embed, gamma: finalNorm };

  for (let i = 0; ; i++) {
    const L = `${P}model.layers.${i}`;
    const inNorm = `${L}.input_layernorm.weight`;
    if (!has.has(inNorm)) break;
    const postNorm = `${L}.post_attention_layernorm.weight`;
    ops_.set(inNorm, { kind: "ones", n: 0 });
    ops_.set(postNorm, { kind: "ones", n: 0 });
    gammaNames.add(inNorm);
    gammaNames.add(postNorm);

    const attnReaders = has.has(`${L}.self_attn.q_proj.weight`)
      ? ["self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj"]
      : ["linear_attn.in_proj_qkv", "linear_attn.in_proj_z", "linear_attn.in_proj_b", "linear_attn.in_proj_a"];
    const writer = attnReaders[0]!.startsWith("self_attn")
      ? "self_attn.o_proj" : "linear_attn.out_proj";
    for (const r of attnReaders) ops_.set(`${L}.${r}.weight`, { kind: "input", gamma: inNorm });
    ops_.set(`${L}.${writer}.weight`, { kind: "output" });
    for (const r of ["mlp.gate_proj", "mlp.up_proj"])
      ops_.set(`${L}.${r}.weight`, { kind: "input", gamma: postNorm });
    ops_.set(`${L}.mlp.down_proj.weight`, { kind: "output" });
  }

  // Vision: the merger's final projection is the ONLY vision→residual seam
  // (deepstack is empty for qwen3_5). Everything else passes through bf16.
  if (has.has("vision_tower.merger.linear_fc2.weight")) {
    ops_.set("vision_tower.merger.linear_fc2.weight", { kind: "output" });
    ops_.set("vision_tower.merger.linear_fc2.bias", { kind: "bias" });
  }

  for (const n of names) if (!ops_.has(n)) ops_.set(n, { kind: "passthrough" });
  return {
    ops: ops_,
    gammaNames: [...gammaNames],
    extraHead,
    deviations: [
      "no-R2 (attn_output_gate does not commute with per-head rotation)",
      "no-embedding-mean-centering", "no-R4-downproj-input-fold", "no-R3",
      "gamma-kept-in-module-as-ones (eps preserved)", "fold-precision-f32",
      "vision folded at merger.linear_fc2 only (deepstack empty)",
    ],
  };
}

/** Plan for the MTP companion (same seed/R1 as its trunk — shared residual
 *  basis). The final `norm` γ is DROPPED (→ ones): it feeds the shared trunk
 *  lm_head which already carries the trunk's final γ; draft logits see
 *  γ_trunk instead of γ_mtp — draft-quality-only (target path exact). */
export function planQwenMtpFold(names: readonly string[]): QwenFoldPlan {
  const has = new Set(names);
  const ops_ = new Map<string, FoldOp>();
  const gammaNames = new Set<string>();
  for (const req of ["fc.weight", "pre_fc_norm_embedding.weight", "pre_fc_norm_hidden.weight", "norm.weight"])
    if (!has.has(req)) throw new Error(`mtp fold plan: missing ${req}`);

  ops_.set("fc.weight", {
    kind: "mtp-fc",
    gammaEmbed: "pre_fc_norm_embedding.weight",
    gammaHidden: "pre_fc_norm_hidden.weight",
  });
  gammaNames.add("pre_fc_norm_embedding.weight");
  gammaNames.add("pre_fc_norm_hidden.weight");
  ops_.set("pre_fc_norm_embedding.weight", { kind: "ones", n: 0 });
  ops_.set("pre_fc_norm_hidden.weight", { kind: "ones", n: 0 });
  ops_.set("norm.weight", { kind: "ones", n: 0 });

  for (let i = 0; ; i++) {
    const L = `layers.${i}`;
    const inNorm = `${L}.input_layernorm.weight`;
    if (!has.has(inNorm)) break;
    const postNorm = `${L}.post_attention_layernorm.weight`;
    ops_.set(inNorm, { kind: "ones", n: 0 });
    ops_.set(postNorm, { kind: "ones", n: 0 });
    gammaNames.add(inNorm);
    gammaNames.add(postNorm);
    for (const r of ["self_attn.q_proj", "self_attn.k_proj", "self_attn.v_proj"])
      ops_.set(`${L}.${r}.weight`, { kind: "input", gamma: inNorm });
    ops_.set(`${L}.self_attn.o_proj.weight`, { kind: "output" });
    for (const r of ["mlp.gate_proj", "mlp.up_proj"])
      ops_.set(`${L}.${r}.weight`, { kind: "input", gamma: postNorm });
    ops_.set(`${L}.mlp.down_proj.weight`, { kind: "output" });
  }

  for (const n of names) if (!ops_.has(n)) ops_.set(n, { kind: "passthrough" });
  return {
    ops: ops_,
    gammaNames: [...gammaNames],
    extraHead: null,
    deviations: [
      "mtp-final-gamma-dropped (draft logits see trunk final γ — draft-quality-only)",
      "no-R2", "fold-precision-f32",
    ],
  };
}

/** Executor state for a streaming qwen fold: owns s1 and the (tiny, owned-f32)
 *  γ table, so source shards can be released freely mid-walk. */
export class QwenFoldContext {
  readonly #s1: MlxArray;
  readonly #gammas = new Map<string, MlxArray>();
  readonly #gammaTimesS1 = new Map<string, MlxArray>();
  readonly hiddenSize: number;
  readonly #eager: boolean;

  constructor(
    weights: Weights,
    hiddenSize: number,
    seed: number,
    gammaNames: string[],
    eager = true,
  ) {
    assertPow2OrKron(hiddenSize);
    this.hiddenSize = hiddenSize;
    this.#eager = eager;
    this.#s1 = Arr.fromFloat32(signVector(seed, hiddenSize, R1_LANE), [hiddenSize]);
    for (const name of gammaNames) {
      // Owned f32 copy. Streaming scripts evaluate it immediately before
      // releasing source shards; the integrated quantizer keeps it lazy.
      const g = weights.tensor(name).astype(Dtype.float32);
      if (this.#eager) g.eval();
      this.#gammas.set(name, g);
    }
  }

  #vec(gamma?: string): MlxArray {
    if (!gamma) return this.#s1;
    let v = this.#gammaTimesS1.get(gamma);
    if (!v) {
      const g = this.#gammas.get(gamma);
      if (!g) throw new Error(`fold context: γ ${gamma} not preloaded`);
      v = ops.mul(g, this.#s1);
      if (this.#eager) v.eval();
      this.#gammaTimesS1.set(gamma, v);
    }
    return v;
  }

  /** Apply `op` to `src`, returning an EVALUATED bf16 array the caller owns.
   *  Never disposes src (the source shard map owns it). */
  apply(op: FoldOp, src: MlxArray): MlxArray {
    switch (op.kind) {
      case "passthrough": {
        // Copy out of the shard map so the shard can be released: astype to
        // the same dtype is a cheap materializing copy.
        const copy = src.astype(src.dtype);
        if (this.#eager) copy.eval();
        return copy;
      }
      case "ones": {
        const n = src.shape[0]!;
        const ones = Arr.fromFloat32(new Float32Array(n).fill(1), [n]);
        const out = ones.astype(Dtype.bfloat16);
        if (this.#eager) out.eval();
        ones.dispose();
        return out;
      }
      case "input": {
        const h = foldLastAxis(src, this.#vec(op.gamma));
        const out = h.astype(Dtype.bfloat16);
        if (this.#eager) out.eval();
        h.dispose();
        return out;
      }
      case "output": {
        const h = foldOutputDim(src, this.#s1);
        const out = h.astype(Dtype.bfloat16);
        if (this.#eager) out.eval();
        h.dispose();
        return out;
      }
      case "bias": {
        const h = foldBias(src, this.#s1);
        const out = h.astype(Dtype.bfloat16);
        if (this.#eager) out.eval();
        h.dispose();
        return out;
      }
      case "mtp-fc": {
        const H = this.hiddenSize;
        const [b0, b1] = ops.split(src, [H], 1) as [MlxArray, MlxArray];
        const f0 = foldLastAxis(b0, this.#vec(op.gammaEmbed));
        const f1 = foldLastAxis(b1, this.#vec(op.gammaHidden));
        const joined = ops.concatAxis([f0, f1], 1);
        const h = foldOutputDim(joined, this.#s1);
        const out = h.astype(Dtype.bfloat16);
        if (this.#eager) out.eval();
        drop(b0, b1, f0, f1, joined, h);
        return out;
      }
    }
  }

  dispose(): void {
    this.#s1.dispose();
    for (const g of this.#gammas.values()) g.dispose();
    for (const v of this.#gammaTimesS1.values()) v.dispose();
    this.#gammas.clear();
    this.#gammaTimesS1.clear();
  }
}

/** mlx hadamard_transform accepts n = m·2^k for m ∈ {1, 12, 20, 28} —
 *  equivalently: odd part ∈ {1, 3, 5, 7} with at least 4 | n when odd > 1
 *  (verified live at n=5120 = 20·256). */
function assertPow2OrKron(n: number): void {
  let odd = n;
  let twos = 0;
  while (odd % 2 === 0) { odd /= 2; twos++; }
  const ok = odd === 1 || ([3, 5, 7].includes(odd) && twos >= 2);
  if (!ok)
    throw new Error(`rotation fold: hidden_size ${n} is not m·2^k with m ∈ {1,12,20,28}`);
}
