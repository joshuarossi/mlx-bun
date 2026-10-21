import metal.Assemble
import host.mlx.KernelSources
import host.mlx.Kernel

namespace Metal.Assemble.Tests
open Host.Mlx Host.Mlx.SourceKernels

/-! # Assembled text of the route's custom kernels

One decode launch of each route kernel: the constructor's name and input and
output names (packages/inference/src/kernels/**.ts), body and header
(`KernelSources`, bound to that TypeScript by KernelSourceBinding.ts), the
launch's `Config` (Kernel.lean) for the output dtypes and template arguments,
and the input dtypes and shapes the `KernelContract` fields and loaded weights
give. Concrete sizes are layer 1's (host/load/Data.lean quantization:
in_proj_qkv 3-bit affine, gate/up 2-bit and down 3-bit Trellis). The texts are
computed by kernel reduction (`decide +kernel`). -/

/-- metal-kernel.ts `apply`: the template dtypes, then the ints, each in
insertion order (`Object.entries`). -/
def configArgs (c : Config) : List TemplateArg :=
  c.templateDtypes.map (fun (n, d) => .dtype n.toList d) ++ c.templateInts.map (fun (n, v) => .int n.toList v)

/-- A route kernel built by `MetalKernel` (atomicOutputs unset: false) and
applied with `c`. -/
def launch (k : Kernel) (name : List Char) (inputs : List Input) (outputs : List (List Char)) (c : Config) :
    Option (List Char) :=
  assemble name inputs outputs (c.outputs.map (·.2)) (sources.source k) (sources.header k) (configArgs c) false

/-- Header, signature, body, closing brace, instantiation. -/
def text (k : Kernel) (signature instantiation : List Char) : List Char :=
  sources.header k ++ signature ++ sources.source k ++ chars!"\n}\n" ++ instantiation

/-- The names used below are the route's FFI kernel names. -/
theorem route_names :
    FfiEval.kernelOf chars!"mlx_bun_affine_row" = some .affineRow ∧
    FfiEval.kernelOf chars!"mlx_bun_silu_rms_heads" = some .siluRmsHeads ∧
    FfiEval.kernelOf chars!"gated_delta_step" = some .gatedDeltaStep ∧
    FfiEval.kernelOf chars!"mlx_bun_gated_rms_norm" = some .gatedRmsNorm ∧
    FfiEval.kernelOf chars!"mlx_bun_residual_rms_norm" = some .residualRmsNorm ∧
    FfiEval.kernelOf chars!"mlx_bun_trellis_gateup_codebook_row" = some .gateUp ∧
    FfiEval.kernelOf chars!"mlx_bun_trellis_down_codebook_row" = some .downPartial ∧
    FfiEval.kernelOf chars!"mlx_bun_trellis_down_codebook_fold" = some .downFold ∧
    FfiEval.kernelOf chars!"normalized_argmax_partial" = some .argmaxPartial ∧
    FfiEval.kernelOf chars!"normalized_argmax_finish" = some .argmaxFinish := by decide +kernel

/-! ## affine-row.ts: in_proj_qkv, K = 5120 (10 steps), N = 10240, 3 bits

`affineRow3`: x is `Row x (steps*512)`, w `uint32 [rows, steps*48]`, scales
and biases `bfloat16 [rows, steps*8]`. -/

def affineRowInputs : List Input :=
  [⟨chars!"x", .bfloat16, [1, 1, 5120]⟩, ⟨chars!"w", .uint32, [10240, 480]⟩,
    ⟨chars!"scales", .bfloat16, [10240, 80]⟩, ⟨chars!"biases", .bfloat16, [10240, 80]⟩]

def affineRowName : List Char :=
  chars!"custom_kernel_mlx_bun_affine_row__bfloat16_t_10240_5120_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t"

def affineRowSignature : List Char :=
  chars!"template <typename T, int N, int K, int BITS, int R, int S>
[[kernel]] void custom_kernel_mlx_bun_affine_row__bfloat16_t_10240_5120_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device uint32_t* w [[buffer(1)]],
  const device bfloat16_t* scales [[buffer(2)]],
  const device bfloat16_t* biases [[buffer(3)]],
  device bfloat16_t* y [[buffer(4)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"

def affineRowInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_affine_row__bfloat16_t_10240_5120_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_affine_row__bfloat16_t_10240_5120_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 10240, 5120, 3, 4, 16>) custom_kernel_mlx_bun_affine_row__bfloat16_t_10240_5120_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 10240, 5120, 3, 4, 16>;\n"

theorem affineRow_name :
    kernelName chars!"mlx_bun_affine_row" affineRowInputs [.bfloat16] (configArgs (affineConfig 5120 10240 3)) =
      some affineRowName := by decide +kernel

theorem affineRow_signature :
    signature affineRowName (sources.source .affineRow) affineRowInputs [chars!"y"] [.bfloat16]
      (configArgs (affineConfig 5120 10240 3)) false = some affineRowSignature := by decide +kernel

theorem affineRow_assemble :
    launch .affineRow chars!"mlx_bun_affine_row" affineRowInputs [chars!"y"] (affineConfig 5120 10240 3) =
      some (text .affineRow affineRowSignature affineRowInstantiation) := by decide +kernel

/-- The same text for any arrays of the dtypes and shapes `affineRow3` assumes. -/
theorem affineRow_contract {p : Inference.Layers.AffineVerifyLinear.Projection3 10 (4*(160*16))}
    {input : Fin (10*512) → _} {x w scales biases : Value}
    (hx : Row x (10*512) input) (hw : Affine3 p w scales biases) :
    launch .affineRow chars!"mlx_bun_affine_row"
      [⟨chars!"x", x.dtype, x.shape⟩, ⟨chars!"w", w.dtype, w.shape⟩,
        ⟨chars!"scales", scales.dtype, scales.shape⟩, ⟨chars!"biases", biases.dtype, biases.shape⟩]
      [chars!"y"] (affineConfig (10*512) (4*(160*16)) 3) =
      some (text .affineRow affineRowSignature affineRowInstantiation) := by
  rw [hx.1, hx.2.1, hw.words.1, hw.words.2, hw.groups.1, hw.groups.2.1, hw.groups.2.2.1, hw.groups.2.2.2]
  exact affineRow_assemble

/-! ## silu-rms-heads.ts: x `Row x 10240`, q/k scales `Vector _ 128` -/

def siluRmsHeadsSignature : List Char :=
  chars!"template <typename T, int C, int HK, int HV, int DK, int DV>
[[kernel]] void custom_kernel_mlx_bun_silu_rms_heads__bfloat16_t_10240_16_48_128_128_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device bfloat16_t* qscale [[buffer(1)]],
  const device bfloat16_t* kscale [[buffer(2)]],
  device bfloat16_t* q [[buffer(3)]],
  device bfloat16_t* k [[buffer(4)]],
  device bfloat16_t* v [[buffer(5)]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"

def siluRmsHeadsInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_silu_rms_heads__bfloat16_t_10240_16_48_128_128_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_silu_rms_heads__bfloat16_t_10240_16_48_128_128_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 10240, 16, 48, 128, 128>) custom_kernel_mlx_bun_silu_rms_heads__bfloat16_t_10240_16_48_128_128_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 10240, 16, 48, 128, 128>;\n"

theorem siluRmsHeads_assemble :
    launch .siluRmsHeads chars!"mlx_bun_silu_rms_heads"
      [⟨chars!"x", .bfloat16, [1, 1, 10240]⟩, ⟨chars!"qscale", .bfloat16, [128]⟩, ⟨chars!"kscale", .bfloat16, [128]⟩]
      [chars!"q", chars!"k", chars!"v"] headsConfig =
      some (text .siluRmsHeads siluRmsHeadsSignature siluRmsHeadsInstantiation) := by decide +kernel

/-! ## gated.ts launchRecurrence (no mask), B = T = 1

`gatedDeltaStep`: q, k `[1,1,16,128]`, v `[1,1,48,128]`, beta `[1,1,48]`
bfloat16; g `float32 [1,1,48]`; state `float32 [1,48,128,128]`; Tin
`int32 [1]` (one element: the constant address space). -/

def gatedDeltaStepSignature : List Char :=
  chars!"template <typename InT, typename StT, int Dk, int Dv, int Hk, int Hv>
[[kernel]] void custom_kernel_gated_delta_step__bfloat16_t_float_128_128_16_48_bfloat16_t_bfloat16_t_bfloat16_t_float_bfloat16_t_float_int32_tc_bfloat16_t_float(
  const device bfloat16_t* q [[buffer(0)]],
  const device bfloat16_t* k [[buffer(1)]],
  const device bfloat16_t* v [[buffer(2)]],
  const device float* g [[buffer(3)]],
  const device bfloat16_t* beta [[buffer(4)]],
  const device float* state_in [[buffer(5)]],
  const constant int32_t* Tin [[buffer(6)]],
  device bfloat16_t* y [[buffer(7)]],
  device float* state_out [[buffer(8)]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 thread_position_in_grid [[thread_position_in_grid]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]]) {
"

def gatedDeltaStepInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_gated_delta_step__bfloat16_t_float_128_128_16_48_bfloat16_t_bfloat16_t_bfloat16_t_float_bfloat16_t_float_int32_tc_bfloat16_t_float\")]] [[kernel]] decltype(custom_kernel_gated_delta_step__bfloat16_t_float_128_128_16_48_bfloat16_t_bfloat16_t_bfloat16_t_float_bfloat16_t_float_int32_tc_bfloat16_t_float<bfloat16_t, float, 128, 128, 16, 48>) custom_kernel_gated_delta_step__bfloat16_t_float_128_128_16_48_bfloat16_t_bfloat16_t_bfloat16_t_float_bfloat16_t_float_int32_tc_bfloat16_t_float<bfloat16_t, float, 128, 128, 16, 48>;\n"

theorem gatedDeltaStep_assemble :
    launch .gatedDeltaStep chars!"gated_delta_step"
      [⟨chars!"q", .bfloat16, [1, 1, 16, 128]⟩, ⟨chars!"k", .bfloat16, [1, 1, 16, 128]⟩,
        ⟨chars!"v", .bfloat16, [1, 1, 48, 128]⟩, ⟨chars!"g", .float32, [1, 1, 48]⟩,
        ⟨chars!"beta", .bfloat16, [1, 1, 48]⟩, ⟨chars!"state_in", .float32, [1, 48, 128, 128]⟩,
        ⟨chars!"Tin", .int32, [1]⟩]
      [chars!"y", chars!"state_out"] gatedConfig =
      some (text .gatedDeltaStep gatedDeltaStepSignature gatedDeltaStepInstantiation) := by decide +kernel

/-! ## gated-rms-norm.ts: x, gate `[1,1,48,128]`, weight `Vector _ 128` -/

def gatedRmsNormSignature : List Char :=
  chars!"template <typename T, int D, int THREADS, int EPS>
[[kernel]] void custom_kernel_mlx_bun_gated_rms_norm__bfloat16_t_128_32_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device bfloat16_t* gate [[buffer(1)]],
  const device bfloat16_t* weight [[buffer(2)]],
  device bfloat16_t* out [[buffer(3)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"

def gatedRmsNormInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_gated_rms_norm__bfloat16_t_128_32_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_gated_rms_norm__bfloat16_t_128_32_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 128, 32, 897988541>) custom_kernel_mlx_bun_gated_rms_norm__bfloat16_t_128_32_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 128, 32, 897988541>;\n"

theorem gatedRmsNorm_assemble :
    launch .gatedRmsNorm chars!"mlx_bun_gated_rms_norm"
      [⟨chars!"x", .bfloat16, [1, 1, 48, 128]⟩, ⟨chars!"gate", .bfloat16, [1, 1, 48, 128]⟩,
        ⟨chars!"weight", .bfloat16, [128]⟩]
      [chars!"out"] gatedNormConfig =
      some (text .gatedRmsNorm gatedRmsNormSignature gatedRmsNormInstantiation) := by decide +kernel

/-! ## residual-rms-norm.ts: x, update `Row _ 5120`, weight `Vector _ 5120` -/

def residualRmsNormSignature : List Char :=
  chars!"template <typename T, int D, int THREADS, int EPS>
[[kernel]] void custom_kernel_mlx_bun_residual_rms_norm__bfloat16_t_5120_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device bfloat16_t* update [[buffer(1)]],
  const device bfloat16_t* weight [[buffer(2)]],
  device bfloat16_t* residual [[buffer(3)]],
  device bfloat16_t* normalized [[buffer(4)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"

def residualRmsNormInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_residual_rms_norm__bfloat16_t_5120_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_residual_rms_norm__bfloat16_t_5120_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 5120, 1024, 897988541>) custom_kernel_mlx_bun_residual_rms_norm__bfloat16_t_5120_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 5120, 1024, 897988541>;\n"

theorem residualRmsNorm_assemble :
    launch .residualRmsNorm chars!"mlx_bun_residual_rms_norm"
      [⟨chars!"x", .bfloat16, [1, 1, 5120]⟩, ⟨chars!"update", .bfloat16, [1, 1, 5120]⟩,
        ⟨chars!"weight", .bfloat16, [5120]⟩]
      [chars!"residual", chars!"normalized"] residualConfig =
      some (text .residualRmsNorm residualRmsNormSignature residualRmsNormInstantiation) := by decide +kernel

/-! ## gate-up-codebook.ts, gate and up 2-bit

x `Flat x [1,5120]`; codes `uint32 [17408, 5120·2/32]` (trellis-linear.ts
trellisGeometry, row-major words); scales `float16 [17408]`
(checkpoint-trellis.ts). -/

def gateUpSignature : List Char :=
  chars!"template <typename T, int R, int C, int BT, int KG, int KU, int L, int ROWS_TG, int THREADS, int TAIL>
[[kernel]] void custom_kernel_mlx_bun_trellis_gateup_codebook_row__bfloat16_t_17408_5120_256_2_2_12_32_1024_0_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device uint32_t* gcodes [[buffer(1)]],
  const device float16_t* gscales [[buffer(2)]],
  const device uint32_t* ucodes [[buffer(3)]],
  const device float16_t* uscales [[buffer(4)]],
  device bfloat16_t* mid [[buffer(5)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 thread_position_in_grid [[thread_position_in_grid]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroups_per_grid [[threadgroups_per_grid]]) {
"

def gateUpInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_gateup_codebook_row__bfloat16_t_17408_5120_256_2_2_12_32_1024_0_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_gateup_codebook_row__bfloat16_t_17408_5120_256_2_2_12_32_1024_0_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t<bfloat16_t, 17408, 5120, 256, 2, 2, 12, 32, 1024, 0>) custom_kernel_mlx_bun_trellis_gateup_codebook_row__bfloat16_t_17408_5120_256_2_2_12_32_1024_0_bfloat16_t_uint32_t_float16_t_uint32_t_float16_t_bfloat16_t<bfloat16_t, 17408, 5120, 256, 2, 2, 12, 32, 1024, 0>;\n"

theorem gateUp_assemble :
    launch .gateUp chars!"mlx_bun_trellis_gateup_codebook_row"
      [⟨chars!"x", .bfloat16, [1, 5120]⟩, ⟨chars!"gcodes", .uint32, [17408, 160]⟩,
        ⟨chars!"gscales", .float16, [17408]⟩, ⟨chars!"ucodes", .uint32, [17408, 160]⟩,
        ⟨chars!"uscales", .float16, [17408]⟩]
      [chars!"mid"] (gateUpConfig 2 2) =
      some (text .gateUp gateUpSignature gateUpInstantiation) := by decide +kernel

/-! ## down-codebook.ts, down 3-bit (block-interleaved)

x is gate-up's output `[1,17408]`; codes `uint32 [5120/512, 17408, 48]`
(trellisGeometry's interleaved case); scales `float16 [17408]`. -/

def downPartialSignature : List Char :=
  chars!"template <typename T, int R, int C, int K, int L, int P, int U, int SPLITS, int THREADS, int INTERLEAVE>
[[kernel]] void custom_kernel_mlx_bun_trellis_down_codebook_row__bfloat16_t_17408_5120_3_12_16_2_128_256_1_bfloat16_t_uint32_t_float16_t_float(
  const device bfloat16_t* x [[buffer(0)]],
  const device uint32_t* codes [[buffer(1)]],
  const device float16_t* scales [[buffer(2)]],
  device float* partial [[buffer(3)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"

def downPartialInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_down_codebook_row__bfloat16_t_17408_5120_3_12_16_2_128_256_1_bfloat16_t_uint32_t_float16_t_float\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_down_codebook_row__bfloat16_t_17408_5120_3_12_16_2_128_256_1_bfloat16_t_uint32_t_float16_t_float<bfloat16_t, 17408, 5120, 3, 12, 16, 2, 128, 256, 1>) custom_kernel_mlx_bun_trellis_down_codebook_row__bfloat16_t_17408_5120_3_12_16_2_128_256_1_bfloat16_t_uint32_t_float16_t_float<bfloat16_t, 17408, 5120, 3, 12, 16, 2, 128, 256, 1>;\n"

theorem downPartial_assemble :
    launch .downPartial chars!"mlx_bun_trellis_down_codebook_row"
      [⟨chars!"x", .bfloat16, [1, 17408]⟩, ⟨chars!"codes", .uint32, [10, 17408, 48]⟩,
        ⟨chars!"scales", .float16, [17408]⟩]
      [chars!"partial"] (downConfig 3) =
      some (text .downPartial downPartialSignature downPartialInstantiation) := by decide +kernel

/-! ## down-codebook.ts fold: the partials `float32 [1,32,5120]` -/

def downFoldSignature : List Char :=
  chars!"template <typename T, int C>
[[kernel]] void custom_kernel_mlx_bun_trellis_down_codebook_fold__bfloat16_t_5120_float_bfloat16_t(
  const device float* partial [[buffer(0)]],
  device bfloat16_t* out [[buffer(1)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"

def downFoldInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_mlx_bun_trellis_down_codebook_fold__bfloat16_t_5120_float_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_down_codebook_fold__bfloat16_t_5120_float_bfloat16_t<bfloat16_t, 5120>) custom_kernel_mlx_bun_trellis_down_codebook_fold__bfloat16_t_5120_float_bfloat16_t<bfloat16_t, 5120>;\n"

theorem downFold_assemble :
    launch .downFold chars!"mlx_bun_trellis_down_codebook_fold"
      [⟨chars!"partial", .float32, [1, 32, 5120]⟩] [chars!"out"] foldConfig =
      some (text .downFold downFoldSignature downFoldInstantiation) := by decide +kernel

/-! ## normalized-argmax.ts: logits `[1,248320]`, lse `[1,1]` (one element:
the constant address space); the partials `float32`/`uint32 [1,243]` -/

def argmaxPartialSignature : List Char :=
  chars!"template <typename T, int V, int P>
[[kernel]] void custom_kernel_normalized_argmax_partial__bfloat16_t_248320_243_bfloat16_t_bfloat16_tc_float_uint32_t(
  const device bfloat16_t* logits [[buffer(0)]],
  const constant bfloat16_t* lse [[buffer(1)]],
  device float* values [[buffer(2)]],
  device uint32_t* indices [[buffer(3)]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"

def argmaxPartialInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_normalized_argmax_partial__bfloat16_t_248320_243_bfloat16_t_bfloat16_tc_float_uint32_t\")]] [[kernel]] decltype(custom_kernel_normalized_argmax_partial__bfloat16_t_248320_243_bfloat16_t_bfloat16_tc_float_uint32_t<bfloat16_t, 248320, 243>) custom_kernel_normalized_argmax_partial__bfloat16_t_248320_243_bfloat16_t_bfloat16_tc_float_uint32_t<bfloat16_t, 248320, 243>;\n"

theorem argmaxPartial_assemble :
    launch .argmaxPartial chars!"normalized_argmax_partial"
      [⟨chars!"logits", .bfloat16, [1, 248320]⟩, ⟨chars!"lse", .bfloat16, [1, 1]⟩]
      [chars!"values", chars!"indices"] partialConfig =
      some (text .argmaxPartial argmaxPartialSignature argmaxPartialInstantiation) := by decide +kernel

def argmaxFinishSignature : List Char :=
  chars!"template <int P>
[[kernel]] void custom_kernel_normalized_argmax_finish__243_float_uint32_t_uint32_t(
  const device float* values [[buffer(0)]],
  const device uint32_t* indices [[buffer(1)]],
  device uint32_t* out [[buffer(2)]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"

def argmaxFinishInstantiation : List Char :=
  chars!"\ntemplate [[host_name(\"custom_kernel_normalized_argmax_finish__243_float_uint32_t_uint32_t\")]] [[kernel]] decltype(custom_kernel_normalized_argmax_finish__243_float_uint32_t_uint32_t<243>) custom_kernel_normalized_argmax_finish__243_float_uint32_t_uint32_t<243>;\n"

theorem argmaxFinish_assemble :
    launch .argmaxFinish chars!"normalized_argmax_finish"
      [⟨chars!"values", .float32, [1, 243]⟩, ⟨chars!"indices", .uint32, [1, 243]⟩]
      [chars!"out"] finishConfig =
      some (text .argmaxFinish argmaxFinishSignature argmaxFinishInstantiation) := by decide +kernel

end Metal.Assemble.Tests
