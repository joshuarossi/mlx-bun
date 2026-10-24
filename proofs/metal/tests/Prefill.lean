import metal.tests.Elab
import metal.kernels.AffineRows3
import metal.kernels.AffineRows4
import metal.kernels.AffineSplitMma
import metal.kernels.GateUpCodebookMma
import metal.kernels.GateUpMmaWide
import metal.kernels.DownMmaWide
import metal.kernels.DownK3iMmaWide
import metal.kernels.AneTrellisFill
import metal.kernels.AneTrellisFillK3i
import metal.kernels.AneWriteHalf
import metal.kernels.VectorExpand

namespace Metal.Prefill.Tests
open Metal Core Host.Mlx Host.Mlx.PrefillSources

/-! # The prefill kernels' texts and inventories

One instance of each prefill kernel (two of vector_expand: untiled and the interleaved
`ROW_TILE` 128), its signature and instantiation spelled out as tests/Assemble.lean spells the decode
kernels', and the same text as the kernel module's `text` (`texts`, by kernel reduction). Their
cores' (PrefillInventory.lean) floating-operation inventories (Elab.lean `inventory` of `elaborateO0`, `inventoryDefault`
of `elaborate`) agree with proofs/metal/AirInventory.ts's `-O0` and `default` columns
(`xcrun metal -std=metal4.1 -fmetal-math-mode=safe`) except for `air.simdgroup_matrix_8x8_init_filled`
(`make_filled_simdgroup_matrix`, a register fill and no floating operation: the core's `.vector`)
and the constant conversions the `-O0` column marks `(const)` (folded here). No prefill kernel has a
contraction site (`llvm.fmuladd`): their multiply-adds are explicit `metal::fma`. -/

/-- Header, signature, body, closing brace, instantiation. -/
def text (k : PrefillKernel) (signature instantiation : List Char) : List Char :=
  header k ++ signature ++ source k ++ chars!"\n}\n" ++ instantiation

def affine3RowsSignature : List Char :=
  chars!"template <typename T, int M, int N, int K, int NR, int SGS, int VPT>\n[[kernel]] void custom_kernel_mlx_bun_affine3_rows__bfloat16_t_2_10240_5120_4_2_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t(\n  const device bfloat16_t* x [[buffer(0)]],\n  const device uint32_t* w [[buffer(1)]],\n  const device bfloat16_t* scales [[buffer(2)]],\n  const device bfloat16_t* biases [[buffer(3)]],\n  device bfloat16_t* y [[buffer(4)]],\n  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],\n  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def affine3RowsInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_affine3_rows__bfloat16_t_2_10240_5120_4_2_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_affine3_rows__bfloat16_t_2_10240_5120_4_2_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 2, 10240, 5120, 4, 2, 16>) custom_kernel_mlx_bun_affine3_rows__bfloat16_t_2_10240_5120_4_2_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 2, 10240, 5120, 4, 2, 16>;\n"

def affine4RowsSignature : List Char :=
  chars!"template <typename T, int M, int N, int K, int NR, int SGS, int VPT>\n[[kernel]] void custom_kernel_mlx_bun_affine4_rows__bfloat16_t_2_10240_5120_4_2_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t(\n  const device bfloat16_t* x [[buffer(0)]],\n  const device uint32_t* w [[buffer(1)]],\n  const device bfloat16_t* scales [[buffer(2)]],\n  const device bfloat16_t* biases [[buffer(3)]],\n  device bfloat16_t* y [[buffer(4)]],\n  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],\n  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def affine4RowsInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_affine4_rows__bfloat16_t_2_10240_5120_4_2_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_affine4_rows__bfloat16_t_2_10240_5120_4_2_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 2, 10240, 5120, 4, 2, 16>) custom_kernel_mlx_bun_affine4_rows__bfloat16_t_2_10240_5120_4_2_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 2, 10240, 5120, 4, 2, 16>;\n"

def affineSplitMmaSignature : List Char :=
  chars!"template <typename T, int N, int K, int BITS, int TILES, int SPLITS>\n[[kernel]] void custom_kernel_mlx_bun_affine_split_mma__bfloat16_t_10240_5120_3_2_2_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t(\n  const device bfloat16_t* x [[buffer(0)]],\n  const constant int* x_shape [[buffer(1)]],\n  const device uint32_t* w [[buffer(2)]],\n  const device bfloat16_t* scales [[buffer(3)]],\n  const device bfloat16_t* biases [[buffer(4)]],\n  device bfloat16_t* y [[buffer(5)]],\n  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],\n  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def affineSplitMmaInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_affine_split_mma__bfloat16_t_10240_5120_3_2_2_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_affine_split_mma__bfloat16_t_10240_5120_3_2_2_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 10240, 5120, 3, 2, 2>) custom_kernel_mlx_bun_affine_split_mma__bfloat16_t_10240_5120_3_2_2_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 10240, 5120, 3, 2, 2>;\n"

def gateUpCodebookMmaSignature : List Char :=
  chars!"template <typename T, int R, int C, int BT, int KG, int KU, int L, int SG_TG>\n[[kernel]] void custom_kernel_mlx_bun_trellis_gateup_codebook_mma__bfloat16_t_17408_5120_256_2_2_12_4_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t(\n  const device bfloat16_t* x [[buffer(0)]],\n  const constant int* x_shape [[buffer(1)]],\n  const device uint32_t* gcodes [[buffer(2)]],\n  const device float16_t* gscales [[buffer(3)]],\n  const device uint32_t* ucodes [[buffer(4)]],\n  const device float16_t* uscales [[buffer(5)]],\n  device bfloat16_t* mid [[buffer(6)]],\n  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],\n  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def gateUpCodebookMmaInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_gateup_codebook_mma__bfloat16_t_17408_5120_256_2_2_12_4_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_gateup_codebook_mma__bfloat16_t_17408_5120_256_2_2_12_4_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t<bfloat16_t, 17408, 5120, 256, 2, 2, 12, 4>) custom_kernel_mlx_bun_trellis_gateup_codebook_mma__bfloat16_t_17408_5120_256_2_2_12_4_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t<bfloat16_t, 17408, 5120, 256, 2, 2, 12, 4>;\n"

def gateUpMmaWideSignature : List Char :=
  chars!"template <typename T, int R, int C, int BT, int KG, int KU, int L, int SG_TG, int MT>\n[[kernel]] void custom_kernel_mlx_bun_trellis_gateup_mma_wide__bfloat16_t_17408_5120_256_2_2_12_8_3_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t(\n  const device bfloat16_t* x [[buffer(0)]],\n  const constant int* x_shape [[buffer(1)]],\n  const device uint32_t* gcodes [[buffer(2)]],\n  const device float16_t* gscales [[buffer(3)]],\n  const device uint32_t* ucodes [[buffer(4)]],\n  const device float16_t* uscales [[buffer(5)]],\n  device bfloat16_t* mid [[buffer(6)]],\n  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],\n  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def gateUpMmaWideInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_gateup_mma_wide__bfloat16_t_17408_5120_256_2_2_12_8_3_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_gateup_mma_wide__bfloat16_t_17408_5120_256_2_2_12_8_3_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t<bfloat16_t, 17408, 5120, 256, 2, 2, 12, 8, 3>) custom_kernel_mlx_bun_trellis_gateup_mma_wide__bfloat16_t_17408_5120_256_2_2_12_8_3_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t<bfloat16_t, 17408, 5120, 256, 2, 2, 12, 8, 3>;\n"

def downMmaWideSignature : List Char :=
  chars!"template <typename T, int R, int C, int K, int L, int SPLITS, int SG_TG, int INTERLEAVE, int MT, int S, int NW>\n[[kernel]] void custom_kernel_mlx_bun_trellis_down_mma_wide__bfloat16_t_17408_5120_2_12_8_4_0_3_8_3_bfloat16_t_uint32_t_float16_t_float(\n  const device bfloat16_t* x [[buffer(0)]],\n  const constant int* x_shape [[buffer(1)]],\n  const device uint32_t* codes [[buffer(2)]],\n  const device float16_t* scales [[buffer(3)]],\n  device float* partial [[buffer(4)]],\n  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],\n  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def downMmaWideInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_down_mma_wide__bfloat16_t_17408_5120_2_12_8_4_0_3_8_3_bfloat16_t_uint32_t_float16_t_float\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_down_mma_wide__bfloat16_t_17408_5120_2_12_8_4_0_3_8_3_bfloat16_t_uint32_t_float16_t_float<bfloat16_t, 17408, 5120, 2, 12, 8, 4, 0, 3, 8, 3>) custom_kernel_mlx_bun_trellis_down_mma_wide__bfloat16_t_17408_5120_2_12_8_4_0_3_8_3_bfloat16_t_uint32_t_float16_t_float<bfloat16_t, 17408, 5120, 2, 12, 8, 4, 0, 3, 8, 3>;\n"

def downK3iMmaWideSignature : List Char :=
  chars!"template <typename T, int R, int C, int K, int L, int SPLITS, int SG_TG, int INTERLEAVE, int MT, int S, int NW>\n[[kernel]] void custom_kernel_mlx_bun_trellis_down_k3i_mma_wide__bfloat16_t_17408_5120_3_12_8_4_1_1_16_5_bfloat16_t_uint32_t_float16_t_float(\n  const device bfloat16_t* x [[buffer(0)]],\n  const constant int* x_shape [[buffer(1)]],\n  const device uint32_t* codes [[buffer(2)]],\n  const device float16_t* scales [[buffer(3)]],\n  device float* partial [[buffer(4)]],\n  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],\n  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def downK3iMmaWideInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_down_k3i_mma_wide__bfloat16_t_17408_5120_3_12_8_4_1_1_16_5_bfloat16_t_uint32_t_float16_t_float\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_down_k3i_mma_wide__bfloat16_t_17408_5120_3_12_8_4_1_1_16_5_bfloat16_t_uint32_t_float16_t_float<bfloat16_t, 17408, 5120, 3, 12, 8, 4, 1, 1, 16, 5>) custom_kernel_mlx_bun_trellis_down_k3i_mma_wide__bfloat16_t_17408_5120_3_12_8_4_1_1_16_5_bfloat16_t_uint32_t_float16_t_float<bfloat16_t, 17408, 5120, 3, 12, 8, 4, 1, 1, 16, 5>;\n"

def aneTrellisFillSignature : List Char :=
  chars!"template <int R, int ROWS, int C, int BT, int BITS, int L, int OFFSET, int PER>\n[[kernel]] void custom_kernel_mlx_bun_ane_trellis_fill__17408_6144_5120_256_3_12_0_16_uint32_t_float16_t_float16_t_int32_t(\n  const device uint32_t* codes [[buffer(0)]],\n  const device float16_t* scales [[buffer(1)]],\n  const device float16_t* dst [[buffer(2)]],\n  device int32_t* done [[buffer(3)]],\n  uint3 thread_position_in_grid [[thread_position_in_grid]]) {\n"

def aneTrellisFillInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_ane_trellis_fill__17408_6144_5120_256_3_12_0_16_uint32_t_float16_t_float16_t_int32_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_ane_trellis_fill__17408_6144_5120_256_3_12_0_16_uint32_t_float16_t_float16_t_int32_t<17408, 6144, 5120, 256, 3, 12, 0, 16>) custom_kernel_mlx_bun_ane_trellis_fill__17408_6144_5120_256_3_12_0_16_uint32_t_float16_t_float16_t_int32_t<17408, 6144, 5120, 256, 3, 12, 0, 16>;\n"

