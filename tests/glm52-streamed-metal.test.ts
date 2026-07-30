import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import {
  Glm52CanonicalQ4MetalExecutor,
  Glm52CanonicalQ8MetalExecutor,
  type Glm52CanonicalQ4MetalLayout,
  type Glm52CanonicalQ8MetalLayout,
} from "../src/model/glm52-streamed-metal";

const HIDDEN = 32;
const INTERMEDIATE = 32;
const MATRIX_BYTES = HIDDEN * INTERMEDIATE / 2;
const SCALE_BYTES = HIDDEN * 4;

const LAYOUT: Glm52CanonicalQ4MetalLayout = {
  hiddenSize: HIDDEN,
  intermediateSize: INTERMEDIATE,
  slotBytes: MATRIX_BYTES * 3 + SCALE_BYTES * 3,
  downWeightOffset: 0,
  gateWeightOffset: MATRIX_BYTES,
  upWeightOffset: MATRIX_BYTES * 2,
  downScaleOffset: MATRIX_BYTES * 3,
  gateScaleOffset: MATRIX_BYTES * 3 + SCALE_BYTES,
  upScaleOffset: MATRIX_BYTES * 3 + SCALE_BYTES * 2,
};

function matrixBytes(seed: number): Uint8Array {
  const bytes = new Uint8Array(MATRIX_BYTES);
  for (let row = 0; row < HIDDEN; row++) {
    for (let column = 0; column < HIDDEN; column += 2) {
      const low = (row * 3 + column * 5 + seed) & 15;
      const high = (row * 7 + column * 2 + seed * 3 + 1) & 15;
      bytes[row * (HIDDEN / 2) + column / 2] = low | (high << 4);
    }
  }
  return bytes;
}

function scales(seed: number): Float32Array {
  const values = new Float32Array(HIDDEN);
  for (let row = 0; row < HIDDEN; row++)
    values[row] = 0.00625 * (1 + ((row + seed) % 7));
  return values;
}

function copyInto(
  destination: Uint8Array,
  offset: number,
  source: Uint8Array,
): void {
  destination.set(source, offset);
}

function referenceLinear(
  input: MlxArray,
  weights: Uint8Array,
  rowScales: Float32Array,
): MlxArray {
  const packed = MlxArray.fromBytesCopy(
    weights,
    [HIDDEN, HIDDEN / 8],
    Dtype.uint32,
  );
  const scalesArray = MlxArray.fromFloat32(
    rowScales,
    [HIDDEN, 1],
  );
  const biases = ops.mulScalar(scalesArray, -8);
  try {
    return ops.quantizedMatmul(
      input,
      packed,
      scalesArray,
      biases,
      { bits: 4, groupSize: 32, mode: "affine" },
      true,
    );
  } finally {
    packed.dispose();
    scalesArray.dispose();
    biases.dispose();
  }
}

