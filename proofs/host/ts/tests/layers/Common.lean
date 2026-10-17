import host.ts.ast.inference.artifacts.Config
import host.ts.ast.inference.artifacts.Safetensors
import host.ts.ast.inference.artifacts.Weights
import host.ts.ast.inference.kernels.delta.Gated
import host.ts.ast.inference.kernels.delta.SiluRmsHeads
import host.ts.ast.inference.kernels.GatedRmsNorm
import host.ts.ast.inference.kernels.quantization.AffineRow
import host.ts.ast.inference.kernels.ResidualRmsNorm
import host.ts.ast.inference.kernels.trellis.Codebook
import host.ts.ast.inference.kernels.trellis.DownCodebook
import host.ts.ast.inference.kernels.trellis.GateUpCodebook
import host.ts.ast.inference.kernels.trellis.Launch
import host.ts.ast.inference.layers.AffineVerifyLinear
import host.ts.ast.inference.layers.CompiledNormalization
import host.ts.ast.inference.layers.DeltaHeads
import host.ts.ast.inference.layers.Helpers
import host.ts.ast.inference.layers.Lora
import host.ts.ast.inference.layers.Normalization
import host.ts.ast.inference.layers.QuantizedLinear
import host.ts.ast.inference.layers.Swiglu
import host.ts.ast.inference.layers.TrellisCodebookDown
import host.ts.ast.inference.layers.TrellisCodebookGateUp
import host.ts.ast.inference.layers.TrellisLinear
import host.ts.ast.inference.layers.TrellisPrompt
import host.ts.ast.inference.models.qwen.Blocks
import host.ts.ast.inference.models.qwen.Checkpoint
import host.ts.ast.inference.models.qwen.WrittenLayers
import host.ts.ast.inference.state.AttentionRead
import host.ts.ast.inference.state.Kv
import host.ts.ast.inference.state.Ssm
import host.ts.ast.mlx.Array
import host.ts.ast.mlx.Compile
import host.ts.ast.mlx.Ffi
import host.ts.ast.mlx.Materialize
import host.ts.ast.mlx.MetalKernel
import host.ts.ast.mlx.Ops
import host.mlx.FfiExpr

/-! Modules shared by the layer runs (`AttnLayer`, `DeltaLayer`): stand-ins for files on
the import graph that the runs do not execute (each function throws, each class
constructor throws; `TRELLIS_MATVEC_MAX_M` carries the value of
`kernels/trellis/reduce.ts`), and the host module `sym` exporting the symbolic cache
offset `n` (number-table entry 0). Everything else is the repository source. -/

namespace Host.Ts.Tests.Layers.StandInferenceArtifactsMmap
/-- Stand-in for `packages/inference/src/artifacts/mmap.ts`. -/
def source : String := "export class MmapFile { static open() { throw new Error(\"stand-in\"); } }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceArtifactsMmap

namespace Host.Ts.Tests.Layers.StandInferenceKernelsAttentionMasks
/-- Stand-in for `packages/inference/src/kernels/attention/masks.ts`. -/
def source : String := "export function bidirMask() { throw new Error(\"stand-in\"); }\nexport function createCausalMask() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsAttentionMasks

namespace Host.Ts.Tests.Layers.StandInferenceKernelsDeltaState
/-- Stand-in for `packages/inference/src/kernels/delta/state.ts`. -/
def source : String := "export function gatedDeltaState() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsDeltaState

namespace Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffineRows
/-- Stand-in for `packages/inference/src/kernels/quantization/affine-rows.ts`. -/
def source : String := "export function quantizedMatmulRows() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffineRows

namespace Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffineSplitMma
/-- Stand-in for `packages/inference/src/kernels/quantization/affine-split-mma.ts`. -/
def source : String := "export function affineSplitMma() { throw new Error(\"stand-in\"); }\nexport function affineSplitMmaEligible() { throw new Error(\"stand-in\"); }\nexport function affineSplitMmaPlan() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffineSplitMma

namespace Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffine3Mma
/-- Stand-in for `packages/inference/src/kernels/quantization/affine3-mma.ts`. -/
def source : String := "export function affine3Mma() { throw new Error(\"stand-in\"); }\nexport function affine3MmaEligible() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffine3Mma

namespace Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffine3Rows
/-- Stand-in for `packages/inference/src/kernels/quantization/affine3-rows.ts`. -/
def source : String := "export function affine3Rows() { throw new Error(\"stand-in\"); }\nexport function affine3RowsEligible() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffine3Rows

namespace Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffine4Mma
/-- Stand-in for `packages/inference/src/kernels/quantization/affine4-mma.ts`. -/
def source : String := "export function affine4Mma() { throw new Error(\"stand-in\"); }\nexport function affine4MmaEligible() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffine4Mma

