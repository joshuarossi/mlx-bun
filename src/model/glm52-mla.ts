// GLM-5.2 multi-head latent attention (MLA), correctness path.
//
// The checkpoint stores a compressed KV representation:
//   latent: [B, T, kv_lora_rank]
//   rope:   [B, T, qk_rope_head_dim]
//
// Prefill reconstructs per-head no-PE keys and values through kv_b_proj.
// Single-token decode absorbs the key/value projections around attention so
// the full per-head K/V history is never materialized.

import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import * as ops from "../mlx/ops";
import type { Glm52Config } from "./glm52-config";
import type { MLACompressedState, MLACache } from "./glm52-cache";
import type { ColibriGlm52Weights } from "./glm52-weights";

/** Structural seam used by tiny fixtures as well as ColibriGlm52Weights. */
export interface Glm52MlaWeightSource {
  tensor(name: string): MlxArray;
  dequantized(name: string, outputRows: number, inputColumns: number): MlxArray;
  linear(
    x: MlxArray,
    name: string,
    outputRows: number,
    inputColumns: number,
  ): MlxArray;
}

export interface Glm52MlaProjection {
  /** [B,T,H,qk_nope_head_dim]. */
  qNope: MlxArray;
  /** [B,T,H,qk_rope_head_dim], already rotated. */
  qRope: MlxArray;
  /** [B,T,kv_lora_rank], normalized compressed content state. */
  latent: MlxArray;
  /** [B,T,qk_rope_head_dim], already rotated. */
  rope: MlxArray;
}

export type Glm52MlaPath = "auto" | "reconstructed" | "absorbed";
export interface Glm52MlaBatchedSelection {
  readonly rows: readonly (MlxArray | null)[];
}
export type Glm52MlaSelectedPositions =
  | readonly number[]
  | MlxArray
  | Glm52MlaBatchedSelection
  | null;

function isBatchedSelection(
  value: Glm52MlaSelectedPositions,
): value is Glm52MlaBatchedSelection {
  return value !== null &&
    !(value instanceof MlxArray) &&
    !Array.isArray(value) &&
    "rows" in value;
}

function positiveInteger(name: string, value: number): void {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new Error(`${name} must be a positive safe integer`);
}

function sameShape(actual: readonly number[], expected: readonly number[]): boolean {
  return actual.length === expected.length &&
    actual.every((dimension, index) => dimension === expected[index]);
}

function validateShape(name: string, array: MlxArray, expected: readonly number[]): void {
  if (!sameShape(array.shape, expected))
    throw new Error(
      `${name} shape ${JSON.stringify(array.shape)} != ${JSON.stringify(expected)}`,
    );
}

function normalizedAxis(axis: number, rank: number): number {
  const result = axis < 0 ? rank + axis : axis;
  if (!Number.isSafeInteger(result) || result < 0 || result >= rank)
    throw new Error(`axis ${axis} is invalid for rank ${rank}`);
  return result;
}

/**
 * Exact GLM partial RoPE layout.
 *
 * The rotary prefix enters as pair-interleaved `[a0,b0,a1,b1,...]` and leaves
 * as split real/imaginary halves `[r0,r1,...,i0,i1,...]`. A non-rotary tail is
 * preserved. Positions advance along `tokenAxis`.
 */
