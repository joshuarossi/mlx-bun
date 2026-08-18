// Rotation folding for weight quantization (TurboQuant weights, W0/W2).
//
// Folds an orthogonal rotation offline into producer/consumer weight pairs so
// weights are quantized in a basis where outlier channels are smeared into
// near-Gaussian marginals. Recipe, fold table, and the decided deviations from
// the QuaRot/SpinQuant references live in docs/design/turboquant-weights.md —
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
      `Hadamard path is not implemented (docs/design/turboquant-weights.md)`,
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
