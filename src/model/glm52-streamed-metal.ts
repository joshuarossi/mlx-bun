import { MlxArray } from "../mlx/array";
import { Dtype } from "../mlx/ffi";
import { MetalKernel } from "../mlx/metal-kernel";
import {
  GLM52_EXPERT_SLOT_ALIGNMENT,
  type Glm52ExpertSlotLayout,
} from "./glm52-expert-layout";

const SIMD_WIDTH = 32;
const SIMD_GROUPS = 4;
const THREADS = SIMD_WIDTH * SIMD_GROUPS;
const ROWS_PER_THREADGROUP = SIMD_GROUPS;

/**
 * The subset of the canonical expert-slot layout consumed by the decode
 * kernel. Offsets are bytes from the beginning of one aligned residency slot.
 */
export interface Glm52CanonicalQ4MetalLayout {
  readonly hiddenSize: number;
  readonly intermediateSize: number;
  readonly slotBytes: number;
  readonly downWeightOffset: number;
  readonly gateWeightOffset: number;
  readonly upWeightOffset: number;
  readonly downScaleOffset: number;
  readonly gateScaleOffset: number;
  readonly upScaleOffset: number;
}

export interface Glm52CanonicalQ8MetalLayout
extends Glm52CanonicalQ4MetalLayout {}

function positiveInteger(value: number, label: string): number {
  if (!Number.isSafeInteger(value) || value <= 0)
    throw new Error(`${label} must be a positive safe integer`);
  return value;
}

function validateRange(
  offset: number,
  byteLength: number,
  slotBytes: number,
  label: string,
): void {
  if (!Number.isSafeInteger(offset) || offset < 0)
    throw new Error(`${label} offset must be a non-negative safe integer`);
  if (!Number.isSafeInteger(byteLength) || byteLength < 0)
    throw new Error(`${label} length must be a non-negative safe integer`);
  if (offset + byteLength > slotBytes)
    throw new Error(`${label} exceeds the canonical expert slot`);
}

/**
 * Resolve and validate a production-compatible Q4 descriptor from the
 * artifact-driven slot catalog. Colibri's main routed experts use one F32
 * scale per output row (`groupSize === null`) and affine zero-point 8.
 */
export function glm52CanonicalQ4MetalLayout(
  layout: Glm52ExpertSlotLayout,
): Glm52CanonicalQ4MetalLayout {
  if (layout.bits !== 4)
    throw new Error("GLM Metal streamed experts require a Q4 slot");
  if (layout.groupSize !== null) {
    throw new Error(
      "GLM Metal streamed experts currently require per-row Q4 scales",
    );
  }

  const down = layout.projections.down;
  const gate = layout.projections.gate;
  const up = layout.projections.up;
  const hiddenSize = positiveInteger(down.tensor.outputRows, "hidden size");
  const intermediateSize = positiveInteger(
    down.tensor.inputColumns,
    "intermediate size",
  );
  const expected = [
    [gate.tensor.outputRows, intermediateSize, "gate output rows"],
    [gate.tensor.inputColumns, hiddenSize, "gate input columns"],
    [up.tensor.outputRows, intermediateSize, "up output rows"],
    [up.tensor.inputColumns, hiddenSize, "up input columns"],
  ] as const;
  for (const [actual, wanted, label] of expected) {
    if (actual !== wanted)
      throw new Error(`${label} must be ${wanted}, got ${actual}`);
  }

  const slotBytes = positiveInteger(layout.slotBytes, "expert slot bytes");
  for (const [projection, outputRows, inputColumns] of [
    [down, hiddenSize, intermediateSize],
    [gate, intermediateSize, hiddenSize],
    [up, intermediateSize, hiddenSize],
  ] as const) {
    const weightBytes = outputRows * inputColumns / 2;
    const scaleBytes = outputRows * 4;
    if (projection.tensor.weight.byteLength !== weightBytes) {
      throw new Error(
        `${projection.projection} Q4 weight bytes must be ${weightBytes}`,
      );
    }
    if (projection.tensor.scales.byteLength !== scaleBytes) {
      throw new Error(
        `${projection.projection} Q4 scale bytes must be ${scaleBytes}`,
      );
    }
    validateRange(
      projection.weightOffset,
      weightBytes,
      slotBytes,
      `${projection.projection} weights`,
    );
    validateRange(
      projection.scaleOffset,
      scaleBytes,
      slotBytes,
      `${projection.projection} scales`,
    );
    if ((projection.weightOffset & 3) !== 0)
      throw new Error(`${projection.projection} weights must be uint32-aligned`);
    if ((projection.scaleOffset & 3) !== 0)
      throw new Error(`${projection.projection} scales must be F32-aligned`);
  }

  return {
    hiddenSize,
    intermediateSize,
    slotBytes,
    downWeightOffset: down.weightOffset,
    gateWeightOffset: gate.weightOffset,
    upWeightOffset: up.weightOffset,
    downScaleOffset: down.scaleOffset,
    gateScaleOffset: gate.scaleOffset,
    upScaleOffset: up.scaleOffset,
  };
}

