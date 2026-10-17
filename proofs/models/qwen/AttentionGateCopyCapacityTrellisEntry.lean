import models.qwen.AttentionGateCopyCapacityTrellisSuffix
import models.qwen.TrellisWeightsFrameRegions
namespace Inference.Models.Qwen.AttentionGateCopyCapacityTrellisEntry
open Contracts.Mlx Kernels.Attention State Layers
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyFreshRead.Read.input
variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
  {x : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {input : BinaryMemory.Input x layer.inputNorm.weight}
  (normal : NormalizationMemory.Execution layer.inputNorm input)
  {s : AttentionGateCopyReadConstruction.Input layer.mixer cache (layer.inputNorm.forward x) angle}
  (linked : s.front.phase.q.source=NormalizationMemory.forwardBuffer normal)

def Safe (base size : Nat) : Prop := MemoryRegions.Disjoint (2*normal.normalized.base) 10240 base size

include linked in
theorem shared : normal.outputBuffer.bytes=s.front.phase.q.source.bytes :=
  (NormalizationMemory.forward_bytes normal).symm.trans (congrArg ArrayStorage.BFBuffer.bytes linked).symm

def buffer {width : Nat} {value : Fin width → ArrayStorage.BF}
    (original : ArrayStorage.BFBuffer value) (originalShared : original.bytes=input.lhs.bytes)
    (safe : Safe normal original.base (2*width)) : ArrayStorage.BFBuffer value :=
  ArrayFrame.bf original s.front.phase.q.source.bytes (fun offset bound =>
    (congrFun (shared normal linked).symm _).trans ((normal.other_region safe offset bound).trans (congrFun originalShared _).symm))

theorem buffer_shared {width : Nat} {value : Fin width → ArrayStorage.BF}
    (original : ArrayStorage.BFBuffer value) (originalShared : original.bytes=input.lhs.bytes)
    (safe : Safe normal original.base (2*width)) :
    (buffer normal linked original originalShared safe).bytes=s.front.phase.q.source.bytes := by simp only [buffer,ArrayFrame.bf]

def weights (original : TrellisWeightsMemory.Weights layer.suffix.mlp input.lhs.bytes)
    (safe : original.Protected (Safe normal)) : TrellisWeightsMemory.Weights layer.suffix.mlp s.front.phase.q.source.bytes :=
  original.reframe _ (original.protected_mono (fun _ _ separate offset bound =>
    (congrFun (shared normal linked).symm _).trans (normal.other_region separate offset bound)) safe)

theorem weights_regions (original : TrellisWeightsMemory.Weights layer.suffix.mlp input.lhs.bytes)
    (safe : original.Protected (Safe normal)) (property : Nat → Nat → Prop) :
    (weights normal linked original safe).Protected property ↔ original.Protected property :=
  TrellisWeightsFrameRegions.regions original _ _ property

variable {preparation : AttentionGateCopyFreshRead.Prepared s}
  (read : AttentionGateCopyFreshRead.Read preparation)
  (attention : AttentionGateCopyCapacityTrellisSuffix.Attention read)
  (tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward x) angle).gate layer.mixer.gate layer.mixer.output)

structure Input where
  residualNormal : Safe normal input.lhs.base 10240
  residualPrefix : AttentionGateCopyCapacityTrellisFrames.Safe read input.lhs.base 10240
  residualTail : AttentionTailMemory.Safe tail input.lhs.base 10240
  norm : ArrayStorage.BFBuffer layer.suffix.norm.weight
  normShared : norm.bytes=input.lhs.bytes
  normNormal : Safe normal norm.base 10240
  normPrefix : AttentionGateCopyCapacityTrellisFrames.Safe read norm.base 10240
  normTail : AttentionTailMemory.Safe tail norm.base 10240
  parameters : TrellisWeightsMemory.Weights layer.suffix.mlp input.lhs.bytes
  parametersNormal : parameters.Protected (Safe normal)
  parametersPrefix : parameters.Protected (AttentionGateCopyCapacityTrellisFrames.Safe read)
  parametersTail : parameters.Protected (AttentionTailMemory.Safe tail)

variable (original : Input normal read attention tail)

theorem parametersPrefix : (weights normal linked original.parameters original.parametersNormal).Protected (AttentionGateCopyCapacityTrellisFrames.Safe read) :=
  (weights_regions normal linked original.parameters original.parametersNormal _).mpr original.parametersPrefix

def suffixInput : AttentionGateCopyCapacityTrellisSuffix.Input read attention tail (x:=x) (block:=layer.suffix) where
  residual := buffer normal linked input.lhs rfl original.residualNormal
  residualShared := buffer_shared normal linked input.lhs rfl original.residualNormal
  residualPrefix := original.residualPrefix
  residualTail := original.residualTail
  norm := buffer normal linked original.norm original.normShared original.normNormal
  normShared := buffer_shared normal linked original.norm original.normShared original.normNormal
  normPrefix := original.normPrefix
  normTail := original.normTail
  parameters := weights normal linked original.parameters original.parametersNormal
  parametersPrefix := parametersPrefix normal linked read attention tail original
  parametersTail := (weights_regions normal linked original.parameters original.parametersNormal _).mpr original.parametersTail
end Inference.Models.Qwen.AttentionGateCopyCapacityTrellisEntry