export function partialInterleavedRopeMlx(
  input: MlxArray,
  positionOffset: number | readonly number[],
  rotaryDimensions: number,
  theta: number,
  tokenAxis = 1,
): MlxArray {
  const shape = input.shape;
  if (shape.length < 2)
    throw new Error("partial interleaved RoPE requires rank >= 2");
  const axis = normalizedAxis(tokenAxis, shape.length);
  if (axis === shape.length - 1)
    throw new Error("RoPE token axis cannot be the feature axis");
  const positionOffsets = typeof positionOffset === "number"
    ? null
    : [...positionOffset];
  if (positionOffsets) {
    if (axis === 0)
      throw new Error("per-row RoPE offsets require a separate token axis");
    if (positionOffsets.length !== shape[0])
      throw new Error(
        `RoPE row offsets ${positionOffsets.length} != batch ${shape[0]}`,
      );
    for (const offset of positionOffsets) {
      if (!Number.isSafeInteger(offset) || offset < 0)
        throw new Error("RoPE position offset must be a non-negative integer");
    }
  } else if (
    !Number.isSafeInteger(positionOffset) || (positionOffset as number) < 0
  ) {
    throw new Error("RoPE position offset must be a non-negative integer");
  }
  if (
    !Number.isSafeInteger(rotaryDimensions) ||
    rotaryDimensions <= 0 ||
    (rotaryDimensions & 1) !== 0 ||
    rotaryDimensions > shape.at(-1)!
  ) {
    throw new Error("RoPE dimensions must be positive, even, and fit the feature axis");
  }
  if (!Number.isFinite(theta) || theta <= 0)
    throw new Error("RoPE theta must be positive");

  const tokens = shape[axis]!;
  const batches = positionOffsets ? shape[0]! : 1;
  const half = rotaryDimensions / 2;
  const angles = new Float32Array(batches * tokens * half);
  for (let batch = 0; batch < batches; batch++) {
    const offset = positionOffsets?.[batch] ?? positionOffset as number;
    for (let token = 0; token < tokens; token++) {
      const position = offset + token;
      for (let pair = 0; pair < half; pair++) {
        const exponent = Math.fround(Math.fround(-2 * pair) / rotaryDimensions);
        const inverseFrequency = Math.fround(
          Math.pow(Math.fround(theta), exponent),
        );
        angles[(batch * tokens + token) * half + pair] = Math.fround(
          position * inverseFrequency,
        );
      }
    }
  }

  const frequencyShape = new Array(shape.length).fill(1);
  if (positionOffsets) frequencyShape[0] = batches;
  frequencyShape[axis] = tokens;
  frequencyShape[shape.length - 1] = half;
  const angleArray = MlxArray.fromFloat32(angles, frequencyShape);
  const cosine = ops.cos(angleArray);
  const sine = ops.sin(angleArray);
  angleArray.dispose();

  const prefixStart = new Array(shape.length).fill(0);
  const prefixStop = [...shape];
  prefixStop[shape.length - 1] = rotaryDimensions;
  const prefix = input.slice(prefixStart, prefixStop);
  const pairShape = [...shape.slice(0, -1), half, 2];
  const pairs = ops.reshape(prefix, pairShape);
  prefix.dispose();

  const evenStart = new Array(pairShape.length).fill(0);
  const evenStop = [...pairShape];
  evenStop[pairShape.length - 1] = 1;
  const oddStart = [...evenStart];
  const oddStop = [...pairShape];
  oddStart[pairShape.length - 1] = 1;
  oddStop[pairShape.length - 1] = 2;
  const evenColumn = pairs.slice(evenStart, evenStop);
  const oddColumn = pairs.slice(oddStart, oddStop);
  pairs.dispose();
  const halfShape = [...shape.slice(0, -1), half];
  const even = ops.reshape(evenColumn, halfShape);
  const odd = ops.reshape(oddColumn, halfShape);
  evenColumn.dispose();
  oddColumn.dispose();

  const evenCos = ops.mul(even, cosine);
  const oddSin = ops.mul(odd, sine);
  const real = ops.sub(evenCos, oddSin);
  const oddCos = ops.mul(odd, cosine);
  const evenSin = ops.mul(even, sine);
  const imaginary = ops.add(oddCos, evenSin);
  const rotated = ops.concatAxis([real, imaginary], shape.length - 1);

  for (const temporary of [
    cosine,
    sine,
    even,
    odd,
    evenCos,
    oddSin,
    real,
    oddCos,
    evenSin,
    imaginary,
  ]) {
    temporary.dispose();
  }

  if (rotaryDimensions === shape.at(-1)) return rotated;
  const tailStart = new Array(shape.length).fill(0);
  tailStart[shape.length - 1] = rotaryDimensions;
  const tail = input.slice(tailStart, shape);
  const output = ops.concatAxis([rotated, tail], shape.length - 1);
  rotated.dispose();
  tail.dispose();
  return output;
}