describe("GLM-5.2 canonical Q4 Metal streamed expert", () => {
  test("tiny direct-slot SwiGLU matches the stock MLX Q4 path", () => {
    const downWeights = matrixBytes(3);
    const gateWeights = matrixBytes(5);
    const upWeights = matrixBytes(9);
    const downScales = scales(2);
    const gateScales = scales(4);
    const upScales = scales(6);
    const bytes = new Uint8Array(LAYOUT.slotBytes);
    copyInto(bytes, LAYOUT.downWeightOffset, downWeights);
    copyInto(bytes, LAYOUT.gateWeightOffset, gateWeights);
    copyInto(bytes, LAYOUT.upWeightOffset, upWeights);
    copyInto(
      bytes,
      LAYOUT.downScaleOffset,
      new Uint8Array(downScales.buffer),
    );
    copyInto(
      bytes,
      LAYOUT.gateScaleOffset,
      new Uint8Array(gateScales.buffer),
    );
    copyInto(
      bytes,
      LAYOUT.upScaleOffset,
      new Uint8Array(upScales.buffer),
    );

    const inputValues = new Float32Array(HIDDEN);
    for (let i = 0; i < inputValues.length; i++)
      inputValues[i] = ((i * 11) % 17 - 8) / 9;
    const input = MlxArray.fromFloat32(inputValues, [1, HIDDEN]);
    const slot = MlxArray.fromBytesCopy(
      bytes,
      [bytes.byteLength],
      Dtype.uint8,
    );
    const executor = new Glm52CanonicalQ4MetalExecutor();
    const got = executor.execute(input, slot, LAYOUT);

    const gate = referenceLinear(input, gateWeights, gateScales);
    const up = referenceLinear(input, upWeights, upScales);
    const activated = ops.silu(gate);
    const product = ops.mul(activated, up);
    const expected = referenceLinear(product, downWeights, downScales);
    ops.evalAll([got, expected]);
    const actualValues = got.toFloat32();
    const expectedValues = expected.toFloat32();
    let maxAbs = 0;
    for (let i = 0; i < actualValues.length; i++) {
      maxAbs = Math.max(
        maxAbs,
        Math.abs(actualValues[i]! - expectedValues[i]!),
      );
    }
    expect(maxAbs).toBeLessThan(2e-4);

    for (const value of [
      input,
      slot,
      got,
      gate,
      up,
      activated,
      product,
      expected,
    ]) {
      value.dispose();
    }
    executor.dispose();
  });

  test("production bfloat16 specialization stays bounded against stock MLX", () => {
    const downWeights = matrixBytes(13);
    const gateWeights = matrixBytes(17);
    const upWeights = matrixBytes(21);
    const downScales = scales(3);
    const gateScales = scales(5);
    const upScales = scales(7);
    const bytes = new Uint8Array(LAYOUT.slotBytes);
    copyInto(bytes, LAYOUT.downWeightOffset, downWeights);
    copyInto(bytes, LAYOUT.gateWeightOffset, gateWeights);
    copyInto(bytes, LAYOUT.upWeightOffset, upWeights);
    copyInto(
      bytes,
      LAYOUT.downScaleOffset,
      new Uint8Array(downScales.buffer),
    );
    copyInto(
      bytes,
      LAYOUT.gateScaleOffset,
      new Uint8Array(gateScales.buffer),
    );
    copyInto(
      bytes,
      LAYOUT.upScaleOffset,
      new Uint8Array(upScales.buffer),
    );

    const inputValues = new Float32Array(HIDDEN);
    for (let i = 0; i < inputValues.length; i++)
      inputValues[i] = ((i * 7) % 19 - 9) / 10;
    const inputF32 = MlxArray.fromFloat32(inputValues, [1, HIDDEN]);
    const input = inputF32.astype(Dtype.bfloat16);
    inputF32.dispose();
    const slot = MlxArray.fromBytesCopy(
      bytes,
      [bytes.byteLength],
      Dtype.uint8,
    );
    const executor = new Glm52CanonicalQ4MetalExecutor();
    const got = executor.execute(input, slot, LAYOUT);
    const gate = referenceLinear(input, gateWeights, gateScales);
    const up = referenceLinear(input, upWeights, upScales);
    const activated = ops.silu(gate);
    const product = ops.mul(activated, up);
    const expected = referenceLinear(product, downWeights, downScales);
    ops.evalAll([got, expected]);

    const actualValues = got.toFloat32();
    const expectedValues = expected.toFloat32();
    let maxAbs = 0;
    for (let i = 0; i < actualValues.length; i++) {
      maxAbs = Math.max(
        maxAbs,
        Math.abs(actualValues[i]! - expectedValues[i]!),
      );
    }
    expect(maxAbs).toBeLessThan(0.02);

    for (const value of [
      input,
      slot,
      got,
      gate,
      up,
      activated,
      product,
      expected,
    ]) {
      value.dispose();
    }
    executor.dispose();
  });

  test("one fixed kernel family is row-stable for M=1 and M=4", () => {
    const bytes = new Uint8Array(LAYOUT.slotBytes);
    copyInto(bytes, LAYOUT.downWeightOffset, matrixBytes(31));
    copyInto(bytes, LAYOUT.gateWeightOffset, matrixBytes(37));
    copyInto(bytes, LAYOUT.upWeightOffset, matrixBytes(41));
    copyInto(
      bytes,
      LAYOUT.downScaleOffset,
      new Uint8Array(scales(11).buffer),
    );
    copyInto(
      bytes,
      LAYOUT.gateScaleOffset,
      new Uint8Array(scales(13).buffer),
    );
    copyInto(
      bytes,
      LAYOUT.upScaleOffset,
      new Uint8Array(scales(17).buffer),
    );
    const values = new Float32Array(HIDDEN * 4);
    for (let row = 0; row < 4; row++) {
      for (let column = 0; column < HIDDEN; column++)
        values[row * HIDDEN + column] =
          ((row * 13 + column * 7) % 23 - 11) / 12;
    }
    const input4 = MlxArray.fromFloat32(values, [4, HIDDEN]);
    const input1 = input4.slice([0, 0], [1, HIDDEN]);
    const slot = MlxArray.fromBytesCopy(
      bytes,
      [LAYOUT.slotBytes],
      Dtype.uint8,
    );
    const executor = new Glm52CanonicalQ4MetalExecutor();
    const output1 = executor.execute(input1, slot, LAYOUT);
    const output4 = executor.execute(input4, slot, LAYOUT);
    const row0 = output4.slice([0, 0], [1, HIDDEN]);
    ops.evalAll([output1, row0]);
    expect([...output1.toFloat32()]).toEqual([...row0.toFloat32()]);
    input1.dispose();
    input4.dispose();
    slot.dispose();
    output1.dispose();
    output4.dispose();
    row0.dispose();
    executor.dispose();
  });
});

