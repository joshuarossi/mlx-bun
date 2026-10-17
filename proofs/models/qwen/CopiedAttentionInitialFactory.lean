import models.qwen.CopiedAttentionOriginalInitialStage
namespace Inference.Models.Qwen.CopiedAttentionInitialFactory
open Contracts.Mlx Layers Kernels Kernels.Attention State
set_option maxRecDepth 10000
set_option genSizeOf false
set_option maxHeartbeats 2000000
attribute [local irreducible] CopiedAttentionOriginalBundle.front CopiedAttentionOriginalBundle.normalized
  CopiedAttentionOriginalInitialStage.prepared
structure Plan (layer : ResidualAttention.Layer) (cache : Kv.Cache Kv.BF 0)
    (input : Fin 5120 → ArrayStorage.BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (original : DecodeParameterMemory.AttentionStorage layer source.bytes) where
  normal : NormalizationMemory.Execution layer.inputNorm ⟨source,original.norm,original.normShared⟩
  safe : original.Protected (MemoryRegions.Disjoint (2*normal.normalized.base) 10240)
  live : Nat → Nat → Prop
  regions : original.Protected live
  projections : CopiedAttentionProjectionConstruction.Plan (input:=layer.inputNorm.forward input) layer.mixer.projections
    (NormalizationMemory.forwardBuffer normal) (CopiedAttentionOriginalBundle.normalized (layer:=layer) source original normal safe).projections live
  queryCopy : CopiedAttentionParameterConstruction.QueryAllocation (layer:=layer.mixer)
    (CopiedAttentionOriginalBundle.normalized (layer:=layer) source original normal safe).projections projections
  native : CopiedAttentionFrontConstruction.Native (layer:=layer.mixer)
    (CopiedAttentionOriginalBundle.normalized (layer:=layer) source original normal safe).projections projections queryCopy
    (CopiedAttentionOriginalBundle.normalized (layer:=layer) source original normal safe).mixer
    (CopiedAttentionOriginalBundle.current_regions (layer:=layer) source original normal safe regions).2.2.1 angle
  read : AttentionGateCopyInitialRead.Read
    (CopiedAttentionOriginalBundle.front (layer:=layer) source original normal safe regions projections queryCopy angle native) cache
  attention : AttentionGateCopyInitialTrellisSuffix.Attention (layer:=layer.mixer) read
  tail : AttentionTailMemory.Execution attention (layer.mixer.heads (layer.inputNorm.forward input) angle).gate layer.mixer.gate layer.mixer.output
  geometry : CopiedAttentionOriginalInitialStage.Regions (layer:=layer) source original normal read attention tail
  suffix : AttentionSuffixAllocation.Plan tail
    (CopiedAttentionOriginalInitialStage.prepared (layer:=layer) source original normal safe regions projections queryCopy angle native read attention tail geometry)

variable {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0}
  {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
  {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (plan : Plan layer cache input angle source original)
def stage : AttentionGateCopyInitialResidualStage.Plan layer cache input angle :=
  CopiedAttentionOriginalInitialStage.stage source original plan.normal plan.safe plan.regions plan.projections plan.queryCopy angle
    plan.native plan.read plan.attention plan.tail plan.geometry plan.suffix

theorem input_source : (stage plan).input.lhs=source := rfl
theorem normalization_weights : (stage plan).input.rhs=original.norm := rfl
theorem suffix_weights : (stage plan).original.parameters=original.suffix.trellis := rfl
end Inference.Models.Qwen.CopiedAttentionInitialFactory
