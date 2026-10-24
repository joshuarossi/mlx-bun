// Float32 64-token gated delta rule, using the pinned MFLUX matrix-squaring solve.
// The owning layer normalizes and repeats q/k heads before this operation.
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";

const CHUNK = 64;

/** Float32 q/k [B,L,H,Dk], already normalized and with repeated heads,
 * v [B,L,H,Dv], log-decay and beta [B,L,H]. Inputs borrowed; q is scaled by
 * Dk**-0.5 here. Returns owned lazy float32 [B,L,H,Dv]. */
export function gatedDeltaChunked(query: MlxArray, key: MlxArray, value: MlxArray, logDecay: MlxArray, beta: MlxArray): MlxArray {
  const [batch, length, heads, keyDim] = key.shape as [number, number, number, number];
  const valueDim = value.shape[3]!;
  const padding = (CHUNK - length % CHUNK) % CHUNK;
  const chunks = (length + padding) / CHUNK;
  const padHeads = (x: MlxArray) => {
    using wide = x.astype(Dtype.float32);
    using headsFirst = ops.transposeAxes(wide, [0, 2, 1, 3]);
    return ops.pad(headsFirst, [[0, 0], [0, 0], [0, padding], [0, 0]]);
  };
  const padScalar = (x: MlxArray) => {
    using wide = x.astype(Dtype.float32);
    using headsFirst = ops.transposeAxes(wide, [0, 2, 1]);
    return ops.pad(headsFirst, [[0, 0], [0, 0], [0, padding]]);
  };
  using qPadded = padHeads(query), kPadded = padHeads(key), vPadded = padHeads(value);
  using gPadded = padScalar(logDecay), bPadded = padScalar(beta);
  using qScaled = ops.mulScalar(qPadded, keyDim ** -0.5);
  using betaColumn = ops.expandDims(bPadded, -1);
  using valueBeta = ops.mul(vPadded, betaColumn), keyBeta = ops.mul(kPadded, betaColumn);
  using q = ops.reshape(qScaled, [batch, heads, chunks, CHUNK, keyDim]);
  using k = ops.reshape(kPadded, [batch, heads, chunks, CHUNK, keyDim]);
  using vb = ops.reshape(valueBeta, [batch, heads, chunks, CHUNK, valueDim]);
  using kb = ops.reshape(keyBeta, [batch, heads, chunks, CHUNK, keyDim]);
  using gChunks = ops.reshape(gPadded, [batch, heads, chunks, CHUNK]);
  using g = ops.cumsum(gChunks, -1);

  const lowerBytes = new Uint8Array(CHUNK * CHUNK), strictBytes = new Uint8Array(CHUNK * CHUNK);
  const identityValues = new Float32Array(CHUNK * CHUNK);
  for (let row = 0; row < CHUNK; row++) {
    identityValues[row * CHUNK + row] = 1;
    for (let column = 0; column <= row; column++) {
      lowerBytes[row * CHUNK + column] = 1;
      if (column < row) strictBytes[row * CHUNK + column] = 1;
    }
  }
  using lower = MlxArray.fromBytesCopy(lowerBytes, [CHUNK, CHUNK], Dtype.bool);
  using strict = MlxArray.fromBytesCopy(strictBytes, [CHUNK, CHUNK], Dtype.bool);
  using identity = MlxArray.fromFloat32(identityValues, [CHUNK, CHUNK]);
  using zero = ops.scalarLike(0, g);
  using gColumn = ops.expandDims(g, -1), gRow = ops.expandDims(g, -2);
  using difference = ops.sub(gColumn, gRow);
  using masked = ops.where(lower, difference, zero);
  using exponential = ops.exp(masked);
  using decay = ops.where(lower, exponential, zero);
  using kt = ops.transposeAxes(k, [0, 1, 2, 4, 3]);
  using product = ops.matmul(kb, kt);
  using decayed = ops.mul(product, decay);
  using negative = ops.neg(decayed);
  using a = ops.where(strict, negative, zero);

  let inverse = ops.add(identity, a);
  let power: MlxArray | undefined;
  try {
    power = ops.copyOf(a);
    for (let i = 0; i < 5; i++) {
      const squared = ops.matmul(power, power);
      power.dispose(); power = squared;
      using plusIdentity = ops.add(identity, power);
      const expanded = ops.matmul(inverse, plusIdentity);
      inverse.dispose(); inverse = expanded;
    }
    using valueChunks = ops.matmul(inverse, vb);
    using expG = ops.exp(g);
    using expGColumn = ops.expandDims(expG, -1);
    using decayedKey = ops.mul(kb, expGColumn);
    using keyDecay = ops.matmul(inverse, decayedKey);
    const block = (x: MlxArray, index: number, width: number) => {
      using slice = x.slice([0, 0, index, 0, 0], [batch, heads, index + 1, CHUNK, width]);
      return ops.reshape(slice, [batch, heads, CHUNK, width]);
    };
    const scalarBlock = (x: MlxArray, index: number) => {
      using slice = x.slice([0, 0, index, 0], [batch, heads, index + 1, CHUNK]);
      return ops.reshape(slice, [batch, heads, CHUNK]);
    };
    let state = ops.zeros([batch, heads, keyDim, valueDim], Dtype.float32);
    const outputs: MlxArray[] = [];
    try {
      for (let index = 0; index < chunks; index++) {
        using qi = block(q, index, keyDim), ki = block(k, index, keyDim), gi = scalarBlock(g, index);
        using di = block(decay, index, CHUNK);
        using kit = ops.transposeAxes(ki, [0, 1, 3, 2]);
        using scores = ops.matmul(qi, kit);
        using attention = ops.mul(scores, di);
        using vi = block(valueChunks, index, valueDim), kd = block(keyDecay, index, keyDim);
        using prior = ops.matmul(kd, state);
        using updatedValues = ops.sub(vi, prior);
        using eg = ops.exp(gi), egColumn = ops.expandDims(eg, -1);
        using scaledQuery = ops.mul(qi, egColumn);
        using fromState = ops.matmul(scaledQuery, state);
        using fromChunk = ops.matmul(attention, updatedValues);
        outputs.push(ops.add(fromState, fromChunk));
        using gLast = gi.slice([0, 0, CHUNK - 1], [batch, heads, CHUNK]);
        using expLast = ops.exp(gLast), expLastColumn = ops.expandDims(expLast, -1);
        using retained = ops.mul(state, expLastColumn);
        using distance = ops.sub(gLast, gi);
        using weights = ops.exp(distance), weightsColumn = ops.expandDims(weights, -1);
        using weightedKey = ops.mul(ki, weightsColumn);
        using weightedKeyT = ops.transposeAxes(weightedKey, [0, 1, 3, 2]);
        using update = ops.matmul(weightedKeyT, updatedValues);
        const next = ops.add(retained, update);
        state.dispose(); state = next;
      }
      using stacked = ops.stackAxis(outputs, 2);
      using flattened = ops.reshape(stacked, [batch, heads, chunks * CHUNK, valueDim]);
      using trimmed = flattened.slice([0, 0, 0, 0], [batch, heads, length, valueDim]);
      return ops.transposeAxes(trimmed, [0, 2, 1, 3]);
    } finally { state.dispose(); for (const output of outputs) output.dispose(); }
  } finally { inverse.dispose(); power?.dispose(); }
}