def aneTrellisFillK3iSignature : List Char :=
  chars!"template <int R, int ROWS, int C, int BT, int BITS, int L, int OFFSET, int PER>\n[[kernel]] void custom_kernel_mlx_bun_ane_trellis_fill_k3i__17408_6144_5120_256_3_12_0_16_uint32_t_float16_t_float16_t_int32_t(\n  const device uint32_t* codes [[buffer(0)]],\n  const device float16_t* scales [[buffer(1)]],\n  const device float16_t* dst [[buffer(2)]],\n  device int32_t* done [[buffer(3)]],\n  uint3 thread_position_in_grid [[thread_position_in_grid]]) {\n"

def aneTrellisFillK3iInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_ane_trellis_fill_k3i__17408_6144_5120_256_3_12_0_16_uint32_t_float16_t_float16_t_int32_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_ane_trellis_fill_k3i__17408_6144_5120_256_3_12_0_16_uint32_t_float16_t_float16_t_int32_t<17408, 6144, 5120, 256, 3, 12, 0, 16>) custom_kernel_mlx_bun_ane_trellis_fill_k3i__17408_6144_5120_256_3_12_0_16_uint32_t_float16_t_float16_t_int32_t<17408, 6144, 5120, 256, 3, 12, 0, 16>;\n"

