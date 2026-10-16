// Independent MLX-affine decoder feeding MPP's right operand directly, as
// Strata's mm_gu3 does for GGUF formats. Generic cooperative indices: no
// assumption about the M4/M5 per-lane element layout.
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { MetalKernel } from "@mlx-bun/mlx/metal-kernel";
import * as ops from "@mlx-bun/mlx/ops";

const SOURCE = String.raw`
  const int n0 = threadgroup_position_in_grid.x * 32;
  const int m0 = threadgroup_position_in_grid.y * 16;
  constexpr auto desc = matmul2d_descriptor(16, 32, 32, false, true, false, matmul2d_descriptor::mode::multiply_accumulate);
  matmul2d<desc, execution_simdgroup> op;
  tensor<device half, dextents<int32_t, 2>, tensor_inline> tx((device half*)x, dextents<int32_t, 2>(K, M));
  auto right = op.template get_right_input_cooperative_tensor<half, half, float>();
  auto left = tx.template slice<32, 16>(0, m0);
  auto acc = op.template get_destination_cooperative_tensor<__tensor_ops_detail::__remove_addrspace_t<decltype(left)>, __tensor_ops_detail::__remove_addrspace_t<decltype(right)>, float>();
  for (uint16_t i = 0; i < acc.get_capacity(); ++i) if (acc.is_valid_element(i)) acc[i] = 0.0f;
  for (int base = 0; base < K; base += 32) {
    for (uint16_t i = 0; i < right.get_capacity(); ++i) {
      const auto ix = right.get_multidimensional_index(i);
      const int k = base + ix[0], n = n0 + ix[1];
      const uint code = (w[n * (K / 8) + k / 8] >> ((k % 8) * 4)) & 15u;
      right[i] = half(float(scales[n * (K / 64) + k / 64]) * float(code) + float(biases[n * (K / 64) + k / 64]));
    }
    left = tx.template slice<32, 16>(base, m0);
    op.run(left, right, acc);
  }
  tensor<device float, dextents<int32_t, 2>, tensor_inline> ty(y, dextents<int32_t, 2>(N, M));
  acc.store(ty.slice(n0, m0));
`;
let kernel: MetalKernel | undefined;
export function mppAffine(x: MlxArray, q: ops.QuantizedTensor): MlxArray[] {
  const [M, K] = x.shape, N = q.scales.shape[0]!;
  if (x.dtype !== Dtype.float16 || M! % 16 || N % 32 || K! % 64) throw new Error("MPP screen requires fp16 and aligned 16x32x64 dimensions");
  kernel ??= new MetalKernel({ name: "strata_screen_affine_mpp", inputNames: ["x", "w", "scales", "biases"], outputNames: ["y"],
    header: "#include <MetalPerformancePrimitives/MetalPerformancePrimitives.h>\nusing namespace mpp::tensor_ops;", source: SOURCE });
  const [y] = kernel.apply([x, q.packed, q.scales, q.biases], { outputs: [{ shape: [M!, N], dtype: Dtype.float32 }],
    grid: [N / 32 * 32, M! / 16, 1], threadGroup: [32, 1, 1], templateInts: { M: M!, K: K!, N } });
  using wide = y!;
  return [wide.astype(x.dtype)];
}