namespace Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffine4Rows
/-- Stand-in for `packages/inference/src/kernels/quantization/affine4-rows.ts`. -/
def source : String := "export function affine4Rows() { throw new Error(\"stand-in\"); }\nexport function affine4RowsEligible() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsQuantizationAffine4Rows

namespace Host.Ts.Tests.Layers.StandInferenceKernelsTrellisIndex
/-- Stand-in for `packages/inference/src/kernels/trellis/index.ts`. -/
def source : String := "export const TRELLIS_MATVEC_MAX_M = 4;\nexport function expandTrellis() { throw new Error(\"stand-in\"); }\nexport function trellisReduce() { throw new Error(\"stand-in\"); }\nexport function trellisScatter() { throw new Error(\"stand-in\"); }\nexport function fusedGateUpSwiglu() { throw new Error(\"stand-in\"); }\nexport function tiledTrellisPrefill() { throw new Error(\"stand-in\"); }\nexport function tiledTrellisPrefillEligible() { throw new Error(\"stand-in\"); }\nexport function splitKTrellisPrefill() { throw new Error(\"stand-in\"); }\nexport function splitKTrellisPrefillEligible() { throw new Error(\"stand-in\"); }\nexport function wideTrellisPrefill() { throw new Error(\"stand-in\"); }\nexport function wideTrellisPrefillEligible() { throw new Error(\"stand-in\"); }\nexport function qualifiedRepresentations() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceKernelsTrellisIndex

namespace Host.Ts.Tests.Layers.StandInferenceLayersAnePrefillSplit
/-- Stand-in for `packages/inference/src/layers/ane-prefill-split.ts`. -/
def source : String := "export class AneAffineSplit { constructor() { throw new Error(\"stand-in\"); } }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceLayersAnePrefillSplit

namespace Host.Ts.Tests.Layers.StandInferenceLayersFoldedAttention
/-- Stand-in for `packages/inference/src/layers/folded-attention.ts`. -/
def source : String := "export function foldedSdpa() { throw new Error(\"stand-in\"); }\nexport function foldedSdpaEligible() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceLayersFoldedAttention

namespace Host.Ts.Tests.Layers.StandInferenceLayersQwenMrope
/-- Stand-in for `packages/inference/src/layers/qwen-mrope.ts`. -/
def source : String := "export function applyInterleavedRope() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceLayersQwenMrope

namespace Host.Ts.Tests.Layers.StandInferenceRuntimeResources
/-- Stand-in for `packages/inference/src/runtime/resources.ts`. -/
def source : String := "export function disposeResources() { throw new Error(\"stand-in\"); }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceRuntimeResources

namespace Host.Ts.Tests.Layers.StandInferenceStateQuantizedKv
/-- Stand-in for `packages/inference/src/state/quantized-kv.ts`. -/
def source : String := "export class QuantizedKVCache { constructor() { throw new Error(\"stand-in\"); } }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceStateQuantizedKv

namespace Host.Ts.Tests.Layers.StandInferenceStateTurboquantAttention
/-- Stand-in for `packages/inference/src/state/turboquant-attention.ts`. -/
def source : String := "export const uncomposedTurboQuantKernels = Object.freeze({});"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandInferenceStateTurboquantAttention

namespace Host.Ts.Tests.Layers.StandMlxAutograd
/-- Stand-in for `packages/mlx/src/autograd.ts`. -/
def source : String := "export class Vjp { constructor() { throw new Error(\"stand-in\"); } }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandMlxAutograd

namespace Host.Ts.Tests.Layers.StandMlxCommandBuffers
/-- Stand-in for `packages/mlx/src/command-buffers.ts`. -/
def source : String := "export function applyCommandBufferLimits() {}"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandMlxCommandBuffers

namespace Host.Ts.Tests.Layers.StandMlxCustomVjp
/-- Stand-in for `packages/mlx/src/custom-vjp.ts`. -/
def source : String := "export class CustomVjp { constructor() { throw new Error(\"stand-in\"); } }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandMlxCustomVjp

namespace Host.Ts.Tests.Layers.StandMlxHostBuffer
/-- Stand-in for `packages/mlx/src/host-buffer.ts`. -/
def source : String := "export const hostBufferDestructor = 4096;\nexport class HostBuffer {}"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandMlxHostBuffer

namespace Host.Ts.Tests.Layers.StandMlxNative
/-- Stand-in for `packages/mlx/src/native.ts`. -/
def source : String := "export const MLX_CORE_VERSION = \"0.32.2\";\nexport function resolveLibmlxc() { return \"/opt/libmlxc.dylib\"; }"
source_parse source
source_ast
end Host.Ts.Tests.Layers.StandMlxNative

namespace Host.Ts.Tests.Layers
open Host.Ts
def symMod {S : Type} : HMod S := ⟨chars!"sym", pure [(chars!"n", .num (.ref 0))]⟩
end Host.Ts.Tests.Layers