def aneWriteHalfSignature : List Char :=
  chars!"template <typename T, int N, int OFFSET>\n[[kernel]] void custom_kernel_mlx_bun_ane_write_half__bfloat16_t_1146880_0_bfloat16_t_float16_t_int32_t(\n  const device bfloat16_t* src [[buffer(0)]],\n  const device float16_t* dst [[buffer(1)]],\n  device int32_t* done [[buffer(2)]],\n  uint3 thread_position_in_grid [[thread_position_in_grid]]) {\n"

def aneWriteHalfInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_ane_write_half__bfloat16_t_1146880_0_bfloat16_t_float16_t_int32_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_ane_write_half__bfloat16_t_1146880_0_bfloat16_t_float16_t_int32_t<bfloat16_t, 1146880, 0>) custom_kernel_mlx_bun_ane_write_half__bfloat16_t_1146880_0_bfloat16_t_float16_t_int32_t<bfloat16_t, 1146880, 0>;\n"

def vectorExpandSignature : List Char :=
  chars!"template <typename T, int R, int C, int BT, int BITS, int L, int INTERLEAVE, int ROW_TILE>\n[[kernel]] void custom_kernel_mlx_bun_trellis_vector_expand__bfloat16_t_11264_5120_256_2_12_0_0_uint32_t_float16_t_bfloat16_t(\n  const device uint32_t* codes [[buffer(0)]],\n  const device float16_t* scales [[buffer(1)]],\n  device bfloat16_t* out [[buffer(2)]],\n  uint3 thread_position_in_grid [[thread_position_in_grid]],\n  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def vectorExpandInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_vector_expand__bfloat16_t_11264_5120_256_2_12_0_0_uint32_t_float16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_vector_expand__bfloat16_t_11264_5120_256_2_12_0_0_uint32_t_float16_t_bfloat16_t<bfloat16_t, 11264, 5120, 256, 2, 12, 0, 0>) custom_kernel_mlx_bun_trellis_vector_expand__bfloat16_t_11264_5120_256_2_12_0_0_uint32_t_float16_t_bfloat16_t<bfloat16_t, 11264, 5120, 256, 2, 12, 0, 0>;\n"