export function rmsNormF32Mlx(
  input: MlxArray,
  weight: MlxArray,
  epsilon: number,
): MlxArray {
  const width = input.shape.at(-1)!;
  validateShape("RMSNorm weight", weight, [width]);
  if (!Number.isFinite(epsilon) || epsilon < 0)
    throw new Error("RMSNorm epsilon must be non-negative");

  const inputF32 = input.dtype === Dtype.float32
    ? input
    : input.astype(Dtype.float32);
  const weightF32 = weight.dtype === Dtype.float32
    ? weight
    : weight.astype(Dtype.float32);
  const square = ops.square(inputF32);
  const mean = ops.meanAxis(square, -1, true);
  const epsilonArray = ops.scalarLike(epsilon, mean);
  const shifted = ops.add(mean, epsilonArray);
  const inverseRoot = ops.rsqrt(shifted);
  const normalized = ops.mul(inputF32, inverseRoot);
  const output = ops.mul(normalized, weightF32);
  for (const temporary of [
    square,
    mean,
    epsilonArray,
    shifted,
    inverseRoot,
    normalized,
  ]) {
    temporary.dispose();
  }
  if (inputF32 !== input) inputF32.dispose();
  if (weightF32 !== weight) weightF32.dispose();
  return output;
}

function disposeProjection(projection: Glm52MlaProjection): void {
  projection.qNope.dispose();
  projection.qRope.dispose();
  projection.latent.dispose();
  projection.rope.dispose();
}

function disposeState(state: MLACompressedState): void {
  state.latent.dispose();
  state.rope.dispose();
  state.dsa?.dispose();
}

/**
 * MLX correctness implementation of GLM-5.2 MLA.
 *
 * This is deliberately independent from the future fused MLA kernel. It loads
 * the existing Colibri artifact directly through ColibriGlm52Weights and pins
 * the mathematical contract used by that optimized path.
 */
export class Glm52Mla {
  readonly config: Glm52Config;
  readonly weights: Glm52MlaWeightSource;
  readonly prefix: string;

  constructor(
    config: Glm52Config,
    weights: ColibriGlm52Weights | Glm52MlaWeightSource,
    layerIndex: number,
  ) {
    if (!Number.isSafeInteger(layerIndex) || layerIndex < 0 ||
        layerIndex > config.numHiddenLayers) {
      throw new Error(`invalid GLM-5.2 layer index ${layerIndex}`);
    }
    if (!config.ropeInterleave)
      throw new Error("GLM-5.2 MLA requires pair-interleaved RoPE");
    positiveInteger("attention heads", config.numAttentionHeads);
    positiveInteger("q LoRA rank", config.qLoraRank);
    positiveInteger("kv LoRA rank", config.kvLoraRank);
    positiveInteger("no-PE head dimension", config.qkNopeHeadDim);
    positiveInteger("RoPE head dimension", config.qkRopeHeadDim);
    positiveInteger("value head dimension", config.vHeadDim);
    this.config = config;
    this.weights = weights;
    this.prefix = `model.layers.${layerIndex}.self_attn`;
  }

