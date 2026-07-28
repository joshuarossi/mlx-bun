// GLM-5.2 DeepSeek Sparse Attention (DSA) correctness primitives.
//
// Projection/scoring has an MLX path for the model graph. The small host
// helpers are deliberately retained as the G2 correctness oracle and for the
// discrete threshold/tie decision, which Colibri itself performs on the CPU.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import {
  dsaScoresFromProjectedF32,
  matvecF32,
  partialInterleavedRopeF32,
  selectDsaThresholdTiesF32,
  type NumericVector,
  type OutputMajorMatrix,
} from "./glm52-reference";

export interface Glm52DsaGeometry {
  readonly numHeads: number;
  readonly headDim: number;
  /** GLM rotates only the first qk_rope_head_dim values of each index head. */
  readonly rotaryDimensions: number;
  readonly ropeTheta: number;
  readonly topK: number;
}

export interface Glm52DsaProjectionWeights {
  /** [numHeads * headDim, q_lora_rank] */
  readonly query: OutputMajorMatrix;
  /** [headDim, hidden_size] */
  readonly key: OutputMajorMatrix;
  /** [numHeads, hidden_size] */
  readonly headWeights: OutputMajorMatrix;
  /** Classical LayerNorm parameters for the projected index key. */
  readonly keyNormWeight: NumericVector;
  readonly keyNormBias: NumericVector;
}

export interface Glm52DsaProjectedQuery {
  readonly heads: Float32Array[];
  readonly headWeights: Float32Array;
}

export type Glm52DsaLayerSelection =
  | {
      readonly mode: "dense";
      readonly layer: number;
      readonly ownerLayer: number;
      readonly contextLength: number;
      readonly positions: null;
      readonly threshold: null;
    }
  | {
      readonly mode: "sparse";
      readonly layer: number;
      readonly ownerLayer: number;
      readonly contextLength: number;
      readonly positions: readonly number[];
      readonly threshold: number;
    };

function f32(value: number): number {
  return Math.fround(value);
}

function positiveInteger(value: number, label: string): number {
  if (!Number.isSafeInteger(value) || value < 1)
    throw new Error(`${label} must be a positive integer`);
  return value;
}

function nonNegativeInteger(value: number, label: string): number {
  if (!Number.isSafeInteger(value) || value < 0)
    throw new Error(`${label} must be a non-negative integer`);
  return value;
}

function validateGeometry(geometry: Glm52DsaGeometry): void {
  positiveInteger(geometry.numHeads, "DSA numHeads");
  positiveInteger(geometry.headDim, "DSA headDim");
  positiveInteger(geometry.topK, "DSA topK");
  if (
    !Number.isSafeInteger(geometry.rotaryDimensions) ||
    geometry.rotaryDimensions < 2 ||
    (geometry.rotaryDimensions & 1) !== 0 ||
    geometry.rotaryDimensions > geometry.headDim
  ) {
    throw new Error("DSA rotaryDimensions must be even and within headDim");
  }
  if (!Number.isFinite(geometry.ropeTheta) || geometry.ropeTheta <= 0)
    throw new Error("DSA ropeTheta must be finite and positive");
}

/**
 * Colibri's index-key norm is ordinary LayerNorm, not RMSNorm. Reductions are
 * accumulated in JS float64 just as Colibri accumulates them in C double; all
 * stored/intermediate scalar operations are rounded back to float32.
 */
