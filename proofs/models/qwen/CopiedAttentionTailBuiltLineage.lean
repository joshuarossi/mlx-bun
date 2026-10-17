import models.qwen.CopiedAttentionInitialTailFactory
import models.qwen.CopiedAttentionCapacityTailFactory
import models.qwen.AttentionTailStorageLineage
import models.qwen.DeltaProjectionParameterSource
namespace Inference.Models.Qwen.CopiedAttentionTailBuiltLineage
open Contracts.Mlx Layers Kernels.Attention State
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] AttentionTailConstruction.gating

section Generic
variable {steps : Nat} {query gate : OutputGateDevice.Heads} {cache : Kv.Cache Kv.BF steps}
  {input : SdpaMemory.Input query cache} {p : SdpaVector.Platform} {contracted : Bool} {arch : Char}
  {gatePlatform : OutputGate.Platform} {projection : AffineVerifyLinear.Projection 12 5120}
  (attention : SdpaShared.Execution input p contracted arch)
  (gates : ∀ head, ArrayStorage.BFBuffer (gate head)) (shared : ∀ head, (gates head).bytes=input.cache.memory)
  (gateSafe : ∀ head, SdpaShared.Safe attention (gates head).base 512)
  (weights : AffineDevice.Storage projection) (weightShared : AffineMemory.Shared projection weights input.cache.memory)
  (regions : AttentionTailConstruction.Regions) (allocation : AttentionTailConstruction.Allocation attention gates weights regions)

theorem tail_framed : DeltaProjectionParameterSource.Framed projection weights
    (AffineStorageLineage.launchWeights
      (AttentionTailConstruction.fromStorage (gatePlatform:=gatePlatform) attention gates shared gateSafe weights weightShared regions allocation).projected.affine) := by
  unfold AttentionTailConstruction.fromStorage AttentionTailConstruction.projected AttentionOutputMemory.fromGate
  rw [AffineStorageLineage.fromStorage_weights (steps:=12) (groups:=1280)]
  exact ⟨_,_,rfl⟩
end Generic

namespace Initial
variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (source : ArrayStorage.BFBuffer input) (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
  (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
  {front : AttentionGateCopyFront.Execution layer.mixer (layer.inputNorm.forward input) angle}
  (linked : front.phase.q.source=NormalizationMemory.forwardBuffer normal)
  {cache : Kv.Cache Kv.BF 0} (read : AttentionGateCopyInitialRead.Read front cache)
  (attention : AttentionGateCopyInitialTrellisSuffix.Attention read)
  {tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output}
  (built : CopiedAttentionInitialTailFactory.Built source original normal linked read attention tail)

include built

theorem gates : tail.gates=read.gate := by cases built; rfl

theorem output_addresses :
    AffineStorageLineage.addresses layer.mixer.output (AffineStorageLineage.launchWeights tail.projected.affine)=
      AffineStorageLineage.addresses layer.mixer.output original.mixer.projection := by
  cases built with
  | construct safe gateSafe regions allocation =>
    exact (AttentionTailStorageLineage.fromStorage_addresses attention read.gate read.gates_shared gateSafe
      (CopiedAttentionInitialTailFactory.weights source original normal linked read safe)
      (CopiedAttentionInitialTailFactory.weights_shared source original normal linked read safe) regions allocation).trans
      (AffineStorageLineage.reframe_addresses _ _ _ _)

theorem output_framed : DeltaProjectionParameterSource.Framed layer.mixer.output original.mixer.projection
    (AffineStorageLineage.launchWeights tail.projected.affine) := by
  cases built with
  | construct safe gateSafe regions allocation =>
    exact DeltaProjectionParameterSource.trans layer.mixer.output original.mixer.projection
      (CopiedAttentionInitialTailFactory.weights source original normal linked read safe) _ ⟨_,_,rfl⟩
      (tail_framed attention read.gate read.gates_shared gateSafe
        (CopiedAttentionInitialTailFactory.weights source original normal linked read safe)
        (CopiedAttentionInitialTailFactory.weights_shared source original normal linked read safe) regions allocation)
end Initial

namespace Capacity
variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  (source : ArrayStorage.BFBuffer input) (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
  (normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩)
  {n : Nat} {cache : Kv.Cache Kv.BF n}
  {s : AttentionGateCopyReadConstruction.Input layer.mixer cache (layer.inputNorm.forward input) angle}
  (linked : s.front.phase.q.source=NormalizationMemory.forwardBuffer normal)
  {preparation : AttentionGateCopyFreshRead.Prepared s} (read : AttentionGateCopyFreshRead.Read preparation)
  (attention : AttentionGateCopyCapacityTrellisSuffix.Attention read)
  {tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output}
  (built : CopiedAttentionCapacityTailFactory.Built source original normal linked read attention tail)

include built

theorem gates : tail.gates=read.gate := by cases built; rfl

theorem output_addresses :
    AffineStorageLineage.addresses layer.mixer.output (AffineStorageLineage.launchWeights tail.projected.affine)=
      AffineStorageLineage.addresses layer.mixer.output original.mixer.projection := by
  cases built with
  | construct safe gateSafe regions allocation =>
    exact (AttentionTailStorageLineage.fromStorage_addresses attention read.gate read.gates_shared gateSafe
      (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe)
      (CopiedAttentionCapacityTailFactory.weights_shared source original normal linked read safe) regions allocation).trans
      (AffineStorageLineage.reframe_addresses _ _ _ _)

theorem output_framed : DeltaProjectionParameterSource.Framed layer.mixer.output original.mixer.projection
    (AffineStorageLineage.launchWeights tail.projected.affine) := by
  cases built with
  | construct safe gateSafe regions allocation =>
    exact DeltaProjectionParameterSource.trans layer.mixer.output original.mixer.projection
      (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe) _ ⟨_,_,rfl⟩
      (tail_framed attention read.gate read.gates_shared gateSafe
        (CopiedAttentionCapacityTailFactory.weights source original normal linked read safe)
        (CopiedAttentionCapacityTailFactory.weights_shared source original normal linked read safe) regions allocation)
end Capacity
end Inference.Models.Qwen.CopiedAttentionTailBuiltLineage
