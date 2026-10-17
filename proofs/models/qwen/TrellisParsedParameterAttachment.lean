import models.qwen.ResidualMlpParsedTrellis
import models.qwen.TrellisParameterExecution
namespace Inference.Models.Qwen.TrellisParsedParameterAttachment
open Contracts.Mlx Contracts.Mlx.M1Max Kernels.Trellis Layers WrittenLayers PackedArrayMaterialization
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF
variable {mlp : GateDown} {memory : ByteMemory.Bytes}

-- Original payload attachments are supplied by the loader contract. These
-- constructors derive the parsed inputs and all model parameter equalities.
def gateInput (weights : TrellisWeightsMemory.Weights mlp memory) : GateInput mlp.gate.width mlp.up.width :=
  ⟨mlp.gate.validWidth,mlp.up.validWidth,weights.gateCodes,weights.upCodes,weights.gateScales,weights.upScales,
    weights.gate,weights.up,weights.upShared.trans weights.gateShared.symm⟩

theorem gate_parameters (weights : TrellisWeightsMemory.Weights mlp memory) :
    TrellisMlpParsedGateProjection.Parameters mlp (gateInput weights) where
  gateWords := congrArg TrellisCodebookGateUp.Projection.words weights.gateBinding
  upWords := congrArg TrellisCodebookGateUp.Projection.words weights.upBinding
  gateScales := congrArg TrellisCodebookGateUp.Projection.scale weights.gateBinding
  upScales := congrArg TrellisCodebookGateUp.Projection.scale weights.upBinding

def downInput (weights : TrellisWeightsMemory.Weights mlp memory) : PackedArrayDownMaterialization.Input mlp.down.width :=
  ⟨mlp.down.validWidth,weights.downCodes,weights.downScales,weights.down⟩

theorem down_words (weights : TrellisWeightsMemory.Weights mlp memory) :
    (downInput weights).matrix=mlp.down.words :=
  congrArg TrellisCodebookDown.Projection.words weights.downBinding

theorem down_scales (weights : TrellisWeightsMemory.Weights mlp memory) :
    CheckpointTrellis.scale (downInput weights).scales=mlp.down.scale :=
  congrArg TrellisCodebookDown.Projection.scale weights.downBinding

variable {x update : Fin 5120 → BF} {block : ResidualBlocks.Mlp} {input : BinaryMemory.Input x update}

def parameters (existing : ResidualMlpMemory.Execution block input)
    (weights : TrellisWeightsMemory.Weights block.mlp existing.mlp.source.bytes)
    (safe : weights.Protected (TrellisMlpMemory.Safe existing.mlp)) :
    TrellisParameterExecution.Execution block.mlp existing.normalization.output := ⟨existing.mlp,weights,safe⟩

def source (existing : ResidualMlpMemory.Execution block input)
    (weights : TrellisWeightsMemory.Weights block.mlp existing.mlp.source.bytes)
    (safe : weights.Protected (TrellisMlpMemory.Safe existing.mlp))
    (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential block.mlp.activation precise absolute)
    (inputBounded : ∀ group, (existing.mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad) : ResidualMlpParsedTrellis.Source existing where
  down := downInput (parameters existing weights safe).afterMiddle
  downWords := down_words (parameters existing weights safe).afterMiddle
  downScales := down_scales (parameters existing weights safe).afterMiddle
  gate := gateInput weights
  gateParameters := gate_parameters weights
  precise := precise
  absolute := absolute
  exponential := exponential
  inputBounded := inputBounded
  vector := vector

-- Down's original code/scales are reframed onto the actual current middle
-- heap using all six protected parameter regions, before any partial writes.
theorem down_current_heap (existing : ResidualMlpMemory.Execution block input)
    (weights : TrellisWeightsMemory.Weights block.mlp existing.mlp.source.bytes)
    (safe : weights.Protected (TrellisMlpMemory.Safe existing.mlp)) :
    (downInput (parameters existing weights safe).afterMiddle).storage.code.bytes=
      existing.mlp.device.kernel.middle.memory :=
  (parameters existing weights safe).afterMiddle.downShared

theorem gate_current_heap (weights : TrellisWeightsMemory.Weights mlp memory) :
    (gateInput weights).gate.code.bytes=memory ∧ (gateInput weights).up.code.bytes=memory :=
  ⟨weights.gateShared,weights.upShared⟩

-- Entry point using original shared-heap checkpoint storage rather than
-- separately supplied gate/down parameter-function equalities.
theorem ready_error (existing : ResidualMlpMemory.Execution block input)
    (weights : TrellisWeightsMemory.Weights block.mlp existing.mlp.source.bytes)
    (safe : weights.Protected (TrellisMlpMemory.Safe existing.mlp))
    (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential block.mlp.activation precise absolute)
    (inputBounded : ∀ group, (existing.mlp.device.staging group).inputBase+10240≤2^64)
    (vector : DownFoldVectorMemory.VectorLoad)
    (allocation : Kernels.Binary.BinaryVvInterleaving.Allocation
      (ResidualMlpParsedTrellis.operands existing).lhs.base (ResidualMlpParsedTrellis.operands existing).rhs.base (2*existing.addition.base))
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i)-targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i)-targetUpdate i| ≤ errorUpdate i)
    (finite : block.Finite x update) (capacity : block.Capacity x update targetX targetUpdate errorX errorUpdate finite)
    (column : Fin 5120) :
    let attached := source existing weights safe precise absolute exponential inputBounded vector
    TrellisMlpParsedPipeline.Ready (ResidualMlpParsedTrellis.branch existing attached)
      (ResidualMlpParsedTrellis.gate existing attached) vector ∧
      |Model.toReal (ResidualMlpParsedTrellis.eventRead existing allocation column)-block.target targetX targetUpdate column| ≤
        block.budget x update targetX targetUpdate errorX errorUpdate finite column :=
  ResidualMlpParsedTrellis.ready_error existing (source existing weights safe precise absolute exponential inputBounded vector)
    allocation targetX targetUpdate errorX errorUpdate hx hu finite capacity column

end Inference.Models.Qwen.TrellisParsedParameterAttachment
