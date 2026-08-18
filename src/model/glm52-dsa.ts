// GLM-5.2 DeepSeek Sparse Attention (DSA) correctness primitives.
//
// Projection/scoring has an MLX path for the model graph. The small host
// helpers are deliberately retained as the G2 correctness oracle and for the
// discrete threshold/tie decision, which Colibri itself performs on the CPU.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
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

/**
 * Owned device result for one FULL-layer sparse selection. `positions` is the
 * compact int32/uint32 buffer shared by the following SHARED layers; neither
 * positions nor threshold is read back unless an explicit probe asks for it.
 */
export interface Glm52DsaDeviceSelection {
  readonly contextLength: number;
  readonly topK: number;
  readonly positions: MlxArray;
  readonly threshold: MlxArray;
  dispose(): void;
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

/** Debug/probe-only observer for selections computed by FULL indexer layers. */
export type Glm52DsaSelectionObserver = (
  selection: Glm52DsaLayerSelection,
) => void;

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

  // [H,D] @ [D,T] -> [H,T]. MLX tiles the contraction internally, avoiding
  // the correctness scaffold's materialized [H,T,D] broadcast product.
  const keyTranspose = ops.transposeAxes(keysF32, [1, 0]);
  let dots = ops.matmul(queryF32, keyTranspose);
  keyTranspose.dispose();
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

let dsaRankKeyKernel: MetalKernel | null = null;
let dsaContractOrderKeyKernel: MetalKernel | null = null;

function getDsaRankKeyKernel(): MetalKernel {
  if (!dsaRankKeyKernel) {
    dsaRankKeyKernel = new MetalKernel({
      name: "glm52_dsa_rank_key",
      inputNames: ["scores"],
      outputNames: ["keys"],
      source: `
        const uint i = thread_position_in_grid.x;
        const float score = scores[i];
        const uint bits = as_type<uint>(score);
        const uint ascending = (bits & 0x80000000u) != 0u
          ? ~bits
          : (bits ^ 0x80000000u);
        const uint descending = ~ascending;
        keys[i] = (ulong(descending) << 32) | ulong(i);
      `,
    });
  }
  return dsaRankKeyKernel;
}

function getDsaContractOrderKeyKernel(): MetalKernel {
  if (!dsaContractOrderKeyKernel) {
    dsaContractOrderKeyKernel = new MetalKernel({
      name: "glm52_dsa_contract_order_key",
      inputNames: ["selected_scores", "selected_positions", "threshold"],
      outputNames: ["keys"],
      source: `
        const uint i = thread_position_in_grid.x;
        const uint position = selected_positions[i];
        const uint threshold_class = selected_scores[i] > threshold ? 0u : 1u;
        keys[i] = (ulong(threshold_class) << 32) | ulong(position);
      `,
    });
  }
  return dsaContractOrderKeyKernel;
}

/**
 * Deterministic on-device equivalent of `selectDsaThresholdTiesF32`.
 *
 * The first uint64 key sorts by score descending and then position ascending,
 * making the top-k set deterministic even at the threshold. The second key
 * restores Colibri's observable two-scan order: all scores strictly above the
 * threshold in position order, followed by threshold ties in position order.
 * The caller owns the returned arrays and must call `dispose()` once the last
 * SHARED-layer consumer is done.
 */
export function selectGlm52DsaDevice(
  scores: MlxArray,
  topK: number,
): Glm52DsaDeviceSelection {
  if (scores.ndim !== 1)
    throw new Error("DSA device selection requires scores [context]");
  const contextLength = positiveInteger(scores.shape[0]!, "DSA context length");
  positiveInteger(topK, "DSA topK");
  if (topK >= contextLength)
    throw new Error("DSA device selection requires context length greater than topK");

  const scoresF32 = scores.dtype === Dtype.float32
    ? scores
    : scores.astype(Dtype.float32);
  const [rankKeys] = getDsaRankKeyKernel().apply([scoresF32], {
    outputs: [{ shape: [contextLength], dtype: Dtype.uint64 }],
    grid: [contextLength, 1, 1],
    threadGroup: [Math.min(256, contextLength), 1, 1],
  });
  const partition = ops.argpartitionAxis(rankKeys!, topK - 1, 0);
  const selectedUnordered = partition.slice([0], [topK]);
  const selectedScores = ops.takeAlongAxis(scoresF32, selectedUnordered, 0);
  const threshold = ops.minAxis(selectedScores, 0, false);
  const [orderKeys] = getDsaContractOrderKeyKernel().apply(
    [selectedScores, selectedUnordered, threshold],
    {
      outputs: [{ shape: [topK], dtype: Dtype.uint64 }],
      grid: [topK, 1, 1],
      threadGroup: [Math.min(256, topK), 1, 1],
    },
  );
  const order = ops.argsortAxis(orderKeys!, 0);
  const positions = ops.takeAlongAxis(selectedUnordered, order, 0);

  rankKeys!.dispose();
  partition.dispose();
  selectedUnordered.dispose();
  selectedScores.dispose();
  orderKeys!.dispose();
  order.dispose();
  if (scoresF32 !== scores) scoresF32.dispose();

  let disposed = false;
  return {
    contextLength,
    topK,
    positions,
    threshold,
    dispose(): void {
      if (disposed) return;
      disposed = true;
      positions.dispose();
      threshold.dispose();
    },
  };
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
  #latestDevices: Array<{
    readonly layer: number;
    readonly row: number;
    readonly contextLength: number;
    /** The only buffer retained across FULL -> SHARED layers. */
    readonly positions: MlxArray;
  }> = [];
  readonly #observer: Glm52DsaSelectionObserver | null;

