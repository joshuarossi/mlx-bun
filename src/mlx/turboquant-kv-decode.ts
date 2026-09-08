// Exact byte-packed TurboQuant K/V decoding. The caller owns output arrays.
// Rotation and cache policy belong to the existing codec/cache layers.
import { type MlxArray, gpuStream } from './array';
import { Dtype, type MlxHandle } from './ffi';
import { isShapelessTracing } from './compile';
import { MetalKernel } from './metal-kernel';

export type PackedKvArrays = readonly [
  keyIndices: MlxArray, keyScales: MlxArray, keyZeros: MlxArray,
  valueIndices: MlxArray, valueScales: MlxArray,
];

const source = `
  uint col = thread_position_in_grid.x, pos = thread_position_in_grid.y;
  uint bh = thread_position_in_grid.z;
  if (col >= D || pos >= vp_shape[2] || bh >= vp_shape[0] * vp_shape[1]) return;
  uint b = bh / vp_shape[1], h = bh % vp_shape[1];
  uint ko = b * kp_strides[0] + h * kp_strides[1] + pos * kp_strides[2];
  uint vpo = b * vp_strides[0] + h * vp_strides[1] + pos * vp_strides[2];
  uint kso = b * ks_strides[0] + h * ks_strides[1] + pos * ks_strides[2] + (col / KG) * ks_strides[3];
  uint kzo = b * kz_strides[0] + h * kz_strides[1] + pos * kz_strides[2] + (col / KG) * kz_strides[3];
  uint vso = b * vs_strides[0] + h * vs_strides[1] + pos * vs_strides[2] + (col / VG) * vs_strides[3];
  int key_code;
  if (KBITS == 8) key_code = int(kp[ko + col * kp_strides[3]]);
  else {
    uint bit = col * KBITS, byte = bit / 8u, shift = bit % 8u;
    uint word = uint(kp[ko + byte * kp_strides[3]]);
    if (shift + KBITS > 8u) word |= uint(kp[ko + (byte + 1u) * kp_strides[3]]) << 8u;
    key_code = int((word >> shift) & ((1u << KBITS) - 1u));
  }
  // Keep the incumbent f32 addition before multiplication.
  float shifted = float(key_code) + float(kz[kzo]);
  uint i = (bh * vp_shape[2] + pos) * D + col;
  outK[i] = OutK(shifted * float(ks[kso]));
  uint bit = col * VBITS, byte = bit / 8u, shift = bit % 8u;
  uint word = uint(vp[vpo + byte * vp_strides[3]]);
  if (shift + VBITS > 8u) word |= uint(vp[vpo + (byte + 1u) * vp_strides[3]]) << 8u;
  uint code = (word >> shift) & ((1u << VBITS) - 1u);
  outV[i] = OutV(centroids[code] * float(vs[vso]));
`;

let kernel: MetalKernel | undefined;
function jointKernel(): MetalKernel {
  return kernel ??= new MetalKernel({
    name: 'turboquant_kv_decode',
    inputNames: ['kp', 'ks', 'kz', 'vp', 'vs', 'centroids'],
    outputNames: ['outK', 'outV'], source, ensureRowContiguous: false,
  });
}

/** Return bf16 K and rotated V (f32 for eager inverse rotation, bf16 for
 * deferred rotation). Null means the ordinary codec must handle this input.
 * Input arrays and the shared centroid table remain borrowed. */
export function tryJointDecodePackedKv(
  inputs: PackedKvArrays, centroids: MlxArray, kBits: number, vBits: number,
  headDim: number, deferV: boolean, stream: MlxHandle = gpuStream,
): [MlxArray, MlxArray] | null {
  if (stream !== gpuStream || isShapelessTracing() ||
      ![64, 128, 256, 512].includes(headDim) ||
      ![2, 4, 5, 8].includes(kBits) || ![2, 3, 4, 5, 8].includes(vBits)) return null;
  const [kp, ks, kz, vp, vs] = inputs;
  if (kp.dtype !== (kBits === 8 ? Dtype.int8 : Dtype.uint8) ||
      vp.dtype !== Dtype.uint8 || centroids.dtype !== Dtype.float32 ||
      centroids.ndim !== 1 || centroids.size !== (1 << vBits)) return null;
  const shapes = inputs.map(a => a.shape);
  if (shapes.some(shape => shape.length !== 4)) return null;
  const [b, h, n] = shapes[3]!;
  if (!b || !h || !n || b * h * n * headDim >= 2 ** 32 ||
      shapes.some(shape => shape[0] !== b || shape[1] !== h || shape[2] !== n) ||
      shapes[0]![3] !== headDim * kBits / 8 || shapes[3]![3] !== headDim * vBits / 8 ||
      shapes[1]![3] !== shapes[2]![3]) return null;
  const keyGroup = headDim / shapes[1]![3]!, valueGroup = headDim / shapes[4]![3]!;
  if (![32, 64].includes(keyGroup) || ![32, 64].includes(valueGroup) ||
      [ks, kz, vs].some(a => ![Dtype.float16, Dtype.bfloat16, Dtype.float32].includes(a.dtype))) return null;
  const shape = [b, h, n, headDim], valueDtype = deferV ? Dtype.bfloat16 : Dtype.float32;
  return jointKernel().apply([...inputs, centroids], {
    templateDtypes: { OutK: Dtype.bfloat16, OutV: valueDtype },
    templateInts: { D: headDim, KBITS: kBits, VBITS: vBits, KG: keyGroup, VG: valueGroup },
    grid: [headDim, n, b * h], threadGroup: [Math.min(headDim, 256), Math.max(1, 256 / headDim), 1],
    outputs: [{ shape, dtype: Dtype.bfloat16 }, { shape, dtype: valueDtype }], stream,
  }) as [MlxArray, MlxArray];
}
