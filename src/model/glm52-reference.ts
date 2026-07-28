// Pure, allocation-bounded reference arithmetic for the Colibri GLM-5.2 port.
//
// This module deliberately contains no model graph, storage policy, or MLX
// ownership. It is the executable numeric contract used by fixtures and by
// optimized implementations while those implementations are brought up.

export type NumericVector = ArrayLike<number>;
export type OutputMajorMatrix = ReadonlyArray<NumericVector>;

export interface Int8PerRowMatrix {
  readonly outputRows: number;
  readonly inputColumns: number;
  readonly qbytes: NumericVector;
  readonly scales: NumericVector;
}

export interface Int4Matrix {
  readonly outputRows: number;
  readonly inputColumns: number;
  readonly qbytes: NumericVector;
  readonly scales: NumericVector;
  /** null means one scale per output row. */
  readonly groupSize: number | null;
}

export interface Glm52Route {
  readonly rawSigmoidScores: Float32Array;
  readonly selectionScores: Float32Array;
  readonly indices: number[];
  readonly executionWeights: Float32Array;
}

export interface SwiGluWeights {
  readonly gate: OutputMajorMatrix;
  readonly up: OutputMajorMatrix;
  readonly down: OutputMajorMatrix;
}

export interface RoutedSwiGluContribution {
  readonly expert: SwiGluWeights;
  readonly weight: number;
}

export interface DsaSelection {
  readonly threshold: number;
  readonly selected: number[];
}

function f32(value: number): number {
  return Math.fround(value);
}

function integer(value: number, label: string, minimum = 1): number {
  if (!Number.isSafeInteger(value) || value < minimum)
    throw new Error(`${label} must be an integer >= ${minimum}`);
  return value;
}

function vectorLength(vector: NumericVector, expected: number, label: string): void {
  if (vector.length !== expected)
    throw new Error(`${label} length ${vector.length} != ${expected}`);
}

function finite(value: number, label: string): number {
  if (!Number.isFinite(value)) throw new Error(`${label} must be finite`);
  return value;
}

function byteAt(bytes: NumericVector, index: number): number {
  const value = bytes[index]!;
  if (!Number.isInteger(value) || value < 0 || value > 255)
    throw new Error(`quantized byte ${index} is outside uint8`);
  return value;
}

function signedInt8(byte: number): number {
  return byte < 128 ? byte : byte - 256;
}

function validateInt8(matrix: Int8PerRowMatrix): void {
  const rows = integer(matrix.outputRows, "outputRows");
  const columns = integer(matrix.inputColumns, "inputColumns");
  vectorLength(matrix.qbytes, rows * columns, "int8 qbytes");
  vectorLength(matrix.scales, rows, "int8 scales");
}

function int4Groups(matrix: Int4Matrix): number {
  if (matrix.groupSize === null) return 1;
  const groupSize = integer(matrix.groupSize, "groupSize");
  return Math.ceil(matrix.inputColumns / groupSize);
}

function validateInt4(matrix: Int4Matrix): number {
  const rows = integer(matrix.outputRows, "outputRows");
  const columns = integer(matrix.inputColumns, "inputColumns");
  const rowBytes = Math.ceil(columns / 2);
  const groups = int4Groups(matrix);
  vectorLength(matrix.qbytes, rows * rowBytes, "int4 qbytes");
  vectorLength(matrix.scales, rows * groups, "int4 scales");
  return groups;
}

function int4Value(matrix: Int4Matrix, output: number, input: number): number {
  const rowBytes = Math.ceil(matrix.inputColumns / 2);
  const byte = byteAt(matrix.qbytes, output * rowBytes + (input >> 1));
  return ((input & 1) === 0 ? byte & 0x0f : byte >> 4) - 8;
}

function inputRows(inputs: ReadonlyArray<NumericVector>, columns: number): void {
  for (let row = 0; row < inputs.length; row++)
    vectorLength(inputs[row]!, columns, `input row ${row}`);
}

/** Expand signed int8 bytes using one float32 scale per output row. */
export function dequantizeInt8PerRowF32(matrix: Int8PerRowMatrix): Float32Array {
  validateInt8(matrix);
  const out = new Float32Array(matrix.outputRows * matrix.inputColumns);
  for (let output = 0; output < matrix.outputRows; output++) {
    const scale = finite(matrix.scales[output]!, `int8 scale ${output}`);
    for (let input = 0; input < matrix.inputColumns; input++) {
      const offset = output * matrix.inputColumns + input;
      out[offset] = f32(signedInt8(byteAt(matrix.qbytes, offset)) * scale);
    }
  }
  return out;
}