export function glm52DsaKeyLayerNormF32(
  input: NumericVector,
  weight: NumericVector,
  bias: NumericVector,
  epsilon = 1e-6,
): Float32Array {
  positiveInteger(input.length, "DSA key length");
  if (weight.length !== input.length || bias.length !== input.length)
    throw new Error("DSA key LayerNorm parameters must match the key length");
  if (!Number.isFinite(epsilon) || epsilon < 0)
    throw new Error("DSA key LayerNorm epsilon must be finite and non-negative");

  let mean = 0;
  for (let index = 0; index < input.length; index++) {
    const value = input[index]!;
    if (!Number.isFinite(value)) throw new Error(`DSA key ${index} must be finite`);
    mean += value;
  }
  mean /= input.length;

  let variance = 0;
  for (let index = 0; index < input.length; index++) {
    const delta = input[index]! - mean;
    variance += delta * delta;
  }
  variance /= input.length;
  const inverseRoot = f32(1 / f32(Math.sqrt(f32(variance) + f32(epsilon))));

  return Float32Array.from({ length: input.length }, (_, index) => {
    const scale = weight[index]!;
    const offset = bias[index]!;
    if (!Number.isFinite(scale) || !Number.isFinite(offset))
      throw new Error(`DSA key LayerNorm parameter ${index} must be finite`);
    const centered = f32(input[index]! - mean);
    return f32(f32(f32(centered * inverseRoot) * scale) + offset);
  });
}

/** Project, normalize, and partially RoPE one index key. */
export function projectGlm52DsaKeyF32(
  hidden: NumericVector,
  position: number,
  weights: Glm52DsaProjectionWeights,
  geometry: Glm52DsaGeometry,
): Float32Array {
  validateGeometry(geometry);
  nonNegativeInteger(position, "DSA key position");
  const projected = matvecF32(hidden, weights.key);
  if (projected.length !== geometry.headDim)
    throw new Error(`DSA key projection rows ${projected.length} != headDim ${geometry.headDim}`);
  const normalized = glm52DsaKeyLayerNormF32(
    projected,
    weights.keyNormWeight,
    weights.keyNormBias,
  );
  return partialInterleavedRopeF32(
    normalized,
    position,
    geometry.rotaryDimensions,
    geometry.ropeTheta,
  );
}

/** Project and partially RoPE every query index head; project head weights. */
export function projectGlm52DsaQueryF32(
  qLora: NumericVector,
  hidden: NumericVector,
  position: number,
  weights: Glm52DsaProjectionWeights,
  geometry: Glm52DsaGeometry,
): Glm52DsaProjectedQuery {
  validateGeometry(geometry);
  nonNegativeInteger(position, "DSA query position");
  const flat = matvecF32(qLora, weights.query);
  const expected = geometry.numHeads * geometry.headDim;
  if (flat.length !== expected)
    throw new Error(`DSA query projection rows ${flat.length} != ${expected}`);

  const heads: Float32Array[] = [];
  for (let head = 0; head < geometry.numHeads; head++) {
    const start = head * geometry.headDim;
    heads.push(partialInterleavedRopeF32(
      flat.subarray(start, start + geometry.headDim),
      position,
      geometry.rotaryDimensions,
      geometry.ropeTheta,
    ));
  }
  const headWeights = matvecF32(hidden, weights.headWeights);
  if (headWeights.length !== geometry.numHeads)
    throw new Error(
      `DSA head-weight projection rows ${headWeights.length} != ${geometry.numHeads}`,
    );
  return { heads, headWeights };
}

/**
 * MLX data-plane score computation for already-projected tensors:
 * queryHeads [H,D], keys [T,D], headWeights [H] -> scores [T].
 *
 * The threshold/tie decision remains a bounded host control-path operation;
 * use Glm52DsaSelectionState after reading these scores.
 */
