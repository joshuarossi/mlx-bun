import kernels.trellis.PackedArrayConsumer
import models.qwen.TrellisWeightsMemory
namespace Inference.Kernels.Trellis.PackedArrayWeights
open Contracts.Mlx Models.Qwen Layers WrittenLayers PackedArrayMaterialization PackedArrayDownMaterialization
set_option maxRecDepth 10000
variable {mlp : GateDown} {memory : ByteMemory.Bytes}

def gate (weights : TrellisWeightsMemory.Weights mlp memory) : GateInput mlp.gate.width mlp.up.width where
  validG:=mlp.gate.validWidth
  validU:=mlp.up.validWidth
  gateCodes:=weights.gateCodes
  upCodes:=weights.upCodes
  gateScales:=weights.gateScales
  upScales:=weights.upScales
  gate:=weights.gate
  up:=weights.up
  shared:=weights.upShared.trans weights.gateShared.symm

def down (weights : TrellisWeightsMemory.Weights mlp memory) : Input mlp.down.width where
  valid:=mlp.down.validWidth
  codes:=weights.downCodes
  scales:=weights.downScales
  storage:=weights.down

theorem gate_matrix (weights : TrellisWeightsMemory.Weights mlp memory) (isUp : Bool) :
    (gate weights).matrix isUp=if isUp then mlp.up.words else mlp.gate.words := by
  cases isUp with
  | false =>
    exact congrArg TrellisCodebookGateUp.Projection.words weights.gateBinding
  | true =>
    exact congrArg TrellisCodebookGateUp.Projection.words weights.upBinding

theorem down_matrix (weights : TrellisWeightsMemory.Weights mlp memory) :
    (down weights).matrix=mlp.down.words :=
  congrArg TrellisCodebookDown.Projection.words weights.downBinding

-- Exact original loaded buffers and their pointers are retained in the
-- constructor. There is no replacement attachment for private/local words.
theorem gate_heap (weights : TrellisWeightsMemory.Weights mlp memory) :
    (gate weights).gate.code.bytes=memory ∧ (gate weights).up.code.bytes=memory :=
  ⟨weights.gateShared,weights.upShared⟩
theorem down_heap (weights : TrellisWeightsMemory.Weights mlp memory) :
    (down weights).storage.code.bytes=memory := weights.downShared
end Inference.Kernels.Trellis.PackedArrayWeights