/**
 * Colibri int8 matmul: accumulate x*q in float32 and apply the row scale once
 * after the dot product. Weight storage is output-major [O,I].
 */
export function matmulInt8PerRowF32(
  inputs: ReadonlyArray<NumericVector>,
  matrix: Int8PerRowMatrix,
): Float32Array[] {
  validateInt8(matrix);
  inputRows(inputs, matrix.inputColumns);
  return inputs.map((input) => {
    const out = new Float32Array(matrix.outputRows);
    for (let output = 0; output < matrix.outputRows; output++) {
      let accumulator = f32(0);
      const base = output * matrix.inputColumns;
      for (let column = 0; column < matrix.inputColumns; column++) {
        const quantized = signedInt8(byteAt(matrix.qbytes, base + column));
        accumulator = f32(accumulator + f32(input[column]! * quantized));
      }
      out[output] = f32(accumulator * finite(matrix.scales[output]!, `int8 scale ${output}`));
    }
    return out;
  });
}

/**
 * Expand Colibri offset-binary int4. Low nibble is the even input column,
 * high nibble the odd column. Scales are output-major, then input-group-major.
 */
export function dequantizeInt4F32(matrix: Int4Matrix): Float32Array {
  const groups = validateInt4(matrix);
  const out = new Float32Array(matrix.outputRows * matrix.inputColumns);
  for (let output = 0; output < matrix.outputRows; output++) {
    for (let input = 0; input < matrix.inputColumns; input++) {
      const group = matrix.groupSize === null ? 0 : Math.floor(input / matrix.groupSize);
      const scale = finite(matrix.scales[output * groups + group]!, `int4 scale ${output}:${group}`);
      out[output * matrix.inputColumns + input] = f32(int4Value(matrix, output, input) * scale);
    }
  }
  return out;
}

/**
 * Exact reference shape for both per-row and grouped int4. The grouped path
 * applies each scale at its group boundary, matching Colibri rather than
 * first expanding a second full-size float matrix.
 */
export function matmulInt4F32(
  inputs: ReadonlyArray<NumericVector>,
  matrix: Int4Matrix,
): Float32Array[] {
  const groups = validateInt4(matrix);
  inputRows(inputs, matrix.inputColumns);
  const groupSize = matrix.groupSize ?? matrix.inputColumns;
  return inputs.map((input) => {
    const out = new Float32Array(matrix.outputRows);
    for (let output = 0; output < matrix.outputRows; output++) {
      let result = f32(0);
      for (let group = 0; group < groups; group++) {
        const start = group * groupSize;
        const end = Math.min(start + groupSize, matrix.inputColumns);
        let accumulator = f32(0);
        for (let column = start; column < end; column++) {
          accumulator = f32(
            accumulator + f32(input[column]! * int4Value(matrix, output, column)),
          );
        }
        const scale = finite(matrix.scales[output * groups + group]!, `int4 scale ${output}:${group}`);
        result = f32(result + f32(accumulator * scale));
      }
      out[output] = result;
    }
    return out;
  });
}

/** Output-major float32 matrix-vector multiply. */
export function matvecF32(input: NumericVector, weights: OutputMajorMatrix): Float32Array {
  if (weights.length === 0) throw new Error("weights must contain an output row");
  const columns = input.length;
  integer(columns, "input length");
  const out = new Float32Array(weights.length);
  for (let output = 0; output < weights.length; output++) {
    const row = weights[output]!;
    vectorLength(row, columns, `weight row ${output}`);
    let accumulator = f32(0);
    for (let column = 0; column < columns; column++)
      accumulator = f32(accumulator + f32(input[column]! * row[column]!));
    out[output] = accumulator;
  }
  return out;
}

/** Colibri RMSNorm: weight is multiplicative, never `1 + weight`. */
export function rmsNormF32(
  input: NumericVector,
  weight: NumericVector,
  epsilon: number,
): Float32Array {
  integer(input.length, "input length");
  vectorLength(weight, input.length, "RMSNorm weight");
  finite(epsilon, "RMSNorm epsilon");
  if (epsilon < 0) throw new Error("RMSNorm epsilon must be non-negative");
  let sumSquares = 0;
  for (let index = 0; index < input.length; index++) {
    const value = finite(input[index]!, `RMSNorm input ${index}`);
    sumSquares += value * value; // Colibri accumulates this reduction in double.
  }
  const denominator = f32(f32(sumSquares / input.length) + f32(epsilon));
  const inverseRoot = f32(1 / f32(Math.sqrt(denominator)));
  return Float32Array.from({ length: input.length }, (_, index) =>
    f32(f32(input[index]! * inverseRoot) * weight[index]!),
  );
}

