// Joint packed K/V decode with eager inverse rotation in the measured D256 regime.
// Hadamard butterfly/layout follows MLX 0.31.2,
// mlx/backend/metal/kernels/hadamard.h, Copyright © 2024 Apple Inc., MIT.
import { type MlxArray, gpuStream } from "./array";
import { Dtype, type MlxHandle } from "./ffi";
import { isShapelessTracing } from "./compile";
import { MetalKernel } from "./metal-kernel";
import { type PackedKvArrays } from "./turboquant-kv-decode";

const header = `
template <short R> inline void tq_inverse_radix(thread float* x) {
  constexpr short logR = __builtin_ctz(R);
  short h = 1;
  #pragma unroll
  for (short s = 0; s < logR; s++) {
    #pragma unroll
    for (short i = 0; i < R / 2; i++) {
      short k = i & (h - 1), j = ((i - k) << 1) + k;
      float a = x[j], b = x[j + h];
      x[j] = a + b; x[j + h] = a - b;
    }
    h <<= 1;
  }
}
`;
const source = `
  constexpr short D = 256, R = 16, NT = 16, LOG_R = 4;
  uint pos = thread_position_in_grid.y, bh = thread_position_in_grid.z;
  short i = thread_position_in_grid.x;
  bool valid = pos < vp_shape[2];
  uint b = bh / vp_shape[1], hidx = bh % vp_shape[1];
  uint ko = b * kp_strides[0] + hidx * kp_strides[1] + pos * kp_strides[2];
  uint vo = b * vp_strides[0] + hidx * vp_strides[1] + pos * vp_strides[2];
  uint kso = b * ks_strides[0] + hidx * ks_strides[1] + pos * ks_strides[2];
  uint kzo = b * kz_strides[0] + hidx * kz_strides[1] + pos * kz_strides[2];
  uint vso = b * vs_strides[0] + hidx * vs_strides[1] + pos * vs_strides[2];
  uint row = (bh * vp_shape[2] + pos) * D;
  threadgroup float storage[D * 16];
  threadgroup float* buf = storage + thread_position_in_threadgroup.y * D;
  #pragma unroll
  for (short j = 0; j < R / 4; j++) {
    short index = j * 4 * NT + i * 4;
    #pragma unroll
    for (short r = 0; r < 4; r++) {
      uint col = index + r;
      if (!valid) { buf[col] = 0.0f; continue; }
      int key_code = int(kp[ko + col * kp_strides[3]]);
      float shifted = float(key_code) + float(kz[kzo + (col / 32) * kz_strides[3]]);
      outK[row + col] = OutK(shifted * float(ks[kso + (col / 32) * ks_strides[3]]));
      uint bit = col * 3u, byte = bit / 8u, shift = bit % 8u;
      uint word = uint(vp[vo + byte * vp_strides[3]]);
      if (shift + 3u > 8u) word |= uint(vp[vo + (byte + 1u) * vp_strides[3]]) << 8u;
      uint code = (word >> shift) & 7u;
      buf[col] = centroids[code * centroids_strides[0]] * float(vs[vso + (col / 32) * vs_strides[3]]);
    }
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  float x[R]; short h = 1;
  #pragma unroll
  for (short s = 0; s < 2; s++) {
    short k = i & (h - 1), j = ((i - k) << LOG_R) + k;
    #pragma unroll
    for (short r = 0; r < R; r++) x[r] = buf[j + h * r];
    tq_inverse_radix<R>(x);
    #pragma unroll
    for (short r = 0; r < R; r++) buf[j + h * r] = x[r];
    h <<= LOG_R;
    threadgroup_barrier(mem_flags::mem_threadgroup);
  }
  #pragma unroll
  for (short j = 0; j < R / 4; j++) {
    short index = j * 4 * NT + i * 4;
    #pragma unroll
    for (short r = 0; r < 4; r++) {
      uint col = index + r;
      float normalized = buf[col] * 0.0625f;
      if (valid) outV[row + col] = OutV(normalized * signs[col * signs_strides[0]]);
    }
  }
`;

let kernel: MetalKernel | undefined;
function inverseKernel(): MetalKernel {
  return kernel ??= new MetalKernel({
    name: "turboquant_kv_inverse256",
    inputNames: ["kp", "ks", "kz", "vp", "vs", "centroids", "signs"],
    outputNames: ["outK", "outV"], header, source, ensureRowContiguous: false,
  });
}

/** Borrow packed inputs and codec tables; return owned bf16 K/V or null.
 * Only the measured eager D256/k8v3/B1/H4/fp16/group32 regime is eligible.
 * Other regimes continue through the existing joint decoder or original codec.
 * N affects dispatch size but is never a shader template parameter. */
export function tryDecodePackedKvInverse256(
  inputs: PackedKvArrays, centroids: MlxArray, signs: MlxArray,
  kBits: number, vBits: number, headDim: number, s: MlxHandle = gpuStream,
): [MlxArray, MlxArray] | null {
  if (s !== gpuStream || isShapelessTracing() || headDim !== 256 || kBits !== 8 || vBits !== 3)
    return null;
  const [kp, ks, kz, vp, vs] = inputs;
  const shape = kp.shape;
  if (shape.length !== 4 || shape[0] !== 1 || shape[1] !== 4 || shape[3] !== 256)
    return null;
  const n = shape[2]!;
  if (n < 8192 || n * 1024 >= 2 ** 32) return null;
  const samePrefix = (a: MlxArray, width: number) => {
    const x = a.shape;
    return x.length === 4 && x[0] === 1 && x[1] === 4 && x[2] === n && x[3] === width;
  };
  if (kp.dtype !== Dtype.int8 || vp.dtype !== Dtype.uint8 || !samePrefix(vp, 96)) return null;
  if (![ks, kz, vs].every(a => a.dtype === Dtype.float16 && samePrefix(a, 8))) return null;
  if (centroids.dtype !== Dtype.float32 || centroids.shape.length !== 1 || centroids.shape[0] !== 8)
    return null;
  if (signs.dtype !== Dtype.float32 || signs.shape.length !== 1 || signs.shape[0] !== 256)
    return null;
  return inverseKernel().apply([...inputs, centroids, signs], {
    templateDtypes: { OutK: Dtype.bfloat16, OutV: Dtype.bfloat16 },
    grid: [16, Math.ceil(n / 16) * 16, 4], threadGroup: [16, 16, 1],
    outputs: [{ shape, dtype: Dtype.bfloat16 }, { shape, dtype: Dtype.bfloat16 }], stream: s,
  }) as [MlxArray, MlxArray];
}
