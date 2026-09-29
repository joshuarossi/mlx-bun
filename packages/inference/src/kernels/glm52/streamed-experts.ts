import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import { positiveInteger } from "../../runtime/integers";
import { GLM52_EXPERT_SLOT_ALIGNMENT, validateRange, type Glm52CanonicalMetalLayout } from "./layout";
export { GLM52_EXPERT_SLOT_ALIGNMENT } from "./layout";
export type { Glm52CanonicalMetalLayout, Glm52CanonicalQ4MetalLayout, Glm52CanonicalQ8MetalLayout } from "./layout";

const SIMD_WIDTH = 32;
const SIMD_GROUPS = 4;
const THREADS = SIMD_WIDTH * SIMD_GROUPS;
const ROWS_PER_THREADGROUP = SIMD_GROUPS;

/** Wrap a live, aligned ExpertIOSlabStore slot without copying it.
 *
 * The residency lease remains owned by the caller and must not be released
 * until the returned expert output has been evaluated and the GPU stream has
 * completed.
 */
export function glm52CanonicalQ4SlotView(
  pointer: number,
  layout: Glm52CanonicalMetalLayout,
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

/** What differs between the Q4 and Q8 kernel families: the Metal sources, the
 *  weight packing the validators check, and the error wording. */
interface CanonicalExecutorSpec {
  readonly label: "Q4" | "Q8";
  readonly kernelPrefix: string;
  readonly gateUpSource: string;
  readonly downSource: string;
  /** Weights stored per byte (Q4 packs two, Q8 one). */
  readonly weightsPerByte: 1 | 2;
  /** Output dimensions must divide by this many packed weights (Q4: one uint32 word). */
  readonly dimensionMultiple: number;
  readonly subject: string;
}

function validateCall(
  input: MlxArray,
  slot: MlxArray,
  layout: Glm52CanonicalMetalLayout,
  spec: CanonicalExecutorSpec,
): void {
  const hidden = positiveInteger(layout.hiddenSize, "hidden size");
  const intermediate = positiveInteger(
    layout.intermediateSize,
    "intermediate size",
  );
  positiveInteger(layout.slotBytes, "expert slot bytes");
  if (hidden % spec.dimensionMultiple !== 0 || intermediate % spec.dimensionMultiple !== 0) {
    throw new Error(
      `${spec.label} expert dimensions must be divisible by ${spec.dimensionMultiple}`,
    );
  }
  if (hidden % ROWS_PER_THREADGROUP !== 0 ||
      intermediate % ROWS_PER_THREADGROUP !== 0) {
    throw new Error(
      `${spec.label} expert output dimensions must be divisible by ${ROWS_PER_THREADGROUP}`,
    );
  }
  if (
    input.shape.length !== 2 ||
    !Number.isSafeInteger(input.shape[0]) ||
    input.shape[0]! < 1 ||
    input.shape[1] !== hidden
  ) {
    throw new Error(`${spec.subject} requires input [M,${hidden}]`);
  }
  if (input.dtype !== Dtype.bfloat16 && input.dtype !== Dtype.float32)
    throw new Error(`${spec.subject} requires bfloat16 or float32 input`);
  if (slot.dtype !== Dtype.uint8 || slot.shape.length !== 1)
    throw new Error("canonical expert slot must be a flat uint8 array");
  if (slot.size < layout.slotBytes)
    throw new Error("canonical expert slot array is shorter than its layout");

  const perByte = spec.weightsPerByte;
  const ranges = [
    [layout.downWeightOffset, hidden * intermediate / perByte, "down weights"],
    [layout.gateWeightOffset, intermediate * hidden / perByte, "gate weights"],
    [layout.upWeightOffset, intermediate * hidden / perByte, "up weights"],
    [layout.downScaleOffset, hidden * 4, "down scales"],
    [layout.gateScaleOffset, intermediate * 4, "gate scales"],
    [layout.upScaleOffset, intermediate * 4, "up scales"],
  ] as const;
  for (const [offset, length, label] of ranges)
    validateRange(offset, length, layout.slotBytes, label);
}

/**
 * Row-independent routed-SwiGLU kernel pair (gate/up, then down) that reads a
 * canonical residency slot directly. M=1 decode and a pinned speculative
 * verify batch use the identical source and dispatch geometry; only grid.z
 * changes. The Q4 and Q8 families below differ only in their spec.
 */
class Glm52CanonicalMetalExecutor {
  readonly #gateUp: MetalKernel;
  readonly #down: MetalKernel;
  readonly #spec: CanonicalExecutorSpec;
  #disposed = false;

  constructor(spec: CanonicalExecutorSpec) {
    this.#spec = spec;
    this.#gateUp = new MetalKernel({
      name: `${spec.kernelPrefix}_gate_up`,
      inputNames: ["x", "slot"],
      outputNames: ["mid"],
      source: spec.gateUpSource,
      ensureRowContiguous: true,
    });
    this.#down = new MetalKernel({
      name: `${spec.kernelPrefix}_down`,
      inputNames: ["mid", "slot"],
      outputNames: ["out"],
      source: spec.downSource,
      ensureRowContiguous: true,
    });
  }

  execute(
    input: MlxArray,
    slot: MlxArray,
    layout: Glm52CanonicalMetalLayout,
  ): MlxArray {
    if (this.#disposed)
      throw new Error(`${this.#spec.subject} executor used after dispose`);
    validateCall(input, slot, layout, this.#spec);
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
    if (!mid) throw new Error(`${this.#spec.subject} gate/up kernel returned no output`);
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
      if (!output) throw new Error(`${this.#spec.subject} down kernel returned no output`);
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

/** Q4 (packed nibbles, affine zero-point 8) kernel family for the GLM-5.2
 *  production geometry. */
export class Glm52CanonicalQ4MetalExecutor extends Glm52CanonicalMetalExecutor {
  constructor() {
    super({
      label: "Q4",
      kernelPrefix: "mlx_bun_glm52_q4_slot",
      gateUpSource: GATE_UP_SOURCE,
      downSource: DOWN_SOURCE,
      weightsPerByte: 2,
      dimensionMultiple: 8,
      subject: "GLM Metal streamed expert decode",
    });
  }
}

/** Fixed M=1..gamma signed-Q8 kernel family for native MTP draft and accepted
 *  token absorption. The row dot-product and materialization boundaries are
 *  identical for every batch width; only grid.z changes. */
export class Glm52CanonicalQ8MetalExecutor extends Glm52CanonicalMetalExecutor {
  constructor() {
    super({
      label: "Q8",
      kernelPrefix: "mlx_bun_glm52_q8_slot",
      gateUpSource: Q8_GATE_UP_SOURCE,
      downSource: Q8_DOWN_SOURCE,
      weightsPerByte: 1,
      dimensionMultiple: 1,
      subject: "GLM MTP Metal streamed expert",
    });
  }
}
