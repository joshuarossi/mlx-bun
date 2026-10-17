import kernels.trellis.DownInputTraceTransport
import kernels.trellis.GateInputTraceTransport
import models.qwen.TrellisMlpParsedPipeline
import models.qwen.TrellisMlpMemory
namespace Inference.Models.Qwen.TrellisMlpParsedMemory
open Contracts.Mlx Contracts.Mlx.M1Max Kernels.Trellis Layers WrittenLayers PackedArrayMaterialization
set_option maxRecDepth 10000
abbrev BF := ArrayStorage.BF
variable {mlp : GateDown} {input : Fin 5120 → BF}

def activation (existing : TrellisMlpMemory.Execution mlp input) : Nat → Float32 :=
  DownLaneSource.activationValue (TrellisMlpParsedDown.middleValues existing.device)

theorem activation_same (existing : TrellisMlpMemory.Execution mlp input) (row : Nat) (bound : row<17408) :
    existing.device.kernel.middle.read row=activation existing row :=
  (existing.device.kernel.middle.read_correct row bound).trans
    (DownLaneSource.activation_value (TrellisMlpParsedDown.middleValues existing.device) row bound)

def reinput (existing : TrellisMlpMemory.Execution mlp input) :=
  DownInputTraceTransport.deviceTrace existing.device.kernel.down (activation existing) (activation_same existing)

def fromMemory (existing : TrellisMlpMemory.Execution mlp input)
    (packed : PackedArrayDownMaterialization.Input mlp.down.width)
    (words : packed.matrix=mlp.down.words) (scales : CheckpointTrellis.scale packed.scales=mlp.down.scale) :
    TrellisMlpParsedDown.Execution mlp input where
  preceding := existing.device
  packed := packed
  words := words
  scales := scales
  down := DownInputTraceTransport.parameters (reinput existing) packed.matrix (CheckpointTrellis.scale packed.scales) words scales
  output := DownInputTraceTransport.parametersOutput (reinput existing) packed.matrix (CheckpointTrellis.scale packed.scales)
    words scales mlp.downPlatform.reduce existing.device.kernel.output

theorem source_same (existing : TrellisMlpMemory.Execution mlp input)
    (packed : PackedArrayDownMaterialization.Input mlp.down.width)
    (words : packed.matrix=mlp.down.words) (scales : CheckpointTrellis.scale packed.scales=mlp.down.scale) :
    (fromMemory existing packed words scales).preceding.source=existing.source := rfl

theorem output_memory (existing : TrellisMlpMemory.Execution mlp input)
    (packed : PackedArrayDownMaterialization.Input mlp.down.width)
    (words : packed.matrix=mlp.down.words) (scales : CheckpointTrellis.scale packed.scales=mlp.down.scale) :
    (fromMemory existing packed words scales).output.memory=existing.device.kernel.output.memory :=
  DownInputTraceTransport.parameters_output_memory (reinput existing) packed.matrix (CheckpointTrellis.scale packed.scales)
    words scales mlp.downPlatform.reduce existing.device.kernel.output

theorem output_base (existing : TrellisMlpMemory.Execution mlp input)
    (packed : PackedArrayDownMaterialization.Input mlp.down.width)
    (words : packed.matrix=mlp.down.words) (scales : CheckpointTrellis.scale packed.scales=mlp.down.scale) :
    (fromMemory existing packed words scales).output.base=existing.device.kernel.output.base :=
  (DownInputTraceTransport.parameters_output_fields (reinput existing) packed.matrix (CheckpointTrellis.scale packed.scales)
    words scales mlp.downPlatform.reduce existing.device.kernel.output).2.1

theorem output_bytes (existing : TrellisMlpMemory.Execution mlp input)
    (packed : PackedArrayDownMaterialization.Input mlp.down.width)
    (words : packed.matrix=mlp.down.words) (scales : CheckpointTrellis.scale packed.scales=mlp.down.scale)
    (abi : DownFoldVectorMemory.VectorLoad) :
    (TrellisMlpParsedDown.outputBuffer (fromMemory existing packed words scales) abi).bytes=existing.outputBuffer.bytes :=
  output_memory existing packed words scales

-- Framing and the global sequence of writes are inherited from the SAME
-- existing heaps and schedules, rather than re-established for a fresh run.
theorem output_frame (existing : TrellisMlpMemory.Execution mlp input)
    (packed : PackedArrayDownMaterialization.Input mlp.down.width)
    (words : packed.matrix=mlp.down.words) (scales : CheckpointTrellis.scale packed.scales=mlp.down.scale)
    (abi : DownFoldVectorMemory.VectorLoad) {base size : Nat}
    (safe : TrellisMlpMemory.Safe existing base size) (offset : Nat) (bound : offset<size) :
    (TrellisMlpParsedDown.outputBuffer (fromMemory existing packed words scales) abi).bytes (base+offset)=
      existing.source.bytes (base+offset) := by
  rw [output_bytes existing packed words scales abi]
  exact existing.other_region safe offset bound

def gateExecution (existing : TrellisMlpMemory.Execution mlp input)
    (downPacked : PackedArrayDownMaterialization.Input mlp.down.width)
    (words : downPacked.matrix=mlp.down.words) (scales : CheckpointTrellis.scale downPacked.scales=mlp.down.scale)
    (packed : GateInput mlp.gate.width mlp.up.width) (parameters : TrellisMlpParsedGateProjection.Parameters mlp packed)
    (precise : Float32 → Float32) (absolute : BF → BF)
    (exponential : TrellisMlpParsedGateTail.Exponential mlp.activation precise absolute)
    (inputBounded : ∀ group, (existing.device.staging group).inputBase+10240≤2^64) :
    TrellisMlpParsedPipeline.GateExecution (fromMemory existing downPacked words scales) where
  tableBase := mlp.gatePlatform.base
  inputBase := fun group => (existing.device.staging group).inputBase
  packed := packed
  parameters := parameters
  actual := fun group => GateInputTraceTransport.fromTrace (existing.device.staging group)
    mlp.gatePlatform.aligned mlp.gatePlatform.bounded (inputBounded group)
  precise := precise
  absolute := absolute
  exponential := exponential

end Inference.Models.Qwen.TrellisMlpParsedMemory