def vectorExpandK3iSignature : List Char :=
  chars!"template <typename T, int R, int C, int BT, int BITS, int L, int INTERLEAVE, int ROW_TILE>\n[[kernel]] void custom_kernel_mlx_bun_trellis_vector_expand__bfloat16_t_11264_5120_256_3_12_2_128_uint32_t_float16_t_bfloat16_t(\n  const device uint32_t* codes [[buffer(0)]],\n  const device float16_t* scales [[buffer(1)]],\n  device bfloat16_t* out [[buffer(2)]],\n  uint3 thread_position_in_grid [[thread_position_in_grid]],\n  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],\n  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {\n"

def vectorExpandK3iInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_vector_expand__bfloat16_t_11264_5120_256_3_12_2_128_uint32_t_float16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_vector_expand__bfloat16_t_11264_5120_256_3_12_2_128_uint32_t_float16_t_bfloat16_t<bfloat16_t, 11264, 5120, 256, 3, 12, 2, 128>) custom_kernel_mlx_bun_trellis_vector_expand__bfloat16_t_11264_5120_256_3_12_2_128_uint32_t_float16_t_bfloat16_t<bfloat16_t, 11264, 5120, 256, 3, 12, 2, 128>;\n"

def affine3RowsText : List Char := text .affine3Rows affine3RowsSignature affine3RowsInstantiation
def affine4RowsText : List Char := text .affine4Rows affine4RowsSignature affine4RowsInstantiation
def affineSplitMmaText : List Char := text .affineSplitMma affineSplitMmaSignature affineSplitMmaInstantiation
def gateUpCodebookMmaText : List Char :=
  text .gateUpCodebookMma gateUpCodebookMmaSignature gateUpCodebookMmaInstantiation