export function glm52DsaScoresMlx(
  queryHeads: MlxArray,
  keys: MlxArray,
  headWeights: MlxArray,
): MlxArray {
  const [heads, dimensions] = queryHeads.shape;
  const [positions, keyDimensions] = keys.shape;
  if (
    queryHeads.ndim !== 2 ||
    keys.ndim !== 2 ||
    headWeights.ndim !== 1 ||
    heads === undefined ||
    dimensions === undefined ||
    positions === undefined ||
    keyDimensions === undefined ||
    dimensions !== keyDimensions ||
    headWeights.shape[0] !== heads
  ) {
    throw new Error(
      "DSA MLX scores require queryHeads [H,D], keys [T,D], and headWeights [H]",
    );
  }

  const queryF32 = queryHeads.dtype === Dtype.float32
    ? queryHeads
    : queryHeads.astype(Dtype.float32);
  const keysF32 = keys.dtype === Dtype.float32 ? keys : keys.astype(Dtype.float32);
  const weightsF32 = headWeights.dtype === Dtype.float32
    ? headWeights
    : headWeights.astype(Dtype.float32);

  const query = ops.reshape(queryF32, [heads, 1, dimensions]);
  const key = ops.reshape(keysF32, [1, positions, dimensions]);
  const products = ops.mul(query, key);
  query.dispose();
  key.dispose();
  let dots = ops.sumAxis(products, -1, false);
  products.dispose();
  dots = replaceDisposed(dots, ops.mulScalar(dots, 1 / Math.sqrt(dimensions)));
  const zero = ops.scalarLike(0, dots);
  const relu = ops.maximum(dots, zero);
  dots.dispose();
  zero.dispose();
  const weights = ops.reshape(weightsF32, [heads, 1]);
  const weighted = ops.mul(relu, weights);
  relu.dispose();
  weights.dispose();
  let scores = ops.sumAxis(weighted, 0, false);
  weighted.dispose();
  scores = replaceDisposed(scores, ops.mulScalar(scores, 1 / Math.sqrt(heads)));

  if (queryF32 !== queryHeads) queryF32.dispose();
  if (keysF32 !== keys) keysF32.dispose();
  if (weightsF32 !== headWeights) weightsF32.dispose();
  return scores;
}

function replaceDisposed(oldValue: MlxArray, newValue: MlxArray): MlxArray {
  oldValue.dispose();
  return newValue;
}

/**
 * Exact G2 host correctness path: float32 score accumulation followed by
 * Colibri's threshold/tie selection. It is intentionally separate from the
 * MLX score graph so cross-kernel reduction drift cannot hide contract bugs.
 */
export function scoreAndSelectGlm52DsaF32(
  query: Glm52DsaProjectedQuery,
  keys: OutputMajorMatrix,
  topK: number,
): Glm52DsaLayerSelection {
  const state = new Glm52DsaSelectionState(topK);
  return state.selectFull(0, dsaScoresFromProjectedF32(query.heads, keys, query.headWeights));
}

/**
 * Carries Colibri's per-token latest-FULL selection across SHARED layers.
 * A zero selection count is represented explicitly as `mode: "dense"`.
 */
export class Glm52DsaSelectionState {
  readonly topK: number;
  #latest: Glm52DsaLayerSelection | null = null;

  constructor(topK: number) {
    this.topK = positiveInteger(topK, "DSA topK");
  }

  get latestFull(): Glm52DsaLayerSelection | null {
    return this.#latest;
  }

  reset(): void {
    this.#latest = null;
  }

  selectFull(layer: number, scores: NumericVector): Glm52DsaLayerSelection {
    nonNegativeInteger(layer, "DSA layer");
    positiveInteger(scores.length, "DSA context length");
    let selection: Glm52DsaLayerSelection;
    if (scores.length <= this.topK) {
      // Exact Colibri dense fallback: dsa_nsel=0 until nk > index_topk.
      selection = {
        mode: "dense",
        layer,
        ownerLayer: layer,
        contextLength: scores.length,
        positions: null,
        threshold: null,
      };
    } else {
      const chosen = selectDsaThresholdTiesF32(scores, this.topK);
      selection = {
        mode: "sparse",
        layer,
        ownerLayer: layer,
        contextLength: scores.length,
        positions: chosen.selected,
        threshold: chosen.threshold,
      };
    }
    this.#latest = selection;
    return selection;
  }

  selectShared(layer: number, contextLength: number): Glm52DsaLayerSelection {
    nonNegativeInteger(layer, "DSA layer");
    positiveInteger(contextLength, "DSA context length");
    const latest = this.#latest;
    if (latest === null)
      throw new Error("DSA shared layer has no preceding full-layer selection");
    if (latest.contextLength !== contextLength) {
      throw new Error(
        `DSA shared context length ${contextLength} != latest full ${latest.contextLength}`,
      );
    }
    return latest.mode === "dense"
      ? { ...latest, layer }
      : { ...latest, layer, positions: [...latest.positions] };
  }
}