/** Resolve the signed two's-complement, per-output-row int8 layout used by
 * GLM-5.2's native MTP routed experts. */
export function glm52CanonicalQ8MetalLayout(
  layout: Glm52ExpertSlotLayout,
): Glm52CanonicalQ8MetalLayout {
  if (layout.bits !== 8)
    throw new Error("GLM MTP Metal streamed experts require a Q8 slot");
  if (layout.groupSize !== null)
    throw new Error("GLM MTP Metal streamed experts require per-row Q8 scales");

  const down = layout.projections.down;
  const gate = layout.projections.gate;
  const up = layout.projections.up;
  const hiddenSize = positiveInteger(down.tensor.outputRows, "hidden size");
  const intermediateSize = positiveInteger(
    down.tensor.inputColumns,
    "intermediate size",
  );
  const expected = [
    [gate.tensor.outputRows, intermediateSize, "gate output rows"],
    [gate.tensor.inputColumns, hiddenSize, "gate input columns"],
    [up.tensor.outputRows, intermediateSize, "up output rows"],
    [up.tensor.inputColumns, hiddenSize, "up input columns"],
  ] as const;
  for (const [actual, wanted, label] of expected) {
    if (actual !== wanted)
      throw new Error(`${label} must be ${wanted}, got ${actual}`);
  }

  const slotBytes = positiveInteger(layout.slotBytes, "expert slot bytes");
  for (const [projection, outputRows, inputColumns] of [
    [down, hiddenSize, intermediateSize],
    [gate, intermediateSize, hiddenSize],
    [up, intermediateSize, hiddenSize],
  ] as const) {
    const weightBytes = outputRows * inputColumns;
    const scaleBytes = outputRows * 4;
    if (projection.tensor.weight.byteLength !== weightBytes)
      throw new Error(
        `${projection.projection} Q8 weight bytes must be ${weightBytes}`,
      );
    if (projection.tensor.scales.byteLength !== scaleBytes)
      throw new Error(
        `${projection.projection} Q8 scale bytes must be ${scaleBytes}`,
      );
    validateRange(
      projection.weightOffset,
      weightBytes,
      slotBytes,
      `${projection.projection} weights`,
    );
    validateRange(
      projection.scaleOffset,
      scaleBytes,
      slotBytes,
      `${projection.projection} scales`,
    );
    if ((projection.scaleOffset & 3) !== 0)
      throw new Error(`${projection.projection} scales must be F32-aligned`);
  }
  return {
    hiddenSize,
    intermediateSize,
    slotBytes,
    downWeightOffset: down.weightOffset,
    gateWeightOffset: gate.weightOffset,
    upWeightOffset: up.weightOffset,
    downScaleOffset: down.scaleOffset,
    gateScaleOffset: gate.scaleOffset,
    upScaleOffset: up.scaleOffset,
  };
}

/** Wrap a live, aligned ExpertIOSlabStore slot without copying it.
 *
 * The residency lease remains owned by the caller and must not be released
 * until the returned expert output has been evaluated and the GPU stream has
 * completed.
 */
export function glm52CanonicalQ4SlotView(
  pointer: number,
  layout: Glm52CanonicalQ4MetalLayout | Glm52CanonicalQ8MetalLayout,
): MlxArray {
  if (!Number.isSafeInteger(pointer) || pointer <= 0)
    throw new Error("expert slot pointer must be a positive safe integer");
  if (pointer % GLM52_EXPERT_SLOT_ALIGNMENT !== 0) {
    throw new Error(
      "expert slot pointer must be page-aligned for zero-copy Metal access",
    );
  }
  return MlxArray.fromPointer(pointer, [layout.slotBytes], Dtype.uint8);
}

export const glm52CanonicalQ8SlotView = glm52CanonicalQ4SlotView;