const Q8_MATRIX_BYTES = HIDDEN * INTERMEDIATE;
const Q8_LAYOUT: Glm52CanonicalQ8MetalLayout = {
  hiddenSize: HIDDEN,
  intermediateSize: INTERMEDIATE,
  slotBytes: Q8_MATRIX_BYTES * 3 + SCALE_BYTES * 3,
  downWeightOffset: 0,
  gateWeightOffset: Q8_MATRIX_BYTES,
  upWeightOffset: Q8_MATRIX_BYTES * 2,
  downScaleOffset: Q8_MATRIX_BYTES * 3,
  gateScaleOffset: Q8_MATRIX_BYTES * 3 + SCALE_BYTES,
  upScaleOffset: Q8_MATRIX_BYTES * 3 + SCALE_BYTES * 2,
};

function q8Matrix(seed: number): Int8Array {
  return Int8Array.from(
    { length: Q8_MATRIX_BYTES },
    (_, index) => ((index * 17 + seed * 29) % 255) - 127,
  );
}

function referenceLinearQ8(
  input: MlxArray,
  values: Int8Array,
  rowScales: Float32Array,
): MlxArray {
  const packed = MlxArray.fromBytesCopy(
    new Uint8Array(values.buffer),
    [HIDDEN, HIDDEN],
    Dtype.int8,
  );
  const floats = packed.astype(Dtype.float32);
  const scale = MlxArray.fromFloat32(rowScales, [HIDDEN, 1]);
  const zeros = ops.zeros([HIDDEN, HIDDEN], Dtype.float32);
  const broadcast = ops.add(scale, zeros);
  const weights = ops.mul(floats, broadcast);
  const transposed = ops.transposeAxes(weights, [1, 0]);
  try {
    return ops.matmul(input, transposed);
  } finally {
    packed.dispose();
    floats.dispose();
    scale.dispose();
    zeros.dispose();
    broadcast.dispose();
    weights.dispose();
    transposed.dispose();
  }
}

describe("GLM-5.2 canonical Q8 Metal MTP expert", () => {
  test("one fixed kernel family matches stock MLX for M=1 and M=3", () => {
    const downWeights = q8Matrix(3);
    const gateWeights = q8Matrix(5);
    const upWeights = q8Matrix(9);
    const downScales = scales(2);
    const gateScales = scales(4);
    const upScales = scales(6);
    const bytes = new Uint8Array(Q8_LAYOUT.slotBytes);
    copyInto(
      bytes,
      Q8_LAYOUT.downWeightOffset,
      new Uint8Array(downWeights.buffer),
    );
    copyInto(
      bytes,
      Q8_LAYOUT.gateWeightOffset,
      new Uint8Array(gateWeights.buffer),
    );
    copyInto(
      bytes,
      Q8_LAYOUT.upWeightOffset,
      new Uint8Array(upWeights.buffer),
    );
    copyInto(
      bytes,
      Q8_LAYOUT.downScaleOffset,
      new Uint8Array(downScales.buffer),
    );
    copyInto(
      bytes,
      Q8_LAYOUT.gateScaleOffset,
      new Uint8Array(gateScales.buffer),
    );
    copyInto(
      bytes,
      Q8_LAYOUT.upScaleOffset,
      new Uint8Array(upScales.buffer),
    );

    const inputValues = Float32Array.from(
      { length: HIDDEN * 3 },
      (_, index) => ((index * 13) % 23 - 11) / 12,
    );
    const input = MlxArray.fromFloat32(inputValues, [3, HIDDEN]);
    const first = input.slice([0, 0], [1, HIDDEN]);
    const slot = MlxArray.fromBytesCopy(
      bytes,
      [bytes.byteLength],
      Dtype.uint8,
    );
    const executor = new Glm52CanonicalQ8MetalExecutor();
    const got3 = executor.execute(input, slot, Q8_LAYOUT);
    const got1 = executor.execute(first, slot, Q8_LAYOUT);

    const gate = referenceLinearQ8(input, gateWeights, gateScales);
    const up = referenceLinearQ8(input, upWeights, upScales);
    const activated = ops.silu(gate);
    const product = ops.mul(activated, up);
    const expected = referenceLinearQ8(product, downWeights, downScales);
    ops.evalAll([got3, got1, expected]);
    const actualValues = got3.toFloat32();
    const expectedValues = expected.toFloat32();
    let maxAbs = 0;
    for (let i = 0; i < actualValues.length; i++) {
      maxAbs = Math.max(
        maxAbs,
        Math.abs(actualValues[i]! - expectedValues[i]!),
      );
    }
    expect(maxAbs).toBeLessThan(3e-4);
    expect(Array.from(got1.toFloat32())).toEqual(
      Array.from(actualValues.slice(0, HIDDEN)),
    );

    for (const value of [
      input,
      first,
      slot,
      got3,
      got1,
      gate,
      up,
      activated,
      product,
      expected,
    ]) {
      value.dispose();
    }
    executor.dispose();
  });
});
