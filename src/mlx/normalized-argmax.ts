// Greedy selection preserves dtype-rounded normalized scores, including ties.
// Native logsumexp retains the reference reduction. Tiled selection avoids
// writing the vocabulary-sized normalized array. Inputs remain borrowed.
import { MlxArray } from "./array";
import { Dtype } from "./ffi";
import * as ops from "./ops";
import { CompiledFunction, isShapelessTracing } from "./compile";
import { MetalKernel } from "./metal-kernel";

const header = `
inline bool better(float x, uint xi, float y, uint yi) {
  return x > y || (x == y && xi < yi);
}`;

// Four simdgroups reduce score/index pairs. Lowest token ID wins every tie.
// The caller finishes the simd==0 block by writing its output from lane zero.
const reduction = `
  for (uint distance = 16; distance > 0; distance >>= 1) {
    float other = simd_shuffle_down(best, distance);
    uint oi = simd_shuffle_down(bestId, distance);
    if (lane + distance < 32 && better(other, oi, best, bestId)) {
      best = other; bestId = oi;
    }
  }
  threadgroup float scores[4];
  threadgroup uint ids[4];
  if (lane == 0) { scores[simd] = best; ids[simd] = bestId; }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  if (simd == 0) {
    best = lane < 4 ? scores[lane] : -INFINITY;
    bestId = lane < 4 ? ids[lane] : 0xffffffffu;
    for (uint distance = 2; distance > 0; distance >>= 1) {
      float other = simd_shuffle_down(best, distance);
      uint oi = simd_shuffle_down(bestId, distance);
      if (lane + distance < 4 && better(other, oi, best, bestId)) {
        best = other; bestId = oi;
      }
    }
`;

const partialSource = `
  const uint tid = thread_position_in_threadgroup.x;
  const uint lane = tid % 32, simd = tid / 32;
  const uint row = threadgroup_position_in_grid.y;
  const uint tile = threadgroup_position_in_grid.x;
  float best = -INFINITY;
  uint bestId = 0xffffffffu;
  for (uint i = tile * 1024 + tid; i < min(uint(V), (tile + 1) * 1024); i += 128) {
    float value = float(T(logits[row * V + i] - lse[row]));
    // A nonfinite logsumexp produces only NaN/-inf normalized scores.
    // Native argmax selects token zero for this degenerate row.
    value = isnan(value) ? -INFINITY : value;
    if (better(value, i, best, bestId)) { best = value; bestId = i; }
  }
  ${reduction}
    if (lane == 0) { values[row * P + tile] = best; indices[row * P + tile] = bestId; }
  }
`;

const finishSource = `
  const uint tid = thread_position_in_threadgroup.x;
  const uint lane = tid % 32, simd = tid / 32;
  const uint row = threadgroup_position_in_grid.y;
  float best = -INFINITY;
  uint bestId = 0xffffffffu;
  for (uint i = tid; i < P; i += 128) {
    float value = values[row * P + i];
    uint id = indices[row * P + i];
    if (better(value, id, best, bestId)) { best = value; bestId = id; }
  }
  ${reduction}
    if (lane == 0) out[row] = bestId;
  }
`;

let partial: MetalKernel | undefined;
let finish: MetalKernel | undefined;
let compiled: CompiledFunction | undefined;

function kernelGraph(logits: MlxArray): MlxArray {
  const shape = logits.shape;
  const vocab = shape.at(-1)!, rows = logits.size / vocab, tiles = Math.ceil(vocab / 1024);
  partial ??= new MetalKernel({ name: "normalized_argmax_partial", header,
    inputNames: ["logits", "lse"], outputNames: ["values", "indices"], source: partialSource });
  finish ??= new MetalKernel({ name: "normalized_argmax_finish", header,
    inputNames: ["values", "indices"], outputNames: ["out"], source: finishSource });
  using lse = ops.logsumexpAxis(logits, -1, true);
  const [values, indices] = partial.apply([logits, lse], {
    outputs: [{ shape: [rows, tiles], dtype: Dtype.float32 }, { shape: [rows, tiles], dtype: Dtype.uint32 }],
    grid: [tiles * 128, rows, 1], threadGroup: [128, 1, 1],
    templateInts: { V: vocab, P: tiles }, templateDtypes: { T: logits.dtype },
  });
  try {
    using tokens = finish.apply([values!, indices!], {
      outputs: [{ shape: [rows], dtype: Dtype.uint32 }],
      grid: [128, rows, 1], threadGroup: [128, 1, 1], templateInts: { P: tiles },
    })[0]!;
    return ops.reshape(tokens, shape.slice(0, -1));
  } finally { values!.dispose(); indices!.dispose(); }
}

/** Return owned greedy IDs with the same shape/rounding as argmax(logprobs).
 * Fixed-shape compilation caches graph/FFI work for repeated row geometries.
 * Shapeless enclosing graphs retain native operations, which support symbolic
 * sizes; integer/empty inputs also retain the original operation semantics. */
export function normalizedArgmax(logits: MlxArray): MlxArray {
  const dtype = logits.dtype;
  if (isShapelessTracing() || logits.size === 0 ||
      (dtype !== Dtype.float32 && dtype !== Dtype.float16 && dtype !== Dtype.bfloat16)) {
    using lse = ops.logsumexpAxis(logits, -1, true);
    using scores = ops.sub(logits, lse);
    return ops.argmaxAxis(scores, -1);
  }
  compiled ??= new CompiledFunction(([input]) => [kernelGraph(input!)], false);
  return compiled.apply([logits])[0]!;
}