  /**
   * Project a token block into query state and compressed cache state.
   * Returned arrays are caller-owned.
   */
  project(
    input: MlxArray,
    positionOffset: number | readonly number[],
  ): Glm52MlaProjection {
    const shape = input.shape;
    if (shape.length !== 3)
      throw new Error(`GLM-5.2 MLA input must have rank 3 (got ${shape.length})`);
    const [batch, tokens, hidden] = shape as [number, number, number];
    positiveInteger("MLA batch", batch);
    positiveInteger("MLA tokens", tokens);
    if (hidden !== this.config.hiddenSize)
      throw new Error(`MLA hidden width ${hidden} != ${this.config.hiddenSize}`);

    const heads = this.config.numAttentionHeads;
    const qA = this.weights.linear(
      input,
      `${this.prefix}.q_a_proj.weight`,
      this.config.qLoraRank,
      this.config.hiddenSize,
    );
    const qNorm = rmsNormF32Mlx(
      qA,
      this.weights.tensor(`${this.prefix}.q_a_layernorm.weight`),
      this.config.rmsNormEps,
    );
    qA.dispose();
    const qFlat = this.weights.linear(
      qNorm,
      `${this.prefix}.q_b_proj.weight`,
      heads * this.config.qkHeadDim,
      this.config.qLoraRank,
    );
    qNorm.dispose();
    const q = ops.reshape(
      qFlat,
      [batch, tokens, heads, this.config.qkHeadDim],
    );
    qFlat.dispose();
    const qNope = q.slice(
      [0, 0, 0, 0],
      [batch, tokens, heads, this.config.qkNopeHeadDim],
    );
    const qRopeRaw = q.slice(
      [0, 0, 0, this.config.qkNopeHeadDim],
      [batch, tokens, heads, this.config.qkHeadDim],
    );
    q.dispose();
    const qRope = partialInterleavedRopeMlx(
      qRopeRaw,
      positionOffset,
      this.config.qkRopeHeadDim,
      this.config.ropeTheta,
      1,
    );
    qRopeRaw.dispose();

    const compressed = this.weights.linear(
      input,
      `${this.prefix}.kv_a_proj_with_mqa.weight`,
      this.config.kvLoraRank + this.config.qkRopeHeadDim,
      this.config.hiddenSize,
    );
    const latentRaw = compressed.slice(
      [0, 0, 0],
      [batch, tokens, this.config.kvLoraRank],
    );
    const ropeRaw = compressed.slice(
      [0, 0, this.config.kvLoraRank],
      [batch, tokens, this.config.kvLoraRank + this.config.qkRopeHeadDim],
    );
    compressed.dispose();
    const latent = rmsNormF32Mlx(
      latentRaw,
      this.weights.tensor(`${this.prefix}.kv_a_layernorm.weight`),
      this.config.rmsNormEps,
    );
    latentRaw.dispose();
    const rope = partialInterleavedRopeMlx(
      ropeRaw,
      positionOffset,
      this.config.qkRopeHeadDim,
      this.config.ropeTheta,
      1,
    );
    ropeRaw.dispose();
    return { qNope, qRope, latent, rope };
  }

  /**
   * Append the compressed state and execute attention.
   *
   * `auto` reconstructs K/V for a multi-token block and selects absorbed MLA
   * for single-token decode. DSA state, when present, is cached atomically with
   * the MLA state but DSA selection itself is owned by the indexer primitive.
   */
  forward(
    input: MlxArray,
    cache: MLACache,
    dsa: MlxArray | null = null,
    path: Glm52MlaPath = "auto",
    selectedPositions: Glm52MlaSelectedPositions = null,
  ): MlxArray {
    if (cache.kvLoraRank !== this.config.kvLoraRank ||
        cache.ropeHeadDim !== this.config.qkRopeHeadDim) {
      throw new Error("MLA cache geometry does not match the model");
    }
    const tokens = input.shape[1]!;
    if (path === "absorbed" && tokens !== 1)
      throw new Error("absorbed MLA is valid only for single-token decode");
    const batch = input.shape[0]!;
    const positionOffset = batch > 1
      ? (cache.rowOffsets.length
          ? cache.rowOffsets
          : new Array(batch).fill(0) as number[])
      : cache.offset;
    const projection = this.project(input, positionOffset);
    const state = cache.appendCompressed(
      projection.latent,
      projection.rope,
      dsa,
    );
    const selectedPath = path === "auto"
      ? (tokens === 1 ? "absorbed" : "reconstructed")
      : path;
    if (selectedPositions !== null && selectedPath !== "absorbed")
      throw new Error("DSA-selected MLA requires single-token absorbed decode");
    try {
      if (selectedPath === "absorbed") {
        if (batch > 1) {
          const selections = isBatchedSelection(selectedPositions)
            ? selectedPositions.rows
            : null;
          if (selectedPositions !== null && selections === null)
            throw new Error("batched MLA requires per-row DSA selections");
          if (selections && selections.length !== batch)
            throw new Error(
              `batched MLA selections ${selections.length} != batch ${batch}`,
            );
          const rows: MlxArray[] = [];
          try {
            for (let row = 0; row < batch; row++) {
              const start = cache.leftPad[row]!;
              const qNope = projection.qNope.slice(
                [row, 0, 0, 0],
                [row + 1, 1, projection.qNope.shape[2]!, projection.qNope.shape[3]!],
              );
              const qRope = projection.qRope.slice(
                [row, 0, 0, 0],
                [row + 1, 1, projection.qRope.shape[2]!, projection.qRope.shape[3]!],
              );
              const latent = state.latent.slice(
                [row, start, 0],
                [row + 1, state.latent.shape[1]!, state.latent.shape[2]!],
              );
              const ropeState = state.rope.slice(
                [row, start, 0],
                [row + 1, state.rope.shape[1]!, state.rope.shape[2]!],
              );
              try {
                rows.push(this.attendAbsorbed(
                  { qNope, qRope },
                  { latent, rope: ropeState },
                  selections?.[row] ?? null,
                ));
              } finally {
                qNope.dispose();
                qRope.dispose();
                latent.dispose();
                ropeState.dispose();
              }
            }
            return ops.concatAxis(rows, 0);
          } finally {
            for (const row of rows) row.dispose();
          }
        }
        return this.attendAbsorbed(projection, state, selectedPositions);
      }
      return this.attendReconstructed(projection, state);
    } finally {
      disposeState(state);
      disposeProjection(projection);
    }
  }