/**
 * GLM partial RoPE. The first `rotaryDimensions` values are pair-interleaved
 * on input and split into real/imaginary halves on output; any tail is kept.
 */
export function partialInterleavedRopeF32(
  input: NumericVector,
  position: number,
  rotaryDimensions: number,
  theta: number,
): Float32Array {
  integer(input.length, "input length");
  integer(rotaryDimensions, "rotaryDimensions", 2);
  if ((rotaryDimensions & 1) !== 0 || rotaryDimensions > input.length)
    throw new Error("rotaryDimensions must be even and no larger than input");
  if (!Number.isSafeInteger(position) || position < 0)
    throw new Error("position must be a non-negative integer");
  finite(theta, "RoPE theta");
  if (theta <= 0) throw new Error("RoPE theta must be positive");

  const source = Float32Array.from(input);
  const out = Float32Array.from(source);
  const half = rotaryDimensions / 2;
  for (let pair = 0; pair < half; pair++) {
    const exponent = f32(f32(-2 * pair) / rotaryDimensions);
    const inverseFrequency = f32(Math.pow(f32(theta), exponent));
    const angle = f32(position * inverseFrequency);
    const cosine = f32(Math.cos(angle));
    const sine = f32(Math.sin(angle));
    const a = source[2 * pair]!;
    const b = source[2 * pair + 1]!;
    out[pair] = f32(f32(a * cosine) - f32(b * sine));
    out[half + pair] = f32(f32(b * cosine) + f32(a * sine));
  }
  return out;
}

export function sigmoidF32(value: number): number {
  const exponential = f32(Math.exp(f32(-finite(value, "sigmoid input"))));
  return f32(1 / f32(1 + exponential));
}

/**
 * Exact noaux_tc router contract: rank sigmoid(logit)+bias, but execute using
 * the unbiased sigmoid values. Strict-greater scanning makes lower expert IDs
 * win exact ties.
 */
export function routeTrueTopKF32(
  logits: NumericVector,
  correctionBias: NumericVector,
  topK: number,
  normalize: boolean,
  routedScale: number,
): Glm52Route {
  integer(logits.length, "expert count");
  vectorLength(correctionBias, logits.length, "correction bias");
  integer(topK, "topK");
  if (topK > logits.length) throw new Error("topK exceeds expert count");
  finite(routedScale, "routed scale");

  const rawSigmoidScores = new Float32Array(logits.length);
  const selectionScores = new Float32Array(logits.length);
  for (let expert = 0; expert < logits.length; expert++) {
    const raw = sigmoidF32(logits[expert]!);
    rawSigmoidScores[expert] = raw;
    selectionScores[expert] = f32(raw + finite(correctionBias[expert]!, `bias ${expert}`));
  }

  const indices: number[] = [];
  const selected = new Uint8Array(logits.length);
  while (indices.length < topK) {
    let best = -1;
    let bestScore = -1e30;
    for (let expert = 0; expert < logits.length; expert++) {
      if (selected[expert] === 0 && selectionScores[expert]! > bestScore) {
        best = expert;
        bestScore = selectionScores[expert]!;
      }
    }
    if (best < 0) throw new Error("router found no selectable expert");
    selected[best] = 1;
    indices.push(best);
  }

  const executionWeights = new Float32Array(topK);
  let sum = f32(0);
  if (normalize) {
    for (const expert of indices) sum = f32(sum + rawSigmoidScores[expert]!);
    sum = f32(sum + f32(1e-20));
  }
  for (let rank = 0; rank < topK; rank++) {
    const raw = rawSigmoidScores[indices[rank]!]!;
    const weight = normalize ? f32(raw / sum) : raw;
    executionWeights[rank] = f32(weight * routedScale);
  }
  return { rawSigmoidScores, selectionScores, indices, executionWeights };
}

function siluF32(value: number): number {
  return f32(value / f32(1 + f32(Math.exp(f32(-value)))));
}