  constructor(
    topK: number,
    observer: Glm52DsaSelectionObserver | null = null,
  ) {
    this.topK = positiveInteger(topK, "DSA topK");
    this.#observer = observer;
  }

  get latestFull(): Glm52DsaLayerSelection | null {
    return this.#latest;
  }

  reset(): void {
    for (const device of this.#latestDevices) device.positions.dispose();
    this.#latestDevices = [];
    this.#latest = null;
  }

  selectFull(layer: number, scores: NumericVector): Glm52DsaLayerSelection {
    for (const device of this.#latestDevices) device.positions.dispose();
    this.#latestDevices = [];
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
    if (this.#observer) {
      this.#observer(selection.mode === "dense"
        ? { ...selection }
        : { ...selection, positions: [...selection.positions] });
    }
    return selection;
  }

  /**
   * Benchmark-only control for constructing a long KV/index-key context in a
   * batched prefill without exercising the unfinished sparse-prefill path.
   * Decode calls still use `selectFullDevice` once they append one token.
   */
  selectFullDense(layer: number, contextLength: number): Glm52DsaLayerSelection {
    for (const device of this.#latestDevices) device.positions.dispose();
    this.#latestDevices = [];
    nonNegativeInteger(layer, "DSA layer");
    positiveInteger(contextLength, "DSA context length");
    const selection: Glm52DsaLayerSelection = {
      mode: "dense",
      layer,
      ownerLayer: layer,
      contextLength,
      positions: null,
      threshold: null,
    };
    this.#latest = selection;
    this.#observer?.({ ...selection });
    return selection;
  }

  /**
   * Production sparse path: keep the exact top-k and threshold on device and
   * retain the compact position buffer for the following SHARED layers. A
   * probe observer deliberately opts into the otherwise-absent host readback.
   */
  selectFullDevice(layer: number, scores: MlxArray, row = 0): MlxArray {
    nonNegativeInteger(layer, "DSA layer");
    nonNegativeInteger(row, "DSA row");
    const contextLength = positiveInteger(scores.shape[0]!, "DSA context length");
    if (scores.ndim !== 1)
      throw new Error("DSA device selection requires scores [context]");
    if (contextLength <= this.topK)
      throw new Error("DSA device selection requires sparse context");

    const previousLayer = this.#latestDevices[0]?.layer;
    if (previousLayer !== undefined && previousLayer !== layer) {
      for (const previous of this.#latestDevices) previous.positions.dispose();
      this.#latestDevices = [];
    }
    if (this.#latestDevices.some((entry) =>
      entry.layer === layer && entry.row === row &&
      entry.contextLength === contextLength
    )) {
      throw new Error(
        `DSA full layer ${layer} already selected context ${contextLength}`,
      );
    }
    const device = selectGlm52DsaDevice(scores, this.topK);
    this.#latest = null;

    try {
      if (this.#observer) {
        const host: Glm52DsaLayerSelection = {
          mode: "sparse",
          layer,
          ownerLayer: layer,
          contextLength,
          positions: device.positions.toIntTokens(),
          threshold: device.threshold.toFloat32()[0]!,
        };
        this.#latest = host;
        this.#observer({ ...host, positions: [...host.positions] });
      }
    } catch (error) {
      device.dispose();
      throw error;
    }
    // Threshold is needed to construct/order positions and for optional probe
    // readback only. Drop its wrapper now so state retains exactly one 8 KiB
    // index buffer, not a second root into the score graph.
    device.threshold.dispose();
    this.#latestDevices.push({ layer, row, contextLength, positions: device.positions });
    return device.positions;
  }

  /** Borrow the latest FULL selection without copying or re-uploading it. */
  selectSharedPositions(
    layer: number,
    contextLength: number,
    row = 0,
  ): MlxArray | null {
    nonNegativeInteger(layer, "DSA layer");
    nonNegativeInteger(row, "DSA row");
    positiveInteger(contextLength, "DSA context length");
    const device = this.#latestDevices.find(
      (entry) => entry.row === row && entry.contextLength === contextLength,
    );
    if (device) {
      return device.positions;
    }
    // A small verification batch may straddle the dense/sparse boundary. Its
    // sparse rows have device buffers while the earlier rows remain dense by
    // the model contract and therefore need no index vector.
    if (contextLength <= this.topK) return null;
    if (this.#latestDevices.length > 0) {
      throw new Error(
        `DSA shared context length ${contextLength} has no FULL selection`,
      );
    }
    const host = this.selectShared(layer, contextLength);
    if (host.mode === "sparse") {
      throw new Error("host DSA selection cannot be reused as a device buffer");
    }
    return null;
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

  dispose(): void {
    this.reset();
  }
}