  /** Reconstruct no-PE keys and values for the complete cached prefix. */
  attendReconstructed(
    projection: Pick<Glm52MlaProjection, "qNope" | "qRope">,
    state: Pick<MLACompressedState, "latent" | "rope">,
  ): MlxArray {
    const [batch, tokens] = projection.qNope.shape;
    const keys = state.latent.shape[1]!;
    const heads = this.config.numAttentionHeads;
    validateShape("MLA q(no-PE)", projection.qNope, [
      batch!,
      tokens!,
      heads,
      this.config.qkNopeHeadDim,
    ]);
    validateShape("MLA q(RoPE)", projection.qRope, [
      batch!,
      tokens!,
      heads,
      this.config.qkRopeHeadDim,
    ]);
    validateShape("MLA latent state", state.latent, [
      batch!,
      keys,
      this.config.kvLoraRank,
    ]);
    validateShape("MLA RoPE state", state.rope, [
      batch!,
      keys,
      this.config.qkRopeHeadDim,
    ]);
    if (keys < tokens!)
      throw new Error("MLA state cannot be shorter than the query block");

    const kvWidth = this.config.qkNopeHeadDim + this.config.vHeadDim;
    const reconstructedFlat = this.weights.linear(
      state.latent,
      `${this.prefix}.kv_b_proj.weight`,
      heads * kvWidth,
      this.config.kvLoraRank,
    );
    const reconstructed = ops.reshape(
      reconstructedFlat,
      [batch!, keys, heads, kvWidth],
    );
    reconstructedFlat.dispose();
    const keyNope = reconstructed.slice(
      [0, 0, 0, 0],
      [batch!, keys, heads, this.config.qkNopeHeadDim],
    );
    const values = reconstructed.slice(
      [0, 0, 0, this.config.qkNopeHeadDim],
      [batch!, keys, heads, kvWidth],
    );
    reconstructed.dispose();

    const ropeOneHead = ops.expandDims(state.rope, 2);
    const ropeHeads = heads === 1
      ? ropeOneHead
      : ops.concatAxis(
        Array.from({ length: heads }, () => ropeOneHead),
        2,
      );
    const query = ops.concatAxis(
      [projection.qNope, projection.qRope],
      3,
    );
    const key = ops.concatAxis([keyNope, ropeHeads], 3);
    const queryHeads = ops.transposeAxes(query, [0, 2, 1, 3]);
    const keyHeads = ops.transposeAxes(key, [0, 2, 3, 1]);
    const valueHeads = ops.transposeAxes(values, [0, 2, 1, 3]);
    const rawScores = ops.matmul(queryHeads, keyHeads);
    const scores = ops.mulScalar(
      rawScores,
      1 / Math.sqrt(this.config.qkHeadDim),
    );
    rawScores.dispose();

    const prefixTokens = keys - tokens!;
    let maskedScores = scores;
    if (tokens! > 1) {
      const maskValues = new Float32Array(tokens! * keys);
      for (let queryToken = 0; queryToken < tokens!; queryToken++) {
        const lastVisible = prefixTokens + queryToken;
        for (let keyToken = lastVisible + 1; keyToken < keys; keyToken++)
          maskValues[queryToken * keys + keyToken] = -Infinity;
      }
      const mask = MlxArray.fromFloat32(maskValues, [1, 1, tokens!, keys]);
      maskedScores = ops.add(scores, mask);
      mask.dispose();
      scores.dispose();
    }
    const probabilities = ops.softmaxAxis(maskedScores, -1, true);
    const contextHeads = ops.matmul(probabilities, valueHeads);
    const contextTokens = ops.transposeAxes(contextHeads, [0, 2, 1, 3]);
    const context = ops.reshape(
      contextTokens,
      [batch!, tokens!, heads * this.config.vHeadDim],
    );
    const output = this.weights.linear(
      context,
      `${this.prefix}.o_proj.weight`,
      this.config.hiddenSize,
      heads * this.config.vHeadDim,
    );

    for (const temporary of [
      keyNope,
      values,
      ropeOneHead,
      ...(ropeHeads === ropeOneHead ? [] : [ropeHeads]),
      query,
      key,
      queryHeads,
      keyHeads,
      valueHeads,
      maskedScores,
      probabilities,
      contextHeads,
      contextTokens,
      context,
    ]) {
      temporary.dispose();
    }
    return output;
  }