function validateCall(
  input: MlxArray,
  slot: MlxArray,
  layout: Glm52CanonicalQ4MetalLayout,
): void {
  const hidden = positiveInteger(layout.hiddenSize, "hidden size");
  const intermediate = positiveInteger(
    layout.intermediateSize,
    "intermediate size",
  );
  positiveInteger(layout.slotBytes, "expert slot bytes");
  if (hidden % 8 !== 0 || intermediate % 8 !== 0)
    throw new Error("Q4 expert dimensions must be divisible by 8");
  if (hidden % ROWS_PER_THREADGROUP !== 0 ||
      intermediate % ROWS_PER_THREADGROUP !== 0) {
    throw new Error(
      `Q4 expert output dimensions must be divisible by ${ROWS_PER_THREADGROUP}`,
    );
  }
  if (
    input.shape.length !== 2 ||
    !Number.isSafeInteger(input.shape[0]) ||
    input.shape[0]! < 1 ||
    input.shape[1] !== hidden
  ) {
    throw new Error(
      `GLM Metal streamed expert decode requires input [M,${hidden}]`,
    );
  }
  if (input.dtype !== Dtype.bfloat16 && input.dtype !== Dtype.float32) {
    throw new Error(
      "GLM Metal streamed expert decode requires bfloat16 or float32 input",
    );
  }
  if (slot.dtype !== Dtype.uint8 || slot.shape.length !== 1)
    throw new Error("canonical expert slot must be a flat uint8 array");
  if (slot.size < layout.slotBytes)
    throw new Error("canonical expert slot array is shorter than its layout");

  const ranges = [
    [layout.downWeightOffset, hidden * intermediate / 2, "down weights"],
    [layout.gateWeightOffset, intermediate * hidden / 2, "gate weights"],
    [layout.upWeightOffset, intermediate * hidden / 2, "up weights"],
    [layout.downScaleOffset, hidden * 4, "down scales"],
    [layout.gateScaleOffset, intermediate * 4, "gate scales"],
    [layout.upScaleOffset, intermediate * 4, "up scales"],
  ] as const;
  for (const [offset, length, label] of ranges)
    validateRange(offset, length, layout.slotBytes, label);
}

// One simdgroup owns one output row. The packed Q4 byte stream and F32 row
// scales are read straight from the canonical residency slot. Every product is
// explicitly dequantized to float and accumulated with an F32 FMA.
const GATE_UP_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = thread_position_in_grid.z;
  if (row >= (uint)I || sample >= (uint)M) return;
  const device T* sampleX = x + (ulong)sample * (ulong)H;

  const device uint32_t* gateRow =
    (const device uint32_t*)(slot + GATE_W) + (ulong)row * (ulong)(H / 8);
  const device uint32_t* upRow =
    (const device uint32_t*)(slot + UP_W) + (ulong)row * (ulong)(H / 8);
  const device float* gateScales = (const device float*)(slot + GATE_S);
  const device float* upScales = (const device float*)(slot + UP_S);
  const float gateScale = gateScales[row];
  const float upScale = upScales[row];

  float gateAcc = 0.0f;
  float upAcc = 0.0f;
  for (uint word = lane; word < (uint)(H / 8); word += 32u) {
    const uint32_t gatePacked = gateRow[word];
    const uint32_t upPacked = upRow[word];
    const uint k0 = word * 8u;
    for (uint place = 0; place < 8u; ++place) {
      const float xv = float(sampleX[k0 + place]);
      const float gateWeight =
        float((gatePacked >> (place * 4u)) & 0xFu) - 8.0f;
      const float upWeight =
        float((upPacked >> (place * 4u)) & 0xFu) - 8.0f;
      gateAcc = metal::fma(gateWeight, xv, gateAcc);
      upAcc = metal::fma(upWeight, xv, upAcc);
    }
  }

  const float gate = metal::simd_sum(gateAcc) * gateScale;
  const float up = metal::simd_sum(upAcc) * upScale;
  if (lane == 0u) {
    // Match the production BF16 graph's materialization boundaries: gate and
    // up are rounded to T, then SiLU and the product are rounded to T.
    const T gateT = T(gate);
    const T upT = T(up);
    const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
    const T siluT = T(float(gateT) * float(sigmoidT));
    mid[(ulong)sample * (ulong)I + row] =
      T(float(siluT) * float(upT));
  }
`;

const DOWN_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = thread_position_in_grid.z;
  if (row >= (uint)H || sample >= (uint)M) return;
  const device T* sampleMid = mid + (ulong)sample * (ulong)I;

  const device uint32_t* downRow =
    (const device uint32_t*)(slot + DOWN_W) + (ulong)row * (ulong)(I / 8);
  const device float* downScales = (const device float*)(slot + DOWN_S);
  const float scale = downScales[row];
  float acc = 0.0f;
  for (uint word = lane; word < (uint)(I / 8); word += 32u) {
    const uint32_t packed = downRow[word];
    const uint k0 = word * 8u;
    for (uint place = 0; place < 8u; ++place) {
      const float xv = float(sampleMid[k0 + place]);
      const float weight =
        float((packed >> (place * 4u)) & 0xFu) - 8.0f;
      acc = metal::fma(weight, xv, acc);
    }
  }
  const float value = metal::simd_sum(acc) * scale;
  if (lane == 0u)
    out[(ulong)sample * (ulong)H + row] = T(value);
`;