def gateUpMmaWideText : List Char := text .gateUpMmaWide gateUpMmaWideSignature gateUpMmaWideInstantiation
def downMmaWideText : List Char := text .downMmaWide downMmaWideSignature downMmaWideInstantiation
def downK3iMmaWideText : List Char := text .downK3iMmaWide downK3iMmaWideSignature downK3iMmaWideInstantiation
def aneTrellisFillText : List Char := text .aneTrellisFill aneTrellisFillSignature aneTrellisFillInstantiation
def aneTrellisFillK3iText : List Char :=
  text .aneTrellisFillK3i aneTrellisFillK3iSignature aneTrellisFillK3iInstantiation
def aneWriteHalfText : List Char := text .aneWriteHalf aneWriteHalfSignature aneWriteHalfInstantiation
def vectorExpandText : List Char := text .vectorExpand vectorExpandSignature vectorExpandInstantiation
def vectorExpandK3iText : List Char := text .vectorExpand vectorExpandK3iSignature vectorExpandK3iInstantiation

/-- The kernel modules' texts at these instances. -/
theorem texts :
    Kernels.AffineRows3.text 2 10240 5120 = affine3RowsText ∧
    Kernels.AffineRows4.text 2 10240 5120 = affine4RowsText ∧
    Kernels.AffineSplitMma.text 10240 5120 3 2 2 = affineSplitMmaText ∧
    Kernels.GateUpCodebookMma.text 2 2 = gateUpCodebookMmaText ∧
    Kernels.GateUpMmaWide.text 2 2 3 = gateUpMmaWideText ∧
    Kernels.DownMmaWide.text 2 8 3 3 = downMmaWideText ∧
    Kernels.DownK3iMmaWide.text 3 16 1 5 = downK3iMmaWideText ∧
    Kernels.AneTrellisFill.text 6144 3 16 = aneTrellisFillText ∧
    Kernels.AneTrellisFillK3i.text 6144 = aneTrellisFillK3iText ∧
    Kernels.AneWriteHalf.text 1146880 = aneWriteHalfText ∧
    Kernels.VectorExpand.text 11264 2 0 0 = vectorExpandText ∧
    Kernels.VectorExpand.text 11264 3 2 128 = vectorExpandK3iText := by
  decide +kernel

/-- Every contraction site, barrier and collective has its own site. -/
theorem sites :
    [affine3RowsText, affine4RowsText, affineSplitMmaText, gateUpCodebookMmaText, gateUpMmaWideText,
      downMmaWideText, downK3iMmaWideText, aneTrellisFillText, aneTrellisFillK3iText, aneWriteHalfText,
      vectorExpandText, vectorExpandK3iText].all Elab.Tests.sitesDistinct = true := by
  decide +kernel

end Metal.Prefill.Tests