/** Reference `down(silu(gate(x))*up(x))`. */
export function swiGluF32(input: NumericVector, weights: SwiGluWeights): Float32Array {
  const gate = matvecF32(input, weights.gate);
  const up = matvecF32(input, weights.up);
  if (gate.length !== up.length)
    throw new Error(`SwiGLU gate rows ${gate.length} != up rows ${up.length}`);
  const hidden = new Float32Array(gate.length);
  for (let index = 0; index < hidden.length; index++)
    hidden[index] = f32(siluF32(gate[index]!) * up[index]!);
  const out = matvecF32(hidden, weights.down);
  for (let row = 0; row < weights.down.length; row++)
    vectorLength(weights.down[row]!, hidden.length, `SwiGLU down row ${row}`);
  return out;
}

/**
 * Accumulate routed experts in route order, then add the unweighted shared
 * expert, matching Colibri's reference composition.
 */
export function composeSharedRoutedSwiGluF32(
  input: NumericVector,
  routed: ReadonlyArray<RoutedSwiGluContribution>,
  shared: SwiGluWeights | null,
): Float32Array {
  if (routed.length === 0 && shared === null)
    throw new Error("MoE composition needs a routed or shared expert");
  let out: Float32Array | null = null;
  for (let route = 0; route < routed.length; route++) {
    const contribution = routed[route]!;
    const value = swiGluF32(input, contribution.expert);
    finite(contribution.weight, `route weight ${route}`);
    out ??= new Float32Array(value.length);
    if (out.length !== value.length) throw new Error("routed expert output dimensions differ");
    for (let index = 0; index < out.length; index++)
      out[index] = f32(out[index]! + f32(contribution.weight * value[index]!));
  }
  if (shared !== null) {
    const value = swiGluF32(input, shared);
    out ??= new Float32Array(value.length);
    if (out.length !== value.length) throw new Error("shared expert output dimension differs");
    for (let index = 0; index < out.length; index++)
      out[index] = f32(out[index]! + value[index]!);
  }
  return out!;
}

/**
 * Select the keep-th threshold, then preserve Colibri's two scans: positions
 * strictly above threshold first, threshold ties second.
 */
export function selectDsaThresholdTiesF32(
  scores: NumericVector,
  keep: number,
): DsaSelection {
  integer(scores.length, "DSA score count");
  integer(keep, "DSA keep");
  if (keep > scores.length) throw new Error("DSA keep exceeds score count");
  const values = Array.from(scores, (score, index) => finite(score, `DSA score ${index}`));
  const threshold = values.slice().sort((a, b) => b - a)[keep - 1]!;
  const selected: number[] = [];
  for (let position = 0; position < values.length && selected.length < keep; position++)
    if (values[position]! > threshold) selected.push(position);
  for (let position = 0; position < values.length && selected.length < keep; position++)
    if (values[position] === threshold) selected.push(position);
  return { threshold, selected };
}

/**
 * DSA scores from already-projected query heads, shared index keys, and head
 * weights:
 *   score_t = 1/sqrt(H) Σ_h w_h ReLU((q_h · k_t)/sqrt(D)).
 */
export function dsaScoresFromProjectedF32(
  queryHeads: OutputMajorMatrix,
  keys: OutputMajorMatrix,
  headWeights: NumericVector,
): Float32Array {
  const heads = integer(queryHeads.length, "DSA head count");
  vectorLength(headWeights, heads, "DSA head weights");
  const headDimensions = integer(queryHeads[0]!.length, "DSA head dimensions");
  for (let head = 0; head < heads; head++)
    vectorLength(queryHeads[head]!, headDimensions, `DSA query head ${head}`);
  const headScale = f32(1 / f32(Math.sqrt(f32(heads))));
  const dimensionScale = f32(1 / f32(Math.sqrt(f32(headDimensions))));
  const out = new Float32Array(keys.length);
  for (let position = 0; position < keys.length; position++) {
    const key = keys[position]!;
    vectorLength(key, headDimensions, `DSA key ${position}`);
    let score = f32(0);
    for (let head = 0; head < heads; head++) {
      const query = queryHeads[head]!;
      let dot = f32(0);
      for (let dimension = 0; dimension < headDimensions; dimension++)
        dot = f32(dot + f32(query[dimension]! * key[dimension]!));
      dot = f32(dot * dimensionScale);
      if (dot > 0)
        score = f32(score + f32(finite(headWeights[head]!, `DSA head weight ${head}`) * dot));
    }
    out[position] = f32(score * headScale);
  }
  return out;
}
