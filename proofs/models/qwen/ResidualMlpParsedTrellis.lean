import models.qwen.TrellisMlpParsedMemory
import models.qwen.ResidualMlpMemory
import kernels.binary.BinaryVvSourceRefinement
namespace Inference.Models.Qwen.ResidualMlpParsedTrellis
open Contracts.Mlx Contracts.Mlx.M1Max Kernels.Trellis Kernels.Binary Layers WrittenLayers PackedArrayMaterialization
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF
variable {x update : Fin 5120 → BF} {block : ResidualBlocks.Mlp} {input : BinaryMemory.Input x update}

-- Checkpoint/primitive/native placement attachments, independently of the
-- layer result. The existing normalization and global allocations are kept.
structure Source (existing : ResidualMlpMemory.Execution block input) where
  down : PackedArrayDownMaterialization.Input block.mlp.down.width
  downWords : down.matrix=block.mlp.down.words
  downScales : CheckpointTrellis.scale down.scales=block.mlp.down.scale
  gate : GateInput block.mlp.gate.width block.mlp.up.width
  gateParameters : TrellisMlpParsedGateProjection.Parameters block.mlp gate
  precise : Float32 → Float32
  absolute : BF → BF
  exponential : TrellisMlpParsedGateTail.Exponential block.mlp.activation precise absolute
  inputBounded : ∀ group, (existing.mlp.device.staging group).inputBase+10240≤2^64
  vector : DownFoldVectorMemory.VectorLoad

def branch (existing : ResidualMlpMemory.Execution block input) (source : Source existing) :=
  TrellisMlpParsedMemory.fromMemory existing.mlp source.down source.downWords source.downScales

def gate (existing : ResidualMlpMemory.Execution block input) (source : Source existing) :=
  TrellisMlpParsedMemory.gateExecution existing.mlp source.down source.downWords source.downScales source.gate
    source.gateParameters source.precise source.absolute source.exponential source.inputBounded

theorem normalized_input (existing : ResidualMlpMemory.Execution block input) (source : Source existing) :
    (branch existing source).preceding.source=existing.normalization.outputBuffer :=
  (TrellisMlpParsedMemory.source_same existing.mlp source.down source.downWords source.downScales).trans existing.linked

theorem ready (existing : ResidualMlpMemory.Execution block input) (source : Source existing) :
    TrellisMlpParsedPipeline.Ready (branch existing source) (gate existing source) source.vector :=
  TrellisMlpParsedPipeline.ready _ _ _

def operands (existing : ResidualMlpMemory.Execution block input) :=
  ResidualMlpMemory.additionInput existing.normalization existing.mlp existing.linked existing.residualSafe

-- The final parsed add reads the very heap produced by the parsed MLP.
theorem right_heap (existing : ResidualMlpMemory.Execution block input) (source : Source existing) :
    (TrellisMlpParsedDown.outputBuffer (branch existing source) source.vector).bytes=(operands existing).rhs.bytes :=
  TrellisMlpParsedMemory.output_bytes existing.mlp source.down source.downWords source.downScales source.vector

theorem right_base (existing : ResidualMlpMemory.Execution block input) (source : Source existing) :
    (TrellisMlpParsedDown.outputBuffer (branch existing source) source.vector).base=(operands existing).rhs.base :=
  TrellisMlpParsedMemory.output_base existing.mlp source.down source.downWords source.downScales

def parsedAdd (existing : ResidualMlpMemory.Execution block input)
    (allocation : BinaryVvInterleaving.Allocation (operands existing).lhs.base (operands existing).rhs.base (2*existing.addition.base)) :=
  BinaryVvSourceRefinement.checked (operands existing) allocation

private theorem output_heap (existing : ResidualMlpMemory.Execution block input) :
    existing.outputBuffer.bytes=existing.addition.trace.memory := rfl

theorem parsed_heap (existing : ResidualMlpMemory.Execution block input)
    (allocation : BinaryVvInterleaving.Allocation (operands existing).lhs.base (operands existing).rhs.base (2*existing.addition.base)) :
    (parsedAdd existing allocation).bodyAfter=existing.outputBuffer.bytes ∧
    (parsedAdd existing allocation).eventAfter.memory=existing.outputBuffer.bytes := by
  have same:=BinaryVvSourceRefinement.checked_eq_existing (operands existing) allocation existing.addition rfl
  exact ⟨same.1.trans (output_heap existing).symm,same.2.trans (output_heap existing).symm⟩

def eventRead (existing : ResidualMlpMemory.Execution block input)
    (allocation : BinaryVvInterleaving.Allocation (operands existing).lhs.base (operands existing).rhs.base (2*existing.addition.base))
    (column : Fin 5120) : BF :=
  Model.ofBits (HalfMemory.load (parsedAdd existing allocation).eventAfter.memory
    (existing.outputBuffer.base+2*column.val))

theorem event_eq (existing : ResidualMlpMemory.Execution block input)
    (allocation : BinaryVvInterleaving.Allocation (operands existing).lhs.base (operands existing).rhs.base (2*existing.addition.base))
    (column : Fin 5120) : eventRead existing allocation column=block.forward x update column := by
  rw [eventRead,(parsed_heap existing allocation).2]
  exact (ArrayStorage.BFBuffer.read_correct existing.outputBuffer column).trans (congrFun existing.output_eq column)

theorem ready_error (existing : ResidualMlpMemory.Execution block input) (source : Source existing)
    (allocation : BinaryVvInterleaving.Allocation (operands existing).lhs.base (operands existing).rhs.base (2*existing.addition.base))
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i)-targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i)-targetUpdate i| ≤ errorUpdate i)
    (finite : block.Finite x update) (capacity : block.Capacity x update targetX targetUpdate errorX errorUpdate finite)
    (column : Fin 5120) :
    TrellisMlpParsedPipeline.Ready (branch existing source) (gate existing source) source.vector ∧
      |Model.toReal (eventRead existing allocation column)-block.target targetX targetUpdate column| ≤
        block.budget x update targetX targetUpdate errorX errorUpdate finite column := by
  refine ⟨ready existing source,?_⟩
  rw [event_eq]
  exact block.forward_error x update targetX targetUpdate errorX errorUpdate hx hu finite capacity column

theorem parsed_frame (existing : ResidualMlpMemory.Execution block input)
    (allocation : BinaryVvInterleaving.Allocation (operands existing).lhs.base (operands existing).rhs.base (2*existing.addition.base))
    {base size : Nat} (safe : ResidualMlpMemory.Safe existing base size) (offset : Nat) (bound : offset<size) :
    (parsedAdd existing allocation).eventAfter.memory (base+offset)=input.lhs.bytes (base+offset) := by
  rw [(parsed_heap existing allocation).2]
  exact existing.other_region safe offset bound

end Inference.Models.Qwen.ResidualMlpParsedTrellis