/**
 * Row-independent routed-SwiGLU kernel for the GLM-5.2 production geometry.
 * M=1 decode and a pinned speculative verify batch use the identical source
 * and dispatch geometry; only grid.z changes.
 */
export class Glm52CanonicalQ4MetalExecutor {
  readonly #gateUp = new MetalKernel({
    name: "mlx_bun_glm52_q4_slot_gate_up",
    inputNames: ["x", "slot"],
    outputNames: ["mid"],
    source: GATE_UP_SOURCE,
    ensureRowContiguous: true,
  });
  readonly #down = new MetalKernel({
    name: "mlx_bun_glm52_q4_slot_down",
    inputNames: ["mid", "slot"],
    outputNames: ["out"],
    source: DOWN_SOURCE,
    ensureRowContiguous: true,
  });
  #disposed = false;

  execute(
    input: MlxArray,
    slot: MlxArray,
    layout: Glm52CanonicalQ4MetalLayout,
  ): MlxArray {
    if (this.#disposed)
      throw new Error("GLM Metal streamed expert executor used after dispose");
    validateCall(input, slot, layout);
    const samples = input.shape[0]!;
    const templateInts = {
      M: samples,
      H: layout.hiddenSize,
      I: layout.intermediateSize,
      DOWN_W: layout.downWeightOffset,
      GATE_W: layout.gateWeightOffset,
      UP_W: layout.upWeightOffset,
      DOWN_S: layout.downScaleOffset,
      GATE_S: layout.gateScaleOffset,
      UP_S: layout.upScaleOffset,
      ROWS_TG: ROWS_PER_THREADGROUP,
    };
    const [mid] = this.#gateUp.apply([input, slot], {
      outputs: [{
        shape: [samples, layout.intermediateSize],
        dtype: input.dtype,
      }],
      grid: [
        THREADS,
        layout.intermediateSize / ROWS_PER_THREADGROUP,
        samples,
      ],
      threadGroup: [THREADS, 1, 1],
      templateDtypes: { T: input.dtype },
      templateInts,
    });
    if (!mid) throw new Error("GLM Metal gate/up kernel returned no output");
    try {
      const [output] = this.#down.apply([mid, slot], {
        outputs: [{
          shape: [samples, layout.hiddenSize],
          dtype: input.dtype,
        }],
        grid: [
          THREADS,
          layout.hiddenSize / ROWS_PER_THREADGROUP,
          samples,
        ],
        threadGroup: [THREADS, 1, 1],
        templateDtypes: { T: input.dtype },
        templateInts,
      });
      if (!output) throw new Error("GLM Metal down kernel returned no output");
      return output;
    } finally {
      mid.dispose();
    }
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    this.#gateUp.dispose();
    this.#down.dispose();
  }
}

const Q8_GATE_UP_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = thread_position_in_grid.z;
  if (row >= (uint)I || sample >= (uint)M) return;

  const device int8_t* gateRow =
    (const device int8_t*)(slot + GATE_W) + (ulong)row * (ulong)H;
  const device int8_t* upRow =
    (const device int8_t*)(slot + UP_W) + (ulong)row * (ulong)H;
  const device float* gateScales = (const device float*)(slot + GATE_S);
  const device float* upScales = (const device float*)(slot + UP_S);
  const float gateScale = gateScales[row];
  const float upScale = upScales[row];
  float gateAcc = 0.0f;
  float upAcc = 0.0f;
  for (uint k = lane; k < (uint)H; k += 32u) {
    const float xv = float(x[(ulong)sample * (ulong)H + k]);
    gateAcc = metal::fma(float(gateRow[k]), xv, gateAcc);
    upAcc = metal::fma(float(upRow[k]), xv, upAcc);
  }
  const float gate = metal::simd_sum(gateAcc) * gateScale;
  const float up = metal::simd_sum(upAcc) * upScale;
  if (lane == 0u) {
    const T gateT = T(gate);
    const T upT = T(up);
    const T sigmoidT = T(1.0f / (1.0f + metal::precise::exp(-float(gateT))));
    const T siluT = T(float(gateT) * float(sigmoidT));
    mid[(ulong)sample * (ulong)I + row] = T(float(siluT) * float(upT));
  }