  /**
   * Weight-absorbed single-token decode.
   *
   * For each head, `q_nope @ Wk` attends directly over cached latent vectors;
   * the weighted latent is then projected through `Wv`. Only the small
   * decoupled RoPE term is scored separately.
   */
  attendAbsorbed(
    projection: Pick<Glm52MlaProjection, "qNope" | "qRope">,
    state: Pick<MLACompressedState, "latent" | "rope">,
    selectedPositions: Glm52MlaSelectedPositions = null,
  ): MlxArray {
    const [batch, tokens] = projection.qNope.shape;
    if (tokens !== 1)
      throw new Error("absorbed MLA is valid only for single-token decode");
    const keys = state.latent.shape[1]!;
    const heads = this.config.numAttentionHeads;
    validateShape("MLA q(no-PE)", projection.qNope, [
      batch!,
      1,
      heads,
      this.config.qkNopeHeadDim,
    ]);
    validateShape("MLA q(RoPE)", projection.qRope, [
      batch!,
      1,
      heads,
      this.config.qkRopeHeadDim,
    ]);
    validateShape("MLA latent state", state.latent, [
      batch!,
      keys,
      this.config.kvLoraRank,
    ]);
    validateShape("MLA RoPE state", state.rope, [
      batch!,
      keys,
      this.config.qkRopeHeadDim,
    ]);

    let activeLatent = state.latent;
    let activeRope = state.rope;
    if (selectedPositions !== null) {
      if (isBatchedSelection(selectedPositions)) {
        throw new Error("per-row DSA selection requires batched MLA");
      }
      let indices: MlxArray;
      let ownsIndices = false;
      if (selectedPositions instanceof MlxArray) {
        if (selectedPositions.ndim !== 1 || selectedPositions.size === 0)
          throw new Error("DSA device selection must be a non-empty vector");
        if (selectedPositions.dtype !== Dtype.uint32 &&
            selectedPositions.dtype !== Dtype.int32) {
          throw new Error("DSA device selection must use uint32 or int32 indices");
        }
        indices = selectedPositions;
      } else {
        if (selectedPositions.length === 0)
          throw new Error("DSA selection cannot be empty");
        for (const position of selectedPositions) {
          if (!Number.isSafeInteger(position) || position < 0 || position >= keys)
            throw new Error(`DSA position ${position} is outside cached prefix ${keys}`);
        }
        indices = ops.fromInt32(
          [...selectedPositions],
          [selectedPositions.length],
        );
        ownsIndices = true;
      }
      activeLatent = ops.takeAxis(state.latent, indices, 1);
      activeRope = ops.takeAxis(state.rope, indices, 1);
      if (ownsIndices) indices.dispose();
    }

    const kvWidth = this.config.qkNopeHeadDim + this.config.vHeadDim;
    const kvWeights = this.weights.dequantized(
      `${this.prefix}.kv_b_proj.weight`,
      heads * kvWidth,
      this.config.kvLoraRank,
    );
    const latentTranspose = ops.transposeAxes(activeLatent, [0, 2, 1]);
    const ropeTranspose = ops.transposeAxes(activeRope, [0, 2, 1]);
    const headOutputs: MlxArray[] = [];
    try {
      for (let head = 0; head < heads; head++) {
        const row = head * kvWidth;
        const qNopeHeadView = projection.qNope.slice(
          [0, 0, head, 0],
          [batch!, 1, head + 1, this.config.qkNopeHeadDim],
        );
        const qNopeHead = ops.reshape(
          qNopeHeadView,
          [batch!, 1, this.config.qkNopeHeadDim],
        );
        qNopeHeadView.dispose();
        const qRopeHeadView = projection.qRope.slice(
          [0, 0, head, 0],
          [batch!, 1, head + 1, this.config.qkRopeHeadDim],
        );
        const qRopeHead = ops.reshape(
          qRopeHeadView,
          [batch!, 1, this.config.qkRopeHeadDim],
        );
        qRopeHeadView.dispose();

        // Wk is [qk_nope, latent], so q_nope @ Wk produces latent-space q.
        const keyWeights = kvWeights.slice(
          [row, 0],
          [row + this.config.qkNopeHeadDim, this.config.kvLoraRank],
        );
        const latentQuery = ops.matmul(qNopeHead, keyWeights);
        const contentScores = ops.matmul(latentQuery, latentTranspose);
        const ropeScores = ops.matmul(qRopeHead, ropeTranspose);
        const combinedScores = ops.add(contentScores, ropeScores);
        const scaledScores = ops.mulScalar(
          combinedScores,
          1 / Math.sqrt(this.config.qkHeadDim),
        );
        const probabilities = ops.softmaxAxis(scaledScores, -1, true);
        const latentContext = ops.matmul(probabilities, activeLatent);

        // Wv is [value, latent], so the latent context multiplies Wv^T.
        const valueWeights = kvWeights.slice(
          [row + this.config.qkNopeHeadDim, 0],
          [row + kvWidth, this.config.kvLoraRank],
        );
        const valueWeightsTranspose = ops.transposeAxes(valueWeights, [1, 0]);
        const headOutput = ops.matmul(latentContext, valueWeightsTranspose);
        headOutputs.push(headOutput);
        for (const temporary of [
          qNopeHead,
          qRopeHead,
          keyWeights,
          latentQuery,
          contentScores,
          ropeScores,
          combinedScores,
          scaledScores,
          probabilities,
          latentContext,
          valueWeights,
          valueWeightsTranspose,
        ]) {
          temporary.dispose();
        }
      }
      const context = headOutputs.length === 1
        ? headOutputs[0]!
        : ops.concatAxis(headOutputs, 2);
      const output = this.weights.linear(
        context,
        `${this.prefix}.o_proj.weight`,
        this.config.hiddenSize,
        heads * this.config.vHeadDim,
      );
      if (headOutputs.length > 1) context.dispose();
      return output;
    } finally {
      for (const output of headOutputs) output.dispose();
      kvWeights.dispose();
      latentTranspose.dispose();
      ropeTranspose.dispose();
      if (activeLatent !== state.latent) activeLatent.dispose();
      if (activeRope !== state.rope) activeRope.dispose();
    }
  }
}
