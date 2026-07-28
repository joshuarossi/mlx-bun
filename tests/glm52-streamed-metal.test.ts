import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import {
  Glm52CanonicalQ4MetalExecutor,
  type Glm52CanonicalQ4MetalLayout,
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

  test("rejects non-decode row counts before dispatch", () => {
    const input = MlxArray.fromFloat32(
      new Float32Array(HIDDEN * 2),
      [2, HIDDEN],
    );
    const slot = MlxArray.fromBytesCopy(
      new Uint8Array(LAYOUT.slotBytes),
      [LAYOUT.slotBytes],
      Dtype.uint8,
    );
    const executor = new Glm52CanonicalQ4MetalExecutor();
    expect(() => executor.execute(input, slot, LAYOUT)).toThrow(
      "requires input [1,32]",
    );
    input.dispose();
    slot.dispose();
    executor.dispose();
  });
});