`;

const Q8_DOWN_SOURCE = String.raw`
  const uint lane = thread_index_in_simdgroup;
  const uint sg = simdgroup_index_in_threadgroup;
  const uint row = thread_position_in_grid.y * (uint)ROWS_TG + sg;
  const uint sample = thread_position_in_grid.z;
  if (row >= (uint)H || sample >= (uint)M) return;

  const device int8_t* downRow =
    (const device int8_t*)(slot + DOWN_W) + (ulong)row * (ulong)I;
  const device float* downScales = (const device float*)(slot + DOWN_S);
  const float scale = downScales[row];
  float acc = 0.0f;
  for (uint k = lane; k < (uint)I; k += 32u) {
    const float xv = float(mid[(ulong)sample * (ulong)I + k]);
    acc = metal::fma(float(downRow[k]), xv, acc);
  }
  const float value = metal::simd_sum(acc) * scale;
  if (lane == 0u) out[(ulong)sample * (ulong)H + row] = T(value);
`;

/**
 * Fixed M=1..gamma signed-Q8 kernel family for native MTP draft and accepted
 * token absorption. The row dot-product and materialization boundaries are
 * identical for every batch width; only grid.z changes.
 */
export class Glm52CanonicalQ8MetalExecutor {
  readonly #gateUp = new MetalKernel({
    name: "mlx_bun_glm52_q8_slot_gate_up",
    inputNames: ["x", "slot"],
    outputNames: ["mid"],
    source: Q8_GATE_UP_SOURCE,
    ensureRowContiguous: true,
  });
  readonly #down = new MetalKernel({
    name: "mlx_bun_glm52_q8_slot_down",
    inputNames: ["mid", "slot"],
    outputNames: ["out"],
    source: Q8_DOWN_SOURCE,
    ensureRowContiguous: true,
  });
  #disposed = false;

  execute(
    input: MlxArray,
    slot: MlxArray,
    layout: Glm52CanonicalQ8MetalLayout,
  ): MlxArray {
    if (this.#disposed)
      throw new Error("GLM MTP Metal expert executor used after dispose");
    const hidden = positiveInteger(layout.hiddenSize, "hidden size");
    const intermediate = positiveInteger(
      layout.intermediateSize,
      "intermediate size",
    );
    const [rows, width] = input.shape;
    if (
      input.shape.length !== 2 ||
      !rows ||
      width !== hidden ||
      (input.dtype !== Dtype.bfloat16 && input.dtype !== Dtype.float32)
    ) {
      throw new Error(
        `GLM MTP Metal streamed expert requires [M,${hidden}] bf16/f32 input`,
      );
    }
    if (hidden % ROWS_PER_THREADGROUP !== 0 ||
        intermediate % ROWS_PER_THREADGROUP !== 0) {
      throw new Error(
        `Q8 expert dimensions must be divisible by ${ROWS_PER_THREADGROUP}`,
      );
    }
    if (slot.dtype !== Dtype.uint8 || slot.shape.length !== 1 ||
        slot.size < layout.slotBytes) {
      throw new Error("canonical Q8 expert slot is invalid");
    }
    const templateInts = {
      M: rows,
      H: hidden,
      I: intermediate,
      DOWN_W: layout.downWeightOffset,
      GATE_W: layout.gateWeightOffset,
      UP_W: layout.upWeightOffset,
      DOWN_S: layout.downScaleOffset,
      GATE_S: layout.gateScaleOffset,
      UP_S: layout.upScaleOffset,
      ROWS_TG: ROWS_PER_THREADGROUP,
    };
    const [mid] = this.#gateUp.apply([input, slot], {
      outputs: [{ shape: [rows, intermediate], dtype: input.dtype }],
      grid: [THREADS, intermediate / ROWS_PER_THREADGROUP, rows],
      threadGroup: [THREADS, 1, 1],
      templateDtypes: { T: input.dtype },
      templateInts,
    });
    if (!mid) throw new Error("GLM MTP Metal gate/up kernel returned no output");
    try {
      const [output] = this.#down.apply([mid, slot], {
        outputs: [{ shape: [rows, hidden], dtype: input.dtype }],
        grid: [THREADS, hidden / ROWS_PER_THREADGROUP, rows],
        threadGroup: [THREADS, 1, 1],
        templateDtypes: { T: input.dtype },
        templateInts,
      });
      if (!output) throw new Error("GLM MTP Metal down kernel returned no output");
      return output;
    } finally {
      mid.dispose();
    }
  }

  dispose(): void {
    if (this.#disposed) return;
    this.#disposed = true;
    this.#gateUp.dispose();
    this.#down.dispose();
  }
}
