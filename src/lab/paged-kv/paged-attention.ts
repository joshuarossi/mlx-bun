import { MlxArray } from "../../mlx/array";
import { Dtype } from "../../mlx/ffi";
import { MetalKernel } from "../../mlx/metal-kernel";
import * as ops from "../../mlx/ops";
import type { KvAttentionView, Mask } from "../../model/gemma4-base";
import { disposeResources } from "../../engine/resources";
import type { BlockPool } from "./paged-kv";

// Each SIMD group reduces one query/head over a bounded sequence partition.
// Only partial output vectors and normalizers materialize, never gathered KV.
const partialSpec = { name: "paged_attention_partial", ensureRowContiguous: true,
  inputNames: ["q", "keys", "values", "table", "scale"], outputNames: ["out", "normal"], source: `
  uint lane = thread_position_in_threadgroup.x;
  uint hq = threadgroup_position_in_grid.y % HQ;
  uint query = threadgroup_position_in_grid.y / HQ;
  uint part = threadgroup_position_in_grid.z;
  uint hk = hq / (HQ / HK);
  float accum[(DV + 31) / 32];
  for (uint j = 0; j < (DV + 31) / 32; ++j) accum[j] = 0;
  float maximum = -INFINITY, total = 0;
  uint length = uint(scale[1]);
  uint count = (length + PART - 1) / PART;
  uint end = min(uint(length - N + query + 1), (part + 1) * PART);
  for (uint token = part * PART; token < end; ++token) {
    uint physical = table[token / BS];
    uint keyBase = ((physical * HK + hk) * BS + token % BS) * DK;
    float score = 0;
    for (uint d = lane; d < DK; d += 32)
      score += float(q[(hq * N + query) * DK + d]) * float(keys[keyBase + d]);
    score = simd_sum(score) * scale[0];
    float next = max(maximum, score);
    float previous = exp(maximum - next), weight = exp(score - next);
    uint valueBase = ((physical * HK + hk) * BS + token % BS) * DV;
    for (uint j = 0; j < (DV + 31) / 32; ++j) {
      uint d = j * 32 + lane;
      if (d < DV) accum[j] = accum[j] * previous + weight * float(values[valueBase + d]);
    }
    total = total * previous + weight; maximum = next;
  }
  uint base = ((hq * N + query) * count + part);
  for (uint j = 0; j < (DV + 31) / 32; ++j) {
    uint d = j * 32 + lane;
    if (d < DV) out[base * DV + d] = accum[j];
  }
  if (lane == 0) { normal[base * 2] = maximum; normal[base * 2 + 1] = total; }
` };
const partial = new MetalKernel(partialSpec);
const quantizedPartial = new MetalKernel({ ...partialSpec, name: "paged_attention_affine_partial",
  inputNames: [...partialSpec.inputNames, "ks", "kb", "vs", "vb"],
  source: partialSpec.source
    .replace("float(keys[keyBase + d])", "float(InT(float(ks[(keyBase+d)/GROUP]) * float((keys[(keyBase+d)/PACK] >> (((keyBase+d)%PACK)*BITS)) & ((1u<<BITS)-1u)) + float(kb[(keyBase+d)/GROUP])))")
    .replace("float(values[valueBase + d])", "float(InT(float(vs[(valueBase+d)/GROUP]) * float((values[(valueBase+d)/PACK] >> (((valueBase+d)%PACK)*BITS)) & ((1u<<BITS)-1u)) + float(vb[(valueBase+d)/GROUP])))"),
});
const merge = new MetalKernel({ name: "paged_attention_merge", inputNames: ["parts", "normal"], outputNames: ["out"], source: `
  uint d = thread_position_in_grid.x;
  uint row = thread_position_in_grid.y;
  if (d >= DV) return;
  uint count = normal_shape[2];
  float maximum = -INFINITY;
  for (uint part = 0; part < count; ++part) maximum = max(maximum, normal[(row * count + part) * 2]);
  float sum = 0, value = 0;
  for (uint part = 0; part < count; ++part) {
    uint base = row * count + part;
    float weight = exp(normal[base * 2] - maximum);
    sum += normal[base * 2 + 1] * weight;
    value += parts[base * DV + d] * weight;
  }
  out[row * DV + d] = OutT(value / sum);
` });

/** Independent immutable view: later appends or row retirement cannot alter it. */
export function pagedAttentionView(pool: BlockPool, blockTable: number[], length: number,
  direct: boolean): KvAttentionView {
  const keys = ops.contiguous(pool.keys), values = ops.contiguous(pool.values);
  const table = MlxArray.fromInt32(Int32Array.from(blockTable), [blockTable.length]);
  const bs = pool.blockSize, quantization = pool.quantization;
  const extra = quantization ? [pool.keyScales!, pool.keyBiases!, pool.valueScales!, pool.valueBiases!].map(a => ops.contiguous(a)) : [];
  const dkStored = pool.headDim, dvStored = pool.vHeadDim;
  const dtype = pool.dtype;
  return {
    attend(q: MlxArray, scale: number, mask: Mask): MlxArray {
      const [, hq, n, dk] = q.shape as [number, number, number, number];
      const hk = keys.shape[1]!, dv = dvStored;
      // Long prefill and explicit masks use the established attention oracle.
      // This is shape dispatch within one attention interface, not scheduling.
      if (!direct || n > 8 || mask.mode === "array") {
        const gather = (tensor: MlxArray) => {
          using picked = ops.takeAxis(tensor, table, 0);
          using transposed = ops.transposeAxes(picked, [1, 0, 2, 3]);
          using flat = ops.reshape(transposed, [1, hk, blockTable.length * bs, tensor.shape[3]!]);
          return flat.slice([0, 0, 0, 0], [1, hk, length, tensor.shape[3]!]);
        };
        using k = gather(keys), v = gather(values);
        if (!quantization) return ops.sdpa(q, k, v, scale, mask.mode, mask.arr);
        using ks = gather(extra[0]!), kb = gather(extra[1]!), vs = gather(extra[2]!), vb = gather(extra[3]!);
        using kd = ops.dequantize(k, ks, kb, { ...quantization, mode: "affine" });
        using vd = ops.dequantize(v, vs, vb, { ...quantization, mode: "affine" });
        return ops.sdpa(q, kd, vd, scale, mask.mode, mask.arr);
      }
      const part = 64, parts = Math.ceil(length / part);
      using multiplier = MlxArray.fromFloat32(new Float32Array([scale, length]), [2]);
      const [out, normal] = (quantization ? quantizedPartial : partial).apply([q, keys, values, table, multiplier, ...extra], {
        outputs: [{ shape: [hq, n, parts, dv], dtype: Dtype.float32 }, { shape: [hq, n, parts, 2], dtype: Dtype.float32 }],
        grid: [32, hq * n, parts], threadGroup: [32, 1, 1],
        templateDtypes: quantization ? { InT: dtype } : {},
        templateInts: { HQ: hq, HK: hk, N: n, DK: dkStored, DV: dv, BS: bs, PART: part,
          ...(quantization ? { BITS: quantization.bits, GROUP: quantization.groupSize, PACK: 32 / quantization.bits } : {}) },
      });
      try {
        return merge.apply([out!, normal!], { outputs: [{ shape: [1, hq, n, dv], dtype: q.dtype }],
          grid: [Math.ceil(dv / 32) * 32, hq * n, 1], threadGroup: [32, 1, 1],
          templateDtypes: { OutT: q.dtype }, templateInts: { DV: dv } })[0]!;
      } finally { disposeResources([out!, normal!]); }
    },
    dispose() { disposeResources([keys, values, table, ...extra]); },
  };
}
